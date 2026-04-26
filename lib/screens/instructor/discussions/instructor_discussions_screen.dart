import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/discussion/discussion_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/screens/instructor/discussions/instructor_discussion_ui.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/discussion_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';

class InstructorDiscussionsScreen extends StatefulWidget {
  const InstructorDiscussionsScreen({
    super.key,
    this.discussionService,
    this.enrollmentService,
  });

  final DiscussionService? discussionService;
  final EnrollmentService? enrollmentService;

  @override
  State<InstructorDiscussionsScreen> createState() =>
      _InstructorDiscussionsScreenState();
}

enum _CourseFilter { all, active, unanswered, pinned, locked, quiet }

enum _CourseSort { latestActivity, mostPosts, mostReplies, courseCode }

class _InstructorDiscussionsScreenState
    extends State<InstructorDiscussionsScreen> {
  late final DiscussionService _discussionService;
  late final EnrollmentService _enrollmentService;

  bool _loading = true;
  String? _errorMessage;
  List<TeachingCourseModel> _courses = const <TeachingCourseModel>[];
  List<DiscussionThread> _threads = const <DiscussionThread>[];
  _CourseFilter _selectedFilter = _CourseFilter.all;
  _CourseSort _selectedSort = _CourseSort.latestActivity;

  @override
  void initState() {
    super.initState();
    final storage = StorageService();
    final client = CoreApiClient(storageService: storage);
    _discussionService =
        widget.discussionService ?? DiscussionService(coreApiClient: client);
    _enrollmentService =
        widget.enrollmentService ?? EnrollmentService(coreApiClient: client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final coursesResult = await _enrollmentService.getTeachingCourses();
      if (!coursesResult.isSuccess) {
        throw Exception(
          coursesResult.error?.message ??
              'Failed to load teaching courses for discussions.',
        );
      }

      final threads = await _loadAllThreads();
      if (!mounted) {
        return;
      }

      setState(() {
        _courses = coursesResult.data ?? const <TeachingCourseModel>[];
        _threads = threads;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<DiscussionThread>> _loadAllThreads({int? courseId}) async {
    const limit = 50;
    var page = 1;
    var hasMore = true;
    final all = <DiscussionThread>[];

    while (hasMore && page <= 20) {
      final result = await _discussionService.getThreads(
        courseId: courseId,
        page: page,
        limit: limit,
      );
      all.addAll(result.data);
      hasMore = result.meta.hasMore;
      page += 1;
    }

    return all;
  }

  List<_CourseSummary> _buildSummaries() {
    final threadsByCourse = <int, List<DiscussionThread>>{};
    for (final thread in _threads) {
      final courseId = thread.courseId;
      if (courseId == null || courseId <= 0) {
        continue;
      }
      threadsByCourse.putIfAbsent(courseId, () => <DiscussionThread>[]).add(
        thread,
      );
    }

    final summaries = _courses.map((course) {
      final threads = threadsByCourse[course.courseId] ?? const <DiscussionThread>[];
      final latestActivity = threads.isEmpty
          ? null
          : threads
              .map((thread) => thread.updatedAt ?? thread.createdAt)
              .reduce((a, b) => a.isAfter(b) ? a : b);

      return _CourseSummary(
        course: course,
        threads: threads,
        latestActivity: latestActivity,
      );
    }).toList(growable: false);

    final filtered = summaries.where((summary) {
      switch (_selectedFilter) {
        case _CourseFilter.all:
          return true;
        case _CourseFilter.active:
          return summary.threadCount > 0;
        case _CourseFilter.unanswered:
          return summary.unansweredCount > 0;
        case _CourseFilter.pinned:
          return summary.pinnedCount > 0;
        case _CourseFilter.locked:
          return summary.lockedCount > 0;
        case _CourseFilter.quiet:
          return summary.threadCount == 0;
      }
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case _CourseSort.latestActivity:
          final aValue = a.latestActivity;
          final bValue = b.latestActivity;
          if (aValue == null && bValue == null) {
            return a.course.course.code.compareTo(b.course.course.code);
          }
          if (aValue == null) {
            return 1;
          }
          if (bValue == null) {
            return -1;
          }
          return bValue.compareTo(aValue);
        case _CourseSort.mostPosts:
          return b.threadCount.compareTo(a.threadCount);
        case _CourseSort.mostReplies:
          return b.replyCount.compareTo(a.replyCount);
        case _CourseSort.courseCode:
          return a.course.course.code.compareTo(b.course.course.code);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final r = context.responsive;
        final summaries = _buildSummaries();

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: InstructorColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  _buildAppBar(isDark, l10n),
                  if (_loading) ...<Widget>[
                    SliverToBoxAdapter(
                      child: InstructorDiscussionSummaryHeader(
                        isDark: isDark,
                        responsive: r,
                        title: l10n.instructorDiscussionHubTitle,
                        subtitle: l10n.instructorDiscussionHubSubtitle,
                        icon: Icons.forum_rounded,
                        stats: <({
                          IconData icon,
                          String label,
                          String value,
                          Color color,
                        })>[
                          (
                            icon: Icons.menu_book_rounded,
                            label: l10n.course,
                            value: '—',
                            color: InstructorColors.teal,
                          ),
                          (
                            icon: Icons.forum_rounded,
                            label: l10n.instructorDiscussionPostsLabel,
                            value: '—',
                            color: InstructorColors.accent,
                          ),
                          (
                            icon: Icons.push_pin_rounded,
                            label: l10n.instructorDiscussionPinnedLabel,
                            value: '—',
                            color: InstructorColors.warning,
                          ),
                          (
                            icon: Icons.reply_all_rounded,
                            label: l10n.instructorDiscussionRepliesLabel,
                            value: '—',
                            color: InstructorColors.success,
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _buildSkeletonCard(isDark);
                        }, childCount: 3),
                      ),
                    ),
                  ] else if (_errorMessage != null) ...<Widget>[
                    SliverFillRemaining(
                      child: InstructorDiscussionEmptyState(
                        isDark: isDark,
                        icon: Icons.error_outline_rounded,
                        title: l10n.instructorDiscussionLoadFailedTitle,
                        message: _errorMessage!,
                        action: FilledButton.icon(
                          onPressed: _loadData,
                          style: FilledButton.styleFrom(
                            backgroundColor: InstructorColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
                      ),
                    ),
                  ] else ...<Widget>[
                    SliverToBoxAdapter(
                      child: InstructorDiscussionSummaryHeader(
                        isDark: isDark,
                        responsive: r,
                        title: l10n.instructorDiscussionHubTitle,
                        subtitle: l10n.instructorDiscussionHubSubtitle,
                        icon: Icons.forum_rounded,
                        stats: _buildHeaderStats(l10n),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFilters(isDark, l10n, r, summaries.length),
                    ),
                    if (_courses.isEmpty)
                      SliverFillRemaining(
                        child: InstructorDiscussionEmptyState(
                          isDark: isDark,
                          icon: Icons.school_outlined,
                          title: l10n.instructorDiscussionNoCoursesTitle,
                          message: l10n.instructorDiscussionNoCoursesSubtitle,
                        ),
                      )
                    else if (summaries.isEmpty)
                      SliverFillRemaining(
                        child: InstructorDiscussionEmptyState(
                          isDark: isDark,
                          icon: Icons.filter_alt_off_rounded,
                          title: l10n.instructorDiscussionNoMatchingCoursesTitle,
                          message:
                              l10n.instructorDiscussionNoMatchingCoursesSubtitle,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            return _buildCourseCard(
                              context,
                              summaries[index],
                              isDark,
                              l10n,
                              r,
                              index,
                            );
                          }, childCount: summaries.length),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: InstructorColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: InstructorColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.discussions,
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
    );
  }

  List<({IconData icon, String label, String value, Color color})>
  _buildHeaderStats(AppLocalizations l10n) {
    final pinnedCount = _threads.where((thread) => thread.isPinned).length;
    final lockedCount = _threads.where((thread) => thread.isLocked).length;
    final replyCount = _threads.fold<int>(
      0,
      (total, thread) => total + thread.replyCount,
    );

    return <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.menu_book_rounded,
        label: l10n.course,
        value: '${_courses.length}',
        color: InstructorColors.teal,
      ),
      (
        icon: Icons.forum_rounded,
        label: l10n.instructorDiscussionPostsLabel,
        value: '${_threads.length}',
        color: InstructorColors.accent,
      ),
      (
        icon: Icons.push_pin_rounded,
        label: l10n.instructorDiscussionPinnedLabel,
        value: '$pinnedCount',
        color: InstructorColors.warning,
      ),
      (
        icon: Icons.lock_rounded,
        label: l10n.instructorDiscussionLockedLabel,
        value: '$lockedCount',
        color: InstructorColors.pink,
      ),
      (
        icon: Icons.reply_all_rounded,
        label: l10n.instructorDiscussionRepliesLabel,
        value: '$replyCount',
        color: InstructorColors.success,
      ),
    ];
  }

  Widget _buildFilters(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    int visibleCount,
  ) {
    return InstructorDiscussionFilterPanel(
      isDark: isDark,
      badgeLabel:
          '$visibleCount ${l10n.instructorDiscussionVisibleCoursesLabel}',
      children: <Widget>[
        Expanded(
          child: InstructorDiscussionDropdown<_CourseFilter>(
            isDark: isDark,
            label: l10n.instructorDiscussionFilterState,
            selectedLabel: _courseFilterLabel(l10n, _selectedFilter),
            value: _selectedFilter,
            icon: Icons.auto_awesome_mosaic_rounded,
            menuMaxHeight: r.screenHeight * 0.45,
            items: _CourseFilter.values
                .map(
                  (filter) => DropdownMenuItem<_CourseFilter>(
                    value: filter,
                    child: Text(
                      _courseFilterLabel(l10n, filter),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedFilter = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InstructorDiscussionDropdown<_CourseSort>(
            isDark: isDark,
            label: l10n.instructorDiscussionSortBy,
            selectedLabel: _courseSortLabel(l10n, _selectedSort),
            value: _selectedSort,
            icon: Icons.swap_vert_rounded,
            menuMaxHeight: r.screenHeight * 0.45,
            items: _CourseSort.values
                .map(
                  (sort) => DropdownMenuItem<_CourseSort>(
                    value: sort,
                    child: Text(
                      _courseSortLabel(l10n, sort),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedSort = value);
            },
          ),
        ),
      ],
    );
  }

  String _courseFilterLabel(AppLocalizations l10n, _CourseFilter filter) {
    switch (filter) {
      case _CourseFilter.all:
        return l10n.instructorDiscussionFilterAllCourses;
      case _CourseFilter.active:
        return l10n.instructorDiscussionFilterWithPosts;
      case _CourseFilter.unanswered:
        return l10n.instructorDiscussionFilterNeedsReplies;
      case _CourseFilter.pinned:
        return l10n.instructorDiscussionFilterPinned;
      case _CourseFilter.locked:
        return l10n.instructorDiscussionFilterLocked;
      case _CourseFilter.quiet:
        return l10n.instructorDiscussionFilterQuiet;
    }
  }

  String _courseSortLabel(AppLocalizations l10n, _CourseSort sort) {
    switch (sort) {
      case _CourseSort.latestActivity:
        return l10n.instructorDiscussionSortLatestActivity;
      case _CourseSort.mostPosts:
        return l10n.instructorDiscussionSortMostPosts;
      case _CourseSort.mostReplies:
        return l10n.instructorDiscussionSortMostReplies;
      case _CourseSort.courseCode:
        return l10n.instructorDiscussionSortCourseCode;
    }
  }

  Widget _buildCourseCard(
    BuildContext context,
    _CourseSummary summary,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    int index,
  ) {
    final latestThread = summary.latestThread;
    final gradient = instructorDiscussionAccentGradient(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: instructorDiscussionCardDecoration(
        isDark,
        highlighted: summary.unansweredCount > 0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openCourse(context, summary),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        instructorDiscussionInitials(
                          summary.course.course.code,
                          summary.course.course.name,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          summary.course.course.code,
                          style: const TextStyle(
                            color: InstructorColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.course.course.name,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontSize: r.isMobile ? 20 : 22,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.instructorDiscussionSectionLabel} ${summary.course.section.sectionNumber} • ${summary.course.semester.name}',
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: InstructorColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${summary.threadCount} ${l10n.instructorDiscussionPostsLabel}',
                      style: const TextStyle(
                        color: InstructorColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  InstructorDiscussionMetricChip(
                    color: InstructorColors.accent,
                    icon: Icons.forum_rounded,
                    label:
                        '${summary.threadCount} ${l10n.instructorDiscussionPostsLabel}',
                  ),
                  InstructorDiscussionMetricChip(
                    color: InstructorColors.success,
                    icon: Icons.reply_all_rounded,
                    label:
                        '${summary.replyCount} ${l10n.instructorDiscussionRepliesLabel}',
                  ),
                  InstructorDiscussionMetricChip(
                    color: InstructorColors.warning,
                    icon: Icons.push_pin_rounded,
                    label:
                        '${summary.pinnedCount} ${l10n.instructorDiscussionPinnedLabel}',
                  ),
                  if (summary.unansweredCount > 0)
                    InstructorDiscussionMetricChip(
                      color: InstructorColors.orange,
                      icon: Icons.help_center_rounded,
                      label:
                          '${summary.unansweredCount} ${l10n.instructorDiscussionNeedsRepliesShort}',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? InstructorColors.surfaceColor(isDark).withValues(
                          alpha: 0.75,
                        )
                      : const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: InstructorColors.borderColor(isDark).withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: latestThread == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.instructorDiscussionNoPostsCardTitle,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.instructorDiscussionNoPostsCardSubtitle,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(isDark),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.instructorDiscussionLatestPostLabel,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            latestThread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latestThread.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(isDark),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: InstructorColors.textTertiaryColor(
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  instructorDiscussionFormatDate(
                                    context,
                                    summary.latestActivity,
                                  ),
                                  style: TextStyle(
                                    color: InstructorColors.textTertiaryColor(
                                      isDark,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OutlinedButton.icon(
                  onPressed: () => _openCourse(context, summary),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: InstructorColors.primary,
                    side: BorderSide(
                      color: InstructorColors.primary.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(l10n.instructorDiscussionOpenCourse),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCourse(BuildContext context, _CourseSummary summary) async {
    await context.push(
      '/instructor/course/${summary.course.courseId}/discussions',
      extra: <String, dynamic>{'course': summary.course},
    );
    if (!mounted) {
      return;
    }
    await _loadData();
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: instructorDiscussionCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(5, (index) {
          final widths = <double>[58, 180, double.infinity, 140, 112];
          final heights = <double>[58, 20, 14, 14, 40];
          return Padding(
            padding: EdgeInsets.only(bottom: index == 4 ? 0 : 12),
            child: Container(
              width: widths[index],
              height: heights[index],
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(index == 0 ? 18 : 10),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CourseSummary {
  const _CourseSummary({
    required this.course,
    required this.threads,
    required this.latestActivity,
  });

  final TeachingCourseModel course;
  final List<DiscussionThread> threads;
  final DateTime? latestActivity;

  int get threadCount => threads.length;

  int get replyCount => threads.fold<int>(
    0,
    (total, thread) => total + thread.replyCount,
  );

  int get pinnedCount => threads.where((thread) => thread.isPinned).length;

  int get lockedCount => threads.where((thread) => thread.isLocked).length;

  int get unansweredCount =>
      threads.where((thread) => thread.replyCount == 0).length;

  DiscussionThread? get latestThread {
    if (threads.isEmpty) {
      return null;
    }

    final sorted = threads.toList(growable: false)
      ..sort(
        (a, b) =>
            (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt),
      );
    return sorted.first;
  }
}
