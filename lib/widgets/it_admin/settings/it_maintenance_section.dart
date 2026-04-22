import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITMaintenanceSection extends StatelessWidget {
  final bool isDark;
  final List<MaintenanceWindow> maintenanceWindows;
  final Function(MaintenanceWindow) onEdit;
  final Function(MaintenanceWindow, bool) onToggle;
  final VoidCallback? onAddWindow;

  const ITMaintenanceSection({
    super.key,
    required this.isDark,
    required this.maintenanceWindows,
    required this.onEdit,
    required this.onToggle,
    this.onAddWindow,
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
          color: isDark ? ITColors.darkBorder : const Color(0xFFE5D4FF),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...maintenanceWindows.map(
            (window) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMaintenanceItem(window),
            ),
          ),
          if (onAddWindow != null) ...[
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
            color: ITColors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.schedule_rounded, color: ITColors.purple, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Maintenance Windows',
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

  Widget _buildMaintenanceItem(MaintenanceWindow window) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(window.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(window.type),
                  size: 18,
                  color: _getTypeColor(window.type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      window.title,
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.repeat_rounded,
                          size: 12,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            window.schedule,
                            style: TextStyle(
                              color: ITColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: window.isActive,
                onChanged: (value) => onToggle(window, value),
                activeThumbColor: ITColors.success,
                activeTrackColor: ITColors.success.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: window.isActive
                      ? ITColors.success.withValues(alpha: 0.1)
                      : ITColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 12,
                      color: window.isActive
                          ? ITColors.success
                          : ITColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next: ${window.nextRun}',
                      style: TextStyle(
                        color: window.isActive
                            ? ITColors.success
                            : ITColors.textSecondaryColor(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onEdit(window),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: ITColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 12,
                          color: ITColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: ITColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddWindow,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? ITColors.purple.withValues(alpha: 0.1)
                : ITColors.purpleLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ITColors.purple.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: ITColors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add Maintenance Window',
                style: TextStyle(
                  color: ITColors.purple,
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'backup':
        return ITColors.teal;
      case 'update':
        return ITColors.info;
      case 'cleanup':
        return ITColors.orange;
      case 'security':
        return ITColors.error;
      default:
        return ITColors.purple;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'backup':
        return Icons.backup_rounded;
      case 'update':
        return Icons.system_update_rounded;
      case 'cleanup':
        return Icons.cleaning_services_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}
