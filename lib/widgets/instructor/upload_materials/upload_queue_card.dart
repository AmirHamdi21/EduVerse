import 'package:flutter/material.dart';
import '../../../models/instructor/upload_materials_model.dart';
import 'upload_materials_colors.dart';

/// Upload queue item card showing upload progress
class UploadQueueCard extends StatelessWidget {
  final UploadQueueItem item;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;
  final bool isDark;

  const UploadQueueCard({
    super.key,
    required this.item,
    this.onCancel,
    this.onRetry,
    this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UploadMaterialsColors.borderColor(isDark)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // File type icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.type.icon, color: item.type.color, size: 22),
              ),
              const SizedBox(width: 12),
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      style: TextStyle(
                        color: UploadMaterialsColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.formattedSize} • ${_getStatusText()}',
                      style: TextStyle(color: _getStatusColor(), fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Action button
              _buildActionButton(),
            ],
          ),
          // Progress bar
          if (item.status == UploadStatus.uploading ||
              item.status == UploadStatus.processing) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                backgroundColor: UploadMaterialsColors.progressBackground(
                  isDark,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(item.progress * 100).toInt()}%',
                  style: TextStyle(
                    color: UploadMaterialsColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                if (item.status == UploadStatus.uploading)
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      color: UploadMaterialsColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                if (item.status == UploadStatus.processing)
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: UploadMaterialsColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
          // Error message
          if (item.status == UploadStatus.failed &&
              item.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: UploadMaterialsColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: UploadMaterialsColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.errorMessage!,
                      style: TextStyle(
                        color: UploadMaterialsColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    switch (item.status) {
      case UploadStatus.pending:
      case UploadStatus.uploading:
        return IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: UploadMaterialsColors.textSecondaryColor(isDark),
            size: 20,
          ),
          onPressed: onCancel,
          tooltip: 'Cancel',
        );
      case UploadStatus.processing:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: UploadMaterialsColors.warning,
          ),
        );
      case UploadStatus.completed:
        return Icon(
          Icons.check_circle_rounded,
          color: UploadMaterialsColors.success,
          size: 24,
        );
      case UploadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: UploadMaterialsColors.primary,
                size: 20,
              ),
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: UploadMaterialsColors.error,
                size: 20,
              ),
              onPressed: onRemove,
              tooltip: 'Remove',
            ),
          ],
        );
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case UploadStatus.pending:
        return 'Waiting';
      case UploadStatus.uploading:
        return 'Uploading';
      case UploadStatus.processing:
        return 'Processing';
      case UploadStatus.completed:
        return 'Completed';
      case UploadStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor() {
    switch (item.status) {
      case UploadStatus.pending:
        return UploadMaterialsColors.textTertiaryColor(isDark);
      case UploadStatus.uploading:
        return UploadMaterialsColors.primary;
      case UploadStatus.processing:
        return UploadMaterialsColors.warning;
      case UploadStatus.completed:
        return UploadMaterialsColors.success;
      case UploadStatus.failed:
        return UploadMaterialsColors.error;
    }
  }

  Color _getProgressColor() {
    switch (item.status) {
      case UploadStatus.uploading:
        return UploadMaterialsColors.primary;
      case UploadStatus.processing:
        return UploadMaterialsColors.warning;
      default:
        return UploadMaterialsColors.primary;
    }
  }
}

/// Empty state for upload queue
class UploadQueueEmpty extends StatelessWidget {
  final bool isDark;

  const UploadQueueEmpty({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: UploadMaterialsColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.cloud_queue_rounded,
                color: UploadMaterialsColors.textTertiaryColor(isDark),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No files in queue',
              style: TextStyle(
                color: UploadMaterialsColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select files to upload',
              style: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
