import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AIMode {
  final String id;
  final String label;
  final IconData icon;
  final String description;

  const AIMode({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}

class AdminAIModeSelector extends StatelessWidget {
  final bool isDark;
  final String selectedMode;
  final Function(String) onModeChanged;

  const AdminAIModeSelector({
    super.key,
    required this.isDark,
    required this.selectedMode,
    required this.onModeChanged,
  });

  static const List<AIMode> _modes = [
    AIMode(
      id: 'general',
      label: 'General',
      icon: Icons.assistant_rounded,
      description: 'General assistance and Q&A',
    ),
    AIMode(
      id: 'analytics',
      label: 'Analytics',
      icon: Icons.analytics_rounded,
      description: 'Data analysis and insights',
    ),
    AIMode(
      id: 'reports',
      label: 'Reports',
      icon: Icons.assessment_rounded,
      description: 'Generate reports and summaries',
    ),
    AIMode(
      id: 'system',
      label: 'System',
      icon: Icons.settings_rounded,
      description: 'System management help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _modes.length,
        itemBuilder: (context, index) {
          final mode = _modes[index];
          final isSelected = selectedMode == mode.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected
                  ? AdminColors.secondary
                  : (isDark ? AdminColors.darkCard : AdminColors.lightCard),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: () => onModeChanged(mode.id),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? AdminColors.secondary
                          : (isDark
                                ? AdminColors.darkCardBorder
                                : AdminColors.lightCardBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mode.icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AdminColors.darkTextSecondary
                                  : AdminColors.lightTextSecondary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mode.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AdminColors.darkText
                                    : AdminColors.lightText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
