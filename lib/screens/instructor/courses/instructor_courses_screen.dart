import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../models/instructor/extended_course_model.dart';
import '../../../widgets/instructor/courses/courses_barrel.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen>
    with TickerProviderStateMixin {
  ResponsiveUtil get _responsive => ResponsiveUtil(context);
  // State variables
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  CourseSortOption _sortOption = CourseSortOption.newest;
  CourseViewType _viewType = CourseViewType.grid;
  List<ExtendedCourse> _courses = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedCourses = {};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late AnimationController _statsAnimController;
  late AnimationController _cardAnimController;
  late Animation<double> _statsAnimation;

  // Categories for filtering
  final List<String> _categories = [
    'all',
    'Programming',
    'Data Science',
    'Web Development',
    'Mobile',
    'AI/ML',
    'Database',
  ];

  // Stats
  int get _totalStudents =>
      _courses.fold<num>(0, (sum, c) => sum + c.course.totalStudents).toInt();
  // ignore: unused_element
  double get _totalRevenue => _courses.fold(0.0, (sum, c) => sum + c.revenue);
  double get _avgEngagement => _courses.isEmpty
      ? 0
      : _courses.fold<num>(0, (sum, c) => sum + c.engagementScore).toDouble() /
            _courses.length;

  @override
  void initState() {
    super.initState();
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
    _loadCourses();
  }

  @override
  void dispose() {
    _statsAnimController.dispose();
    _cardAnimController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    // Reset animation controllers for refresh
    _statsAnimController.reset();
    _cardAnimController.reset();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _courses = _getDemoCourses();
          _isLoading = false;
        });
        _statsAnimController.forward();
        _cardAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load courses. Please try again.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: InstructorColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadCourses,
            ),
          ),
        );
      }
    }
  }

  List<ExtendedCourse> _getDemoCourses() {
    return [
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '1',
          name: 'Advanced Operating Systems',
          code: 'CS501',
          description:
              'Deep dive into OS internals, process management, memory systems, and distributed computing.',
          totalStudents: 156,
          newItems: 5,
          activeQuizzes: 3,
          colorValue: 0xFF0D47A1,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [
            AssignmentModel(
              id: '1',
              title: 'Process Scheduling',
              dueDate: DateTime.now().add(const Duration(days: 3)),
              submissionsCount: 98,
              gradedCount: 45,
            ),
            AssignmentModel(
              id: '2',
              title: 'Memory Management',
              dueDate: DateTime.now().add(const Duration(days: 7)),
              submissionsCount: 56,
              gradedCount: 20,
            ),
          ],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.72,
        revenue: 4680.0,
        engagementScore: 89,
        status: 'published',
        category: 'Programming',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        enrollmentTrend: [0.5, 0.6, 0.7, 0.65, 0.8, 0.85, 0.9],
        hasMilestone: true,
        milestoneText: '150+ Students! 🎉',
      ),
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '2',
          name: 'Data Structures & Algorithms',
          code: 'CS202',
          description:
              'Master fundamental data structures and algorithmic thinking.',
          totalStudents: 234,
          newItems: 2,
          activeQuizzes: 4,
          colorValue: 0xFF7C4DFF,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.85,
        revenue: 7020.0,
        engagementScore: 94,
        status: 'published',
        category: 'Programming',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        enrollmentTrend: [0.7, 0.75, 0.8, 0.85, 0.82, 0.88, 0.92],
        hasMilestone: true,
        milestoneText: 'Top Rated! ⭐',
      ),
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '3',
          name: 'Machine Learning Fundamentals',
          code: 'AI301',
          description:
              'Introduction to ML algorithms, neural networks, and practical applications.',
          totalStudents: 189,
          newItems: 8,
          activeQuizzes: 2,
          colorValue: 0xFF00BFA5,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [
            AssignmentModel(
              id: '3',
              title: 'Linear Regression',
              dueDate: DateTime.now().add(const Duration(days: 5)),
              submissionsCount: 145,
              gradedCount: 100,
            ),
          ],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.68,
        revenue: 5670.0,
        engagementScore: 91,
        status: 'published',
        category: 'AI/ML',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        enrollmentTrend: [0.4, 0.5, 0.55, 0.7, 0.75, 0.8, 0.85],
      ),
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '4',
          name: 'Full-Stack Web Development',
          code: 'WEB401',
          description:
              'Build modern web applications with React, Node.js, and cloud deployment.',
          totalStudents: 312,
          newItems: 12,
          activeQuizzes: 5,
          colorValue: 0xFFFF6D00,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.78,
        revenue: 9360.0,
        engagementScore: 96,
        status: 'published',
        category: 'Web Development',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        enrollmentTrend: [0.8, 0.82, 0.85, 0.88, 0.9, 0.92, 0.95],
        hasMilestone: true,
        milestoneText: '300+ Students! 🚀',
      ),
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '5',
          name: 'Database Design & SQL',
          code: 'DB301',
          description: 'Design efficient databases and master SQL queries.',
          totalStudents: 87,
          newItems: 1,
          activeQuizzes: 1,
          colorValue: 0xFFE91E63,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.45,
        revenue: 2610.0,
        engagementScore: 72,
        status: 'draft',
        category: 'Database',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        enrollmentTrend: [0.2, 0.25, 0.3, 0.35, 0.4, 0.42, 0.45],
      ),
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '6',
          name: 'Mobile App Development with Flutter',
          code: 'MOB401',
          description:
              'Create beautiful cross-platform mobile apps with Flutter and Dart.',
          totalStudents: 145,
          newItems: 6,
          activeQuizzes: 3,
          colorValue: 0xFF536DFE,
          isActive: true,
          semester: 'Fall 2025',
          assignments: [],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.62,
        revenue: 4350.0,
        engagementScore: 88,
        status: 'published',
        category: 'Mobile',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        enrollmentTrend: [0.5, 0.55, 0.6, 0.58, 0.65, 0.68, 0.7],
      ),
      ExtendedCourse(
        course: InstructorCourseModel(
          id: '7',
          name: 'Python for Data Science',
          code: 'DS201',
          description:
              'Learn Python programming for data analysis and visualization.',
          totalStudents: 0,
          newItems: 0,
          activeQuizzes: 0,
          colorValue: 0xFFFFAB00,
          isActive: false,
          semester: 'Spring 2025',
          assignments: [],
          materials: [],
          announcements: [],
        ),
        completionRate: 0.0,
        revenue: 0.0,
        engagementScore: 0,
        status: 'archived',
        category: 'Data Science',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        enrollmentTrend: [0, 0, 0, 0, 0, 0, 0],
      ),
    ];
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
                  child: _isLoading
                      ? _buildSkeletonLoader(isDark)
                      : _filteredCourses.isEmpty
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
                    const Color(0xFF0D3D9F).withOpacity(0.15),
                    const Color(0xFF155CFB).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF155CFB).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF155CFB).withOpacity(0.1),
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
                  const Color(0xFF0D3D9F).withOpacity(0.2),
                  const Color(0xFF155CFB).withOpacity(0.15),
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
                const Color(0xFF0D3D9F).withOpacity(0.12),
                const Color(0xFF155CFB).withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF155CFB).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF155CFB).withOpacity(0.08),
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
              ),
              const SizedBox(width: 2),
              _buildEnhancedViewToggle(
                Icons.view_list_rounded,
                CourseViewType.list,
                isDark,
              ),
              const SizedBox(width: 2),
              _buildEnhancedViewToggle(
                Icons.view_headline_rounded,
                CourseViewType.compact,
                isDark,
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
                          const Color(0xFF0D3D9F).withOpacity(0.15),
                          const Color(0xFF155CFB).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSelectionMode
                      ? const Color(0xFF155CFB).withOpacity(0.5)
                      : const Color(0xFF155CFB).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSelectionMode
                        ? const Color(0xFF155CFB).withOpacity(0.3)
                        : const Color(0xFF155CFB).withOpacity(0.08),
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
                        const Color(0xFF155CFB).withOpacity(0.08),
                        const Color(0xFF155CFB).withOpacity(0.0),
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
                        const Color(0xFF7C4DFF).withOpacity(0.06),
                        const Color(0xFF7C4DFF).withOpacity(0.0),
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
  ) {
    final isSelected = _viewType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _viewType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [const Color(0xFF0D3D9F), const Color(0xFF155CFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF155CFB).withOpacity(0.3),
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
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF0D3D9F).withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton(
    IconData icon,
    CourseViewType type,
    bool isDark,
  ) {
    final isSelected = _viewType == type;
    return GestureDetector(
      onTap: () => setState(() => _viewType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? InstructorColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white60 : InstructorColors.textSecondary),
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(20),
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
          color: const Color(0xFF155CFB).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155CFB).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF0D3D9F), const Color(0xFF155CFB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF155CFB).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview Dashboard',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0D3D9F),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your teaching performance at a glance',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Time period badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'This Month',
                      style: TextStyle(
                        color: const Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Grid
          SizedBox(
            height: _responsive.p264,
            child: Column(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    isDark: isDark,
                    icon: Icons.school_rounded,
                    iconColors: [
                      const Color(0xFF0D3D9F),
                      const Color(0xFF155CFB),
                    ],
                    label: l10n.totalCourses,
                    value:
                        '${(_courses.length * _statsAnimation.value).round()}',
                    subValue: '${_courses.length}',
                    trend: '+2 this month',
                    trendPositive: true,
                    accentColor: const Color(0xFF155CFB),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildEnhancedStatCard(
                    isDark: isDark,
                    icon: Icons.people_rounded,
                    iconColors: [
                      const Color(0xFF7C4DFF),
                      const Color(0xFF9C27B0),
                    ],
                    label: l10n.totalStudentsLabel,
                    value:
                        '${(_totalStudents * _statsAnimation.value).round()}',
                    subValue: _formatNumber(_totalStudents),
                    trend: '+48 this week',
                    trendPositive: true,
                    accentColor: const Color(0xFF7C4DFF),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildEnhancedStatCard(
                    isDark: isDark,
                    icon: Icons.trending_up_rounded,
                    iconColors: [
                      const Color(0xFF10B981),
                      const Color(0xFF059669),
                    ],
                    label: 'Engagement',
                    value:
                        '${(_avgEngagement * _statsAnimation.value).round()}%',
                    subValue: '${_avgEngagement.round()}%',
                    trend: '+5% vs last month',
                    trendPositive: true,
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: iconColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconColors[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          // Value with animated counter
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: iconColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Label
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF6B7280),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          Spacer(),
          // Trend indicator with enhanced design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color:
                  (trendPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    (trendPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color:
                        (trendPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    trendPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 10,
                    color: trendPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trendPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
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
            height: 38,
            child: ListView(
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
                      ? l10n.category
                      : _selectedCategory,
                  items: _categories
                      .map(
                        (c) => PopupMenuItem(
                          value: c,
                          child: Text(c == 'all' ? l10n.all : c),
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
              onPressed: _selectedCourses.isEmpty
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
      onRefresh: _loadCourses,
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
      context.push('/instructor/course-management', extra: course.course);
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    InstructorColors.primary.withValues(alpha: 0.1),
                    InstructorColors.accentPurple.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 64,
                color: InstructorColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Courses Found',
              style: TextStyle(
                color: isDark ? Colors.white : InstructorColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty ||
                      _selectedStatus != 'all' ||
                      _selectedCategory != 'all'
                  ? l10n.tryAdjustingFilters
                  : 'Create your first course and start teaching!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : InstructorColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (_searchQuery.isEmpty &&
                _selectedStatus == 'all' &&
                _selectedCategory == 'all')
              ElevatedButton.icon(
                onPressed: () => _showCreateCourseDialog(),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.createCourse),
                style: ElevatedButton.styleFrom(
                  backgroundColor: InstructorColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _selectedStatus = 'all';
                  _selectedCategory = 'all';
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: InstructorColors.primary,
                  side: const BorderSide(color: InstructorColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
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
                    _loadCourses();
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
