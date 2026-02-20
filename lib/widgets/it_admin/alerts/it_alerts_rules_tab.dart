import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsRulesTab extends StatefulWidget {
  final bool isDark;
  final List<AlertRule> rules;
  final String searchQuery;
  final AlertSeverity? selectedSeverity;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<AlertSeverity?> onSeverityChanged;
  final ValueChanged<AlertRule> onRuleTap;
  final ValueChanged<AlertRule> onRuleToggle;
  final VoidCallback onCreateRule;

  const ITAlertsRulesTab({
    super.key,
    required this.isDark,
    required this.rules,
    required this.searchQuery,
    this.selectedSeverity,
    required this.onSearchChanged,
    required this.onSeverityChanged,
    required this.onRuleTap,
    required this.onRuleToggle,
    required this.onCreateRule,
  });

  @override
  State<ITAlertsRulesTab> createState() => _ITAlertsRulesTabState();
}

class _ITAlertsRulesTabState extends State<ITAlertsRulesTab> {
  @override
  Widget build(BuildContext context) {
    final filteredRules = widget.rules.where((rule) {
      final matchesSearch = widget.searchQuery.isEmpty ||
          rule.name.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          rule.service.toLowerCase().contains(widget.searchQuery.toLowerCase());
      final matchesSeverity = widget.selectedSeverity == null ||
          rule.severity == widget.selectedSeverity;
      return matchesSearch && matchesSeverity;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and filters
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: widget.onSearchChanged,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(widget.isDark),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search alert rules...',
                    hintStyle: TextStyle(
                      color: ITColors.textSecondaryColor(widget.isDark),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ITColors.textSecondaryColor(widget.isDark),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildSeverityFilter(),
          ],
        ),
        const SizedBox(height: 12),

        // Create rule button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: widget.onCreateRule,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ITColors.primary, ITColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: ITColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Create Rule',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Rules list
        if (filteredRules.isEmpty)
          _buildEmptyState()
        else
          ...filteredRules.map((rule) => _buildRuleCard(rule)),
      ],
    );
  }

  Widget _buildSeverityFilter() {
    return PopupMenuButton<AlertSeverity?>(
      onSelected: widget.onSeverityChanged,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDark ? ITColors.darkCard : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedSeverity == null
                  ? 'All Severity'
                  : _getSeverityLabel(widget.selectedSeverity!),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ITColors.textPrimaryColor(widget.isDark),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildSeverityMenuItem(null, 'All Severity'),
        _buildSeverityMenuItem(AlertSeverity.critical, 'Critical'),
        _buildSeverityMenuItem(AlertSeverity.warning, 'Warning'),
        _buildSeverityMenuItem(AlertSeverity.info, 'Info'),
      ],
    );
  }

  PopupMenuItem<AlertSeverity?> _buildSeverityMenuItem(AlertSeverity? severity, String label) {
    return PopupMenuItem(
      value: severity,
      child: Row(
        children: [
          if (severity != null)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _getSeverityColor(severity),
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: ITColors.textPrimaryColor(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(AlertRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(widget.isDark),
        border: rule.isEnabled
            ? null
            : Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getSeverityColor(rule.severity).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSeverityIcon(rule.severity),
                  color: _getSeverityColor(rule.severity),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ITColors.textPrimaryColor(widget.isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rule.service,
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.isEnabled,
                onChanged: (_) => widget.onRuleToggle(rule),
                activeTrackColor: ITColors.success.withValues(alpha: 0.5),
                activeThumbColor: ITColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rule.description,
            style: TextStyle(
              fontSize: 13,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildInfoChip(
                Icons.analytics_rounded,
                '${rule.metric} ${rule.operator} ${rule.threshold}',
              ),
              _buildInfoChip(
                Icons.timer_outlined,
                'for ${_formatDuration(rule.forDuration)}',
              ),
              if (rule.lastTriggered != null)
                _buildInfoChip(
                  Icons.access_time_rounded,
                  'Last fired ${_formatTimeAgo(rule.lastTriggered!)}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...rule.tags.take(3).map((tag) => Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ITColors.primary,
                  ),
                ),
              )),
              const Spacer(),
              GestureDetector(
                onTap: () => widget.onRuleTap(rule),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      size: 16,
                      color: ITColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ITColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: ITColors.textSecondaryColor(widget.isDark),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.rule_folder_rounded,
              size: 48,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No alert rules found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(widget.isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first alert rule to start monitoring',
              style: TextStyle(
                fontSize: 13,
                color: ITColors.textSecondaryColor(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return ITColors.error;
      case AlertSeverity.warning:
        return ITColors.warning;
      case AlertSeverity.info:
        return ITColors.info;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error_rounded;
      case AlertSeverity.warning:
        return Icons.warning_rounded;
      case AlertSeverity.info:
        return Icons.info_rounded;
    }
  }

  String _getSeverityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inHours}h';
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }
}
