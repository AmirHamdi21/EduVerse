import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITQuickActionsGrid extends StatelessWidget {
  final bool isDark;
  final Function(String) onActionTap;

  const ITQuickActionsGrid({
    super.key,
    required this.isDark,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      _QuickAction(
        id: 'system_health',
        icon: Icons.monitor_heart_rounded,
        label: l10n.itSystemHealth,
        color: ITColors.success,
      ),
      _QuickAction(
        id: 'servers',
        icon: Icons.dns_rounded,
        label: l10n.itServers,
        color: ITColors.secondary,
      ),
      _QuickAction(
        id: 'security',
        icon: Icons.security_rounded,
        label: l10n.itSecurity,
        color: ITColors.purple,
      ),
      _QuickAction(
        id: 'backup',
        icon: Icons.backup_rounded,
        label: l10n.itBackup,
        color: ITColors.teal,
      ),
      _QuickAction(
        id: 'api',
        icon: Icons.api_rounded,
        label: l10n.itApi,
        color: ITColors.orange,
      ),
      _QuickAction(
        id: 'logs',
        icon: Icons.bug_report_rounded,
        label: l10n.itLogs,
        color: ITColors.error,
      ),
      _QuickAction(
        id: 'database',
        icon: Icons.storage_rounded,
        label: l10n.itDatabase,
        color: ITColors.cyan,
      ),
      _QuickAction(
        id: 'cloud',
        icon: Icons.cloud_rounded,
        label: l10n.itCloud,
        color: ITColors.primary,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded, color: ITColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.itQuickActions,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return _buildActionItem(actions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(_QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onActionTap(action.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: action.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String id;
  final IconData icon;
  final String label;
  final Color color;

  _QuickAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
  });
}
