import 'package:flutter/material.dart';

import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../../../models/materials/course_material_model.dart';
import 'course_management_colors.dart';

class BundleCard extends StatelessWidget {
  final MaterialBundleModel bundle;
  final bool isDark;
  final ValueChanged<MaterialModel>? onViewMaterial;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BundleCard({
    super.key,
    required this.bundle,
    required this.isDark,
    this.onViewMaterial,
    this.onToggleVisibility,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasVideo = bundle.videoMaterial != null;
    final publishedCount = bundle.materials.where((m) => m.isPublished).length;
    final allHidden = publishedCount == 0;

    return Opacity(
      opacity: allHidden ? 0.75 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CMColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasVideo)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 8,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildThumbnail(),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: _Badge(
                          label: allHidden
                              ? 'Hidden'
                              : '$publishedCount/${bundle.totalMaterials} Published',
                          color: allHidden
                              ? CMColors.warning
                              : CMColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bundle.baseTitle,
                              style: TextStyle(
                                color: CMColors.text(isDark),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (bundle.weekNumber != null)
                                  _Badge(
                                    label: 'Week ${bundle.weekNumber}',
                                    color: CMColors.primary,
                                  ),
                                _Badge(
                                  label: '${bundle.totalMaterials} Materials',
                                  color: CMColors.accent,
                                ),
                                if (bundle.videoMaterial != null)
                                  const _Badge(
                                    label: 'Video',
                                    color: CMColors.error,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: CMColors.textSub(isDark),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'toggle':
                              onToggleVisibility?.call();
                              break;
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'toggle',
                            child: Text('Toggle Visibility'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit Titles'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete Bundle'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (bundle.companionMaterials.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...bundle.companionMaterials.take(4).map((material) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              _iconForType(material.materialType),
                              size: 16,
                              color: CMColors.textSub(isDark),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                material.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: CMColors.text(isDark),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            _Badge(
                              label: material.materialType.toUpperCase(),
                              color: CMColors.teal,
                            ),
                          ],
                        ),
                      );
                    }),
                    if (bundle.companionMaterials.length > 4)
                      Text(
                        '+${bundle.companionMaterials.length - 4} more',
                        style: TextStyle(
                          color: CMColors.textMutedColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final thumbnailUrl = bundle.videoMaterial?.thumbnailUrl;
    final thumbnail = thumbnailUrl == null || thumbnailUrl.isEmpty
        ? Container(
            color: CMColors.primary.withValues(alpha: 0.15),
            child: const Center(
              child: Icon(Icons.play_circle_fill_rounded, size: 52),
            ),
          )
        : Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: CMColors.primary.withValues(alpha: 0.15),
                child: const Center(
                  child: Icon(Icons.play_circle_fill_rounded, size: 52),
                ),
              );
            },
          );

    final videoMaterial = bundle.videoMaterial;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewMaterial != null && videoMaterial != null
            ? () => onViewMaterial!(_mapToLegacyMaterial(videoMaterial))
            : null,
        child: thumbnail,
      ),
    );
  }

  MaterialModel _mapToLegacyMaterial(CourseMaterialModel material) {
    return MaterialModel(
      id: material.materialId,
      title: material.title,
      type: material.materialType,
      fileSize: '',
      fileUrl: material.url ?? material.externalUrl ?? '',
      isPublished: material.isPublished,
      uploadedAt: material.createdAt,
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline_rounded;
      case 'slide':
        return Icons.slideshow_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      case 'link':
        return Icons.link_rounded;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
