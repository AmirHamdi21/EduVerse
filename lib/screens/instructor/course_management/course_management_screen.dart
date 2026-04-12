import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/course_structure/course_structure_bloc.dart';
import '../../../bloc/course_structure/course_structure_event.dart';
import '../../../bloc/course_structure/course_structure_state.dart';
import '../../../bloc/instructor/instructor_courses_bloc.dart';
import '../../../bloc/instructor/instructor_courses_event.dart';
import '../../../bloc/instructor/instructor_courses_state.dart';
import '../../../bloc/materials/materials_bloc.dart';
import '../../../bloc/materials/materials_event.dart';
import '../../../bloc/materials/materials_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/course_structure_model.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/course_management/course_management_barrel.dart';

class CourseManagementScreen extends StatefulWidget {
  final InstructorCourseModel? course;
  final int? courseId;
  final StorageService? storageService;

  const CourseManagementScreen({
    super.key,
    this.course,
    this.courseId,
    this.storageService,
  });

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  late final StorageService _storageService;

  late TabController _tabController;
  late InstructorCourseModel _course;
  int? _resolvedCourseId;
  int? _requestedStudentsSectionId;
  int? _requestedMetricsCourseId;
  String? _materialsFailureMessage;
  List<String> _failedMaterialIds = const <String>[];
  bool _retryingFailedMaterials = false;
  bool _hasCourseAccess = true;
  bool _canDeleteCourse = true;
  bool _canManageCourseStructure = true;

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _tabController = TabController(length: 5, vsync: this);
    _resolveRoleAccess();
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
      context.read<CourseStructureBloc>().add(
        LoadStructure(_resolvedCourseId!),
      );
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
  void didUpdateWidget(covariant CourseManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.course != null && widget.course!.id != _course.id) {
      _course = widget.course!;
    }

    final incomingCourseId =
        widget.courseId ?? int.tryParse(widget.course?.id ?? '');
    if (incomingCourseId == _resolvedCourseId) {
      return;
    }

    _resolvedCourseId = incomingCourseId;
    _requestedStudentsSectionId = null;
    _requestedMetricsCourseId = null;

    if (_resolvedCourseId == null || _resolvedCourseId! <= 0) {
      return;
    }

