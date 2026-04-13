import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/course_structure_model.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import 'bundle_card.dart';
import 'course_management_colors.dart';
import 'course_structure_editor.dart';

/// Redesigned materials tab with modern file cards
class MaterialsTab extends StatelessWidget {
  final List<MaterialModel> materials;
  final List<MaterialBundleModel> bundles;
  final List<CourseStructureModel> structureItems;
  final Map<int, int> materialCountsByWeek;
  final String? partialFailureMessage;
  final List<String> failedMaterialIds;
  final VoidCallback? onRetryFailedMaterials;
  final ValueChanged<MaterialModel>? onViewMaterial;
  final ValueChanged<MaterialModel>? onToggleMaterialVisibility;
  final ValueChanged<MaterialModel>? onEditMaterial;
  final ValueChanged<MaterialModel>? onDeleteMaterial;
  final ValueChanged<MaterialBundleModel>? onToggleBundleVisibility;
  final ValueChanged<MaterialBundleModel>? onEditBundle;
  final ValueChanged<MaterialBundleModel>? onDeleteBundle;
  final bool structureLoading;
  final String? structureErrorMessage;
  final VoidCallback? onReloadStructure;
  final CreateStructureItemCallback? onCreateStructureItem;
  final UpdateStructureItemCallback? onUpdateStructureItem;
  final DeleteStructureItemCallback? onDeleteStructureItem;
  final ReorderStructureItemsCallback? onReorderStructureItems;
  final bool isDark;
  final AppLocalizations l10n;

