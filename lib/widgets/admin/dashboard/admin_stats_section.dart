import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminStatsSection extends StatelessWidget {
  const AdminStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: l10n.totalUsers,
                    value: '12,847',
                    badge: '+8.2%',
                    badgeColor: AdminColors.success,
                    icon: Icons.people_rounded,
                    chartValues: [0.2, 0.35, 0.3, 0.45, 0.4, 0.55, 0.5, 0.65],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: l10n.activeCourses,
                    value: '342',
                    badge: '+5.1%',
                    badgeColor: AdminColors.success,
                    icon: Icons.school_rounded,
                    chartValues: [0.3, 0.4, 0.35, 0.5, 0.48, 0.6, 0.55, 0.7],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: l10n.systemHealth,
                    value: '98.7%',
                    badge: l10n.excellent,
                    badgeColor: AdminColors.success,
                    icon: Icons.shield_rounded,
                    chartValues: [
                      0.9,
                      0.92,
                      0.91,
                      0.95,
                      0.94,
                      0.97,
                      0.96,
                      0.98,
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: l10n.aiActionsToday,
                    value: '1,429',
                    badge: '+12.3%',
                    badgeColor: AdminColors.success,
                    icon: Icons.auto_awesome_rounded,
                    chartValues: [0.5, 0.6, 0.55, 0.7, 0.68, 0.78, 0.75, 0.85],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: l10n.dailyActiveUsers,
                    value: '8,431',
                    badge: '+6.7%',
                    badgeColor: AdminColors.success,
                    icon: Icons.trending_up_rounded,
                    chartValues: [0.6, 0.7, 0.65, 0.8, 0.78, 0.9, 0.88, 1.0],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: l10n.storageUsage,
                    value: '68%',
                    badge: '2.1TB / 3TB',
                    badgeColor: AdminColors.getTextTertiaryColor(isDark),
                    badgeBgColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFECEEF2),
                    badgeTextColor: AdminColors.getTextColor(isDark),
                    icon: Icons.cloud_rounded,
                    chartValues: [0.5, 0.52, 0.54, 0.58, 0.6, 0.63, 0.65, 0.68],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required List<double> chartValues,
    Color? badgeBgColor,
    Color? badgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor ?? badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: badgeBgColor != null
                        ? Colors.transparent
                        : badgeColor.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeTextColor ?? badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartValues
                  .map(
                    (v) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AdminColors.primaryLight,
                              AdminColors.accent,
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        height: 32 * v,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
