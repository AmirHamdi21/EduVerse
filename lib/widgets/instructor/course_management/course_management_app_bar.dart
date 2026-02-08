import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'course_management_colors.dart';

/// AppBar for Course Management - matches instructor courses screen style
class CourseManagementAppBar extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final bool isDark;
  final VoidCallback onSettings;

  const CourseManagementAppBar({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.isDark,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: null,
      leadingWidth: 0,
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: 8),
          _buildTitleIcon(),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: TextStyle(
                    color: isDark ? Colors.white : CMColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  courseCode,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : CMColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CMColors.primary.withValues(alpha: 0.15),
                    CMColors.primaryMedium.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CMColors.primaryMedium.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: isDark ? Colors.white : CMColors.primary,
                size: 16,
              ),
            ),
            onPressed: onSettings,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [CMColors.darkSurface, CMColors.darkBg]
                  : [const Color(0xFFF8FBFF), const Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CMColors.primaryLight.withValues(alpha: 0.08),
                        CMColors.primaryLight.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CMColors.accent.withValues(alpha: 0.06),
                        CMColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CMColors.primary.withValues(alpha: 0.15),
              CMColors.primaryMedium.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CMColors.primaryMedium.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CMColors.primaryMedium.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : CMColors.primary,
          size: 16,
        ),
      ),
      onPressed: () => context.pop(),
    );
  }

  Widget _buildTitleIcon() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CMColors.primary.withValues(alpha: 0.2),
            CMColors.primaryMedium.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.class_rounded,
        color: isDark ? Colors.white : CMColors.primary,
        size: 16,
      ),
    );
  }
}
