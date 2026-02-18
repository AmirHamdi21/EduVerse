import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/admin_colors.dart';

class AdminSettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final List<AdminSettingsItem> items;
  final bool isExpanded;

  const AdminSettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.isDark,
    required this.items,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.getCardBorderColor(isDark),
          width: 1,
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AdminColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AdminColors.getDividerColor(isDark),
            height: 1,
          ),

          // Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                _AdminSettingsItemTile(
                  item: item,
                  isDark: isDark,
                ),
                if (!isLast)
                  Divider(
                    color: AdminColors.getDividerColor(isDark),
                    height: 1,
                    indent: 60,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class AdminSettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final bool showBadge;
  final String? badgeText;
  final bool isDestructive;

  const AdminSettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.showBadge = false,
    this.badgeText,
    this.isDestructive = false,
  });
}

class _AdminSettingsItemTile extends StatelessWidget {
  final AdminSettingsItem item;
  final bool isDark;

  const _AdminSettingsItemTile({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = item.isDestructive
        ? AdminColors.error
        : (item.iconColor ?? AdminColors.primary);

    return InkWell(
      onTap: item.onTap != null
          ? () {
              HapticFeedback.selectionClick();
              item.onTap!();
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? AdminColors.error.withValues(alpha: 0.1)
                    : (isDark
                        ? AdminColors.darkBackground
                        : AdminColors.lightBackground),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: item.isDestructive
                                ? AdminColors.error
                                : AdminColors.getTextColor(isDark),
                          ),
                        ),
                      ),
                      if (item.showBadge && item.badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AdminColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.badgeText!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (item.trailing != null)
              item.trailing!
            else if (item.onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AdminColors.getTextTertiaryColor(isDark),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
