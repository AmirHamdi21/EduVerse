import 'dart:async';

import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../question_bank/question_bank_localized_labels.dart';
import '../question_bank/question_form_menu_field.dart';
import '../question_bank/question_text_renderer.dart';
import '../shared/instructor_colors.dart';

class ExamCandidateQuestionPicker extends StatefulWidget {
  const ExamCandidateQuestionPicker({
    super.key,
    required this.questions,
    required this.onSelected,
    this.existingQuestionIds = const <int>{},
    this.questionsNeedingOverride = const <int>{},
    this.overrideReasonsByQuestionId = const <int, List<String>>{},
    this.chapters = const <CourseChapterModel>[],
    this.groups = const <QuestionBankGroupModel>[],
    this.hasMore = false,
    this.isLoading = false,
    this.onFiltersChanged,
    this.onLoadMore,
  });

  final List<QuestionBankQuestionModel> questions;
  final ValueChanged<QuestionBankQuestionModel> onSelected;
  final Set<int> existingQuestionIds;
  final Set<int> questionsNeedingOverride;
  final Map<int, List<String>> overrideReasonsByQuestionId;
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
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.playlist_add_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.examCandidatePicker,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.examCandidatePickerHint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _SearchField(onChanged: _onSearchChanged),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 620;
              final gap = narrow ? 10.0 : 12.0;
              final width = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<int?>(
                      label: l10n.chapter,
                      value: _chapterId,
                      icon: Icons.menu_book_outlined,
                      color: InstructorColors.primary,
                      options: [
                        QuestionFormMenuOption<int?>(
                          value: null,
                          label: l10n.allStates,
                          icon: Icons.select_all_rounded,
                        ),
                        ...widget.chapters.map(
                          (chapter) => QuestionFormMenuOption<int?>(
                            value: chapter.id,
                            label: chapter.name,
                            icon: Icons.menu_book_outlined,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _chapterId = value);
                        _apply();
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<int?>(
                      label: l10n.qbGroups,
                      value: _groupId,
                      icon: Icons.folder_copy_outlined,
                      color: InstructorColors.accent,
                      options: [
                        QuestionFormMenuOption<int?>(
                          value: null,
                          label: l10n.allStates,
                          icon: Icons.select_all_rounded,
                        ),
                        ...widget.groups.map(
                          (group) => QuestionFormMenuOption<int?>(
                            value: group.id,
                            label:
                                group.title ?? '${l10n.qbGroups} ${group.id}',
                            icon: Icons.folder_copy_outlined,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _groupId = value);
                        _apply();
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _enum<QuestionBankType>(
                      l10n.type,
                      _type,
                      QuestionBankType.values,
                      (value) => localizedQuestionType(l10n, value),
                      (value) {
                        setState(() => _type = value);
                        _apply();
                      },
                      Icons.category_outlined,
                      InstructorColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _enum<QuestionBankDifficulty>(
                      l10n.difficulty,
                      _difficulty,
                      QuestionBankDifficulty.values,
                      (value) => localizedDifficulty(l10n, value),
                      (value) {
                        setState(() => _difficulty = value);
                        _apply();
                      },
                      Icons.speed_outlined,
                      InstructorColors.teal,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _enum<BloomLevel>(
                      l10n.qbBloomLevel,
                      _bloom,
                      BloomLevel.values,
                      (value) => localizedBloomLevel(l10n, value),
                      (value) {
                        setState(() => _bloom = value);
                        _apply();
                      },
                      Icons.lightbulb_outline_rounded,
                      InstructorColors.accent,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (widget.isLoading && widget.questions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            )
          else if (widget.questions.isEmpty)
            _EmptyPicker(message: l10n.questionBankEmptyMessage)
          else ...[
            ...widget.questions.map(
              (question) => _CandidateCard(
                question: question,
                onSelected: widget.onSelected,
                alreadyInDraft:
                    widget.existingQuestionIds.contains(question.id) ||
                    widget.existingQuestionIds.contains(question.questionId),
                needsOverride:
                    widget.questionsNeedingOverride.contains(question.id) ||
                    widget.questionsNeedingOverride.contains(
                      question.questionId,
                    ),
                overrideReasons:
                    widget.overrideReasonsByQuestionId[question.id] ??
                    widget.overrideReasonsByQuestionId[question.questionId] ??
                    const <String>[],
              ),
            ),
            if (widget.hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: widget.isLoading ? null : widget.onLoadMore,
                    icon: widget.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more_rounded),
                    label: Text(l10n.loadMore),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _enum<T>(
    String label,
    T? value,
    List<T> values,
    String Function(T) text,
    ValueChanged<T?> onChanged,
    IconData icon,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context);
    return QuestionFormMenuField<T?>(
      label: label,
      value: value,
      icon: icon,
      color: color,
      options: [
        QuestionFormMenuOption<T?>(
          value: null,
          label: l10n.allStates,
          icon: Icons.select_all_rounded,
        ),
        ...values.map(
          (item) => QuestionFormMenuOption<T?>(
            value: item,
            label: text(item),
            icon: icon,
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  void _onSearchChanged(String value) {
    _search = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 260), _apply);
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
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: l10n.examSearchApprovedQuestionsHint,
        prefixIcon: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
          decoration: BoxDecoration(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.18 : 0.1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.search_rounded,
            color: InstructorColors.primary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: InstructorColors.surfaceColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.question,
    required this.onSelected,
    required this.alreadyInDraft,
    required this.needsOverride,
    required this.overrideReasons,
  });

  final QuestionBankQuestionModel question;
  final ValueChanged<QuestionBankQuestionModel> onSelected;
  final bool alreadyInDraft;
  final bool needsOverride;
  final List<String> overrideReasons;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: alreadyInDraft || needsOverride
          ? null
          : () => onSelected(question),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            question.questionImageUrl == null
                ? Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: InstructorColors.primary.withValues(
                        alpha: isDark ? 0.18 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.quiz_outlined,
                      color: InstructorColors.primary,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      question.questionImageUrl!,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        color: InstructorColors.primary,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestionFormattedText(
                    text: question.questionText,
                    fallback: '${l10n.questions} ${question.id}',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _MiniPill(
                        label: localizedQuestionType(
                          l10n,
                          question.questionType,
                        ),
                        color: InstructorColors.primary,
                      ),
                      _MiniPill(
                        label: localizedDifficulty(l10n, question.difficulty),
                        color: InstructorColors.teal,
                      ),
                      _MiniPill(
                        label: localizedBloomLevel(l10n, question.bloomLevel),
                        color: InstructorColors.accent,
                      ),
                      if (alreadyInDraft)
                        _MiniPill(
                          label: l10n.examQuestionAlreadyInDraft,
                          color: InstructorColors.success,
                        )
                      else if (needsOverride)
                        _MiniPill(
                          label: l10n.examNeedsOverride,
                          color: InstructorColors.warning,
                        ),
                    ],
                  ),
                  if (needsOverride && overrideReasons.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    _MismatchNote(reason: overrideReasons.first),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CandidateActions(
              alreadyInDraft: alreadyInDraft,
              needsOverride: needsOverride,
              onAdd: () => onSelected(question),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateActions extends StatelessWidget {
  const _CandidateActions({
    required this.alreadyInDraft,
    required this.needsOverride,
    required this.onAdd,
  });

  final bool alreadyInDraft;
  final bool needsOverride;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (alreadyInDraft) {
      return Tooltip(
        message: l10n.examQuestionAlreadyInDraftHint,
        child: const Icon(
          Icons.check_circle_rounded,
          color: InstructorColors.success,
        ),
      );
    }
    if (needsOverride) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: l10n.examNeedsOverrideHint,
            child: const Icon(
              Icons.warning_amber_rounded,
              color: InstructorColors.warning,
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: l10n.examAddQuestionWithOverride,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onAdd,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: InstructorColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: InstructorColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Tooltip(
      message: l10n.examAddQuestion,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onAdd,
        child: const Icon(
          Icons.add_circle_outline_rounded,
          color: InstructorColors.primary,
        ),
      ),
    );
  }
}

class _MismatchNote extends StatelessWidget {
  const _MismatchNote({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: InstructorColors.warning.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: InstructorColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: InstructorColors.warning,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: InstructorColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: isDark ? 0.16 : 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_off_rounded, color: InstructorColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: InstructorColors.primary),
    );
  }
}
