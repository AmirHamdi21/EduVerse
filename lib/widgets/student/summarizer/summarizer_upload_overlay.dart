import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/summarizer/summarizer_cubit.dart';
import '../../../bloc/summarizer/summarizer_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SummarizerUploadOverlay extends StatelessWidget {
  const SummarizerUploadOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<SummarizerCubit, SummarizerState>(
          buildWhen: (previous, current) =>
              previous.uploadProgress != current.uploadProgress,
          builder: (context, state) {
            if (state.uploadProgress == null) {
              return const SizedBox.shrink();
            }

            final progress = state.uploadProgress!;
            final l10n = AppLocalizations.of(context);

            return AnimatedOpacity(
              opacity: progress.isCompleted ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2939) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Upload icon with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: progress.error != null
                                        ? [
                                            const Color(0xFFEF4444),
                                            const Color(0xFFDC2626),
                                          ]
                                        : [
                                            const Color(0xFF3B82F6),
                                            const Color(0xFF1D4ED8),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  progress.error != null
                                      ? Icons.error_outline_rounded
                                      : Icons.cloud_upload_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Status text
                        Text(
                          progress.error != null
                              ? l10n.summarizerUploadFailed
                              : l10n.summarizerUploading,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFF3F4F6)
                                : const Color(0xFF101828),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // File name
                        if (progress.fileName.isNotEmpty)
                          Text(
                            progress.fileName,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 20),
                        // Progress bar
                        if (progress.error == null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress.progress,
                              backgroundColor: isDark
                                  ? const Color(0xFF364153)
                                  : const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3B82F6),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Percentage
                          Text(
                            '${(progress.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else ...[
                          // Error message
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              progress.error!,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
