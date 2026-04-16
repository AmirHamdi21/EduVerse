import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/utils/student_course_filters.dart';
import '../../common/utils/student_courses_theme.dart';
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
  // ── Local filter/sort/search state ─────────────────────────────────────
  String _selectedFilter = 'all';
  String _selectedSort = 'title_asc';
  String _searchQuery = '';
  int? _selectedSemesterId;

  @override
  void initState() {
    super.initState();
    context.read<CoursesBloc>().add(
      StudentCoursesFetched(semester: _selectedSemesterId),
    );
  }

  List<CourseEnrollmentModel> _applyFiltersAndSort(
    List<CourseEnrollmentModel> enrollments,
  ) {
    return StudentCourseFilters.applyCourseFiltersAndSort(
      enrollments: enrollments,
      query: _searchQuery,
      selectedStatus: _selectedFilter,
      sortKey: _selectedSort,
      selectedSemesterId: _selectedSemesterId,
    );
  }

  List<CourseEnrollmentModel> _enrollmentsFromState(CoursesState state) {
    if (state is CoursesLoaded) {
      return state.enrollments;
    }
    if (state is CoursesLoading) {
      return state.cachedData.whereType<CourseEnrollmentModel>().toList();
    }
    return <CourseEnrollmentModel>[];
  }

  void _ensureSemesterSelectionIsValid(List<SemesterFilterOption> options) {
    if (_selectedSemesterId == null) {
      return;
    }

    final bool stillExists = options.any(
      (SemesterFilterOption option) => option.id == _selectedSemesterId,
    );

    if (!stillExists && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedSemesterId = null;
        });
      });
    }
  }

  void _retryStudentFetch() {
    context.read<CoursesBloc>().add(
      StudentCoursesFetched(semester: _selectedSemesterId),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilter = 'all';
      _searchQuery = '';
      _selectedSemesterId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          floatingActionButton: const JoinCourseButton(),
          backgroundColor: StudentCoursesTheme.scaffoldBackground(isDark),
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
                      onPressed: _retryStudentFetch,
                    ),
                  ),
                );
              }

              if (state is CoursesAuthSessionRequired) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(fontSize: 13),
                    ),
                    backgroundColor: const Color(0xFFB45309),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }

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
            child: BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                final List<SemesterFilterOption> semesterOptions =
                    StudentCourseFilters.deriveSemesterOptions(
                      _enrollmentsFromState(state),
                    );
                _ensureSemesterSelectionIsValid(semesterOptions);

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
                                  selectedSemesterId: _selectedSemesterId,
                                  semesterOptions: semesterOptions,
                                  onFilterChanged: (filter) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                  onSemesterChanged: (semesterId) {
                                    setState(() {
                                      _selectedSemesterId = semesterId;
                                    });
                                    _retryStudentFetch();
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
                              selectedFilter: _selectedFilter,
                              onFilterChanged: (filter) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              selectedSemesterId: _selectedSemesterId,
                              semesterOptions: semesterOptions,
                              onSemesterChanged: (semesterId) {
                                setState(() {
                                  _selectedSemesterId = semesterId;
                                });
                                _retryStudentFetch();
                              },
                            ),
                            const SizedBox(height: 20),
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

  Widget _buildContent(CoursesState state, bool isDark, AppLocalizations l10n) {
    if (state is CoursesInitial ||
        (state is CoursesLoading && state.cachedData.isEmpty)) {
      return _buildSkeletonLoader(isDark);
    }

    if (state is CoursesLoading && state.cachedData.isNotEmpty) {
      final cached = state.cachedData
          .whereType<CourseEnrollmentModel>()
          .toList();
      final filtered = _applyFiltersAndSort(cached);
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

    if (state is CoursesLoaded) {
      final filtered = _applyFiltersAndSort(state.enrollments);
      if (filtered.isEmpty && state.enrollments.isEmpty) {
        return _buildEmptyState(isDark, l10n);
      }
      if (filtered.isEmpty && state.enrollments.isNotEmpty) {
        return _buildNoFilterResults(isDark, l10n);
      }
      return CoursesListView(enrollments: filtered);
    }

    if (state is CoursesAuthSessionRequired) {
      return _buildAuthSessionRequiredState(isDark, state);
    }

    if (state is CoursesError) {
      return _buildErrorState(isDark, l10n);
    }

    return _buildEmptyState(isDark, l10n);
  }

  Widget _buildSkeletonLoader(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: StudentCoursesTheme.cardBackground(isDark),
              borderRadius: StudentCoursesTheme.cardRadius,
              border: Border.all(
                color: StudentCoursesTheme.borderColor(isDark),
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

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
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
              l10n.noCoursesFound,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noCoursesFoundDescription,
              style: TextStyle(
                color: StudentCoursesTheme.mutedText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResults(bool isDark, AppLocalizations l10n) {
    final bool semesterOnly =
        _selectedSemesterId != null &&
        _searchQuery.trim().isEmpty &&
        _selectedFilter == 'all';

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
              semesterOnly
                  ? 'No courses in this semester'
                  : 'No courses match your filters',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                l10n.clearFilters,
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

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
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
              onPressed: _retryStudentFetch,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.tryAgain),
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

  Widget _buildAuthSessionRequiredState(
    bool isDark,
    CoursesAuthSessionRequired state,
  ) {
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
                    ? const Color(0xFF3A2A16)
                    : const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_clock_outlined,
                size: 40,
                color: isDark
                    ? const Color(0xFFFCD34D)
                    : const Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Session Required',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                color: StudentCoursesTheme.mutedText(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _retryStudentFetch,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Re-authenticate'),
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
