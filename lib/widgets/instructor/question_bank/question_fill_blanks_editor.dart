import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_fill_blank_model.dart';

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
    return Column(
      children: [
        for (var i = 0; i < blanks.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final keyField = TextFormField(
                  initialValue: blanks[i].blankKey,
                  decoration: InputDecoration(
                    labelText: l10n.qbBlankKey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) => _update(i, blankKey: value),
                );
                final answerField = TextFormField(
                  initialValue: blanks[i].acceptableAnswer,
                  decoration: InputDecoration(
                    labelText: l10n.qbAnswer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (value) => _update(i, answer: value),
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
                        child: IconButton(
                          onPressed: blanks.length <= 1
                              ? null
                              : () => onChanged([...blanks]..removeAt(i)),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: keyField),
                    const SizedBox(width: 10),
                    Expanded(child: answerField),
                    IconButton(
                      onPressed: blanks.length <= 1
                          ? null
                          : () => onChanged([...blanks]..removeAt(i)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
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
}
