import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';

class MaterialsTab extends StatelessWidget {
  const MaterialsTab({
    super.key,
    this.materials = const <MaterialModel>[],
    this.courseMaterials = const <CourseMaterialModel>[],
    this.bundles = const <MaterialBundleModel>[],
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
    required this.isDark,
    required this.l10n,
  });

  final List<MaterialModel> materials;
  final List<CourseMaterialModel> courseMaterials;
  final List<MaterialBundleModel> bundles;
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
  final bool isDark;
  final AppLocalizations l10n;

  List<CourseMaterialModel> get _resolvedMaterials {
    if (courseMaterials.isNotEmpty) {
      return courseMaterials;
    }

    return materials
        .map(
          (material) => CourseMaterialModel(
            materialId: material.id,
            courseId: '0',
            materialType: material.type,
            title: material.title,
            description: null,
            externalUrl: material.fileUrl,
            url: material.fileUrl,
            orderIndex: 0,
            weekNumber: _extractWeekNumber(material.title),
            viewCount: 0,
            downloadCount: 0,
            uploadedBy: null,
            isPublished: material.isPublished,
            hasBeenViewed: false,
            createdAt: material.uploadedAt ?? DateTime.now(),
            updatedAt: material.uploadedAt,
          ),
        )
        .toList(growable: false);
  }

