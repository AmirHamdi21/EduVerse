import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../question_bank/question_bank_localized_labels.dart';
import '../question_bank/question_text_renderer.dart';

class ExamCandidateQuestionPicker extends StatefulWidget {
  const ExamCandidateQuestionPicker({
    super.key,
    required this.questions,
    required this.onSelected,
    this.chapters = const <CourseChapterModel>[],
    this.groups = const <QuestionBankGroupModel>[],
    this.hasMore = false,
    this.isLoading = false,
    this.onFiltersChanged,
    this.onLoadMore,
  });

  final List<QuestionBankQuestionModel> questions;
  final ValueChanged<int> onSelected;
  final List<CourseChapterModel> chapters;
  final List<QuestionBankGroupModel> groups;
  final bool hasMore;
  final bool isLoading;
  final void Function({
    int? chapterId,
    int? groupId,
    QuestionBankType? questionType,
    QuestionBankDifficulty? difficulty,
    BloomLevel? bloomLevel,
    String? search,
  })?
  onFiltersChanged;
  final VoidCallback? onLoadMore;

  @override
  State<ExamCandidateQuestionPicker> createState() =>
      _ExamCandidateQuestionPickerState();
}

class _ExamCandidateQuestionPickerState
    extends State<ExamCandidateQuestionPicker> {
  QuestionBankType? _type;
  QuestionBankDifficulty? _difficulty;
  BloomLevel? _bloom;
  int? _chapterId;
  int? _groupId;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.examCandidatePicker,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _box(
              _intDropdown(
                l10n.chapter,
                _chapterId,
                widget.chapters
                    .map((chapter) => MapEntry(chapter.id, chapter.name))
                    .toList(),
                (value) => setState(() => _chapterId = value),
              ),
            ),
            _box(
              _intDropdown(
                l10n.qbGroups,
                _groupId,
                widget.groups
                    .map(
                      (group) => MapEntry(
                        group.id,
                        group.title ?? '${l10n.qbGroups} ${group.id}',
                      ),
                    )
                    .toList(),
                (value) => setState(() => _groupId = value),
              ),
            ),
            _box(
              _enum<QuestionBankType>(
                l10n.type,
                _type,
                QuestionBankType.values,
                (value) => localizedQuestionType(l10n, value),
                (value) => setState(() => _type = value),
              ),
            ),
            _box(
              _enum<QuestionBankDifficulty>(
                l10n.difficulty,
                _difficulty,
                QuestionBankDifficulty.values,
                (value) => localizedDifficulty(l10n, value),
                (value) => setState(() => _difficulty = value),
              ),
            ),
            _box(
              _enum<BloomLevel>(
                l10n.qbBloomLevel,
                _bloom,
                BloomLevel.values,
                (value) => localizedBloomLevel(l10n, value),
                (value) => setState(() => _bloom = value),
              ),
            ),
            _box(
              TextField(
                decoration: InputDecoration(labelText: l10n.search),
                onChanged: (value) => _search = value,
                onSubmitted: (_) => _apply(),
              ),
            ),
            FilledButton.icon(
              onPressed: widget.isLoading ? null : _apply,
              icon: const Icon(Icons.filter_alt_outlined),
              label: Text(l10n.applyFilters),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.isLoading && widget.questions.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (widget.questions.isEmpty)
          Text(l10n.questionBankEmptyMessage)
        else ...[
          ...widget.questions.map(
            (question) => ListTile(
              leading: question.questionImageUrl == null
                  ? const CircleAvatar(child: Icon(Icons.quiz_outlined))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        question.questionImageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const CircleAvatar(
                          child: Icon(Icons.image_outlined),
                        ),
                      ),
                    ),
              title: QuestionFormattedText(
                text: question.questionText,
                fallback: '${l10n.questions} ${question.id}',
              ),
              subtitle: Text(
                '${localizedQuestionType(l10n, question.questionType)} • '
                '${localizedDifficulty(l10n, question.difficulty)} • '
                '${localizedBloomLevel(l10n, question.bloomLevel)}'
                '${question.groups.isNotEmpty ? ' • ${question.groups.first.title ?? '${l10n.qbGroups} ${question.groups.first.groupId}'}' : ''}',
              ),
              onTap: () => widget.onSelected(question.id),
            ),
          ),
          if (widget.hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: widget.isLoading ? null : widget.onLoadMore,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more),
                label: Text(l10n.loadMore),
              ),
            ),
        ],
      ],
    );
  }

  void _apply() {
    widget.onFiltersChanged?.call(
      chapterId: _chapterId,
      groupId: _groupId,
      questionType: _type,
      difficulty: _difficulty,
      bloomLevel: _bloom,
      search: _search,
    );
  }

  Widget _intDropdown(
    String label,
    int? value,
    List<MapEntry<int, String>> entries,
    ValueChanged<int?> onChanged,
  ) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<int?>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<int?>(value: null, child: Text(l10n.allStates)),
        ...entries.map(
          (entry) => DropdownMenuItem<int?>(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _box(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      child: child,
    );
  }

  Widget _enum<T>(
    String label,
    T? value,
    List<T> values,
    String Function(T) text,
    ValueChanged<T?> onChanged,
  ) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<T?>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T?>(value: null, child: Text(l10n.allStates)),
        ...values.map(
          (item) => DropdownMenuItem<T?>(
            value: item,
            child: Text(text(item), overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
