import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_state.dart';
import 'package:edu_verse/bloc/ta/ta_courses_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_courses_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/shared/current_user_identity.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_dashboard_v9_metrics.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_drawer_v9.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_liquid_glass_bottom_nav.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class TADashboardV9Screen extends StatefulWidget {
  const TADashboardV9Screen({super.key});

  @override
  State<TADashboardV9Screen> createState() => _TADashboardV9ScreenState();
}

class _TADashboardV9ScreenState extends State<TADashboardV9Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final AssignmentService _assignmentService;
  late final LabService _labService;
  late final ScheduleApiService _scheduleService;

  TAV9Snapshot _snapshot = TAV9Snapshot.empty;
  bool _isMetricsLoading = false;
  String? _metricsError;
  String? _lastCourseKey;
  TAV9TaskFilter _taskFilter = TAV9TaskFilter.all;
  final ValueNotifier<bool> _bottomNavVisibleNotifier = ValueNotifier<bool>(
    true,
  );
  ScrollDirection _lastBottomNavScrollDirection = ScrollDirection.idle;
  double _bottomNavDirectionalScroll = 0;

  @override
  void initState() {
    super.initState();
    final coreApiClient = CoreApiClient(storageService: StorageService());
    _assignmentService = AssignmentService(coreApiClient: coreApiClient);
    _labService = LabService(coreApiClient: coreApiClient);
    _scheduleService = ScheduleApiService(coreApiClient: coreApiClient);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureDashboardDataLoaded();
    });
  }

  @override
  void dispose() {
    _bottomNavVisibleNotifier.dispose();
    super.dispose();
  }

  void _ensureDashboardDataLoaded() {
    final coursesCubit = context.read<TACoursesCubit>();
    final status = coursesCubit.state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>> &&
        status is! TASubTabLoading<List<TeachingCourseModel>>) {
      coursesCubit.fetchTACourses();
      return;
    }

    final courses = TADashboardV9Metrics.coursesFromState(coursesCubit.state);
    _loadV9Data(courses, coursesCubit.state.sectionStudentCounts);
  }

  Future<void> _refreshDashboard() async {
    final coursesCubit = context.read<TACoursesCubit>();
    final notificationCubit = context.read<NotificationCubit>();
    await coursesCubit.fetchTACourses();
    if (!mounted) return;
    final state = coursesCubit.state;
    await _loadV9Data(
      TADashboardV9Metrics.coursesFromState(state),
      state.sectionStudentCounts,
      force: true,
    );
    await notificationCubit.loadNotifications();
  }

  Future<void> _loadV9Data(
    List<TeachingCourseModel> courses,
    Map<int, int> sectionStudentCounts, {
    bool force = false,
  }) async {
    final courseKey = courses
        .map(
          (course) =>
              '${course.courseId}:${sectionStudentCounts[course.sectionId] ?? course.enrolledCount}',
        )
        .join(',');
    if (!force && courseKey == _lastCourseKey && _snapshot.courses.isNotEmpty) {
      return;
    }

    _lastCourseKey = courseKey;
    final fastSnapshot = TADashboardV9Metrics.snapshotFromCourses(
      courses,
      sectionStudentCounts: sectionStudentCounts,
    );

    if (mounted) {
      setState(() {
        _snapshot = fastSnapshot;
        _isMetricsLoading = true;
        _metricsError = null;
      });
    }

    try {
      final snapshot = await TADashboardV9Metrics.loadSnapshot(
        courses: courses,
        sectionStudentCounts: sectionStudentCounts,
        assignmentService: _assignmentService,
        labService: _labService,
        scheduleService: _scheduleService,
      );
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _isMetricsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isMetricsLoading = false;
        _metricsError = error.toString();
      });
    }
  }

  bool _handleDashboardScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final pixels = notification.metrics.pixels;
    if (pixels <= 16) {
      _bottomNavDirectionalScroll = 0;
      _lastBottomNavScrollDirection = ScrollDirection.idle;
      _setBottomNavVisible(true);
      return false;
    }

    if (notification is UserScrollNotification) {
      if (notification.direction != _lastBottomNavScrollDirection) {
        _bottomNavDirectionalScroll = 0;
        _lastBottomNavScrollDirection = notification.direction;
      }
      if (notification.direction == ScrollDirection.idle && pixels <= 24) {
        _setBottomNavVisible(true);
      }
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta != null && delta.abs() > 3) {
        final direction = delta > 0
            ? ScrollDirection.reverse
            : ScrollDirection.forward;
        if (direction != _lastBottomNavScrollDirection) {
          _bottomNavDirectionalScroll = 0;
          _lastBottomNavScrollDirection = direction;
        }
        _bottomNavDirectionalScroll += delta.abs();

        if (direction == ScrollDirection.reverse &&
            pixels > 96 &&
            _bottomNavDirectionalScroll > 46) {
          _setBottomNavVisible(false);
        } else if (direction == ScrollDirection.forward &&
            _bottomNavDirectionalScroll > 18) {
          _setBottomNavVisible(true);
        }
      }
    } else if (notification is ScrollEndNotification && pixels <= 24) {
      _bottomNavDirectionalScroll = 0;
      _lastBottomNavScrollDirection = ScrollDirection.idle;
      _setBottomNavVisible(true);
    }

    return false;
  }

  void _setBottomNavVisible(bool visible) {
    if (_bottomNavVisibleNotifier.value == visible) return;
    _bottomNavVisibleNotifier.value = visible;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        return BlocListener<TACoursesCubit, TACoursesState>(
          listener: (context, state) {
            final status = state.coursesStatus;
            if (status is TASubTabLoaded<List<TeachingCourseModel>>) {
              _loadV9Data(status.data, state.sectionStudentCounts);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: _TAV9Colors.background(isDark),
            drawer: TADrawerV9(snapshot: _snapshot),
            body: SafeArea(
              bottom: false,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _TAV9Colors.pageGradient(isDark),
                  ),
                ),
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: _handleDashboardScroll,
                      child: RefreshIndicator(
                        color: _TAV9Colors.primary,
                        onRefresh: _refreshDashboard,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 76),
                          children: [
                            _CenteredTAContent(
                              child: _TAV9TopBar(
                                isDark: isDark,
                                onMenuTap: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                              ),
                            ),
                            _CenteredTAContent(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child:
                                    BlocBuilder<TACoursesCubit, TACoursesState>(
                                      builder: (context, coursesState) {
                                        final courses =
                                            TADashboardV9Metrics.coursesFromState(
                                              coursesState,
                                            );
                                        final isCoursesLoading =
                                            coursesState.coursesStatus
                                                is TASubTabLoading<
                                                  List<TeachingCourseModel>
                                                >;

                                        return Column(
                                          children: [
                                            _TAV9StatsCard(
                                              isDark: isDark,
                                              courses: courses,
                                              snapshot: _snapshot,
                                              isLoading:
                                                  isCoursesLoading ||
                                                  _isMetricsLoading,
                                            ),
                                            const SizedBox(height: 12),
                                            _TAV9AiInsightsCard(
                                              isDark: isDark,
                                              snapshot: _snapshot,
                                            ),
                                            const SizedBox(height: 12),
                                            _TAV9QuickActionsCard(
                                              isDark: isDark,
                                            ),
                                            const SizedBox(height: 12),
                                            _TAV9WeeklyActivityCard(
                                              isDark: isDark,
                                              snapshot: _snapshot,
                                              isLoading: _isMetricsLoading,
                                            ),
                                            const SizedBox(height: 12),
                                            _TAV9AssignedCoursesCard(
                                              isDark: isDark,
                                              snapshot: _snapshot,
                                              isLoading:
                                                  isCoursesLoading ||
                                                  _isMetricsLoading,
                                              error: _metricsError,
                                              onRetry: () => _loadV9Data(
                                                courses,
                                                coursesState
                                                    .sectionStudentCounts,
                                                force: true,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            _TAV9TaskCenterCard(
                                              isDark: isDark,
                                              snapshot: _snapshot,
                                              isLoading: _isMetricsLoading,
                                              filter: _taskFilter,
                                              onFilterChanged: (filter) {
                                                setState(
                                                  () => _taskFilter = filter,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 12),
                                            _TAV9AskAiButton(isDark: isDark),
                                          ],
                                        );
                                      },
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _bottomNavVisibleNotifier,
                      builder: (context, isBottomNavVisible, child) {
                        return TALiquidGlassBottomNav(
                          isDark: isDark,
                          isVisible: isBottomNavVisible,
                        );
                      },
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

class _CenteredTAContent extends StatelessWidget {
  final Widget child;

  const _CenteredTAContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth >= 1100
        ? 960.0
        : screenWidth >= 700
        ? (screenWidth - 96).clamp(620.0, 860.0)
        : 460.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class _TAV9TopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onMenuTap;

  const _TAV9TopBar({required this.isDark, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Teaching Assistant',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.menu_rounded,
            isDark: isDark,
            onTap: onMenuTap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => context.push('/ta/search'),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _TAV9Colors.controlSurface(isDark),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _TAV9Colors.glassBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: _TAV9Colors.mutedText(isDark),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search tasks...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _TAV9Colors.mutedText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (previous, current) =>
                previous.unreadCount != current.unreadCount,
            builder: (context, state) {
              return _NotificationButton(
                isDark: isDark,
                count: state.unreadCount,
                onTap: () => context.push('/ta/notifications'),
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/ta/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: TAColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _TAV9Colors.primary.withValues(alpha: 0.24),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  identity.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TAV9StatsCard extends StatelessWidget {
  final bool isDark;
  final List<TeachingCourseModel> courses;
  final TAV9Snapshot snapshot;
  final bool isLoading;

  const _TAV9StatsCard({
    required this.isDark,
    required this.courses,
    required this.snapshot,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Teaching Assistant',
    );
    final tasksOpen = snapshot.tasks.length;

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.welcomeBackName(identity.displayName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _TAV9Colors.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: isLoading ? '--' : '$tasksOpen',
                  label: 'Tasks',
                  color: _TAV9Colors.primary,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: isLoading ? '--' : '${snapshot.pendingGrading}',
                  label: 'To grade',
                  color: _TAV9Colors.success,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: '${courses.length}',
                  label: l10n.courses,
                  color: _TAV9Colors.info,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: snapshot.aiTimeSaved ?? '--',
                  label: 'AI saved',
                  color: _TAV9Colors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TAV9AiInsightsCard extends StatelessWidget {
  final bool isDark;
  final TAV9Snapshot snapshot;

  const _TAV9AiInsightsCard({required this.isDark, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busiest = snapshot.courses.isEmpty ? null : snapshot.courses.first;
    final insight = busiest == null
        ? 'AI Insights: Your TA workspace is ready once assigned courses load.'
        : busiest.openTasks > 0
        ? '${busiest.openTasks} tasks need attention in ${busiest.course.course.code}.'
        : 'No urgent TA tasks right now. Review analytics for your next support opportunity.';

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: _TAV9Colors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: _TAV9Colors.primaryText(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight,
            style: TextStyle(
              color: _TAV9Colors.secondaryText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SmallActionButton(
                label: l10n.taViewFullInsights,
                color: _TAV9Colors.primary,
                onTap: () => context.push('/ta/analytics'),
              ),
              const SizedBox(width: 8),
              _SmallActionButton(
                label: 'Ask AI Help',
                color: _TAV9Colors.secondary,
                filled: false,
                onTap: () => context.push('/ta/ai-assistant'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TAV9QuickActionsCard extends StatelessWidget {
  final bool isDark;

  const _TAV9QuickActionsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.menu_book_outlined,
        label: 'Courses',
        route: '/ta/courses',
        color: _TAV9Colors.primary,
      ),
      _QuickAction(
        icon: Icons.assignment_outlined,
        label: 'Tasks',
        route: '/ta/assignments',
        color: _TAV9Colors.warning,
      ),
      _QuickAction(
        icon: Icons.fact_check_outlined,
        label: 'Exam Grade',
        route: '/ta/grading',
        color: _TAV9Colors.secondary,
      ),
      _QuickAction(
        icon: Icons.science_outlined,
        label: 'Review Labs',
        route: '/ta/labs',
        color: _TAV9Colors.success,
      ),
      _QuickAction(
        icon: Icons.quiz_outlined,
        label: 'Quizzes',
        route: '/ta/quiz-management',
        color: const Color(0xFF7C3AED),
      ),
      _QuickAction(
        icon: Icons.groups_outlined,
        label: 'Roster',
        route: '/ta/roster',
        color: _TAV9Colors.teal,
      ),
      _QuickAction(
        icon: Icons.forum_outlined,
        label: 'Discussions',
        route: '/ta/discussions',
        color: _TAV9Colors.info,
      ),
      _QuickAction(
        icon: Icons.auto_awesome_rounded,
        label: 'Ask AI Help',
        route: '/ta/ai-assistant',
        color: _TAV9Colors.pink,
      ),
    ];

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Quick actions', isDark: isDark),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth < 330
                  ? 58.0
                  : constraints.maxWidth < 600
                  ? 62.0
                  : 68.0;
              final tileHeight = constraints.maxWidth < 600 ? 62.0 : 66.0;
              return Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: constraints.maxWidth < 600 ? 8 : 10,
                  runSpacing: constraints.maxWidth < 600 ? 10 : 12,
                  children: [
                    for (final action in actions)
                      SizedBox(
                        width: tileWidth,
                        height: tileHeight,
                        child: _QuickActionTile(action: action, isDark: isDark),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TAV9WeeklyActivityCard extends StatelessWidget {
  final bool isDark;
  final TAV9Snapshot snapshot;
  final bool isLoading;

  const _TAV9WeeklyActivityCard({
    required this.isDark,
    required this.snapshot,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_ActivityMetric>[
      _ActivityMetric(
        icon: Icons.assignment_turned_in_outlined,
        value: isLoading ? '--' : '${snapshot.assignmentsGradedThisWeek}',
        label: 'Graded',
        color: _TAV9Colors.primary,
      ),
      _ActivityMetric(
        icon: Icons.science_outlined,
        value: isLoading ? '--' : '${snapshot.labsReviewedThisWeek}',
        label: 'Labs reviewed',
        color: _TAV9Colors.success,
      ),
      _ActivityMetric(
        icon: Icons.question_answer_outlined,
        value: snapshot.questionsAnswered?.toString() ?? '--',
        label: 'Q. answered',
        color: _TAV9Colors.info,
      ),
      _ActivityMetric(
        icon: Icons.calendar_month_outlined,
        value: snapshot.weeklySessions?.toString() ?? '--',
        label: 'Sessions',
        color: _TAV9Colors.teal,
      ),
      _ActivityMetric(
        icon: Icons.auto_awesome_rounded,
        value: snapshot.aiTimeSaved ?? '--',
        label: 'AI saved',
        color: _TAV9Colors.pink,
      ),
    ];

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Weekly Activity', isDark: isDark),
          const SizedBox(height: 12),
          Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: _ActivityMetricTile(item: item, isDark: isDark),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TAV9AssignedCoursesCard extends StatelessWidget {
  final bool isDark;
  final TAV9Snapshot snapshot;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _TAV9AssignedCoursesCard({
    required this.isDark,
    required this.snapshot,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final courses = snapshot.courses.take(3).toList();

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.taAssignedCourses,
            isDark: isDark,
            actionLabel: l10n.viewAll,
            onActionTap: () => context.push('/ta/courses'),
          ),
          const SizedBox(height: 6),
          if (isLoading && courses.isEmpty)
            const _LoadingRows(count: 3)
          else if (error != null && courses.isEmpty)
            _CompactMessageRow(
              isDark: isDark,
              text: error!,
              actionLabel: l10n.retry,
              onTap: onRetry,
            )
          else if (courses.isEmpty)
            _CompactMessageRow(
              isDark: isDark,
              text: l10n.taCoursesNoAssignedTitle,
              actionLabel: l10n.viewAll,
              onTap: () => context.push('/ta/courses'),
            )
          else
            for (var i = 0; i < courses.length; i++)
              _CourseRow(
                metrics: courses[i],
                isDark: isDark,
                isLast: i == courses.length - 1,
              ),
        ],
      ),
    );
  }
}

class _TAV9TaskCenterCard extends StatelessWidget {
  final bool isDark;
  final TAV9Snapshot snapshot;
  final bool isLoading;
  final TAV9TaskFilter filter;
  final ValueChanged<TAV9TaskFilter> onFilterChanged;

  const _TAV9TaskCenterCard({
    required this.isDark,
    required this.snapshot,
    required this.isLoading,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = snapshot.tasks
        .where((task) {
          switch (filter) {
            case TAV9TaskFilter.all:
              return true;
            case TAV9TaskFilter.grading:
              return task.category == TAV9TaskCategory.grading;
            case TAV9TaskFilter.review:
              return task.category == TAV9TaskCategory.review;
            case TAV9TaskFilter.discussion:
              return task.category == TAV9TaskCategory.discussion;
          }
        })
        .take(4)
        .toList();

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Task Center', isDark: isDark),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TAV9TaskFilter.values.map((item) {
                final selected = item == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _FilterChip(
                    label: item.label,
                    selected: selected,
                    isDark: isDark,
                    onTap: () => onFilterChanged(item),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading && tasks.isEmpty)
            const _LoadingRows(count: 3, compact: true)
          else if (tasks.isEmpty)
            _CompactMessageRow(
              isDark: isDark,
              text: 'No tasks need attention right now.',
              actionLabel: 'Assignments',
              onTap: () => context.push('/ta/assignments'),
            )
          else
            for (final task in tasks) _TaskRow(task: task, isDark: isDark),
        ],
      ),
    );
  }
}

class _TAV9AskAiButton extends StatelessWidget {
  final bool isDark;

  const _TAV9AskAiButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/ta/ai-assistant'),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: TAColors.aiGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _TAV9Colors.primary.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Ask AI Help',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final TAV9CourseMetrics metrics;
  final bool isDark;
  final bool isLast;

  const _CourseRow({
    required this.metrics,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final course = metrics.course;
    final title = TADashboardV9Metrics.courseTitle(course);
    final progress = (metrics.openTasks * 8).clamp(6, 100).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _TAV9Colors.innerLine(isDark),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _TAV9Colors.primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${metrics.openTasks} tasks',
                style: TextStyle(
                  color: _TAV9Colors.secondaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 4,
              backgroundColor: _TAV9Colors.controlSurface(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(_TAV9Colors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SmallActionButton(
                  label: 'Open',
                  color: _TAV9Colors.primary,
                  onTap: () => context.push('/ta/course/${course.courseId}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SmallActionButton(
                  label: 'Tasks',
                  color: _TAV9Colors.secondary,
                  filled: false,
                  onTap: () =>
                      context.push('/ta/grading?courseId=${course.courseId}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final TAV9TaskItem task;
  final bool isDark;

  const _TaskRow({required this.task, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _TAV9Colors.innerLine(isDark))),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _priorityColor(task.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _TAV9Colors.primaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.courseLabel} • ${task.dueLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _TAV9Colors.mutedText(isDark),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _SmallActionButton(
            label: 'Start',
            icon: Icons.play_arrow_rounded,
            color: _TAV9Colors.primary,
            onTap: () => context.push(task.route),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TAV9TaskPriority priority) {
    switch (priority) {
      case TAV9TaskPriority.high:
        return _TAV9Colors.error;
      case TAV9TaskPriority.medium:
        return _TAV9Colors.warning;
      case TAV9TaskPriority.low:
        return _TAV9Colors.primary;
    }
  }
}

class _GlassPanel extends StatelessWidget {
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GlassPanel({
    required this.isDark,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _TAV9Colors.glassSurface(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _TAV9Colors.glassBorder(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _TAV9Colors.primaryText(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: TAColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _TAV9Colors.mutedText(
              Theme.of(context).brightness == Brightness.dark,
            ),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  final bool isDark;

  const _QuickActionTile({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(action.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 17),
          ),
          const SizedBox(height: 5),
          Text(
            action.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _TAV9Colors.primaryText(isDark),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityMetricTile extends StatelessWidget {
  final _ActivityMetric item;
  final bool isDark;

  const _ActivityMetricTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, color: item.color, size: 18),
        const SizedBox(height: 5),
        Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: item.color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _TAV9Colors.mutedText(isDark),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : Colors.white.withValues(alpha: 0.76),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: filled ? Colors.white : color),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled ? Colors.white : color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : _TAV9Colors.secondaryText(isDark),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      selectedColor: _TAV9Colors.primary,
      backgroundColor: _TAV9Colors.controlSurface(isDark),
      side: BorderSide(color: _TAV9Colors.glassBorder(isDark)),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onTap(),
    );
  }
}

class _CompactMessageRow extends StatelessWidget {
  final bool isDark;
  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  const _CompactMessageRow({
    required this.isDark,
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _TAV9Colors.controlSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _TAV9Colors.innerLine(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _TAV9Colors.secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _LoadingRows extends StatelessWidget {
  final int count;
  final bool compact;

  const _LoadingRows({required this.count, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(count, (index) {
        return Container(
          height: compact ? 34 : 58,
          margin: EdgeInsets.only(bottom: index == count - 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: _TAV9Colors.skeleton(isDark),
            borderRadius: BorderRadius.circular(14),
          ),
        );
      }),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _TAV9Colors.controlSurface(isDark),
            shape: BoxShape.circle,
            border: Border.all(color: _TAV9Colors.glassBorder(isDark)),
          ),
          child: Icon(icon, size: 19, color: _TAV9Colors.primaryText(isDark)),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool isDark;
  final int count;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.isDark,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CircleButton(
          icon: Icons.notifications_none_rounded,
          isDark: isDark,
          onTap: onTap,
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -1,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _TAV9Colors.warning,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isDark ? TAColors.darkBg : Colors.white,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Color(0xFF713F12),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class _ActivityMetric {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ActivityMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

enum TAV9TaskFilter {
  all('All'),
  grading('Grading'),
  review('Review'),
  discussion('Discussion');

  final String label;
  const TAV9TaskFilter(this.label);
}

class _TAV9Colors {
  static const primary = TAColors.primary;
  static const secondary = TAColors.secondary;
  static const success = TAColors.success;
  static const info = TAColors.info;
  static const teal = TAColors.teal;
  static const pink = TAColors.pink;
  static const warning = TAColors.warning;
  static const error = TAColors.error;

  static Color background(bool isDark) => TAColors.background(isDark);

  static List<Color> pageGradient(bool isDark) {
    if (isDark) {
      return const [TAColors.darkBg, Color(0xFF1E1E3F), TAColors.darkCard];
    }
    return const [
      TAColors.primarySurface,
      TAColors.surface,
      TAColors.accentLight,
    ];
  }

  static Color glassSurface(bool isDark) => isDark
      ? TAColors.darkCard.withValues(alpha: 0.86)
      : Colors.white.withValues(alpha: 0.78);

  static Color glassBorder(bool isDark) => isDark
      ? TAColors.darkBorder.withValues(alpha: 0.45)
      : TAColors.border.withValues(alpha: 0.72);

  static Color controlSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : TAColors.primarySurface.withValues(alpha: 0.72);

  static Color innerLine(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : TAColors.border.withValues(alpha: 0.62);

  static Color primaryText(bool isDark) => TAColors.textPrimaryColor(isDark);

  static Color secondaryText(bool isDark) =>
      TAColors.textSecondaryColor(isDark);

  static Color mutedText(bool isDark) => TAColors.textTertiaryColor(isDark);

  static Color skeleton(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.60);
}
