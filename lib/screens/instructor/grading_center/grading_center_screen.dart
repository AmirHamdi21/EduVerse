import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/features/walkthrough/instructor_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_target.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../models/instructor/teaching_course_model.dart';
import '../../../common/utils/responsive.dart';
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/student/shared/drive_file_preview_screen.dart';
import '../../../widgets/student/academic/academic_list_skeleton.dart';

class GradingCenterScreen extends StatefulWidget {
  const GradingCenterScreen({super.key, this.courseId, this.embedded = false});

  final int? courseId;
  final bool embedded;

  @override
  State<GradingCenterScreen> createState() => _GradingCenterScreenState();
}

enum _GradingSubmissionFilter { all, pending, graded, late }

class _GradingCenterScreenState extends State<GradingCenterScreen> {
  late final AssignmentService _assignmentService;
  late final EnrollmentService _enrollmentService;

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  List<TeachingCourseModel> _teachingCourses = <TeachingCourseModel>[];
  List<_SubmissionEntry> _submissions = <_SubmissionEntry>[];

  int? _selectedCourseId;
  _GradingSubmissionFilter _selectedFilter = _GradingSubmissionFilter.all;

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient(storageService: StorageService());
    _assignmentService = AssignmentService(coreApiClient: coreApiClient);
    _enrollmentService = EnrollmentService(coreApiClient: coreApiClient);
    _selectedCourseId = widget.courseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadSubmissions();
    });
  }

  Future<void> _loadSubmissions({bool refresh = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final failureMessage = AppLocalizations.of(context).operationFailed;
      final teachingCoursesResult = await _enrollmentService
          .getTeachingCourses();
      if (!teachingCoursesResult.isSuccess ||
          teachingCoursesResult.data == null) {
        throw Exception(teachingCoursesResult.error?.message ?? failureMessage);
      }

      final relevantCourses = teachingCoursesResult.data!
          .where(
            (course) =>
                widget.courseId == null || course.courseId == widget.courseId,
          )
          .toList(growable: false);

      final entries = <_SubmissionEntry>[];

      for (final teachingCourse in relevantCourses) {
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

          for (final submission in submissionsResult.data!) {
            entries.add(
              _SubmissionEntry(
                courseId: teachingCourse.courseId,
                courseCode: teachingCourse.course.code.trim(),
                courseName: teachingCourse.course.name.trim(),
                sectionCode: teachingCourse.section.sectionNumber.trim(),
                assignment: assignment,
                submission: submission,
                studentName: _resolveStudentName(submission),
                studentEmail: submission.user?.email.trim() ?? '',
              ),
            );
          }
        }
      }

      entries.sort(
        (left, right) =>
            right.submission.submittedAt.compareTo(left.submission.submittedAt),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _teachingCourses = relevantCourses;
        _submissions = entries;
        if (widget.courseId != null) {
          _selectedCourseId = widget.courseId;
        } else if (_selectedCourseId != null &&
            !_teachingCourses.any(
              (course) => course.courseId == _selectedCourseId,
            )) {
          _selectedCourseId = null;
        }
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = error.toString();
      });
    }
  }

  String _resolveStudentName(AssignmentSubmissionModel submission) {
    final firstName = submission.user?.firstName.trim() ?? '';
    final lastName = submission.user?.lastName.trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = submission.user?.email.trim() ?? '';
    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return AppLocalizations.of(
      context,
    ).gradingCenterStudentFallback(submission.userId);
  }

  List<_SubmissionEntry> get _courseScopedSubmissions {
    return _submissions
        .where(
          (entry) =>
              _selectedCourseId == null || entry.courseId == _selectedCourseId,
        )
        .toList(growable: false);
  }

  List<_SubmissionEntry> get _filteredSubmissions {
    return _courseScopedSubmissions
        .where((entry) {
          switch (_selectedFilter) {
            case _GradingSubmissionFilter.pending:
              return !entry.isGraded;
            case _GradingSubmissionFilter.graded:
              return entry.isGraded;
            case _GradingSubmissionFilter.late:
              return entry.submission.isLate;
            case _GradingSubmissionFilter.all:
              return true;
          }
        })
        .toList(growable: false);
  }

  Map<int, List<_SubmissionEntry>> get _groupedSubmissions {
    final grouped = <int, List<_SubmissionEntry>>{};
    for (final entry in _filteredSubmissions) {
      grouped
          .putIfAbsent(entry.courseId, () => <_SubmissionEntry>[])
          .add(entry);
    }
    return grouped;
  }

  int get _totalCourses => _teachingCourses.length;
  int get _pendingCount =>
      _courseScopedSubmissions.where((entry) => !entry.isGraded).length;
  int get _gradedCount =>
      _courseScopedSubmissions.where((entry) => entry.isGraded).length;
  int get _lateCount =>
      _courseScopedSubmissions.where((entry) => entry.submission.isLate).length;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        final content = RefreshIndicator(
          onRefresh: () => _loadSubmissions(refresh: true),
          color: InstructorColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              if (!widget.embedded) _buildAppBar(isDark, l10n),
              if (_isLoading && _submissions.isEmpty) ...<Widget>[
                _buildLoadingHeader(isDark),
                _buildLoadingSkeleton(isDark),
              ] else if (_errorMessage != null && _submissions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(isDark),
                )
              else if (!_isLoading && _teachingCourses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildNoCoursesState(isDark),
                )
              else
                _buildLoadedContent(isDark, l10n),
            ],
          ),
        );

        if (widget.embedded) {
          return Container(
            color: InstructorColors.background(isDark),
            child: content,
          );
        }

        return InstructorWalkthroughRouteMarker(
          segmentId: InstructorWalkthroughIds.grading,
          child: Scaffold(
            backgroundColor: InstructorColors.background(isDark),
            body: SafeArea(child: content),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: InstructorColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: _safeBackToDashboard,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: InstructorColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.gradingCenter,
        style: TextStyle(
          color: InstructorColors.textPrimaryColor(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
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

  void _safeBackToDashboard() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/instructor/dashboard');
    }
  }

  SliverToBoxAdapter _buildLoadingHeader(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark
              ? InstructorColors.darkHeaderGradient
              : const LinearGradient(
                  colors: <Color>[
                    Color(0xFF155CFB),
                    Color(0xFF3B82F6),
                    Color(0xFF14B8A6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.gradingCenterHeroTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.gradingCenterHeroSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingSkeleton(bool isDark) {
    return SliverToBoxAdapter(
      child: IgnorePointer(
        child: AcademicListSkeleton(
          isDark: isDark,
          itemCount: 4,
          topPadding: 16,
          bottomPadding: 24,
          sliverFriendly: true,
        ),
      ),
    );
  }

  SliverMainAxisGroup _buildLoadedContent(bool isDark, AppLocalizations l10n) {
    final grouped = _groupedSubmissions;
    final courseIds = grouped.keys.toList(growable: false);

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: InstructorWalkthroughIds.gradingHeader,
            child: _buildSummaryHeader(isDark, l10n),
          ),
        ),
        SliverToBoxAdapter(
          child: WalkthroughTarget(
            id: InstructorWalkthroughIds.gradingFilters,
            child: _buildFilterCard(isDark, l10n),
          ),
        ),
        if (courseIds.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptySubmissionsState(isDark, l10n),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final courseId = courseIds[index];
                final entries = grouped[courseId] ?? const <_SubmissionEntry>[];
                final card = Padding(
                  padding: EdgeInsets.only(
                    bottom: index == courseIds.length - 1 ? 0 : 16,
                  ),
                  child: _buildCourseSubmissionCard(isDark, l10n, entries),
                );
                if (index == 0) {
                  return WalkthroughTarget(
                    id: InstructorWalkthroughIds.gradingList,
                    child: card,
                  );
                }
                return card;
              }, childCount: courseIds.length),
            ),
          ),
        if (_isRefreshing)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: LinearProgressIndicator(
                color: InstructorColors.primary,
                backgroundColor: InstructorColors.primary.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(999),
                minHeight: 4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(bool isDark, AppLocalizations l10n) {
    final r = context.responsive;
    final totalSubmissions = _courseScopedSubmissions.length;
    final statCards = <_HeroStat>[
      _HeroStat(
        icon: Icons.menu_book_rounded,
        label: l10n.gradingCenterCoursesStat,
        value: _totalCourses.toString(),
        color: const Color(0xFF22C55E),
      ),
      _HeroStat(
        icon: Icons.assignment_turned_in_rounded,
        label: l10n.gradingCenterSubmissionsStat,
        value: totalSubmissions.toString(),
        color: const Color(0xFFD946EF),
      ),
      _HeroStat(
        icon: Icons.pending_actions_rounded,
        label: l10n.pending,
        value: _pendingCount.toString(),
        color: InstructorColors.warning,
      ),
      _HeroStat(
        icon: Icons.check_circle_rounded,
        label: l10n.graded,
        value: _gradedCount.toString(),
        color: InstructorColors.success,
      ),
      _HeroStat(
        icon: Icons.timer_off_rounded,
        label: l10n.late,
        value: _lateCount.toString(),
        color: InstructorColors.error,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: EdgeInsets.all(r.isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorColors.darkHeaderGradient
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF155CFB),
                  Color(0xFF3B82F6),
                  Color(0xFF14B8A6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -22,
            right: -18,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -14,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: r.isMobile ? 36 : 40,
                    height: r.isMobile ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fact_check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.gradingCenterHeroTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.isMobile ? 16 : 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.gradingCenterHeroSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: r.isMobile ? 10.5 : 11.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statCards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _heroStatsColumns(r),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: r.isMobile ? 1.5 : 1.95,
                ),
                itemBuilder: (context, index) {
                  return _buildHeroStatCard(statCards[index], r);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _heroStatsColumns(ResponsiveUtil r) {
    if (r.screenWidth < 340) {
      return 2;
    }
    if (r.isMobile || r.isTablet) {
      return 3;
    }
    return 5;
  }

  Widget _buildHeroStatCard(_HeroStat stat, ResponsiveUtil r) {
    return Container(
      padding: EdgeInsets.all(r.isMobile ? 9 : 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(stat.icon, size: r.isMobile ? 15 : 17, color: stat.color),
          const SizedBox(height: 6),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: r.isMobile ? 14 : 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xE6FFFFFF),
              fontSize: r.isMobile ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(bool isDark, AppLocalizations l10n) {
    final totalFiltered = _filteredSubmissions.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.9),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.gradingCenterSubmissionsCount(totalFiltered),
              style: const TextStyle(
                color: InstructorColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildModernDropdown<int?>(
                  isDark: isDark,
                  title: l10n.gradingCenterCourseFilterLabel,
                  icon: Icons.menu_book_rounded,
                  value: _selectedCourseId,
                  selectedLabel: _selectedCourseLabel(l10n),
                  items: <DropdownMenuItem<int?>>[
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.allCourses),
                    ),
                    ..._teachingCourses.map((course) {
                      return DropdownMenuItem<int?>(
                        value: course.courseId,
                        child: Text(_courseChipLabel(course)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernDropdown<_GradingSubmissionFilter>(
                  isDark: isDark,
                  title: l10n.gradingCenterStatusFilterLabel,
                  icon: Icons.tune_rounded,
                  value: _selectedFilter,
                  selectedLabel: _filterLabel(l10n, _selectedFilter),
                  items: _GradingSubmissionFilter.values
                      .map((filter) {
                        return DropdownMenuItem<_GradingSubmissionFilter>(
                          value: filter,
                          child: Text(_filterLabel(l10n, filter)),
                        );
                      })
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSubmissionCard(
    bool isDark,
    AppLocalizations l10n,
    List<_SubmissionEntry> entries,
  ) {
    final r = context.responsive;
    final course = entries.first;

    return Container(
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: InstructorColors.borderColor(isDark).withValues(alpha: 0.82),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(
              r.isMobile ? 14 : 16,
              r.isMobile ? 14 : 16,
              r.isMobile ? 14 : 16,
              r.isMobile ? 14 : 18,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  const Color(0xFFEAF3FF),
                  InstructorColors.tealLight.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: r.isMobile ? 42 : 46,
                  height: r.isMobile ? 42 : 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF14B8A6), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _courseBadgeLabel(course.courseCode, course.courseName),
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.isMobile ? 15 : 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        course.courseCode,
                        style: TextStyle(
                          color: InstructorColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: r.isMobile ? 10.5 : 11.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.courseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: r.isMobile ? 13 : 14.5,
                          height: 1.2,
                        ),
                      ),
                      if (course.sectionCode.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          course.sectionCode,
                          style: TextStyle(
                            color: InstructorColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: r.isMobile ? 10.5 : 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.isMobile ? 10 : 12,
                    vertical: r.isMobile ? 7 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: InstructorColors.successLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.gradingCenterSubmissionsCount(entries.length),
                    style: TextStyle(
                      color: InstructorColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: r.isMobile ? 10.5 : 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: <Widget>[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: InstructorColors.borderColor(isDark),
                  ),
                _buildSubmissionRow(isDark, l10n, item),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubmissionRow(
    bool isDark,
    AppLocalizations l10n,
    _SubmissionEntry entry,
  ) {
    final badge = _statusBadge(entry);
    final r = context.responsive;
    final gradeText = entry.submission.score == null
        ? l10n.gradingCenterNotGradedYet
        : '${_formatScore(entry.submission.score!)} / ${entry.assignment.maxGrade.toStringAsFixed(entry.assignment.maxGrade.truncateToDouble() == entry.assignment.maxGrade ? 0 : 1)}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 50,
                height: r.isMobile ? 46 : 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: InstructorColors.primary, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(entry.studentName),
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w800,
                              fontSize: r.isMobile ? 15 : 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusChip(badge),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.assignment.title,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: InstructorColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildMetaItem(
                    icon: Icons.calendar_today_rounded,
                    text: _formatRelativeDate(entry.submission.submittedAt),
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildMetaItem(
                    icon: entry.submission.driveFile != null
                        ? Icons.attach_file_rounded
                        : entry.submission.submissionLink?.trim().isNotEmpty ==
                              true
                        ? Icons.link_rounded
                        : Icons.notes_rounded,
                    text: entry.submission.driveFile != null
                        ? l10n.gradingCenterSubmissionTypeFile
                        : entry.submission.submissionLink?.trim().isNotEmpty ==
                              true
                        ? l10n.gradingCenterSubmissionTypeLink
                        : l10n.gradingCenterSubmissionTypeText,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildMetaItem(
                    icon: Icons.repeat_rounded,
                    text: l10n.gradingCenterAttemptNumber(
                      entry.submission.attemptNumber,
                    ),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  InstructorColors.successLight.withValues(alpha: 0.92),
                  InstructorColors.tealLight.withValues(alpha: 0.84),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: InstructorColors.success.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: InstructorColors.success,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.submission.score == null
                        ? '--'
                        : _letterFromScore(
                            entry.submission.score!,
                            entry.assignment.maxGrade,
                          ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        gradeText,
                        style: const TextStyle(
                          color: InstructorColors.success,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: entry.submission.score == null
                              ? 0
                              : (entry.submission.score! /
                                        entry.assignment.maxGrade)
                                    .clamp(0, 1),
                          minHeight: 6,
                          color: InstructorColors.success,
                          backgroundColor: Colors.white.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    entry.submission.score == null
                        ? l10n.pending
                        : '${((entry.submission.score! / entry.assignment.maxGrade) * 100).round()}%',
                    style: const TextStyle(
                      color: InstructorColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openDetailsSheet(entry),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(l10n.viewDetails),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.primary,
                    side: BorderSide(
                      color: InstructorColors.primary.withValues(alpha: 0.30),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openGradeSheet(entry),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(
                    entry.submission.score == null
                        ? l10n.grade
                        : l10n.editGrade,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: InstructorColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: InstructorColors.textTertiaryColor(isDark)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(_StatusBadge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badge.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badge.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            badge.label,
            style: TextStyle(
              color: badge.foreground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _StatusBadge _statusBadge(_SubmissionEntry entry) {
    if (entry.isGraded) {
      return _StatusBadge(
        label: AppLocalizations.of(context).graded,
        foreground: InstructorColors.success,
        background: InstructorColors.successLight,
      );
    }
    if (entry.submission.isLate) {
      return _StatusBadge(
        label: AppLocalizations.of(context).late,
        foreground: InstructorColors.error,
        background: InstructorColors.errorLight,
      );
    }
    return _StatusBadge(
      label: AppLocalizations.of(context).pending,
      foreground: InstructorColors.warning,
      background: InstructorColors.warningLight,
    );
  }

  Widget _buildErrorState(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: InstructorColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 46,
                color: InstructorColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.gradingCenterLoadErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? l10n.tryAgain,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadSubmissions,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: FilledButton.styleFrom(
                backgroundColor: InstructorColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCoursesState(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: InstructorColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 48,
                color: InstructorColors.info,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.gradingCenterNoCoursesAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubmissionsState(bool isDark, AppLocalizations l10n) {
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedFilter) {
      case _GradingSubmissionFilter.pending:
        title = l10n.noPendingSubmissions;
        subtitle = l10n.gradingCenterPendingEmptySubtitle;
        icon = Icons.pending_actions_rounded;
        break;
      case _GradingSubmissionFilter.graded:
        title = l10n.noGradedSubmissions;
        subtitle = l10n.gradingCenterGradedEmptySubtitle;
        icon = Icons.check_circle_outline_rounded;
        break;
      case _GradingSubmissionFilter.late:
        title = l10n.noLateSubmissions;
        subtitle = l10n.gradingCenterLateEmptySubtitle;
        icon = Icons.schedule_rounded;
        break;
      case _GradingSubmissionFilter.all:
        title = l10n.noSubmissionsFound;
        subtitle = l10n.gradingCenterAllEmptySubtitle;
        icon = Icons.inbox_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: InstructorColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetailsSheet(_SubmissionEntry entry) async {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);
    final studentInfo = entry.studentEmail.isNotEmpty
        ? '${entry.studentName} (${entry.studentEmail})'
        : entry.studentName;
    final fileName = entry.submission.driveFile?.fileName.trim() ?? '';
    final submissionText = entry.submission.submissionText?.trim() ?? '';
    final submissionLink = entry.submission.submissionLink?.trim() ?? '';
    final feedback = entry.submission.feedback?.trim() ?? '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          minChildSize: 0.56,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: InstructorColors.cardColor(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: InstructorColors.borderColor(isDark),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: InstructorColors.primary.withValues(
                              alpha: 0.10,
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(entry.studentName),
                            style: const TextStyle(
                              color: InstructorColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                entry.studentName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: InstructorColors.textPrimaryColor(
                                    isDark,
                                  ),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.assignment.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: InstructorColors.textSecondaryColor(
                                    isDark,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: InstructorColors.textSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      children: <Widget>[
                        _buildSheetSection(
                          isDark: isDark,
                          icon: Icons.dashboard_customize_rounded,
                          title: l10n.gradingCenterSubmissionSnapshot,
                          child: Column(
                            children: <Widget>[
                              _buildDetailRow(
                                isDark,
                                l10n.gradingCenterStudentLabel,
                                studentInfo,
                              ),
                              _buildDetailRow(
                                isDark,
                                l10n.gradingCenterCourseLabel,
                                '${entry.courseCode} - ${entry.courseName}',
                              ),
                              _buildDetailRow(
                                isDark,
                                l10n.gradingCenterStatusLabel,
                                _statusBadge(entry).label,
                              ),
                              _buildDetailRow(
                                isDark,
                                l10n.gradingCenterSubmittedLabel,
                                _formatFullDate(entry.submission.submittedAt),
                              ),
                              _buildDetailRow(
                                isDark,
                                l10n.gradingCenterAttemptLabel,
                                l10n.gradingCenterAttemptNumber(
                                  entry.submission.attemptNumber,
                                ),
                              ),
                              _buildDetailRow(
                                isDark,
                                l10n.gradingCenterCurrentGradeLabel,
                                entry.submission.score == null
                                    ? l10n.gradingCenterNotGradedYet
                                    : '${_formatScore(entry.submission.score!)} / ${entry.assignment.maxGrade.toStringAsFixed(entry.assignment.maxGrade.truncateToDouble() == entry.assignment.maxGrade ? 0 : 1)}',
                              ),
                            ],
                          ),
                        ),
                        if (feedback.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          _buildSheetSection(
                            isDark: isDark,
                            icon: Icons.feedback_outlined,
                            title: l10n.feedback,
                            child: Text(
                              feedback,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                        if (submissionText.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          _buildSheetSection(
                            isDark: isDark,
                            icon: Icons.notes_rounded,
                            title: l10n.gradingCenterTextSubmissionTitle,
                            child: SelectableText(
                              submissionText,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                        if (submissionLink.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          _buildSheetSection(
                            isDark: isDark,
                            icon: Icons.link_rounded,
                            title: l10n.gradingCenterLinkSubmissionTitle,
                            child: InkWell(
                              onTap: () => _openExternalUrl(submissionLink),
                              child: Text(
                                submissionLink,
                                style: const TextStyle(
                                  color: InstructorColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (fileName.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          _buildSheetSection(
                            isDark: isDark,
                            icon: Icons.attach_file_rounded,
                            title: l10n.gradingCenterFileSubmissionTitle,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  fileName,
                                  style: TextStyle(
                                    color: InstructorColors.textPrimaryColor(
                                      isDark,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: <Widget>[
                                    if ((entry.submission.driveFile?.webViewLink
                                                .trim() ??
                                            '')
                                        .isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            openDriveFilePreviewScreen(
                                              sheetContext,
                                              file: entry.submission.driveFile!,
                                              isDark: isDark,
                                            ),
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                        ),
                                        label: Text(l10n.preview),
                                      ),
                                    if ((entry.submission.driveFile?.downloadUrl
                                                .trim() ??
                                            '')
                                        .isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () => _openExternalUrl(
                                          entry
                                              .submission
                                              .driveFile!
                                              .downloadUrl,
                                        ),
                                        icon: const Icon(
                                          Icons.download_rounded,
                                        ),
                                        label: Text(
                                          l10n.studentCourseDetailDownload,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _buildSheetSection({
    required bool isDark,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: InstructorColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: InstructorColors.textTertiaryColor(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGradeSheet(_SubmissionEntry entry) async {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final r = context.responsive;
    final scoreController = TextEditingController(
      text: entry.submission.score == null
          ? ''
          : _formatScore(entry.submission.score!),
    );
    final feedbackController = TextEditingController(
      text: entry.submission.feedback ?? '',
    );
    String? errorText;
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submitGrade() async {
              final rawScore = scoreController.text.trim();
              final parsedScore = double.tryParse(rawScore);
              if (parsedScore == null ||
                  parsedScore < 0 ||
                  parsedScore > entry.assignment.maxGrade) {
                setModalState(() {
                  errorText = l10n.gradingCenterInvalidGradeRange(
                    entry.assignment.maxGrade.toStringAsFixed(
                      entry.assignment.maxGrade.truncateToDouble() ==
                              entry.assignment.maxGrade
                          ? 0
                          : 1,
                    ),
                  );
                });
                return;
              }

              setModalState(() {
                errorText = null;
                isSubmitting = true;
              });

              final result = await _assignmentService.gradeSubmission(
                entry.assignment.assignmentId,
                entry.submission.id,
                parsedScore,
                feedback: feedbackController.text.trim().isEmpty
                    ? null
                    : feedbackController.text.trim(),
              );

              if (!mounted) {
                return;
              }

              if (!result.isSuccess) {
                setModalState(() {
                  isSubmitting = false;
                  errorText =
                      result.error?.message ?? l10n.gradingCenterSaveFailed;
                });
                return;
              }

              setState(() {
                final index = _submissions.indexWhere(
                  (item) => item.submission.id == entry.submission.id,
                );
                if (index != -1) {
                  _submissions[index] = _submissions[index].copyWith(
                    submission: AssignmentSubmissionModel(
                      id: entry.submission.id,
                      assignmentId: entry.submission.assignmentId,
                      userId: entry.submission.userId,
                      submissionText: entry.submission.submissionText,
                      submissionLink: entry.submission.submissionLink,
                      fileId: entry.submission.fileId,
                      submissionStatus: api.SubmissionStatus.graded,
                      isLate: entry.submission.isLate,
                      attemptNumber: entry.submission.attemptNumber,
                      submittedAt: entry.submission.submittedAt,
                      score: parsedScore,
                      feedback: feedbackController.text.trim().isEmpty
                          ? null
                          : feedbackController.text.trim(),
                      gradedBy: entry.submission.gradedBy,
                      gradedAt: DateTime.now(),
                      user: entry.submission.user,
                      driveFile: entry.submission.driveFile,
                    ),
                  );
                }
              });

              HapticFeedback.mediumImpact();
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
              if (!mounted) {
                return;
              }
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.gradeSubmitted),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: InstructorColors.success,
                ),
              );
            }

            final quickScores = <int>[100, 90, 80, 70, 60, 50];
            final currentPercent = entry.submission.score == null
                ? null
                : (entry.submission.score! / entry.assignment.maxGrade) * 100;

            final maxGradeLabel = entry.assignment.maxGrade.toStringAsFixed(
              entry.assignment.maxGrade.truncateToDouble() ==
                      entry.assignment.maxGrade
                  ? 0
                  : 1,
            );

            return Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
              ),
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: r.isMobile ? double.infinity : 640,
                      maxHeight:
                          MediaQuery.of(sheetContext).size.height *
                          (r.isMobile ? 0.66 : 0.60),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: InstructorColors.cardColor(isDark),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 46,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: InstructorColors.borderColor(isDark),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? InstructorColors.darkHeaderGradient
                                    : InstructorColors.headerGradient,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.fact_check_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          l10n.gradeSubmission,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: r.isMobile ? 19 : 21,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          entry.studentName,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.84,
                                            ),
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(sheetContext).pop(),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: InstructorColors.surfaceColor(isDark),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: InstructorColors.borderColor(isDark),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: InstructorColors.primary,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          entry.assignment.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                InstructorColors.textPrimaryColor(
                                                  isDark,
                                                ),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.5,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${entry.courseCode} - ${entry.courseName}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                InstructorColors.textSecondaryColor(
                                                  isDark,
                                                ),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    InstructorColors.primary.withValues(
                                      alpha: 0.06,
                                    ),
                                    InstructorColors.tealLight.withValues(
                                      alpha: 0.18,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: InstructorColors.borderColor(isDark),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          l10n.grade,
                                          style: TextStyle(
                                            color:
                                                InstructorColors.textPrimaryColor(
                                                  isDark,
                                                ),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (currentPercent != null)
                                        Flexible(
                                          child: _buildInfoPill(
                                            icon: Icons.analytics_rounded,
                                            label: l10n
                                                .gradingCenterCurrentScore(
                                                  currentPercent.round(),
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: InstructorColors.cardColor(
                                              isDark,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: InstructorColors.primary
                                                  .withValues(alpha: 0.18),
                                            ),
                                          ),
                                          child: TextField(
                                            controller: scoreController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color:
                                                  InstructorColors.textPrimaryColor(
                                                    isDark,
                                                  ),
                                              fontSize: r.isMobile ? 24 : 28,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.72,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          '/ $maxGradeLabel',
                                          style: TextStyle(
                                            color:
                                                InstructorColors.textSecondaryColor(
                                                  isDark,
                                                ),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: <Widget>[
                                      _buildInfoPill(
                                        icon: Icons.schedule_rounded,
                                        label: l10n.gradingCenterLatePenalty(
                                          entry.assignment.latePenaltyPercent
                                              .toStringAsFixed(0),
                                        ),
                                      ),
                                      _buildInfoPill(
                                        icon: Icons.flag_rounded,
                                        label: entry.submission.isLate
                                            ? l10n.late
                                            : l10n.pending,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: InstructorColors.cardColor(isDark),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: InstructorColors.borderColor(
                                          isDark,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          l10n.quickGrade,
                                          style: TextStyle(
                                            color:
                                                InstructorColors.textSecondaryColor(
                                                  isDark,
                                                ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: quickScores
                                              .map((percent) {
                                                final value =
                                                    ((entry
                                                            .assignment
                                                            .maxGrade *
                                                        percent) /
                                                    100);
                                                return InkWell(
                                                  onTap: () {
                                                    scoreController.text =
                                                        _formatScore(value);
                                                    setModalState(() {
                                                      errorText = null;
                                                    });
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _quickGradeColor(
                                                        percent,
                                                      ).withValues(alpha: 0.10),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            _quickGradeColor(
                                                              percent,
                                                            ).withValues(
                                                              alpha: 0.25,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '$percent%',
                                                      style: TextStyle(
                                                        color: _quickGradeColor(
                                                          percent,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(growable: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.feedback,
                              style: TextStyle(
                                color: InstructorColors.textPrimaryColor(
                                  isDark,
                                ),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: feedbackController,
                              minLines: 3,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: l10n.gradingCenterFeedbackHint,
                                filled: true,
                                fillColor: InstructorColors.cardColor(isDark),
                                contentPadding: const EdgeInsets.all(16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: InstructorColors.borderColor(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: InstructorColors.borderColor(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: InstructorColors.primary,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            if (errorText != null) ...<Widget>[
                              const SizedBox(height: 12),
                              Text(
                                errorText!,
                                style: const TextStyle(
                                  color: InstructorColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(sheetContext).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          InstructorColors.textPrimaryColor(
                                            isDark,
                                          ),
                                      side: BorderSide(
                                        color: InstructorColors.borderColor(
                                          isDark,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                    ),
                                    child: Text(l10n.cancel),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: isSubmitting
                                        ? null
                                        : submitGrade,
                                    icon: isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check_circle_rounded,
                                          ),
                                    label: Text(
                                      isSubmitting
                                          ? l10n.gradingCenterSaving
                                          : l10n.submitGrade,
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: InstructorColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                    ),
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
              ),
            );
          },
        );
      },
    );

    scoreController.dispose();
    feedbackController.dispose();
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: InstructorColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: InstructorColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).gradingCenterOpenLinkError,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _selectedCourseLabel(AppLocalizations l10n) {
    if (_selectedCourseId == null) {
      return l10n.allCourses;
    }
    final match = _teachingCourses.where(
      (course) => course.courseId == _selectedCourseId,
    );
    if (match.isEmpty) {
      return l10n.allCourses;
    }
    return _courseChipLabel(match.first);
  }

  String _courseChipLabel(TeachingCourseModel course) {
    final code = course.course.code.trim();
    final name = course.course.name.trim();
    if (code.isEmpty) {
      return name;
    }
    return '$code - $name';
  }

  String _courseBadgeLabel(String code, String name) {
    final cleanCode = code.trim();
    if (cleanCode.isNotEmpty) {
      return cleanCode;
    }

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  String _filterLabel(AppLocalizations l10n, _GradingSubmissionFilter filter) {
    switch (filter) {
      case _GradingSubmissionFilter.pending:
        return l10n.pending;
      case _GradingSubmissionFilter.graded:
        return l10n.graded;
      case _GradingSubmissionFilter.late:
        return l10n.late;
      case _GradingSubmissionFilter.all:
        return l10n.gradingCenterAllStates;
    }
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _formatRelativeDate(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes.clamp(1, 59);
      return l10n.notificationMinutesAgo(minutes);
    }
    if (difference.inHours < 24) {
      return l10n.notificationHoursAgo(difference.inHours);
    }
    if (difference.inDays < 7) {
      return l10n.notificationDaysAgo(difference.inDays);
    }
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  String _formatFullDate(DateTime date) {
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_jm().format(date);
  }

  String _formatScore(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _letterFromScore(double score, double maxGrade) {
    if (maxGrade <= 0) {
      return 'A';
    }
    final ratio = score / maxGrade;
    if (ratio >= 0.9) {
      return 'A';
    }
    if (ratio >= 0.8) {
      return 'B';
    }
    if (ratio >= 0.7) {
      return 'C';
    }
    if (ratio >= 0.6) {
      return 'D';
    }
    return 'F';
  }

  Color _quickGradeColor(int percent) {
    if (percent >= 90) {
      return InstructorColors.success;
    }
    if (percent >= 80) {
      return InstructorColors.teal;
    }
    if (percent >= 70) {
      return InstructorColors.warning;
    }
    if (percent >= 60) {
      return InstructorColors.orange;
    }
    return InstructorColors.error;
  }

  Widget _buildModernDropdown<T>({
    required bool isDark,
    required String title,
    required IconData icon,
    required T value,
    required String selectedLabel,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: InstructorColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: InstructorColors.borderColor(
                  isDark,
                ).withValues(alpha: 0.9),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: InstructorColors.borderColor(
                  isDark,
                ).withValues(alpha: 0.9),
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
            return items
                .map((_) {
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
                })
                .toList(growable: false);
          },
          items: items,
        ),
      ],
    );
  }
}

class _SubmissionEntry {
  const _SubmissionEntry({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.sectionCode,
    required this.assignment,
    required this.submission,
    required this.studentName,
    required this.studentEmail,
  });

  final int courseId;
  final String courseCode;
  final String courseName;
  final String sectionCode;
  final AssignmentModel assignment;
  final AssignmentSubmissionModel submission;
  final String studentName;
  final String studentEmail;

  bool get isGraded {
    return submission.submissionStatus == api.SubmissionStatus.graded ||
        submission.submissionStatus == api.SubmissionStatus.returned;
  }

  _SubmissionEntry copyWith({AssignmentSubmissionModel? submission}) {
    return _SubmissionEntry(
      courseId: courseId,
      courseCode: courseCode,
      courseName: courseName,
      sectionCode: sectionCode,
      assignment: assignment,
      submission: submission ?? this.submission,
      studentName: studentName,
      studentEmail: studentEmail,
    );
  }
}

class _HeroStat {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatusBadge {
  const _StatusBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}
