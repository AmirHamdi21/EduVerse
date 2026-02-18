import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminPushNotificationsScreen extends StatefulWidget {
  const AdminPushNotificationsScreen({super.key});

  @override
  State<AdminPushNotificationsScreen> createState() =>
      _AdminPushNotificationsScreenState();
}

class _AdminPushNotificationsScreenState
    extends State<AdminPushNotificationsScreen> {
  bool _enabled = true;
  String _selectedProvider = 'Firebase';
  final _serverKeyController = TextEditingController();
  final _senderIdController = TextEditingController();
  
  // Notification types
  bool _newEnrollments = true;
  bool _courseUpdates = true;
  bool _assignments = true;
  bool _grades = true;
  bool _announcements = true;
  bool _messages = true;
  bool _systemAlerts = true;

  @override
  void dispose() {
    _serverKeyController.dispose();
    _senderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStatusCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildProviderSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildNotificationTypesSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildStatisticsSection(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildSaveButton(isDark, l10n),
                  SizedBox(height: responsive.p32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AdminColors.getBackgroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      title: Text(
        l10n.pushNotifications,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _enabled
            ? AdminColors.primaryGradient
            : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade700]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_enabled ? AdminColors.primary : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 32,
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
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _enabled ? l10n.enabled : l10n.disabled,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.devices_rounded,
                  label: l10n.registeredDevices,
                  value: '3,842',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.send_rounded,
                  label: l10n.sentToday,
                  value: '1,247',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSection(bool isDark, AppLocalizations l10n) {
    final providers = [
      ('Firebase', Icons.local_fire_department_rounded, const Color(0xFFFFCA28)),
      ('OneSignal', Icons.notifications_rounded, const Color(0xFFE54B4D)),
      ('AWS SNS', Icons.cloud_rounded, const Color(0xFFFF9900)),
      ('Pusher', Icons.rocket_launch_rounded, const Color(0xFF300D4F)),
    ];

    return _buildSection(
      isDark: isDark,
      title: l10n.notificationProvider,
      icon: Icons.business_rounded,
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: providers.map((provider) {
              final isSelected = _selectedProvider == provider.$1;
              return GestureDetector(
                onTap: () => setState(() => _selectedProvider = provider.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? provider.$3.withValues(alpha: 0.15)
                        : AdminColors.getBackgroundColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? provider.$3
                          : AdminColors.getDividerColor(isDark),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.$2,
                        size: 20,
                        color: isSelected
                            ? provider.$3
                            : AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.$1,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? provider.$3
                              : AdminColors.getTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            isDark: isDark,
            label: l10n.serverKey,
            hint: 'Enter your server key',
            controller: _serverKeyController,
            prefixIcon: Icons.key_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            isDark: isDark,
            label: l10n.senderId,
            hint: 'Enter sender ID',
            controller: _senderIdController,
            prefixIcon: Icons.numbers_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.notificationTypes,
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.newEnrollments,
            subtitle: l10n.newEnrollmentsDesc,
            icon: Icons.person_add_rounded,
            value: _newEnrollments,
            onChanged: (v) => setState(() => _newEnrollments = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.courseUpdates,
            subtitle: l10n.courseUpdatesDesc,
            icon: Icons.school_rounded,
            value: _courseUpdates,
            onChanged: (v) => setState(() => _courseUpdates = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.assignments,
            subtitle: l10n.assignmentsDesc,
            icon: Icons.assignment_rounded,
            value: _assignments,
            onChanged: (v) => setState(() => _assignments = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.grades,
            subtitle: l10n.gradesDesc,
            icon: Icons.grade_rounded,
            value: _grades,
            onChanged: (v) => setState(() => _grades = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.announcements,
            subtitle: l10n.announcementsDesc,
            icon: Icons.campaign_rounded,
            value: _announcements,
            onChanged: (v) => setState(() => _announcements = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.messages,
            subtitle: l10n.messagesDesc,
            icon: Icons.message_rounded,
            value: _messages,
            onChanged: (v) => setState(() => _messages = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.systemAlerts,
            subtitle: l10n.systemAlertsDesc,
            icon: Icons.warning_amber_rounded,
            value: _systemAlerts,
            onChanged: (v) => setState(() => _systemAlerts = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.deliveryStatistics,
      icon: Icons.analytics_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.delivered,
                  value: '98.5%',
                  icon: Icons.check_circle_rounded,
                  color: AdminColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.failed,
                  value: '1.5%',
                  icon: Icons.cancel_rounded,
                  color: AdminColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.opened,
                  value: '67.2%',
                  icon: Icons.visibility_rounded,
                  color: AdminColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  title: l10n.clicked,
                  value: '23.8%',
                  icon: Icons.touch_app_rounded,
                  color: AdminColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AdminColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
            prefixIcon: Icon(
              prefixIcon,
              color: AdminColors.getTextTertiaryColor(isDark),
              size: 20,
            ),
            filled: true,
            fillColor: AdminColors.getBackgroundColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AdminColors.getDividerColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AdminColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? AdminColors.primary.withValues(alpha: 0.1)
                  : AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value
                  ? AdminColors.primary
                  : AdminColors.getTextTertiaryColor(isDark),
              size: 22,
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
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AdminColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: AdminColors.getDividerColor(isDark),
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pushNotificationsSaved),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AdminColors.success,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        l10n.saveConfiguration,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
