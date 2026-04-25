import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/grading/grading_barrel.dart';

class GradingCenterScreen extends StatefulWidget {
  const GradingCenterScreen({super.key, this.courseId, this.embedded = false});

  final int? courseId;
  final bool embedded;

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
  List<_SubmissionEntry> _submissions = [];
  List<String> _courses = <String>['All'];

  late final AssignmentService _assignmentService;
  late final EnrollmentService _enrollmentService;

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient(storageService: StorageService());
    _assignmentService = AssignmentService(coreApiClient: coreApiClient);
    _enrollmentService = EnrollmentService(coreApiClient: coreApiClient);
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

    setState(() {
      _isLoading = true;
    });
    _statsAnimController.reset();
    _listAnimController.reset();

    try {
      final teachingCoursesResult = await _enrollmentService
          .getTeachingCourses();
      if (!teachingCoursesResult.isSuccess ||
          teachingCoursesResult.data == null) {
        throw Exception(
          teachingCoursesResult.error?.message ??
              'Failed to load teaching courses',
        );
      }

      final loadedCourses = widget.courseId == null
          ? <String>['All']
          : <String>[];
      final loadedSubmissions = <_SubmissionEntry>[];

      for (final teachingCourse in teachingCoursesResult.data!) {
        if (widget.courseId != null &&
            teachingCourse.courseId != widget.courseId) {
          continue;
        }

        final courseLabel = _buildCourseLabel(
          teachingCourse.course.code,
          teachingCourse.course.name,
        );
        if (!loadedCourses.contains(courseLabel)) {
          loadedCourses.add(courseLabel);
        }

        final assignmentsResult = await _assignmentService.getAll(
          courseId: teachingCourse.courseId,
          page: 1,
          limit: 20,
          sortBy: 'dueDate',
          sortOrder: 'DESC',
        );

        if (!assignmentsResult.isSuccess || assignmentsResult.data == null) {
          continue;
        }

        for (final assignment in assignmentsResult.data!.data) {
          final submissionsResult = await _assignmentService.getSubmissions(
            assignment.assignmentId,
          );

          if (!submissionsResult.isSuccess || submissionsResult.data == null) {
            continue;
          }

          for (final apiSubmission in submissionsResult.data!) {
            final studentFirstName = apiSubmission.user?.firstName ?? '';
            final studentLastName = apiSubmission.user?.lastName ?? '';
            final studentName =
                '$studentFirstName $studentLastName'.trim().isEmpty
                ? 'Student #${apiSubmission.userId}'
                : '$studentFirstName $studentLastName'.trim();

            loadedSubmissions.add(
              _SubmissionEntry(
                submission: apiSubmission,
                studentName: studentName,
                assignmentTitle: assignment.title,
                courseName: courseLabel,
                maxGrade: assignment.maxGrade > 0
                    ? assignment.maxGrade.round()
                    : 100,
                dueDate: assignment.dueDate,
                latePenaltyPercent: assignment.latePenaltyPercent,
              ),
            );
          }
        }
      }

      loadedSubmissions.sort(
        (a, b) => b.submission.submittedAt.compareTo(a.submission.submittedAt),
      );

      if (mounted) {
        setState(() {
          _courses = loadedCourses;
          if (widget.courseId != null && _courses.isNotEmpty) {
            _selectedCourse = _courses.first;
          } else if (!_courses.contains(_selectedCourse)) {
            _selectedCourse = 'All';
          }
          _submissions = loadedSubmissions;
          _isLoading = false;
        });
        _statsAnimController.forward();
        _listAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

  String _buildCourseLabel(String code, String name) {
    final cleanCode = code.trim();
    final cleanName = name.trim();
    if (cleanCode.isEmpty) {
      return cleanName;
    }
    return '$cleanCode - $cleanName';
  }

  bool _isGradedStatus(api.SubmissionStatus status) {
    return status == api.SubmissionStatus.graded ||
        status == api.SubmissionStatus.returned;
  }

  AssignmentSubmissionModel _copySubmissionWithGrade(
    AssignmentSubmissionModel submission,
    double grade,
    String? feedback,
  ) {
    return AssignmentSubmissionModel(
      id: submission.id,
      assignmentId: submission.assignmentId,
      userId: submission.userId,
      submissionText: submission.submissionText,
      submissionLink: submission.submissionLink,
      fileId: submission.fileId,
      submissionStatus: api.SubmissionStatus.graded,
      isLate: submission.isLate,
      attemptNumber: submission.attemptNumber,
      submittedAt: submission.submittedAt,
      score: grade,
      feedback: feedback,
      gradedBy: submission.gradedBy,
      gradedAt: DateTime.now(),
      user: submission.user,
      driveFile: submission.driveFile,
    );
  }

  List<_SubmissionEntry> _getFilteredSubmissions(String filter) {
    return _submissions.where((s) {
      final matchesSearch =
          s.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.assignmentTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCourse =
          _selectedCourse == 'All' || s.courseName == _selectedCourse;
      final isGraded = _isGradedStatus(s.submission.submissionStatus);
      final matchesFilter =
          filter == 'all' ||
          (filter == 'pending' && !isGraded) ||
          (filter == 'graded' && isGraded) ||
          (filter == 'late' && s.submission.isLate);
      return matchesSearch && matchesCourse && matchesFilter;
    }).toList();
  }

  int get _pendingCount => _submissions
      .where((s) => !_isGradedStatus(s.submission.submissionStatus))
      .length;
  int get _gradedCount => _submissions
      .where((s) => _isGradedStatus(s.submission.submissionStatus))
      .length;
  int get _lateCount => _submissions.where((s) => s.submission.isLate).length;

  Future<void> _handleGradeSubmission(
    _SubmissionEntry submissionEntry,
    double grade,
    String? feedback,
  ) async {
    final assignmentId = submissionEntry.submission.assignmentId;
    final submissionId = submissionEntry.submission.id;

    final gradeResult = await _assignmentService.gradeSubmission(
      assignmentId,
      submissionId,
      grade,
      feedback: feedback,
    );

    if (!gradeResult.isSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gradeResult.error?.message ?? 'Failed to save grade. Please retry.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: GradingColors.late,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      final index = _submissions.indexWhere(
        (s) => s.submission.id == submissionEntry.submission.id,
      );
      if (index != -1) {
        _submissions[index] = _submissions[index].copyWith(
          submission: _copySubmissionWithGrade(
            _submissions[index].submission,
            grade,
            feedback,
          ),
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
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final tabContent = Column(
          children: [
            _buildSearchFilterBar(isDark, l10n),
            _buildTabBar(isDark, l10n),
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
        );

        if (widget.embedded) {
          return Container(
            color: GradingColors.background(isDark),
            child: Column(
              children: [
                _buildHeaderSection(isDark, l10n),
                Expanded(child: tabContent),
              ],
            ),
          );
        }

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
            body: tabContent,
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
              _isLoading
                  ? StatsSkeletonDashboard(isDark: isDark)
                  : FadeTransition(
                      opacity: _statsAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_statsAnimation),
                        child: StatsDashboard(
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
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                }),
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
                          onPressed: () => setState(() {
                            _searchQuery = '';
                          }),
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
                onChanged: widget.courseId != null
                    ? null
                    : (v) => setState(() {
                        _selectedCourse = v ?? 'All';
                      }),
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
        physics: widget.embedded ? const ClampingScrollPhysics() : null,
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
        physics: widget.embedded ? const ClampingScrollPhysics() : null,
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submissionEntry = submissions[index];
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
            submission: submissionEntry.submission,
            studentName: submissionEntry.studentName,
            assignmentTitle: submissionEntry.assignmentTitle,
            courseName: submissionEntry.courseName,
            maxGrade: submissionEntry.maxGrade,
            dueDate: submissionEntry.dueDate,
            isDark: isDark,
            animation: itemAnimation,
            onGrade: () => GradeDialog.show(
              context: context,
              submission: submissionEntry.submission,
              studentName: submissionEntry.studentName,
              assignmentTitle: submissionEntry.assignmentTitle,
              courseName: submissionEntry.courseName,
              maxGrade: submissionEntry.maxGrade,
              dueDate: submissionEntry.dueDate,
              latePenaltyPercent: submissionEntry.latePenaltyPercent,
              isDark: isDark,
              onSubmit: (grade, feedback) =>
                  _handleGradeSubmission(submissionEntry, grade, feedback),
            ),
            onViewDetails: () =>
                _showSubmissionDetails(context, submissionEntry, isDark),
          );
        },
      ),
    );
  }

