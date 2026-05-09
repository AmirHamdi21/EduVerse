import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class QuestionFormMenuOption<T> {
  const QuestionFormMenuOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class QuestionFormMenuField<T> extends StatelessWidget {
  const QuestionFormMenuField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon = Icons.tune_rounded,
    this.color = InstructorColors.primary,
    this.enabled = true,
    this.width,
    this.valueMaxLines = 1,
  });

  final String label;
  final T? value;
  final List<QuestionFormMenuOption<T>> options;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final Color color;
  final bool enabled;
  final double? width;
  final int valueMaxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = options
        .where((option) => option.value == value)
        .firstOrNull;
    final child = Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? InstructorColors.borderColor(isDark)
              : InstructorColors.borderColor(isDark).withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selected?.label ?? '',
                  maxLines: valueMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled
                ? InstructorColors.textSecondaryColor(isDark)
                : InstructorColors.textTertiaryColor(isDark),
          ),
        ],
      ),
    );

    if (!enabled) return child;

    return PopupMenuButton<T>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<T>(
              value: option.value,
              onTap: () => onChanged(option.value),
              child: _QuestionFormMenuItem(
                label: option.label,
                icon: option.icon,
                selected: option.value == value,
                color: color,
                isDark: isDark,
              ),
            ),
          )
          .toList(),
      child: child,
    );
  }
}

class _QuestionFormMenuItem extends StatelessWidget {
  const _QuestionFormMenuItem({
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color color;
  final bool isDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          selected ? Icons.check_circle_rounded : icon ?? Icons.circle_outlined,
          size: 18,
          color: selected ? color : InstructorColors.textSecondaryColor(isDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? color
                  : InstructorColors.textPrimaryColor(isDark),
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
