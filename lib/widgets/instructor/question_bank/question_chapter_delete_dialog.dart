import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';

Future<bool> showQuestionChapterDeleteDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: _DeleteChapterDialogContent(l10n: l10n),
        ),
      ) ??
      false;
}

class _DeleteChapterDialogContent extends StatelessWidget {
  const _DeleteChapterDialogContent({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: InstructorColors.error.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: InstructorColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.qbDeleteChapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: IconButton.styleFrom(
                  backgroundColor: InstructorColors.surfaceColor(isDark),
                  foregroundColor: InstructorColors.textPrimaryColor(isDark),
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InstructorColors.error.withValues(
                alpha: isDark ? 0.16 : 0.07,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: InstructorColors.error.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              l10n.qbChapterCascadeWarning,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 340;
              final deleteButton = FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(
                  l10n.qbDeleteChapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              final cancelButton = OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: InstructorColors.primary,
                  side: const BorderSide(color: InstructorColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    deleteButton,
                    const SizedBox(height: 10),
                    cancelButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: cancelButton),
                  const SizedBox(width: 10),
                  Expanded(child: deleteButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
