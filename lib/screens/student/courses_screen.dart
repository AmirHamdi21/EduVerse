import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/courses/courses_bloc.dart';
import '../../bloc/courses/courses_event.dart';
import '../../bloc/courses/courses_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/core/enrollment_model.dart';
import '../../widgets/student/courses/course_filter_bar.dart';
import '../../widgets/student/courses/course_search_bar.dart';
import '../../widgets/student/courses/courses_list_view.dart';
import '../../widgets/student/courses/courses_header.dart';
import '../../widgets/student/courses/join_course_button.dart';
import '../../widgets/student/courses/filter_button.dart';
import '../../widgets/student/courses/sort_button.dart';

/// Student courses screen consuming live data from [CoursesBloc].
///
/// Replaces the static mock-data approach with BLoC-driven state management.
/// Handles loading, loaded, error, and offline-cache states gracefully.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // ── Local filter/sort/search state (US2 support) ─────────────────────
  String _selectedFilter = 'all';
  String _selectedSort = 'title_asc';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // T008: Dispatch the fetch event to load live courses from backend.
    context.read<CoursesBloc>().add(const StudentCoursesFetched());
  }

  // ── In-memory filter/sort helpers (T012, T013) ───────────────────────

  List<CourseEnrollmentModel> _applyFilters(
    List<CourseEnrollmentModel> enrollments,
  ) {
    var filtered = enrollments.where((enrollment) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          (enrollment.course?.courseName ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (enrollment.course?.courseCode ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (enrollment.course?.departmentName ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Status filter — backend sends 'enrolled' which maps to 'active' in UI
      final statusLower = enrollment.status.toLowerCase();
      final matchesFilter =
          _selectedFilter == 'all' ||
          (_selectedFilter == 'completed' && statusLower == 'completed') ||
          (_selectedFilter == 'active' &&
              (statusLower == 'active' || statusLower == 'enrolled')) ||
          (_selectedFilter == 'dropped' && statusLower == 'dropped');

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort
    _sortEnrollments(filtered);

    return filtered;
  }

  void _sortEnrollments(List<CourseEnrollmentModel> enrollments) {
    switch (_selectedSort) {
      case 'title_asc':
        enrollments.sort(
          (a, b) => (a.course?.courseName ?? '').compareTo(
            b.course?.courseName ?? '',
          ),
        );
        break;
      case 'title_desc':
        enrollments.sort(
          (a, b) => (b.course?.courseName ?? '').compareTo(
            a.course?.courseName ?? '',
          ),
        );
        break;
      case 'credits_desc':
        enrollments.sort(
          (a, b) => (b.course?.credits ?? 0).compareTo(a.course?.credits ?? 0),
        );
        break;
      case 'credits_asc':
        enrollments.sort(
          (a, b) => (a.course?.credits ?? 0).compareTo(b.course?.credits ?? 0),
        );
        break;
      case 'date':
        enrollments.sort(
          (a, b) => b.enrollmentDate.compareTo(a.enrollmentDate),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          floatingActionButton: const JoinCourseButton(),
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          // T007: BlocListener for offline Snackbar warnings
          body: BlocListener<CoursesBloc, CoursesState>(
            listener: (context, state) {
              if (state is CoursesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message.isNotEmpty
                                ? state.message
                                : 'Unable to load courses. Please check your connection.',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'RETRY',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<CoursesBloc>().add(
                          const StudentCoursesFetched(),
                        );
                      },
                    ),
                  ),
                );
              }
              // Show offline-cache Snackbar when loading with cached data
              if (state is CoursesLoading && state.cachedData.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Offline: Showing cached data',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            // T004: Wrap content with BlocBuilder<CoursesBloc, CoursesState>
            child: BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                return SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            CoursesHeader(
                              title: l10n.myCoursesHeader,
                              subtitle: l10n.allEnrolledCoursesThisSemester,
                            ),
                            const SizedBox(height: 16),
                            CourseSearchBar(
                              onSearchChanged: (query) {
                                setState(() {
                                  _searchQuery = query;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FilterButton(
                                  selectedFilter: _selectedFilter,
                                  onFilterChanged: (filter) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                ),
                                const SizedBox(width: 12),
                                SortButton(
                                  selectedSort: _selectedSort,
                                  onSortChanged: (sort) {
                                    setState(() {
                                      _selectedSort = sort;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CourseFilterBar(
                              onFilterChanged: (filter) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            // ── State-driven content ─────────────────
                            _buildContent(state, isDark, l10n),
                            const SizedBox(height: 32),
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
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

  /// Renders content based on the current [CoursesState].
  Widget _buildContent(CoursesState state, bool isDark, AppLocalizations l10n) {
    // Loading state with no cached data → skeleton
    if (state is CoursesInitial ||
        (state is CoursesLoading && state.cachedData.isEmpty)) {
      return _buildSkeletonLoader(isDark);
    }

    // Loading state WITH cached data → show cached list with subtle indicator
    if (state is CoursesLoading && state.cachedData.isNotEmpty) {
      final cached = state.cachedData
          .whereType<CourseEnrollmentModel>()
          .toList();
      final filtered = _applyFilters(cached);
      return Column(
        children: [
          const LinearProgressIndicator(
            minHeight: 2,
            color: Color(0xFF155DFC),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 8),
          CoursesListView(enrollments: filtered),
        ],
      );
    }

    // Loaded state → show live data
    if (state is CoursesLoaded) {
      final filtered = _applyFilters(state.enrollments);
      if (filtered.isEmpty && state.enrollments.isNotEmpty) {
        // Filter produced no results
        return _buildNoFilterResults(isDark);
      }
      return CoursesListView(enrollments: filtered);
    }

    // Error state → show error UI
    if (state is CoursesError) {
      return _buildErrorState(isDark);
    }

    // Fallback
    return _buildEmptyState(isDark);
  }

  /// Skeleton loader cards while initial fetch is in progress.
  Widget _buildSkeletonLoader(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFD1D5DC),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _shimmerBox(64, 64, isDark, radius: 16),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(double.infinity, 16, isDark),
                            const SizedBox(height: 8),
                            _shimmerBox(120, 12, isDark),
                            const SizedBox(height: 8),
                            _shimmerBox(80, 10, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _shimmerBox(
                          double.infinity,
                          40,
                          isDark,
                          radius: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _shimmerBox(
                          double.infinity,
                          40,
                          isDark,
                          radius: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(
    double width,
    double height,
    bool isDark, {
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Empty state when there are genuinely no courses.
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A3F5F)
                    : const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 40,
                color: isDark
                    ? Colors.white30
                    : const Color(0xFF155DFC).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Courses Yet',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enroll in courses to get started',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF667085),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// State when filters return no matching results.
  Widget _buildNoFilterResults(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 48,
              color: isDark ? Colors.white30 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No courses match your filters',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'all';
                  _searchQuery = '';
                });
              },
              child: const Text(
                'Clear Filters',
                style: TextStyle(
                  color: Color(0xFF155DFC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state with retry action.
  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3D2020)
                    : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: isDark
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Error',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load your courses.',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF667085),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CoursesBloc>().add(const StudentCoursesFetched());
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF155DFC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
