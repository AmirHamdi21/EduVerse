import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_ai_model_settings_barrel.dart';

class ITAIRequestLogsSection extends StatelessWidget {
  final bool isDark;
  final AIRequestStats stats;
  final List<AIRequestLog> logs;
  final VoidCallback onViewFullLogs;
  final VoidCallback onDownloadLogs;

  const ITAIRequestLogsSection({
    super.key,
    required this.isDark,
    required this.stats,
    required this.logs,
    required this.onViewFullLogs,
    required this.onDownloadLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.primary.withValues(alpha: 0.2),
                      ITColors.teal.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: ITColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Request Logs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monitor AI usage and performance',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Grid
          _buildStatsGrid(),
          const SizedBox(height: 20),
          
          // Recent Requests Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Requests',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textSecondaryColor(isDark),
                ),
              ),
              TextButton(
                onPressed: onViewFullLogs,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  'View Full Logs',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ITColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Log Entries
          ...logs.take(5).map((log) => _buildLogEntry(log)),
          
          if (logs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 48,
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent requests',
                      style: TextStyle(
                        fontSize: 14,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Download Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDownloadLogs,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download Logs'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ITColors.primary,
                side: BorderSide(color: ITColors.primary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Success Rate',
            '${stats.successRate.toStringAsFixed(1)}%',
            Icons.check_circle_rounded,
            ITColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Providers',
            stats.activeProviders.toString(),
            Icons.hub_rounded,
            ITColors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.2 : 0.1),
            color.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(AIRequestLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(log.status),
              size: 18,
              color: log.statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatTimestamp(log.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getProviderColor(log.provider).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getModelShortName(log.model),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getProviderColor(log.provider),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: log.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              log.statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: log.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.success:
        return Icons.check_circle_outline_rounded;
      case RequestStatus.failed:
        return Icons.error_outline_rounded;
      case RequestStatus.pending:
        return Icons.pending_outlined;
      case RequestStatus.rateLimited:
        return Icons.speed_rounded;
    }
  }

  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return const Color(0xFF10A37F);
      case AIProvider.gemini:
        return const Color(0xFF4285F4);
      case AIProvider.claude:
        return const Color(0xFFD97706);
    }
  }

  String _getModelShortName(AIModel model) {
    switch (model) {
      case AIModel.gpt4Turbo:
        return 'GPT-4.1';
      case AIModel.gpt4:
        return 'GPT-4';
      case AIModel.gpt35Turbo:
        return 'GPT-3.5';
      case AIModel.geminiPro:
        return 'Gemini';
      case AIModel.gemini15Pro:
        return 'Gemini 1.5';
      case AIModel.claude3Opus:
        return 'Claude Opus';
      case AIModel.claude3Sonnet:
        return 'Claude 3';
      case AIModel.claude35Sonnet:
        return 'Claude 3.5';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
