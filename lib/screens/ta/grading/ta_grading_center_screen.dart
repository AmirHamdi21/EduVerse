import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/ta/ta_courses_cubit.dart';
import '../../../bloc/ta/ta_courses_state.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/storage_service.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/instructor/grading/grade_dialog.dart';
import '../../../widgets/shared/submission_detail_viewer.dart';

/// TA Grading Center — displays all submissions across TA's assigned courses.
/// Mirrors instructor's GradingCenterScreen but adapted for TA role.
class TAGradingCenterScreen extends StatefulWidget {
  const TAGradingCenterScreen({
    super.key,
    this.courseId,
    this.embedded = false,
  });

  final int? courseId;
  final bool embedded;

  @override
  State<TAGradingCenterScreen> createState() => _TAGradingCenterScreenState();
}

class _TAGradingCenterScreenState extends State<TAGradingCenterScreen>
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

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient(storageService: StorageService());
    _assignmentService = AssignmentService(coreApiClient: coreApiClient);
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
      // Get TA courses from cubit
      final cubit = context.read<TACoursesCubit>();
      if (cubit.state.coursesStatus
          is! TASubTabLoaded<List<TeachingCourseModel>>) {
        await cubit.fetchTACourses();
      }

      final teachingCoursesResult = cubit.state.coursesStatus;
      if (teachingCoursesResult is! TASubTabLoaded<List<TeachingCourseModel>>) {
        throw Exception('Failed to load teaching courses');
      }

      final loadedCourses = <String>['All'];
      final loadedSubmissions = <_SubmissionEntry>[];

      for (final teachingCourse in teachingCoursesResult.data) {
        if (widget.courseId != null &&
            teachingCourse.courseId != widget.courseId) {
          continue;
        }

        final courseLabel = _buildCourseLabel(
          teachingCourse.course.courseCode,
          teachingCourse.course.courseName,
        );
        if (!loadedCourses.contains(courseLabel)) {
          loadedCourses.add(courseLabel);
        }

        final assignmentsResult = await _assignmentService.getAll(
          courseId: teachingCourse.courseId,
          page: 1,
          limit: 50,
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
            backgroundColor: TAColors.error,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save grade'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: TAColors.error,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        final idx = _submissions.indexWhere(
          (s) => s.submission.id == submissionId,
        );
        if (idx >= 0) {
          _submissions[idx] = _SubmissionEntry(
            submission: _copySubmissionWithGrade(
              submissionEntry.submission,
              grade,
              feedback,
            ),
            studentName: submissionEntry.studentName,
            assignmentTitle: submissionEntry.assignmentTitle,
            courseName: submissionEntry.courseName,
            maxGrade: submissionEntry.maxGrade,
            dueDate: submissionEntry.dueDate,
            latePenaltyPercent: submissionEntry.latePenaltyPercent,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Grade saved successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: TAColors.success,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadSubmissions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          appBar: widget.embedded
              ? null
              : AppBar(
                  backgroundColor: TAColors.scaffoldColor(isDark),
                  leading: IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/ta/dashboard');
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: TAColors.textPrimaryColor(isDark),
                    ),
                  ),
                  title: Text(
                    'Grading Center',
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => context.read<ThemeBloc>().add(
                        const ToggleThemeEvent(),
                      ),
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: TAColors.primary),
                )
              : Column(
                  children: [
                    _buildStatsBar(isDark),
                    _buildFilterTabs(isDark, l10n),
                    _buildSearchBar(isDark),
                    _buildCourseFilter(isDark),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSubmissionList('all', isDark),
                          _buildSubmissionList('pending', isDark),
                          _buildSubmissionList('graded', isDark),
                          _buildSubmissionList('late', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatsBar(bool isDark) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            border: Border(
              bottom: BorderSide(color: TAColors.borderColor(isDark), width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildStatItem(
                'Pending',
                _pendingCount,
                TAColors.warning,
                isDark,
                _statsAnimation.value,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                'Graded',
                _gradedCount,
                TAColors.success,
                isDark,
                _statsAnimation.value,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                'Late',
                _lateCount,
                TAColors.error,
                isDark,
                _statsAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    int count,
    Color color,
    bool isDark,
    double animationValue,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '${(count * animationValue).round()}',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark, AppLocalizations l10n) {
    return Container(
      color: TAColors.scaffoldColor(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TAColors.borderColor(isDark), width: 1),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: TAColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: TAColors.textSecondaryColor(isDark),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Graded'),
            Tab(text: 'Late'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        decoration: InputDecoration(
          hintText: 'Search submissions...',
          prefixIcon: Icon(
            Icons.search,
            color: TAColors.textSecondaryColor(isDark),
          ),
          filled: true,
          fillColor: TAColors.cardColor(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseFilter(bool isDark) {
    if (_courses.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _courses.map((course) {
            final isSelected = course == _selectedCourse;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(course),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCourse = course);
                },
                selectedColor: TAColors.primary.withValues(alpha: 0.2),
                checkmarkColor: TAColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? TAColors.primary
                      : TAColors.textPrimaryColor(isDark),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubmissionList(String filter, bool isDark) {
    final filtered = _getFilteredSubmissions(filter);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: TAColors.textTertiaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No submissions found',
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _listAnimController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listAnimController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_listAnimController),
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: TAColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final entry = filtered[index];
                  return _buildSubmissionCard(entry, isDark);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmissionCard(_SubmissionEntry entry, bool isDark) {
    final isGraded = _isGradedStatus(entry.submission.submissionStatus);
    final statusColor = isGraded
        ? TAColors.success
        : entry.submission.isLate
        ? TAColors.error
        : TAColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isGraded
                        ? Icons.check_circle_rounded
                        : entry.submission.isLate
                        ? Icons.warning_amber_rounded
                        : Icons.pending_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.studentName,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.assignmentTitle,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        entry.courseName,
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isGraded && entry.submission.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: TAColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.submission.score!.toStringAsFixed(1)}/${entry.maxGrade}',
                      style: TextStyle(
                        color: TAColors.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewSubmissionDetails(entry),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TAColors.primary,
                      side: BorderSide(
                        color: TAColors.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openGradeDialog(entry),
                    icon: Icon(
                      isGraded ? Icons.edit_rounded : Icons.grading_rounded,
                      size: 16,
                    ),
                    label: Text(isGraded ? 'Edit Grade' : 'Grade'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TAColors.primary,
                      side: BorderSide(
                        color: TAColors.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Future<void> _viewSubmissionDetails(_SubmissionEntry entry) async {
    await SubmissionDetailViewer.showAssignment(
      context: context,
      submission: entry.submission,
      studentName: entry.studentName,
      assignmentTitle: entry.assignmentTitle,
      maxGrade: entry.maxGrade.toDouble(),
      onGrade: (grade, feedback) async {
        await _handleGradeSubmission(entry, grade, feedback);
      },
    );
  }

  Future<void> _openGradeDialog(_SubmissionEntry entry) async {
    await GradeDialog.show(
      context: context,
      submission: entry.submission,
      studentName: entry.studentName,
      assignmentTitle: entry.assignmentTitle,
      courseName: entry.courseName,
      maxGrade: entry.maxGrade,
      dueDate: entry.dueDate,
      latePenaltyPercent: entry.latePenaltyPercent,
      isDark: Theme.of(context).brightness == Brightness.dark,
      onSubmit: (grade, feedback) async {
        await _handleGradeSubmission(entry, grade, feedback);
      },
    );
  }
}

class _SubmissionEntry {
  final AssignmentSubmissionModel submission;
  final String studentName;
  final String assignmentTitle;
  final String courseName;
  final int maxGrade;
  final DateTime? dueDate;
  final double latePenaltyPercent;

  const _SubmissionEntry({
    required this.submission,
    required this.studentName,
    required this.assignmentTitle,
    required this.courseName,
    required this.maxGrade,
    this.dueDate,
    this.latePenaltyPercent = 0,
  });
}
