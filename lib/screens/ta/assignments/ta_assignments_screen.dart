import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/features/walkthrough/ta_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_target.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_drawer.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../widgets/student/academic/academic_list_skeleton.dart';
import '../../../widgets/shared/modern_action_sheet.dart';
import '../../instructor/create_assignment_screen.dart';

class TAAssignmentsScreen extends StatefulWidget {
  const TAAssignmentsScreen({
    super.key,
    this.initialCourseId,
    this.lockCourseSelection = false,
    this.embedded = false,
  });

  final int? initialCourseId;
  final bool lockCourseSelection;
  final bool embedded;

  @override
  State<TAAssignmentsScreen> createState() => _TAAssignmentsScreenState();
}

enum _TAAssignmentStateFilter { all, draft, published, closed, archived }

class _TAAssignmentsScreenState extends State<TAAssignmentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedCourseId;
  _TAAssignmentStateFilter _selectedStatusFilter = _TAAssignmentStateFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final cubit = context.read<TACoursesCubit>();
    final status = cubit.state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>>) {
      await cubit.fetchTACourses();
    }

    if (!mounted) {
      return;
    }

    _syncSelectedCourse(context.read<TACoursesCubit>().state);
  }

  void _syncSelectedCourse(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>>) {
      return;
    }

    final courses = status.data;

    final preferredCourseId =
        widget.initialCourseId != null &&
            courses.any((course) => course.courseId == widget.initialCourseId)
        ? widget.initialCourseId
        : null;
    final hasSelected =
        _selectedCourseId != null &&
        courses.any((course) => course.courseId == _selectedCourseId);
    final nextCourseId =
        preferredCourseId ?? (hasSelected ? _selectedCourseId : null);

    final assignmentsState = state.assignmentsData;
    final shouldFetch =
        _selectedCourseId != nextCourseId ||
        assignmentsState is TASubTabInitial<List<AssignmentModel>>;

    if (_selectedCourseId != nextCourseId) {
      setState(() => _selectedCourseId = nextCourseId);
    }

    if (shouldFetch) {
      context.read<TACoursesCubit>().fetchCourseAssignments(nextCourseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocConsumer<TACoursesCubit, TACoursesState>(
          listener: (context, state) {
            _syncSelectedCourse(state);
          },
          builder: (context, state) {
            final courses = _coursesFromState(state);
            final content = RefreshIndicator(
              color: TAColors.primary,
              onRefresh: () async {
                final cubit = context.read<TACoursesCubit>();
                await cubit.fetchTACourses();
                if (!mounted) {
                  return;
                }
                final courseId = _selectedCourseId;
                await cubit.fetchCourseAssignments(courseId);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  if (!widget.embedded) _buildAppBar(isDark, l10n),
                  _buildContent(isDark, l10n, state, courses),
                ],
              ),
            );

            if (widget.embedded) {
              return Container(
                color: TAColors.scaffoldColor(isDark),
                child: content,
              );
            }

            return TAWalkthroughRouteMarker(
              segmentId: TAWalkthroughIds.assignments,
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: TAColors.scaffoldColor(isDark),
                drawer: TADrawer(
                  currentRoute: '/ta/assignments',
                  isDark: isDark,
                ),
                floatingActionButton: widget.embedded
                    ? null
                    : FloatingActionButton.extended(
                        onPressed: () => _openAssignmentEditor(context),
                        backgroundColor: TAColors.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.createAssignment),
                      ),
                body: SafeArea(child: content),
              ),
            );
          },
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.assignments,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildContent(
    bool isDark,
    AppLocalizations l10n,
    TACoursesState state,
    List<TeachingCourseModel> courses,
  ) {
    final assignmentsState = state.assignmentsData;
    final assignments =
        assignmentsState is TASubTabLoaded<List<AssignmentModel>>
        ? assignmentsState.data
        : const <AssignmentModel>[];
    final filteredAssignments = _applyStatusFilter(assignments);
    final grouped = <int, List<AssignmentModel>>{};
    for (final assignment in filteredAssignments) {
      grouped
          .putIfAbsent(assignment.courseId, () => <AssignmentModel>[])
          .add(assignment);
    }
    final courseIds = grouped.keys.toList(growable: false);
    final r = context.responsive;

    if (state.coursesStatus is TASubTabLoading<List<TeachingCourseModel>> &&
        courses.isEmpty) {
      return SliverMainAxisGroup(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _buildLoadingHeader(isDark, l10n)),
          _buildLoadingSkeleton(isDark),
        ],
      );
    }

    if (courses.isEmpty) {
      return SliverFillRemaining(child: _buildNoCoursesState(isDark, l10n));
    }

    if (assignmentsState is TASubTabError<List<AssignmentModel>>) {
      return SliverMainAxisGroup(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: WalkthroughTarget(
              id: TAWalkthroughIds.assignmentsHeader,
              child: _buildSummaryHeader(isDark, l10n, r, courses, assignments),
            ),
          ),
          SliverToBoxAdapter(
            child: WalkthroughTarget(
              id: TAWalkthroughIds.assignmentsFilters,
              child: _buildFilterMenus(
                isDark,
                l10n,
                r,
                courses,
                filteredAssignments.length,
              ),
            ),
          ),
          SliverFillRemaining(
            child: _buildErrorState(isDark, l10n, assignmentsState.message),
          ),
        ],
      );
    }

    if (assignmentsState is TASubTabLoading<List<AssignmentModel>> &&
        assignments.isEmpty) {
      return SliverMainAxisGroup(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _buildLoadingHeader(isDark, l10n)),
          _buildLoadingSkeleton(isDark),
        ],
      );
    }

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: TAWalkthroughIds.assignmentsHeader,
            child: _buildSummaryHeader(isDark, l10n, r, courses, assignments),
          ),
        ),
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: TAWalkthroughIds.assignmentsFilters,
            child: _buildFilterMenus(
              isDark,
              l10n,
              r,
              courses,
              filteredAssignments.length,
            ),
          ),
        ),
        if (courseIds.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyAssignmentsState(
              isDark,
              l10n,
              onCreate: _resolveEditorCourseId(context) == null
                  ? null
                  : () => _openAssignmentEditor(context),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final courseId = courseIds[index];
                final card = _buildCourseAssignmentsCard(
                  isDark,
                  l10n,
                  courses,
                  courseId,
                  grouped[courseId] ?? const <AssignmentModel>[],
                );
                if (index == 0) {
                  return WalkthroughTarget(
                    id: TAWalkthroughIds.assignmentsList,
                    child: card,
                  );
                }
                return card;
              }, childCount: courseIds.length),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? TAColors.darkHeaderGradient
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF8B5CF6),
                  Color(0xFFA78BFA),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.taAssignmentsHeaderTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            l10n.taAssignmentsHeaderSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    List<TeachingCourseModel> courses,
    List<AssignmentModel> assignments,
  ) {
    final publishedCount = assignments
        .where((item) => item.apiStatus == api.AssignmentStatus.published)
        .length;
    final draftCount = assignments
        .where((item) => item.apiStatus == api.AssignmentStatus.draft)
        .length;
    final closedCount = assignments
        .where(
          (item) =>
              item.apiStatus == api.AssignmentStatus.closed ||
              item.apiStatus == api.AssignmentStatus.archived,
        )
        .length;

    TeachingCourseModel? selectedCourse;
    for (final course in courses) {
      if (course.courseId == _selectedCourseId) {
        selectedCourse = course;
        break;
      }
    }

    final subtitle = selectedCourse == null
        ? l10n.taAssignmentsHeaderSubtitle
        : '${selectedCourse.course.code} • ${selectedCourse.course.name}';
    final courseCount = selectedCourse == null ? courses.length : 1;

    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.menu_book_rounded,
        label: l10n.course,
        value: '$courseCount',
        color: TAColors.teal,
      ),
      (
        icon: Icons.assignment_rounded,
        label: l10n.assignments,
        value: '${assignments.length}',
        color: TAColors.secondary,
      ),
      (
        icon: Icons.publish_rounded,
        label: l10n.assignmentStatusPublished,
        value: '$publishedCount',
        color: TAColors.success,
      ),
      (
        icon: Icons.edit_note_rounded,
        label: l10n.draft,
        value: '$draftCount',
        color: TAColors.warning,
      ),
      (
        icon: Icons.archive_rounded,
        label: l10n.assignmentStatusClosed,
        value: '$closedCount',
        color: TAColors.pink,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: isDark
            ? TAColors.darkHeaderGradient
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF8B5CF6),
                  Color(0xFFA78BFA),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TAColors.primary.withValues(alpha: isDark ? 0.28 : 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -34,
              right: -10,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -42,
              left: -18,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.isMobile ? 16 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.taAssignmentsHeaderTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.isMobile ? 18 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: r.isMobile ? 11.5 : 12,
                                height: 1.28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 360 ? 2 : 3;
                      const spacing = 8.0;
                      final itemWidth =
                          (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: stats
                            .map((stat) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildHeaderStatCard(
                                  icon: stat.icon,
                                  label: stat.label,
                                  value: stat.value,
                                  color: stat.color,
                                ),
                              );
                            })
                            .toList(growable: false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenus(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    List<TeachingCourseModel> courses,
    int visibleCount,
  ) {
    String selectedCourseLabel = l10n.allCourses;
    for (final course in courses) {
      if (course.courseId == _selectedCourseId) {
        selectedCourseLabel = '${course.course.code} • ${course.course.name}';
        break;
      }
    }
    final selectedCourseValue =
        courses.any((course) => course.courseId == _selectedCourseId)
        ? _selectedCourseId
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.7),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$visibleCount ${l10n.assignments}',
                    style: TextStyle(
                      color: TAColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (widget.lockCourseSelection)
              _buildModernDropdown<_TAAssignmentStateFilter>(
                isDark: isDark,
                label: l10n.status,
                selectedLabel: _statusFilterLabel(l10n, _selectedStatusFilter),
                value: _selectedStatusFilter,
                icon: Icons.tune_rounded,
                menuMaxHeight: r.screenHeight * 0.45,
                items: <DropdownMenuItem<_TAAssignmentStateFilter>>[
                  DropdownMenuItem(
                    value: _TAAssignmentStateFilter.all,
                    child: Text(l10n.assignmentAllStates),
                  ),
                  DropdownMenuItem(
                    value: _TAAssignmentStateFilter.draft,
                    child: Text(l10n.draft),
                  ),
                  DropdownMenuItem(
                    value: _TAAssignmentStateFilter.published,
                    child: Text(l10n.assignmentStatusPublished),
                  ),
                  DropdownMenuItem(
                    value: _TAAssignmentStateFilter.closed,
                    child: Text(l10n.assignmentStatusClosed),
                  ),
                  DropdownMenuItem(
                    value: _TAAssignmentStateFilter.archived,
                    child: Text(l10n.archived),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedStatusFilter = value);
                },
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _buildModernDropdown<int?>(
                      isDark: isDark,
                      label: l10n.course,
                      selectedLabel: selectedCourseLabel,
                      value: selectedCourseValue,
                      icon: Icons.menu_book_rounded,
                      menuMaxHeight: r.screenHeight * 0.45,
                      items: <DropdownMenuItem<int?>>[
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            l10n.allCourses,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...courses.map((course) {
                          return DropdownMenuItem<int?>(
                            value: course.courseId,
                            child: Text(
                              '${course.course.code} • ${course.course.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCourseId = value);
                        context.read<TACoursesCubit>().fetchCourseAssignments(
                          value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernDropdown<_TAAssignmentStateFilter>(
                      isDark: isDark,
                      label: l10n.status,
                      selectedLabel: _statusFilterLabel(
                        l10n,
                        _selectedStatusFilter,
                      ),
                      value: _selectedStatusFilter,
                      icon: Icons.tune_rounded,
                      menuMaxHeight: r.screenHeight * 0.45,
                      items: <DropdownMenuItem<_TAAssignmentStateFilter>>[
                        DropdownMenuItem(
                          value: _TAAssignmentStateFilter.all,
                          child: Text(l10n.assignmentAllStates),
                        ),
                        DropdownMenuItem(
                          value: _TAAssignmentStateFilter.draft,
                          child: Text(l10n.draft),
                        ),
                        DropdownMenuItem(
                          value: _TAAssignmentStateFilter.published,
                          child: Text(l10n.assignmentStatusPublished),
                        ),
                        DropdownMenuItem(
                          value: _TAAssignmentStateFilter.closed,
                          child: Text(l10n.assignmentStatusClosed),
                        ),
                        DropdownMenuItem(
                          value: _TAAssignmentStateFilter.archived,
                          child: Text(l10n.archived),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _selectedStatusFilter = value);
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required bool isDark,
    required String label,
    required String selectedLabel,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required double menuMaxHeight,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: menuMaxHeight,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: TAColors.textSecondaryColor(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 18, color: TAColors.primary),
        filled: true,
        fillColor: isDark
            ? TAColors.surfaceColor(isDark).withValues(alpha: 0.75)
            : TAColors.surfaceColor(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TAColors.primary, width: 1.4),
        ),
      ),
      dropdownColor: TAColors.cardColor(isDark),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: TAColors.primary,
      ),
      style: TextStyle(
        color: TAColors.textPrimaryColor(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      selectedItemBuilder: (context) {
        return items
            .map((_) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            })
            .toList(growable: false);
      },
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildCourseAssignmentsCard(
    bool isDark,
    AppLocalizations l10n,
    List<TeachingCourseModel> courses,
    int courseId,
    List<AssignmentModel> assignments,
  ) {
    final course = courses
        .where((item) => item.courseId == courseId)
        .firstOrNull;
    final courseCode = course?.course.code ?? assignments.first.courseCode;
    final courseName = course?.course.name ?? assignments.first.courseName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.6),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  TAColors.primary.withValues(alpha: isDark ? 0.28 : 0.12),
                  TAColors.secondary.withValues(alpha: isDark ? 0.18 : 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: TAColors.success,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _courseInitials(courseCode),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        courseCode,
                        style: const TextStyle(
                          color: TAColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        courseName,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${assignments.length} ${l10n.assignments}',
                    style: const TextStyle(
                      color: TAColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...assignments.map(
            (assignment) => _buildAssignmentTile(isDark, l10n, assignment),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openAssignmentDetail(assignment),
      onLongPress: () => _showAssignmentActions(l10n, assignment),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _assignmentTypeColor(
                  assignment.type,
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                assignment.type.icon,
                color: _assignmentTypeColor(assignment.type),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    assignment.title,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: <Widget>[
                      _buildMetaChip(
                        isDark,
                        icon: Icons.calendar_today_rounded,
                        label: _formatDate(context, assignment.dueDate),
                      ),
                      _buildMetaChip(
                        isDark,
                        icon: Icons.stars_rounded,
                        label: _formatScore(assignment.maxGrade),
                      ),
                      _buildMetaChip(
                        isDark,
                        icon: Icons.upload_file_rounded,
                        label: _submissionTypeLabel(
                          l10n,
                          assignment.submissionType,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _buildStatusBadge(isDark, l10n, assignment.apiStatus),
                IconButton(
                  onPressed: () => _showAssignmentActions(l10n, assignment),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(
    bool isDark, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: TAColors.textSecondaryColor(isDark)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
    bool isDark,
    AppLocalizations l10n,
    api.AssignmentStatus status,
  ) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(l10n, status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return SliverToBoxAdapter(
      child: IgnorePointer(
        child: AcademicListSkeleton(
          isDark: isDark,
          itemCount: 4,
          topPadding: 16,
          bottomPadding: 24,
          sliverFriendly: true,
        ),
      ),
    );
  }

  Widget _buildNoCoursesState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.school_outlined, size: 52, color: TAColors.info),
            const SizedBox(height: 12),
            Text(
              l10n.noCoursesAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAssignmentsState(
    bool isDark,
    AppLocalizations l10n, {
    VoidCallback? onCreate,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 46,
                color: TAColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAssignmentsFound,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.assignmentEmptyManagementMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
            if (onCreate != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.createAssignment),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 48, color: TAColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TACoursesCubit>().fetchCourseAssignments(
                  _selectedCourseId,
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  List<TeachingCourseModel> _coursesFromState(TACoursesState state) {
    final status = state.coursesStatus;
    if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
      return status.data;
    }
    return const <TeachingCourseModel>[];
  }

  List<AssignmentModel> _applyStatusFilter(List<AssignmentModel> assignments) {
    return assignments
        .where((assignment) {
          switch (_selectedStatusFilter) {
            case _TAAssignmentStateFilter.all:
              return true;
            case _TAAssignmentStateFilter.draft:
              return assignment.apiStatus == api.AssignmentStatus.draft;
            case _TAAssignmentStateFilter.published:
              return assignment.apiStatus == api.AssignmentStatus.published;
            case _TAAssignmentStateFilter.closed:
              return assignment.apiStatus == api.AssignmentStatus.closed;
            case _TAAssignmentStateFilter.archived:
              return assignment.apiStatus == api.AssignmentStatus.archived;
          }
        })
        .toList(growable: false);
  }

  Future<void> _openAssignmentEditor(
    BuildContext context, {
    AssignmentModel? assignment,
  }) async {
    final courseId = _resolveEditorCourseId(context, assignment: assignment);
    if (courseId == null) {
      return;
    }

    final cubit = context.read<TACoursesCubit>();
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateAssignmentScreen(
          assignment: assignment,
          assignmentId: assignment?.assignmentId,
          preferredCourseId: courseId,
          useTAColors: true,
        ),
      ),
    );

    if (result == true && mounted) {
      await cubit.fetchCourseAssignments(_selectedCourseId);
    }
  }

  int? _resolveEditorCourseId(
    BuildContext context, {
    AssignmentModel? assignment,
  }) {
    final directCourseId = _selectedCourseId ?? assignment?.courseId;
    if (directCourseId != null) {
      return directCourseId;
    }

    final courses = _coursesFromState(context.read<TACoursesCubit>().state);
    if (courses.isEmpty) {
      return null;
    }

    return courses.first.courseId;
  }

  Future<void> _showAssignmentActions(
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) async {
    final actions = <ModernActionItem<String>>[
      ModernActionItem<String>(
        value: 'open',
        label: l10n.assignmentDetails,
        icon: Icons.open_in_new_rounded,
        color: TAColors.primary,
      ),
      ModernActionItem<String>(
        value: 'edit',
        label: l10n.edit,
        icon: Icons.edit_rounded,
        color: TAColors.accent,
      ),
      ..._nextStatuses(assignment.apiStatus).map(
        (status) => ModernActionItem<String>(
          value: 'status:${status.value}',
          label: _statusLabel(l10n, status),
          icon: _statusActionIcon(status),
          color: _statusColor(status),
        ),
      ),
      ModernActionItem<String>(
        value: 'delete',
        label: l10n.delete,
        icon: Icons.delete_outline_rounded,
        color: TAColors.error,
        destructive: true,
      ),
    ];

    final value = await showModernActionSheet<String>(
      context,
      title: assignment.title,
      accentColor: _assignmentTypeColor(assignment.type),
      actions: actions,
    );

    if (!mounted || value == null) {
      return;
    }

    if (value == 'open') {
      await _openAssignmentDetail(assignment);
    } else if (value == 'edit') {
      await _openAssignmentEditor(context, assignment: assignment);
    } else if (value == 'delete') {
      await _confirmDelete(context, assignment);
    } else if (value.startsWith('status:')) {
      final raw = value.split(':').last;
      await _updateStatus(
        context,
        assignment,
        api.AssignmentStatus.fromString(raw),
      );
    }
  }

  Future<void> _openAssignmentDetail(AssignmentModel assignment) async {
    final courseId = _selectedCourseId;
    await context.push<void>(
      '/ta/assignments/${assignment.assignmentId}',
      extra: assignment,
    );
    if (mounted) {
      await context.read<TACoursesCubit>().fetchCourseAssignments(courseId);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AssignmentModel assignment,
  ) async {
    final courseId = _selectedCourseId ?? assignment.courseId;
    final cubit = context.read<TACoursesCubit>();
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.assignmentDeleteTitle),
          content: Text(l10n.assignmentDeleteConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await cubit.deleteAssignment(courseId, assignment.assignmentId);
      await cubit.fetchCourseAssignments(courseId);
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    AssignmentModel assignment,
    api.AssignmentStatus status,
  ) async {
    final courseId = _selectedCourseId ?? assignment.courseId;

    final cubit = context.read<TACoursesCubit>();
    final message = await cubit.updateAssignmentStatus(
      courseId,
      assignment.assignmentId,
      status,
    );
    if (!mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static List<api.AssignmentStatus> _nextStatuses(
    api.AssignmentStatus current,
  ) {
    switch (current) {
      case api.AssignmentStatus.draft:
        return const <api.AssignmentStatus>[api.AssignmentStatus.published];
      case api.AssignmentStatus.published:
        return const <api.AssignmentStatus>[
          api.AssignmentStatus.closed,
          api.AssignmentStatus.archived,
        ];
      case api.AssignmentStatus.closed:
        return const <api.AssignmentStatus>[
          api.AssignmentStatus.archived,
          api.AssignmentStatus.draft,
        ];
      case api.AssignmentStatus.archived:
        return const <api.AssignmentStatus>[api.AssignmentStatus.draft];
      case api.AssignmentStatus.unknown:
        return const <api.AssignmentStatus>[];
    }
  }

  static IconData _statusActionIcon(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.published:
        return Icons.publish_rounded;
      case api.AssignmentStatus.closed:
        return Icons.lock_outline_rounded;
      case api.AssignmentStatus.archived:
        return Icons.archive_outlined;
      case api.AssignmentStatus.draft:
        return Icons.edit_note_rounded;
      case api.AssignmentStatus.unknown:
        return Icons.more_horiz_rounded;
    }
  }

  static String _statusFilterLabel(
    AppLocalizations l10n,
    _TAAssignmentStateFilter value,
  ) {
    switch (value) {
      case _TAAssignmentStateFilter.all:
        return l10n.assignmentAllStates;
      case _TAAssignmentStateFilter.draft:
        return l10n.draft;
      case _TAAssignmentStateFilter.published:
        return l10n.assignmentStatusPublished;
      case _TAAssignmentStateFilter.closed:
        return l10n.assignmentStatusClosed;
      case _TAAssignmentStateFilter.archived:
        return l10n.archived;
    }
  }

  static Color _statusColor(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return TAColors.warning;
      case api.AssignmentStatus.published:
        return TAColors.success;
      case api.AssignmentStatus.closed:
        return TAColors.info;
      case api.AssignmentStatus.archived:
        return TAColors.pink;
      case api.AssignmentStatus.unknown:
        return TAColors.textSecondary;
    }
  }

  static String _statusLabel(
    AppLocalizations l10n,
    api.AssignmentStatus status,
  ) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return l10n.draft;
      case api.AssignmentStatus.published:
        return l10n.assignmentStatusPublished;
      case api.AssignmentStatus.closed:
        return l10n.assignmentStatusClosed;
      case api.AssignmentStatus.archived:
        return l10n.archived;
      case api.AssignmentStatus.unknown:
        return l10n.unknown;
    }
  }

  static String _submissionTypeLabel(
    AppLocalizations l10n,
    api.SubmissionType type,
  ) {
    switch (type) {
      case api.SubmissionType.file:
        return l10n.assignmentSubmissionTypeFile;
      case api.SubmissionType.text:
        return l10n.assignmentSubmissionTypeText;
      case api.SubmissionType.link:
        return l10n.assignmentSubmissionTypeLink;
      case api.SubmissionType.multiple:
        return l10n.assignmentSubmissionTypeMultiple;
      case api.SubmissionType.unknown:
        return l10n.unknown;
    }
  }

  static Color _assignmentTypeColor(AssignmentType type) {
    switch (type) {
      case AssignmentType.document:
        return TAColors.secondary;
      case AssignmentType.code:
        return TAColors.accent;
      case AssignmentType.presentation:
        return TAColors.warning;
      case AssignmentType.quiz:
        return TAColors.pink;
      case AssignmentType.project:
        return TAColors.success;
      case AssignmentType.lab:
        return TAColors.teal;
      case AssignmentType.other:
        return TAColors.textSecondary;
    }
  }

  String _formatDate(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
  }

  String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  static String _courseInitials(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) {
      return 'AS';
    }
    return cleaned.length <= 4
        ? cleaned.toUpperCase()
        : cleaned.substring(0, 4).toUpperCase();
  }
}
