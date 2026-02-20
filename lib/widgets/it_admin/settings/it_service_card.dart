import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITServiceCard extends StatelessWidget {
  final bool isDark;
  final ServiceConfig service;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onMore;

  const ITServiceCard({
    super.key,
    required this.isDark,
    required this.service,
    this.onView,
    this.onEdit,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkSurface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ITColors.darkBorder : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildDetails(),
          const SizedBox(height: 12),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? ITColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? ITColors.darkBorder
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  service.version,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isOnline = service.status.toLowerCase() == 'online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? ITColors.successLight : ITColors.warningLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline ? ITColors.success : ITColors.warning,
        ),
      ),
      child: Text(
        service.status,
        style: TextStyle(
          color: isOnline ? ITColors.operational : ITColors.degraded,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _buildDetailRow(Icons.location_on_outlined, service.region),
        const SizedBox(height: 4),
        _buildDetailRow(Icons.access_time_rounded, service.lastUpdated),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: ITColors.textSecondaryColor(isDark),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.visibility_outlined,
            label: 'View',
            onTap: onView,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton(Icons.more_vert_rounded, onMore),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? ITColors.darkBorder
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: ITColors.textPrimaryColor(isDark)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? ITColors.darkBorder
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: ITColors.textPrimaryColor(isDark),
          ),
        ),
      ),
    );
  }
}
