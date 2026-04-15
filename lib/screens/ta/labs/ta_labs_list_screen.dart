import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/ta/ta_labs_cubit.dart';
import '../../../bloc/ta/ta_labs_state.dart';
import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../models/labs/lab_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/instructor/labs/lab_create_form.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';

/// T029: TA Labs List Screen — fully refactored from mock data to TALabsCubit.
/// All mock model classes (TACourseWithLabs, TALabListItem) removed.
class TALabsListScreen extends StatefulWidget {
  const TALabsListScreen({super.key});

  @override
  State<TALabsListScreen> createState() => _TALabsListScreenState();
}

class _TALabsListScreenState extends State<TALabsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
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
          drawer: TADrawer(currentRoute: '/ta/labs', isDark: isDark),
          // T031: Create Lab FAB
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openCreateLabForm(isDark),
            backgroundColor: TAColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Lab'),
          ),
          body: SafeArea(
            child: BlocBuilder<TALabsCubit, TALabsState>(
              builder: (context, labsState) {
                return RefreshIndicator(
                  onRefresh: () => context.read<TALabsCubit>().fetchTALabs(),
                  color: TAColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(isDark, l10n),
                      _buildFilterChips(isDark, l10n),
                      _buildContent(isDark, l10n, labsState),
                    ],
                  ),
                );
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

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildFilterChip(
              label: l10n.taLabFilterAll,
              value: 'all',
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n.taLabFilterActive,
              value: 'active',
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n.taLabFilterPendingReview,
              value: 'pending',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? TAColors.primary : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n, TALabsState state) {
    // Wrap in BlocBuilder to get TA's assigned courses for filtering
    return BlocBuilder<TACoursesCubit, TACoursesState>(
      builder: (context, coursesState) {
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

        // Handle full loading (no cache) - only on initial load
        if (state is TALabsLoading) {
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: TAColors.primary),
            ),
          );
        }

        if (state is TALabsError) {
          return SliverFillRemaining(
            child: _buildErrorState(isDark, state.message),
          );
        }

        // Handle loading with cache - show existing labs with refresh indicator
        if (state is TALabsLoadingWithCache) {
          final filteredLabs = state.cachedLabs.where((lab) {
            return assignedCourseIds.isEmpty ||
                assignedCourseIds.contains(lab.courseId);
          }).toList();

          return _buildLabsList(
            isDark,
            l10n,
            filteredLabs,
            assignedCourses,
            assignedCourseIds,
            showRefreshIndicator: true,
          );
        }

        if (state is TALabsLoaded) {
          // Filter labs to only show those from TA's assigned courses
          final filteredLabs = state.labs.where((lab) {
            return assignedCourseIds.isEmpty ||
                assignedCourseIds.contains(lab.courseId);
          }).toList();

          return _buildLabsList(
            isDark,
            l10n,
            filteredLabs,
            assignedCourses,
            assignedCourseIds,
            showRefreshIndicator: false,
          );
        }

        // Initial state - show loading if no courses loaded yet
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: TAColors.primary),
          ),
        );
      },
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
    final filteredLabs = _applyFilter(labs);

    // Group labs by courseId
    final grouped = <int, List<LabModel>>{};
    for (final lab in filteredLabs) {
      grouped.putIfAbsent(lab.courseId, () => []).add(lab);
    }

    // Show all assigned courses, even those without labs
    final courseIds = assignedCourseIds.isNotEmpty
        ? assignedCourseIds.toList()
        : grouped.keys.toList();

    if (courseIds.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(isDark, l10n));
    }

    return SliverPadding(
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
  }

  List<LabModel> _applyFilter(List<LabModel> labs) {
    if (_selectedFilter == 'all') return labs;
    if (_selectedFilter == 'active') {
      return labs.where((lab) => lab.status.toJson() == 'published').toList();
    }
    if (_selectedFilter == 'pending') {
      return labs
          .where((lab) => lab.status.toJson() == 'published' && !lab.isPastDue)
          .toList();
    }
    return labs;
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

  Widget _buildErrorState(bool isDark, String message) {
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
            label: const Text('Retry'),
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
    // Find the course model from assigned courses
    final courseModel = assignedCourses.firstWhere(
      (c) => c.courseId == courseId,
      orElse: () => assignedCourses.isNotEmpty
          ? assignedCourses.first
          : throw Exception('Course not found'),
    );

    final courseName = labs.isNotEmpty
        ? (labs.first.course?.name ?? courseModel.course.courseName)
        : courseModel.course.courseName;
    final courseCode = labs.isNotEmpty
        ? (labs.first.course?.code ?? courseModel.course.courseCode)
        : courseModel.course.courseCode;
    final color = _courseColor(courseId);

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
                      courseCode.replaceAll(RegExp(r'[^A-Z]'), ''),
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
        onTap: () => context.push('/ta/lab/${lab.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                    Text(
                      lab.title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: TAColors.textTertiaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lab.formattedDueDate,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [_buildStatusBadge(statusStr, l10n)],
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: TAColors.textTertiaryColor(isDark),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDeleteLab(lab);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 18,
                          color: TAColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: TAColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      case 'archived':
        label = l10n.taLabClosed;
        break;
      case 'draft':
        label = 'Draft';
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

  // T031: Open Create Lab form
  void _openCreateLabForm(bool isDark) {
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
          content: const Text('Courses are still loading. Please try again.'),
          backgroundColor: TAColors.warning,
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TAColors.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return LabCreateForm(
              courses: courses,
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: (data) async {
                Navigator.of(ctx).pop();
                try {
                  // T031: Resolve LabService — try provider tree, fallback to local instance
                  LabService labService;
                  try {
                    labService = context.read<LabService>();
                  } catch (_) {
                    final coreApiClient = CoreApiClient(
                      storageService: StorageService(),
                    );
                    labService = LabService(coreApiClient: coreApiClient);
                  }

                  await labService.create(data);
                  if (mounted) {
                    context.read<TALabsCubit>().fetchTALabs();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().contains('403')
                              ? "You don't have permission to create labs for this course"
                              : 'Failed to create lab: $e',
                        ),
                        backgroundColor: TAColors.error,
                        behavior: SnackBarBehavior.fixed,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  // T033: Delete lab from list
  void _confirmDeleteLab(LabModel lab) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lab'),
        content: const Text(
          'Are you sure you want to delete this lab? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TALabsCubit>().deleteLab(lab.id);
            },
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
