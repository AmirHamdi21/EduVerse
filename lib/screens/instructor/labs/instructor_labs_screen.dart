import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/instructor/instructor_labs_cubit.dart';
import '../../../bloc/instructor/instructor_labs_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/labs/lab_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/storage_service.dart';
import '../../shared/lab_editor_screen.dart';
import '../../../widgets/instructor/labs/lab_create_form.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/shared/modern_action_sheet.dart';

class InstructorLabsScreen extends StatelessWidget {
  const InstructorLabsScreen({
    super.key,
    this.labService,
    this.enrollmentService,
    this.storageService,
    this.canManageLabs = true,
    this.initialCourseId,
  });

  final LabService? labService;
  final EnrollmentService? enrollmentService;
  final StorageService? storageService;
  final bool canManageLabs;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    final resolvedStorage = storageService ?? StorageService();
    final coreApiClient = CoreApiClient(storageService: resolvedStorage);

    final resolvedLabService =
        labService ?? LabService(coreApiClient: coreApiClient);
    final resolvedEnrollmentService =
        enrollmentService ?? EnrollmentService(coreApiClient: coreApiClient);

    return BlocProvider<InstructorLabsCubit>(
      create: (_) => InstructorLabsCubit(
        labService: resolvedLabService,
        enrollmentService: resolvedEnrollmentService,
      )..initialize(preferredCourseId: initialCourseId),
      child: _InstructorLabsView(
        canManageLabs: canManageLabs,
        storageService: resolvedStorage,
      ),
    );
  }
}

enum _InstructorLabStateFilter { all, active, draft, closed, archived }

class _InstructorLabsView extends StatefulWidget {
  const _InstructorLabsView({
    required this.canManageLabs,
    required this.storageService,
  });

  final bool canManageLabs;
  final StorageService storageService;

  @override
  State<_InstructorLabsView> createState() => _InstructorLabsViewState();
}

class _InstructorLabsViewState extends State<_InstructorLabsView> {
  bool _resolvedCanManage = false;

  @override
  void initState() {
    super.initState();
    _resolveRoleAccess();
  }

  @override
  void didUpdateWidget(covariant _InstructorLabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storageService != widget.storageService ||
        oldWidget.canManageLabs != widget.canManageLabs) {
      _resolveRoleAccess();
    }
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await widget.storageService.getUserData();
      final roleNames = user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (!mounted) {
        return;
      }

