import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITServiceConfigSection extends StatelessWidget {
  final bool isDark;
  final List<ServiceConfig> services;
  final Function(ServiceConfig) onViewService;
  final Function(ServiceConfig) onEditService;
  final Function(ServiceConfig) onMoreOptions;
  final VoidCallback? onAddService;

  const ITServiceConfigSection({
    super.key,
    required this.isDark,
    required this.services,
    required this.onViewService,
    required this.onEditService,
    required this.onMoreOptions,
    this.onAddService,
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
          color: isDark ? ITColors.darkBorder : const Color(0xFFBEDBFF),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...services.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ITServiceCard(
                  isDark: isDark,
                  service: service,
                  onView: () => onViewService(service),
                  onEdit: () => onEditService(service),
                  onMore: () => onMoreOptions(service),
                ),
              )),
          if (onAddService != null) ...[
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
            color: ITColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.dns_rounded,
            color: ITColors.secondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Server & Microservice Configuration',
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

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddService,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? ITColors.primary.withValues(alpha: 0.1)
                : ITColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ITColors.primary.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: ITColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Add New Service',
                style: TextStyle(
                  color: ITColors.primary,
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
}