  void _showSubmissionDetails(
    BuildContext context,
    _SubmissionEntry submissionEntry,
    bool isDark,
  ) {
    final submission = submissionEntry.submission;
    final studentEmail = submission.user?.email.trim() ?? '';
    final lateDays = _calculateLateDays(submissionEntry);
    final submissionText = submission.submissionText?.trim() ?? '';
    final submissionLink = submission.submissionLink?.trim() ?? '';
    final feedback = submission.feedback?.trim() ?? '';
    final driveFile = submission.driveFile;
    final fileName = driveFile?.fileName.trim().isNotEmpty == true
        ? driveFile!.fileName
        : (submission.fileId != null
              ? 'Attached file #${submission.fileId}'
              : '');

    HapticFeedback.lightImpact();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.68,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: GradingColors.cardColor(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GradingColors.borderColor(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: GradingColors.primary.withValues(
                            alpha: 0.14,
                          ),
                          child: Text(
                            submissionEntry.studentName.isNotEmpty
                                ? submissionEntry.studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: GradingColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                submissionEntry.studentName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: GradingColors.textPrimaryColor(isDark),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                submissionEntry.assignmentTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: GradingColors.textSecondaryColor(
                                    isDark,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: GradingColors.textSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: GradingColors.borderColor(isDark)),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        _buildDetailsTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Student',
                          value: studentEmail.isNotEmpty
                              ? '${submissionEntry.studentName} ($studentEmail)'
                              : submissionEntry.studentName,
                          isDark: isDark,
                        ),
                        _buildDetailsTile(
                          icon: Icons.class_rounded,
                          label: 'Course',
                          value: submissionEntry.courseName,
                          isDark: isDark,
                        ),
                        _buildDetailsTile(
                          icon: Icons.assignment_outlined,
                          label: 'Status',
                          value: _formatSubmissionStatus(
                            submission.submissionStatus,
                          ),
                          isDark: isDark,
                        ),
                        _buildDetailsTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'Submitted',
                          value: _formatDateTime(submission.submittedAt),
                          isDark: isDark,
                        ),
                        _buildDetailsTile(
                          icon: Icons.repeat_rounded,
                          label: 'Attempt',
                          value: 'Attempt ${submission.attemptNumber}',
                          isDark: isDark,
                        ),
                        if (submission.isLate)
                          _buildDetailsTile(
                            icon: Icons.warning_amber_rounded,
                            label: 'Late Submission',
                            value: '$lateDays day(s) late',
                            valueColor: GradingColors.late,
                            isDark: isDark,
                          ),
                        if (submission.score != null)
                          _buildDetailsTile(
                            icon: Icons.grade_rounded,
                            label: 'Current Grade',
                            value:
                                '${_formatScore(submission.score!)} / ${submissionEntry.maxGrade}',
                            isDark: isDark,
                          ),
                        if (feedback.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildLongTextBlock(
                            icon: Icons.feedback_outlined,
                            label: 'Feedback',
                            value: feedback,
                            isDark: isDark,
                          ),
                        ],
                        if (submissionText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildLongTextBlock(
                            icon: Icons.notes_rounded,
                            label: 'Text Submission',
                            value: submissionText,
                            isDark: isDark,
                          ),
                        ],
                        if (submissionLink.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildDetailsTile(
                            icon: Icons.link_rounded,
                            label: 'Link Submission',
                            value: submissionLink,
                            isDark: isDark,
                            isLink: true,
                            onTap: () => _openExternalUrl(submissionLink),
                          ),
                        ],
                        if (fileName.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildFileSection(
                            fileName: fileName,
                            openUrl: driveFile?.webViewLink ?? '',
                            downloadUrl: driveFile?.downloadUrl ?? '',
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    final valueTextStyle = TextStyle(
      color: valueColor ?? GradingColors.textPrimaryColor(isDark),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.35,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: GradingColors.textTertiaryColor(isDark)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: GradingColors.textTertiaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                if (isLink)
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Text(
                      value,
                      style: valueTextStyle.copyWith(
                        color: GradingColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(value, style: valueTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTextBlock({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GradingColors.surfaceColor(
          isDark,
        ).withValues(alpha: isDark ? 0.35 : 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GradingColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: GradingColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: GradingColors.textTertiaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: TextStyle(
              color: GradingColors.textPrimaryColor(isDark),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSection({
    required String fileName,
    required String openUrl,
    required String downloadUrl,
    required bool isDark,
  }) {
    final hasOpenUrl = openUrl.trim().isNotEmpty;
    final hasDownloadUrl = downloadUrl.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GradingColors.surfaceColor(
          isDark,
        ).withValues(alpha: isDark ? 0.35 : 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GradingColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 18,
                color: GradingColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                'File Submission',
                style: TextStyle(
                  color: GradingColors.textTertiaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            style: TextStyle(
              color: GradingColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Size: unavailable',
            style: TextStyle(
              color: GradingColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
          if (hasOpenUrl || hasDownloadUrl) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (hasOpenUrl)
                  OutlinedButton.icon(
                    onPressed: () => _openExternalUrl(openUrl),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Preview'),
                  ),
                if (hasDownloadUrl)
                  OutlinedButton.icon(
                    onPressed: () => _openExternalUrl(downloadUrl),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(String rawUrl) async {
    final normalizedUrl = rawUrl.trim();
    if (normalizedUrl.isEmpty) {
      _showInlineMessage('No link available for this submission.');
      return;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      _showInlineMessage('Invalid URL format.');
      return;
    }

    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      _showInlineMessage('No app available to open this link.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showInlineMessage('No app available to open this link.');
      }
    } catch (_) {
      _showInlineMessage('Failed to open link.');
    }
  }

  void _showInlineMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  int _calculateLateDays(_SubmissionEntry submissionEntry) {
    if (!submissionEntry.submission.isLate) {
      return 0;
    }

    final lateDuration = submissionEntry.submission.submittedAt.difference(
      submissionEntry.dueDate,
    );

    if (lateDuration.isNegative) {
      return 1;
    }

    final lateDays = (lateDuration.inHours / 24).ceil();
    return lateDays <= 0 ? 1 : lateDays;
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatScore(double score) {
    if (score == score.roundToDouble()) {
      return score.toInt().toString();
    }
    return score.toStringAsFixed(1);
  }

  String _formatSubmissionStatus(api.SubmissionStatus status) {
    switch (status) {
      case api.SubmissionStatus.submitted:
        return 'Submitted';
      case api.SubmissionStatus.graded:
        return 'Graded';
      case api.SubmissionStatus.returned:
        return 'Returned';
      case api.SubmissionStatus.resubmit:
        return 'Resubmitted';
      case api.SubmissionStatus.unknown:
        return 'Unknown';
    }
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 0.0;

        return SingleChildScrollView(
          physics: widget.embedded ? const ClampingScrollPhysics() : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
            ),
          ),
        );
      },
    );
  }
}

class _SubmissionEntry {
  const _SubmissionEntry({
    required this.submission,
    required this.studentName,
    required this.assignmentTitle,
    required this.courseName,
    required this.maxGrade,
    required this.dueDate,
    required this.latePenaltyPercent,
  });

  final AssignmentSubmissionModel submission;
  final String studentName;
  final String assignmentTitle;
  final String courseName;
  final int maxGrade;
  final DateTime dueDate;
  final double latePenaltyPercent;

  _SubmissionEntry copyWith({AssignmentSubmissionModel? submission}) {
    return _SubmissionEntry(
      submission: submission ?? this.submission,
      studentName: studentName,
      assignmentTitle: assignmentTitle,
      courseName: courseName,
      maxGrade: maxGrade,
      dueDate: dueDate,
      latePenaltyPercent: latePenaltyPercent,
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
