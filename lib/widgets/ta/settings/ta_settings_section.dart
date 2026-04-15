import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

class TASettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<TASettingsItem> items;
  final bool isDark;

  const TASettingsSection({
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
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: TAColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildSettingsItem(item, isLast),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: TAColors.borderColor(
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

  Widget _buildSettingsItem(TASettingsItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.vertical(
          top: items.indexOf(item) == 0
              ? const Radius.circular(16)
              : Radius.zero,
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
                  color: (item.iconColor ?? TAColors.primary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: item.iconColor ?? TAColors.primary,
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
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
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
                  activeColor: TAColors.primary,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: TAColors.textTertiaryColor(isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TASettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool hasToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const TASettingsItem({
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
