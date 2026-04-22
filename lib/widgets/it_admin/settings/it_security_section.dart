import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITSecuritySection extends StatelessWidget {
  final bool isDark;
  final List<SecuritySetting> settings;
  final Function(SecuritySetting, bool) onToggle;
  final Function(SecuritySetting) onConfigure;

  const ITSecuritySection({
    super.key,
    required this.isDark,
    required this.settings,
    required this.onToggle,
    required this.onConfigure,
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
          color: isDark ? ITColors.darkBorder : const Color(0xFFFFE5E5),
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...settings.map(
            (setting) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSettingItem(setting),
            ),
          ),
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
            color: ITColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.security_rounded, color: ITColors.error, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Security Settings',
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

  Widget _buildSettingItem(SecuritySetting setting) {
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
                  color: setting.isEnabled
                      ? ITColors.success.withValues(alpha: 0.1)
                      : ITColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  setting.icon,
                  size: 18,
                  color: setting.isEnabled
                      ? ITColors.success
                      : ITColors.textSecondaryColor(isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.title,
                      style: TextStyle(
                        color: ITColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      setting.description,
                      style: TextStyle(
                        color: ITColors.textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: setting.isEnabled,
                onChanged: (value) => onToggle(setting, value),
                activeThumbColor: ITColors.success,
                activeTrackColor: ITColors.success.withValues(alpha: 0.3),
              ),
            ],
          ),
          if (setting.lastUpdated != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last updated: ${setting.lastUpdated}',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onConfigure(setting),
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
                      child: Text(
                        'Configure',
                        style: TextStyle(
                          color: ITColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
