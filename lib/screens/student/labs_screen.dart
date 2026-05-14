import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/labs/labs_cubit.dart';
import '../../bloc/labs/labs_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/responsive.dart';
import '../../config/app_theme.dart';
import '../../features/walkthrough/student_walkthrough_registry.dart';
import '../../features/walkthrough/walkthrough_target.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/core/course_model.dart';
import '../../models/labs/lab_model.dart';
import '../../utils/navigation/safe_back.dart';
import '../../widgets/student/academic/academic_list_skeleton.dart';
import 'lab_detail_screen.dart';

class LabsScreen extends StatefulWidget {
  final int? preselectedCourseId;

  const LabsScreen({super.key, this.preselectedCourseId});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
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

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<LabsCubit>().loadEnrolledCourses(
        preselectedCourseId: widget.preselectedCourseId,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            segmentId: StudentWalkthroughIds.labs,
            child: Scaffold(
              backgroundColor: _StudentLabColors.background(isDark),
              body: SafeArea(
                child: BlocConsumer<LabsCubit, LabsState>(
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
                    context.read<LabsCubit>().clearError();
                  },
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<LabsCubit>().refreshLabs(),
                      color: _StudentLabColors.primary,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          _buildAppBar(context, isDark, l10n),
                          if (state.isLoading &&
                              state.labs.isEmpty) ...<Widget>[
                            _buildLoadingHero(isDark, l10n),
                            _buildLoadingSkeleton(isDark),
                          ] else if (!state.isLoading &&
                              state.enrolledCourses.isEmpty)
                            SliverFillRemaining(
                              child: _buildNoCoursesState(
                                context,
                                isDark,
                                l10n,
                              ),
                            )
                          else if (state.error != null &&
                              state.labs.isEmpty &&
                              !state.isLoading)
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
      backgroundColor: _StudentLabColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      leading: IconButton(
        onPressed: () => _leaveStudentAcademicScreen(context),
        icon: Icon(
          iosBackIcon(context),
          color: _StudentLabColors.textPrimary(isDark),
        ),
      ),
      title: Text(
        l10n.labs,
        style: TextStyle(
          color: _StudentLabColors.textPrimary(isDark),
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
            color: _StudentLabColors.textSecondary(isDark),
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
    LabsState state,
  ) {
    final labs = state.filteredLabs;
    final grouped = <int, List<LabModel>>{};
    for (final lab in labs) {
      grouped.putIfAbsent(lab.courseId, () => <LabModel>[]).add(lab);
    }

    final courseIds = grouped.keys.toList(growable: false);
    final responsive = context.responsive;

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: StudentWalkthroughIds.labsHeader,
            child: _buildSummaryHeader(
              context,
              isDark,
              l10n,
              responsive,
              state,
              labs,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: StudentWalkthroughIds.labsFilters,
            child: _buildFilterCard(
              context,
              isDark,
              l10n,
              responsive,
              state,
              labs.length,
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
                id: StudentWalkthroughIds.labsList,
                child: Column(
                  children: [
                    for (final courseId in courseIds)
                      _buildCourseCard(
                        context,
                        isDark,
                        l10n,
                        state,
                        courseId,
                        grouped[courseId] ?? const <LabModel>[],
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
    LabsState state,
    List<LabModel> labs,
  ) {
    final selectedCourse = state.selectedCourse;
    final courseCount = selectedCourse == null
        ? state.enrolledCourses.length
        : 1;
    final subtitle = selectedCourse == null
        ? _studentHeroSubtitle()
        : '${selectedCourse.code} • ${selectedCourse.name}';

    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.menu_book_rounded,
        label: l10n.course,
        value: '$courseCount',
        color: _StudentLabColors.info,
      ),
      (
        icon: Icons.science_rounded,
        label: l10n.labs,
        value: '${labs.length}',
        color: _StudentLabColors.accent,
      ),
      (
        icon: Icons.schedule_rounded,
        label: 'Upcoming',
        value: '${state.upcomingCount}',
        color: _StudentLabColors.warning,
      ),
      (
        icon: Icons.play_circle_rounded,
        label: 'Active',
        value: '${state.inProgressCount}',
        color: _StudentLabColors.primary,
      ),
      (
        icon: Icons.check_circle_rounded,
        label: 'Completed',
        value: '${state.completedCount}',
        color: _StudentLabColors.success,
      ),
      (
        icon: Icons.warning_amber_rounded,
        label: 'Missed',
        value: '${state.missedCount}',
        color: _StudentLabColors.error,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: isDark ? _darkHeroGradient : _lightHeroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _StudentLabColors.primary.withValues(
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
                          Icons.science_rounded,
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
    LabsState state,
    int visibleCount,
  ) {
    final selectedCourse = state.selectedCourse;
    final selectedCourseLabel = selectedCourse == null
        ? l10n.allCourses
        : '${selectedCourse.code} • ${selectedCourse.name}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _StudentLabColors.card(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _StudentLabColors.border(isDark).withValues(alpha: 0.72),
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
                    color: _StudentLabColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$visibleCount ${l10n.labs}',
                    style: const TextStyle(
                      color: _StudentLabColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: context.read<LabsCubit>().setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search labs, instructions, or courses...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _StudentLabColors.primary,
                ),
                filled: true,
                fillColor: isDark
                    ? _StudentLabColors.surface(isDark).withValues(alpha: 0.75)
                    : _StudentLabColors.surface(isDark),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: _StudentLabColors.border(
                      isDark,
                    ).withValues(alpha: 0.9),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: _StudentLabColors.border(
                      isDark,
                    ).withValues(alpha: 0.9),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  borderSide: BorderSide(
                    color: _StudentLabColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                      context.read<LabsCubit>().selectCourse(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernDropdown<LabsDisplayStatus?>(
                    isDark: isDark,
                    label: l10n.status,
                    selectedLabel: _filterLabel(state.filter.status),
                    value: state.filter.status,
                    icon: Icons.tune_rounded,
                    menuMaxHeight: responsive.screenHeight * 0.45,
                    items: <DropdownMenuItem<LabsDisplayStatus?>>[
                      DropdownMenuItem<LabsDisplayStatus?>(
                        value: null,
                        child: Text(l10n.all),
                      ),
                      ...LabsDisplayStatus.values.map((status) {
                        return DropdownMenuItem<LabsDisplayStatus?>(
                          value: status,
                          child: Text(status.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      context.read<LabsCubit>().setFilter(
                        state.filter.copyWith(
                          status: value,
                          clearStatus: value == null,
                        ),
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
          color: _StudentLabColors.textSecondary(isDark),
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
            ? _StudentLabColors.surface(isDark).withValues(alpha: 0.75)
            : _StudentLabColors.surface(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: _StudentLabColors.border(isDark).withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: _StudentLabColors.border(isDark).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _StudentLabColors.primary,
            width: 1.4,
          ),
        ),
      ),
      dropdownColor: _StudentLabColors.card(isDark),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _StudentLabColors.primary,
      ),
      style: TextStyle(
        color: _StudentLabColors.textPrimary(isDark),
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
                    Icon(icon, size: 18, color: _StudentLabColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _StudentLabColors.textPrimary(isDark),
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
    LabsState state,
    int courseId,
    List<LabModel> labs,
  ) {
    CourseModel? course;
    for (final item in state.enrolledCourses) {
      if (item.id == courseId) {
        course = item;
        break;
      }
    }

    final courseCode = course?.code ?? labs.first.course?.code ?? 'LAB';
    final courseName = course?.name ?? labs.first.course?.name ?? 'Course';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _StudentLabColors.card(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _StudentLabColors.border(isDark).withValues(alpha: 0.6),
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
                  _StudentLabColors.primary.withValues(
                    alpha: isDark ? 0.28 : 0.12,
                  ),
                  _StudentLabColors.info.withValues(
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
                    color: _StudentLabColors.info,
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
                          color: _StudentLabColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        courseName,
                        style: TextStyle(
                          color: _StudentLabColors.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _StudentLabColors.success.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${labs.length} ${labs.length == 1 ? "Lab" : l10n.labs}',
                    style: const TextStyle(
                      color: _StudentLabColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...labs.asMap().entries.map((entry) {
            final index = entry.key;
            final lab = entry.value;
            return Column(
              children: <Widget>[
                _buildLabCard(context, isDark, l10n, lab),
                if (index != labs.length - 1)
                  Divider(
                    height: 1,
                    color: _StudentLabColors.border(
                      isDark,
                    ).withValues(alpha: 0.55),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLabCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabModel lab,
  ) {
    final responsive = context.responsive;
    final submissionState = _submissionLabel(lab);
    final statusColor = _statusColor(lab);

    return InkWell(
      onTap: () => _openLabDetails(
        context,
        lab,
        context.read<LabsCubit>().state.enrolledCourses,
      ),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _StudentLabColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.science_rounded,
                    color: _StudentLabColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lab.title,
                        style: TextStyle(
                          color: _StudentLabColors.textPrimary(isDark),
                          fontSize: responsive.fontSize16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lab.description?.trim().isNotEmpty == true
                            ? lab.description!.trim()
                            : 'Hands-on work, instructions, and submission details are ready inside.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _StudentLabColors.textSecondary(isDark),
                          fontSize: responsive.fontSize13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    submissionState,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _metaPill(
                    icon: Icons.calendar_today_rounded,
                    text: lab.formattedDueDate,
                    isDark: isDark,
                  ),
                  _metaPill(
                    icon: Icons.stars_rounded,
                    text: '${lab.maxScore.toStringAsFixed(0)} pts',
                    isDark: isDark,
                  ),
                  _metaPill(
                    icon: Icons.percent_rounded,
                    text: '${lab.weight.toStringAsFixed(0)}% weight',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openLabDetails(
                      context,
                      lab,
                      context.read<LabsCubit>().state.enrolledCourses,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _StudentLabColors.primary,
                      side: BorderSide(
                        color: _StudentLabColors.primary.withValues(
                          alpha: 0.26,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openLabDetails(
                      context,
                      lab,
                      context.read<LabsCubit>().state.enrolledCourses,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _StudentLabColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      lab.isAcceptingSubmissions
                          ? Icons.upload_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      lab.isAcceptingSubmissions ? 'Submit Work' : 'Open Lab',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaPill({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: _StudentLabColors.textSecondary(isDark)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: _StudentLabColors.textSecondary(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
    return _buildFillStateScaffold(
      context,
      icon: Icons.school_outlined,
      title: 'No enrolled courses found',
      message: 'Enroll in a course to view available labs.',
      isDark: isDark,
      actionLabel: null,
      onTap: null,
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return _buildFillStateScaffold(
      context,
      icon: Icons.error_outline_rounded,
      title: l10n.errorOccurred,
      message: context.read<LabsCubit>().state.error ?? 'Failed to load labs.',
      isDark: isDark,
      actionLabel: l10n.tryAgain,
      onTap: () => context.read<LabsCubit>().loadEnrolledCourses(
        preselectedCourseId: widget.preselectedCourseId,
      ),
      iconColor: _StudentLabColors.error,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    LabsState state,
  ) {
    return _buildFillStateScaffold(
      context,
      icon: Icons.science_outlined,
      title: 'No labs available',
      message:
          state.searchQuery.trim().isNotEmpty || state.filter.hasActiveFilters
          ? 'Try a different search or reset the current filters.'
          : l10n.noLabsDescription,
      isDark: isDark,
      actionLabel:
          state.searchQuery.trim().isNotEmpty || state.filter.hasActiveFilters
          ? 'Clear filters'
          : null,
      onTap:
          state.searchQuery.trim().isNotEmpty || state.filter.hasActiveFilters
          ? () {
              _searchController.clear();
              context.read<LabsCubit>().setSearchQuery('');
              context.read<LabsCubit>().clearFilters();
            }
          : null,
    );
  }

  Widget _buildFillStateScaffold(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required bool isDark,
    required String? actionLabel,
    required VoidCallback? onTap,
    Color? iconColor,
  }) {
    final responsive = context.responsive;
    final resolvedIconColor = iconColor ?? _StudentLabColors.primary;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(responsive.p24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: responsive.p80,
                height: responsive.p80,
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: responsive.fontSize40,
                  color: resolvedIconColor,
                ),
              ),
              SizedBox(height: responsive.p18),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize20,
                  fontWeight: FontWeight.w800,
                  color: _StudentLabColors.textPrimary(isDark),
                ),
              ),
              SizedBox(height: responsive.p8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: _StudentLabColors.textSecondary(isDark),
                  height: 1.45,
                ),
              ),
              if (actionLabel != null && onTap != null) ...<Widget>[
                SizedBox(height: responsive.p20),
                FilledButton.icon(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _StudentLabColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p18,
                      vertical: responsive.p12,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _studentHeroTitle(AppLocalizations l10n) => 'Lab Sprint';

  String _studentHeroSubtitle() =>
      'Track upcoming experiments, review instructions, and submit lab work without losing momentum.';

  String _courseInitials(String code) {
    final compact = code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (compact.length <= 4) {
      return compact.toUpperCase();
    }
    return compact.substring(0, 4).toUpperCase();
  }

  String _filterLabel(LabsDisplayStatus? status) {
    return status?.label ?? 'All States';
  }

  String _submissionLabel(LabModel lab) {
    if (lab.status.name == 'closed') {
      return 'Completed';
    }
    if (lab.status.name == 'archived') {
      return 'Missed';
    }
    if (lab.isPastDue) {
      return 'In review';
    }
    return 'Open';
  }

  Color _statusColor(LabModel lab) {
    if (lab.status.name == 'closed') {
      return _StudentLabColors.success;
    }
    if (lab.status.name == 'archived') {
      return _StudentLabColors.error;
    }
    if (lab.isPastDue) {
      return _StudentLabColors.warning;
    }
    return _StudentLabColors.primary;
  }

  Future<void> _openLabDetails(
    BuildContext context,
    LabModel lab,
    List<CourseModel> enrolledCourses,
  ) async {
    final labsCubit = context.read<LabsCubit>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabDetailScreen(
          labId: lab.id,
          labService: labsCubit.labService,
          enrollmentService: labsCubit.enrollmentService,
          lab: lab,
          enrolledCourses: enrolledCourses,
        ),
      ),
    );
  }
}

void _leaveStudentAcademicScreen(BuildContext context) {
  safeBack(context, '/dashboard');
}

class _StudentLabColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static Color background(bool isDark) {
    return isDark ? AppTheme.darkSurfaceColor : const Color(0xFFF8FAFC);
  }

  static Color card(bool isDark) {
    return isDark ? const Color(0xFF111827) : Colors.white;
  }

  static Color surface(bool isDark) {
    return isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);
  }

  static Color border(bool isDark) {
    return isDark ? const Color(0xFF334155) : const Color(0xFFD9E2F0);
  }

  static Color textPrimary(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF0F172A);
  }

  static Color textSecondary(bool isDark) {
    return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  }
}
