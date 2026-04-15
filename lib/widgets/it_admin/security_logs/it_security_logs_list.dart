import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITSecurityLogsList extends StatelessWidget {
  final bool isDark;
  final List<SecurityLogEntry> logs;
  final String searchQuery;
  final String selectedFilter;
  final bool showFlaggedOnly;
  final bool showHighRiskOnly;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final Function(bool) onFlaggedOnlyChanged;
  final Function(bool) onHighRiskOnlyChanged;
  final Function(SecurityLogEntry) onLogTap;

  const ITSecurityLogsList({
    super.key,
    required this.isDark,
    required this.logs,
    required this.searchQuery,
    required this.selectedFilter,
    required this.showFlaggedOnly,
    required this.showHighRiskOnly,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onFlaggedOnlyChanged,
    required this.onHighRiskOnlyChanged,
    required this.onLogTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'All Flagged Only',
              isSelected: showFlaggedOnly,
              onTap: () => onFlaggedOnlyChanged(!showFlaggedOnly),
              icon: Icons.flag_rounded,
              color: ITColors.warning,
            ),
            _buildFilterChip(
              label: 'High-Risk Only',
              isSelected: showHighRiskOnly,
              onTap: () => onHighRiskOnlyChanged(!showHighRiskOnly),
              icon: Icons.warning_rounded,
              color: ITColors.error,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : ITColors.border,
            ),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search logs by user, IP, description...',
              hintStyle: TextStyle(
                color: ITColors.textTertiaryColor(isDark),
                fontSize: 13,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: ITColors.textTertiaryColor(isDark),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Event type filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : ITColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              isExpanded: true,
              dropdownColor: isDark ? ITColors.darkCard : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ITColors.textSecondaryColor(isDark),
              ),
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 13,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All Events',
                  child: Text('All Events'),
                ),
                DropdownMenuItem(value: 'Login', child: Text('Login Events')),
                DropdownMenuItem(value: 'Logout', child: Text('Logout Events')),
                DropdownMenuItem(
                  value: 'Breach',
                  child: Text('Breach Attempts'),
                ),
                DropdownMenuItem(
                  value: 'Permission',
                  child: Text('Permission Changes'),
                ),
                DropdownMenuItem(value: 'API', child: Text('API Access')),
              ],
              onChanged: (value) {
                if (value != null) onFilterChanged(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Log entries
        if (logs.isEmpty)
          _buildEmptyState()
        else
          ...logs.map((log) => _buildLogEntry(log)),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : ITColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? color : ITColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : ITColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(SecurityLogEntry log) {
    return GestureDetector(
      onTap: () => onLogTap(log),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getRiskBorderColor(log.riskLevel),
            width:
                log.riskLevel == RiskLevel.critical ||
                    log.riskLevel == RiskLevel.high
                ? 1.5
                : 1,
          ),
          boxShadow: ITColors.lightCardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getEventColor(log.eventType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getEventIcon(log.eventType),
                    color: _getEventColor(log.eventType),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.userName,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        log.userEmail,
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRiskBadge(log.riskLevel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildEventTypeBadge(log.eventType),
                const Spacer(),
                if (log.isFlagged)
                  Icon(Icons.flag_rounded, size: 14, color: ITColors.warning),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: ITColors.textTertiaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(log.timestamp),
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.language_rounded,
                  size: 12,
                  color: ITColors.textTertiaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${log.ipAddress}${log.location != null ? ' • ${log.location}' : ''}',
                    style: TextStyle(
                      color: ITColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (log.device != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.devices_rounded,
                    size: 12,
                    color: ITColors.textTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    log.device!,
                    style: TextStyle(
                      color: ITColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeBadge(LogEventType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEventColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getEventName(type),
        style: TextStyle(
          color: _getEventColor(type),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRiskBadge(RiskLevel risk) {
    Color color;
    String label;

    switch (risk) {
      case RiskLevel.critical:
        color = ITColors.error;
        label = 'Critical';
        break;
      case RiskLevel.high:
        color = ITColors.orange;
        label = 'High';
        break;
      case RiskLevel.medium:
        color = ITColors.warning;
        label = 'Medium';
        break;
      case RiskLevel.low:
        color = ITColors.success;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            'No logs found',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskBorderColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.critical:
        return ITColors.error.withValues(alpha: 0.3);
      case RiskLevel.high:
        return ITColors.orange.withValues(alpha: 0.3);
      default:
        return isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border;
    }
  }

  Color _getEventColor(LogEventType type) {
    switch (type) {
      case LogEventType.loginSuccess:
        return ITColors.success;
      case LogEventType.loginFailed:
        return ITColors.error;
      case LogEventType.logout:
        return ITColors.info;
      case LogEventType.breachAttempt:
        return ITColors.error;
      case LogEventType.permissionChange:
        return ITColors.purple;
      case LogEventType.apiAccess:
        return ITColors.teal;
      case LogEventType.mfaEnabled:
        return ITColors.success;
      case LogEventType.passwordChange:
        return ITColors.warning;
      case LogEventType.accountLocked:
        return ITColors.error;
      case LogEventType.sessionExpired:
        return ITColors.orange;
    }
  }

  IconData _getEventIcon(LogEventType type) {
    switch (type) {
      case LogEventType.loginSuccess:
        return Icons.login_rounded;
      case LogEventType.loginFailed:
        return Icons.error_outline_rounded;
      case LogEventType.logout:
        return Icons.logout_rounded;
      case LogEventType.breachAttempt:
        return Icons.gpp_bad_rounded;
      case LogEventType.permissionChange:
        return Icons.admin_panel_settings_rounded;
      case LogEventType.apiAccess:
        return Icons.api_rounded;
      case LogEventType.mfaEnabled:
        return Icons.security_rounded;
      case LogEventType.passwordChange:
        return Icons.key_rounded;
      case LogEventType.accountLocked:
        return Icons.lock_rounded;
      case LogEventType.sessionExpired:
        return Icons.timer_off_rounded;
    }
  }

  String _getEventName(LogEventType type) {
    switch (type) {
      case LogEventType.loginSuccess:
        return 'Login Success';
      case LogEventType.loginFailed:
        return 'Login Failed';
      case LogEventType.logout:
        return 'Logout';
      case LogEventType.breachAttempt:
        return 'Breach Attempt';
      case LogEventType.permissionChange:
        return 'Permission Change';
      case LogEventType.apiAccess:
        return 'API Access';
      case LogEventType.mfaEnabled:
        return 'MFA Enabled';
      case LogEventType.passwordChange:
        return 'Password Change';
      case LogEventType.accountLocked:
        return 'Account Locked';
      case LogEventType.sessionExpired:
        return 'Session Expired';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';

    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
