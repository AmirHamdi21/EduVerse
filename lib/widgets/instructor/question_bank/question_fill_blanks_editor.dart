import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';
import '../shared/instructor_colors.dart';

class QuestionFillBlanksEditor extends StatelessWidget {
  const QuestionFillBlanksEditor({
    super.key,
    required this.blanks,
    required this.onChanged,
  });

  final List<QuestionBankFillBlankModel> blanks;
  final ValueChanged<List<QuestionBankFillBlankModel>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        for (var i = 0; i < blanks.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InstructorColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final keyField = TextFormField(
                  initialValue: blanks[i].blankKey,
                  decoration: _decoration(
                    context,
                    l10n.qbBlankKey,
                    Icons.key_rounded,
                  ),
                  onChanged: (value) => _update(i, blankKey: value),
                );
                final answerField = TextFormField(
                  initialValue: blanks[i].acceptableAnswer,
                  decoration: _decoration(
                    context,
                    l10n.qbAnswer,
                    Icons.check_circle_outline_rounded,
                  ),
                  onChanged: (value) => _update(i, answer: value),
                );
                final removeButton = IconButton(
                  onPressed: blanks.length <= 1
                      ? null
                      : () => onChanged([...blanks]..removeAt(i)),
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.error.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    foregroundColor: InstructorColors.error,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                );

                if (compact) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      keyField,
                      const SizedBox(height: 10),
                      answerField,
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: removeButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: keyField),
                    const SizedBox(width: 10),
                    Expanded(child: answerField),
                    removeButton,
                  ],
                );
              },
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: () => onChanged([
              ...blanks,
              QuestionBankFillBlankModel(
                blankKey: 'blank${blanks.length + 1}',
                acceptableAnswer: '',
              ),
            ]),
            style: FilledButton.styleFrom(
              backgroundColor: InstructorColors.accent.withValues(
                alpha: isDark ? 0.22 : 0.1,
              ),
              foregroundColor: InstructorColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.qbAddBlank),
          ),
        ),
      ],
    );
  }

  void _update(int index, {String? blankKey, String? answer}) {
    final next = [...blanks];
    next[index] = QuestionBankFillBlankModel(
      blankKey: blankKey ?? blanks[index].blankKey,
      acceptableAnswer: answer ?? blanks[index].acceptableAnswer,
      isCaseSensitive: blanks[index].isCaseSensitive,
    );
    onChanged(next);
  }

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: InstructorColors.cardColor(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
    );
  }
}
