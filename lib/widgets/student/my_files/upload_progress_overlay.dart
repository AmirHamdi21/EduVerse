import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class UploadProgressOverlay extends StatelessWidget {
  const UploadProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (p, c) => p.uploadProgress != c.uploadProgress,
      builder: (context, state) {
        final progress = state.uploadProgress;

        if (progress == null || progress.status == UploadStatus.idle) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 100,
          left: 16,
          right: 16,
          child: _UploadProgressCard(progress: progress),
        );
      },
    );
  }
}

class _UploadProgressCard extends StatelessWidget {
  final UploadProgress progress;

  const _UploadProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (progress.status) {
      case UploadStatus.picking:
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.folder_open_rounded;
        statusText = l10n.selectingFiles;
        break;
      case UploadStatus.uploading:
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.cloud_upload_rounded;
        statusText = '${l10n.uploading} ${progress.fileName}';
        break;
      case UploadStatus.completed:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        statusText = l10n.uploadComplete;
        break;
      case UploadStatus.failed:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_rounded;
        statusText = progress.errorMessage ?? l10n.uploadFailed;
        break;
      case UploadStatus.idle:
        return const SizedBox.shrink();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.status == UploadStatus.uploading
                            ? l10n.uploading
                            : statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (progress.status == UploadStatus.uploading)
                        Text(
                          progress.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (progress.status == UploadStatus.uploading)
                  Text(
                    '${(progress.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (progress.status == UploadStatus.uploading) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.progress),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
