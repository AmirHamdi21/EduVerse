import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_profile_barrel.dart';

class ITProfilePreferencesTab extends StatefulWidget {
  final bool isDark;
  final UIPreferences preferences;
  final List<ActivityLogEntry> activityLog;
  final Function(UIPreferences) onSave;
  final VoidCallback onRevokeApiKeys;
  final VoidCallback onResetSecuritySettings;
  final VoidCallback onRequestRoleDowngrade;

  const ITProfilePreferencesTab({
    super.key,
    required this.isDark,
    required this.preferences,
    required this.activityLog,
    required this.onSave,
    required this.onRevokeApiKeys,
    required this.onResetSecuritySettings,
    required this.onRequestRoleDowngrade,
  });

  @override
  State<ITProfilePreferencesTab> createState() =>
      _ITProfilePreferencesTabState();
}

class _ITProfilePreferencesTabState extends State<ITProfilePreferencesTab> {
  late UIPreferences _prefs;

  final List<String> _densityOptions = ['Compact', 'Standard', 'Comfortable'];

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferences;
  }

  void _updatePrefs(UIPreferences newPrefs) {
    setState(() => _prefs = newPrefs);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Theme & UI Customization
        _buildThemeSection(),
        const SizedBox(height: 16),

        // Recent Activity
        _buildRecentActivitySection(),
        const SizedBox(height: 16),

        // Danger Zone
        _buildDangerZoneSection(),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'Theme & UI Customization',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Theme Mode
          Text(
            'Theme Mode',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ThemeModeOption.values.map((mode) {
              final isSelected = _prefs.themeMode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _updatePrefs(_prefs.copyWith(themeMode: mode)),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: mode != ThemeModeOption.auto ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ITColors.primary.withValues(alpha: 0.15)
                          : (widget.isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? ITColors.primary
                            : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getThemeIcon(mode),
                          size: 22,
                          color: isSelected
                              ? ITColors.primary
                              : ITColors.textSecondaryColor(widget.isDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getThemeLabel(mode),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? ITColors.primary
                                : ITColors.textSecondaryColor(widget.isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Accent Color
          Text(
            'Accent Color',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: AccentColorOption.values.map((color) {
              final isSelected = _prefs.accentColor == color;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      _updatePrefs(_prefs.copyWith(accentColor: color)),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: color != AccentColorOption.purple ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getAccentColorValue(color).withValues(alpha: 0.15)
                          : (widget.isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? _getAccentColorValue(color)
                            : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getAccentColorValue(color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getAccentLabel(color),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? _getAccentColorValue(color)
                                : ITColors.textSecondaryColor(widget.isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // UI Density
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UI Density',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ITColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _prefs.uiDensity,
                          items: _densityOptions.map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ITColors.textPrimaryColor(
                                    widget.isDark,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              _updatePrefs(_prefs.copyWith(uiDensity: val)),
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          borderRadius: BorderRadius.circular(10),
                          dropdownColor: widget.isDark
                              ? ITColors.darkCard
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Advanced Metrics toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advanced Metrics Mode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ITColors.textPrimaryColor(widget.isDark),
                      ),
                    ),
                    Text(
                      'Show detailed analytics and charts',
                      style: TextStyle(
                        fontSize: 11,
                        color: ITColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _prefs.advancedMetricsMode,
                onChanged: (val) =>
                    _updatePrefs(_prefs.copyWith(advancedMetricsMode: val)),
                activeTrackColor: ITColors.success.withValues(alpha: 0.5),
                activeThumbColor: ITColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ITColors.cardShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Timestamp',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ITColors.textSecondaryColor(widget.isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Action',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ITColors.textSecondaryColor(widget.isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Severity',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ITColors.textSecondaryColor(widget.isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ITColors.textSecondaryColor(widget.isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          ...widget.activityLog
              .take(5)
              .map((entry) => _buildActivityRow(entry)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(ActivityLogEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatTime(entry.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: ITColors.textSecondaryColor(widget.isDark),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              entry.action,
              style: TextStyle(
                fontSize: 12,
                color: ITColors.textPrimaryColor(widget.isDark),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getSeverityColor(
                    entry.severity,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.severity,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _getSeverityColor(entry.severity),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Icon(
                entry.result == 'success'
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                size: 16,
                color: entry.result == 'success'
                    ? ITColors.success
                    : ITColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ITColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ITColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, size: 18, color: ITColors.error),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildDangerAction(
            icon: Icons.key_off_rounded,
            title: 'Revoke API Keys',
            subtitle: 'Invalidate all API access tokens',
            onTap: widget.onRevokeApiKeys,
          ),
          _buildDangerAction(
            icon: Icons.restore_rounded,
            title: 'Reset Security Settings',
            subtitle: 'Reset MFA and security preferences',
            onTap: widget.onResetSecuritySettings,
          ),
          _buildDangerAction(
            icon: Icons.arrow_downward_rounded,
            title: 'Request Role Downgrade',
            subtitle: 'Submit request for reduced privileges',
            onTap: widget.onRequestRoleDowngrade,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: ITColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ITColors.textPrimaryColor(widget.isDark),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: ITColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ITColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return Icons.light_mode_rounded;
      case ThemeModeOption.dark:
        return Icons.dark_mode_rounded;
      case ThemeModeOption.auto:
        return Icons.brightness_auto_rounded;
    }
  }

  String _getThemeLabel(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.dark:
        return 'Dark';
      case ThemeModeOption.auto:
        return 'Auto';
    }
  }

  Color _getAccentColorValue(AccentColorOption color) {
    switch (color) {
      case AccentColorOption.cyan:
        return ITColors.info;
      case AccentColorOption.teal:
        return ITColors.teal;
      case AccentColorOption.purple:
        return ITColors.purple;
    }
  }

  String _getAccentLabel(AccentColorOption color) {
    switch (color) {
      case AccentColorOption.cyan:
        return 'Cyan';
      case AccentColorOption.teal:
        return 'Teal';
      case AccentColorOption.purple:
        return 'Purple';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return ITColors.error;
      case 'medium':
        return ITColors.warning;
      case 'low':
        return ITColors.success;
      default:
        return ITColors.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${time.month}/${time.day}';
  }
}
