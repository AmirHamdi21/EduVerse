import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../question_bank/question_bank_localized_labels.dart';
import 'exam_generator_localized_labels.dart';

class ExamGenerationRuleCard extends StatelessWidget {
  const ExamGenerationRuleCard({
    super.key,
    required this.rule,
    required this.chapters,
    this.groups = const <QuestionBankGroupModel>[],
    required this.onChanged,
    this.onRemove,
  });

  final ExamGenerationRuleModel rule;
  final List<CourseChapterModel> chapters;
  final List<QuestionBankGroupModel> groups;
  final ValueChanged<ExamGenerationRuleModel> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uniqueChapters = _uniqueChapters(chapters);
    final uniqueGroups = _uniqueGroups(groups);
    final selectedChapterId =
        uniqueChapters
                .where((chapter) => chapter.id == rule.chapterId)
                .length ==
            1
        ? rule.chapterId
        : null;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: ExpansionTile(
        initiallyExpanded: MediaQuery.sizeOf(context).width >= 700,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _summary(l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.examGenerationRules,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExamGenerationScope.values.map((scope) {
                    return ChoiceChip(
                      label: Text(localizedGenerationScope(l10n, scope)),
                      selected: rule.scope == scope,
                      onSelected: (_) => onChanged(_normalizeForScope(scope)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (rule.scope == ExamGenerationScope.chapter)
                    _box(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: selectedChapterId,
                        decoration: InputDecoration(labelText: l10n.chapter),
                        items: uniqueChapters
                            .map(
                              (chapter) => DropdownMenuItem(
                                value: chapter.id,
                                child: Text(
                                  chapter.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            onChanged(rule.copyWith(chapterId: value)),
                      ),
                    ),
                  if (rule.scope == ExamGenerationScope.chapters)
                    _wide(_multiChapters(l10n, uniqueChapters)),
                  if (rule.scope == ExamGenerationScope.group)
                    _wide(_multiGroups(l10n, uniqueGroups)),
                  if (rule.scope == ExamGenerationScope.group)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.examGroupScopeKeepsPrompt,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  _box(
                    TextFormField(
                      initialValue: rule.count.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.examQuestionCount,
                      ),
                      onChanged: (value) =>
                          onChanged(rule.copyWith(count: int.tryParse(value))),
                    ),
                  ),
                  _box(
                    TextFormField(
                      initialValue: rule.weightPerQuestion.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.examWeightPerQuestion,
                      ),
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          weightPerQuestion: double.tryParse(value),
                        ),
                      ),
                    ),
                  ),
                  _box(
                    _optionalEnum<QuestionBankType>(
                      context: context,
                      label: l10n.type,
                      value: rule.questionType,
                      values: QuestionBankType.values,
                      text: (value) => localizedQuestionType(l10n, value),
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          questionType: value,
                          clearQuestionType: value == null,
                        ),
                      ),
                    ),
                  ),
                  _box(
                    _optionalEnum<QuestionBankDifficulty>(
                      context: context,
                      label: l10n.difficulty,
                      value: rule.difficulty,
                      values: QuestionBankDifficulty.values,
                      text: (value) => localizedDifficulty(l10n, value),
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          difficulty: value,
                          clearDifficulty: value == null,
                        ),
                      ),
                    ),
                  ),
                  _box(
                    _optionalEnum<BloomLevel>(
                      context: context,
                      label: l10n.qbBloomLevel,
                      value: rule.bloomLevel,
                      values: BloomLevel.values,
                      text: (value) => localizedBloomLevel(l10n, value),
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          bloomLevel: value,
                          clearBloomLevel: value == null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _summary(AppLocalizations l10n) {
    return '${localizedGenerationScope(l10n, rule.scope)} • '
        '${rule.count} ${l10n.questions} • '
        '${rule.weightPerQuestion} ${l10n.examWeightPerQuestion}';
  }

  Widget _box(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: child,
    );
  }

  Widget _wide(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 560),
      child: child,
    );
  }

  Widget _multiChapters(
    AppLocalizations l10n,
    List<CourseChapterModel> uniqueChapters,
  ) {
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.allChapters),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: uniqueChapters.map((chapter) {
          final selected = rule.chapterIds.contains(chapter.id);
          return FilterChip(
            label: Text(chapter.name),
            selected: selected,
            onSelected: (value) {
              final next = [...rule.chapterIds];
              value ? next.add(chapter.id) : next.remove(chapter.id);
              onChanged(rule.copyWith(chapterIds: next));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _multiGroups(
    AppLocalizations l10n,
    List<QuestionBankGroupModel> uniqueGroups,
  ) {
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.qbGroups),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: uniqueGroups.map((group) {
          final selected = rule.groupIds.contains(group.id);
          return FilterChip(
            label: Text(group.title ?? '${l10n.qbGroups} ${group.id}'),
            selected: selected,
            onSelected: (value) {
              final next = [...rule.groupIds];
              value ? next.add(group.id) : next.remove(group.id);
              onChanged(rule.copyWith(groupIds: next));
            },
          );
        }).toList(),
      ),
    );
  }

  List<CourseChapterModel> _uniqueChapters(List<CourseChapterModel> source) {
    final seen = <int>{};
    return [
      for (final chapter in source)
        if (seen.add(chapter.id)) chapter,
    ];
  }

  List<QuestionBankGroupModel> _uniqueGroups(
    List<QuestionBankGroupModel> source,
  ) {
    final seen = <int>{};
    return [
      for (final group in source)
        if (seen.add(group.id)) group,
    ];
  }

  ExamGenerationRuleModel _normalizeForScope(ExamGenerationScope scope) {
    return rule.copyWith(
      scope: scope,
      chapterId:
          rule.chapterId ?? (chapters.isNotEmpty ? chapters.first.id : null),
      chapterIds: rule.chapterIds.isNotEmpty
          ? rule.chapterIds
          : chapters.isNotEmpty
          ? [chapters.first.id]
          : const <int>[],
      groupIds: rule.groupIds.isNotEmpty
          ? rule.groupIds
          : groups.isNotEmpty
          ? [groups.first.id]
          : const <int>[],
    );
  }

  Widget _optionalEnum<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T) text,
    required ValueChanged<T?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<T?>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T?>(value: null, child: Text(l10n.allStates)),
        ...values.map(
          (item) => DropdownMenuItem<T?>(value: item, child: Text(text(item))),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
