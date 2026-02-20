import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITIntegrationSection extends StatelessWidget {
  final bool isDark;
  final List<IntegrationConfig> integrations;
  final Function(IntegrationConfig) onConfigure;
  final Function(IntegrationConfig) onSync;
  final VoidCallback? onAddIntegration;

  const ITIntegrationSection({
    super.key,
    required this.isDark,
    required this.integrations,
    required this.onConfigure,
    required this.onSync,
    this.onAddIntegration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ITColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? ITColors.darkBorder : const Color(0xFFD4F4E8),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...integrations.map(
            (integration) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildIntegrationItem(integration),
            ),
          ),
          if (onAddIntegration != null) ...[
            const SizedBox(height: 8),
            _buildAddButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ITColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.hub_rounded, color: ITColors.teal, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Integrations & APIs',
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntegrationItem(IntegrationConfig integration) {
    final isConnected = integration.status.toLowerCase() == 'connected';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? ITColors.darkBorder : const Color(0xFFE5E7EB),
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
                  color: _getIntegrationColor(
                    integration.type,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  integration.icon,
                  size: 20,
                  color: _getIntegrationColor(integration.type),
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
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isConnected
                                ? ITColors.success.withValues(alpha: 0.1)
                                : ITColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isConnected
                                      ? ITColors.success
                                      : ITColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                integration.status,
                                style: TextStyle(
                                  color: isConnected
                                      ? ITColors.success
                                      : ITColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          integration.type,
                          style: TextStyle(
                            color: ITColors.textTertiaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: 12,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last sync: ${integration.lastSync}',
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildSmallButton(
                    icon: Icons.sync_rounded,
                    label: 'Sync',
                    color: ITColors.info,
                    onTap: () => onSync(integration),
                  ),
                  const SizedBox(width: 8),
                  _buildSmallButton(
                    icon: Icons.settings_outlined,
                    label: 'Configure',
                    color: ITColors.primary,
                    onTap: () => onConfigure(integration),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
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
                label,
                style: TextStyle(
                  color: color,
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

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddIntegration,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? ITColors.teal.withValues(alpha: 0.1)
                : ITColors.tealLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ITColors.teal.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: ITColors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add Integration',
                style: TextStyle(
                  color: ITColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIntegrationColor(String type) {
    switch (type.toLowerCase()) {
      case 'oauth':
        return ITColors.secondary;
      case 'webhook':
        return ITColors.orange;
      case 'api':
        return ITColors.info;
      case 'database':
        return ITColors.purple;
      case 'storage':
        return ITColors.teal;
      default:
        return ITColors.primary;
    }
  }
}