  static int? _extractWeekNumber(String title) {
    final match = RegExp(
      r'week\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(title);
    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <int, List<CourseMaterialModel>>{};
    for (final material in _resolvedMaterials) {
      final weekNumber = material.weekNumber ?? 0;
      grouped.putIfAbsent(weekNumber, () => <CourseMaterialModel>[]).add(material);
    }

    final weeks = grouped.keys.toList(growable: false)
      ..sort((a, b) {
        if (a == 0 && b != 0) {
          return 1;
        }
        if (b == 0 && a != 0) {
          return -1;
        }
        return a.compareTo(b);
      });

    return Column(
      children: [
        if (partialFailureMessage != null && failedMaterialIds.isNotEmpty)
          _PartialFailureBanner(
            isDark: isDark,
            message: partialFailureMessage!,
            retryLabel: l10n.retry,
            onRetry: onRetryFailedMaterials,
          ),
        Expanded(
          child: weeks.isEmpty
              ? _EmptyState(isDark: isDark, l10n: l10n)
              : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: weeks.length,
                  itemBuilder: (context, index) {
                    final weekNumber = weeks[index];
                    return _WeekAccordionCard(
                      key: ValueKey<String>('instructor-week-$weekNumber'),
                      weekNumber: weekNumber,
                      materials: grouped[weekNumber] ?? const <CourseMaterialModel>[],
                      isDark: isDark,
                      l10n: l10n,
                      initiallyExpanded: index == 0,
                      onViewMaterial: onViewMaterial,
                      onToggleMaterialVisibility: onToggleMaterialVisibility,
                      onEditMaterial: onEditMaterial,
                      onDeleteMaterial: onDeleteMaterial,
                      legacyMaterials: materials,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PartialFailureBanner extends StatelessWidget {
  const _PartialFailureBanner({
    required this.isDark,
    required this.message,
    required this.retryLabel,
    this.onRetry,
  });

  final bool isDark;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.42 : 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark, required this.l10n});

  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF172033) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 42,
                color: isDark ? Colors.white70 : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No materials yet',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noMaterialsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekAccordionCard extends StatefulWidget {
  const _WeekAccordionCard({
    super.key,
    required this.weekNumber,
    required this.materials,
    required this.isDark,
    required this.l10n,
    required this.legacyMaterials,
    this.initiallyExpanded = false,
    this.onViewMaterial,
    this.onToggleMaterialVisibility,
    this.onEditMaterial,
    this.onDeleteMaterial,
  });

  final int weekNumber;
  final List<CourseMaterialModel> materials;
  final bool isDark;
  final AppLocalizations l10n;
  final bool initiallyExpanded;
  final List<MaterialModel> legacyMaterials;
  final ValueChanged<MaterialModel>? onViewMaterial;
  final ValueChanged<MaterialModel>? onToggleMaterialVisibility;
  final ValueChanged<MaterialModel>? onEditMaterial;
  final ValueChanged<MaterialModel>? onDeleteMaterial;

  @override
  State<_WeekAccordionCard> createState() => _WeekAccordionCardState();
}

class _WeekAccordionCardState extends State<_WeekAccordionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant _WeekAccordionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE2E8F0);

    final weekLabel = widget.weekNumber > 0
        ? 'Week ${widget.weekNumber}'
        : 'Ungrouped materials';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.calendar_view_week_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekLabel,
                          style: TextStyle(
                            color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.materials.length} materials',
                          style: TextStyle(
                            color: widget.isDark ? Colors.white60 : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: widget.materials
                    .map(
                      (material) => _InstructorMaterialCard(
                        material: material,
                        isDark: widget.isDark,
                        l10n: widget.l10n,
                        legacyMaterial: _resolveLegacyMaterial(
                          material,
                          widget.legacyMaterials,
                        ),
                        onViewMaterial: widget.onViewMaterial,
                        onToggleMaterialVisibility: widget.onToggleMaterialVisibility,
                        onEditMaterial: widget.onEditMaterial,
                        onDeleteMaterial: widget.onDeleteMaterial,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }

  MaterialModel _resolveLegacyMaterial(
    CourseMaterialModel material,
    List<MaterialModel> legacyMaterials,
  ) {
    for (final legacyMaterial in legacyMaterials) {
      if (legacyMaterial.id == material.materialId) {
        return legacyMaterial;
      }
    }

    final fileUrl =
        material.file?.webViewLink ??
        material.file?.iframeUrl ??
        material.file?.downloadUrl ??
        material.externalUrl ??
        material.url ??
        '';

    return MaterialModel(
      id: material.materialId,
      title: material.title,
      type: material.materialType,
      fileSize: '',
      fileUrl: fileUrl,
      isPublished: material.isPublished,
      uploadedAt: material.createdAt,
    );
  }
}

class _InstructorMaterialCard extends StatelessWidget {
  const _InstructorMaterialCard({
    required this.material,
    required this.isDark,
    required this.l10n,
    required this.legacyMaterial,
    this.onViewMaterial,
    this.onToggleMaterialVisibility,
    this.onEditMaterial,
    this.onDeleteMaterial,
  });

  final CourseMaterialModel material;
  final bool isDark;
  final AppLocalizations l10n;
  final MaterialModel legacyMaterial;
  final ValueChanged<MaterialModel>? onViewMaterial;
  final ValueChanged<MaterialModel>? onToggleMaterialVisibility;
  final ValueChanged<MaterialModel>? onEditMaterial;
  final ValueChanged<MaterialModel>? onDeleteMaterial;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF101828);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF667085);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewMaterial == null ? null : () => onViewMaterial!(legacyMaterial),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(type: material.materialType, isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              material.title,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<_MaterialAction>(
                            tooltip: '',
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            color: isDark ? const Color(0xFF111827) : Colors.white,
                            onSelected: (action) {
                              switch (action) {
                                case _MaterialAction.toggleVisibility:
                                  onToggleMaterialVisibility?.call(legacyMaterial);
                                  break;
                                case _MaterialAction.edit:
                                  onEditMaterial?.call(legacyMaterial);
                                  break;
                                case _MaterialAction.delete:
                                  onDeleteMaterial?.call(legacyMaterial);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<_MaterialAction>(
                                value: _MaterialAction.toggleVisibility,
                                child: Row(
                                  children: [
                                    Icon(
                                      material.isPublished
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      material.isPublished ? 'Hide' : l10n.show,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<_MaterialAction>(
                                value: _MaterialAction.edit,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10n.edit),
                                  ],
                                ),
                              ),
                              PopupMenuItem<_MaterialAction>(
                                value: _MaterialAction.delete,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10n.delete),
                                  ],
                                ),
                              ),
                            ],
                            child: Icon(
                              Icons.more_horiz_rounded,
                              color: subtitleColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      if (material.description != null && material.description!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            material.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _StatChip(
                            label: '${l10n.views} ${material.viewCount ?? 0}',
                            icon: Icons.visibility_outlined,
                            isDark: isDark,
                          ),
                          _StatChip(
                            label: '${l10n.download} ${material.downloadCount ?? 0}',
                            icon: Icons.download_outlined,
                            isDark: isDark,
                          ),
                          _StatusChip(
                            isPublished: material.isPublished,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (material.thumbnailUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        material.thumbnailUrl!,
                        width: 72,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _MaterialAction { toggleVisibility, edit, delete }

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.isDark});

  final String type;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final upper = type.toUpperCase();
    final color = _resolveColor(upper);

    return Container(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          upper,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _resolveColor(String type) {
    switch (type) {
      case 'VIDEO':
        return const Color(0xFFE11D48);
      case 'DOCUMENT':
      case 'PDF':
      case 'DOC':
      case 'DOCX':
        return const Color(0xFF0369A1);
      case 'LINK':
        return const Color(0xFF7C3AED);
      case 'TEXT':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF475569);
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isPublished, required this.isDark});

  final bool isPublished;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isPublished ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPublished ? 'Published' : 'Hidden',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
