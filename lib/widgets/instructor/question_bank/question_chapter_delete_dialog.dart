import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

Future<bool> showQuestionChapterDeleteDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.qbDeleteChapter),
          content: Text(l10n.qbChapterCascadeWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.qbDeleteChapter),
            ),
          ],
        ),
      ) ??
      false;
}
