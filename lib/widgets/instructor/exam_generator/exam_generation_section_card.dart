import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generation_rule_model.dart';
import '../../../models/exams/exam_generation_section_model.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../../../models/question_bank/question_bank_group_model.dart';
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
                '${section.title} • ${section.rules.fold<int>(0, (sum, rule) => sum + rule.count)} ${l10n.questions}',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.examSections,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _box(
                    TextFormField(
                      initialValue: section.title,
                      decoration: InputDecoration(labelText: l10n.title),
                      onChanged: (value) => _emit(title: value),
                    ),
                  ),
                  _box(
                    TextFormField(
                      initialValue: section.totalMarks.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.totalMarks),
                      onChanged: (value) =>
                          _emit(totalMarks: double.tryParse(value)),
                    ),
                  ),
                  _box(
                    DropdownButtonFormField<ExamSectionAnswerPolicy>(
                      initialValue: section.answerPolicy,
                      decoration: InputDecoration(
                        labelText: l10n.examAnswerPolicy,
                        helperText:
                            section.answerPolicy ==
                                ExamSectionAnswerPolicy.answerAny
                            ? l10n.examAnswerAnyMarksHelp
                            : null,
                      ),
                      items: ExamSectionAnswerPolicy.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(localizedAnswerPolicy(l10n, value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => _emit(answerPolicy: value),
                    ),
                  ),
                  _box(
                    TextFormField(
                      initialValue:
                          section.requiredAnswerCount?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.examRequiredAnswerCount,
                      ),
                      onChanged: (value) =>
                          _emit(requiredAnswerCount: int.tryParse(value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: section.instructions ?? '',
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.instructions),
                onChanged: (value) => _emit(instructions: value),
              ),
              const SizedBox(height: 12),
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
                          final next = [...section.rules]..removeAt(entry.key);
                          _emit(rules: next);
                        },
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
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
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.examGenerationRules),
                ),
              ),
            ],
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

  Widget _box(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: child,
    );
  }
}
