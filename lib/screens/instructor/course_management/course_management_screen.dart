import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/instructor/instructor_courses_bloc.dart';
import '../../../bloc/instructor/instructor_courses_event.dart';
import '../../../bloc/instructor/instructor_courses_state.dart';
import '../../../bloc/materials/materials_bloc.dart';
import '../../../bloc/materials/materials_event.dart';
import '../../../bloc/materials/materials_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../widgets/instructor/course_management/course_management_barrel.dart';

class CourseManagementScreen extends StatefulWidget {
  final InstructorCourseModel? course;
  final int? courseId;

  const CourseManagementScreen({super.key, this.course, this.courseId});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late InstructorCourseModel _course;
  int? _resolvedCourseId;
  int? _requestedStudentsSectionId;
  int? _requestedMetricsCourseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _course =
        widget.course ??
        InstructorCourseModel(
          id: (widget.courseId ?? 0).toString(),
          code: 'COURSE',
          name: 'Course',
          totalStudents: 0,
          colorValue: 0xFF155CFB,
        );
    _resolvedCourseId = widget.courseId ?? int.tryParse(_course.id);

    if (_resolvedCourseId != null && _resolvedCourseId! > 0) {
      context.read<InstructorCoursesBloc>().add(
        SelectCourse(_resolvedCourseId!),
      );
      context.read<MaterialsBloc>().add(LoadMaterials(_resolvedCourseId!));
      context.read<InstructorCoursesBloc>().add(
        LoadDeadlines(_resolvedCourseId!),
      );
    }

    final current = context.read<InstructorCoursesBloc>().state;
    if (current is InstructorCoursesLoaded) {
      _requestCourseDetailLoads(current);
      return;
    }

    context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final instructorState = context.watch<InstructorCoursesBloc>().state;
        final materialsState = context.watch<MaterialsBloc>().state;

        final teachingCourse = _resolveTeachingCourse(instructorState);
        final deadlines = _resolveDeadlines(instructorState);
        final students = _resolveStudents(instructorState);
        final engagementMetrics = _resolveEngagementMetrics(instructorState);
        final materials = _resolveMaterials(materialsState);
        final displayCourse = _buildDisplayCourse(
          teachingCourse,
          materials,
          deadlines,
          students,
        );

