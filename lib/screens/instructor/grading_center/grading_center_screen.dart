import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/submission_model.dart';
import '../../../widgets/instructor/grading/grading_barrel.dart';

class GradingCenterScreen extends StatefulWidget {
  const GradingCenterScreen({super.key});

  @override
  State<GradingCenterScreen> createState() => _GradingCenterScreenState();
}

class _GradingCenterScreenState extends State<GradingCenterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _statsAnimController;
  late AnimationController _listAnimController;
  late Animation<double> _statsAnimation;

  String _searchQuery = '';
  String _selectedCourse = 'All';
  bool _isLoading = true;
  List<Submission> _submissions = [];

  final List<String> _courses = [
    'All',
    'CS101 - OS',
    'CS202 - Data Structures',
    'CS305 - Database',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _statsAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsAnimController,
      curve: Curves.easeOutCubic,
    );
    _loadSubmissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statsAnimController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    _statsAnimController.reset();
    _listAnimController.reset();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _submissions = _getDemoSubmissions();
          _isLoading = false;
        });
        _statsAnimController.forward();
        _listAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load submissions'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: GradingColors.late,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadSubmissions,
            ),
          ),
        );
      }
    }
  }

  List<Submission> _getDemoSubmissions() {
    return [
      Submission(
        id: '1',
        studentName: 'Ahmed Mohamed',
        studentEmail: 'ahmed@uni.edu',
        assignmentTitle: 'Process Scheduling',
        courseName: 'CS101 - OS',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: SubmissionStatus.pending,
        grade: null,
        maxGrade: 100,
      ),
      Submission(
        id: '2',
        studentName: 'Sara Ahmed',
        studentEmail: 'sara@uni.edu',
        assignmentTitle: 'Binary Trees',
        courseName: 'CS202 - Data Structures',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: SubmissionStatus.pending,
        grade: null,
        maxGrade: 100,
      ),
      Submission(
        id: '3',
        studentName: 'Omar Hassan',
        studentEmail: 'omar@uni.edu',
        assignmentTitle: 'SQL Queries',
        courseName: 'CS305 - Database',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: SubmissionStatus.graded,
        grade: 85,
        maxGrade: 100,
      ),
      Submission(
        id: '4',
        studentName: 'Fatima Ali',
        studentEmail: 'fatima@uni.edu',
        assignmentTitle: 'Memory Management',
        courseName: 'CS101 - OS',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: SubmissionStatus.late,
        grade: null,
        maxGrade: 100,
        lateDays: 1,
      ),
      Submission(
        id: '5',
        studentName: 'Youssef Khaled',
        studentEmail: 'youssef@uni.edu',
        assignmentTitle: 'Hash Tables',
        courseName: 'CS202 - Data Structures',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: SubmissionStatus.graded,
        grade: 92,
        maxGrade: 100,
      ),
      Submission(
        id: '6',
        studentName: 'Nour Ibrahim',
        studentEmail: 'nour@uni.edu',
        assignmentTitle: 'ER Diagrams',
        courseName: 'CS305 - Database',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: SubmissionStatus.late,
        grade: null,
        maxGrade: 100,
        lateDays: 2,
      ),
      Submission(
        id: '7',
        studentName: 'Mohamed Salah',
        studentEmail: 'msalah@uni.edu',
        assignmentTitle: 'Deadlock Prevention',
        courseName: 'CS101 - OS',
        submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
        status: SubmissionStatus.pending,
        grade: null,
        maxGrade: 100,
      ),
    ];
  }

  List<Submission> _getFilteredSubmissions(String filter) {
    return _submissions.where((s) {
      final matchesSearch =
          s.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.assignmentTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCourse =
          _selectedCourse == 'All' || s.courseName == _selectedCourse;
      final matchesFilter =
          filter == 'all' ||
          (filter == 'pending' && s.status == SubmissionStatus.pending) ||
          (filter == 'graded' && s.status == SubmissionStatus.graded) ||
          (filter == 'late' && s.status == SubmissionStatus.late);
      return matchesSearch && matchesCourse && matchesFilter;
    }).toList();
  }

  int get _pendingCount =>
      _submissions.where((s) => s.status == SubmissionStatus.pending).length;
  int get _gradedCount =>
      _submissions.where((s) => s.status == SubmissionStatus.graded).length;
  int get _lateCount =>
      _submissions.where((s) => s.status == SubmissionStatus.late).length;

  void _handleGradeSubmission(
    Submission submission,
    int grade,
    String? feedback,
  ) {
    setState(() {
      final index = _submissions.indexWhere((s) => s.id == submission.id);
      if (index != -1) {
        _submissions[index] = submission.copyWith(
          grade: grade,
          feedback: feedback,
          status: SubmissionStatus.graded,
        );
      }
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Grade submitted successfully!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: GradingColors.graded,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: GradingColors.background(isDark),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(isDark, l10n),
                // Header scrolls away with the header
                SliverToBoxAdapter(child: _buildHeaderSection(isDark, l10n)),
              ];
            },
            body: Column(
              children: [
                // Search and filter bar stays pinned
                _buildSearchFilterBar(isDark, l10n),
                // Tab bar
                _buildTabBar(isDark, l10n),
                // Submissions list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSubmissionsList(isDark, l10n, 'all'),
                      _buildSubmissionsList(isDark, l10n, 'pending'),
                      _buildSubmissionsList(isDark, l10n, 'graded'),
                      _buildSubmissionsList(isDark, l10n, 'late'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? GradingColors.darkBg : GradingColors.primary,
      surfaceTintColor: isDark ? GradingColors.darkBg : GradingColors.primary,
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
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.1),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.15),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          // Grading Center title with icon
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.15),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                      ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.grading_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.gradingCenter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [GradingColors.darkBg, GradingColors.darkCard]
                  : [GradingColors.primary, GradingColors.primaryLight],
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
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.0),
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
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _GradingPatternPainter(
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? GradingColors.darkHeaderGradient
            : GradingColors.headerGradient,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GradingPatternPainter(
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Title section
              // Row(
              //   children: [
              //     Container(
              //       padding: const EdgeInsets.all(14),
              //       decoration: BoxDecoration(
              //         gradient: LinearGradient(
              //           colors: [
              //             Colors.white.withValues(alpha: 0.25),
              //             Colors.white.withValues(alpha: 0.1),
              //           ],
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight,
              //         ),
              //         borderRadius: BorderRadius.circular(16),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withValues(alpha: 0.1),
              //             blurRadius: 10,
              //             offset: const Offset(0, 4),
              //           ),
              //         ],
              //       ),
              //       child: const Icon(
              //         Icons.grading_rounded,
              //         color: Colors.white,
              //         size: 28,
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             l10n.gradingCenter,
              //             style: const TextStyle(
              //               color: Colors.white,
              //               fontSize: 26,
              //               fontWeight: FontWeight.bold,
              //               letterSpacing: -0.5,
              //             ),
              //           ),
              //           const SizedBox(height: 4),
              //           Text(
              //             '${_submissions.length} submissions to review',
              //             style: TextStyle(
              //               color: Colors.white.withValues(alpha: 0.8),
              //               fontSize: 14,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 16),
              // Stats dashboard
              FadeTransition(
                opacity: _statsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_statsAnimation),
                  child: _isLoading
                      ? StatsSkeletonDashboard(isDark: isDark)
                      : StatsDashboard(
                          pendingCount: _pendingCount,
                          gradedCount: _gradedCount,
                          lateCount: _lateCount,
                          totalCount: _submissions.length,
                          isDark: isDark,
                          onStatTap: (status) {
                            switch (status) {
                              case 'pending':
                                _tabController.animateTo(1);
                                break;
                              case 'graded':
                                _tabController.animateTo(2);
                                break;
                              case 'late':
                                _tabController.animateTo(3);
                                break;
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildSliverAppBar(
  //   bool isDark,
  //   AppLocalizations l10n,
  //   bool innerBoxIsScrolled,
  // ) {
  //   return SliverAppBar(
  //     expandedHeight: 280,
  //     floating: false,
  //     pinned: true,
  //     elevation: 0,
  //     backgroundColor: Colors.transparent,
  //     surfaceTintColor: Colors.transparent,
  //     leading: Padding(
  //       padding: const EdgeInsets.only(left: 8),
  //       child: Center(
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: isDark
  //                   ? [
  //                       Colors.white.withValues(alpha: 0.15),
  //                       Colors.white.withValues(alpha: 0.08),
  //                     ]
  //                   : [
  //                       Colors.white.withValues(alpha: 0.9),
  //                       Colors.white.withValues(alpha: 0.7),
  //                     ],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withValues(alpha: 0.1),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.arrow_back_rounded,
  //               color: isDark ? Colors.white : GradingColors.primary,
  //             ),
  //             onPressed: () => context.pop(),
  //           ),
  //         ),
  //       ),
  //     ),
  //     flexibleSpace: FlexibleSpaceBar(
  //       background: Stack(
  //         children: [
  //           // Gradient background
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: isDark
  //                   ? GradingColors.darkHeaderGradient
  //                   : GradingColors.headerGradient,
  //             ),
  //           ),
  //           // Decorative circles
  //           Positioned(
  //             top: -60,
  //             right: -40,
  //             child: Container(
  //               width: 200,
  //               height: 200,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: Colors.white.withValues(alpha: 0.05),
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             top: 80,
  //             left: -60,
  //             child: Container(
  //               width: 150,
  //               height: 150,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: Colors.white.withValues(alpha: 0.03),
  //               ),
  //             ),
  //           ),
  //           // Pattern overlay
  //           Positioned.fill(
  //             child: CustomPaint(
  //               painter: _GradingPatternPainter(
  //                 color: Colors.white.withValues(alpha: 0.03),
  //               ),
  //             ),
  //           ),
  //           // Content
  //           Positioned(
  //             left: 0,
  //             right: 0,
  //             bottom: 0,
  //             child: Column(
  //               children: [
  //                 // Title section
  //                 Padding(
  //                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
  //                   child: Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.all(14),
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [
  //                               Colors.white.withValues(alpha: 0.25),
  //                               Colors.white.withValues(alpha: 0.1),
  //                             ],
  //                             begin: Alignment.topLeft,
  //                             end: Alignment.bottomRight,
  //                           ),
  //                           borderRadius: BorderRadius.circular(16),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black.withValues(alpha: 0.1),
  //                               blurRadius: 10,
  //                               offset: const Offset(0, 4),
  //                             ),
  //                           ],
  //                         ),
  //                         child: const Icon(
  //                           Icons.grading_rounded,
  //                           color: Colors.white,
  //                           size: 28,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 16),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               l10n.gradingCenter,
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 26,
  //                                 fontWeight: FontWeight.bold,
  //                                 letterSpacing: -0.5,
  //                               ),
  //                             ),
  //                             const SizedBox(height: 4),
  //                             Text(
  //                               '${_submissions.length} submissions to review',
  //                               style: TextStyle(
  //                                 color: Colors.white.withValues(alpha: 0.8),
  //                                 fontSize: 14,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // Stats dashboard
  //                 FadeTransition(
  //                   opacity: _statsAnimation,
  //                   child: SlideTransition(
  //                     position: Tween<Offset>(
  //                       begin: const Offset(0, 0.2),
  //                       end: Offset.zero,
  //                     ).animate(_statsAnimation),
  //                     child: _isLoading
  //                         ? StatsSkeletonDashboard(isDark: isDark)
  //                         : StatsDashboard(
  //                             pendingCount: _pendingCount,
  //                             gradedCount: _gradedCount,
  //                             lateCount: _lateCount,
  //                             totalCount: _submissions.length,
  //                             isDark: isDark,
  //                             onStatTap: (status) {
  //                               switch (status) {
  //                                 case 'pending':
  //                                   _tabController.animateTo(1);
  //                                   break;
  //                                 case 'graded':
  //                                   _tabController.animateTo(2);
  //                                   break;
  //                                 case 'late':
  //                                   _tabController.animateTo(3);
  //                                   break;
  //                               }
  //                             },
  //                           ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchFilterBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: GradingColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: GradingColors.primary.withValues(
                      alpha: isDark ? 0.08 : 0.04,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(
                  color: GradingColors.textPrimaryColor(isDark),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchStudents,
                  hintStyle: TextStyle(
                    color: GradingColors.textTertiaryColor(isDark),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: GradingColors.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: GradingColors.textTertiaryColor(isDark),
                            size: 18,
                          ),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? GradingColors.darkSurface
                      : GradingColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: GradingColors.borderColor(isDark),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: GradingColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Course filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [GradingColors.darkSurface, GradingColors.darkCard]
                    : [GradingColors.surface, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: GradingColors.borderColor(isDark),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourse,
                dropdownColor: GradingColors.cardColor(isDark),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: GradingColors.primary,
                ),
                style: TextStyle(
                  color: GradingColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                items: _courses.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.length > 15 ? '${c.substring(0, 15)}...' : c),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCourse = v ?? 'All'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? GradingColors.darkCard : GradingColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GradingColors.borderColor(isDark), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: GradingColors.textSecondaryColor(isDark),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicator: BoxDecoration(
          gradient: GradingColors.headerGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: GradingColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabAlignment: TabAlignment.fill, // Added this
        tabs: [
          _buildTabWithBadge(l10n.all, _submissions.length, isDark),
          _buildTabWithBadge(l10n.pending, _pendingCount, isDark),
          _buildTabWithBadge(l10n.graded, _gradedCount, isDark),
          _buildTabWithBadge(l10n.late, _lateCount, isDark),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count, bool isDark) {
    return Tab(
      height: 40,
      child: Column(
        // Changed from Row to Column
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : GradingColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionsList(
    bool isDark,
    AppLocalizations l10n,
    String filter,
  ) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GradingSkeleton(isDark: isDark);
        },
      );
    }

    final submissions = _getFilteredSubmissions(filter);

    if (submissions.isEmpty) {
      return _buildEmptyState(isDark, l10n, filter);
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      color: GradingColors.primary,
      backgroundColor: GradingColors.cardColor(isDark),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submission = submissions[index];
          final itemAnimation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _listAnimController,
              curve: Interval(
                (index / submissions.length) * 0.5,
                ((index + 1) / submissions.length) * 0.5 + 0.5,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          return SubmissionCard(
            submission: submission,
            isDark: isDark,
            animation: itemAnimation,
            onGrade: () => GradeDialog.show(
              context: context,
              submission: submission,
              isDark: isDark,
              onSubmit: (grade, feedback) =>
                  _handleGradeSubmission(submission, grade, feedback),
            ),
            onViewDetails: () {
              // TODO: Navigate to submission details
              HapticFeedback.lightImpact();
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n, String filter) {
    IconData icon;
    String message;
    Color color;

    switch (filter) {
      case 'pending':
        icon = Icons.pending_actions_rounded;
        message = l10n.noPendingSubmissions;
        color = GradingColors.pending;
        break;
      case 'graded':
        icon = Icons.check_circle_outline_rounded;
        message = l10n.noGradedSubmissions;
        color = GradingColors.graded;
        break;
      case 'late':
        icon = Icons.schedule_rounded;
        message = l10n.noLateSubmissions;
        color = GradingColors.late;
        break;
      default:
        icon = Icons.inbox_rounded;
        message = l10n.noSubmissionsFound;
        color = GradingColors.primary;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                color: GradingColors.textSecondaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'all'
                  ? 'All caught up! Check back later.'
                  : 'No submissions in this category',
              style: TextStyle(
                color: GradingColors.textTertiaryColor(isDark),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pattern painter for app bar decoration
class _GradingPatternPainter extends CustomPainter {
  final Color color;

  _GradingPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    const dotRadius = 1.5;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
