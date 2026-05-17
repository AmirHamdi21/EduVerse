import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../bloc/profile/profile_models.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../screens/shared/profile/role_profile_theme.dart';
import '../shared_settings_role.dart';
import 'shared_settings_glass.dart';

class SharedSettingsHeader extends StatelessWidget {
  final UserProfile profile;
  final SharedSettingsRole role;
  final RoleProfileTheme theme;
  final bool isDark;
  final VoidCallback onTap;

  const SharedSettingsHeader({
    super.key,
    required this.profile,
    required this.role,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SettingsGlassSurface(
        isDark: isDark,
        accent: theme.primary,
        padding: const EdgeInsetsDirectional.all(16),
        borderRadius: BorderRadius.circular(26),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? theme.darkHeaderGradient
                    : theme.headerGradient,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.44),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textSecondary(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(
                        alpha: isDark ? 0.18 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.primary.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      role.label(l10n),
                      style: TextStyle(
                        color: isDark ? Colors.white : theme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: theme.textTertiary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedSettingsStateCard extends StatelessWidget {
  final bool isDark;
  final RoleProfileTheme theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const SharedSettingsStateCard({
    super.key,
    required this.isDark,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsGlassSurface(
      isDark: isDark,
      accent: theme.primary,
      padding: const EdgeInsetsDirectional.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.textSecondary(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class SharedSettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final RoleProfileTheme theme;
  final List<SharedSettingsItem> items;

  const SharedSettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.isDark,
    required this.theme,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsGlassSurface(
      isDark: isDark,
      accent: theme.primary,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.all(8),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 18, color: theme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textPrimary(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return Column(
              children: [
                SharedSettingsTile(item: item, isDark: isDark, theme: theme),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 70,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.07),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class SharedSettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final bool destructive;

  const SharedSettingsItem({
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.onTap,
    this.trailing,
    this.iconColor,
    this.destructive = false,
  });
}

class SharedSettingsTile extends StatelessWidget {
  final SharedSettingsItem item;
  final bool isDark;
  final RoleProfileTheme theme;

  const SharedSettingsTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = item.destructive
        ? theme.error
        : item.iconColor ?? theme.primary;
    final titleColor = item.destructive
        ? theme.error
        : theme.textPrimary(isDark);

    return InkWell(
      onTap: item.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              item.onTap!();
            },
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 14, 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (item.trailing != null)
              item.trailing!
            else if (item.onTap != null)
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: item.destructive
                    ? theme.error.withValues(alpha: 0.60)
                    : theme.textTertiary(isDark),
              ),
          ],
        ),
      ),
    );
  }
}

class SharedSettingsPrimaryButton extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;

  const SharedSettingsPrimaryButton({
    super.key,
    required this.label,
    required this.accent,
    this.onPressed,
    this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFFF453A) : accent;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
