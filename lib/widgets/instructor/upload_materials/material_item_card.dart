import 'package:flutter/material.dart';
import '../../../models/instructor/upload_materials_model.dart';
import 'upload_materials_colors.dart';

/// Material item card for displaying uploaded materials
class MaterialItemCard extends StatelessWidget {
  final CourseMaterial material;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDownload;
  final bool isDark;

  const MaterialItemCard({
    super.key,
    required this.material,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleVisibility,
    this.onDownload,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: material.isVisible ? 1.0 : 0.72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: UploadMaterialsColors.borderColor(isDark),
              ),
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
            child: Row(
              children: [
                // File type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: material.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    material.type.icon,
                    color: material.type.color,
                    size: 24,
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
                                color: UploadMaterialsColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!material.isVisible)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: UploadMaterialsColors.warning.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hidden',
                                style: TextStyle(
                                  color: UploadMaterialsColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            material.formattedSize,
                            style: TextStyle(
                              color: UploadMaterialsColors.textSecondaryColor(
                                isDark,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          if (material.downloadCount > 0) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: UploadMaterialsColors.textTertiaryColor(
                                  isDark,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(
                              Icons.download_rounded,
                              size: 12,
                              color: UploadMaterialsColors.textTertiaryColor(
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${material.downloadCount}',
                              style: TextStyle(
                                color: UploadMaterialsColors.textSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (material.tags != null &&
                          material.tags!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: material.tags!.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: UploadMaterialsColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: UploadMaterialsColors.primary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: UploadMaterialsColors.textSecondaryColor(isDark),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'visibility':
                        onToggleVisibility?.call();
                        break;
                      case 'download':
                        onDownload?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem(
                      'edit',
                      Icons.edit_outlined,
                      'Edit',
                      UploadMaterialsColors.textPrimaryColor(isDark),
                    ),
                    _buildMenuItem(
                      'visibility',
                      material.isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      material.isVisible ? 'Hide' : 'Show',
                      UploadMaterialsColors.textPrimaryColor(isDark),
                    ),
                    _buildMenuItem(
                      'download',
                      Icons.download_outlined,
                      'Download',
                      UploadMaterialsColors.textPrimaryColor(isDark),
                    ),
                    if (onDelete != null) ...[
                      const PopupMenuDivider(),
                      _buildMenuItem(
                        'delete',
                        Icons.delete_outline,
                        'Delete',
                        UploadMaterialsColors.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}

/// Materials list empty state
class MaterialsListEmpty extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onUpload;

  const MaterialsListEmpty({super.key, required this.isDark, this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: UploadMaterialsColors.surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  color: UploadMaterialsColors.textTertiaryColor(isDark),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Materials Yet',
                style: TextStyle(
                  color: UploadMaterialsColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload course materials to share with your students',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                  fontSize: 14,
                ),
              ),
              if (onUpload != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Upload Materials'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UploadMaterialsColors.uploadGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
