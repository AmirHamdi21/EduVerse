import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import 'question_bank_localized_labels.dart';

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
        return Card(
          key: ValueKey(question.id),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            leading: const Icon(Icons.drag_indicator_rounded),
            title: Text(
              question.questionText ?? '${l10n.questions} ${question.id}',
            ),
            subtitle: Text(
              '${l10n.type}: ${localizedQuestionType(l10n, question.questionType)}',
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: l10n.questionBankEditQuestion,
                  onPressed: onEdit == null ? null : () => onEdit!(question),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.qbRemoveFromGroup,
                  onPressed: onDelete == null
                      ? null
                      : () => onDelete!(question),
                  icon: const Icon(Icons.link_off_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
