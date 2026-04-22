import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class Integration {
  final String id;
  final String name;
  final String description;
  final String category;
  final String status;
  final IconData icon;
  final Color iconColor;
  final DateTime? lastSync;
  final bool isConnected;

  const Integration({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.icon,
    required this.iconColor,
    this.lastSync,
    required this.isConnected,
  });
}

class IntegrationsListCard extends StatelessWidget {
  final bool isDark;
  final List<Integration> integrations;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final Function(Integration) onIntegrationTap;
  final Function(Integration, bool) onToggleConnection;

  const IntegrationsListCard({
    super.key,
    required this.isDark,
    required this.integrations,
    this.selectedCategory,
    required this.onCategoryChanged,
    required this.onIntegrationTap,
    required this.onToggleConnection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      'all',
      'lms',
      'payment',
      'communication',
      'storage',
      'analytics',
    ];

    final filteredIntegrations =
        selectedCategory == null || selectedCategory == 'all'
        ? integrations
        : integrations.where((i) => i.category == selectedCategory).toList();

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
              Icon(Icons.apps_rounded, color: AdminColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.integrations,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${filteredIntegrations.length} ${l10n.total}',
                style: TextStyle(
                  color: AdminColors.getTextSecondaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = (selectedCategory ?? 'all') == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category, l10n)),
                    selected: isSelected,
                    onSelected: (_) =>
                        onCategoryChanged(category == 'all' ? null : category),
                    backgroundColor: AdminColors.getCardColor(isDark),
                    selectedColor: AdminColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AdminColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AdminColors.primary
                          : AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AdminColors.primary
                          : AdminColors.getCardBorderColor(isDark),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Integrations list
          ...filteredIntegrations.map(
            (integration) => _buildIntegrationItem(context, integration, l10n),
          ),
          if (filteredIntegrations.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.integration_instructions_outlined,
                      color: AdminColors.getTextTertiaryColor(isDark),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noIntegrationsFound,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'all':
        return l10n.all;
      case 'lms':
        return l10n.lms;
      case 'payment':
        return l10n.payment;
      case 'communication':
        return l10n.communication;
      case 'storage':
        return l10n.storage;
      case 'analytics':
        return l10n.analytics;
      default:
        return category;
    }
  }

  Widget _buildIntegrationItem(
    BuildContext context,
    Integration integration,
    AppLocalizations l10n,
  ) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onIntegrationTap(integration),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: integration.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    integration.icon,
                    color: integration.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        integration.name,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        integration.description,
                        style: TextStyle(
                          color: AdminColors.getTextSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (integration.lastSync != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.sync_rounded,
                              size: 12,
                              color: AdminColors.getTextTertiaryColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${l10n.lastSync}: ${_formatTime(integration.lastSync!)}',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(integration.status, l10n),
                    const SizedBox(height: 8),
                    Switch(
                      value: integration.isConnected,
                      onChanged: (value) =>
                          onToggleConnection(integration, value),
                      activeColor: AdminColors.success,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'active':
        backgroundColor = AdminColors.success.withValues(alpha: 0.15);
        textColor = AdminColors.success;
        label = l10n.active;
        break;
      case 'inactive':
        backgroundColor = AdminColors.warning.withValues(alpha: 0.15);
        textColor = AdminColors.warning;
        label = l10n.inactive;
        break;
      case 'error':
        backgroundColor = AdminColors.error.withValues(alpha: 0.15);
        textColor = AdminColors.error;
        label = l10n.error;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
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
