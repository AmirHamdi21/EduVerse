import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  String _profileVisibility = 'everyone';
  String _activityStatus = 'everyone';
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _allowTagging = true;
  bool _allowMentions = true;
  bool _dataCollection = true;
  bool _personalization = true;
  bool _analytics = true;

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
          l10n.privacy,
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
          // Profile Privacy
          _buildSectionTitle(l10n.profilePrivacy, isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildDropdownItem(
              isDark,
              icon: Icons.person_rounded,
              title: l10n.profileVisibility,
              subtitle: l10n.profileVisibilityDesc,
              value: _profileVisibility,
              options: [
                ('everyone', l10n.everyone),
                ('friends', l10n.friendsOnly),
                ('private', l10n.onlyMe),
              ],
              onChanged: (v) => setState(() => _profileVisibility = v),
            ),
            _buildDivider(isDark),
            _buildDropdownItem(
              isDark,
              icon: Icons.visibility_rounded,
              title: l10n.activityStatus,
              subtitle: l10n.activityStatusDesc,
              value: _activityStatus,
              options: [
                ('everyone', l10n.everyone),
                ('friends', l10n.friendsOnly),
                ('nobody', l10n.nobody),
              ],
              onChanged: (v) => setState(() => _activityStatus = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Online Status
          _buildSectionTitle(l10n.onlineStatus, isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.circle,
              title: l10n.showOnlineStatus,
              subtitle: l10n.showOnlineStatusDesc,
              value: _showOnlineStatus,
              onChanged: (v) => setState(() => _showOnlineStatus = v),
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.schedule_rounded,
              title: l10n.showLastSeen,
              subtitle: l10n.showLastSeenDesc,
              value: _showLastSeen,
              onChanged: (v) => setState(() => _showLastSeen = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Interactions
          _buildSectionTitle(l10n.interactions, isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.local_offer_rounded,
              title: l10n.allowTagging,
              subtitle: l10n.allowTaggingDesc,
              value: _allowTagging,
              onChanged: (v) => setState(() => _allowTagging = v),
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.alternate_email_rounded,
              title: l10n.allowMentions,
              subtitle: l10n.allowMentionsDesc,
              value: _allowMentions,
              onChanged: (v) => setState(() => _allowMentions = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Data & Analytics
          _buildSectionTitle(l10n.dataAnalytics, isDark),
          const SizedBox(height: 12),
          _buildSettingsCard(isDark, [
            _buildToggleItem(
              isDark,
              icon: Icons.data_usage_rounded,
              title: l10n.dataCollection,
              subtitle: l10n.dataCollectionDesc,
              value: _dataCollection,
              onChanged: (v) => setState(() => _dataCollection = v),
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.auto_awesome_rounded,
              title: l10n.personalization,
              subtitle: l10n.personalizationDesc,
              value: _personalization,
              onChanged: (v) => setState(() => _personalization = v),
            ),
            _buildDivider(isDark),
            _buildToggleItem(
              isDark,
              icon: Icons.analytics_rounded,
              title: l10n.analytics,
              subtitle: l10n.analyticsDesc,
              value: _analytics,
              onChanged: (v) => setState(() => _analytics = v),
            ),
          ]),
          const SizedBox(height: 24),

          // Quick Links
          _buildSettingsCard(isDark, [
            _buildNavigationItem(
              isDark,
              icon: Icons.history_rounded,
              title: l10n.loginHistory,
              onTap: () => context.push('/settings/login-history'),
            ),
            _buildDivider(isDark),
            _buildNavigationItem(
              isDark,
              icon: Icons.block_rounded,
              title: l10n.blockedUsers,
              onTap: () => context.push('/settings/blocked-users'),
            ),
            _buildDivider(isDark),
            _buildNavigationItem(
              isDark,
              icon: Icons.download_rounded,
              title: l10n.downloadMyData,
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dataRequestSent),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ]),
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
              size: icon == Icons.circle ? 12 : 20,
              color: value
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

  Widget _buildDropdownItem(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox.shrink(),
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor:
                  isDark ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              items: options.map((o) {
                return DropdownMenuItem(
                  value: o.$1,
                  child: Text(o.$2),
                );
              }).toList(),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    bool isDark, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
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
