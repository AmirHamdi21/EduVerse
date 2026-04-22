import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// User statistics card
class UserStatistics extends StatelessWidget {
  final bool isDark;
  final int totalUsers;
  final int activeToday;
  final int newThisWeek;
  final int flaggedUsers;

  const UserStatistics({
    super.key,
    required this.isDark,
    this.totalUsers = 1254,
    this.activeToday = 847,
    this.newThisWeek = 32,
    this.flaggedUsers = 5,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.userStatistics,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                label: l10n.totalUsers,
                value: totalUsers.toString(),
                icon: Icons.people_rounded,
                gradient: AdminColors.primaryGradient,
              ),
              _buildStatCard(
                label: l10n.activeToday,
                value: activeToday.toString(),
                icon: Icons.trending_up_rounded,
                gradient: AdminColors.greenGradient,
              ),
              _buildStatCard(
                label: l10n.newThisWeek,
                value: '+$newThisWeek',
                icon: Icons.person_add_rounded,
                gradient: AdminColors.cyanGradient,
              ),
              _buildStatCard(
                label: l10n.flaggedUsers,
                value: flaggedUsers.toString(),
                icon: Icons.flag_rounded,
                gradient: LinearGradient(
                  colors: [
                    AdminColors.error,
                    AdminColors.error.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
