import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_event.dart';
import '../../../bloc/voice_to_text/voice_to_text_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/student/voice_to_text/voice_recording_button.dart';
import '../../../widgets/student/voice_to_text/waveform_visualizer.dart';
import '../../../widgets/student/voice_to_text/transcription_card.dart';
import '../../../widgets/student/voice_to_text/recordings_list_card.dart';

class VoiceToTextScreen extends StatelessWidget {
  const VoiceToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VoiceToTextBloc()..add(const InitializeVoiceToText()),
      child: const _VoiceToTextScreenContent(),
    );
  }
}

class _VoiceToTextScreenContent extends StatelessWidget {
  const _VoiceToTextScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocListener<VoiceToTextBloc, VoiceToTextState>(
          listener: (context, state) {
            // Show error messages
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.errorMessage!)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }

            // Show success messages
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.successMessage!)),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF030712),
                          const Color(0xFF162456),
                          const Color(0xFF101828),
                        ]
                      : [
                          const Color(0xFF1C398E),
                          const Color(0xFF193CB8),
                          const Color(0xFF104E64),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Background decorations
                  _buildBackgroundDecorations(isDark),

                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // App Bar
                        _buildAppBar(context, isDark, l10n),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                const SizedBox(height: 32),

                                // Recording Button Section
                                const VoiceRecordingButton(),

                                const SizedBox(height: 24),

                                // Waveform Visualizer
                                const WaveformVisualizer(),

                                const SizedBox(height: 32),

                                // Transcription Card
                                const TranscriptionCard(),

                                const SizedBox(height: 24),

                                // Recent Recordings
                                const RecordingsListCard(),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  const Color(0xFF06B6D4).withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.5, 0.7],
              ),
            ),
          ),
        ),

        // Top blur circle
        Positioned(
          top: 80,
          left: 80,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2B7FFF).withOpacity(0.2),
            ),
          ),
        ),

        // Bottom blur circle
        Positioned(
          bottom: -100,
          left: -86,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00B8DB).withOpacity(0.2),
            ),
          ),
        ),

        // Apply blur to the circles
        Positioned.fill(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF101828).withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF1E2939).withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => safeBack(context, '/dashboard'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iosBackIcon(context), color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.voiceToTextTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.voiceToTextSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFDBEAFE),
                  ),
                ),
              ],
            ),
          ),

          // Settings Button
          GestureDetector(
            onTap: () => _showSettingsBottomSheet(context, isDark, l10n),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262626).withOpacity(0.3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF262626)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: isDark ? Colors.white : const Color(0xFF155DFC),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF101828) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2939)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              l10n.voiceToTextSettings,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 24),

            // Language Setting
            _buildSettingItem(
              isDark: isDark,
              icon: Icons.language_rounded,
              title: l10n.voiceToTextLanguage,
              subtitle: l10n.voiceToTextLanguageDesc,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF155DFC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Auto',
                  style: TextStyle(
                    color: Color(0xFF155DFC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Divider(height: 32),

            // Auto-punctuation Setting
            _buildSettingItem(
              isDark: isDark,
              icon: Icons.auto_fix_high_rounded,
              title: l10n.voiceToTextAutoPunctuation,
              subtitle: l10n.voiceToTextAutoPunctuationDesc,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF155DFC),
              ),
            ),
            const Divider(height: 32),

            // Continuous Recording Setting
            _buildSettingItem(
              isDark: isDark,
              icon: Icons.loop_rounded,
              title: l10n.voiceToTextContinuousRecording,
              subtitle: l10n.voiceToTextContinuousRecordingDesc,
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: const Color(0xFF155DFC),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF155DFC), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
