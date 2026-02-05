import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class NotificationSwipeSettingsScreen extends StatefulWidget {
  const NotificationSwipeSettingsScreen({super.key});

  @override
  State<NotificationSwipeSettingsScreen> createState() =>
      _NotificationSwipeSettingsScreenState();
}

class _NotificationSwipeSettingsScreenState
    extends State<NotificationSwipeSettingsScreen> {
  String _leftSwipeAction = 'delete';
  String _rightSwipeAction = 'mark_read';
  bool _swipeEnabled = true;
  bool _confirmDelete = true;

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
          l10n.notificationSwipeSettings,
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
          // Preview Card
          _buildPreviewCard(isDark, l10n),
          const SizedBox(height: 24),

          // Enable Swipe
          _buildSectionTitle(l10n.general, isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.swipe_rounded,
              title: l10n.enableSwipe,
              subtitle: l10n.enableSwipeDesc,
              value: _swipeEnabled,
              onChanged: (v) => setState(() => _swipeEnabled = v),
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.warning_rounded,
              title: l10n.confirmDelete,
              subtitle: l10n.confirmDeleteDesc,
              value: _confirmDelete,
              onChanged: (v) => setState(() => _confirmDelete = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Swipe Actions
          _buildSectionTitle(l10n.swipeDirections, isDark),
          const SizedBox(height: 12),
          _buildActionSelector(
            isDark,
            l10n,
            title: l10n.swipeLeft,
            icon: Icons.arrow_back_rounded,
            value: _leftSwipeAction,
            onChanged: (v) => setState(() => _leftSwipeAction = v),
          ),
          const SizedBox(height: 12),
          _buildActionSelector(
            isDark,
            l10n,
            title: l10n.swipeRight,
            icon: Icons.arrow_forward_rounded,
            value: _rightSwipeAction,
            onChanged: (v) => setState(() => _rightSwipeAction = v),
          ),
          const SizedBox(height: 32),
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

  Widget _buildPreviewCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            l10n.preview,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 20,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sampleNotification,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.swipeToSeeActions,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionBadge(
                _getActionColor(_leftSwipeAction),
                _getActionIcon(_leftSwipeAction),
                '← ${_getActionLabel(l10n, _leftSwipeAction)}',
              ),
              const SizedBox(width: 16),
              _buildActionBadge(
                _getActionColor(_rightSwipeAction),
                _getActionIcon(_rightSwipeAction),
                '${_getActionLabel(l10n, _rightSwipeAction)} →',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBadge(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
  }) {
    return Padding(
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
              color: isDark ? Colors.white54 : Colors.black45,
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
                    fontWeight: FontWeight.w600,
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
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 60,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildActionSelector(
    bool isDark,
    AppLocalizations l10n, {
    required String title,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final actions = [
      ('delete', l10n.delete, Icons.delete_rounded, const Color(0xFFEF4444)),
      ('archive', l10n.archive, Icons.archive_rounded, const Color(0xFFF59E0B)),
      ('mark_read', l10n.markAsRead, Icons.mark_email_read_rounded, const Color(0xFF3B82F6)),
      ('pin', l10n.pin, Icons.push_pin_rounded, const Color(0xFF8B5CF6)),
      ('mute', l10n.mute, Icons.notifications_off_rounded, const Color(0xFF64748B)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((action) {
              final isSelected = value == action.$1;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(action.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? action.$4.withValues(alpha: 0.15)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? action.$4
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.$3,
                        size: 18,
                        color: isSelected
                            ? action.$4
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        action.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? action.$4
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'delete':
        return const Color(0xFFEF4444);
      case 'archive':
        return const Color(0xFFF59E0B);
      case 'mark_read':
        return const Color(0xFF3B82F6);
      case 'pin':
        return const Color(0xFF8B5CF6);
      case 'mute':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'delete':
        return Icons.delete_rounded;
      case 'archive':
        return Icons.archive_rounded;
      case 'mark_read':
        return Icons.mark_email_read_rounded;
      case 'pin':
        return Icons.push_pin_rounded;
      case 'mute':
        return Icons.notifications_off_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getActionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'delete':
        return l10n.delete;
      case 'archive':
        return l10n.archive;
      case 'mark_read':
        return l10n.markAsRead;
      case 'pin':
        return l10n.pin;
      case 'mute':
        return l10n.mute;
      default:
        return '';
    }
  }
}
