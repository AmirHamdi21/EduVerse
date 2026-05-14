import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    final loginHistory = [
      _LoginEntry(
        device: 'iPhone 15 Pro',
        location: 'Cairo, Egypt',
        ipAddress: '192.168.1.xxx',
        time: DateTime.now(),
        status: 'success',
      ),
      _LoginEntry(
        device: 'MacBook Pro',
        location: 'Cairo, Egypt',
        ipAddress: '192.168.1.xxx',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'success',
      ),
      _LoginEntry(
        device: 'Unknown Device',
        location: 'Lagos, Nigeria',
        ipAddress: '41.58.xxx.xxx',
        time: DateTime.now().subtract(const Duration(hours: 12)),
        status: 'failed',
      ),
      _LoginEntry(
        device: 'iPad Air',
        location: 'Alexandria, Egypt',
        ipAddress: '197.37.xxx.xxx',
        time: DateTime.now().subtract(const Duration(days: 1)),
        status: 'success',
      ),
      _LoginEntry(
        device: 'Windows PC',
        location: 'Giza, Egypt',
        ipAddress: '156.197.xxx.xxx',
        time: DateTime.now().subtract(const Duration(days: 2)),
        status: 'success',
      ),
      _LoginEntry(
        device: 'Unknown Device',
        location: 'Moscow, Russia',
        ipAddress: '95.85.xxx.xxx',
        time: DateTime.now().subtract(const Duration(days: 3)),
        status: 'blocked',
      ),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => safeBack(context, '/dashboard'),
          icon: Icon(
            iosBackIcon(context),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.loginHistory,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Summary Card
          _buildSummaryCard(isDark, loginHistory, l10n),
          const SizedBox(height: 24),

          // Recent Activity
          _buildSectionTitle(l10n.recentActivity, isDark),
          const SizedBox(height: 12),
          ...loginHistory.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLoginEntryCard(isDark, entry, l10n),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    bool isDark,
    List<_LoginEntry> history,
    AppLocalizations l10n,
  ) {
    final successful = history.where((e) => e.status == 'success').length;
    final failed = history.where((e) => e.status == 'failed').length;
    final blocked = history.where((e) => e.status == 'blocked').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.loginActivity,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.last30Days,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.successful,
                  successful.toString(),
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  l10n.failed,
                  failed.toString(),
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  l10n.blocked,
                  blocked.toString(),
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLoginEntryCard(
    bool isDark,
    _LoginEntry entry,
    AppLocalizations l10n,
  ) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (entry.status) {
      case 'success':
        statusIcon = Icons.check_circle_rounded;
        statusColor = const Color(0xFF10B981);
        statusText = l10n.successful;
        break;
      case 'failed':
        statusIcon = Icons.error_rounded;
        statusColor = const Color(0xFFF59E0B);
        statusText = l10n.failed;
        break;
      case 'blocked':
        statusIcon = Icons.block_rounded;
        statusColor = const Color(0xFFEF4444);
        statusText = l10n.blocked;
        break;
      default:
        statusIcon = Icons.help_rounded;
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: entry.status != 'success'
            ? Border.all(color: statusColor.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, size: 24, color: statusColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.device,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.router_outlined,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.ipAddress,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(entry.time),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class _LoginEntry {
  final String device;
  final String location;
  final String ipAddress;
  final DateTime time;
  final String status;

  const _LoginEntry({
    required this.device,
    required this.location,
    required this.ipAddress,
    required this.time,
    required this.status,
  });
}
