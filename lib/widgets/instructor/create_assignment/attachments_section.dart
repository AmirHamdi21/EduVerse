import 'package:flutter/material.dart';
import '../../../models/instructor/assignment_model.dart';
import 'create_assignment_colors.dart';

class AttachmentsSection extends StatelessWidget {
  final List<AssignmentAttachment> attachments;
  final bool isDark;
  final VoidCallback onChooseFiles;
  final Function(int) onRemoveAttachment;
  final Color? accentColor;

  const AttachmentsSection({
    super.key,
    required this.attachments,
    required this.isDark,
    required this.onChooseFiles,
    required this.onRemoveAttachment,
    this.accentColor,
  });

  Color get _accent => accentColor ?? CreateAssignmentColors.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag & Drop Area
        _buildDropZone(),
        const SizedBox(height: 12),

        // Choose Files Button
        Center(
          child: OutlinedButton.icon(
            onPressed: onChooseFiles,
            icon: Icon(Icons.attach_file_rounded, size: 18, color: _accent),
            label: Text('Choose Files', style: TextStyle(color: _accent)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accent,
              side: BorderSide(
                color: _accent.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        // Attachments List
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...attachments.asMap().entries.map((entry) {
            final index = entry.key;
            final attachment = entry.value;
            return _buildAttachmentItem(attachment, index);
          }),
        ],
      ],
    );
  }

  Widget _buildDropZone() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.3)
            : _accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _accent.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: _accent.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Drag files here or tap to browse',
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, Images, Code files, Datasets',
              style: TextStyle(
                color: CreateAssignmentColors.textTertiaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(AssignmentAttachment attachment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileTypeIcon(attachment.mimeType),
              size: 20,
              color: _accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.formattedSize,
                  style: TextStyle(
                    color: CreateAssignmentColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onRemoveAttachment(index),
            icon: Icon(
              Icons.close_rounded,
              color: CreateAssignmentColors.textTertiaryColor(isDark),
              size: 18,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              minimumSize: const Size(28, 28),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (mimeType.contains('code') || mimeType.contains('text/')) return Icons.code_rounded;
    if (mimeType.contains('spreadsheet') || mimeType.contains('csv')) return Icons.table_chart_rounded;
    if (mimeType.contains('document') || mimeType.contains('word')) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }
}