        if (instructorState is InstructorCoursesLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _requestCourseDetailLoads(instructorState);
          });
        }

        return Scaffold(
          backgroundColor: CMColors.bg(isDark),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              CourseManagementAppBar(
                courseName: displayCourse.name,
                courseCode: displayCourse.code,
                isDark: isDark,
                onSettings: () => _showCourseSettings(context, isDark),
              ),
              SliverToBoxAdapter(
                child: CourseManagementHeader(
                  course: displayCourse,
                  isDark: isDark,
                  l10n: l10n,
                  tabController: _tabController,
                  studentsCount: students.isNotEmpty
                      ? students.length
                      : (teachingCourse?.enrolledCount ??
                            displayCourse.totalStudents),
                  assignmentsCount: deadlines
                      .where((item) => item.type == DeadlineType.assignment)
                      .length,
                  materialsCount: materials.length,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(
                  course: displayCourse,
                  isDark: isDark,
                  l10n: l10n,
                  courseId: _resolvedCourseId,
                  deadlines: deadlines,
                  studentsCount: students.isNotEmpty
                      ? students.length
                      : (teachingCourse?.enrolledCount ??
                            displayCourse.totalStudents),
                  averageGrade: teachingCourse?.averageGrade,
                  engagementMetrics: engagementMetrics,
                  schedules: teachingCourse?.section.schedules ?? const [],
                ),
                MaterialsTab(
                  materials: materials.isNotEmpty
                      ? materials.map(_mapCourseMaterialToLegacy).toList()
                      : displayCourse.materials,
                  isDark: isDark,
                  l10n: l10n,
                ),
                AssignmentsTab(isDark: isDark, l10n: l10n),
                GradingTab(isDark: isDark, l10n: l10n),
                StudentsTab(students: students, isDark: isDark, l10n: l10n),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(isDark, l10n),
        );
      },
    );
  }

  TeachingCourseModel? _resolveTeachingCourse(InstructorCoursesState state) {
    final courseId = _resolvedCourseId;
    if (courseId == null ||
        courseId <= 0 ||
        state is! InstructorCoursesLoaded) {
      return null;
    }

    for (final course in state.courses) {
      if (course.courseId == courseId) {
        return course;
      }
    }

    return null;
  }

  List<DeadlineCardModel> _resolveDeadlines(InstructorCoursesState state) {
    if (state is InstructorCoursesLoaded) {
      return state.deadlines;
    }
    if (state is DeadlinesLoaded) {
      return state.deadlines;
    }
    return const <DeadlineCardModel>[];
  }

  List<SectionStudentModel> _resolveStudents(InstructorCoursesState state) {
    if (state is InstructorCoursesLoaded) {
      return state.sectionStudents;
    }
    return const <SectionStudentModel>[];
  }

  EngagementMetricsModel? _resolveEngagementMetrics(
    InstructorCoursesState state,
  ) {
    if (state is InstructorCoursesLoaded) {
      return state.engagementMetrics;
    }
    return null;
  }

  List<CourseMaterialModel> _resolveMaterials(MaterialsState state) {
    if (state is MaterialsLoaded && state.courseId == _resolvedCourseId) {
      return state.materials;
    }
    return const <CourseMaterialModel>[];
  }

  InstructorCourseModel _buildDisplayCourse(
    TeachingCourseModel? teachingCourse,
    List<CourseMaterialModel> materials,
    List<DeadlineCardModel> deadlines,
    List<SectionStudentModel> students,
  ) {
    if (teachingCourse == null) {
      return _course;
    }

    return _course.copyWith(
      id: teachingCourse.courseId.toString(),
      code: teachingCourse.course.courseCode,
      name: teachingCourse.course.courseName,
      description: teachingCourse.course.description ?? '',
      totalStudents: students.isNotEmpty
          ? students.length
          : (teachingCourse.enrolledCount > 0
                ? teachingCourse.enrolledCount
                : teachingCourse.section.currentEnrollment),
      semester: teachingCourse.semester.name,
      materials: materials.map(_mapCourseMaterialToLegacy).toList(),
      assignments: List<AssignmentModel>.generate(
        deadlines.where((item) => item.type == DeadlineType.assignment).length,
        (index) => AssignmentModel(
          id: 'assignment-$index',
          title: 'Assignment',
          dueDate: DateTime.now(),
          totalPoints: 100,
          submissionsCount: 0,
          gradedCount: 0,
        ),
      ),
    );
  }

  void _requestCourseDetailLoads(InstructorCoursesLoaded state) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    final teachingCourse = _resolveTeachingCourse(state);
    if (teachingCourse == null) {
      return;
    }

    if (_requestedStudentsSectionId != teachingCourse.sectionId) {
      _requestedStudentsSectionId = teachingCourse.sectionId;
      context.read<InstructorCoursesBloc>().add(
        LoadSectionStudents(teachingCourse.sectionId),
      );
    }

    if (_requestedMetricsCourseId != courseId) {
      _requestedMetricsCourseId = courseId;
      final enrolledCount = teachingCourse.enrolledCount > 0
          ? teachingCourse.enrolledCount
          : teachingCourse.section.currentEnrollment;

      context.read<InstructorCoursesBloc>().add(
        LoadEngagementMetrics(
          courseId: courseId,
          totalEnrolledStudents: enrolledCount,
        ),
      );
    }
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddOptions(context, isDark, l10n),
      backgroundColor: CMColors.primary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        l10n.add,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCourseSettings(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: CMColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.edit_outlined,
              l10n.editCourse,
              CMColors.primary,
              isDark,
            ),
            _buildSheetItem(
              ctx,
              Icons.archive_outlined,
              l10n.archiveCourse,
              CMColors.warning,
              isDark,
            ),
            _buildSheetItem(
              ctx,
              Icons.delete_outline,
              l10n.delete,
              CMColors.error,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: CMColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.assignment_add,
              l10n.createAssignment,
              CMColors.primary,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.assignmentCreated),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: CMColors.primary,
                  ),
                );
              },
            ),
            _buildSheetItem(
              ctx,
              Icons.upload_file_rounded,
              l10n.uploadMaterial,
              CMColors.success,
              isDark,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.materialUploaded),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: CMColors.success,
                  ),
                );
              },
            ),
            _buildSheetItem(
              ctx,
              Icons.campaign_rounded,
              l10n.postAnnouncement,
              CMColors.warning,
              isDark,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: CMColors.text(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap ?? () => Navigator.pop(ctx),
    );
  }

  MaterialModel _mapCourseMaterialToLegacy(CourseMaterialModel material) {
    return MaterialModel(
      id: material.materialId,
      title: material.title,
      type: material.materialType,
      fileSize: _formatBytes(material.file?.fileSize),
      fileUrl: material.url ?? material.externalUrl ?? '',
      uploadedAt: material.createdAt,
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
}
