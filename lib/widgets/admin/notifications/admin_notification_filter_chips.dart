import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_notification_model.dart';
import '../shared/admin_colors.dart';

class AdminNotificationFilterChips extends StatelessWidget {
  final AdminNotificationCategory selectedCategory;
  final Function(AdminNotificationCategory) onCategoryChanged;
  final bool isDark;

  const AdminNotificationFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories = AdminNotificationCategory.values;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onCategoryChanged(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AdminColors.primaryGradient : null,
                  color: isSelected
                      ? null
                      : (isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.2),
                        ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AdminColors.getTextSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryLabel(category),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(AdminNotificationCategory category) {
    switch (category) {
      case AdminNotificationCategory.all:
        return Icons.notifications_rounded;
      case AdminNotificationCategory.users:
        return Icons.people_rounded;
      case AdminNotificationCategory.courses:
        return Icons.school_rounded;
      case AdminNotificationCategory.system:
        return Icons.settings_rounded;
      case AdminNotificationCategory.security:
        return Icons.security_rounded;
      case AdminNotificationCategory.announcements:
        return Icons.campaign_rounded;
      case AdminNotificationCategory.reports:
        return Icons.analytics_rounded;
    }
  }

  String _getCategoryLabel(AdminNotificationCategory category) {
    switch (category) {
      case AdminNotificationCategory.all:
        return 'All';
      case AdminNotificationCategory.users:
        return 'Users';
      case AdminNotificationCategory.courses:
        return 'Courses';
      case AdminNotificationCategory.system:
        return 'System';
      case AdminNotificationCategory.security:
        return 'Security';
      case AdminNotificationCategory.announcements:
        return 'Announcements';
      case AdminNotificationCategory.reports:
        return 'Reports';
    }
  }
}
