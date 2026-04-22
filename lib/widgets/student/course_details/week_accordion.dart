import 'package:flutter/material.dart';

import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import 'bundle_viewer.dart';
import 'material_card.dart';

class WeekAccordion extends StatefulWidget {
  final int weekNumber;
  final String? title;
  final List<CourseMaterialModel> materials;
  final List<MaterialBundleModel> bundles;
  final bool isDark;
  final bool initiallyExpanded;
  final bool isLoading;
  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<CourseMaterialModel>? onMaterialTap;

  const WeekAccordion({
    super.key,
    required this.weekNumber,
    this.title,
    required this.materials,
    required this.bundles,
    required this.isDark,
    this.initiallyExpanded = false,
    this.isLoading = false,
    this.onExpandedChanged,
    this.onMaterialTap,
  });

  @override
  State<WeekAccordion> createState() => _WeekAccordionState();
}

class _WeekAccordionState extends State<WeekAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant WeekAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List<Widget>.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 72,
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1F2937)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E7EB);

    final bundledIds = widget.bundles
        .expand((bundle) => bundle.materials)
        .map((material) => material.materialId)
        .toSet();

    final unbundledMaterials = widget.materials
        .where((material) => !bundledIds.contains(material.materialId))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
              widget.onExpandedChanged?.call(_expanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.calendar_view_week_rounded,
                        color: Color(0xFF1D4ED8),
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
                          widget.title == null || widget.title!.trim().isEmpty
                              ? 'Week ${widget.weekNumber}'
                              : 'Week ${widget.weekNumber} - ${widget.title}',
                          style: TextStyle(
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.materials.length} materials',
                          style: TextStyle(
                            color: widget.isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isDark
                        ? Colors.white70
                        : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: widget.isLoading
                  ? _buildLoadingSkeleton()
                  : Column(
                      children: [
                        for (final bundle in widget.bundles)
                          BundleViewer(bundle: bundle, isDark: widget.isDark),
                        for (final material in unbundledMaterials)
                          MaterialCard(
                            material: material,
                            isDark: widget.isDark,
                            onTap: widget.onMaterialTap == null
                                ? null
                                : () => widget.onMaterialTap!(material),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