      setState(() {
        if (roleNames.isEmpty) {
          _resolvedCanManage = widget.canManageLabs;
        } else {
          _resolvedCanManage = roleNames.contains('instructor');
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _resolvedCanManage = widget.canManageLabs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return BlocConsumer<InstructorLabsCubit, InstructorLabsState>(
          listener: (context, state) {
            if (state is InstructorLabsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<InstructorLabsCubit>();

            return Scaffold(
              backgroundColor: InstructorColors.background(isDark),
              floatingActionButton: _resolvedCanManage &&
                      state is InstructorLabsLoaded
                  ? FloatingActionButton.extended(
                      onPressed: () => _openCreateOrEditSheet(context, state),
                      backgroundColor: InstructorColors.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.taLabsCreateLab),
                    )
                  : null,
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () => cubit.loadLabs(),
                  color: InstructorColors.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(isDark, l10n),
                      if (state is InstructorLabsLoading ||
                          state is InstructorLabsInitial) ...[
                        _buildLoadingHeader(isDark, l10n),
                        _buildLoadingSkeleton(isDark),
                      ] else if (state is InstructorLabsError) ...[
                        SliverFillRemaining(
                          child: _buildErrorState(isDark, l10n, state.message),
                        ),
                      ] else ...[
                        _buildLoadedContent(
                          context,
                          isDark,
                          l10n,
                          state as InstructorLabsLoaded,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
        l10n.taLabsTitle,
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
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

  SliverMainAxisGroup _buildLoadedContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    InstructorLabsLoaded state,
  ) {
    final r = context.responsive;
    final selectedStateFilter = _stateFilterFromString(state.selectedStatus);
    final labs = state.filteredLabs;
    final groupedLabs = <int, List<LabModel>>{};

    for (final lab in labs) {
      groupedLabs.putIfAbsent(lab.courseId, () => <LabModel>[]).add(lab);
    }

    final showAllAssignedCourses = state.selectedCourseId == null &&
        selectedStateFilter == _InstructorLabStateFilter.all;
    final courseIds = _resolveVisibleCourseIds(
      grouped: groupedLabs,
      teachingCourses: state.teachingCourses,
      selectedCourseId: state.selectedCourseId,
      showAllAssignedCourses: showAllAssignedCourses,
    );

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryHeader(isDark, l10n, r, state)),
        SliverToBoxAdapter(child: _buildFilterMenus(isDark, l10n, r, state)),
        if (courseIds.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(
              isDark,
              l10n,
              canManage: _resolvedCanManage,
              onCreate: _resolvedCanManage
                  ? () => _openCreateOrEditSheet(context, state)
                  : null,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final courseId = courseIds[index];
                return _buildCourseLabsCard(
                  context,
                  courseId,
                  groupedLabs[courseId] ?? const <LabModel>[],
                  isDark,
                  l10n,
                  state.teachingCourses,
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
                  onPressed: state.isLoadingMore
                      ? null
                      : () => context.read<InstructorLabsCubit>().loadMore(),
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
                  child: state.isLoadingMore
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.taLabsLoadMore),
                ),
              ),
            ),
          ),
      ],
    );
  }

  SliverToBoxAdapter _buildLoadingHeader(bool isDark, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: isDark
              ? InstructorColors.darkHeaderGradient
              : InstructorColors.headerGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.instructorLabsHeaderTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.instructorLabsHeaderSubtitle,
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

  Widget _buildSummaryHeader(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    InstructorLabsLoaded state,
  ) {
    final courseCount =
        state.selectedCourseId == null ? state.teachingCourses.length : 1;
    final activeCount = state.labs.where(_isActiveLab).length;
    final draftCount =
        state.labs.where((lab) => lab.status == api.LabStatus.draft).length;
    final closedCount = state.labs
        .where(
          (lab) =>
              lab.status == api.LabStatus.closed ||
              lab.status == api.LabStatus.archived,
        )
        .length;
    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.menu_book_rounded,
        label: l10n.course,
        value: '$courseCount',
        color: InstructorColors.teal,
      ),
      (
        icon: Icons.science_rounded,
        label: l10n.taLabsCount,
        value: '${state.labs.length}',
        color: InstructorColors.accent,
      ),
      (
        icon: Icons.play_circle_rounded,
        label: l10n.taLabActive,
        value: '$activeCount',
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
        label: l10n.taLabClosed,
        value: '$closedCount',
        color: InstructorColors.pink,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorColors.darkHeaderGradient
            : InstructorColors.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
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
          children: [
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          Icons.auto_graph_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.instructorLabsHeaderTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.isMobile ? 19 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.instructorLabsHeaderSubtitle,
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
        children: [
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
    InstructorLabsLoaded state,
  ) {
    String selectedCourseLabel = l10n.allCourses;
    if (state.selectedCourseId != null) {
      for (final course in state.teachingCourses) {
        if (course.courseId == state.selectedCourseId) {
          selectedCourseLabel = '${course.course.code} • ${course.course.name}';
          break;
        }
      }
    }

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                    '${state.filteredLabs.length} ${l10n.taLabsCount}',
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
              children: [
                Expanded(
                  child: _buildModernDropdown<int?>(
                    isDark: isDark,
                    label: l10n.course,
                    value: state.selectedCourseId,
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
                      ...state.teachingCourses.map((course) {
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
                      context.read<InstructorLabsCubit>().selectCourse(value);
                    },
                    selectedLabel: selectedCourseLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernDropdown<_InstructorLabStateFilter>(
                    isDark: isDark,
                    label: l10n.status,
                    value: _stateFilterFromString(state.selectedStatus),
                    icon: Icons.tune_rounded,
                    menuMaxHeight: r.screenHeight * 0.45,
                    items: <DropdownMenuItem<_InstructorLabStateFilter>>[
                      DropdownMenuItem<_InstructorLabStateFilter>(
                        value: _InstructorLabStateFilter.all,
                        child: Text(
                          l10n.taLabsAllStates,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<_InstructorLabStateFilter>(
                        value: _InstructorLabStateFilter.active,
                        child: Text(
                          l10n.taLabActive,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<_InstructorLabStateFilter>(
                        value: _InstructorLabStateFilter.draft,
                        child: Text(
                          l10n.draft,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<_InstructorLabStateFilter>(
                        value: _InstructorLabStateFilter.closed,
                        child: Text(
                          l10n.taLabClosed,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<_InstructorLabStateFilter>(
                        value: _InstructorLabStateFilter.archived,
                        child: Text(
                          l10n.archived,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      context.read<InstructorLabsCubit>().filterLabs(
                            status: _stateFilterValue(value),
                          );
                    },
                    selectedLabel: _stateFilterLabel(
                      l10n,
                      _stateFilterFromString(state.selectedStatus),
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

  Widget _buildModernDropdown<T>({
    required bool isDark,
    required String label,
    required String selectedLabel,
    required T value,
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
      onChanged: onChanged,
    );
  }

  List<int> _resolveVisibleCourseIds({
    required Map<int, List<LabModel>> grouped,
    required List<TeachingCourseModel> teachingCourses,
    required int? selectedCourseId,
    required bool showAllAssignedCourses,
  }) {
    if (selectedCourseId != null) {
      return <int>[selectedCourseId];
    }
    if (showAllAssignedCourses) {
      return teachingCourses
          .map((course) => course.courseId)
          .toList(growable: false);
    }
    return grouped.keys.toList(growable: false);
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildSkeletonCourseCard(isDark);
        }, childCount: 3),
      ),
    );
  }

  Widget _buildSkeletonCourseCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _skeletonBox(isDark, width: 48, height: 48, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(isDark, width: 72, height: 12, radius: 4),
                    const SizedBox(height: 8),
                    _skeletonBox(isDark, width: 180, height: 16, radius: 5),
                  ],
                ),
              ),
              _skeletonBox(isDark, width: 64, height: 24, radius: 8),
            ],
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(
            2,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  _skeletonBox(isDark, width: 40, height: 40, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _skeletonBox(
                          isDark,
                          width: double.infinity,
                          height: 14,
                          radius: 4,
                        ),
                        const SizedBox(height: 8),
                        _skeletonBox(isDark, width: 140, height: 12, radius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _skeletonBox(isDark, width: 52, height: 22, radius: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(
    bool isDark, {
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE2E8F0),
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
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: InstructorColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<InstructorLabsCubit>().loadLabs(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    AppLocalizations l10n, {
    required bool canManage,
    VoidCallback? onCreate,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.science_rounded,
              size: 48,
              color: InstructorColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.taLabNoLabs,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taLabNoLabsDesc,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
          if (canManage && onCreate != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.taLabsCreateLab),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseLabsCard(
    BuildContext context,
    int courseId,
    List<LabModel> labs,
    bool isDark,
    AppLocalizations l10n,
    List<TeachingCourseModel> teachingCourses,
  ) {
    TeachingCourseModel? courseModel;
    for (final course in teachingCourses) {
      if (course.courseId == courseId) {
        courseModel = course;
        break;
      }
    }

    final fallbackCourseName = '${l10n.course} #$courseId';
    final courseName = labs.isNotEmpty
        ? (labs.first.course?.name ??
            courseModel?.course.name ??
            fallbackCourseName)
        : (courseModel?.course.name ?? fallbackCourseName);
    final courseCode = labs.isNotEmpty
        ? (labs.first.course?.code ?? courseModel?.course.code ?? '')
        : (courseModel?.course.code ?? '');
    final color = _courseColor(courseId);
    final courseInitials = _courseInitials(courseCode, courseName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: isDark ? 0.25 : 0.15),
                  color.withValues(alpha: isDark ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      courseInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (courseCode.isNotEmpty)
                        Text(
                          courseCode,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        courseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimaryColor(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${labs.length} ${l10n.taLabsCount}',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...labs.asMap().entries.map((entry) {
            final index = entry.key;
            final lab = entry.value;
            final isLast = index == labs.length - 1;

            return Column(
              children: [
                _buildLabItem(context, lab, isDark, l10n),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: InstructorColors.borderColor(
                      isDark,
                    ).withValues(alpha: 0.5),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLabItem(
    BuildContext context,
    LabModel lab,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final statusStr = lab.status.toJson();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/instructor/labs/${lab.id}'),
        onLongPress:
            _resolvedCanManage ? () => _showLabActions(l10n, lab) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        statusStr,
                      ).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.science_rounded,
                      color: _getStatusColor(statusStr),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                lab.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: InstructorColors.textPrimaryColor(
                                    isDark,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(width: 10),
                              _buildStatusBadge(statusStr, l10n),
                              if (_resolvedCanManage) ...[
                                const SizedBox(width: 2),
                                _buildLabMenuButton(isDark, l10n, lab),
                              ],
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: InstructorColors.textTertiaryColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDueDate(context, l10n, lab),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: InstructorColors.textSecondaryColor(
                                    isDark,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isCompact) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildStatusBadge(statusStr, l10n),
                              if (_resolvedCanManage) ...[
                                const Spacer(),
                                _buildLabMenuButton(isDark, l10n, lab),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabMenuButton(bool isDark, AppLocalizations l10n, LabModel lab) {
    return IconButton(
      onPressed: () => _showLabActions(l10n, lab),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: InstructorColors.textTertiaryColor(isDark),
      ),
    );
  }

  Future<void> _showLabActions(AppLocalizations l10n, LabModel lab) async {
    if (!_resolvedCanManage) {
      return;
    }

    final actions = <ModernActionItem<String>>[
      ModernActionItem<String>(
        value: 'open',
        label: l10n.labDetails,
        icon: Icons.open_in_new_rounded,
        color: InstructorColors.primary,
      ),
      ModernActionItem<String>(
        value: 'edit',
        label: l10n.edit,
        icon: Icons.edit_rounded,
        color: InstructorColors.accent,
      ),
      if (lab.status == api.LabStatus.draft)
        ModernActionItem<String>(
          value: 'publish',
          label: l10n.publish,
          icon: Icons.publish_rounded,
          color: InstructorColors.success,
        ),
      if (lab.status == api.LabStatus.published)
        ModernActionItem<String>(
          value: 'close',
          label: l10n.close,
          icon: Icons.lock_outline_rounded,
          color: InstructorColors.warning,
        ),
      if (lab.status == api.LabStatus.closed)
        ModernActionItem<String>(
          value: 'archive',
          label: l10n.archive,
          icon: Icons.archive_outlined,
          color: InstructorColors.textSecondary,
        ),
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
      title: lab.title,
      accentColor: _getStatusColor(lab.status.toJson()),
      actions: actions,
    );

    if (!mounted || value == null) {
      return;
    }

    if (value == 'open') {
      context.push('/instructor/labs/${lab.id}');
      return;
    }

    if (value == 'edit') {
      final currentState = context.read<InstructorLabsCubit>().state;
      if (currentState is InstructorLabsLoaded) {
        await _openCreateOrEditSheet(context, currentState, existingLab: lab);
      }
      return;
    }

    if (value == 'delete') {
      _confirmDelete(context, lab, l10n);
    } else if (value == 'publish') {
      _updateLabStatus(lab, api.LabStatus.published);
    } else if (value == 'close') {
      _updateLabStatus(lab, api.LabStatus.closed);
    } else if (value == 'archive') {
      _updateLabStatus(lab, api.LabStatus.archived);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return InstructorColors.success;
      case 'draft':
        return InstructorColors.info;
      case 'closed':
      case 'archived':
        return InstructorColors.textSecondary;
      default:
        return InstructorColors.primary;
    }
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    final color = _getStatusColor(status);
    String label;

    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        label = l10n.taLabActive;
        break;
      case 'closed':
        label = l10n.taLabClosed;
        break;
      case 'archived':
        label = l10n.archived;
        break;
      case 'draft':
        label = l10n.draft;
        break;
      default:
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _courseColor(int courseId) {
    const colors = [
      InstructorColors.primary,
      InstructorColors.teal,
      InstructorColors.warning,
      InstructorColors.accent,
      InstructorColors.info,
    ];
    return colors[courseId % colors.length];
  }

  String _formatDueDate(
    BuildContext context,
    AppLocalizations l10n,
    LabModel lab,
  ) {
    if (lab.dueDate == null) {
      return l10n.taLabNoDueDate;
    }

    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_jm().format(lab.dueDate!.toLocal());
  }

  String _courseInitials(String courseCode, String courseName) {
    final codeLetters =
        courseCode.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
    if (codeLetters.isNotEmpty) {
      return codeLetters.length <= 3
          ? codeLetters
          : codeLetters.substring(0, 3);
    }

    final words = courseName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (words.isEmpty) {
      return 'LAB';
    }
    return words.map((word) => word.substring(0, 1).toUpperCase()).join();
  }

  bool _isActiveLab(LabModel lab) {
    return lab.status == api.LabStatus.published;
  }

  _InstructorLabStateFilter _stateFilterFromString(String value) {
    return switch (value.trim().toLowerCase()) {
      'published' => _InstructorLabStateFilter.active,
      'draft' => _InstructorLabStateFilter.draft,
      'closed' => _InstructorLabStateFilter.closed,
      'archived' => _InstructorLabStateFilter.archived,
      _ => _InstructorLabStateFilter.all,
    };
  }

  String _stateFilterValue(_InstructorLabStateFilter filter) {
    return switch (filter) {
      _InstructorLabStateFilter.all => 'all',
      _InstructorLabStateFilter.active => 'published',
      _InstructorLabStateFilter.draft => 'draft',
      _InstructorLabStateFilter.closed => 'closed',
      _InstructorLabStateFilter.archived => 'archived',
    };
  }

  String _stateFilterLabel(
    AppLocalizations l10n,
    _InstructorLabStateFilter filter,
  ) {
    return switch (filter) {
      _InstructorLabStateFilter.all => l10n.taLabsAllStates,
      _InstructorLabStateFilter.active => l10n.taLabActive,
      _InstructorLabStateFilter.draft => l10n.draft,
      _InstructorLabStateFilter.closed => l10n.taLabClosed,
      _InstructorLabStateFilter.archived => l10n.archived,
    };
  }

  Future<void> _openCreateOrEditSheet(
    BuildContext context,
    InstructorLabsLoaded state, {
    LabModel? existingLab,
  }) async {
    final cubit = context.read<InstructorLabsCubit>();
    final isEdit = existingLab != null;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => LabEditorScreen(
          role: LabComposerRole.instructor,
          courses: state.teachingCourses,
          existingLab: existingLab,
          onSave: (payload) {
            return isEdit
                ? cubit.updateLab(
                    existingLab.id.isNotEmpty
                        ? existingLab.id
                        : existingLab.labId.toString(),
                    payload,
                  )
                : cubit.createLab(payload);
          },
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(_labSavedMessage(l10n, result['status'])),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LabModel lab,
    AppLocalizations l10n,
  ) async {
    final cubit = context.read<InstructorLabsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.taLabDelete),
          content: Text(l10n.taLabDeleteConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final message = await cubit.deleteLab(
      lab.id.isNotEmpty ? lab.id : lab.labId.toString(),
    );

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message ?? l10n.taLabDeletedSuccess),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateLabStatus(LabModel lab, api.LabStatus status) async {
    final l10n = AppLocalizations.of(context);
    final message = await context.read<InstructorLabsCubit>().updateStatus(
          lab.id.isNotEmpty ? lab.id : lab.labId.toString(),
          status,
        );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? _labStatusSuccessMessage(l10n, status)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _labSavedMessage(AppLocalizations l10n, Object? rawStatus) {
    final status = api.LabStatus.fromString(rawStatus?.toString() ?? '');
    if (status == api.LabStatus.published) {
      return l10n.taLabsCreatedPublished;
    }
    return l10n.taLabsCreatedDraft;
  }

  String _labStatusSuccessMessage(AppLocalizations l10n, api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return l10n.taLabsPublishedSuccess;
      case api.LabStatus.closed:
        return l10n.taLabsClosedSuccess;
      case api.LabStatus.archived:
        return l10n.taLabsArchivedSuccess;
      case api.LabStatus.draft:
        return l10n.taLabsMovedToDraft;
      case api.LabStatus.unknown:
        return l10n.taLabsStatusUpdated;
    }
  }
}
