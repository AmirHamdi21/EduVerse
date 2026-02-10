import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class InstructorNotificationsTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDarkMode;
  final String allLabel;
  final String unreadLabel;
  final String readLabel;

  const InstructorNotificationsTabBar({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.allLabel,
    required this.unreadLabel,
    required this.readLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: allLabel),
          Tab(text: unreadLabel),
          Tab(text: readLabel),
        ],
      ),
    );
  }
}
