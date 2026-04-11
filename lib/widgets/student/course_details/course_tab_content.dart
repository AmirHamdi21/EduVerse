import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/courses/courses_bloc.dart';
import '../../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import '../../../models/core/course_structure_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../courses/course_model.dart';
import 'document_preview_widget.dart';
import 'video_player_widget.dart';
import 'week_accordion.dart';

class CourseTabContent extends StatefulWidget {
  final int selectedIndex;
  final bool isDark;
  final CourseModel course;

  const CourseTabContent({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.course,
  });

  @override
  State<CourseTabContent> createState() => _CourseTabContentState();
}

class _CourseTabContentState extends State<CourseTabContent> {
  final Set<int> _manuallyExpandedWeeks = <int>{1};
  final Set<int> _loadingWeeks = <int>{};

  Map<int, List<CourseStructureModel>> _groupByWeek(
    List<CourseStructureModel> structures,
  ) {
    final grouped = <int, List<CourseStructureModel>>{};
    for (final item in structures) {
      grouped
          .putIfAbsent(item.weekNumber, () => <CourseStructureModel>[])
          .add(item);
    }
    return grouped;
  }

  void _clearWeekLoading(int weekNumber) {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _loadingWeeks.remove(weekNumber));
      }
    });
  }

  CourseMaterialModel _materialFromStructure(
    CourseStructureModel item,
    Map<String, CourseMaterialModel> materialMap,
  ) {
    if (item.material != null) {
      return item.material!;
    }

    final mapped = item.materialId == null
        ? null
        : materialMap[item.materialId!];
    if (mapped != null) {
      return mapped;
    }

    return CourseMaterialModel(
      materialId: item.materialId ?? item.organizationId,
      courseId: item.courseId,
      materialType: item.organizationType,
      title: item.title,
      description: item.description,
      externalUrl: null,
      orderIndex: item.orderIndex,
      weekNumber: item.weekNumber,
      viewCount: 0,
      downloadCount: 0,
      uploadedBy: null,
      isPublished: true,
      hasBeenViewed: false,
      createdAt: item.createdAt ?? DateTime.now(),
      updatedAt: item.updatedAt,
    );
  }

  dynamic _resolveCourseId(CourseMaterialModel material) {
    final widgetCourseId = widget.course.courseId;
    if (widgetCourseId != null) {
      return widgetCourseId;
    }

    return int.tryParse(material.courseId) ?? material.courseId;
  }

  Future<void> _showMaterialBottomSheet(
    CourseMaterialModel material,
    Widget Function(dynamic courseId) contentBuilder,
  ) async {
    final courseId = _resolveCourseId(material);
    final coursesBloc = context.read<CoursesBloc>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (_) =>
              MaterialViewerBloc(materialService: coursesBloc.materialService),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFFFFFFF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SingleChildScrollView(child: contentBuilder(courseId)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMaterial(CourseMaterialModel material) async {
    final type = material.materialType.toLowerCase();

    if (type == 'video' || type == 'lecture') {
      await _showMaterialBottomSheet(
        material,
        (courseId) => VideoPlayerWidget(courseId: courseId, material: material),
      );
      return;
    }

    if (type == 'document' || type == 'slide') {
      await _showMaterialBottomSheet(
        material,
        (courseId) =>
            DocumentPreviewWidget(courseId: courseId, material: material),
      );
      return;
    }

    await _openExternalMaterial(material);
  }

  Future<void> _openExternalMaterial(CourseMaterialModel material) async {
    final candidates = <String?>[
      material.externalUrl,
      material.youtubeVideoId == null
          ? null
          : 'https://www.youtube.com/watch?v=${material.youtubeVideoId}',
      material.drivePreviewUrl,
      material.file?.webViewLink,
    ];

    final url = candidates.firstWhere(
      (value) => value != null && value.trim().isNotEmpty,
      orElse: () => null,
    );

    if (url == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No preview link available for this material.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This material link is invalid.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this material right now.'),
        ),
      );
    }
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List<Widget>.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          height: 84,
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF2D2D44)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        if (state.isLoadingStructure && state.structure.isEmpty) {
          return _buildLoadingSkeleton();
        }

        if (state.error != null && state.structure.isEmpty) {
          return Column(
            children: [
              Text(
                state.error!.isEmpty
                    ? 'Could not load course structure.'
                    : state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isDark
                      ? Colors.white70
                      : const Color(0xFF4A5565),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  final courseId = widget.course.courseId;
                  if (courseId != null) {
                    context.read<CourseDetailBloc>().add(
                      LoadCourseDetail(courseId: courseId),
                    );
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          );
        }

        if (state.structure.isEmpty) {
          return Text(
            'No course materials are available yet.',
            style: TextStyle(
              color: widget.isDark ? Colors.white60 : const Color(0xFF667085),
              fontSize: 13,
            ),
          );
        }

        final grouped = _groupByWeek(state.structure);
        final weeks = grouped.keys.toList()..sort();
        final materialMap = <String, CourseMaterialModel>{
          for (final material in state.materials) material.materialId: material,
        };

        return Column(
          children: List<Widget>.generate(weeks.length, (index) {
            final weekNumber = weeks[index];
            final weekItems = grouped[weekNumber] ?? <CourseStructureModel>[];
            final materials = weekItems
                .map((item) => _materialFromStructure(item, materialMap))
                .toList();
            final bundles = MaterialBundleModel.detectBundles(
              materials,
            ).values.toList();

            return WeekAccordion(
              weekNumber: weekNumber,
              title: weekItems.isEmpty ? null : weekItems.first.title,
              materials: materials,
              bundles: bundles,
              isDark: widget.isDark,
              initiallyExpanded:
                  index == 0 || _manuallyExpandedWeeks.contains(weekNumber),
              onExpandedChanged: (expanded) {
                setState(() {
                  if (expanded) {
                    _manuallyExpandedWeeks.add(weekNumber);
                    _loadingWeeks.add(weekNumber);
                  } else {
                    _manuallyExpandedWeeks.remove(weekNumber);
                    _loadingWeeks.remove(weekNumber);
                  }
                });

                if (expanded && widget.course.courseId != null) {
                  context.read<CourseDetailBloc>().add(
                    ExpandWeek(weekIndex: weekNumber),
                  );
                  context.read<CourseDetailBloc>().add(
                    LoadMaterials(
                      courseId: widget.course.courseId!,
                      weekNumber: weekNumber,
                    ),
                  );
                  _clearWeekLoading(weekNumber);
                } else {
                  setState(() => _loadingWeeks.remove(weekNumber));
                }
              },
              onMaterialTap: _openMaterial,
              isLoading: _loadingWeeks.contains(weekNumber),
            );
          }),
        );
      },
    );
  }
}
