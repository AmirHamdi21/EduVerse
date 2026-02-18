import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class ApiUsageCard extends StatelessWidget {
  final bool isDark;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double averageLatency;
  final List<Map<String, dynamic>> recentActivity;
  final Function() onViewDetails;

  const ApiUsageCard({
    super.key,
    required this.isDark,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageLatency,
    required this.recentActivity,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final successRate = totalRequests > 0 
        ? (successfulRequests / totalRequests * 100).round() 
        : 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: AdminColors.chartCyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.apiUsage,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(l10n.viewDetails),
                style: TextButton.styleFrom(
                  foregroundColor: AdminColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.totalRequests,
                  _formatNumber(totalRequests),
                  Icons.trending_up_rounded,
                  AdminColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.successRate,
                  '$successRate%',
                  Icons.check_circle_rounded,
                  AdminColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.failedRequests,
                  _formatNumber(failedRequests),
                  Icons.error_rounded,
                  AdminColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.avgLatency,
                  '${averageLatency.toStringAsFixed(0)}ms',
                  Icons.speed_rounded,
                  AdminColors.chartPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Usage chart placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.requestsOverTime,
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (index) {
                        final height = (0.3 + (index % 3) * 0.25 + (index / 12) * 0.3);
                        return Container(
                          width: 16,
                          height: 60 * height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AdminColors.primary,
                                AdminColors.primary.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recent activity
          Text(
            l10n.recentActivity,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...recentActivity.take(5).map((activity) => _buildActivityItem(activity, l10n)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, AppLocalizations l10n) {
    final method = activity['method'] as String? ?? 'GET';
    final endpoint = activity['endpoint'] as String? ?? '/api/unknown';
    final status = activity['status'] as int? ?? 200;
    final latency = activity['latency'] as int? ?? 0;

    final isSuccess = status >= 200 && status < 300;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.03) 
            : Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getMethodColor(method).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: _getMethodColor(method),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              endpoint,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isSuccess ? AdminColors.success : AdminColors.error)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$status',
              style: TextStyle(
                color: isSuccess ? AdminColors.success : AdminColors.error,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${latency}ms',
            style: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return AdminColors.success;
      case 'POST':
        return AdminColors.primary;
      case 'PUT':
        return AdminColors.warning;
      case 'PATCH':
        return AdminColors.chartPurple;
      case 'DELETE':
        return AdminColors.error;
      default:
        return AdminColors.getTextSecondaryColor(isDark);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
