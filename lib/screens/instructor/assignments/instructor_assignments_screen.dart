import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/instructor/instructor_assignments_cubit.dart';
import '../../../bloc/instructor/instructor_assignments_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/shared/modern_action_sheet.dart';

class InstructorAssignmentsScreen extends StatelessWidget {
  const InstructorAssignmentsScreen({
    super.key,
    this.assignmentService,
    this.enrollmentService,
    this.canManageAssignments = true,
    this.initialCourseId,
    this.lockCourseSelection = false,
    this.embedded = false,
  });

  final AssignmentService? assignmentService;
  final EnrollmentService? enrollmentService;
  final bool canManageAssignments;
  final int? initialCourseId;
  final bool lockCourseSelection;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final coreApiClient = CoreApiClient(storageService: StorageService());
    final resolvedAssignmentService =
        assignmentService ?? AssignmentService(coreApiClient: coreApiClient);
    final resolvedEnrollmentService =
        enrollmentService ?? EnrollmentService(coreApiClient: coreApiClient);

    return BlocProvider<InstructorAssignmentsCubit>(
      create: (_) => InstructorAssignmentsCubit(
        assignmentService: resolvedAssignmentService,
        enrollmentService: resolvedEnrollmentService,
      )..loadTeachingCourses(preferredCourseId: initialCourseId),
      child: _InstructorAssignmentsView(
        canManage: canManageAssignments,
        lockCourseSelection: lockCourseSelection,
        embedded: embedded,
      ),
    );
  }
}

enum _InstructorAssignmentStateFilter {
  all,
  draft,
  published,
  closed,
  archived
}

class _InstructorAssignmentsView extends StatefulWidget {
  const _InstructorAssignmentsView({
    required this.canManage,
    required this.lockCourseSelection,
    required this.embedded,
  });

  final bool canManage;
  final bool lockCourseSelection;
  final bool embedded;

  @override
  State<_InstructorAssignmentsView> createState() =>
      _InstructorAssignmentsViewState();
}

