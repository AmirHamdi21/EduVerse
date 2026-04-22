import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminVideoConferencingScreen extends StatefulWidget {
  const AdminVideoConferencingScreen({super.key});

  @override
  State<AdminVideoConferencingScreen> createState() =>
      _AdminVideoConferencingScreenState();
}

class _AdminVideoConferencingScreenState
    extends State<AdminVideoConferencingScreen> {
  String _selectedProvider = 'Zoom';
  bool _enabled = true;
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();

  // Settings
  bool _enableWaitingRoom = true;
  bool _enableRecording = false;
  bool _muteOnEntry = true;
  bool _enableChat = true;
  bool _enableScreenShare = true;
  int _maxParticipants = 100;
  int _maxDuration = 60;

  final List<_VideoProvider> _providers = [
    _VideoProvider(
      name: 'Zoom',
      icon: Icons.videocam_rounded,
      color: const Color(0xFF2D8CFF),
    ),
    _VideoProvider(
      name: 'Google Meet',
      icon: Icons.video_call_rounded,
      color: const Color(0xFF00897B),
    ),
    _VideoProvider(
      name: 'Microsoft Teams',
      icon: Icons.groups_rounded,
      color: const Color(0xFF6264A7),
    ),
    _VideoProvider(
      name: 'Jitsi',
      icon: Icons.video_chat_rounded,
      color: const Color(0xFF1D76C3),
    ),
  ];

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiSecretController.dispose();
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
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStatusCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildProviderSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildCredentialsSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildMeetingSettings(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildLimitsSection(isDark, l10n),
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
        l10n.videoConferencing,
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
            : LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade700],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_enabled ? AdminColors.primary : Colors.grey).withValues(
              alpha: 0.3,
            ),
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
                  Icons.video_camera_front_rounded,
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
                      l10n.videoConferencing,
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
                  icon: Icons.video_call_rounded,
                  label: l10n.activeMeetings,
                  value: '12',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.history_rounded,
                  label: l10n.todayMeetings,
                  value: '47',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.people_rounded,
                  label: l10n.participants,
                  value: '234',
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.videoProvider,
      icon: Icons.business_rounded,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _providers.map((provider) {
          final isSelected = _selectedProvider == provider.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedProvider = provider.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? provider.color.withValues(alpha: 0.15)
                    : AdminColors.getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? provider.color
                      : AdminColors.getDividerColor(isDark),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.icon,
                    size: 20,
                    color: isSelected
                        ? provider.color
                        : AdminColors.getTextTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? provider.color
                          : AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCredentialsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.apiCredentials,
      icon: Icons.vpn_key_rounded,
      child: Column(
        children: [
          _buildTextField(
            isDark: isDark,
            label: l10n.apiKey,
            hint: 'Enter API key',
            controller: _apiKeyController,
            prefixIcon: Icons.key_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            isDark: isDark,
            label: l10n.apiSecret,
            hint: 'Enter API secret',
            controller: _apiSecretController,
            prefixIcon: Icons.lock_rounded,
            isPassword: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingSettings(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.meetingSettings,
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.enableWaitingRoom,
            subtitle: l10n.waitingRoomDesc,
            icon: Icons.hourglass_top_rounded,
            value: _enableWaitingRoom,
            onChanged: (v) => setState(() => _enableWaitingRoom = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.enableRecording,
            subtitle: l10n.recordingDesc,
            icon: Icons.fiber_manual_record_rounded,
            value: _enableRecording,
            onChanged: (v) => setState(() => _enableRecording = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.muteOnEntry,
            subtitle: l10n.muteOnEntryDesc,
            icon: Icons.mic_off_rounded,
            value: _muteOnEntry,
            onChanged: (v) => setState(() => _muteOnEntry = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.enableChat,
            subtitle: l10n.chatDesc,
            icon: Icons.chat_rounded,
            value: _enableChat,
            onChanged: (v) => setState(() => _enableChat = v),
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.enableScreenShare,
            subtitle: l10n.screenShareDesc,
            icon: Icons.screen_share_rounded,
            value: _enableScreenShare,
            onChanged: (v) => setState(() => _enableScreenShare = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection(bool isDark, AppLocalizations l10n) {
    return _buildSection(
      isDark: isDark,
      title: l10n.limits,
      icon: Icons.speed_rounded,
      child: Column(
        children: [
          _buildSliderItem(
            isDark: isDark,
            title: l10n.maxParticipants,
            value: _maxParticipants.toDouble(),
            min: 10,
            max: 500,
            divisions: 49,
            onChanged: (v) => setState(() => _maxParticipants = v.round()),
            displayValue: '$_maxParticipants',
          ),
          const SizedBox(height: 16),
          _buildSliderItem(
            isDark: isDark,
            title: l10n.maxDuration,
            value: _maxDuration.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            onChanged: (v) => setState(() => _maxDuration = v.round()),
            displayValue: '$_maxDuration ${l10n.minutes}',
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
    bool isPassword = false,
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
          obscureText: isPassword,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
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
              borderSide: BorderSide(
                color: AdminColors.getDividerColor(isDark),
              ),
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

  Widget _buildSliderItem({
    required bool isDark,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AdminColors.primary,
            inactiveTrackColor: AdminColors.primary.withValues(alpha: 0.2),
            thumbColor: AdminColors.primary,
            overlayColor: AdminColors.primary.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, color: AdminColors.getDividerColor(isDark));
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.videoConferencingSaved),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AdminColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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

class _VideoProvider {
  final String name;
  final IconData icon;
  final Color color;

  _VideoProvider({required this.name, required this.icon, required this.color});
}
