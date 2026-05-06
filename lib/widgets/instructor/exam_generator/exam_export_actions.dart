import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

class ExamExportActions extends StatelessWidget {
  const ExamExportActions({
    super.key,
    required this.onPublish,
    required this.onUnpublish,
    required this.onArchive,
    required this.onExport,
  });

  final VoidCallback onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onArchive;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onPublish,
          icon: const Icon(Icons.publish_outlined),
          label: Text(l10n.examPublish),
        ),
        OutlinedButton.icon(
          onPressed: onUnpublish,
          icon: const Icon(Icons.undo_rounded),
          label: Text(l10n.examUnpublish),
        ),
        OutlinedButton.icon(
          onPressed: onArchive,
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.examArchive),
        ),
        FilledButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.download_rounded),
          label: Text(l10n.examExport),
        ),
      ],
    );
  }
}
