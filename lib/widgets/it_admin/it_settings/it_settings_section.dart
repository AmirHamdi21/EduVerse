import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ITSettingsItem> items;
  final bool isDark;

  const ITSettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: ITColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ITColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ITColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildSettingsItem(item, isLast, index == 0),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: ITColors.borderColor(
                        isDark,
                      ).withValues(alpha: 0.3),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(ITSettingsItem item, bool isLast, bool isFirst) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (item.iconColor ?? ITColors.primary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: item.iconColor ?? ITColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (item.trailing != null)
                item.trailing!
              else if (item.hasToggle)
                Switch(
                  value: item.toggleValue ?? false,
                  onChanged: item.onToggleChanged,
                  activeTrackColor: ITColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: ITColors.primary,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ITColors.textTertiaryColor(isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ITSettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool hasToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const ITSettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.hasToggle = false,
    this.toggleValue,
    this.onToggleChanged,
  });
}
