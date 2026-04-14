import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/assignments/assignment_form_data.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/courses/ta_courses_barrel.dart';
import '../../../widgets/instructor/assignments/assignment_create_form.dart';
import '../assignments/ta_assignment_submissions_screen.dart';

class TACourseDetailScreen extends StatefulWidget {
  final String courseId;

  const TACourseDetailScreen({super.key, required this.courseId});

  @override
  State<TACourseDetailScreen> createState() => _TACourseDetailScreenState();
}

class _TACourseDetailScreenState extends State<TACourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _loadedTabs = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Ensure TA courses are fetched if not already
    final cubit = context.read<TACoursesCubit>();
    final status = cubit.state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>>) {
      cubit.fetchTACourses();
    }

    // Load first tab on init
    _loadTabData(0);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _loadTabData(_tabController.index);
  }

  /// Fires the named cubit method for the tab on first activation only.
  void _loadTabData(int tabIndex) {
    if (_loadedTabs.contains(tabIndex)) return;
    _loadedTabs.add(tabIndex);

    final cubit = context.read<TACoursesCubit>();
    final courseId = int.tryParse(widget.courseId);

    // Resolve the TeachingCourseModel for section access
    TeachingCourseModel? tc;
    final status = cubit.state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      final id = int.tryParse(widget.courseId);
      if (id != null) {
        tc = status.data.cast<TeachingCourseModel?>().firstWhere(
              (c) => c!.sectionId == id || c.courseId == id,
              orElse: () => null,
            );
      }
    }

    final cId = tc?.courseId ?? courseId;
    if (cId == null) return;

    switch (tabIndex) {
      case 0:
        cubit.fetchCourseOverview(cId);
      case 1:
        cubit.fetchCourseSectionsAndLabs(cId);
      case 2:
        cubit.fetchCourseStructure(cId);
      case 3:
        cubit.fetchCourseMaterials(cId);
      case 4:
        cubit.fetchCourseAssignments(cId);
      case 5:
        cubit.fetchPendingGrading(cId);
      case 6:
        cubit.fetchAttendanceSummary(cId);
      case 7:
        // Students: auto-load sections[0].id
        if (tc != null) {
          cubit.fetchSectionStudents(tc.sectionId);
        }
      case 8:
        // Announcements: no network call — static empty state
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Extract the matching TeachingCourseModel from cubit state.
  TeachingCourseModel? _findCourse(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      final id = int.tryParse(widget.courseId);
      if (id == null) return null;
      try {
        return status.data.firstWhere(
          (tc) => tc.sectionId == id || tc.courseId == id,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          body: SafeArea(
            child: BlocBuilder<TACoursesCubit, TACoursesState>(
              builder: (context, taState) {
                return _buildBody(isDark, l10n, taState);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n, TACoursesState state) {
    final status = state.coursesStatus;

    if (status is TASubTabLoading<List<TeachingCourseModel>>) {
      return _buildLoadingState(isDark);
    }

    if (status is TASubTabError<List<TeachingCourseModel>>) {
      return _buildErrorState(isDark, l10n, status.message);
    }

    final course = _findCourse(state);
    if (course == null) {
      return _buildEmptyState(isDark, l10n);
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildAppBar(isDark, l10n, course),
        SliverToBoxAdapter(child: _buildCourseContent(isDark, l10n, course)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            child: _buildTabBar(isDark, l10n),
            isDark: isDark,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDark, l10n, course, state),
          _buildSectionsLabsTab(isDark, l10n, state),
          _buildLecturesTab(isDark, l10n, state),
          _buildMaterialsTab(isDark, l10n, state),
          _buildAssignmentsTab(isDark, l10n, state, course),
          _buildGradingTab(isDark, l10n, state),
          _buildAttendanceTab(isDark, l10n, state),
          _buildStudentsTab(isDark, l10n, state, course),
          _buildAnnouncementsTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(isDark, width: 40, height: 40, radius: 10),
          const SizedBox(height: 24),
          Row(
            children: [
              _skeletonBox(isDark, width: 52, height: 52, radius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(isDark, width: 200, height: 18, radius: 4),
                    const SizedBox(height: 8),
                    _skeletonBox(isDark, width: 140, height: 14, radius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
              const SizedBox(width: 12),
              Expanded(child: _skeletonBox(isDark, height: 80, radius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _skeletonBox(isDark, width: double.infinity, height: 48, radius: 12),
          const SizedBox(height: 24),
          _skeletonBox(isDark, width: double.infinity, height: 120, radius: 16),
        ],
      ),
    );
  }

  Widget _skeletonBox(
    bool isDark, {
    double? width,
    double height = 16,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: TAColors.borderColor(isDark).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TAColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: TAColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load course',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TACoursesCubit>().fetchTACourses();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Text(
        'Course not found',
        style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
      ),
    );
  }

  SliverAppBar _buildAppBar(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
  ) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tc.course.courseCode} — ${tc.course.courseName}',
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${tc.semester.name} • Section ${tc.section.sectionNumber}',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildCourseContent(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TACourseStatsCards(
            isDark: isDark,
            studentsCount: tc.section.currentEnrollment,
            labsCount: 0,
            assignmentsCount: 0,
            discussionsCount: 0,
          ),
          const SizedBox(height: 16),
          TACourseQuickActions(
            isDark: isDark,
            onViewLabs: () => _tabController.animateTo(1),
            onViewSubmissions: () => _tabController.animateTo(5),
            onViewDiscussions: () => _tabController.animateTo(8),
            onAIInsights: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      color: TAColors.scaffoldColor(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            color: TAColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: TAColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: TAColors.textSecondaryColor(isDark),
          labelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtil(context).isMobile ? 10 : 13,
            fontWeight: FontWeight.w500,
          ),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Sections & Labs'),
            Tab(text: 'Lectures'),
            Tab(text: 'Materials'),
            Tab(text: 'Assignments'),
            Tab(text: 'Grading'),
            Tab(text: 'Attendance'),
            Tab(text: 'Students'),
            Tab(text: 'Announcements'),
          ],
        ),
      ),
    );
  }

  // ── Sub-tab builders ─────────────────────────────────────────

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    TeachingCourseModel tc,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<TACourseOverview>(
        isDark: isDark,
        subTabState: state.overviewData,
        emptyMessage: 'No overview data available',
        emptyIcon: Icons.dashboard_rounded,
        builder: (overview) {
          return TACourseOverviewTab(
            isDark: isDark,
            upcomingTasks: [
              TAUpcomingTask(
                id: '1',
                title: 'Review ${tc.course.courseName} materials',
                subtitle: '${tc.section.currentEnrollment} students enrolled',
              ),
            ],
            recentActivities: [
              TARecentActivity(
                id: '1',
                title:
                    'Course ${tc.course.courseCode} — ${overview.totalAssignments} assignments, ${overview.totalLabs} labs',
                timeAgo: '${overview.pendingGrading} pending grading',
                icon: Icons.school_rounded,
                color: TAColors.primary,
              ),
            ],
            onStartTask: (task) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting: ${task.title}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionsLabsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<TACourseSectionsLabs>(
        isDark: isDark,
        subTabState: state.sectionsLabsData,
        emptyMessage: 'No sections or labs found',
        emptyIcon: Icons.science_rounded,
        builder: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.sections.isNotEmpty) ...[
                _buildSectionHeader(isDark, 'Sections', Icons.class_rounded),
                ...data.sections.map((section) => _buildInfoCard(
                      isDark: isDark,
                      title: 'Section ${section.sectionNumber}',
                      subtitle:
                          '${section.currentEnrollment}/${section.maxCapacity} students',
                      trailing: section.location ?? 'TBA',
                      icon: Icons.group_rounded,
                      color: TAColors.primary,
                    )),
              ],
              if (data.labs.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(isDark, 'Labs', Icons.science_rounded),
                ...data.labs.map((lab) => _buildInfoCard(
                      isDark: isDark,
                      title: lab.title,
                      subtitle: lab.status.value.toUpperCase(),
                      trailing: lab.dueDate != null
                          ? '${lab.dueDate!.day}/${lab.dueDate!.month}'
                          : '',
                      icon: Icons.science_rounded,
                      color: TAColors.teal,
                      onTap: () =>
                          context.push('/ta/lab/${lab.labId ?? lab.id}'),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildLecturesTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<dynamic>(
        isDark: isDark,
        subTabState: state.structureData,
        emptyMessage: 'No lectures available',
        emptyIcon: Icons.play_lesson_rounded,
        builder: (data) {
          if (data is List && data.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No lectures available',
              icon: Icons.play_lesson_rounded,
            );
          }
          // TODO: render CourseStructureModel list when T010 widget is available
          return _buildEmptyTabState(
            isDark: isDark,
            message: 'Lectures loaded — UI pending',
            icon: Icons.play_lesson_rounded,
          );
        },
      ),
    );
  }

  Widget _buildMaterialsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent<List<dynamic>>(
        isDark: isDark,
        subTabState: state.materialsData,
        emptyMessage: 'No materials available',
        emptyIcon: Icons.folder_rounded,
        builder: (materials) {
          if (materials.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No materials available',
              icon: Icons.folder_rounded,
            );
          }
          return Column(
            children: materials.map((mat) {
              final title = mat is Map ? (mat['title'] ?? 'Material') : 'Material';
              return _buildInfoCard(
                isDark: isDark,
                title: title.toString(),
                subtitle: '',
                trailing: '',
                icon: Icons.insert_drive_file_rounded,
                color: TAColors.info,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel tc,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // T017: Create Assignment button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAssignmentForm(tc),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSubTabContent(
            isDark: isDark,
            subTabState: state.assignmentsData,
            emptyMessage: 'No assignments yet',
            emptyIcon: Icons.assignment_rounded,
            builder: (assignments) {
              if (assignments.isEmpty) {
                return _buildEmptyTabState(
                  isDark: isDark,
                  message: 'No assignments yet',
                  icon: Icons.assignment_rounded,
                );
              }
              return Column(
                children: assignments.map((a) {
                  return _buildAssignmentCard(isDark, a, tc);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // T017: Open assignment creation form
  void _openAssignmentForm(TeachingCourseModel tc, {AssignmentModel? existing}) {
    final cubit = context.read<TACoursesCubit>();
    final status = cubit.state.coursesStatus;
    final courses = status is TASubTabLoaded<List<TeachingCourseModel>>
        ? status.data
        : <TeachingCourseModel>[tc];
    final assignmentService = context.read<AssignmentService>();

    AssignmentFormData? initialData;
    if (existing != null) {
      initialData = AssignmentFormData(
        title: existing.title,
        description: existing.description,
        instructions: existing.instructionsText,
        dueDate: existing.dueDate,
        maxScore: existing.maxGrade,
        weight: existing.weight,
        submissionType: existing.submissionType,
        maxFileSizeMb: existing.maxFileSizeMb,
        allowedFileTypes: existing.allowedFileTypes ?? const [],
        latePenaltyPercent: existing.latePenaltyPercent,
        status: existing.apiStatus,
        courseId: existing.courseId,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(existing != null ? 'Edit Assignment' : 'Create Assignment'),
          ),
          body: AssignmentCreateForm(
            courses: courses,
            assignmentService: assignmentService,
            initialData: initialData,
            assignmentId: existing?.assignmentId,
            onSubmit: (formData) async {
              try {
                if (existing != null) {
                  await assignmentService.update(
                    existing.assignmentId,
                    formData.toJson(),
                  );
                } else {
                  await assignmentService.create(formData.toJson());
                }
                if (mounted) {
                  Navigator.of(context).pop();
                  cubit.fetchCourseAssignments(tc.courseId);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  // T019: Delete assignment with confirmation dialog
  void _confirmDeleteAssignment(TeachingCourseModel tc, AssignmentModel a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text(
          'This action cannot be undone. Delete this assignment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TACoursesCubit>().deleteAssignment(
                    tc.courseId,
                    a.assignmentId,
                  );
            },
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // T017-T019: Assignment card with Edit/Delete actions
  Widget _buildAssignmentCard(
    bool isDark,
    AssignmentModel a,
    TeachingCourseModel tc,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TAAssignmentSubmissionsScreen(
                  assignment: a,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TAColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    size: 20,
                    color: TAColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${a.apiStatus.toJson().toUpperCase()} • ${a.maxGrade} pts',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // T018: Edit button
                IconButton(
                  onPressed: () => _openAssignmentForm(tc, existing: a),
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: TAColors.info,
                  ),
                  tooltip: 'Edit',
                ),
                // T019: Delete button
                IconButton(
                  onPressed: () => _confirmDeleteAssignment(tc, a),
                  icon: Icon(
                    Icons.delete_rounded,
                    size: 18,
                    color: TAColors.error,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradingTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent(
        isDark: isDark,
        subTabState: state.pendingGradingData,
        emptyMessage: 'No pending grading — all caught up!',
        emptyIcon: Icons.check_circle_rounded,
        builder: (pending) {
          if (pending.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No pending grading — all caught up!',
              icon: Icons.check_circle_rounded,
            );
          }
          return Column(
            children: pending.map((sub) {
              return _buildInfoCard(
                isDark: isDark,
                title: '${sub.user?.firstName ?? ''} ${sub.user?.lastName ?? ''}'.trim().isEmpty
                    ? 'Student #${sub.userId}'
                    : '${sub.user!.firstName} ${sub.user!.lastName}'.trim(),
                subtitle: 'Assignment #${sub.assignmentId}',
                trailing: sub.submissionStatus.value,
                icon: Icons.grading_rounded,
                color: TAColors.warning,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent(
        isDark: isDark,
        subTabState: state.attendanceSummaryData,
        emptyMessage: 'No attendance data yet',
        emptyIcon: Icons.event_available_rounded,
        builder: (summaries) {
          if (summaries.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No attendance data yet',
              icon: Icons.event_available_rounded,
            );
          }
          return Column(
            children: summaries.map((s) {
              return _buildInfoCard(
                isDark: isDark,
                title: s.labTitle,
                subtitle:
                    'P:${s.presentCount} A:${s.absentCount} E:${s.excusedCount} L:${s.lateCount}',
                trailing: '${s.totalCount} total',
                icon: Icons.how_to_reg_rounded,
                color: TAColors.success,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStudentsTab(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    TeachingCourseModel tc,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildSubTabContent(
        isDark: isDark,
        subTabState: state.studentsData,
        emptyMessage: 'No students enrolled in this section',
        emptyIcon: Icons.people_rounded,
        builder: (students) {
          if (students.isEmpty) {
            return _buildEmptyTabState(
              isDark: isDark,
              message: 'No students enrolled in this section',
              icon: Icons.people_rounded,
            );
          }
          return Column(
            children: students.map((s) {
              final name =
                  s is Map ? '${s['firstName'] ?? ''} ${s['lastName'] ?? ''}' : 'Student';
              return _buildInfoCard(
                isDark: isDark,
                title: name.toString().trim(),
                subtitle: '',
                trailing: '',
                icon: Icons.person_rounded,
                color: TAColors.primary,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildEmptyTabState(
        isDark: isDark,
        message: 'Announcements are not available for this course',
        icon: Icons.campaign_rounded,
      ),
    );
  }

  // ── Shared Helpers ───────────────────────────────────────────

  /// Generic sub-tab content builder with loading/error/empty/loaded states.
  Widget _buildSubTabContent<T>({
    required bool isDark,
    required TASubTabState<T> subTabState,
    required String emptyMessage,
    required IconData emptyIcon,
    required Widget Function(T data) builder,
  }) {
    return switch (subTabState) {
      TASubTabInitial<T>() || TASubTabLoading<T>() => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CircularProgressIndicator(
              color: TAColors.primary,
              strokeWidth: 3,
            ),
          ),
        ),
      TASubTabError<T>(message: final msg) => _buildErrorWidget(isDark, msg),
      TASubTabLoaded<T>(data: final data) => builder(data),
    };
  }

  Widget _buildErrorWidget(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: TAColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTabState({
    required bool isDark,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: TAColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TAColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required String trailing,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing.isNotEmpty)
                  Text(
                    trailing,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: TAColors.textTertiaryColor(isDark),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  _TabBarDelegate({required this.child, required this.isDark});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return isDark != oldDelegate.isDark;
  }
}
