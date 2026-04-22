import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class Webhook {
  final String id;
  final String name;
  final String url;
  final String? secret;
  final List<String> events;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int successCount;
  final int failureCount;

  const Webhook({
    required this.id,
    required this.name,
    required this.url,
    this.secret,
    required this.events,
    required this.isActive,
    required this.createdAt,
    this.lastTriggered,
    required this.successCount,
    required this.failureCount,
  });
}

class WebhooksCard extends StatelessWidget {
  final bool isDark;
  final List<Webhook> webhooks;
  final Function() onCreateWebhook;
  final Function(Webhook) onEditWebhook;
  final Function(Webhook) onDeleteWebhook;
  final Function(Webhook) onTestWebhook;
  final Function(Webhook, bool) onToggleWebhook;

  const WebhooksCard({
    super.key,
    required this.isDark,
    required this.webhooks,
    required this.onCreateWebhook,
    required this.onEditWebhook,
    required this.onDeleteWebhook,
    required this.onTestWebhook,
    required this.onToggleWebhook,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.webhook_rounded,
                color: AdminColors.chartPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.webhooks,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onCreateWebhook,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addWebhook),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.chartPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (webhooks.isEmpty)
            _buildEmptyState(l10n)
          else
            ...webhooks.map(
              (webhook) => _buildWebhookItem(context, webhook, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.webhook_rounded,
              color: AdminColors.getTextTertiaryColor(isDark),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noWebhooks,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.webhooksDescription,
              style: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebhookItem(
    BuildContext context,
    Webhook webhook,
    AppLocalizations l10n,
  ) {
    final successRate = webhook.successCount + webhook.failureCount > 0
        ? (webhook.successCount /
                  (webhook.successCount + webhook.failureCount) *
                  100)
              .round()
        : 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        (webhook.isActive
                                ? AdminColors.success
                                : AdminColors.getTextTertiaryColor(isDark))
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.webhook_rounded,
                    color: webhook.isActive
                        ? AdminColors.success
                        : AdminColors.getTextTertiaryColor(isDark),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        webhook.name,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        webhook.url,
                        style: TextStyle(
                          color: AdminColors.getTextSecondaryColor(isDark),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: webhook.isActive,
                  onChanged: (value) => onToggleWebhook(webhook, value),
                  activeColor: AdminColors.success,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Events
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: webhook.events
                  .map(
                    (event) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AdminColors.chartPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event,
                        style: TextStyle(
                          color: AdminColors.chartPink,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.check_circle_rounded,
                  value: '${webhook.successCount}',
                  label: l10n.success,
                  color: AdminColors.success,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.error_rounded,
                  value: '${webhook.failureCount}',
                  label: l10n.failed,
                  color: AdminColors.error,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.percent_rounded,
                  value: '$successRate%',
                  label: l10n.rate,
                  color: successRate >= 90
                      ? AdminColors.success
                      : successRate >= 70
                      ? AdminColors.warning
                      : AdminColors.error,
                ),
                // const Spacer(),
              ],
            ),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                  color: AdminColors.primary,
                  onPressed: () => onTestWebhook(webhook),
                  tooltip: l10n.test,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  color: AdminColors.getTextSecondaryColor(isDark),
                  onPressed: () => onEditWebhook(webhook),
                  tooltip: l10n.edit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 20),
                  color: AdminColors.error,
                  onPressed: () => onDeleteWebhook(webhook),
                  tooltip: l10n.delete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            if (webhook.lastTriggered != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.lastTriggered}: ${_formatTime(webhook.lastTriggered!)}',
                    style: TextStyle(
                      color: AdminColors.getTextTertiaryColor(isDark),
                      fontSize: 10,
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

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
