import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../shared/instructor_colors.dart';
import 'question_bank_localized_labels.dart';
import 'question_text_renderer.dart';

class QuestionGroupReorderList extends StatelessWidget {
  const QuestionGroupReorderList({
    super.key,
    required this.questions,
    required this.onReorder,
    this.onEdit,
    this.onDelete,
  });

  final List<QuestionBankQuestionModel> questions;
  final ValueChanged<List<int>> onReorder;
  final ValueChanged<QuestionBankQuestionModel>? onEdit;
  final ValueChanged<QuestionBankQuestionModel>? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      onReorder: (oldIndex, newIndex) {
        final ids = questions.map((question) => question.id).toList();
        final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final moved = ids.removeAt(oldIndex);
        ids.insert(target, moved);
        onReorder(ids);
      },
      itemBuilder: (context, index) {
        final question = questions[index];
        return Container(
          key: ValueKey(question.id),
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              const PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: InstructorColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: InstructorColors.primary.withValues(
                          alpha: isDark ? 0.18 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.drag_indicator_rounded,
                        color: InstructorColors.primary,
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
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoPill(
                                label: localizedQuestionType(
                                  l10n,
                                  question.questionType,
                                ),
                                color: InstructorColors.primary,
                                isDark: isDark,
                              ),
                              _InfoPill(
                                label: localizedDifficulty(
                                  l10n,
                                  question.difficulty,
                                ),
                                color: InstructorColors.teal,
                                isDark: isDark,
                              ),
                              _InfoPill(
                                label: localizedBloomLevel(
                                  l10n,
                                  question.bloomLevel,
                                ),
                                color: InstructorColors.accent,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          tooltip: l10n.questionBankEditQuestion,
                          onPressed: onEdit == null
                              ? null
                              : () => onEdit!(question),
                          style: IconButton.styleFrom(
                            backgroundColor: InstructorColors.primary
                                .withValues(alpha: isDark ? 0.18 : 0.1),
                            foregroundColor: InstructorColors.primary,
                          ),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          tooltip: l10n.qbRemoveFromGroup,
                          onPressed: onDelete == null
                              ? null
                              : () => onDelete!(question),
                          style: IconButton.styleFrom(
                            backgroundColor: InstructorColors.error.withValues(
                              alpha: isDark ? 0.18 : 0.1,
                            ),
                            foregroundColor: InstructorColors.error,
                          ),
                          icon: const Icon(Icons.link_off_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}
