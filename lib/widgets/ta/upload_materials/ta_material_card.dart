import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

enum TAMaterialType { pdf, video, code, image, document, archive, other }

class TAMaterialItem {
  final String id;
  final String name;
  final String size;
  final String uploadDate;
  final String uploadedBy;
  final TAMaterialType type;
  final bool isAIGenerated;
  final String? courseId;
  final String? labId;

  const TAMaterialItem({
    required this.id,
    required this.name,
    required this.size,
    required this.uploadDate,
    required this.uploadedBy,
    required this.type,
    this.isAIGenerated = false,
    this.courseId,
    this.labId,
  });
}

class TAMaterialCard extends StatelessWidget {
  final TAMaterialItem material;
  final bool isDark;
  final VoidCallback? onView;
  final VoidCallback? onDownload;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;

  const TAMaterialCard({
    super.key,
    required this.material,
    required this.isDark,
    this.onView,
    this.onDownload,
    this.onReplace,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: material.isAIGenerated
              ? TAColors.primary.withValues(alpha: 0.3)
              : TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 24),
                ),
                if (material.isAIGenerated)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: TAColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        material.name,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (material.isAIGenerated)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TAColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AI',
                          style: TextStyle(
                            color: TAColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${material.size} • ${material.uploadDate} • ${material.uploadedBy}',
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.visibility_outlined,
                color: TAColors.info,
                isDark: isDark,
                onTap: onView,
                tooltip: 'View',
              ),
              _ActionButton(
                icon: Icons.download_outlined,
                color: TAColors.success,
                isDark: isDark,
                onTap: onDownload,
                tooltip: 'Download',
              ),
              _ActionButton(
                icon: Icons.swap_horiz_rounded,
                color: TAColors.warning,
                isDark: isDark,
                onTap: onReplace,
                tooltip: 'Replace',
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                color: TAColors.error,
                isDark: isDark,
                onTap: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case TAMaterialType.video:
        return Icons.videocam_rounded;
      case TAMaterialType.code:
        return Icons.code_rounded;
      case TAMaterialType.image:
        return Icons.image_rounded;
      case TAMaterialType.document:
        return Icons.description_rounded;
      case TAMaterialType.archive:
        return Icons.folder_zip_rounded;
      case TAMaterialType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getTypeColor() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return const Color(0xFFE74C3C);
      case TAMaterialType.video:
        return const Color(0xFF9B59B6);
      case TAMaterialType.code:
        return const Color(0xFF3498DB);
      case TAMaterialType.image:
        return const Color(0xFF2ECC71);
      case TAMaterialType.document:
        return const Color(0xFFF39C12);
      case TAMaterialType.archive:
        return const Color(0xFF1ABC9C);
      case TAMaterialType.other:
        return const Color(0xFF95A5A6);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}
