import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _courseUpdates = true;
  bool _assignmentReminders = true;
  bool _gradeNotifications = true;
  bool _messageAlerts = true;
  bool _aiSuggestions = true;
  bool _systemAlerts = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showPreview = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.pushNotifications,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Master Toggle
          _buildMasterToggle(isDark, l10n),
          const SizedBox(height: 24),

          // Notification Categories
          _buildSectionTitle('Notification Categories', isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.school_rounded,
              title: 'Course Updates',
              subtitle: 'New content, announcements',
              value: _courseUpdates,
              onChanged: (v) => setState(() => _courseUpdates = v),
              enabled: _pushEnabled,
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.assignment_rounded,
              title: 'Assignment Reminders',
              subtitle: 'Due dates, submissions',
              value: _assignmentReminders,
              onChanged: (v) => setState(() => _assignmentReminders = v),
              enabled: _pushEnabled,
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.grade_rounded,
              title: 'Grade Notifications',
              subtitle: 'New grades, feedback',
              value: _gradeNotifications,
              onChanged: (v) => setState(() => _gradeNotifications = v),
              enabled: _pushEnabled,
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.chat_bubble_rounded,
              title: 'Message Alerts',
              subtitle: 'Chat messages, discussions',
              value: _messageAlerts,
              onChanged: (v) => setState(() => _messageAlerts = v),
              enabled: _pushEnabled,
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.auto_awesome_rounded,
              title: 'AI Suggestions',
              subtitle: 'Study tips, recommendations',
              value: _aiSuggestions,
              onChanged: (v) => setState(() => _aiSuggestions = v),
              enabled: _pushEnabled,
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.settings_rounded,
              title: 'System Alerts',
              subtitle: 'App updates, maintenance',
              value: _systemAlerts,
              onChanged: (v) => setState(() => _systemAlerts = v),
              enabled: _pushEnabled,
            ),
          ]),
          const SizedBox(height: 24),

          // Sound & Vibration
          _buildSectionTitle('Sound & Vibration', isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.volume_up_rounded,
              title: 'Notification Sound',
              subtitle: 'Play sound for notifications',
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
              enabled: _pushEnabled,
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.vibration_rounded,
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _vibrationEnabled,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
              enabled: _pushEnabled,
            ),
          ]),
          const SizedBox(height: 24),

          // Privacy
          _buildSectionTitle('Privacy', isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.preview_rounded,
              title: 'Show Preview',
              subtitle: 'Display message content in notifications',
              value: _showPreview,
              onChanged: (v) => setState(() => _showPreview = v),
              enabled: _pushEnabled,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMasterToggle(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _pushEnabled
              ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
              : isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                  : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _pushEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _pushEnabled ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: _pushEnabled
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.black45),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pushNotifications,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _pushEnabled
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pushEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 14,
                    color: _pushEnabled
                        ? Colors.white.withValues(alpha: 0.8)
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch.adaptive(
              value: _pushEnabled,
              onChanged: (v) {
                HapticFeedback.mediumImpact();
                setState(() => _pushEnabled = v);
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value && enabled
                    ? const Color(0xFF3B82F6)
                    : (isDark ? Colors.white38 : Colors.black26),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled
                  ? (v) {
                      HapticFeedback.selectionClick();
                      onChanged(v);
                    }
                  : null,
              activeColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white12 : Colors.black12,
      height: 1,
      indent: 60,
    );
  }
}
