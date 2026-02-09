import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../../generated_l10n/app_localizations.dart';

enum InstructorNotificationCategory {
  all,
  submissions,
  grading,
  messages,
  deadlines,
  system,
}

class InstructorNotificationFilterChips extends StatelessWidget {
  final InstructorNotificationCategory selectedCategory;
  final ValueChanged<InstructorNotificationCategory> onCategoryChanged;
  final bool isDarkMode;

  const InstructorNotificationFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final categories = [
      _CategoryItem(
        category: InstructorNotificationCategory.all,
        label: l10n.all,
        icon: Icons.all_inbox_outlined,
        color: AppTheme.primaryColor,
      ),
      _CategoryItem(
        category: InstructorNotificationCategory.submissions,
        label: 'Submissions',
        icon: Icons.assignment_turned_in_outlined,
        color: const Color(0xFF155CFB),
      ),
      _CategoryItem(
        category: InstructorNotificationCategory.grading,
        label: 'Grading',
        icon: Icons.grading_outlined,
        color: const Color(0xFF7C3AED),
      ),
      _CategoryItem(
        category: InstructorNotificationCategory.messages,
        label: l10n.messages,
        icon: Icons.mail_outline,
        color: const Color(0xFF059669),
      ),
      _CategoryItem(
        category: InstructorNotificationCategory.deadlines,
        label: 'Deadlines',
        icon: Icons.schedule_outlined,
        color: const Color(0xFFEF4444),
      ),
      _CategoryItem(
        category: InstructorNotificationCategory.system,
        label: 'System',
        icon: Icons.settings_outlined,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((item) {
          final isSelected = selectedCategory == item.category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _FilterChip(
              label: item.label,
              icon: item.icon,
              isSelected: isSelected,
              isDarkMode: isDarkMode,
              color: item.color,
              onTap: () => onCategoryChanged(item.category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryItem {
  final InstructorNotificationCategory category;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDarkMode;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDarkMode,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                )
              : null,
          color: isSelected
              ? null
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.2)),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textLight),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
