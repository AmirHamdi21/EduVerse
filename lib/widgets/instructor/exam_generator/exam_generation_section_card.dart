import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
import '../question_bank/question_form_menu_field.dart';
import '../shared/instructor_colors.dart';
import 'exam_generation_rule_card.dart';
import 'exam_generator_localized_labels.dart';

class ExamGenerationSectionCard extends StatelessWidget {
  const ExamGenerationSectionCard({
    super.key,
    required this.section,
    required this.chapters,
    this.groups = const <QuestionBankGroupModel>[],
    required this.onChanged,
    this.onRemove,
  });

  final ExamGenerationSectionModel section;
  final List<CourseChapterModel> chapters;
  final List<QuestionBankGroupModel> groups;
  final ValueChanged<ExamGenerationSectionModel> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: InstructorColors.accent.withValues(
              alpha: isDark ? 0.18 : 0.1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.view_agenda_outlined,
            color: InstructorColors.accent,
            size: 21,
          ),
        ),
        title: Text(
          '${section.title} • ${section.rules.fold<int>(0, (sum, rule) => sum + rule.count)} ${l10n.questions}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w900,
          ),
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
                    child: _ModernTextField(
                      label: l10n.title,
                      value: section.title,
                      icon: Icons.title_rounded,
                      color: InstructorColors.accent,
                      onChanged: (value) => _emit(title: value),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      label: l10n.totalMarks,
                      value: section.totalMarks.toString(),
                      icon: Icons.star_outline_rounded,
                      color: InstructorColors.orange,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _emit(totalMarks: double.tryParse(value)),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<ExamSectionAnswerPolicy>(
                      label: l10n.examAnswerPolicy,
                      value: section.answerPolicy,
                      icon: Icons.checklist_rounded,
                      color: InstructorColors.teal,
                      options: ExamSectionAnswerPolicy.values
                          .map(
                            (value) =>
                                QuestionFormMenuOption<ExamSectionAnswerPolicy>(
                                  value: value,
                                  label: localizedAnswerPolicy(l10n, value),
                                  icon: Icons.checklist_rounded,
                                ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _emit(answerPolicy: value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      label: l10n.examRequiredAnswerCount,
                      value: section.requiredAnswerCount?.toString() ?? '',
                      icon: Icons.done_all_rounded,
                      color: InstructorColors.primary,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _emit(requiredAnswerCount: int.tryParse(value)),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _ModernTextField(
                      label: l10n.instructions,
                      value: section.instructions ?? '',
                      icon: Icons.notes_rounded,
                      color: InstructorColors.primary,
                      minLines: 2,
                      maxLines: 4,
                      onChanged: (value) => _emit(instructions: value),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      children: [
                        ...section.rules.asMap().entries.map(
                          (entry) => ExamGenerationRuleCard(
                            rule: entry.value,
                            chapters: chapters,
                            groups: groups,
                            onChanged: (rule) {
                              final next = [...section.rules];
                              next[entry.key] = rule;
                              _emit(rules: next);
                            },
                            onRemove: section.rules.length <= 1
                                ? null
                                : () {
                                    final next = [...section.rules]
                                      ..removeAt(entry.key);
                                    _emit(rules: next);
                                  },
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _AddButton(
                            label: l10n.examAddRule,
                            onPressed: chapters.isEmpty
                                ? null
                                : () => _emit(
                                    rules: [
                                      ...section.rules,
                                      ExamGenerationRuleModel(
                                        chapterId: chapters.first.id,
                                        count: 1,
                                        weightPerQuestion: 1,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
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

  void _emit({
    String? title,
    String? instructions,
    double? totalMarks,
    ExamSectionAnswerPolicy? answerPolicy,
    int? requiredAnswerCount,
    List<ExamGenerationRuleModel>? rules,
  }) {
    onChanged(
      ExamGenerationSectionModel(
        title: title ?? section.title,
        instructions: instructions ?? section.instructions,
        totalMarks: totalMarks ?? section.totalMarks,
        answerPolicy: answerPolicy ?? section.answerPolicy,
        requiredAnswerCount: requiredAnswerCount ?? section.requiredAnswerCount,
        rules: rules ?? section.rules,
      ),
    );
  }
}

class _ModernTextField extends StatefulWidget {
  const _ModernTextField({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ModernTextField oldWidget) {
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
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: widget.minLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: EdgeInsets.only(top: widget.minLines > 1 ? 4 : 0),
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
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: InstructorColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
    );
  }
}
