import 'package:flutter/material.dart';

import '../../../models/instructor/upload_materials_model.dart';
import 'upload_materials_colors.dart';

class BundleUploadSection extends StatelessWidget {
  final bool isDark;
  final String bundleName;
  final ValueChanged<String> onBundleNameChanged;
  final UploadProgressState? progress;
  final VoidCallback onSelectBundleFiles;
  final VoidCallback? onRetry;
  final String? selectedWeekLabel;

  const BundleUploadSection({
    super.key,
    required this.isDark,
    required this.bundleName,
    required this.onBundleNameChanged,
    required this.progress,
    required this.onSelectBundleFiles,
    this.onRetry,
    this.selectedWeekLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasProgress = progress != null;
    final status = progress?.status;

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
                  color: UploadMaterialsColors.archive.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.collections_bookmark_rounded,
                  color: UploadMaterialsColors.archive,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle Upload',
                      style: TextStyle(
                        color: UploadMaterialsColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      selectedWeekLabel == null
                          ? 'Upload one video with companion docs'
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
                key: const ValueKey<String>('bundle-pick-files-button'),
                onPressed: onSelectBundleFiles,
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: const Text('Pick Files'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: UploadMaterialsColors.archive,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey<String>('bundle-name-field-$bundleName'),
            initialValue: bundleName,
            onChanged: onBundleNameChanged,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Bundle Name',
              hintText: 'Example: Week 3 - Sorting',
              labelStyle: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(isDark),
              ),
              hintStyle: TextStyle(
                color: UploadMaterialsColors.textTertiaryColor(isDark),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: TextStyle(
              color: UploadMaterialsColors.textPrimaryColor(isDark),
            ),
          ),
          if (hasProgress) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress!.progressPercent / 100,
                minHeight: 6,
                backgroundColor: UploadMaterialsColors.progressBackground(
                  isDark,
                ),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  UploadMaterialsColors.archive,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              progress!.stepLabel,
              style: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
          if (status == UploadProgressStatus.failed && onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry Failed Items'),
              ),
            ),
        ],
      ),
    );
  }
}
