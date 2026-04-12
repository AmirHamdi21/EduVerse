import 'package:flutter/material.dart';

import '../../../models/instructor/upload_materials_model.dart';
import 'upload_materials_colors.dart';

class VideoUploadSection extends StatelessWidget {
  final UploadProgressState? progress;
  final bool isDark;
  final VoidCallback onSelectVideo;
  final VoidCallback? onRetry;
  final String? selectedWeekLabel;

  const VideoUploadSection({
    super.key,
    required this.progress,
    required this.isDark,
    required this.onSelectVideo,
    this.onRetry,
    this.selectedWeekLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasProgress = progress != null;
    final percent = (progress?.progressPercent ?? 0).clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UploadMaterialsColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: UploadMaterialsColors.video.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.video_library_rounded,
                  color: UploadMaterialsColors.video,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Upload',
                      style: TextStyle(
                        color: UploadMaterialsColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      selectedWeekLabel == null
                          ? 'Select a video file and start upload'
                          : 'Destination: $selectedWeekLabel',
                      style: TextStyle(
                        color: UploadMaterialsColors.textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                key: const ValueKey<String>('video-select-button'),
                onPressed: onSelectVideo,
                icon: const Icon(Icons.upload_file_rounded, size: 16),
                label: const Text('Select'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: UploadMaterialsColors.video,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: UploadMaterialsColors.progressBackground(
                  isDark,
                ),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  UploadMaterialsColors.video,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress!.stepLabel,
                    style: TextStyle(
                      color: UploadMaterialsColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: UploadMaterialsColors.textPrimaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (progress?.status == UploadProgressStatus.failed &&
              onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: UploadMaterialsColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
