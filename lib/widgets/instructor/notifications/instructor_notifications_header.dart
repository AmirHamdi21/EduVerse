import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/app_theme.dart';
import '../../../utils/navigation/safe_back.dart';

class InstructorNotificationsHeader extends StatelessWidget {
  final bool isDarkMode;
  final bool showElevation;
  final int unreadCount;
  final String title;
  final bool isSearching;
  final VoidCallback onBackPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onMarkAllReadPressed;

  const InstructorNotificationsHeader({
    super.key,
    required this.isDarkMode,
    required this.showElevation,
    required this.unreadCount,
    required this.title,
    required this.isSearching,
    required this.onBackPressed,
    required this.onSearchPressed,
    required this.onMarkAllReadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC),
        boxShadow: showElevation
            ? [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  iosBackIcon(context),
                  size: 18,
                  color: isDarkMode
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                  if (unreadCount > 0)
                    Text(
                      '$unreadCount unread',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textLight,
                      ),
                    ),
                ],
              ),
            ),
            _buildHeaderAction(
              icon: Icons.search_rounded,
              isDarkMode: isDarkMode,
              onTap: onSearchPressed,
              isActive: isSearching,
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.done_all_rounded,
              isDarkMode: isDarkMode,
              onTap: onMarkAllReadPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.15)),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppTheme.primaryColor
              : (isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark),
        ),
      ),
    );
  }
}
