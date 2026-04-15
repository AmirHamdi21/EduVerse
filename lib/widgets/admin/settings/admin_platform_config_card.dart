import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminPlatformConfigCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final LinearGradient? gradient;
  final String? status;
  final bool isActive;
  final VoidCallback? onTap;
  final List<PlatformConfigItem>? items;

  const AdminPlatformConfigCard({
    super.key,
    required this.isDark,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.gradient,
    this.status,
    this.isActive = true,
    this.onTap,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AdminColors.primary.withValues(alpha: 0.3)
                : AdminColors.getCardBorderColor(isDark),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient ?? AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (iconColor ?? AdminColors.primary).withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminColors.getTextSecondaryColor(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (status != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AdminColors.success.withValues(alpha: 0.1)
                          : AdminColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AdminColors.success
                            : AdminColors.warning,
                      ),
                    ),
                  ),
                ],
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AdminColors.getTextTertiaryColor(isDark),
                    size: 22,
                  ),
                ],
              ],
            ),
            if (items != null && items!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: AdminColors.getDividerColor(isDark), height: 1),
              const SizedBox(height: 12),
              ...items!.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.statusColor ?? AdminColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: AdminColors.getTextSecondaryColor(isDark),
                          ),
                        ),
                      ),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PlatformConfigItem {
  final String label;
  final String value;
  final Color? statusColor;

  const PlatformConfigItem({
    required this.label,
    required this.value,
    this.statusColor,
  });
}
