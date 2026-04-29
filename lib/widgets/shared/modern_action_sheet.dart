import 'package:flutter/material.dart';

class ModernActionItem<T> {
  const ModernActionItem({
    required this.value,
    required this.label,
    required this.icon,
    this.description,
    this.color,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final String? description;
  final Color? color;
  final bool destructive;
}

Future<T?> showModernActionSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<ModernActionItem<T>> actions,
  required Color accentColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
  final surfaceColor =
      isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
  final borderColor =
      isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);
  final primaryText = isDark ? Colors.white : const Color(0xFF1E293B);
  final secondaryText =
      isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor.withValues(alpha: 0.8)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.auto_awesome_rounded,
                            color: accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (subtitle != null) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: secondaryText,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: actions.map((action) {
                      final color = action.destructive
                          ? (action.color ?? const Color(0xFFEF4444))
                          : (action.color ?? accentColor);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              Navigator.of(sheetContext).pop(action.value),
                          child: Ink(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child:
                                      Icon(action.icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        action.label,
                                        style: TextStyle(
                                          color: primaryText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (action.description !=
                                          null) ...<Widget>[
                                        const SizedBox(height: 2),
                                        Text(
                                          action.description!,
                                          style: TextStyle(
                                            color: secondaryText,
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: secondaryText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
