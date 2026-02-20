import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/it_colors.dart';

class ITIntegrationAppBar extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final VoidCallback? onRefreshTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final int connectedCount;
  final int totalCount;

  const ITIntegrationAppBar({
    super.key,
    required this.isDark,
    required this.title,
    required this.subtitle,
    this.onRefreshTap,
    this.onSearchTap,
    this.onFilterTap,
    this.connectedCount = 0,
    this.totalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: ITColors.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : ITColors.primary,
              size: 22,
            ),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        if (onSearchTap != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white : ITColors.primary,
                size: 22,
              ),
            ),
            onPressed: onSearchTap,
          ),
        if (onFilterTap != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: isDark ? Colors.white : ITColors.primary,
                size: 22,
              ),
            ),
            onPressed: onFilterTap,
          ),
        if (onRefreshTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? Colors.white : ITColors.primary,
                  size: 22,
                ),
              ),
              onPressed: onRefreshTap,
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? ITColors.darkHeaderGradient
                : ITColors.headerGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Connection stats
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          label: 'Connected',
                          value: connectedCount.toString(),
                          icon: Icons.check_circle_rounded,
                          color: ITColors.success,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _buildStatItem(
                          label: 'Total',
                          value: totalCount.toString(),
                          icon: Icons.apps_rounded,
                          color: Colors.white,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _buildStatItem(
                          label: 'Available',
                          value: (totalCount - connectedCount).toString(),
                          icon: Icons.add_circle_outline_rounded,
                          color: ITColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