  const MaterialsTab({
    super.key,
    required this.materials,
    this.bundles = const <MaterialBundleModel>[],
    this.structureItems = const <CourseStructureModel>[],
    this.materialCountsByWeek = const <int, int>{},
    this.partialFailureMessage,
    this.failedMaterialIds = const <String>[],
    this.onRetryFailedMaterials,
    this.onViewMaterial,
    this.onToggleMaterialVisibility,
    this.onEditMaterial,
    this.onDeleteMaterial,
    this.onToggleBundleVisibility,
    this.onEditBundle,
    this.onDeleteBundle,
    this.structureLoading = false,
    this.structureErrorMessage,
    this.onReloadStructure,
    this.onCreateStructureItem,
    this.onUpdateStructureItem,
    this.onDeleteStructureItem,
    this.onReorderStructureItems,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasStructurePanel =
        structureLoading ||
        structureErrorMessage != null ||
        structureItems.isNotEmpty ||
        onCreateStructureItem != null;
    final sections = _buildSections();

    return Column(
      children: [
        if (hasStructurePanel)
          SizedBox(
            height: structureItems.isEmpty ? 250 : 330,
            child: _buildStructurePanel(),
          ),
        if (partialFailureMessage != null && failedMaterialIds.isNotEmpty)
          _buildPartialFailureBanner(),
        Expanded(
          child: (materials.isEmpty && bundles.isEmpty)
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return _WeekSectionCard(
                      section: section,
                      isDark: isDark,
                      onViewMaterial: onViewMaterial,
                      onToggleMaterialVisibility: onToggleMaterialVisibility,
                      onEditMaterial: onEditMaterial,
                      onDeleteMaterial: onDeleteMaterial,
                      onToggleBundleVisibility: onToggleBundleVisibility,
                      onEditBundle: onEditBundle,
                      onDeleteBundle: onDeleteBundle,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPartialFailureBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CMColors.warning.withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CMColors.warning.withValues(alpha: isDark ? 0.55 : 0.45),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: CMColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                partialFailureMessage!,
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onRetryFailedMaterials != null)
              TextButton(
                onPressed: onRetryFailedMaterials,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructurePanel() {
    if (structureLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CMColors.primary),
        ),
      );
    }

    if (structureErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CMColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CMColors.borderColor(isDark)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: CMColors.error,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load course structure',
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                structureErrorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: CMColors.textSub(isDark), fontSize: 12),
              ),
              if (onReloadStructure != null) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onReloadStructure,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: CMColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: CourseStructureEditor(
        items: structureItems,
        materialCountsByWeek: materialCountsByWeek,
        isDark: isDark,
        onCreate: onCreateStructureItem,
        onUpdate: onUpdateStructureItem,
        onDelete: onDeleteStructureItem,
        onReorder: onReorderStructureItems,
      ),
    );
  }

  List<_WeekSection> _buildSections() {
    final weekMap = <int, _WeekSection>{};

    for (final bundle in bundles) {
      final week = bundle.weekNumber ?? 0;
      final section = weekMap.putIfAbsent(
        week,
        () => _WeekSection(weekNumber: week),
      );
      section.bundles.add(bundle);
    }

    final bundledIds = bundles
        .expand((bundle) => bundle.materials)
        .map((material) => material.materialId)
        .toSet();

    for (final material in materials) {
      if (bundledIds.contains(material.id)) {
        continue;
      }

      final week = _extractWeekNumber(material);
      final section = weekMap.putIfAbsent(
        week,
        () => _WeekSection(weekNumber: week),
      );
      section.materials.add(material);
    }

    final sections = weekMap.values.toList(growable: false)
      ..sort((a, b) {
        if (a.weekNumber == 0 && b.weekNumber != 0) {
          return 1;
        }
        if (b.weekNumber == 0 && a.weekNumber != 0) {
          return -1;
        }
        return a.weekNumber.compareTo(b.weekNumber);
      });

    return sections;
  }

  int _extractWeekNumber(MaterialModel material) {
    final match = RegExp(
      r'week\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(material.title);
    if (match == null) {
      return 0;
    }

    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CMColors.success.withValues(alpha: 0.1),
                  CMColors.success.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: CMColors.success.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No materials yet',
            style: TextStyle(
              color: CMColors.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload files for your students',
            style: TextStyle(color: CMColors.textSub(isDark), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _WeekSection {
  final int weekNumber;
  final List<MaterialBundleModel> bundles = <MaterialBundleModel>[];
  final List<MaterialModel> materials = <MaterialModel>[];

  _WeekSection({required this.weekNumber});
}

class _WeekSectionCard extends StatelessWidget {
  final _WeekSection section;
  final bool isDark;
  final ValueChanged<MaterialModel>? onViewMaterial;
  final ValueChanged<MaterialModel>? onToggleMaterialVisibility;
  final ValueChanged<MaterialModel>? onEditMaterial;
  final ValueChanged<MaterialModel>? onDeleteMaterial;
  final ValueChanged<MaterialBundleModel>? onToggleBundleVisibility;
  final ValueChanged<MaterialBundleModel>? onEditBundle;
  final ValueChanged<MaterialBundleModel>? onDeleteBundle;

  const _WeekSectionCard({
    required this.section,
    required this.isDark,
    this.onViewMaterial,
    this.onToggleMaterialVisibility,
    this.onEditMaterial,
    this.onDeleteMaterial,
    this.onToggleBundleVisibility,
    this.onEditBundle,
    this.onDeleteBundle,
  });

  @override
  Widget build(BuildContext context) {
    final header = section.weekNumber > 0
        ? 'Week ${section.weekNumber}'
        : 'Ungrouped Materials';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Text(
            header,
            style: TextStyle(
              color: CMColors.text(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...section.bundles.map(
          (bundle) => BundleCard(
            bundle: bundle,
            isDark: isDark,
            onViewMaterial: onViewMaterial,
            onToggleVisibility: onToggleBundleVisibility == null
                ? null
                : () => onToggleBundleVisibility!(bundle),
            onEdit: onEditBundle == null ? null : () => onEditBundle!(bundle),
            onDelete: onDeleteBundle == null
                ? null
                : () => onDeleteBundle!(bundle),
          ),
        ),
        ...section.materials.asMap().entries.map((entry) {
          return _MaterialCard(
            material: entry.value,
            isDark: isDark,
            index: entry.key,
            onViewMaterial: onViewMaterial,
            onToggleVisibility: onToggleMaterialVisibility == null
                ? null
                : () => onToggleMaterialVisibility!(entry.value),
            onEdit: onEditMaterial == null
                ? null
                : () => onEditMaterial!(entry.value),
            onDelete: onDeleteMaterial == null
                ? null
                : () => onDeleteMaterial!(entry.value),
          );
        }),
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final bool isDark;
  final int index;
  final ValueChanged<MaterialModel>? onViewMaterial;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MaterialCard({
    required this.material,
    required this.isDark,
    required this.index,
    this.onViewMaterial,
    this.onToggleVisibility,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typeConfig = _getTypeConfig(material.type);
    final thumbnail = _resolveVideoThumbnail(material);

    return Opacity(
      opacity: material.isPublished ? 1 : 0.74,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CMColors.borderColor(isDark), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onViewMaterial?.call(material),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // File type icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: typeConfig.gradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: typeConfig.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: thumbnail == null
                        ? Icon(typeConfig.icon, color: Colors.white, size: 24)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Icon(
                                      typeConfig.icon,
                                      color: Colors.white,
                                      size: 24,
                                    );
                                  },
                                ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  child: const Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.title,
                          style: TextStyle(
                            color: CMColors.text(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: typeConfig.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                material.type.toUpperCase(),
                                style: TextStyle(
                                  color: typeConfig.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (thumbnail != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: CMColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'YOUTUBE',
                                  style: TextStyle(
                                    color: CMColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                            if (material.fileSize.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                material.fileSize,
                                style: TextStyle(
                                  color: CMColors.textMutedColor(isDark),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (!material.isPublished) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: CMColors.warning.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'HIDDEN',
                                  style: TextStyle(
                                    color: CMColors.warning,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        keyName: 'visibility',
                        icon: material.isPublished
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: CMColors.warning,
                        onTap: onToggleVisibility ?? () {},
                      ),
                      const SizedBox(width: 4),
                      _buildIconButton(
                        keyName: 'edit',
                        icon: Icons.edit_outlined,
                        color: CMColors.primary,
                        onTap: onEdit ?? () {},
                      ),
                      const SizedBox(width: 4),
                      _buildIconButton(
                        keyName: 'delete',
                        icon: Icons.delete_outline_rounded,
                        color: CMColors.error,
                        onTap: onDelete ?? () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _resolveVideoThumbnail(MaterialModel material) {
    if (material.type.toLowerCase() != 'video') {
      return null;
    }

    if (material.fileUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(material.fileUrl);
    if (uri == null) {
      return null;
    }

    String? videoId;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        videoId = uri.pathSegments.first;
      }
    } else if (uri.queryParameters.containsKey('v')) {
      videoId = uri.queryParameters['v'];
    } else {
      final match = RegExp(
        r'(?:embed/|shorts/)([A-Za-z0-9_-]{11})',
      ).firstMatch(material.fileUrl);
      videoId = match?.group(1);
    }

    if (videoId == null || videoId.isEmpty) {
      return null;
    }

    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  Widget _buildIconButton({
    required String keyName,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          key: ValueKey<String>('material-action-$keyName'),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  _TypeConfig _getTypeConfig(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return _TypeConfig(
          Icons.picture_as_pdf_rounded,
          CMColors.error,
          const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF87171)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'video':
        return _TypeConfig(
          Icons.play_circle_rounded,
          CMColors.primary,
          CMColors.primaryGradient,
        );
      case 'doc':
      case 'docx':
        return _TypeConfig(
          Icons.description_rounded,
          CMColors.accent,
          CMColors.accentGradient,
        );
      default:
        return _TypeConfig(
          Icons.insert_drive_file_rounded,
          CMColors.teal,
          CMColors.successGradient,
        );
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  _TypeConfig(this.icon, this.color, this.gradient);
}
