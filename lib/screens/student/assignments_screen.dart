import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/assignments/assignment_bloc.dart';
import '../../bloc/assignments/assignment_event.dart';
import '../../bloc/assignments/assignment_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/responsive.dart';
import '../../config/app_theme.dart';
import '../../features/walkthrough/student_walkthrough_registry.dart';
import '../../features/walkthrough/walkthrough_target.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/assignments/assignment_model.dart';
import '../../models/core/course_model.dart';
import '../../models/core/enums/assignment_enums.dart' as api;
import '../../utils/navigation/safe_back.dart';
import '../../widgets/student/academic/academic_list_skeleton.dart';
import 'assignment_detail_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  final int? preselectedCourseId;

  const AssignmentsScreen({super.key, this.preselectedCourseId});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  static const LinearGradient _lightHeroGradient = LinearGradient(
    colors: <Color>[Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient _darkHeroGradient = LinearGradient(
    colors: <Color>[Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AssignmentBloc>().add(
        FetchAssignments(courseId: widget.preselectedCourseId ?? -1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: StudentWalkthroughRouteMarker(
            segmentId: StudentWalkthroughIds.assignments,
            child: Scaffold(
              backgroundColor: _StudentAssignmentColors.background(isDark),
              body: SafeArea(
                child: BlocConsumer<AssignmentBloc, AssignmentState>(
                  listener: (context, state) {
                    final error = state.error;
                    if (error == null || error.isEmpty) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.read<AssignmentBloc>().add(const ClearError());
                  },
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AssignmentBloc>().add(
                          RefreshAssignments(courseId: state.selectedCourseId),
                        );
                        await context.read<AssignmentBloc>().stream.firstWhere(
                          (next) => !next.isListLoading,
                        );
                      },
                      color: _StudentAssignmentColors.primary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          _buildAppBar(context, isDark, l10n),
                          if (state.isListLoading &&
                              state.assignments.isEmpty) ...<Widget>[
                            _buildLoadingHero(isDark, l10n),
                            _buildLoadingSkeleton(isDark),
                          ] else if (!state.isListLoading &&
                              state.enrolledCourses.isEmpty)
                            SliverFillRemaining(
                              child: _buildNoCoursesState(
                                context,
                                isDark,
                                l10n,
                              ),
                            )
                          else if (state.error != null &&
                              state.assignments.isEmpty &&
                              !state.isListLoading)
                            SliverFillRemaining(
                              child: _buildErrorState(context, isDark, l10n),
                            )
                          else
                            _buildLoadedContent(context, isDark, l10n, state),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SliverAppBar(
      backgroundColor: _StudentAssignmentColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      leading: IconButton(
        onPressed: () => _leaveStudentAcademicScreen(context),
        icon: Icon(
          iosBackIcon(context),
          color: _StudentAssignmentColors.textPrimary(isDark),
        ),
      ),
      title: Text(
        l10n.assignments,
        style: TextStyle(
          color: _StudentAssignmentColors.textPrimary(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: _StudentAssignmentColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  SliverToBoxAdapter _buildLoadingHero(bool isDark, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark ? _darkHeroGradient : _lightHeroGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _studentHeroTitle(l10n),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _studentHeroSubtitle(),
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
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingSkeleton(bool isDark) {
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

  SliverMainAxisGroup _buildLoadedContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentState state,
  ) {
    final assignments = state.filteredAssignments;
    final grouped = <int, List<AssignmentModel>>{};
    for (final assignment in assignments) {
      grouped
          .putIfAbsent(assignment.courseId, () => <AssignmentModel>[])
          .add(assignment);
    }

    final courseIds = grouped.keys.toList(growable: false);
    final responsive = context.responsive;

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: StudentWalkthroughIds.assignmentsHeader,
            child: _buildSummaryHeader(
              context,
              isDark,
              l10n,
              responsive,
              state,
              assignments,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: StudentWalkthroughIds.assignmentsFilters,
            child: _buildFilterCard(
              context,
              isDark,
              l10n,
              responsive,
              state,
              assignments.length,
            ),
          ),
        ),
        if (courseIds.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(context, isDark, l10n, state),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverToBoxAdapter(
              child: WalkthroughTarget(
                id: StudentWalkthroughIds.assignmentsList,
                child: Column(
                  children: [
                    for (final courseId in courseIds)
                      _buildCourseCard(
                        context,
                        isDark,
                        l10n,
                        state,
                        courseId,
                        grouped[courseId] ?? const <AssignmentModel>[],
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
    AssignmentState state,
    List<AssignmentModel> assignments,
  ) {
    final selectedCourse = _selectedCourse(state);
    final courseCount = selectedCourse == null
        ? state.enrolledCourses.length
        : 1;
    final gradedCount = assignments.where((item) => item.grade != null).length;
    final subtitle = selectedCourse == null
        ? _studentHeroSubtitle()
        : '${selectedCourse.code} • ${selectedCourse.name}';

    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.menu_book_rounded,
        label: l10n.course,
        value: '$courseCount',
        color: _StudentAssignmentColors.info,
      ),
      (
        icon: Icons.assignment_rounded,
        label: l10n.assignments,
        value: '${assignments.length}',
        color: _StudentAssignmentColors.accent,
      ),
      (
        icon: Icons.cloud_done_rounded,
        label: l10n.submitted,
        value: '${state.submittedCount}',
        color: _StudentAssignmentColors.success,
      ),
      (
        icon: Icons.pending_actions_rounded,
        label: l10n.pending,
        value: '${state.pendingCount}',
        color: _StudentAssignmentColors.warning,
      ),
      (
        icon: Icons.grade_rounded,
        label: 'Graded',
        value: '$gradedCount',
        color: _StudentAssignmentColors.primary,
      ),
      (
        icon: Icons.warning_amber_rounded,
        label: l10n.overdue,
        value: '${state.overdueCount}',
        color: _StudentAssignmentColors.error,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: isDark ? _darkHeroGradient : _lightHeroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _StudentAssignmentColors.primary.withValues(
              alpha: isDark ? 0.28 : 0.18,
            ),
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
              padding: EdgeInsets.all(responsive.isMobile ? 16 : 18),
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
                              _studentHeroTitle(l10n),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.isMobile ? 18 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: responsive.isMobile ? 11.5 : 12,
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
                                child: _buildHeroStatCard(
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

  Widget _buildHeroStatCard({
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

  Widget _buildFilterCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
    AssignmentState state,
    int visibleCount,
  ) {
    final selectedCourse = _selectedCourse(state);
    final selectedCourseLabel = selectedCourse == null
        ? l10n.allCourses
        : '${selectedCourse.code} • ${selectedCourse.name}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _StudentAssignmentColors.card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _StudentAssignmentColors.border(
              isDark,
            ).withValues(alpha: 0.72),
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
                    color: _StudentAssignmentColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$visibleCount ${l10n.assignments}',
                    style: const TextStyle(
                      color: _StudentAssignmentColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _buildModernDropdown<int?>(
                    isDark: isDark,
                    label: l10n.course,
                    selectedLabel: selectedCourseLabel,
                    value: state.selectedCourseId,
                    icon: Icons.menu_book_rounded,
                    menuMaxHeight: responsive.screenHeight * 0.45,
                    items: <DropdownMenuItem<int?>>[
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(
                          l10n.allCourses,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...state.enrolledCourses.map((course) {
                        return DropdownMenuItem<int?>(
                          value: course.id,
                          child: Text(
                            '${course.code} • ${course.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      context.read<AssignmentBloc>().add(
                        FetchAssignments(courseId: value ?? -1),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernDropdown<AssignmentFilterStatus>(
                    isDark: isDark,
                    label: l10n.status,
                    selectedLabel: _filterLabel(l10n, state.filterStatus),
                    value: state.filterStatus,
                    icon: Icons.tune_rounded,
                    menuMaxHeight: responsive.screenHeight * 0.45,
                    items: <DropdownMenuItem<AssignmentFilterStatus>>[
                      DropdownMenuItem(
                        value: AssignmentFilterStatus.all,
                        child: Text(l10n.all),
                      ),
                      DropdownMenuItem(
                        value: AssignmentFilterStatus.submitted,
                        child: Text(l10n.submitted),
                      ),
                      DropdownMenuItem(
                        value: AssignmentFilterStatus.pending,
                        child: Text(l10n.pending),
                      ),
                      DropdownMenuItem(
                        value: AssignmentFilterStatus.overdue,
                        child: Text(l10n.overdue),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      context.read<AssignmentBloc>().add(
                        SetAssignmentFilterStatus(filterStatus: value),
                      );
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
          color: _StudentAssignmentColors.textSecondary(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.circle,
          color: Colors.transparent,
          size: 0,
        ),
        filled: true,
        fillColor: isDark
            ? _StudentAssignmentColors.surface(isDark).withValues(alpha: 0.75)
            : _StudentAssignmentColors.surface(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: _StudentAssignmentColors.border(
              isDark,
            ).withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: _StudentAssignmentColors.border(
              isDark,
            ).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _StudentAssignmentColors.primary,
            width: 1.4,
          ),
        ),
      ),
      dropdownColor: _StudentAssignmentColors.card(isDark),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _StudentAssignmentColors.primary,
      ),
      style: TextStyle(
        color: _StudentAssignmentColors.textPrimary(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      selectedItemBuilder: (context) {
        return items
            .map((_) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 18,
                      color: _StudentAssignmentColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _StudentAssignmentColors.textPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false);
      },
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentState state,
    int courseId,
    List<AssignmentModel> assignments,
  ) {
    CourseModel? course;
    for (final item in state.enrolledCourses) {
      if (item.id == courseId) {
        course = item;
        break;
      }
    }
    final courseCode = course?.code ?? assignments.first.courseCode;
    final courseName = course?.name ?? assignments.first.courseName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _StudentAssignmentColors.card(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _StudentAssignmentColors.border(isDark).withValues(alpha: 0.6),
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
                  _StudentAssignmentColors.primary.withValues(
                    alpha: isDark ? 0.28 : 0.12,
                  ),
                  _StudentAssignmentColors.info.withValues(
                    alpha: isDark ? 0.18 : 0.08,
                  ),
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
                    color: _StudentAssignmentColors.info,
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
                          color: _StudentAssignmentColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        courseName,
                        style: TextStyle(
                          color: _StudentAssignmentColors.textPrimary(isDark),
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
                    color: _StudentAssignmentColors.success.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${assignments.length} ${l10n.assignments}',
                    style: const TextStyle(
                      color: _StudentAssignmentColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...assignments.map(
            (assignment) =>
                _buildAssignmentTile(context, isDark, l10n, assignment),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    final submissionStatus = _submissionStatus(assignment);
    final statusColor = _statusColor(submissionStatus);
    final grade = assignment.grade;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openAssignmentDetails(context, assignment),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: _StudentAssignmentColors.border(
                isDark,
              ).withValues(alpha: 0.5),
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
                      color: _StudentAssignmentColors.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grade == null
                        ? _submissionSupportText(l10n, assignment)
                        : '${_formatScore(grade)} / ${_formatScore(assignment.maxGrade)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: grade == null
                          ? _StudentAssignmentColors.textSecondary(isDark)
                          : _StudentAssignmentColors.success,
                      fontSize: 13,
                      fontWeight: grade == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        label: _submissionTypeLabel(assignment),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(l10n, submissionStatus),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _StudentAssignmentColors.textSecondary(isDark),
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
        Icon(
          icon,
          size: 14,
          color: _StudentAssignmentColors.textSecondary(isDark),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: _StudentAssignmentColors.textSecondary(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNoCoursesState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;
    return _buildFillStateScaffold(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.school_outlined,
            size: responsive.fontSize56,
            color: _StudentAssignmentColors.info,
          ),
          const SizedBox(height: 12),
          Text(
            'No enrolled courses found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _StudentAssignmentColors.textPrimary(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enroll in a course to view your assignments here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _StudentAssignmentColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    AssignmentState state,
  ) {
    final selectedCourse = _selectedCourse(state);
    final message = selectedCourse == null
        ? 'No assignments are available yet. Enroll in a course to get started.'
        : 'No assignments are available in ${selectedCourse.name} right now.';

    return _buildFillStateScaffold(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _StudentAssignmentColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 46,
              color: _StudentAssignmentColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noAssignmentsFound,
            style: TextStyle(
              color: _StudentAssignmentColors.textPrimary(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _StudentAssignmentColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final responsive = context.responsive;
    return _buildFillStateScaffold(
      context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.wifi_off_rounded,
            size: responsive.fontSize56,
            color: _StudentAssignmentColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load assignments',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _StudentAssignmentColors.textPrimary(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or try again to sync your assignment feed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _StudentAssignmentColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<AssignmentBloc>().add(
                FetchAssignments(courseId: widget.preselectedCourseId ?? -1),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: _StudentAssignmentColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildFillStateScaffold(
    BuildContext context, {
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }

  AssignmentFilterStatus _submissionStatus(AssignmentModel assignment) {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return AssignmentFilterStatus.submitted;
      case 'overdue':
        return AssignmentFilterStatus.overdue;
      default:
        return AssignmentFilterStatus.pending;
    }
  }

  String _statusLabel(AppLocalizations l10n, AssignmentFilterStatus status) {
    switch (status) {
      case AssignmentFilterStatus.submitted:
        return l10n.submitted;
      case AssignmentFilterStatus.pending:
        return l10n.pending;
      case AssignmentFilterStatus.overdue:
        return l10n.overdue;
      case AssignmentFilterStatus.all:
        return l10n.all;
    }
  }

  String _filterLabel(AppLocalizations l10n, AssignmentFilterStatus status) {
    switch (status) {
      case AssignmentFilterStatus.all:
        return l10n.all;
      case AssignmentFilterStatus.submitted:
        return l10n.submitted;
      case AssignmentFilterStatus.pending:
        return l10n.pending;
      case AssignmentFilterStatus.overdue:
        return l10n.overdue;
    }
  }

  String _submissionSupportText(
    AppLocalizations l10n,
    AssignmentModel assignment,
  ) {
    if (assignment.submissionFilterStatus == 'submitted') {
      return l10n.submitted;
    }
    if (assignment.submissionFilterStatus == 'overdue') {
      return l10n.overdue;
    }
    return 'Ready to submit';
  }

  String _submissionTypeLabel(AssignmentModel assignment) {
    switch (assignment.submissionType) {
      case api.SubmissionType.file:
        return 'File';
      case api.SubmissionType.text:
        return 'Text';
      case api.SubmissionType.link:
        return 'Link';
      case api.SubmissionType.multiple:
        return 'Mixed';
      case api.SubmissionType.unknown:
        return 'Flexible';
    }
  }

  Color _statusColor(AssignmentFilterStatus status) {
    switch (status) {
      case AssignmentFilterStatus.submitted:
        return _StudentAssignmentColors.success;
      case AssignmentFilterStatus.pending:
        return _StudentAssignmentColors.warning;
      case AssignmentFilterStatus.overdue:
        return _StudentAssignmentColors.error;
      case AssignmentFilterStatus.all:
        return _StudentAssignmentColors.primary;
    }
  }

  Color _assignmentTypeColor(AssignmentType type) {
    switch (type) {
      case AssignmentType.document:
        return _StudentAssignmentColors.primary;
      case AssignmentType.code:
        return _StudentAssignmentColors.accent;
      case AssignmentType.presentation:
        return _StudentAssignmentColors.warning;
      case AssignmentType.quiz:
        return _StudentAssignmentColors.info;
      case AssignmentType.project:
        return _StudentAssignmentColors.success;
      case AssignmentType.lab:
        return const Color(0xFF0891B2);
      case AssignmentType.other:
        return _StudentAssignmentColors.textMuted;
    }
  }

  CourseModel? _selectedCourse(AssignmentState state) {
    final selectedCourseId = state.selectedCourseId;
    if (selectedCourseId == null) {
      return null;
    }
    for (final course in state.enrolledCourses) {
      if (course.id == selectedCourseId) {
        return course;
      }
    }
    return null;
  }

  Future<void> _openAssignmentDetails(
    BuildContext context,
    AssignmentModel assignment,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssignmentDetailScreen(assignment: assignment),
      ),
    );
    if (!context.mounted) {
      return;
    }
    context.read<AssignmentBloc>().add(
      RefreshAssignments(
        courseId: context.read<AssignmentBloc>().state.selectedCourseId,
      ),
    );
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

  String _studentHeroTitle(AppLocalizations l10n) => 'Assignment Pulse';

  String _studentHeroSubtitle() =>
      'Track upcoming deadlines, review what you have submitted, and jump into the next assignment with less friction.';

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

void _leaveStudentAcademicScreen(BuildContext context) {
  safeBack(context, '/dashboard');
}

class _StudentAssignmentColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color textMuted = Color(0xFF64748B);

  static Color background(bool isDark) {
    return isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC);
  }

  static Color card(bool isDark) {
    return isDark ? const Color(0xFF111827) : Colors.white;
  }

  static Color surface(bool isDark) {
    return isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);
  }

  static Color textPrimary(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF0F172A);
  }

  static Color textSecondary(bool isDark) {
    return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  }

  static Color border(bool isDark) {
    return isDark ? const Color(0xFF334155) : const Color(0xFFD9E2F0);
  }
}
