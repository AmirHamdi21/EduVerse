import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_event.dart';
import '../../../bloc/voice_to_text/voice_to_text_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';

class VoiceRecordingButton extends StatefulWidget {
  const VoiceRecordingButton({super.key});

  @override
  State<VoiceRecordingButton> createState() => _VoiceRecordingButtonState();
}

class _VoiceRecordingButtonState extends State<VoiceRecordingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _pulseController.reset();
    _rippleController.stop();
    _rippleController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocConsumer<VoiceToTextBloc, VoiceToTextState>(
          listener: (context, state) {
            if (state.isRecording) {
              _startAnimations();
            } else {
              _stopAnimations();
            }
          },
          builder: (context, state) {
            final isRecording = state.isRecording;
            final isPaused = state.isPaused;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isRecording
                        ? Colors.red.withOpacity(isDark ? 0.3 : 0.15)
                        : isPaused
                        ? Colors.orange.withOpacity(isDark ? 0.3 : 0.15)
                        : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.9)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecording
                          ? Colors.red.withOpacity(0.5)
                          : isPaused
                          ? Colors.orange.withOpacity(0.5)
                          : (isDark
                                ? Colors.white.withOpacity(0.2)
                                : const Color(0xFFBEDBFF)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isRecording
                            ? Colors.red.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRecording) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isRecording
                            ? '🎙️ Listening...'
                            : isPaused
                            ? '⏸️ Paused'
                            : '🎤 Tap to Record',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isRecording
                              ? Colors.red
                              : isPaused
                              ? Colors.orange
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recording Duration
                if (isRecording ||
                    isPaused ||
                    state.recordingDuration.inSeconds > 0)
                  Column(
                    children: [
                      Text(
                        state.formattedRecordingDuration,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRecording
                            ? 'Recording...'
                            : isPaused
                            ? 'Paused'
                            : 'Duration',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFFBEDBFF)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Main Recording Button with Ripple Effects
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple effects when recording
                      if (isRecording) ...[
                        AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 200 + (_rippleAnimation.value * 100),
                              height: 200 + (_rippleAnimation.value * 100),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red.withOpacity(
                                    (1 - _rippleAnimation.value) * 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            final delayedValue =
                                ((_rippleAnimation.value + 0.5) % 1.0);
                            return Container(
                              width: 200 + (delayedValue * 100),
                              height: 200 + (delayedValue * 100),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red.withOpacity(
                                    (1 - delayedValue) * 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // Glow effect
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isRecording
                                  ? Colors.red.withOpacity(0.4)
                                  : const Color(0xFF2B7FFF).withOpacity(0.3),
                              blurRadius: 64,
                              spreadRadius: 16,
                            ),
                          ],
                        ),
                      ),

                      // Main button
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isRecording ? _pulseAnimation.value : 1.0,
                            child: GestureDetector(
                              onTap: () {
                                final bloc = context.read<VoiceToTextBloc>();
                                if (isRecording) {
                                  bloc.add(const StopRecording());
                                } else if (isPaused) {
                                  bloc.add(const ResumeRecording());
                                } else {
                                  bloc.add(const StartRecording());
                                }
                              },
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isRecording
                                        ? [
                                            const Color(0xFFFB2C36),
                                            const Color(0xFFE7000B),
                                          ]
                                        : [
                                            const Color(0xFF155DFC),
                                            const Color(0xFF0092B8),
                                          ],
                                  ),
                                  border: Border.all(
                                    color: isRecording
                                        ? const Color(0xFFFFA2A2)
                                        : const Color(0xFF8EC5FF),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isRecording
                                          ? Colors.red.withOpacity(0.4)
                                          : const Color(
                                              0xFF155DFC,
                                            ).withOpacity(0.4),
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isRecording
                                      ? Icons.stop_rounded
                                      : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Control Buttons (Pause/Cancel)
                if (isRecording || isPaused)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pause/Resume Button
                        _buildControlButton(
                          icon: isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          label: isPaused ? 'Resume' : 'Pause',
                          color: const Color(0xFF155DFC),
                          isDark: isDark,
                          onTap: () {
                            final bloc = context.read<VoiceToTextBloc>();
                            if (isPaused) {
                              bloc.add(const ResumeRecording());
                            } else {
                              bloc.add(const PauseRecording());
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        // Cancel Button
                        _buildControlButton(
                          icon: Icons.close_rounded,
                          label: 'Cancel',
                          color: Colors.red,
                          isDark: isDark,
                          onTap: () {
                            context.read<VoiceToTextBloc>().add(
                              const CancelRecording(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? Colors.white : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: color, size: 24)],
        ),
      ),
    );
  }
}
