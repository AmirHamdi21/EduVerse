import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class IpRule {
  final String id;
  final String ipAddress;
  final String description;
  final bool isWhitelisted;
  final DateTime addedDate;

  const IpRule({
    required this.id,
    required this.ipAddress,
    required this.description,
    required this.isWhitelisted,
    required this.addedDate,
  });
}

class IpManagementCard extends StatelessWidget {
  final bool isDark;
  final List<IpRule> rules;
  final Function(IpRule) onRemove;
  final VoidCallback onAddWhitelist;
  final VoidCallback onAddBlacklist;
  final VoidCallback onViewAll;

  const IpManagementCard({
    super.key,
    required this.isDark,
    required this.rules,
    required this.onRemove,
    required this.onAddWhitelist,
    required this.onAddBlacklist,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final whitelisted = rules.where((r) => r.isWhitelisted).length;
    final blacklisted = rules.where((r) => !r.isWhitelisted).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
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
                  color: AdminColors.chartOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: AdminColors.chartOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ipManagement,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    Text(
                      l10n.ipManagementDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  icon: Icons.check_circle_rounded,
                  label: l10n.whitelisted,
                  value: whitelisted.toString(),
                  color: AdminColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatChip(
                  icon: Icons.block_rounded,
                  label: l10n.blacklisted,
                  value: blacklisted.toString(),
                  color: AdminColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: l10n.addToWhitelist,
                  color: AdminColors.success,
                  onTap: onAddWhitelist,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.remove_circle_outline_rounded,
                  label: l10n.addToBlacklist,
                  color: AdminColors.error,
                  onTap: onAddBlacklist,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.recentRules,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 10),
          ...rules.take(4).map((rule) => _buildRuleItem(rule, l10n)),
          if (rules.length > 4) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onViewAll,
                child: Text(
                  '${l10n.viewAll} (${rules.length} ${l10n.rules})',
                  style: TextStyle(color: AdminColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(IpRule rule, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : AdminColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: rule.isWhitelisted
                    ? AdminColors.success
                    : AdminColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.ipAddress,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                  Text(
                    rule.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRemove(rule);
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AdminColors.error,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
