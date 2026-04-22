import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class InstructorNotificationsEmptyState extends StatelessWidget {
  final int tabIndex;
  final bool isDarkMode;
  final String allTitle;
  final String allSubtitle;
  final String unreadTitle;
  final String unreadSubtitle;
  final String readTitle;
  final String readSubtitle;

  const InstructorNotificationsEmptyState({
    super.key,
    required this.tabIndex,
    required this.isDarkMode,
    required this.allTitle,
    required this.allSubtitle,
    required this.unreadTitle,
    required this.unreadSubtitle,
    required this.readTitle,
    required this.readSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 1:
        title = unreadTitle;
        subtitle = unreadSubtitle;
        icon = Icons.mark_email_read_rounded;
        break;
      case 2:
        title = readTitle;
        subtitle = readSubtitle;
        icon = Icons.inbox_rounded;
        break;
      default:
        title = allTitle;
        subtitle = allSubtitle;
        icon = Icons.notifications_off_rounded;
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppTheme.darkCardColor
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: isDarkMode
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
