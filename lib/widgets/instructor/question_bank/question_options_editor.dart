import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_option_model.dart';
import '../shared/instructor_colors.dart';

class QuestionOptionsEditor extends StatelessWidget {
  const QuestionOptionsEditor({
    super.key,
    required this.options,
    required this.onChanged,
    this.lockCount = false,
    this.singleCorrect = false,
  });

  final List<QuestionBankOptionModel> options;
  final ValueChanged<List<QuestionBankOptionModel>> onChanged;
  final bool lockCount;
  final bool singleCorrect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InstructorColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: InstructorColors.borderColor(isDark)),
            ),
            child: Row(
              children: [
                if (singleCorrect)
                  _SingleCorrectPicker(
                    selected: options[i].isCorrect,
                    isDark: isDark,
                    onTap: () => onChanged([
                      for (
                        var optionIndex = 0;
                        optionIndex < options.length;
                        optionIndex++
                      )
                        QuestionBankOptionModel(
                          optionText: options[optionIndex].optionText,
                          isCorrect: optionIndex == i,
                        ),
                    ]),
                  )
                else
                  Checkbox(
                    value: options[i].isCorrect,
                    activeColor: InstructorColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (value) {
                      final next = [...options];
                      next[i] = QuestionBankOptionModel(
                        optionText: options[i].optionText,
                        isCorrect: value ?? false,
                      );
                      onChanged(next);
                    },
                  ),
                Expanded(
                  child: TextFormField(
                    initialValue: options[i].optionText,
                    decoration: InputDecoration(
                      labelText: '${l10n.qbOptionNumber} ${i + 1}',
                      filled: true,
                      fillColor: InstructorColors.cardColor(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: InstructorColors.borderColor(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: InstructorColors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      final next = [...options];
                      next[i] = QuestionBankOptionModel(
                        optionText: value,
                        isCorrect: options[i].isCorrect,
                      );
                      onChanged(next);
                    },
                  ),
                ),
                if (!lockCount)
                  IconButton(
                    onPressed: options.length <= 2
                        ? null
                        : () => onChanged([...options]..removeAt(i)),
                    style: IconButton.styleFrom(
                      backgroundColor: InstructorColors.error.withValues(
                        alpha: isDark ? 0.18 : 0.1,
                      ),
                      foregroundColor: InstructorColors.error,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
          ),
        if (!lockCount)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              onPressed: () => onChanged([
                ...options,
                const QuestionBankOptionModel(optionText: '', isCorrect: false),
              ]),
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary.withValues(
                  alpha: isDark ? 0.22 : 0.1,
                ),
                foregroundColor: InstructorColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.qbAddOption),
            ),
          ),
      ],
    );
  }
}

class _SingleCorrectPicker extends StatelessWidget {
  const _SingleCorrectPicker({
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? InstructorColors.success
                : InstructorColors.cardColor(isDark),
            border: Border.all(
              color: selected
                  ? InstructorColors.success
                  : InstructorColors.textSecondaryColor(isDark),
              width: 2,
            ),
          ),
          child: selected
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
