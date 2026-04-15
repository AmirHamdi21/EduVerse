import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/courses/courses_bloc.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import '../../../models/core/enrollment_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../../../widgets/student/course_details/course_tab_content.dart';
import '../../../widgets/student/course_details/document_preview_widget.dart';
import '../../../widgets/student/course_details/video_player_widget.dart';
import '../../../widgets/student/course_details/week_accordion.dart';
import '../../../widgets/student/courses/course_model.dart';
import '../../../widgets/student/progress/progress_indicator.dart';
import '../bloc/course_detail/course_detail_bloc.dart';
import '../bloc/course_detail/course_detail_event.dart';
import '../bloc/course_detail/course_detail_state.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseEnrollmentModel enrollment;
  final int initialTabIndex;

  const CourseDetailScreen({
    super.key,
    required this.enrollment,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final coursesBloc = context.read<CoursesBloc>();
    final courseId =
        enrollment.course?.courseId ?? int.tryParse(enrollment.courseId);
    final legacyCourse = _legacyCourse();

    return BlocProvider(
      create: (_) =>
          CourseDetailBloc(
            courseService: coursesBloc.courseService,
            materialService: coursesBloc.materialService,
          )..add(
            LoadCourseDetail(
              courseId: courseId,
              initialTabIndex: initialTabIndex,
            ),
          ),
      child: DefaultTabController(
        length: 3,
        initialIndex: initialTabIndex,
        child: Scaffold(
          appBar: AppBar(
            title: Text(enrollment.course?.courseName ?? 'Course Details'),
            bottom: const TabBar(
              tabs: <Tab>[
                Tab(text: 'Structure'),
                Tab(text: 'Materials'),
                Tab(text: 'Progress'),
              ],
            ),
          ),
          body: BlocBuilder<CourseDetailBloc, CourseDetailState>(
            builder: (context, state) {
              return TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: CourseTabContent(
                      selectedIndex: 0,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      course: legacyCourse,
                    ),
                  ),
                  _MaterialsTab(
                    state: state,
                    courseId: courseId,
                    coursesBloc: coursesBloc,
                  ),
                  _ProgressTab(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  CourseModel _legacyCourse() {
    return CourseModel(
      courseId: enrollment.course?.courseId,
      title: enrollment.course?.courseName ?? 'Course',
      instructor: enrollment.course?.departmentName ?? 'Instructor',
      progress: 0.0,
      nextEvent: '',
      eventDate: '',
      iconBackgroundColor: const Color(0xFF155DFC),
      courseIcon: Icons.school_outlined,
    );
  }
}

class _MaterialsTab extends StatefulWidget {
  final CourseDetailState state;
  final dynamic courseId;
  final CoursesBloc coursesBloc;

  const _MaterialsTab({
    required this.state,
    required this.courseId,
    required this.coursesBloc,
  });

  @override
  State<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<_MaterialsTab> {
  Map<int, List<CourseMaterialModel>> _groupByWeek(
    List<CourseMaterialModel> materials,
  ) {
    final grouped = <int, List<CourseMaterialModel>>{};
    for (final material in materials) {
      grouped
          .putIfAbsent(material.weekNumber ?? 0, () => <CourseMaterialModel>[])
          .add(material);
    }
    return grouped;
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

  Future<void> _showMaterialBottomSheet(
    CourseMaterialModel material,
    Widget Function(dynamic courseId) contentBuilder,
  ) async {
    final resolvedCourseId = widget.courseId ?? material.courseId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (_) => MaterialViewerBloc(
            materialService: widget.coursesBloc.materialService,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFFFFFFF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SingleChildScrollView(
                child: contentBuilder(resolvedCourseId),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openExternalMaterial(CourseMaterialModel material) async {
    final url = material.externalUrl;
    if (url == null || url.isEmpty) {
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

    // External URL materials are shown directly without bottom sheet
    final type = material.materialType.toLowerCase();
    if (type == 'video' || type == 'lecture') {
      await _showMaterialBottomSheet(
        material,
        (courseId) => VideoPlayerWidget(courseId: courseId, material: material),
      );
    } else if (type == 'document' || type == 'slide') {
      await _showMaterialBottomSheet(
        material,
        (courseId) =>
            DocumentPreviewWidget(courseId: courseId, material: material),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.state.isLoadingMaterials && widget.state.materials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.state.materials.isEmpty) {
      return const Center(child: Text('No materials available'));
    }

    final grouped = _groupByWeek(widget.state.materials);
    final weeks = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekNumber = weeks[index];
        final materials = grouped[weekNumber] ?? const <CourseMaterialModel>[];
        final bundles = MaterialBundleModel.detectBundles(
          materials,
        ).values.toList();

        return WeekAccordion(
          weekNumber: weekNumber,
          materials: materials,
          bundles: bundles,
          isDark: isDark,
          initiallyExpanded: index == 0,
          onMaterialTap: (material) => _openMaterial(material),
        );
      },
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final CourseDetailState state;

  const _ProgressTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.materials.length;
    final viewed = state.materials.where((m) => m.hasBeenViewed).length;

    if (total == 0) {
      return const Center(child: Text('No materials available yet.'));
    }

    final Map<int, int> totalByWeek = <int, int>{};
    final Map<int, int> viewedByWeek = <int, int>{};

    for (final material in state.materials) {
      final week = material.weekNumber ?? 0;
      totalByWeek[week] = (totalByWeek[week] ?? 0) + 1;
      if (material.hasBeenViewed) {
        viewedByWeek[week] = (viewedByWeek[week] ?? 0) + 1;
      }
    }

    final weeks = totalByWeek.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CourseProgressIndicator(totalMaterials: total, viewedMaterials: viewed),
        const SizedBox(height: 20),
        Text(
          'Weekly Breakdown',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...weeks.map((week) {
          final weekTotal = totalByWeek[week] ?? 0;
          final weekViewed = viewedByWeek[week] ?? 0;
          final weekProgress = weekTotal == 0 ? 0.0 : weekViewed / weekTotal;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    week > 0 ? 'Week $week' : 'Unscheduled',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text('Viewed $weekViewed of $weekTotal'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: weekProgress),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
