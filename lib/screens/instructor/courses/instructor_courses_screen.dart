import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/instructor/instructor_courses_bloc.dart';
import '../../../bloc/instructor/instructor_courses_event.dart';
import '../../../bloc/instructor/instructor_courses_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/instructor/extended_course_model.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/courses/courses_barrel.dart';

class InstructorCoursesScreen extends StatefulWidget {
  final StorageService? storageService;

  const InstructorCoursesScreen({super.key, this.storageService});

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen>
    with TickerProviderStateMixin {
  // State variables
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  CourseSortOption _sortOption = CourseSortOption.newest;
  CourseViewType _viewType = CourseViewType.grid;
  bool _isSelectionMode = false;
  final Set<String> _selectedCourses = {};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final StorageService _storageService;

  bool _hasScreenAccess = true;
  bool _canDeleteCourses = true;

  // Animation controllers
  late AnimationController _statsAnimController;
  late AnimationController _cardAnimController;
  late Animation<double> _statsAnimation;

  // Categories for filtering
  final List<String> _categories = [
    'all',
    'FRESHMAN',
    'SOPHOMORE',
    'JUNIOR',
    'SENIOR',
    'GRADUATE',
  ];

  static const Map<String, String> _levelLabels = <String, String>{
    'all': 'All Levels',
    'FRESHMAN': 'Freshman',
    'SOPHOMORE': 'Sophomore',
    'JUNIOR': 'Junior',
    'SENIOR': 'Senior',
    'GRADUATE': 'Graduate',
  };

  // Stats - computed from live BLoC state
  int _totalStudents = 0;
  List<ExtendedCourse> _courses = [];

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _statsAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsAnimController,
      curve: Curves.easeOutCubic,
    );
    _resolveRoleAccess();
    context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await _storageService.getUserData();
      final roleNames =
          user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (roleNames.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _hasScreenAccess = true;
          _canDeleteCourses = true;
        });
        return;
      }

      final hasInstructorAccess = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'ta' ||
            role == 'teaching_assistant' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      final canDelete = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasScreenAccess = hasInstructorAccess;
        _canDeleteCourses = canDelete;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasScreenAccess = true;
        _canDeleteCourses = true;
      });
    }
  }

  void _showDeletePermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Access denied: TAs cannot delete courses.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAccessDeniedState(bool isDark, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: isDark
          ? InstructorColors.darkBackground
          : InstructorColors.primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: InstructorColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Access Denied',
                style: TextStyle(
                  color: isDark ? Colors.white : InstructorColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You do not have permission to access instructor courses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : InstructorColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _statsAnimController.dispose();
    _cardAnimController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Maps backend [TeachingCourseModel] list into UI-compatible
  /// [ExtendedCourse] wrappers, populating visual fields with
  /// sensible defaults derived from backend data.
  List<ExtendedCourse> _mapToExtendedCourses(List<TeachingCourseModel> models) {
    // Deterministic color palette for visual variety
    const colorPalette = [
      0xFF0D47A1,
      0xFF7C4DFF,
      0xFF00BFA5,
      0xFFFF6D00,
      0xFFE91E63,
      0xFF536DFE,
      0xFFFFAB00,
      0xFF00C853,
    ];

    return models.asMap().entries.map((entry) {
      final idx = entry.key;
      final tc = entry.value;
      final colorValue = colorPalette[idx % colorPalette.length];
      final fillRatio = tc.section.maxCapacity > 0
          ? tc.section.currentEnrollment / tc.section.maxCapacity
          : 0.0;

      return ExtendedCourse(
        course: InstructorCourseModel(
          id: tc.courseId.toString(),
          code: tc.course.courseCode,
          name: tc.course.courseName,
          description: tc.course.description ?? '',
          totalStudents: tc.section.currentEnrollment,
          capacity: tc.section.maxCapacity,
          colorValue: colorValue,
          isActive: true,
          semester: tc.semester.name,
          assignments: const [],
          materials: const [],
          announcements: const [],
        ),
        completionRate: fillRatio.clamp(0.0, 1.0),
        engagementScore: 0,
        status: 'published',
        category: _normalizeCourseLevel(tc.course.level),
        createdAt: tc.semester.startDate ?? DateTime.now(),
        enrollmentTrend: [
          fillRatio,
          fillRatio,
          fillRatio,
          fillRatio,
          fillRatio,
          fillRatio,
          fillRatio,
        ],
      );
    }).toList();
  }

  String _normalizeCourseLevel(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized.isEmpty || normalized == 'UNKNOWN') {
      return 'UNKNOWN';
    }
    return normalized;
  }

  String _levelLabel(String level) {
    return _levelLabels[level] ?? level;
  }

  List<ExtendedCourse> get _filteredCourses {
    var result = _courses.where((c) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          c.course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.course.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.course.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Status filter
      final matchesStatus =
          _selectedStatus == 'all' || c.status == _selectedStatus;

      // Category filter
      final matchesCategory =
          _selectedCategory == 'all' || c.category == _selectedCategory;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();

    // Sort
    switch (_sortOption) {
      case CourseSortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CourseSortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CourseSortOption.mostStudents:
        result.sort(
          (a, b) => b.course.totalStudents.compareTo(a.course.totalStudents),
        );
        break;
      case CourseSortOption.leastStudents:
        result.sort(
          (a, b) => a.course.totalStudents.compareTo(b.course.totalStudents),
        );
        break;
      case CourseSortOption.alphabetical:
        result.sort((a, b) => a.course.name.compareTo(b.course.name));
        break;
      case CourseSortOption.reverseAlphabetical:
        result.sort((a, b) => b.course.name.compareTo(a.course.name));
        break;
      case CourseSortOption.mostEngagement:
        result.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        if (!_hasScreenAccess) {
          return _buildAccessDeniedState(isDark, l10n);
        }

        return BlocConsumer<InstructorCoursesBloc, InstructorCoursesState>(
          listener: (context, coursesState) {
            if (coursesState is InstructorCoursesLoaded) {
              setState(() {
                _courses = _mapToExtendedCourses(coursesState.courses);
                _totalStudents = coursesState.courses.fold<int>(
                  0,
                  (sum, item) => sum + item.enrolledCount,
                );
              });
              _statsAnimController.reset();
              _cardAnimController.reset();
              _statsAnimController.forward();
              _cardAnimController.forward();
            }
          },
          builder: (context, coursesState) {
            final isLoading = coursesState is InstructorCoursesLoading;
            final isError = coursesState is InstructorCoursesError;
            final errorMessage = isError ? coursesState.message : '';

            return Scaffold(
              backgroundColor: isDark
                  ? InstructorColors.darkBackground
                  : InstructorColors.primaryBackground,
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _buildSliverAppBar(isDark, l10n),
                  // Stats Dashboard scrolls away with the header
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _statsAnimation,
                      builder: (context, child) =>
                          _buildStatsDashboard(isDark, l10n),
                    ),
                  ),
                ],
                body: Column(
                  children: [
                    // Search, Filter, Sort bar stays pinned
                    _buildSearchFilterBar(isDark, l10n),
                    // Bulk actions bar (when in selection mode)
                    if (_isSelectionMode) _buildBulkActionsBar(isDark, l10n),
                    // Course list/grid
                    Expanded(
                      child: isLoading
                          ? _buildSkeletonLoader(isDark)
                          : isError
                          ? _buildErrorState(isDark, l10n, errorMessage)
                          : _courses.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : _buildCoursesList(isDark, l10n),
                    ),
                  ],
                ),
              ),
              floatingActionButton: _buildFAB(isDark, l10n),
            );
          },
        );
      },
    );
  }

  /// Error state with retry button (T009)
  Widget _buildErrorState(bool isDark, AppLocalizations l10n, String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: InstructorColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 40,
                      color: InstructorColors.error,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Unable to load courses',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : InstructorColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.isEmpty
                        ? 'Please check your connection and try again.'
                        : message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : InstructorColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<InstructorCoursesBloc>().add(
                        const LoadTeachingCourses(),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: InstructorColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
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
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      // expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: null,
      leadingWidth: 0,
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Back button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D3D9F).withValues(alpha: 0.15),
                    const Color(0xFF155CFB).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF155CFB).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF155CFB).withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF0D3D9F),
                size: 16,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          // My Courses title with icon
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D3D9F).withValues(alpha: 0.2),
                  const Color(0xFF155CFB).withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.school_rounded,
              color: isDark ? Colors.white : const Color(0xFF0D3D9F),
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.myCourses,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0D3D9F),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // View toggle with smaller design
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D3D9F).withValues(alpha: 0.12),
                const Color(0xFF155CFB).withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF155CFB).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF155CFB).withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEnhancedViewToggle(
                Icons.grid_view_rounded,
                CourseViewType.grid,
                isDark,
                'view-toggle-grid',
              ),
              const SizedBox(width: 2),
              _buildEnhancedViewToggle(
                Icons.view_list_rounded,
                CourseViewType.list,
                isDark,
                'view-toggle-list',
              ),
              const SizedBox(width: 2),
              _buildEnhancedViewToggle(
                Icons.view_headline_rounded,
                CourseViewType.compact,
                isDark,
                'view-toggle-compact',
              ),
            ],
          ),
        ),
        // Selection mode toggle with smaller design
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: _isSelectionMode
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF0D3D9F),
                          const Color(0xFF155CFB),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF0D3D9F).withValues(alpha: 0.15),
                          const Color(0xFF155CFB).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSelectionMode
                      ? const Color(0xFF155CFB).withValues(alpha: 0.5)
                      : const Color(0xFF155CFB).withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSelectionMode
                        ? const Color(0xFF155CFB).withValues(alpha: 0.3)
                        : const Color(0xFF155CFB).withValues(alpha: 0.08),
                    blurRadius: _isSelectionMode ? 10 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isSelectionMode
                    ? Icons.checklist_rtl_rounded
                    : Icons.checklist_rounded,
                color: _isSelectionMode
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF0D3D9F)),
                size: 16,
              ),
            ),
            onPressed: () => setState(() {
              _isSelectionMode = !_isSelectionMode;
              if (!_isSelectionMode) _selectedCourses.clear();
            }),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      InstructorColors.darkSurface,
                      InstructorColors.darkBackground,
                    ]
                  : [const Color(0xFFF8FBFF), const Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF155CFB).withValues(alpha: 0.08),
                        const Color(0xFF155CFB).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C4DFF).withValues(alpha: 0.06),
                        const Color(0xFF7C4DFF).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: AppBarPatternPainter(
                    color: (isDark ? Colors.white : const Color(0xFF155CFB))
                        .withValues(alpha: 0.03),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedViewToggle(
    IconData icon,
    CourseViewType type,
    bool isDark,
    String keyName,
  ) {
    final isSelected = _viewType == type;
    return SizedBox(
      key: ValueKey<String>(keyName),
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => setState(() => _viewType = type),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF0D3D9F),
                        const Color(0xFF155CFB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF155CFB).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : const Color(0xFF0D3D9F).withValues(alpha: 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildStatsDashboard(bool isDark, AppLocalizations l10n) {
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: _buildStatCard(
  //             isDark: isDark,
  //             icon: Icons.school_rounded,
  //             iconGradient: InstructorColors.primaryGradient,
  //             label: l10n.totalCourses,
  //             value: '${(_courses.length * _statsAnimation.value).round()}',
  //             trend: '+2 this month',
  //             trendPositive: true,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: _buildStatCard(
  //             isDark: isDark,
  //             icon: Icons.people_rounded,
  //             iconGradient: InstructorColors.accentGradient,
  //             label: l10n.totalStudentsLabel,
  //             value: '${(_totalStudents * _statsAnimation.value).round()}',
  //             trend: '+48 this week',
  //             trendPositive: true,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: _buildStatCard(
  //             isDark: isDark,
  //             icon: Icons.trending_up_rounded,
  //             iconGradient: InstructorColors.successGradient,
  //             label: 'Engagement',
  //             value: '${(_avgEngagement * _statsAnimation.value).round()}%',
  //             trend: '+5% vs last month',
  //             trendPositive: true,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatCard({
  //   required bool isDark,
  //   required IconData icon,
  //   required LinearGradient iconGradient,
  //   required String label,
  //   required String value,
  //   required String trend,
  //   required bool trendPositive,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: isDark ? InstructorColors.darkCard : Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: isDark ? InstructorColors.darkBorder : InstructorColors.border,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             gradient: iconGradient,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Icon(icon, color: Colors.white, size: 18),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: isDark ? Colors.white : InstructorColors.textPrimary,
  //             fontSize: 22,
  //             fontWeight: FontWeight.w700,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: isDark
  //                 ? InstructorColors.darkTextSecondary
  //                 : InstructorColors.textSecondary,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         Row(
  //           children: [
  //             Icon(
  //               trendPositive
  //                   ? Icons.arrow_upward_rounded
  //                   : Icons.arrow_downward_rounded,
  //               size: 12,
  //               color: trendPositive
  //                   ? InstructorColors.success
  //                   : InstructorColors.error,
  //             ),
  //             const SizedBox(width: 4),
  //             Expanded(
  //               child: Text(
  //                 trend,
  //                 style: TextStyle(
  //                   color: trendPositive
  //                       ? InstructorColors.success
  //                       : InstructorColors.error,
  //                   fontSize: 10,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  //Enhanced stats dashboard with improved design and animation
  Widget _buildStatsDashboard(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [Colors.white, const Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF155CFB).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155CFB).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF0D3D9F), const Color(0xFF155CFB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF155CFB).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview Dashboard',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0D3D9F),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your teaching performance at a glance',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'This Month',
                      style: TextStyle(
                        color: const Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  isDark: isDark,
                  icon: Icons.school_rounded,
                  iconColors: const [Color(0xFF0D3D9F), Color(0xFF155CFB)],
                  label: l10n.totalCourses,
                  value: '${(_courses.length * _statsAnimation.value).round()}',
                  subValue: '${_courses.length}',
                  trend: 'Assigned now',
                  trendPositive: true,
                  accentColor: const Color(0xFF155CFB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildEnhancedStatCard(
                  isDark: isDark,
                  icon: Icons.people_rounded,
                  iconColors: const [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
                  label: l10n.totalStudentsLabel,
                  value: '${(_totalStudents * _statsAnimation.value).round()}',
                  subValue: _formatNumber(_totalStudents),
                  trend: 'Across sections',
                  trendPositive: true,
                  accentColor: const Color(0xFF7C4DFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard({
    required bool isDark,
    required IconData icon,
    required List<Color> iconColors,
    required String label,
    required String value,
    required String subValue,
    required String trend,
    required bool trendPositive,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1F2937).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColors[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: iconColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                        ),
                        // const SizedBox(width: 6),
                        // Flexible(
                        //   child: Text(
                        //     subValue,
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(
                        //       color: isDark
                        //           ? Colors.white.withValues(alpha: 0.55)
                        //           : const Color(0xFF6B7280),
                        //       fontSize: 11,
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color:
                  (trendPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color:
                    (trendPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  trendPositive
                      ? Icons.arrow_outward_rounded
                      : Icons.south_east_rounded,
                  size: 12,
                  color: trendPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trendPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format large numbers
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildSearchFilterBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? InstructorColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? InstructorColors.darkBorder
                    : InstructorColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: '${l10n.searchCourses}...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : InstructorColors.textMuted,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white38 : InstructorColors.textMuted,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? Colors.white38
                              : InstructorColors.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips row
          SizedBox(
            height: 48,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                // Status filter
                _buildFilterDropdown(
                  isDark: isDark,
                  icon: Icons.flag_rounded,
                  label: _selectedStatus == 'all'
                      ? l10n.status
                      : _selectedStatus,
                  items: [
                    PopupMenuItem(value: 'all', child: Text(l10n.all)),
                    PopupMenuItem(
                      value: 'published',
                      child: _buildStatusMenuItem(
                        'Published',
                        InstructorColors.success,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'draft',
                      child: _buildStatusMenuItem(
                        'Draft',
                        InstructorColors.warning,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'archived',
                      child: _buildStatusMenuItem(
                        'Archived',
                        InstructorColors.textMuted,
                      ),
                    ),
                  ],
                  onSelected: (v) => setState(() => _selectedStatus = v),
                ),
                const SizedBox(width: 8),
                // Category filter
                _buildFilterDropdown(
                  isDark: isDark,
                  icon: Icons.category_rounded,
                  label: _selectedCategory == 'all'
                      ? _levelLabel('all')
                      : _levelLabel(_selectedCategory),
                  items: _categories
                      .map(
                        (c) => PopupMenuItem(
                          value: c,
                          child: Text(_levelLabel(c)),
                        ),
                      )
                      .toList(),
                  onSelected: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(width: 8),
                // Sort dropdown
                _buildSortDropdown(isDark, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMenuItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required bool isDark,
    required IconData icon,
    required String label,
    required List<PopupMenuItem<String>> items,
    required void Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? InstructorColors.darkCard : Colors.white,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? InstructorColors.darkBorder
                : InstructorColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: InstructorColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isDark ? Colors.white60 : InstructorColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => items,
    );
  }

  Widget _buildSortDropdown(bool isDark, AppLocalizations l10n) {
    final sortLabels = {
      CourseSortOption.newest: l10n.newestFirst,
      CourseSortOption.oldest: l10n.oldestFirst,
      CourseSortOption.mostStudents: 'Most Students',
      CourseSortOption.leastStudents: 'Least Students',
      CourseSortOption.alphabetical: 'A-Z',
      CourseSortOption.reverseAlphabetical: 'Z-A',
      CourseSortOption.mostEngagement: 'Top Engagement',
    };

    return PopupMenuButton<CourseSortOption>(
      onSelected: (v) => setState(() => _sortOption = v),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? InstructorColors.darkCard : Colors.white,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? InstructorColors.darkBorder
                : InstructorColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: InstructorColors.accentPurple,
            ),
            const SizedBox(width: 6),
            Text(
              sortLabels[_sortOption] ?? 'Sort',
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isDark ? Colors.white60 : InstructorColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => sortLabels.entries
          .map(
            (e) => PopupMenuItem(
              value: e.key,
              child: Row(
                children: [
                  if (_sortOption == e.key)
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: InstructorColors.primary,
                    )
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(e.value),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBulkActionsBar(bool isDark, AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSelectionMode ? 56 : 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: InstructorColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: InstructorColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              '${_selectedCourses.length} selected',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.archive_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _selectedCourses.isEmpty
                  ? null
                  : () => _handleBulkAction('archive'),
              tooltip: l10n.archived,
            ),
            IconButton(
              icon: const Icon(
                Icons.publish_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _selectedCourses.isEmpty
                  ? null
                  : () => _handleBulkAction('publish'),
              tooltip: 'Publish',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _selectedCourses.isEmpty || !_canDeleteCourses
                  ? null
                  : () => _handleBulkAction('delete'),
              tooltip: l10n.delete,
            ),
          ],
        ),
      ),
    );
  }

  void _handleBulkAction(String action) {
    if (action == 'delete' && !_canDeleteCourses) {
      _showDeletePermissionDenied();
      return;
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action ${_selectedCourses.length} courses'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: InstructorColors.primary,
      ),
    );
    setState(() {
      _selectedCourses.clear();
      _isSelectionMode = false;
    });
  }

  Widget _buildCoursesList(bool isDark, AppLocalizations l10n) {
    final courses = _filteredCourses;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
      },
      color: InstructorColors.primary,
      backgroundColor: isDark ? InstructorColors.darkCard : Colors.white,
      child: _viewType == CourseViewType.grid
          ? _buildGridView(courses, isDark, l10n)
          : _viewType == CourseViewType.list
          ? _buildListView(courses, isDark, l10n)
          : _buildCompactView(courses, isDark, l10n),
    );
  }

  Widget _buildGridView(
    List<ExtendedCourse> courses,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildAnimatedCard(
          index: index,
          child: CourseGridCard(
            course: courses[index],
            isDark: isDark,
            isSelected: _selectedCourses.contains(courses[index].course.id),
            isSelectionMode: _isSelectionMode,
            onTap: () => _handleCourseTap(courses[index]),
            onLongPress: () => _handleCourseLongPress(courses[index]),
            onQuickAction: (action) =>
                _handleQuickAction(courses[index], action),
          ),
        );
      },
    );
  }

  Widget _buildListView(
    List<ExtendedCourse> courses,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildAnimatedCard(
          index: index,
          child: CourseListCard(
            course: courses[index],
            isDark: isDark,
            isSelected: _selectedCourses.contains(courses[index].course.id),
            isSelectionMode: _isSelectionMode,
            onTap: () => _handleCourseTap(courses[index]),
            onLongPress: () => _handleCourseLongPress(courses[index]),
            onQuickAction: (action) =>
                _handleQuickAction(courses[index], action),
          ),
        );
      },
    );
  }

  Widget _buildCompactView(
    List<ExtendedCourse> courses,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildAnimatedCard(
          index: index,
          child: CourseCompactCard(
            course: courses[index],
            isDark: isDark,
            isSelected: _selectedCourses.contains(courses[index].course.id),
            isSelectionMode: _isSelectionMode,
            onTap: () => _handleCourseTap(courses[index]),
            onLongPress: () => _handleCourseLongPress(courses[index]),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  void _handleCourseTap(ExtendedCourse course) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedCourses.contains(course.course.id)) {
          _selectedCourses.remove(course.course.id);
        } else {
          _selectedCourses.add(course.course.id);
        }
      });
      HapticFeedback.selectionClick();
    } else {
      final courseId = int.tryParse(course.course.id) ?? 0;
      context.push('/instructor/courses/$courseId', extra: course.course);
    }
  }

  void _handleCourseLongPress(ExtendedCourse course) {
    if (!_isSelectionMode) {
      HapticFeedback.mediumImpact();
      _showCoursePreviewModal(course);
    }
  }

  void _handleQuickAction(ExtendedCourse course, String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'edit':
        _showEditCourseDialog(course);
        break;
      case 'analytics':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening analytics for ${course.course.name}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course "${course.course.name}" duplicated'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: InstructorColors.success,
          ),
        );
        break;
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Share link copied to clipboard'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: InstructorColors.primary,
          ),
        );
        break;
      case 'delete':
        if (!_canDeleteCourses) {
          _showDeletePermissionDenied();
          return;
        }
        _showDeleteConfirmation(course);
        break;
    }
  }

  void _showCoursePreviewModal(ExtendedCourse course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CoursePreviewModal(course: course),
    );
  }

  void _showEditCourseDialog(ExtendedCourse course) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: course.course.name);
    final codeController = TextEditingController(text: course.course.code);
    final descController = TextEditingController(
      text: course.course.description,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: InstructorColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l10n.editCourse,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : InstructorColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                isDark,
                nameController,
                l10n.courseName,
                Icons.school_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                codeController,
                l10n.courseCode,
                Icons.tag_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                descController,
                l10n.description,
                Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white70
                            : InstructorColors.textSecondary,
                        side: BorderSide(
                          color: isDark
                              ? InstructorColors.darkBorder
                              : InstructorColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Course updated successfully'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: InstructorColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(l10n.saveChanges),
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

  Widget _buildModernTextField(
    bool isDark,
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : InstructorColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : InstructorColors.textSecondary,
        ),
        prefixIcon: Icon(icon, color: InstructorColors.primary),
        filled: true,
        fillColor: isDark
            ? InstructorColors.darkCard
            : InstructorColors.primaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: InstructorColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ExtendedCourse course) {
    if (!_canDeleteCourses) {
      _showDeletePermissionDenied();
      return;
    }

    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? InstructorColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: InstructorColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: InstructorColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.delete,
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${course.course.name}"? This action cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.white70 : InstructorColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white70 : InstructorColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course "${course.course.name}" deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: InstructorColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isDark) {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
        mainAxisExtent: 200,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return CourseSkeletonCard(isDark: isDark);
      },
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    final isFiltered =
        _searchQuery.isNotEmpty ||
        _selectedStatus != 'all' ||
        _selectedCategory != 'all';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: EmptyCoursesMessage(
                isDark: isDark,
                title: isFiltered
                    ? 'No Courses Found'
                    : 'No courses assigned yet',
                subtitle: isFiltered
                    ? l10n.tryAdjustingFilters
                    : 'You do not have any assigned courses yet.',
                buttonLabel: isFiltered ? 'Clear Filters' : l10n.createCourse,
                buttonIcon: isFiltered
                    ? Icons.refresh_rounded
                    : Icons.add_rounded,
                outlinedButton: isFiltered,
                onPressed: () {
                  if (!isFiltered) {
                    _showCreateCourseDialog();
                    return;
                  }

                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedStatus = 'all';
                    _selectedCategory = 'all';
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateCourseDialog(),
      backgroundColor: InstructorColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        l10n.createCourse,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showCreateCourseDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? InstructorColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: InstructorColors.successGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l10n.createCourse,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : InstructorColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                isDark,
                nameController,
                l10n.courseName,
                Icons.school_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                codeController,
                l10n.courseCode,
                Icons.tag_rounded,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                isDark,
                descController,
                l10n.description,
                Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.courseCreated),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: InstructorColors.success,
                      ),
                    );
                    context.read<InstructorCoursesBloc>().add(
                      const LoadTeachingCourses(),
                    );
                  },
                  icon: const Icon(Icons.rocket_launch_rounded),
                  label: Text(l10n.createCourse),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
