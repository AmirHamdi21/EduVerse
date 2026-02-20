import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_integration_barrel.dart';

class ITIntegrationListSection extends StatelessWidget {
  final bool isDark;
  final List<IntegrationProvider> integrations;
  final String sectionTitle;
  final String? sectionSubtitle;
  final Function(IntegrationProvider) onIntegrationTap;
  final Function(IntegrationProvider) onConfigure;
  final Function(IntegrationProvider) onSync;
  final Function(IntegrationProvider) onToggleConnection;
  final VoidCallback? onViewAll;

  const ITIntegrationListSection({
    super.key,
    required this.isDark,
    required this.integrations,
    required this.sectionTitle,
    this.sectionSubtitle,
    required this.onIntegrationTap,
    required this.onConfigure,
    required this.onSync,
    required this.onToggleConnection,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (integrations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionTitle,
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sectionSubtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sectionSubtitle!,
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${integrations.length}',
                  style: TextStyle(
                    color: ITColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: ITColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: ITColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Integration cards
        ...integrations.map((integration) => ITIntegrationCard(
              isDark: isDark,
              integration: integration,
              onTap: () => onIntegrationTap(integration),
              onConfigure: () => onConfigure(integration),
              onSync: () => onSync(integration),
              onToggleConnection: () => onToggleConnection(integration),
            )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hub_outlined,
            size: 48,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            'No integrations found',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
