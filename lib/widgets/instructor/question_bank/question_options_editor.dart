import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_option_model.dart';

class QuestionOptionsEditor extends StatelessWidget {
  const QuestionOptionsEditor({
    super.key,
    required this.options,
    required this.onChanged,
    this.lockCount = false,
  });

  final List<QuestionBankOptionModel> options;
  final ValueChanged<List<QuestionBankOptionModel>> onChanged;
  final bool lockCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Checkbox(
                  value: options[i].isCorrect,
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
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
                    icon: const Icon(Icons.remove_circle_outline),
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
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.qbAddOption),
            ),
          ),
      ],
    );
  }
}