    context.read<InstructorCoursesBloc>().add(SelectCourse(_resolvedCourseId!));
    context.read<MaterialsBloc>().add(LoadMaterials(_resolvedCourseId!));
    context.read<CourseStructureBloc>().add(LoadStructure(_resolvedCourseId!));
    context.read<InstructorCoursesBloc>().add(
      LoadDeadlines(_resolvedCourseId!),
    );
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await _storageService.getUserData();
      final roleNames =
          user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (roleNames.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _hasCourseAccess = true;
          _canDeleteCourse = true;
          _canManageCourseStructure = true;
        });
        return;
      }

      final hasInstructorAccess = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'ta' ||
            role == 'teaching_assistant' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      final canDeleteCourse = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasCourseAccess = hasInstructorAccess;
        _canDeleteCourse = canDeleteCourse;
        _canManageCourseStructure = canDeleteCourse;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasCourseAccess = true;
        _canDeleteCourse = true;
        _canManageCourseStructure = true;
      });
    }
  }

  void _showDeletePermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Access denied: TAs cannot delete courses or course structure.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAccessDeniedState(bool isDark, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: CMColors.bg(isDark),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: CMColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Access Denied',
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You do not have permission to access course management.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CMColors.textSub(isDark)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
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

        if (!_hasCourseAccess) {
          return _buildAccessDeniedState(isDark, l10n);
        }

        final instructorState = context.watch<InstructorCoursesBloc>().state;
        final materialsState = context.watch<MaterialsBloc>().state;
        final structureState = context.watch<CourseStructureBloc>().state;

        final teachingCourse = _resolveTeachingCourse(instructorState);
        final deadlines = _resolveDeadlines(instructorState);
        final students = _resolveStudents(instructorState);
        final engagementMetrics = _resolveEngagementMetrics(instructorState);
        final materials = _resolveMaterials(materialsState);
        final bundles = _resolveBundles(materialsState);
        final structureItems = _resolveStructureItems(structureState);
        final structureLoading = _isStructureLoading(structureState);
        final structureErrorMessage = _resolveStructureError(structureState);
        final materialCountsByWeek = _buildMaterialCountsByWeek(materials);
        final studentsCount = _resolveStudentsCount(teachingCourse, students);
        final hasValidSection = _hasValidSection(teachingCourse);
        final displayCourse = _buildDisplayCourse(
          teachingCourse,
          materials,
          deadlines,
          students,
        );

        return MultiBlocListener(
          listeners: [
            BlocListener<InstructorCoursesBloc, InstructorCoursesState>(
              listener: (context, state) {
                if (state is InstructorCoursesLoaded) {
                  _requestCourseDetailLoads(state);
                }
              },
            ),
            BlocListener<MaterialsBloc, MaterialsState>(
              listener: _onMaterialsStateChanged,
            ),
          ],
          child: Scaffold(
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
                    studentsCount: studentsCount,
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
                    studentsCount: studentsCount,
                    averageGrade: teachingCourse?.averageGrade,
                    engagementMetrics: engagementMetrics,
                    schedules: teachingCourse?.section.schedules ?? const [],
                  ),
                  MaterialsTab(
                    materials: materials.isNotEmpty
                        ? materials.map(_mapCourseMaterialToLegacy).toList()
                        : displayCourse.materials,
                    bundles: bundles,
                    structureItems: structureItems,
                    materialCountsByWeek: materialCountsByWeek,
                    partialFailureMessage: _materialsFailureMessage,
                    failedMaterialIds: _failedMaterialIds,
                    onRetryFailedMaterials: _retryFailedMaterials,
                    onToggleMaterialVisibility: _toggleMaterialVisibility,
                    onEditMaterial: _editMaterial,
                    onDeleteMaterial: _deleteMaterial,
                    onToggleBundleVisibility: _toggleBundleVisibility,
                    onEditBundle: _editBundle,
                    onDeleteBundle: _deleteBundle,
                    onViewMaterial: _handleViewMaterial,
                    structureLoading: structureLoading,
                    structureErrorMessage: structureErrorMessage,
                    onReloadStructure: _reloadStructure,
                    onCreateStructureItem: _canManageCourseStructure
                        ? _createStructureItem
                        : null,
                    onUpdateStructureItem: _canManageCourseStructure
                        ? _updateStructureItem
                        : null,
                    onDeleteStructureItem: _canManageCourseStructure
                        ? _deleteStructureItem
                        : null,
                    onReorderStructureItems: _canManageCourseStructure
                        ? _reorderStructureItems
                        : null,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                  AssignmentsTab(isDark: isDark, l10n: l10n),
                  GradingTab(isDark: isDark, l10n: l10n),
                  StudentsTab(
                    students: students,
                    isDark: isDark,
                    l10n: l10n,
                    emptyStateTitleOverride: hasValidSection
                        ? null
                        : 'No section assigned',
                    emptyStateSubtitleOverride: hasValidSection
                        ? null
                        : 'Assign a valid section to load enrolled students.',
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFAB(isDark, l10n),
          ),
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

  List<MaterialBundleModel> _resolveBundles(MaterialsState state) {
    if (state is MaterialsLoaded && state.courseId == _resolvedCourseId) {
      return state.bundles;
    }
    return const <MaterialBundleModel>[];
  }

  List<CourseStructureModel> _resolveStructureItems(
    CourseStructureState state,
  ) {
    if (state is StructureLoaded && state.courseId == _resolvedCourseId) {
      return state.items;
    }

    return const <CourseStructureModel>[];
  }

  bool _isStructureLoading(CourseStructureState state) {
    return state is StructureLoading;
  }

  String? _resolveStructureError(CourseStructureState state) {
    if (state is StructureError) {
      return state.message;
    }

    return null;
  }

  Map<int, int> _buildMaterialCountsByWeek(
    List<CourseMaterialModel> materials,
  ) {
    final counts = <int, int>{};
    for (final material in materials) {
      final week = material.weekNumber;
      if (week == null || week <= 0) {
        continue;
      }

      counts[week] = (counts[week] ?? 0) + 1;
    }

    return counts;
  }

  bool _hasValidSection(TeachingCourseModel? teachingCourse) {
    return teachingCourse != null && teachingCourse.sectionId > 0;
  }

  int _resolveStudentsCount(
    TeachingCourseModel? teachingCourse,
    List<SectionStudentModel> students,
  ) {
    if (students.isNotEmpty) {
      return students.length;
    }

    if (teachingCourse == null) {
      return _course.totalStudents;
    }

    final fallback = teachingCourse.enrolledCount > 0
        ? teachingCourse.enrolledCount
        : teachingCourse.section.currentEnrollment;
    final adjusted = fallback - 1;
    return adjusted > 0 ? adjusted : 0;
  }

  void _reloadStructure() {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    context.read<CourseStructureBloc>().add(LoadStructure(courseId));
  }

  void _createStructureItem(String title, int weekNumber, String? description) {
    if (!_canManageCourseStructure) {
      _showDeletePermissionDenied();
      return;
    }

    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    context.read<CourseStructureBloc>().add(
      CreateStructureItem(
        courseId: courseId,
        title: title,
        weekNumber: weekNumber,
        description: description,
      ),
    );
  }

  void _updateStructureItem(
    CourseStructureModel item,
    String title,
    int weekNumber,
    String? description,
  ) {
    if (!_canManageCourseStructure) {
      _showDeletePermissionDenied();
      return;
    }

    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    context.read<CourseStructureBloc>().add(
      UpdateStructureItem(
        courseId: courseId,
        itemId: item.organizationId,
        payload: <String, dynamic>{
          'title': title,
          'weekNumber': weekNumber,
          'description': description,
        },
      ),
    );
  }

  void _deleteStructureItem(CourseStructureModel item) {
    if (!_canManageCourseStructure) {
      _showDeletePermissionDenied();
      return;
    }

    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0) {
      return;
    }

    context.read<CourseStructureBloc>().add(
      DeleteStructureItem(courseId: courseId, itemId: item.organizationId),
    );
  }

  void _reorderStructureItems(List<int> itemIds) {
    if (!_canManageCourseStructure) {
      _showDeletePermissionDenied();
      return;
    }

    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || itemIds.isEmpty) {
      return;
    }

    context.read<CourseStructureBloc>().add(
      ReorderStructureItems(courseId: courseId, itemIds: itemIds),
    );
  }

  void _onMaterialsStateChanged(BuildContext context, MaterialsState state) {
    if (!mounted) {
      return;
    }

    if (state is MaterialsLoaded && _retryingFailedMaterials) {
      setState(() {
        _retryingFailedMaterials = false;
        _materialsFailureMessage = null;
        _failedMaterialIds = const <String>[];
      });
      return;
    }

    if (state is! MaterialsError) {
      return;
    }

    if (_retryingFailedMaterials) {
      setState(() {
        _retryingFailedMaterials = false;
      });
    }

    final messenger = ScaffoldMessenger.of(context);
    final canRetryDelete =
        state.failedMaterialIds.isNotEmpty &&
        state.message.toLowerCase().contains('materials deleted');

    if (canRetryDelete) {
      setState(() {
        _materialsFailureMessage = state.message;
        _failedMaterialIds = List<String>.from(state.failedMaterialIds);
      });

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _retryFailedMaterials,
            ),
          ),
        );
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleViewMaterial(MaterialModel material) {
    if (material.type.toLowerCase() != 'video') {
      return;
    }

    final rawUrl = material.fileUrl.trim();
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video URL available for this material.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final videoId = _extractYoutubeVideoId(rawUrl);
    if (videoId == null || videoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not parse a valid YouTube video ID.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || !mounted) {
      return;
    }

    final encodedTitle = Uri.encodeComponent(material.title);
    final route =
        '/instructor/courses/$courseId/video/$videoId?title=$encodedTitle';
    context.push(route, extra: _course);
  }

  String? _extractYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }

    final match = RegExp(
      r'(?:embed/|shorts/)([A-Za-z0-9_-]{11})',
    ).firstMatch(url);
    return match?.group(1);
  }

  void _toggleMaterialVisibility(MaterialModel material) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || material.id.isEmpty) {
      return;
    }

    context.read<MaterialsBloc>().add(
      ToggleMaterialVisibility(
        courseId: courseId,
        materialId: material.id,
        isPublished: !material.isPublished,
      ),
    );
  }

  void _editMaterial(MaterialModel material) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || material.id.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: material.title);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit material title'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) {
                  return;
                }

                context.read<MaterialsBloc>().add(
                  UpdateMaterial(
                    courseId: courseId,
                    materialId: material.id,
                    payload: <String, dynamic>{'title': title},
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMaterial(MaterialModel material) {
    if (material.id.isEmpty) {
      return;
    }

    _confirmDeleteMaterials(
      materialIds: <String>[material.id],
      title: 'Delete material?',
      body: 'This action cannot be undone.',
    );
  }

  void _toggleBundleVisibility(MaterialBundleModel bundle) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || bundle.materials.isEmpty) {
      return;
    }

    final publishAll = bundle.materials.any(
      (material) => !material.isPublished,
    );
    for (final material in bundle.materials) {
      context.read<MaterialsBloc>().add(
        ToggleMaterialVisibility(
          courseId: courseId,
          materialId: material.materialId,
          isPublished: publishAll,
        ),
      );
    }
  }

  void _editBundle(MaterialBundleModel bundle) {
    final courseId = _resolvedCourseId;
    final ids = bundle.materials
        .map((material) => material.materialId)
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (courseId == null || courseId <= 0 || ids.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: bundle.baseTitle);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit bundle title'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Bundle title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isEmpty) {
                  return;
                }

                context.read<MaterialsBloc>().add(
                  UpdateMaterial(
                    courseId: courseId,
                    materialId: ids.first,
                    materialIds: ids,
                    payload: <String, dynamic>{'title': title},
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBundle(MaterialBundleModel bundle) {
    final ids = bundle.materials
        .map((material) => material.materialId)
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (ids.isEmpty) {
      return;
    }

    _confirmDeleteMaterials(
      materialIds: ids,
      title: 'Delete bundle?',
      body:
          'This will delete all ${ids.length} materials in the bundle. This action cannot be undone.',
    );
  }

  void _confirmDeleteMaterials({
    required List<String> materialIds,
    required String title,
    required String body,
  }) {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || materialIds.isEmpty) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<MaterialsBloc>().add(
                  DeleteMaterial(courseId: courseId, materialIds: materialIds),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: CMColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _retryFailedMaterials() {
    final courseId = _resolvedCourseId;
    if (courseId == null || courseId <= 0 || _failedMaterialIds.isEmpty) {
      return;
    }

    final retryIds = List<String>.from(_failedMaterialIds);
    setState(() {
      _retryingFailedMaterials = true;
      _materialsFailureMessage = null;
      _failedMaterialIds = const <String>[];
    });

    context.read<MaterialsBloc>().add(
      DeleteMaterial(courseId: courseId, materialIds: retryIds),
    );
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
      totalStudents: _resolveStudentsCount(teachingCourse, students),
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

    final sectionId = teachingCourse.sectionId;
    if (sectionId > 0) {
      if (_requestedStudentsSectionId != sectionId) {
        _requestedStudentsSectionId = sectionId;
        context.read<InstructorCoursesBloc>().add(
          LoadSectionStudents(sectionId),
        );
      }
    } else {
      _requestedStudentsSectionId = null;
    }

    if (_requestedMetricsCourseId != courseId) {
      _requestedMetricsCourseId = courseId;
      final enrolledCount = _resolveStudentsCount(
        teachingCourse,
        const <SectionStudentModel>[],
      );

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
            if (_canDeleteCourse)
              _buildSheetItem(
                ctx,
                Icons.archive_outlined,
                l10n.archiveCourse,
                CMColors.warning,
                isDark,
              ),
            if (_canDeleteCourse)
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
      isPublished: material.isPublished,
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
