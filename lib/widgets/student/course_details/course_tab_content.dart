import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/core/course_structure_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../../../screens/instructor/materials/material_preview_screen.dart';
import '../../../screens/instructor/video/instructor_video_player_screen.dart';
import '../courses/course_model.dart';
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
      materialId: item.materialId ?? item.organizationId.toString(),
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

  Future<void> _openMaterial(CourseMaterialModel material) async {
    final type = material.materialType.toLowerCase().trim();

    if (type == 'video') {
      final videoId = material.youtubeVideoId;
      if (videoId == null || videoId.isEmpty) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No video ID available for this material.'),
          ),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InstructorVideoPlayerScreen(
            videoId: videoId,
            courseName: widget.course.title,
            videoTitle: material.title,
          ),
        ),
      );
      return;
    }

    final materialModel = _toMaterialModel(material);
    if (materialModel.fileUrl.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MaterialPreviewScreen(material: materialModel),
        ),
      );
      return;
    }

    await _openExternalMaterial(material);
  }

  MaterialModel _toMaterialModel(CourseMaterialModel courseMaterial) {
    String fileUrl = '';
    final driveFile = courseMaterial.file;

    if (driveFile != null) {
      fileUrl =
          driveFile.webViewLink ??
          driveFile.iframeUrl ??
          driveFile.downloadUrl ??
          '';
    }

    if (fileUrl.isEmpty && courseMaterial.externalUrl?.isNotEmpty == true) {
      fileUrl = courseMaterial.externalUrl!;
    }

    if (fileUrl.isEmpty && courseMaterial.url?.isNotEmpty == true) {
      fileUrl = courseMaterial.url!;
    }

    return MaterialModel(
      id: courseMaterial.materialId,
      title: courseMaterial.title,
      type: courseMaterial.materialType,
      fileSize: _formatBytes(courseMaterial.file?.fileSize),
      fileUrl: fileUrl,
      isPublished: courseMaterial.isPublished,
      uploadedAt: courseMaterial.createdAt,
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) {
      return '';
    }
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  Map<int, List<CourseMaterialModel>> _groupMaterialsByWeek(
    List<CourseMaterialModel> materials,
  ) {
    final grouped = <int, List<CourseMaterialModel>>{};
    for (final material in materials) {
      final weekNumber = material.weekNumber ?? 0;
      grouped
          .putIfAbsent(weekNumber, () => <CourseMaterialModel>[])
          .add(material);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final orderCompare = (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
        if (orderCompare != 0) {
          return orderCompare;
        }

        return a.createdAt.compareTo(b.createdAt);
      });
    }

    return grouped;
  }

  List<CourseMaterialModel> _flattenStructureMappedMaterials(
    List<CourseStructureModel> structure,
    Map<String, CourseMaterialModel> materialMap,
  ) {
    return structure
        .map((item) => _materialFromStructure(item, materialMap))
        .toList(growable: false);
  }

  List<CourseMaterialModel> _materialsNotInStructure({
    required List<CourseMaterialModel> allMaterials,
    required List<CourseMaterialModel> structureMaterials,
  }) {
    if (allMaterials.isEmpty) {
      return const <CourseMaterialModel>[];
    }

    final inStructureIds = structureMaterials
        .map((item) => item.materialId)
        .toSet();

    return allMaterials
        .where((item) => !inStructureIds.contains(item.materialId))
        .toList(growable: false);
  }

  Widget _buildWeeksFromMaterials(List<CourseMaterialModel> materials) {
    if (materials.isEmpty) {
      return Text(
        'No course materials are available yet.',
        style: TextStyle(
          color: widget.isDark ? Colors.white60 : const Color(0xFF667085),
          fontSize: 13,
        ),
      );
    }

    final grouped = _groupMaterialsByWeek(materials);
    final weeks = grouped.keys.toList()..sort();

    return Column(
      children: List<Widget>.generate(weeks.length, (index) {
        final weekNumber = weeks[index];
        final weekMaterials = grouped[weekNumber] ?? <CourseMaterialModel>[];
        final bundles = MaterialBundleModel.detectBundles(
          weekMaterials,
        ).values.toList();

        return WeekAccordion(
          weekNumber: weekNumber,
          title: null,
          materials: weekMaterials,
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
        if (state.isLoadingStructure &&
            state.structure.isEmpty &&
            state.materials.isEmpty) {
          return _buildLoadingSkeleton();
        }

        if (state.error != null &&
            state.structure.isEmpty &&
            state.materials.isEmpty) {
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

        final materialMap = <String, CourseMaterialModel>{
          for (final material in state.materials) material.materialId: material,
        };

        if (state.structure.isEmpty) {
          return _buildWeeksFromMaterials(state.materials);
        }

        final grouped = _groupByWeek(state.structure);
        final weeks = grouped.keys.toList()..sort();

        final structureMaterials = _flattenStructureMappedMaterials(
          state.structure,
          materialMap,
        );
        final unmatchedMaterials = _materialsNotInStructure(
          allMaterials: state.materials,
          structureMaterials: structureMaterials,
        );
        final unmatchedByWeek = _groupMaterialsByWeek(unmatchedMaterials);
        final allWeekNumbers = <int>{...weeks, ...unmatchedByWeek.keys}.toList()
          ..sort();

        return Column(
          children: List<Widget>.generate(allWeekNumbers.length, (index) {
            final weekNumber = allWeekNumbers[index];
            final weekItems =
                grouped[weekNumber] ?? const <CourseStructureModel>[];

            final structureMappedMaterials = weekItems
                .map((item) => _materialFromStructure(item, materialMap))
                .toList();

            final extraMaterials =
                unmatchedByWeek[weekNumber] ?? const <CourseMaterialModel>[];

            final seenIds = structureMappedMaterials
                .map((item) => item.materialId)
                .toSet();

            final materials =
                <CourseMaterialModel>[
                  ...structureMappedMaterials,
                  ...extraMaterials.where(
                    (item) => !seenIds.contains(item.materialId),
                  ),
                ]..sort((a, b) {
                  final orderCompare = (a.orderIndex ?? 0).compareTo(
                    b.orderIndex ?? 0,
                  );
                  if (orderCompare != 0) {
                    return orderCompare;
                  }

                  return a.createdAt.compareTo(b.createdAt);
                });

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
