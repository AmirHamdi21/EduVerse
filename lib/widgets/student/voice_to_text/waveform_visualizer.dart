import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';

class WaveformVisualizer extends StatelessWidget {
  const WaveformVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<VoiceToTextBloc, VoiceToTextState>(
          builder: (context, state) {
            if (!state.isRecording && !state.isPaused) {
              return const SizedBox.shrink();
            }

            return Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: state.waveformData.isEmpty
                  ? _buildIdleWaveform(isDark)
                  : _buildActiveWaveform(state.waveformData, isDark, state.isRecording),
            );
          },
        );
      },
    );
  }

  Widget _buildIdleWaveform(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(40, (index) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFF155DFC),
                const Color(0xFF00D3F2),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildActiveWaveform(List<double> data, bool isDark, bool isRecording) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barCount = (constraints.maxWidth / 8).floor();
        final displayData = _prepareWaveformData(data, barCount);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(displayData.length, (index) {
            final height = displayData[index] * 60 + 4;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 4,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isRecording
                      ? [
                          const Color(0xFF155DFC),
                          const Color(0xFF00D3F2),
                        ]
                      : [
                          Colors.orange,
                          Colors.orangeAccent,
                        ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isRecording
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D3F2).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }

  List<double> _prepareWaveformData(List<double> data, int targetCount) {
    if (data.isEmpty) {
      return List.generate(targetCount, (index) => 0.1);
    }

    if (data.length == targetCount) {
      return data;
    }

    if (data.length < targetCount) {
      // Pad with zeros
      final result = List<double>.from(data);
      while (result.length < targetCount) {
        result.insert(0, 0.1);
      }
      return result;
    }

    // Downsample
    final ratio = data.length / targetCount;
    return List.generate(targetCount, (index) {
      final startIndex = (index * ratio).floor();
      final endIndex = ((index + 1) * ratio).floor().clamp(0, data.length);
      if (startIndex >= endIndex) return 0.1;
      final segment = data.sublist(startIndex, endIndex);
      return segment.reduce((a, b) => a + b) / segment.length;
    });
  }
}
