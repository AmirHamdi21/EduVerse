import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../question_bank/question_bank_localized_labels.dart';
import '../question_bank/question_form_menu_field.dart';
import '../shared/instructor_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uniqueChapters = _uniqueChapters(chapters);
    final uniqueGroups = _uniqueGroups(groups);
    final selectedChapterId =
        uniqueChapters.any((chapter) => chapter.id == rule.chapterId)
        ? rule.chapterId
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: MediaQuery.sizeOf(context).width >= 700,
        maintainState: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.18 : 0.1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.rule_folder_outlined,
            color: InstructorColors.primary,
            size: 21,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedGenerationScope(l10n, rule.scope),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SummaryPill(
                  label: '${rule.count} ${l10n.questions}',
                  icon: Icons.format_list_numbered_rounded,
                  color: InstructorColors.teal,
                ),
                _SummaryPill(
                  label: '${rule.weightPerQuestion} ${l10n.examWeightUnits}',
                  icon: Icons.monitor_weight_outlined,
                  color: InstructorColors.orange,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: InstructorColors.error,
              ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ],
        ),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
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
                    child: QuestionFormMenuField<ExamGenerationScope>(
                      label: l10n.examGenerationRules,
                      value: rule.scope,
                      icon: Icons.account_tree_outlined,
                      color: InstructorColors.primary,
                      options: ExamGenerationScope.values
                          .map(
                            (scope) =>
                                QuestionFormMenuOption<ExamGenerationScope>(
                                  value: scope,
                                  label: localizedGenerationScope(l10n, scope),
                                  icon: Icons.account_tree_outlined,
                                ),
                          )
                          .toList(),
                      onChanged: (scope) {
                        if (scope != null) onChanged(_normalizeForScope(scope));
                      },
                    ),
                  ),
                  if (rule.scope == ExamGenerationScope.chapters)
                    SizedBox(
                      width: constraints.maxWidth,
                      child: _multiChapters(context, uniqueChapters),
                    ),
                  if (rule.scope == ExamGenerationScope.group)
                    SizedBox(
                      width: constraints.maxWidth,
                      child: _multiGroups(context, uniqueGroups),
                    ),
                  if (rule.scope == ExamGenerationScope.group)
                    SizedBox(
                      width: constraints.maxWidth,
                      child: _HintStrip(text: l10n.examGroupScopeKeepsPrompt),
                    ),
                  if (rule.scope == ExamGenerationScope.chapter)
                    SizedBox(
                      width: width,
                      child: QuestionFormMenuField<int>(
                        label: l10n.chapter,
                        value: selectedChapterId,
                        icon: Icons.menu_book_outlined,
                        color: InstructorColors.primary,
                        options: uniqueChapters
                            .map(
                              (chapter) => QuestionFormMenuOption<int>(
                                value: chapter.id,
                                label: chapter.name,
                                icon: Icons.menu_book_outlined,
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            onChanged(rule.copyWith(chapterId: value)),
                      ),
                    ),
                  SizedBox(
                    width: width,
                    child: _NumberField(
                      label: l10n.examQuestionCount,
                      value: rule.count.toString(),
                      icon: Icons.format_list_numbered_rounded,
                      color: InstructorColors.teal,
                      onChanged: (value) =>
                          onChanged(rule.copyWith(count: int.tryParse(value))),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _NumberField(
                      label: l10n.examWeightPerQuestion,
                      value: rule.weightPerQuestion.toString(),
                      icon: Icons.monitor_weight_outlined,
                      color: InstructorColors.orange,
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          weightPerQuestion: double.tryParse(value),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _optionalEnum<QuestionBankType>(
                      context: context,
                      label: l10n.type,
                      value: rule.questionType,
                      values: QuestionBankType.values,
                      icon: Icons.category_outlined,
                      color: InstructorColors.primary,
                      text: (value) => localizedQuestionType(l10n, value),
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          questionType: value,
                          clearQuestionType: value == null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _optionalEnum<QuestionBankDifficulty>(
                      context: context,
                      label: l10n.difficulty,
                      value: rule.difficulty,
                      values: QuestionBankDifficulty.values,
                      icon: Icons.speed_outlined,
                      color: InstructorColors.teal,
                      text: (value) => localizedDifficulty(l10n, value),
                      onChanged: (value) => onChanged(
                        rule.copyWith(
                          difficulty: value,
                          clearDifficulty: value == null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _optionalEnum<BloomLevel>(
                      context: context,
                      label: l10n.qbBloomLevel,
                      value: rule.bloomLevel,
                      values: BloomLevel.values,
                      icon: Icons.lightbulb_outline_rounded,
                      color: InstructorColors.accent,
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _multiChapters(
    BuildContext context,
    List<CourseChapterModel> uniqueChapters,
  ) {
    final l10n = AppLocalizations.of(context);
    return _MultiPickerShell(
      label: l10n.allChapters,
      icon: Icons.menu_book_outlined,
      color: InstructorColors.primary,
      children: uniqueChapters.map((chapter) {
        final selected = rule.chapterIds.contains(chapter.id);
        return _SelectablePill(
          label: chapter.name,
          selected: selected,
          color: InstructorColors.primary,
          onTap: () {
            final next = [...rule.chapterIds];
            selected ? next.remove(chapter.id) : next.add(chapter.id);
            onChanged(rule.copyWith(chapterIds: next));
          },
        );
      }).toList(),
    );
  }

  Widget _multiGroups(
    BuildContext context,
    List<QuestionBankGroupModel> uniqueGroups,
  ) {
    final l10n = AppLocalizations.of(context);
    return _MultiPickerShell(
      label: l10n.qbGroups,
      icon: Icons.folder_copy_outlined,
      color: InstructorColors.accent,
      children: uniqueGroups.map((group) {
        final selected = rule.groupIds.contains(group.id);
        return _SelectablePill(
          label: group.title ?? '${l10n.qbGroups} ${group.id}',
          selected: selected,
          color: InstructorColors.accent,
          onTap: () {
            final next = [...rule.groupIds];
            selected ? next.remove(group.id) : next.add(group.id);
            onChanged(rule.copyWith(groupIds: next));
          },
        );
      }).toList(),
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
    required IconData icon,
    required Color color,
    required String Function(T) text,
    required ValueChanged<T?> onChanged,
  }) {
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
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ValueChanged<String> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(widget.icon, color: widget.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiPickerShell extends StatelessWidget {
  const _MultiPickerShell({
    required this.label,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        maintainState: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsetsDirectional.fromSTEB(12, 4, 10, 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(icon, color: color, size: 18),
        title: Text(
          label,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(spacing: 8, runSpacing: 8, children: children),
          ),
        ],
      ),
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.18 : 0.1)
              : InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : InstructorColors.borderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected
                  ? color
                  : InstructorColors.textTertiaryColor(isDark),
              size: 16,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? color
                      : InstructorColors.textSecondaryColor(isDark),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintStrip extends StatelessWidget {
  const _HintStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: InstructorColors.teal.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: InstructorColors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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
