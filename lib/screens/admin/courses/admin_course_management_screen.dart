import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/admin_course_management/admin_enrollment_bloc.dart';
import '../../../bloc/admin_course_management/course_list_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/courses/course_model.dart';
import '../../../models/courses/instructor_assignment_model.dart';
import '../../../models/courses/schedule_model.dart';
import '../../../models/courses/section_model.dart';
import '../../../widgets/admin/courses/courses_barrel.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

/// Admin Course Management Screen
class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({super.key});

  @override
  State<AdminCourseManagementScreen> createState() =>
      _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState
    extends State<AdminCourseManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<CourseListBloc>().add(const LoadCourses());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }

    setState(() {});

    final selected = _selectedCourse(context.read<CourseListBloc>().state);
    if (selected != null) {
      context.read<CourseListBloc>().add(LoadCourseDetails(selected.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return MultiBlocListener(
          listeners: [
            BlocListener<AdminEnrollmentBloc, AdminEnrollmentState>(
              listener: (context, state) {
                _handleEnrollmentState(state, isDark, l10n);
              },
            ),
            BlocListener<CourseListBloc, CourseListState>(
              listener: (context, state) {
                if (state.errorMessage != null &&
                    state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: AdminColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                }
              },
            ),
          ],
          child: Scaffold(
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            body: SafeArea(
              child: Container(
                decoration: isDark
                    ? null
                    : BoxDecoration(
                        gradient: AdminColors.lightBackgroundGradient,
                      ),
                child: BlocBuilder<CourseListBloc, CourseListState>(
                  builder: (context, state) {
                    if (state.status == CourseListStatus.loading &&
                        state.courses.isEmpty) {
                      return _buildLoadingState(isDark, l10n);
                    }

                    if (state.status == CourseListStatus.failure &&
                        state.courses.isEmpty) {
                      return _buildErrorState(isDark, l10n, state.errorMessage);
                    }

                    return _buildContent(isDark, l10n, state);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
  ) {
    final aiInsight = state.courses
        .where((course) => (course.taIds ?? const <int>[]).isEmpty)
        .length;

    final selectedCourse = _selectedCourse(state);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CourseListBloc>().add(
          const LoadCourses(forceRefresh: true),
        );
      },
      color: AdminColors.primary,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: CourseManagementAppBar(
              isDark: isDark,
              totalCourses: state.courses.length,
              searchController: _searchController,
              onSearchChanged: (value) {
                context.read<CourseListBloc>().add(
                  FilterCourses(searchQuery: value),
                );
              },
              onAddCourse: () => context.push('/admin/courses/add'),
              sortBy: state.sortBy,
              sortAscending: state.sortAscending,
              onSortChanged: (sortBy) {
                final nextAscending = state.sortBy == sortBy
                    ? !state.sortAscending
                    : true;

                context.read<CourseListBloc>().add(
                  FilterCourses(sortBy: sortBy, sortAscending: nextAscending),
                );
              },
              departments: _getDepartments(state),
              selectedDepartment: state.selectedDepartment,
              onDepartmentChanged: (department) {
                context.read<CourseListBloc>().add(
                  FilterCourses(selectedDepartment: department ?? ''),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: CourseFilters(
              isDark: isDark,
              selectedFilter: state.selectedFilter,
              onFilterChanged: (value) {
                context.read<CourseListBloc>().add(
                  FilterCourses(selectedFilter: value),
                );
              },
              filterCounts: _getFilterCounts(state),
            ),
          ),
          if (aiInsight > 0) ...<Widget>[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: CourseAIInsight(
                isDark: isDark,
                insight: '$aiInsight ${l10n.coursesNoTA}',
                onAction: () {
                  context.read<CourseListBloc>().add(
                    const FilterCourses(selectedFilter: 'needs_ta'),
                  );
                },
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: CourseStatistics(
              isDark: isDark,
              totalCourses: state.courses.length,
              activeCourses: state.courses
                  .where((course) => course.status == 'ACTIVE')
                  .length,
              totalStudents: state.courses
                  .map((course) => _studentCount(course, state))
                  .fold<int>(0, (a, b) => a + b),
              unassignedCourses: state.courses
                  .where(
                    (course) =>
                        course.instructorId == null ||
                        (course.taIds ?? const <int>[]).isEmpty,
                  )
                  .length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _buildCoursePickerAndTabs(
              isDark,
              l10n,
              state,
              selectedCourse,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          _buildActiveTabSliver(isDark, l10n, state, selectedCourse),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCoursePickerAndTabs(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
    CourseModel? selectedCourse,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AdminColors.darkSurface.withValues(alpha: 0.5)
                  : const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedCourse?.id,
                isExpanded: true,
                hint: Text(
                  l10n.selectCourse,
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
                dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
                items: state.filteredCourses
                    .map(
                      (course) => DropdownMenuItem<int>(
                        value: course.id,
                        child: Text(
                          '${course.code} - ${course.name}',
                          style: TextStyle(
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (courseId) {
                  context.read<CourseListBloc>().add(SelectCourse(courseId));
                  if (courseId != null) {
                    context.read<CourseListBloc>().add(
                      LoadCourseDetails(courseId),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AdminColors.darkSurface.withValues(alpha: 0.4)
                  : AdminColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AdminColors.primary,
              unselectedLabelColor: AdminColors.getTextSecondaryColor(isDark),
              indicatorColor: AdminColors.primary,
              tabs: <Tab>[
                Tab(text: l10n.courses),
                Tab(text: l10n.staff),
                Tab(text: l10n.schedule),
                Tab(text: l10n.exam),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabSliver(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
    CourseModel? selectedCourse,
  ) {
    switch (_tabController.index) {
      case 0:
        return _buildCoursesSliver(isDark, l10n, state);
      case 1:
        return SliverToBoxAdapter(
          child: _buildStaffTab(isDark, l10n, state, selectedCourse),
        );
      case 2:
        return SliverToBoxAdapter(
          child: _buildScheduleTab(isDark, l10n, state, selectedCourse),
        );
      case 3:
      default:
        return SliverToBoxAdapter(
          child: _buildExamsTab(isDark, l10n, state, selectedCourse),
        );
    }
  }

  Widget _buildCoursesSliver(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
  ) {
    if (state.filteredCourses.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark, l10n));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final course = state.filteredCourses[index];

        return CourseCard(
          isDark: isDark,
          course: course,
          instructorName: _resolveInstructorName(course, state),
          instructorInitials: _resolveInstructorInitials(course, state),
          taName: _resolveTaName(course, state),
          taInitials: _resolveTaInitials(course, state),
          studentCount: _studentCount(course, state),
          labCount: _labCount(course, state),
          averageGrade: _averageGrade(course, state),
          aiInsight: _courseInsight(course, state, l10n),
          onEdit: () {
            context.read<CourseListBloc>().add(SelectCourse(course.id));
            context.push('/admin/courses/add', extra: course);
          },
          onAssign: () {
            context.read<CourseListBloc>().add(SelectCourse(course.id));
            context.read<CourseListBloc>().add(LoadCourseDetails(course.id));
            _tabController.animateTo(1);
          },
          onViewLabs: () {
            context.read<CourseListBloc>().add(SelectCourse(course.id));
            context.read<CourseListBloc>().add(LoadCourseDetails(course.id));
            _tabController.animateTo(2);
          },
          onViewDetails: () {
            context.read<CourseListBloc>().add(SelectCourse(course.id));
            context.read<CourseListBloc>().add(LoadCourseDetails(course.id));
          },
          onDelete: () => _confirmDelete(course, isDark, l10n),
        );
      }, childCount: state.filteredCourses.length),
    );
  }

  Widget _buildStaffTab(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
    CourseModel? selectedCourse,
  ) {
    if (selectedCourse == null) {
      return _buildTabEmptyCard(
        isDark: isDark,
        title: l10n.noCoursesFound,
        subtitle: l10n.noData,
        icon: Icons.people_outline_rounded,
      );
    }

    final List<SectionModel> sections =
        state.sectionsByCourse[selectedCourse.id] ??
        selectedCourse.sections ??
        const <SectionModel>[];

    final List<InstructorAssignmentModel> staff =
        state.staffByCourse[selectedCourse.id] ??
        const <InstructorAssignmentModel>[];

    if (state.isDetailsLoading &&
        !state.staffByCourse.containsKey(selectedCourse.id)) {
      return _buildTabLoadingCard(isDark, l10n);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${selectedCourse.code} - ${selectedCourse.name}',
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (staff.isEmpty)
            _buildTabInlinePlaceholder(isDark, l10n.noData)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final sectionStaff = staff
                    .where((item) => item.sectionId == section.id)
                    .toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AdminColors.darkSurface.withValues(alpha: 0.5)
                        : AdminColors.lightBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            l10n.sectionLabel(section.sectionNumber),
                            style: TextStyle(
                              color: AdminColors.getTextColor(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _openSectionStudentsSheet(
                              section.id,
                              isDark,
                              l10n,
                            ),
                            icon: const Icon(
                              Icons.people_outline_rounded,
                              size: 16,
                            ),
                            label: Text(l10n.students),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (sectionStaff.isEmpty)
                        _buildTabInlinePlaceholder(isDark, l10n.noData)
                      else
                        ...sectionStaff.map(
                          (assignment) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  assignment.role.toLowerCase() == 'ta'
                                      ? Icons.support_agent_rounded
                                      : Icons.person_rounded,
                                  size: 16,
                                  color: assignment.role.toLowerCase() == 'ta'
                                      ? AdminColors.accent
                                      : AdminColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${assignment.fullName} (${_localizedRoleLabel(assignment.role, l10n)})',
                                    style: TextStyle(
                                      color: AdminColors.getTextSecondaryColor(
                                        isDark,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
    CourseModel? selectedCourse,
  ) {
    if (selectedCourse == null) {
      return _buildTabEmptyCard(
        isDark: isDark,
        title: l10n.noCoursesFound,
        subtitle: l10n.noData,
        icon: Icons.schedule_rounded,
      );
    }

    final List<SectionModel> sections =
        state.sectionsByCourse[selectedCourse.id] ??
        selectedCourse.sections ??
        const <SectionModel>[];

    final List<ScheduleModel> schedules =
        state.schedulesByCourse[selectedCourse.id] ?? const <ScheduleModel>[];

    if (state.isDetailsLoading &&
        !state.schedulesByCourse.containsKey(selectedCourse.id)) {
      return _buildTabLoadingCard(isDark, l10n);
    }

    final sectionNumberById = <int, String>{
      for (final section in sections) section.id: section.sectionNumber,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.schedule,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (schedules.isEmpty)
            _buildTabInlinePlaceholder(isDark, l10n.noData)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final sectionNumber =
                    sectionNumberById[schedule.sectionId] ?? '-';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AdminColors.darkSurface.withValues(alpha: 0.5)
                        : AdminColors.lightBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          color: AdminColors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.sectionScheduleLabel(
                                sectionNumber,
                                _localizedDayName(
                                  schedule.dayOfWeek.name,
                                  l10n,
                                ),
                              ),
                              style: TextStyle(
                                color: AdminColors.getTextColor(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${schedule.startTime} - ${schedule.endTime}  ${schedule.room ?? ''}',
                              style: TextStyle(
                                color: AdminColors.getTextSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExamsTab(
    bool isDark,
    AppLocalizations l10n,
    CourseListState state,
    CourseModel? selectedCourse,
  ) {
    if (selectedCourse == null) {
      return _buildTabEmptyCard(
        isDark: isDark,
        title: l10n.noCoursesFound,
        subtitle: l10n.noData,
        icon: Icons.quiz_rounded,
      );
    }

    final List<SectionModel> sections =
        state.sectionsByCourse[selectedCourse.id] ??
        selectedCourse.sections ??
        const <SectionModel>[];

    if (state.isDetailsLoading &&
        !state.sectionsByCourse.containsKey(selectedCourse.id)) {
      return _buildTabLoadingCard(isDark, l10n);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.exam,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (sections.isEmpty)
            _buildTabInlinePlaceholder(isDark, l10n.noData)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AdminColors.darkSurface.withValues(alpha: 0.5)
                        : AdminColors.lightBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.event_note_rounded,
                          color: AdminColors.warning,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.sectionLabel(section.sectionNumber),
                              style: TextStyle(
                                color: AdminColors.getTextColor(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l10n.noData,
                              style: TextStyle(
                                color: AdminColors.getTextSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(color: AdminColors.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            l10n.loading,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.somethingWentWrong,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? l10n.error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CourseListBloc>().add(const LoadCourses());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                color: AdminColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCoursesFound,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noCoursesFoundDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/courses/add'),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCourse),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
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
        ),
      ),
    );
  }

  Widget _buildTabEmptyCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: AdminColors.primary, size: 36),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLoadingCard(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AdminColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.loading,
            style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabInlinePlaceholder(bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AdminColors.getTextSecondaryColor(isDark),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  CourseModel? _selectedCourse(CourseListState state) {
    final selectedId = state.selectedCourseId;
    if (selectedId == null) {
      return state.filteredCourses.isEmpty ? null : state.filteredCourses.first;
    }

    for (final course in state.filteredCourses) {
      if (course.id == selectedId) {
        return course;
      }
    }
    return state.filteredCourses.isEmpty ? null : state.filteredCourses.first;
  }

  List<String> _getDepartments(CourseListState state) {
    final departments = state.courses
        .map((course) => course.departmentName)
        .whereType<String>()
        .toSet()
        .toList();
    departments.sort();
    return departments;
  }

  Map<String, int> _getFilterCounts(CourseListState state) {
    return <String, int>{
      'all': state.courses.length,
      'active': state.courses
          .where((course) => course.status == 'ACTIVE')
          .length,
      'inactive': state.courses
          .where((course) => course.status == 'INACTIVE')
          .length,
      'needs_instructor': state.courses
          .where((course) => course.instructorId == null)
          .length,
      'needs_ta': state.courses
          .where((course) => (course.taIds ?? const <int>[]).isEmpty)
          .length,
      'ai_flagged': state.courses
          .where(
            (course) =>
                course.status == 'INACTIVE' ||
                course.instructorId == null ||
                (course.taIds ?? const <int>[]).isEmpty,
          )
          .length,
      'lab_based': state.courses
          .where((course) => _labCount(course, state) > 0)
          .length,
    };
  }

  int _studentCount(CourseModel course, CourseListState state) {
    final sections =
        state.sectionsByCourse[course.id] ??
        course.sections ??
        const <SectionModel>[];
    return sections.fold<int>(
      0,
      (sum, section) => sum + section.currentEnrollment,
    );
  }

  int _labCount(CourseModel course, CourseListState state) {
    final schedules =
        state.schedulesByCourse[course.id] ?? const <ScheduleModel>[];
    if (schedules.isNotEmpty) {
      return schedules
          .where(
            (schedule) => schedule.scheduleType.name.toLowerCase() == 'lab',
          )
          .length;
    }

    final sections = course.sections ?? const <SectionModel>[];
    return sections
        .expand((section) => section.schedules ?? const <ScheduleModel>[])
        .where((schedule) => schedule.scheduleType.name.toLowerCase() == 'lab')
        .length;
  }

  double _averageGrade(CourseModel course, CourseListState state) {
    final students = _studentCount(course, state);
    if (students == 0) {
      return 0;
    }

    // Grade averages are not currently returned by this endpoint.
    return 0;
  }

  String? _resolveInstructorName(CourseModel course, CourseListState state) {
    final staff =
        state.staffByCourse[course.id] ?? const <InstructorAssignmentModel>[];
    for (final assignment in staff) {
      if (assignment.role.toLowerCase() != 'ta') {
        return assignment.fullName;
      }
    }

    if (course.instructorId != null) {
      return AppLocalizations.of(
        context,
      ).idValue(course.instructorId.toString());
    }
    return null;
  }

  String? _resolveInstructorInitials(
    CourseModel course,
    CourseListState state,
  ) {
    final name = _resolveInstructorName(course, state);
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    return _toInitials(name);
  }

  String? _resolveTaName(CourseModel course, CourseListState state) {
    final staff =
        state.staffByCourse[course.id] ?? const <InstructorAssignmentModel>[];
    for (final assignment in staff) {
      if (assignment.role.toLowerCase() == 'ta') {
        return assignment.fullName;
      }
    }

    final taIds = course.taIds ?? const <int>[];
    if (taIds.isNotEmpty) {
      return AppLocalizations.of(context).idValue(taIds.first.toString());
    }
    return null;
  }

  String? _resolveTaInitials(CourseModel course, CourseListState state) {
    final name = _resolveTaName(course, state);
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    return _toInitials(name);
  }

  String? _courseInsight(
    CourseModel course,
    CourseListState state,
    AppLocalizations l10n,
  ) {
    final instructorMissing = _resolveInstructorName(course, state) == null;
    final taMissing = _resolveTaName(course, state) == null;

    if (instructorMissing) {
      return l10n.noInstructorAssigned;
    }

    if (taMissing) {
      return l10n.noTAAssigned;
    }

    return null;
  }

  String _localizedRoleLabel(String role, AppLocalizations l10n) {
    switch (role.toLowerCase()) {
      case 'primary':
        return l10n.rolePrimary;
      case 'co_instructor':
      case 'co-instructor':
        return l10n.roleCoInstructor;
      case 'guest':
        return l10n.roleGuestInstructor;
      case 'ta':
        return l10n.teachingAssistant;
      default:
        return l10n.instructor;
    }
  }

  String _localizedDayName(String dayName, AppLocalizations l10n) {
    switch (dayName.toLowerCase()) {
      case 'monday':
        return l10n.monday;
      case 'tuesday':
        return l10n.tuesday;
      case 'wednesday':
        return l10n.wednesday;
      case 'thursday':
        return l10n.thursday;
      case 'friday':
        return l10n.friday;
      case 'saturday':
        return l10n.saturday;
      case 'sunday':
        return l10n.sunday;
      default:
        return dayName;
    }
  }

  String _toInitials(String value) {
    final parts = value
        .trim()
        .split(' ')
        .where((item) => item.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  Future<void> _confirmDelete(
    CourseModel course,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        title: Text(
          l10n.confirmDelete,
          style: TextStyle(color: AdminColors.getTextColor(isDark)),
        ),
        content: Text(
          '${course.code} - ${course.name}',
          style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (approved == true && mounted) {
      context.read<CourseListBloc>().add(DeleteCourse(course.id));
    }
  }

  Future<void> _openSectionStudentsSheet(
    int sectionId,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    context.read<AdminEnrollmentBloc>().add(LoadSectionStudents(sectionId));

    final userIdController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.78,
          decoration: BoxDecoration(
            color: isDark ? AdminColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '${l10n.students} - #$sectionId',
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          context.read<AdminEnrollmentBloc>().add(
                            LoadSectionStudents(sectionId),
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: userIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: l10n.studentUserIdHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final userId = int.tryParse(
                            userIdController.text.trim(),
                          );
                          if (userId == null) {
                            return;
                          }

                          context.read<AdminEnrollmentBloc>().add(
                            EnrollStudentToSection(
                              sectionId: sectionId,
                              userId: userId,
                            ),
                          );
                        },
                        child: Text(l10n.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        BlocBuilder<AdminEnrollmentBloc, AdminEnrollmentState>(
                          builder: (context, enrollmentState) {
                            if (enrollmentState.status ==
                                    AdminEnrollmentStatus.loading &&
                                enrollmentState.students.isEmpty) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AdminColors.primary,
                                ),
                              );
                            }

                            if (enrollmentState.status ==
                                    AdminEnrollmentStatus.failure &&
                                enrollmentState.students.isEmpty) {
                              return Center(
                                child: Text(
                                  enrollmentState.errorMessage ?? l10n.error,
                                  style: TextStyle(
                                    color: AdminColors.getTextSecondaryColor(
                                      isDark,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (enrollmentState.students.isEmpty) {
                              return Center(
                                child: Text(
                                  l10n.noData,
                                  style: TextStyle(
                                    color: AdminColors.getTextSecondaryColor(
                                      isDark,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: enrollmentState.students.length,
                              itemBuilder: (context, index) {
                                final student = enrollmentState.students[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: AdminColors.primary
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      _toInitials(student.displayName),
                                      style: TextStyle(
                                        color: AdminColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student.displayName,
                                    style: TextStyle(
                                      color: AdminColors.getTextColor(isDark),
                                    ),
                                  ),
                                  subtitle: Text(
                                    student.email ?? '-',
                                    style: TextStyle(
                                      color: AdminColors.getTextSecondaryColor(
                                        isDark,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.person_remove_alt_1_rounded,
                                      color: AdminColors.error,
                                    ),
                                    onPressed: () {
                                      context.read<AdminEnrollmentBloc>().add(
                                        DropStudentEnrollment(
                                          enrollmentId: student.userId
                                              .toString(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    userIdController.dispose();
  }

  void _handleEnrollmentState(
    AdminEnrollmentState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (state.status == AdminEnrollmentStatus.conflictWarning &&
        state.conflictAction != null) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
          title: Text(
            l10n.warning,
            style: TextStyle(color: AdminColors.getTextColor(isDark)),
          ),
          content: Text(
            state.conflictAction!.warningMessage,
            style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AdminEnrollmentBloc>().add(
                  const ClearEnrollmentFeedback(),
                );
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AdminEnrollmentBloc>().add(
                  const ConfirmConflictOverride(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.warning,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      return;
    }

    if (state.status == AdminEnrollmentStatus.failure &&
        state.errorMessage != null &&
        state.errorMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AdminColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (state.status == AdminEnrollmentStatus.success &&
        state.successMessage != null &&
        state.successMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: AdminColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}
