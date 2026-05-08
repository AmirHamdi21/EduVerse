import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';

class ExamDraftEditorToolbar extends StatelessWidget {
  const ExamDraftEditorToolbar({
    super.key,
    required this.canEdit,
    required this.onAddSection,
    required this.onAddQuestion,
    required this.onSave,
  });

  final bool canEdit;
  final VoidCallback onAddSection;
  final VoidCallback onAddQuestion;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      _DraftActionData(
        label: l10n.examCreateSection,
        icon: Icons.view_agenda_outlined,
        color: InstructorColors.accent,
        onPressed: canEdit ? onAddSection : null,
        emphasis: _ActionEmphasis.outline,
      ),
      _DraftActionData(
        label: l10n.examAddQuestion,
        icon: Icons.add_rounded,
        color: InstructorColors.primary,
        onPressed: canEdit ? onAddQuestion : null,
        emphasis: _ActionEmphasis.filled,
      ),
      _DraftActionData(
        label: l10n.save,
        icon: Icons.save_outlined,
        color: InstructorColors.teal,
        onPressed: onSave,
        emphasis: _ActionEmphasis.soft,
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 430 ? 3 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 1 ? 5.1 : 2.65,
            ),
            itemBuilder: (context, index) =>
                _DraftActionTile(data: actions[index]),
          );
        },
      ),
    );
  }
}

enum _ActionEmphasis { filled, outline, soft }

class _DraftActionData {
  const _DraftActionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.emphasis,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final _ActionEmphasis emphasis;
}

class _DraftActionTile extends StatelessWidget {
  const _DraftActionTile({required this.data});

  final _DraftActionData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = data.onPressed != null;
    final filled = data.emphasis == _ActionEmphasis.filled;
    final background = filled
        ? data.color
        : data.color.withValues(alpha: isDark ? 0.16 : 0.08);
    final foreground = filled ? Colors.white : data.color;
    return InkWell(
      onTap: data.onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: filled
                  ? data.color
                  : data.color.withValues(
                      alpha: data.emphasis == _ActionEmphasis.outline
                          ? 0.45
                          : 0.2,
                    ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: 0.16)
                      : data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: foreground, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled
                        ? Colors.white
                        : InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
