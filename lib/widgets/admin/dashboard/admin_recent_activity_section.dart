import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class RecentActivityItem {
  final String userName;
  final String action;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;

  RecentActivityItem({
    required this.userName,
    required this.action,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
  });
}

class AdminRecentActivitySection extends StatelessWidget {
  const AdminRecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        final activities = _getMockActivities(l10n);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkCard.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightCardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: AdminColors.getTextColor(isDark),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.recentActivity,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showAllActivities(context, isDark, l10n, activities),
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        color: AdminColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...activities
                  .take(5)
                  .map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildActivityItem(isDark, activity),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(bool isDark, RecentActivityItem activity) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activity.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activity.icon, color: activity.iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: activity.userName,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' ${activity.action}',
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity.timeAgo,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<RecentActivityItem> _getMockActivities(AppLocalizations l10n) {
    return [
      RecentActivityItem(
        userName: 'Dr. Sarah Johnson',
        action: l10n.createdNewCourse,
        timeAgo: l10n.minutesAgo(5),
        icon: Icons.add_box_rounded,
        iconColor: AdminColors.success,
      ),
      RecentActivityItem(
        userName: 'Admin User',
        action: l10n.updatedSystemSettings,
        timeAgo: l10n.minutesAgo(15),
        icon: Icons.settings_rounded,
        iconColor: AdminColors.primary,
      ),
      RecentActivityItem(
        userName: 'Prof. Michael Chen',
        action: l10n.uploadedCourseMaterials,
        timeAgo: l10n.minutesAgo(30),
        icon: Icons.upload_file_rounded,
        iconColor: AdminColors.secondary,
      ),
      RecentActivityItem(
        userName: 'John Smith',
        action: l10n.enrolledInCourse,
        timeAgo: l10n.hoursAgo(1),
        icon: Icons.person_add_rounded,
        iconColor: AdminColors.accent,
      ),
      RecentActivityItem(
        userName: 'Dr. Emily Williams',
        action: l10n.publishedAnnouncement,
        timeAgo: l10n.hoursAgo(2),
        icon: Icons.campaign_rounded,
        iconColor: AdminColors.warning,
      ),
    ];
  }

  void _showAllActivities(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    List<RecentActivityItem> activities,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentActivity,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: activities.length + 5, // Add more mock items
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  if (index < activities.length) {
                    return _buildActivityItem(isDark, activities[index]);
                  }
                  // Generate more mock items
                  return _buildActivityItem(
                    isDark,
                    RecentActivityItem(
                      userName: 'User ${index + 1}',
                      action: l10n.performedAction,
                      timeAgo: l10n.hoursAgo(index),
                      icon: Icons.check_circle_rounded,
                      iconColor: AdminColors.chartGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