class _InstructorAssignmentsViewState
    extends State<_InstructorAssignmentsView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocConsumer<InstructorAssignmentsCubit,
            InstructorAssignmentsState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final content = RefreshIndicator(
              onRefresh: () =>
                  context.read<InstructorAssignmentsCubit>().loadAssignments(
                        page: 1,
                        limit: 20,
                        refresh: true,
                      ),
              color: InstructorColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  if (!widget.embedded) _buildAppBar(isDark, l10n),
                  if (state.isLoading && state.assignments == null) ...<Widget>[
                    _buildLoadingHeader(isDark, l10n),
                    _buildLoadingSkeleton(isDark),
                  ] else if (!state.isLoading && state.teachingCourses.isEmpty)
                    SliverFillRemaining(
                      child: _buildNoCoursesState(isDark, l10n),
                    )
                  else
                    _buildLoadedContent(isDark, l10n, state),
                ],
              ),
            );

            if (widget.embedded) {
              return Container(
                color: InstructorColors.background(isDark),
                child: content,
              );
            }

            return Scaffold(
              backgroundColor: InstructorColors.background(isDark),
              floatingActionButton: widget.canManage
                  ? FloatingActionButton.extended(
                      onPressed: _openCreateAssignment,
                      backgroundColor: InstructorColors.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.createAssignment),
                    )
                  : null,
              body: SafeArea(child: content),
            );
          },
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: InstructorColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: InstructorColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.assignments,
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(isDark),
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
            color: InstructorColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  SliverToBoxAdapter _buildLoadingHeader(
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: isDark
              ? InstructorColors.darkHeaderGradient
              : const LinearGradient(
                  colors: <Color>[
                    Color(0xFF155CFB),
                    Color(0xFF3B82F6),
                    Color(0xFF14B8A6),
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
              l10n.instructorAssignmentsHeaderTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.instructorAssignmentsHeaderSubtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverMainAxisGroup _buildLoadedContent(
    bool isDark,
    AppLocalizations l10n,
    InstructorAssignmentsState state,
  ) {
    final assignments = state.assignmentItems;
    final grouped = <int, List<AssignmentModel>>{};
    for (final assignment in assignments) {
      grouped
          .putIfAbsent(assignment.courseId, () => <AssignmentModel>[])
          .add(assignment);
    }

    final courseIds = grouped.keys.toList(growable: false);
    final r = context.responsive;

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _buildSummaryHeader(isDark, l10n, r, state, assignments),
        ),
        SliverToBoxAdapter(
          child: _buildFilterMenus(isDark, l10n, r, state, assignments.length),
        ),
        if (courseIds.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyAssignmentsState(
              isDark,
              l10n,
              onCreate: widget.canManage ? _openCreateAssignment : null,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final courseId = courseIds[index];
                return _buildCourseAssignmentsCard(
                  isDark,
                  l10n,
                  state,
                  courseId,
                  grouped[courseId] ?? const <AssignmentModel>[],
                );
              }, childCount: courseIds.length),
            ),
          ),
        if (state.hasMorePages)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: state.isLoading
                      ? null
                      : () =>
                          context.read<InstructorAssignmentsCubit>().loadMore(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.primary,
                    side: BorderSide(
                      color: InstructorColors.primary.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.loadMore),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    InstructorAssignmentsState state,
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

    final selectedCourse = _selectedCourse(state);
    final subtitle = selectedCourse == null
        ? l10n.instructorAssignmentsHeaderSubtitle
        : '${selectedCourse.course.code} • ${selectedCourse.course.name}';

    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.menu_book_rounded,
        label: l10n.course,
        value: selectedCourse == null ? '0' : '1',
        color: InstructorColors.teal,
      ),
      (
        icon: Icons.assignment_rounded,
        label: l10n.assignments,
        value: '${assignments.length}',
        color: InstructorColors.accent,
      ),
      (
        icon: Icons.publish_rounded,
        label: l10n.assignmentStatusPublished,
        value: '$publishedCount',
        color: InstructorColors.success,
      ),
      (
        icon: Icons.edit_note_rounded,
        label: l10n.draft,
        value: '$draftCount',
        color: InstructorColors.warning,
      ),
      (
        icon: Icons.archive_rounded,
        label: l10n.assignmentStatusClosed,
        value: '$closedCount',
        color: InstructorColors.pink,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorColors.darkHeaderGradient
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF155CFB),
                  Color(0xFF3B82F6),
                  Color(0xFF14B8A6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.28 : 0.2,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
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
              padding: EdgeInsets.all(r.isMobile ? 18 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.instructorAssignmentsHeaderTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.isMobile ? 19 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: r.isMobile ? 12 : 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 420 ? 2 : 4;
                      const spacing = 10.0;
                      final itemWidth = (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: stats.map((stat) {
                          return SizedBox(
                            width: itemWidth,
                            child: _buildHeaderStatCard(
                              icon: stat.icon,
                              label: stat.label,
                              value: stat.value,
                              color: stat.color,
                            ),
                          );
                        }).toList(growable: false),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
    InstructorAssignmentsState state,
    int visibleCount,
  ) {
    final selectedCourse = _selectedCourse(state);
    final selectedCourseLabel = selectedCourse == null
        ? l10n.course
        : '${selectedCourse.course.code} • ${selectedCourse.course.name}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: InstructorColors.borderColor(isDark).withValues(alpha: 0.7),
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
                    color: InstructorColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$visibleCount ${l10n.assignments}',
                    style: TextStyle(
                      color: InstructorColors.primary,
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
                  child: _buildModernDropdown<int>(
                    isDark: isDark,
                    label: l10n.course,
                    selectedLabel: selectedCourseLabel,
                    value: state.selectedCourseId ?? 0,
                    icon: Icons.menu_book_rounded,
                    menuMaxHeight: r.screenHeight * 0.45,
                    enabled: !widget.lockCourseSelection,
                    items: state.teachingCourses.map((course) {
                      return DropdownMenuItem<int>(
                        value: course.courseId,
                        child: Text(
                          '${course.course.code} • ${course.course.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      context
                          .read<InstructorAssignmentsCubit>()
                          .selectCourse(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernDropdown<_InstructorAssignmentStateFilter>(
                    isDark: isDark,
                    label: l10n.status,
                    selectedLabel: _statusFilterLabel(
                      l10n,
                      _statusFilterFromApi(state.statusFilter),
                    ),
                    value: _statusFilterFromApi(state.statusFilter),
                    icon: Icons.tune_rounded,
                    menuMaxHeight: r.screenHeight * 0.45,
                    items: <DropdownMenuItem<_InstructorAssignmentStateFilter>>[
                      DropdownMenuItem(
                        value: _InstructorAssignmentStateFilter.all,
                        child: Text(l10n.assignmentAllStates),
                      ),
                      DropdownMenuItem(
                        value: _InstructorAssignmentStateFilter.draft,
                        child: Text(l10n.draft),
                      ),
                      DropdownMenuItem(
                        value: _InstructorAssignmentStateFilter.published,
                        child: Text(l10n.assignmentStatusPublished),
                      ),
                      DropdownMenuItem(
                        value: _InstructorAssignmentStateFilter.closed,
                        child: Text(l10n.assignmentStatusClosed),
                      ),
                      DropdownMenuItem(
                        value: _InstructorAssignmentStateFilter.archived,
                        child: Text(l10n.archived),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      context
                          .read<InstructorAssignmentsCubit>()
                          .setStatusFilter(
                            _statusFilterToApi(value),
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
    required T value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required double menuMaxHeight,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: menuMaxHeight,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: InstructorColors.textSecondaryColor(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 18, color: InstructorColors.primary),
        filled: true,
        fillColor: isDark
            ? InstructorColors.surfaceColor(isDark).withValues(alpha: 0.75)
            : InstructorColors.surfaceColor(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: InstructorColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: InstructorColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: InstructorColors.primary,
            width: 1.4,
          ),
        ),
      ),
      dropdownColor: InstructorColors.cardColor(isDark),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: InstructorColors.primary,
      ),
      style: TextStyle(
        color: InstructorColors.textPrimaryColor(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      selectedItemBuilder: (context) {
        return items.map((_) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              selectedLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(growable: false);
      },
      items: items,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildCourseAssignmentsCard(
    bool isDark,
    AppLocalizations l10n,
    InstructorAssignmentsState state,
    int courseId,
    List<AssignmentModel> assignments,
  ) {
    final course = state.teachingCourses
        .where((item) => item.courseId == courseId)
        .firstOrNull;
    final courseCode = course?.course.code ?? assignments.first.courseCode;
    final courseName = course?.course.name ?? assignments.first.courseName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.6),
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
                  InstructorColors.primary
                      .withValues(alpha: isDark ? 0.28 : 0.12),
                  InstructorColors.teal.withValues(alpha: isDark ? 0.18 : 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: InstructorColors.teal,
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
                          color: InstructorColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        courseName,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
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
                    color: InstructorColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${assignments.length} ${l10n.assignments}',
                    style: const TextStyle(
                      color: InstructorColors.success,
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
              color:
                  InstructorColors.borderColor(isDark).withValues(alpha: 0.5),
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
                color: _assignmentTypeColor(assignment.type)
                    .withValues(alpha: 0.12),
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
                      color: InstructorColors.textPrimaryColor(isDark),
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
                            l10n, assignment.submissionType),
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
                    color: InstructorColors.textSecondaryColor(isDark),
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
        Icon(icon,
            size: 14, color: InstructorColors.textSecondaryColor(isDark)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: InstructorColors.textSecondaryColor(isDark),
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
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 210,
            decoration: BoxDecoration(
              color: InstructorColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(22),
            ),
          );
        }, childCount: 3),
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
            Icon(Icons.school_outlined, size: 52, color: InstructorColors.info),
            const SizedBox(height: 12),
            Text(
              l10n.noCoursesAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
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
                color: InstructorColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 46,
                color: InstructorColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAssignmentsFound,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.assignmentEmptyManagementMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
              ),
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

  TeachingCourseModel? _selectedCourse(InstructorAssignmentsState state) {
    final selectedCourseId = state.selectedCourseId;
    if (selectedCourseId == null) {
      return null;
    }
    return state.teachingCourses
        .where((course) => course.courseId == selectedCourseId)
        .firstOrNull;
  }

  Future<void> _openCreateAssignment() async {
    final cubit = context.read<InstructorAssignmentsCubit>();
    final result = await context.push<bool>('/instructor/assignments/create');
    if (result == true && mounted) {
      await cubit.loadAssignments(page: 1, limit: 20, refresh: true);
    }
  }

  Future<void> _openEditAssignment(AssignmentModel assignment) async {
    final cubit = context.read<InstructorAssignmentsCubit>();
    final result = await context.push<bool>(
      '/instructor/assignments/create',
      extra: <String, dynamic>{
        'assignmentId': assignment.assignmentId,
        'assignment': assignment,
      },
    );
    if (result == true && mounted) {
      await cubit.loadAssignments(page: 1, limit: 20, refresh: true);
    }
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
        color: InstructorColors.primary,
      ),
      if (widget.canManage)
        ModernActionItem<String>(
          value: 'edit',
          label: l10n.edit,
          icon: Icons.edit_rounded,
          color: InstructorColors.accent,
        ),
      if (widget.canManage)
        ..._nextStatuses(assignment.apiStatus).map(
          (status) => ModernActionItem<String>(
            value: 'status:${status.value}',
            label: _statusLabel(l10n, status),
            icon: _statusActionIcon(status),
            color: _statusColor(status),
          ),
        ),
      if (widget.canManage)
        ModernActionItem<String>(
          value: 'delete',
          label: l10n.delete,
          icon: Icons.delete_outline_rounded,
          color: InstructorColors.error,
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
      _openAssignmentDetail(assignment);
    } else if (value == 'edit') {
      await _openEditAssignment(assignment);
    } else if (value == 'delete') {
      context.read<InstructorAssignmentsCubit>().deleteAssignment(
            assignment.assignmentId,
          );
    } else if (value.startsWith('status:')) {
      final raw = value.split(':').last;
      context.read<InstructorAssignmentsCubit>().updateStatus(
            assignment.assignmentId,
            api.AssignmentStatus.fromString(raw),
          );
    }
  }

  Future<void> _openAssignmentDetail(AssignmentModel assignment) async {
    final cubit = context.read<InstructorAssignmentsCubit>();
    await context.push<void>(
      '/instructor/assignments/${assignment.assignmentId}',
      extra: assignment,
    );
    if (mounted) {
      await cubit.loadAssignments(page: 1, limit: 20, refresh: true);
    }
  }

  static _InstructorAssignmentStateFilter _statusFilterFromApi(
    api.AssignmentStatus? status,
  ) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return _InstructorAssignmentStateFilter.draft;
      case api.AssignmentStatus.published:
        return _InstructorAssignmentStateFilter.published;
      case api.AssignmentStatus.closed:
        return _InstructorAssignmentStateFilter.closed;
      case api.AssignmentStatus.archived:
        return _InstructorAssignmentStateFilter.archived;
      case api.AssignmentStatus.unknown:
      case null:
        return _InstructorAssignmentStateFilter.all;
    }
  }

  static api.AssignmentStatus? _statusFilterToApi(
    _InstructorAssignmentStateFilter value,
  ) {
    switch (value) {
      case _InstructorAssignmentStateFilter.all:
        return null;
      case _InstructorAssignmentStateFilter.draft:
        return api.AssignmentStatus.draft;
      case _InstructorAssignmentStateFilter.published:
        return api.AssignmentStatus.published;
      case _InstructorAssignmentStateFilter.closed:
        return api.AssignmentStatus.closed;
      case _InstructorAssignmentStateFilter.archived:
        return api.AssignmentStatus.archived;
    }
  }

  static String _statusFilterLabel(
    AppLocalizations l10n,
    _InstructorAssignmentStateFilter value,
  ) {
    switch (value) {
      case _InstructorAssignmentStateFilter.all:
        return l10n.assignmentAllStates;
      case _InstructorAssignmentStateFilter.draft:
        return l10n.draft;
      case _InstructorAssignmentStateFilter.published:
        return l10n.assignmentStatusPublished;
      case _InstructorAssignmentStateFilter.closed:
        return l10n.assignmentStatusClosed;
      case _InstructorAssignmentStateFilter.archived:
        return l10n.archived;
    }
  }

  static List<api.AssignmentStatus> _nextStatuses(
      api.AssignmentStatus current) {
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

  static Color _statusColor(api.AssignmentStatus status) {
    switch (status) {
      case api.AssignmentStatus.draft:
        return InstructorColors.warning;
      case api.AssignmentStatus.published:
        return InstructorColors.success;
      case api.AssignmentStatus.closed:
        return InstructorColors.info;
      case api.AssignmentStatus.archived:
        return InstructorColors.pink;
      case api.AssignmentStatus.unknown:
        return InstructorColors.textSecondary;
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
        return InstructorColors.primary;
      case AssignmentType.code:
        return InstructorColors.accent;
      case AssignmentType.presentation:
        return InstructorColors.warning;
      case AssignmentType.quiz:
        return InstructorColors.pink;
      case AssignmentType.project:
        return InstructorColors.success;
      case AssignmentType.lab:
        return InstructorColors.teal;
      case AssignmentType.other:
        return InstructorColors.textSecondary;
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
