import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

class QuestionBulkEditor extends StatelessWidget {
  const QuestionBulkEditor({
    super.key,
    required this.rowCount,
    required this.onAddRow,
    required this.children,
  });

  final int rowCount;
  final VoidCallback onAddRow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$rowCount / 50 ${l10n.questions}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            FilledButton.icon(
              onPressed: rowCount >= 50 ? null : onAddRow,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.qbAddRow),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
