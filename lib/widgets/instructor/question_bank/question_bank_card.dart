import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import 'question_bank_localized_labels.dart';

class QuestionBankCard extends StatelessWidget {
  const QuestionBankCard({
    super.key,
    required this.question,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.selectionMode = false,
    this.onSelectionChanged,
  });

  final QuestionBankQuestionModel question;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool selectionMode;
  final ValueChanged<bool?>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectionMode) ...[
                Checkbox(value: isSelected, onChanged: onSelectionChanged),
                const SizedBox(width: 6),
              ],
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.help_outline, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.questionText?.trim().isNotEmpty == true
                          ? question.questionText!
                          : l10n.questionBankImageQuestion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(localizedQuestionType(l10n, question.questionType)),
                        _Chip(localizedDifficulty(l10n, question.difficulty)),
                        _Chip(localizedBloomLevel(l10n, question.bloomLevel)),
                        _Chip(localizedQuestionStatus(l10n, question.status)),
                        if (question.hasAttachments) _Chip(l10n.attachments),
                        if (question.isGrouped) _Chip(l10n.qbGroups),
                      ],
                    ),
                  ],
                ),
              ),
              if (!selectionMode)
                IconButton(
                  tooltip: l10n.edit,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (!selectionMode && onDelete != null)
                IconButton(
                  tooltip: l10n.qbDeleteQuestion,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
