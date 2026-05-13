import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 380;
              final title = Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: InstructorColors.primary.withValues(
                        alpha: isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.playlist_add_check_rounded,
                      color: InstructorColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.qbBulkRows,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$rowCount / 50 ${l10n.questions}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final button = Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _AddRowButton(
                  rowCount: rowCount,
                  onAddRow: onAddRow,
                  filled: true,
                ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 12), button],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  Flexible(child: button),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        ...children,
        const SizedBox(height: 2),
        _AddRowButton(rowCount: rowCount, onAddRow: onAddRow),
      ],
    );
  }
}

class _AddRowButton extends StatelessWidget {
  const _AddRowButton({
    required this.rowCount,
    required this.onAddRow,
    this.filled = false,
  });

  final int rowCount;
  final VoidCallback onAddRow;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onPressed = rowCount >= 50 ? null : onAddRow;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    if (filled) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 150),
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: InstructorColors.primary,
            foregroundColor: Colors.white,
            shape: shape,
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            l10n.qbAddRow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: InstructorColors.primary.withValues(
            alpha: isDark ? 0.14 : 0.07,
          ),
          foregroundColor: InstructorColors.primary,
          side: BorderSide(
            color: InstructorColors.primary.withValues(alpha: 0.24),
          ),
          shape: shape,
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.qbAddRow,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
