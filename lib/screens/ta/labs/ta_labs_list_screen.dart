import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/ta/ta_labs_cubit.dart';
import '../../../bloc/ta/ta_labs_state.dart';
import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/labs/lab_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/storage_service.dart';
import '../../shared/lab_editor_screen.dart';
import '../../../widgets/shared/modern_action_sheet.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/instructor/labs/lab_create_form.dart';

/// T029: TA Labs List Screen — fully refactored from mock data to TALabsCubit.
/// All mock model classes (TACourseWithLabs, TALabListItem) removed.
class TALabsListScreen extends StatefulWidget {
  const TALabsListScreen({
    super.key,
    this.initialCourseId,
    this.lockCourseSelection = false,
    this.embedded = false,
  });

  final int? initialCourseId;
  final bool lockCourseSelection;
  final bool embedded;

  @override
  State<TALabsListScreen> createState() => _TALabsListScreenState();
}

enum _TALabStateFilter { all, active, draft, closed, archived }

class _TALabsListScreenState extends State<TALabsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LabService _labService = LabService(
    coreApiClient: CoreApiClient(storageService: StorageService()),
  );
  int? _selectedCourseId;
  _TALabStateFilter _selectedStateFilter = _TALabStateFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourseId;
    // Always fetch - cubit now handles caching properly to prevent infinite loading
    context.read<TALabsCubit>().fetchTALabs();

    // T029: Ensure courses are loaded for Create Lab form dropdown (T031)
    final coursesState = context.read<TACoursesCubit>().state;
    if (coursesState.coursesStatus is TASubTabInitial) {
      context.read<TACoursesCubit>().fetchTACourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: widget.embedded
              ? null
              : TADrawer(currentRoute: '/ta/labs', isDark: isDark),
          // T031: Create Lab FAB
          floatingActionButton: widget.embedded
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openCreateLabForm(isDark),
                  backgroundColor: TAColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.taLabsCreateLab),
                ),
          body: SafeArea(
            top: !widget.embedded,
            child: BlocBuilder<TALabsCubit, TALabsState>(
              builder: (context, labsState) {
                final content = RefreshIndicator(
                  onRefresh: () => context.read<TALabsCubit>().fetchTALabs(),
                  color: TAColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      if (!widget.embedded) _buildAppBar(isDark, l10n),
                      _buildContent(isDark, l10n, labsState),
                    ],
                  ),
                );

                if (widget.embedded) {
                  return Container(
                    color: TAColors.scaffoldColor(isDark),
                    child: content,
                  );
                }

                return content;
              },
            ),
          ),
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
        l10n.taLabsTitle,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
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
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
      floating: true,
      snap: true,
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n, TALabsState state) {
    // Wrap in BlocBuilder to get TA's assigned courses for filtering
    return BlocBuilder<TACoursesCubit, TACoursesState>(
      builder: (context, coursesState) {
        final cachedLabs = context.read<TALabsCubit>().cachedLabs;
        final r = context.responsive;

        // Get TA's assigned course IDs and models
        List<TeachingCourseModel> assignedCourses = [];
        if (coursesState.coursesStatus
            is TASubTabLoaded<List<TeachingCourseModel>>) {
          assignedCourses =
              (coursesState.coursesStatus
                      as TASubTabLoaded<List<TeachingCourseModel>>)
                  .data;
        }
        final assignedCourseIds = assignedCourses
            .map((c) => c.courseId)
            .toSet();
        final allAssignedLabs = _filterLabsToAssignedCourses(
          labs: state is TALabsLoaded
              ? state.labs
              : state is TALabsLoadingWithCache
              ? state.cachedLabs
              : cachedLabs,
          assignedCourseIds: assignedCourseIds,
        );
        final visibleLabs = _applyFilters(allAssignedLabs);
        final headerSlivers = <Widget>[
          SliverToBoxAdapter(
            child: _buildSummaryHeader(
              isDark,
              l10n,
              r,
              allAssignedLabs,
              assignedCourseIds,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFilterMenus(
              isDark,
              l10n,
              r,
              assignedCourses,
              visibleLabs.length,
            ),
          ),
        ];

        // Handle full loading (no cache) - only on initial load
        if (state is TALabsLoading) {
          if (cachedLabs.isNotEmpty) {
            return SliverMainAxisGroup(
              slivers: [
                ...headerSlivers,
                _buildLabsList(
                  isDark,
                  l10n,
                  cachedLabs,
                  assignedCourses,
                  assignedCourseIds,
                  showRefreshIndicator: true,
                ),
              ],
            );
          }

          return SliverMainAxisGroup(
            slivers: [...headerSlivers, _buildLoadingSkeleton(isDark)],
          );
        }

        if (state is TALabsError) {
          return SliverMainAxisGroup(
            slivers: [
              ...headerSlivers,
              SliverFillRemaining(
                child: _buildErrorState(isDark, l10n, state.message),
              ),
            ],
          );
        }

        // Handle loading with cache - show existing labs with refresh indicator
        if (state is TALabsLoadingWithCache) {
          final filteredLabs = state.cachedLabs.where((lab) {
            return assignedCourseIds.isEmpty ||
                assignedCourseIds.contains(lab.courseId);
          }).toList();

          return SliverMainAxisGroup(
            slivers: [
              ...headerSlivers,
              _buildLabsList(
                isDark,
                l10n,
                filteredLabs,
                assignedCourses,
                assignedCourseIds,
                showRefreshIndicator: true,
              ),
            ],
          );
        }

        if (state is TALabsLoaded) {
          // Filter labs to only show those from TA's assigned courses
          final filteredLabs = state.labs.where((lab) {
            return assignedCourseIds.isEmpty ||
                assignedCourseIds.contains(lab.courseId);
          }).toList();

          return SliverMainAxisGroup(
            slivers: [
              ...headerSlivers,
              _buildLabsList(
                isDark,
                l10n,
                filteredLabs,
                assignedCourses,
                assignedCourseIds,
                showRefreshIndicator: false,
              ),
            ],
          );
        }

        if (state is TALabDetailLoading ||
            state is TALabDetailLoaded ||
            state is TALabDetailError ||
            state is TALabAttendanceRefreshing ||
            state is TALabGrading ||
            state is TALabGradeSuccess ||
            state is TALabGradeError) {
          if (cachedLabs.isNotEmpty) {
            return SliverMainAxisGroup(
              slivers: [
                ...headerSlivers,
                _buildLabsList(
                  isDark,
                  l10n,
                  cachedLabs,
                  assignedCourses,
                  assignedCourseIds,
                  showRefreshIndicator: false,
                ),
              ],
            );
          }

          return SliverMainAxisGroup(
            slivers: [...headerSlivers, _buildLoadingSkeleton(isDark)],
          );
        }

        // Initial state - show loading if no courses loaded yet
        return SliverMainAxisGroup(
          slivers: [...headerSlivers, _buildLoadingSkeleton(isDark)],
        );
      },
    );
  }

  List<LabModel> _filterLabsToAssignedCourses({
    required List<LabModel> labs,
    required Set<int> assignedCourseIds,
  }) {
    return labs
        .where((lab) {
          return assignedCourseIds.isEmpty ||
              assignedCourseIds.contains(lab.courseId);
        })
        .toList(growable: false);
  }

  Widget _buildSummaryHeader(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    List<LabModel> labs,
    Set<int> assignedCourseIds,
  ) {
    final courseCount = assignedCourseIds.isNotEmpty
        ? assignedCourseIds.length
        : labs.map((lab) => lab.courseId).toSet().length;
    final activeCount = labs.where(_isActiveLab).length;
    final draftCount = labs
        .where((lab) => lab.status == api.LabStatus.draft)
        .length;
    final closedCount = labs
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
        color: TAColors.teal,
      ),
      (
        icon: Icons.science_rounded,
        label: l10n.taLabsCount,
        value: '${labs.length}',
        color: TAColors.secondary,
      ),
      (
        icon: Icons.play_circle_rounded,
        label: l10n.taLabActive,
        value: '$activeCount',
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
        label: l10n.taLabClosed,
        value: '$closedCount',
        color: TAColors.pink,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: isDark
            ? TAColors.darkHeaderGradient
            : TAColors.headerGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
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
              padding: EdgeInsets.all(r.isMobile ? 16 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.taLabsHeaderTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.isMobile ? 18 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l10n.taLabsHeaderSubtitle,
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
                      final spacing = 8.0;
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
        children: [
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
    List<TeachingCourseModel> assignedCourses,
    int visibleLabsCount,
  ) {
    String selectedCourseLabel = l10n.allCourses;
    if (_selectedCourseId != null) {
      for (final course in assignedCourses) {
        if (course.courseId == _selectedCourseId) {
          selectedCourseLabel =
              '${course.course.courseCode} • ${course.course.courseName}';
          break;
        }
      }
    }

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
                    color: TAColors.primary.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$visibleLabsCount ${l10n.taLabsCount}',
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
              _buildModernDropdown<_TALabStateFilter>(
                isDark: isDark,
                label: l10n.status,
                value: _selectedStateFilter,
                icon: Icons.tune_rounded,
                menuMaxHeight: r.screenHeight * 0.45,
                items: <DropdownMenuItem<_TALabStateFilter>>[
                  DropdownMenuItem<_TALabStateFilter>(
                    value: _TALabStateFilter.all,
                    child: Text(
                      l10n.taLabsAllStates,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_TALabStateFilter>(
                    value: _TALabStateFilter.active,
                    child: Text(
                      l10n.taLabActive,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_TALabStateFilter>(
                    value: _TALabStateFilter.draft,
                    child: Text(
                      l10n.draft,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_TALabStateFilter>(
                    value: _TALabStateFilter.closed,
                    child: Text(
                      l10n.taLabClosed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem<_TALabStateFilter>(
                    value: _TALabStateFilter.archived,
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
                  setState(() => _selectedStateFilter = value);
                },
                selectedLabel: _stateFilterLabel(
                  l10n,
                  _selectedStateFilter,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildModernDropdown<int?>(
                      isDark: isDark,
                      label: l10n.course,
                      value: _selectedCourseId,
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
                        ...assignedCourses.map((course) {
                          return DropdownMenuItem<int?>(
                            value: course.courseId,
                            child: Text(
                              '${course.course.courseCode} • ${course.course.courseName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCourseId = value);
                      },
                      selectedLabel: selectedCourseLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernDropdown<_TALabStateFilter>(
                      isDark: isDark,
                      label: l10n.status,
                      value: _selectedStateFilter,
                      icon: Icons.tune_rounded,
                      menuMaxHeight: r.screenHeight * 0.45,
                      items: <DropdownMenuItem<_TALabStateFilter>>[
                        DropdownMenuItem<_TALabStateFilter>(
                          value: _TALabStateFilter.all,
                          child: Text(
                            l10n.taLabsAllStates,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<_TALabStateFilter>(
                          value: _TALabStateFilter.active,
                          child: Text(
                            l10n.taLabActive,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<_TALabStateFilter>(
                          value: _TALabStateFilter.draft,
                          child: Text(
                            l10n.draft,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<_TALabStateFilter>(
                          value: _TALabStateFilter.closed,
                          child: Text(
                            l10n.taLabClosed,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<_TALabStateFilter>(
                          value: _TALabStateFilter.archived,
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
                        setState(() => _selectedStateFilter = value);
                      },
                      selectedLabel: _stateFilterLabel(
                        l10n,
                        _selectedStateFilter,
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
          borderSide: BorderSide(color: TAColors.primary, width: 1.4),
        ),
      ),
      dropdownColor: TAColors.cardColor(isDark),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: TAColors.primary),
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

  /// Shared labs list builder - works for both loaded and cached states
  Widget _buildLabsList(
    bool isDark,
    AppLocalizations l10n,
    List<LabModel> labs,
    List<TeachingCourseModel> assignedCourses,
    Set<int> assignedCourseIds, {
    required bool showRefreshIndicator,
  }) {
    final filteredLabs = _applyFilters(labs);

    // Group labs by courseId
    final grouped = <int, List<LabModel>>{};
    for (final lab in filteredLabs) {
      grouped.putIfAbsent(lab.courseId, () => []).add(lab);
    }

    final bool showAllAssignedCourses =
        _selectedCourseId == null &&
        _selectedStateFilter == _TALabStateFilter.all;
    final courseIds = _resolveVisibleCourseIds(
      grouped: grouped,
      assignedCourseIds: assignedCourseIds,
      showAllAssignedCourses: showAllAssignedCourses,
    );

    if (courseIds.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(isDark, l10n));
    }

    final labsSliver = SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final courseId = courseIds[index];
          final courseLabs = grouped[courseId] ?? [];
          return _buildCourseLabsCard(
            courseId,
            courseLabs,
            isDark,
            l10n,
            assignedCourses,
          );
        }, childCount: courseIds.length),
      ),
    );

    if (!showRefreshIndicator) {
      return labsSliver;
    }

    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: LinearProgressIndicator(
              minHeight: 3,
              color: TAColors.primary,
            ),
          ),
        ),
        labsSliver,
      ],
    );
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
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
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

  List<int> _resolveVisibleCourseIds({
    required Map<int, List<LabModel>> grouped,
    required Set<int> assignedCourseIds,
    required bool showAllAssignedCourses,
  }) {
    if (_selectedCourseId != null) {
      return <int>[_selectedCourseId!];
    }
    if (showAllAssignedCourses && assignedCourseIds.isNotEmpty) {
      return assignedCourseIds.toList();
    }
    return grouped.keys.toList();
  }

  List<LabModel> _applyFilters(List<LabModel> labs) {
    return labs
        .where((lab) {
          final courseMatches =
              _selectedCourseId == null || lab.courseId == _selectedCourseId;
          final stateMatches = switch (_selectedStateFilter) {
            _TALabStateFilter.all => true,
            _TALabStateFilter.active => _isActiveLab(lab),
            _TALabStateFilter.draft => lab.status == api.LabStatus.draft,
            _TALabStateFilter.closed => lab.status == api.LabStatus.closed,
            _TALabStateFilter.archived => lab.status == api.LabStatus.archived,
          };

          return courseMatches && stateMatches;
        })
        .toList(growable: false);
  }

  bool _isActiveLab(LabModel lab) {
    return lab.status == api.LabStatus.published;
  }

  String _stateFilterLabel(
    AppLocalizations l10n,
    _TALabStateFilter stateFilter,
  ) {
    return switch (stateFilter) {
      _TALabStateFilter.all => l10n.taLabsAllStates,
      _TALabStateFilter.active => l10n.taLabActive,
      _TALabStateFilter.draft => l10n.draft,
      _TALabStateFilter.closed => l10n.taLabClosed,
      _TALabStateFilter.archived => l10n.archived,
    };
  }

  // T035: Empty state
  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.science_rounded,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.taLabNoLabs,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taLabNoLabsDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: TAColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<TALabsCubit>().fetchTALabs(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseLabsCard(
    int courseId,
    List<LabModel> labs,
    bool isDark,
    AppLocalizations l10n,
    List<TeachingCourseModel> assignedCourses,
  ) {
    TeachingCourseModel? courseModel;
    for (final course in assignedCourses) {
      if (course.courseId == courseId) {
        courseModel = course;
        break;
      }
    }

    final fallbackCourseName = '${l10n.course} #$courseId';
    final courseName = labs.isNotEmpty
        ? (labs.first.course?.name ??
              courseModel?.course.courseName ??
              fallbackCourseName)
        : (courseModel?.course.courseName ?? fallbackCourseName);
    final courseCode = labs.isNotEmpty
        ? (labs.first.course?.code ?? courseModel?.course.courseCode ?? '')
        : (courseModel?.course.courseCode ?? '');
    final color = _courseColor(courseId);
    final courseInitials = _courseInitials(courseCode, courseName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
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
          // Course Header
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
                          color: TAColors.textPrimaryColor(isDark),
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
          // Labs List
          ...labs.asMap().entries.map((entry) {
            final index = entry.key;
            final lab = entry.value;
            final isLast = index == labs.length - 1;

            return Column(
              children: [
                _buildLabItem(lab, isDark, l10n),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
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

  Widget _buildLabItem(LabModel lab, bool isDark, AppLocalizations l10n) {
    final statusStr = lab.status.toJson();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await context.push('/ta/lab/${lab.id}');
          if (!mounted) {
            return;
          }
          context.read<TALabsCubit>().restoreLabsList();
        },
        onLongPress: () => _showLabActions(l10n, lab),
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
                                  color: TAColors.textPrimaryColor(isDark),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(width: 10),
                              _buildStatusBadge(statusStr, l10n),
                              const SizedBox(width: 2),
                              _buildLabMenuButton(isDark, l10n, lab),
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
                              color: TAColors.textTertiaryColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDueDate(context, l10n, lab),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TAColors.textSecondaryColor(isDark),
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
                              const Spacer(),
                              _buildLabMenuButton(isDark, l10n, lab),
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
        color: TAColors.textTertiaryColor(isDark),
      ),
    );
  }

  Future<void> _showLabActions(AppLocalizations l10n, LabModel lab) async {
    final actions = <ModernActionItem<String>>[
      ModernActionItem<String>(
        value: 'open',
        label: l10n.labDetails,
        icon: Icons.open_in_new_rounded,
        color: TAColors.primary,
      ),
      ModernActionItem<String>(
        value: 'edit',
        label: l10n.edit,
        icon: Icons.edit_rounded,
        color: TAColors.accent,
      ),
      if (lab.status == api.LabStatus.draft)
        ModernActionItem<String>(
          value: 'publish',
          label: l10n.publish,
          icon: Icons.publish_rounded,
          color: TAColors.success,
        ),
      if (lab.status == api.LabStatus.published)
        ModernActionItem<String>(
          value: 'close',
          label: l10n.close,
          icon: Icons.lock_outline_rounded,
          color: TAColors.warning,
        ),
      if (lab.status == api.LabStatus.closed)
        ModernActionItem<String>(
          value: 'archive',
          label: l10n.archive,
          icon: Icons.archive_outlined,
          color: TAColors.textSecondary,
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
      title: lab.title,
      accentColor: _getStatusColor(lab.status.toJson()),
      actions: actions,
    );

    if (!mounted || value == null) {
      return;
    }

    if (value == 'open') {
      await context.push('/ta/lab/${lab.id}');
      if (!mounted) {
        return;
      }
      context.read<TALabsCubit>().restoreLabsList();
      return;
    }

    if (value == 'edit') {
      await _openEditLabForm(l10n, lab);
      return;
    }

    if (value == 'delete') {
      _confirmDeleteLab(lab, l10n);
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
        return TAColors.success;
      case 'draft':
        return TAColors.info;
      case 'closed':
      case 'archived':
        return TAColors.textSecondary;
      default:
        return TAColors.primary;
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
      TAColors.primary,
      TAColors.teal,
      TAColors.warning,
      TAColors.info,
      TAColors.success,
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
    final codeLetters = courseCode
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase();
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

  // T031: Open Create Lab form
  Future<void> _openCreateLabForm(bool _) async {
    final l10n = AppLocalizations.of(context);
    final coursesState = context.read<TACoursesCubit>().state;
    final courses =
        coursesState.coursesStatus is TASubTabLoaded<List<TeachingCourseModel>>
        ? (coursesState.coursesStatus
                  as TASubTabLoaded<List<TeachingCourseModel>>)
              .data
        : <TeachingCourseModel>[];

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.taLabsCoursesLoading),
          backgroundColor: TAColors.warning,
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => LabEditorScreen(
          role: LabComposerRole.ta,
          courses: courses,
          onSave: (data) => context.read<TALabsCubit>().createLab(data),
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_labSavedMessage(result['status']?.toString())),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  Future<void> _openEditLabForm(AppLocalizations l10n, LabModel lab) async {
    final coursesState = context.read<TACoursesCubit>().state;
    final courses =
        coursesState.coursesStatus is TASubTabLoaded<List<TeachingCourseModel>>
        ? (coursesState.coursesStatus
                  as TASubTabLoaded<List<TeachingCourseModel>>)
              .data
        : <TeachingCourseModel>[];

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.taLabsCoursesLoading),
          backgroundColor: TAColors.warning,
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => LabEditorScreen(
          role: LabComposerRole.ta,
          courses: courses,
          existingLab: lab,
          onSave: (data) async {
            final response = await _labService.update(lab.id, data);
            if (!response.isSuccess) {
              return response.error?.message ?? l10n.taLabPermissionEditDenied;
            }
            return null;
          },
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    context.read<TALabsCubit>().fetchTALabs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_labSavedMessage(result['status']?.toString())),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  // T033: Delete lab from list
  void _confirmDeleteLab(LabModel lab, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.taLabDelete),
        content: Text(l10n.taLabDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TALabsCubit>().deleteLab(lab.id);
            },
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLabStatus(LabModel lab, api.LabStatus status) async {
    final message = await context.read<TALabsCubit>().updateLabStatus(
      lab.id.isNotEmpty ? (int.tryParse(lab.id) ?? lab.id) : lab.labId,
      status,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? _labStatusSuccessMessage(status)),
        backgroundColor: message == null ? TAColors.success : TAColors.error,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  String _labSavedMessage(String? rawStatus) {
    final l10n = AppLocalizations.of(context);
    final status = api.LabStatus.fromString(rawStatus ?? '');
    if (status == api.LabStatus.published) {
      return l10n.taLabsCreatedPublished;
    }
    return l10n.taLabsCreatedDraft;
  }

  String _labStatusSuccessMessage(api.LabStatus status) {
    final l10n = AppLocalizations.of(context);
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
