import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_event.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/features/walkthrough/instructor_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_target.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/instructor/dashboard/instructor_dashboard_v9_metrics.dart';
import 'package:edu_verse/widgets/instructor/dashboard/instructor_drawer_v9.dart';
import 'package:edu_verse/widgets/instructor/dashboard/instructor_liquid_glass_bottom_nav.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:edu_verse/widgets/shared/current_user_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InstructorDashboardV9Screen extends StatefulWidget {
  const InstructorDashboardV9Screen({super.key});

  @override
  State<InstructorDashboardV9Screen> createState() =>
      _InstructorDashboardV9ScreenState();
}

class _InstructorDashboardV9ScreenState
    extends State<InstructorDashboardV9Screen> {
  late final AssignmentService _assignmentService;
  late final EnrollmentService _enrollmentService;
  late final ScheduleApiService _scheduleService;

  InstructorV9Snapshot _snapshot = InstructorV9Snapshot.empty;
  List<InstructorV9EventItem> _events = const <InstructorV9EventItem>[];
  bool _isMetricsLoading = false;
  String? _metricsError;
  String? _lastCourseKey;
  bool _showAiOverview = true;
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
    _enrollmentService = EnrollmentService(coreApiClient: coreApiClient);
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
    final coursesBloc = context.read<InstructorCoursesBloc>();
    if (coursesBloc.state is! InstructorCoursesLoaded &&
        coursesBloc.state is! InstructorCoursesLoading) {
      coursesBloc.add(const LoadTeachingCourses());
      return;
    }

    final courses = InstructorDashboardV9Metrics.teachingCoursesFromState(
      coursesBloc.state,
    );
    _loadV9Data(courses);
  }

  Future<void> _refreshDashboard() async {
    final coursesBloc = context.read<InstructorCoursesBloc>();
    final notificationCubit = context.read<NotificationCubit>();
    coursesBloc.add(const LoadTeachingCourses());
    await _loadV9Data(
      InstructorDashboardV9Metrics.teachingCoursesFromState(coursesBloc.state),
      force: true,
    );
    await notificationCubit.loadNotifications();
  }

  Future<void> _loadV9Data(
    List<TeachingCourseModel> courses, {
    bool force = false,
  }) async {
    final courseKey = courses.map((course) => course.courseId).join(',');
    if (!force && courseKey == _lastCourseKey && _snapshot.courses.isNotEmpty) {
      return;
    }

    _lastCourseKey = courseKey;
    final courseSnapshot = InstructorDashboardV9Metrics.snapshotFromCourses(
      courses,
    );
    if (mounted) {
      setState(() {
        _snapshot = courseSnapshot;
        _isMetricsLoading = true;
        _metricsError = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        InstructorDashboardV9Metrics.loadSnapshot(
          courses: courses,
          assignmentService: _assignmentService,
          enrollmentService: _enrollmentService,
        ),
        InstructorDashboardV9Metrics.loadUpcomingEvents(
          scheduleService: _scheduleService,
        ),
      ]);

      if (!mounted) return;
      setState(() {
        _snapshot = results[0] as InstructorV9Snapshot;
        _events = results[1] as List<InstructorV9EventItem>;
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

        return BlocListener<InstructorCoursesBloc, InstructorCoursesState>(
          listener: (context, state) {
            if (state is InstructorCoursesLoaded) {
              _loadV9Data(state.courses);
            }
          },
          child: InstructorWalkthroughRouteMarker(
            segmentId: InstructorWalkthroughIds.dashboard,
            child: Scaffold(
              backgroundColor: _InstructorV9Colors.background(isDark),
              drawer: InstructorDrawerV9(snapshot: _snapshot),
              body: SafeArea(
                bottom: false,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _InstructorV9Colors.pageGradient(isDark),
                    ),
                  ),
                  child: Stack(
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: _handleDashboardScroll,
                        child: RefreshIndicator(
                          color: _InstructorV9Colors.purple,
                          onRefresh: _refreshDashboard,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 76),
                            children: [
                              _CenteredInstructorContent(
                                child: WalkthroughTarget(
                                  id: InstructorWalkthroughIds.dashboardTop,
                                  child: _InstructorV9TopBar(isDark: isDark),
                                ),
                              ),
                              _CenteredInstructorContent(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child:
                                      BlocBuilder<
                                        InstructorCoursesBloc,
                                        InstructorCoursesState
                                      >(
                                        builder: (context, coursesState) {
                                          final teachingCourses =
                                              InstructorDashboardV9Metrics.teachingCoursesFromState(
                                                coursesState,
                                              );

                                          return Column(
                                            children: [
                                              WalkthroughTarget(
                                                id: InstructorWalkthroughIds
                                                    .dashboardStats,
                                                child: _InstructorV9StatsCard(
                                                  isDark: isDark,
                                                  courses: teachingCourses,
                                                  snapshot: _snapshot,
                                                  isLoading: _isMetricsLoading,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              if (_showAiOverview) ...[
                                                _InstructorV9AiOverviewCard(
                                                  isDark: isDark,
                                                  snapshot: _snapshot,
                                                  onReview: () => context.push(
                                                    '/instructor/reports',
                                                  ),
                                                  onDismiss: () => setState(() {
                                                    _showAiOverview = false;
                                                  }),
                                                ),
                                                const SizedBox(height: 12),
                                              ],
                                              WalkthroughTarget(
                                                id: InstructorWalkthroughIds
                                                    .dashboardQuick,
                                                child:
                                                    _InstructorV9QuickActionsCard(
                                                      isDark: isDark,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              _InstructorV9CoursesCard(
                                                isDark: isDark,
                                                snapshot: _snapshot,
                                                isLoading: _isMetricsLoading,
                                                error: _metricsError,
                                                onRetry: () => _loadV9Data(
                                                  teachingCourses,
                                                  force: true,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              WalkthroughTarget(
                                                id: InstructorWalkthroughIds
                                                    .dashboardPending,
                                                child:
                                                    _InstructorV9PendingGradingCard(
                                                      isDark: isDark,
                                                      snapshot: _snapshot,
                                                      isLoading:
                                                          _isMetricsLoading,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              _InstructorV9UpcomingEventsCard(
                                                isDark: isDark,
                                                events: _events,
                                                isLoading: _isMetricsLoading,
                                              ),
                                              const SizedBox(height: 12),
                                              _InstructorV9AskAiButton(
                                                isDark: isDark,
                                              ),
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
                          return InstructorLiquidGlassBottomNav(
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
          ),
        );
      },
    );
  }
}

class _CenteredInstructorContent extends StatelessWidget {
  final Widget child;

  const _CenteredInstructorContent({required this.child});

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

class _InstructorV9TopBar extends StatelessWidget {
  final bool isDark;

  const _InstructorV9TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Instructor',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.menu_rounded,
            isDark: isDark,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/instructor/search'),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _InstructorV9Colors.controlSurface(isDark),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _InstructorV9Colors.hairline(isDark),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 17,
                      color: _InstructorV9Colors.mutedText(isDark),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.searchStudentsCourses,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _InstructorV9Colors.mutedText(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (previous, current) =>
                previous.unreadCount != current.unreadCount,
            builder: (context, state) {
              return _CircleButton(
                icon: Icons.notifications_rounded,
                isDark: isDark,
                badgeCount: state.unreadCount,
                onTap: () => context.push('/instructor/notifications'),
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/instructor/profile'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _InstructorV9Colors.purple,
                    _InstructorV9Colors.pink,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _InstructorV9Colors.purple.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  identity.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

class _InstructorV9StatsCard extends StatelessWidget {
  final bool isDark;
  final List<TeachingCourseModel> courses;
  final InstructorV9Snapshot snapshot;
  final bool isLoading;

  const _InstructorV9StatsCard({
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
      fallbackName: 'Instructor',
    );
    final students = InstructorDashboardV9Metrics.totalStudents(courses);
    final avg = snapshot.averageGrade;

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
              color: _InstructorV9Colors.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '$students',
                  label: l10n.students,
                  color: _InstructorV9Colors.purple,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: isLoading ? '--' : '${snapshot.pendingGrading.length}',
                  label: l10n.pending,
                  color: _InstructorV9Colors.pink,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: isLoading ? '--' : '${snapshot.atRiskCount}',
                  label: l10n.atRisk,
                  color: _InstructorV9Colors.rose,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  value: avg == null ? '--' : '${avg.round()}%',
                  label: l10n.avg,
                  color: _InstructorV9Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructorV9AiOverviewCard extends StatelessWidget {
  final bool isDark;
  final InstructorV9Snapshot snapshot;
  final VoidCallback onReview;
  final VoidCallback onDismiss;

  const _InstructorV9AiOverviewCard({
    required this.isDark,
    required this.snapshot,
    required this.onReview,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestion = _resolveSuggestion(l10n, snapshot);

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: _InstructorV9Colors.purple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aiTeachingOverview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _InstructorV9Colors.primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _InstructorV9Colors.secondaryText(isDark),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _MicroButton(
                label: l10n.review,
                isPrimary: true,
                onTap: onReview,
              ),
              const SizedBox(width: 6),
              _MicroButton(label: l10n.dismiss, onTap: onDismiss),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveSuggestion(
    AppLocalizations l10n,
    InstructorV9Snapshot snapshot,
  ) {
    if (snapshot.courses.isEmpty) {
      return '${l10n.aiTeachingOverview}: ${l10n.noCoursesYet}';
    }

    final risky = snapshot.courses.where((course) => course.atRisk > 0).toList()
      ..sort((a, b) => b.atRisk.compareTo(a.atRisk));
    if (risky.isNotEmpty) {
      final course = risky.first;
      return 'Suggestion: Review ${course.course.course.code} support plans - ${course.atRisk} ${l10n.atRisk.toLowerCase()}';
    }

    final pending =
        snapshot.courses.where((course) => course.pendingGrading > 0).toList()
          ..sort((a, b) => b.pendingGrading.compareTo(a.pendingGrading));
    if (pending.isNotEmpty) {
      final course = pending.first;
      return 'Suggestion: Grade ${course.course.course.code} submissions - ${course.pendingGrading} ${l10n.pending.toLowerCase()}';
    }

    return 'Suggestion: Your teaching queue is clear. Review analytics for the next improvement opportunity.';
  }
}

class _InstructorV9QuickActionsCard extends StatelessWidget {
  final bool isDark;

  const _InstructorV9QuickActionsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.menu_book_outlined,
        label: l10n.courses,
        route: '/instructor/courses',
        color: _InstructorV9Colors.purple,
      ),
      _QuickAction(
        icon: Icons.assignment_outlined,
        label: l10n.assigns,
        route: '/instructor/assignments',
        color: _InstructorV9Colors.pink,
      ),
      _QuickAction(
        icon: Icons.storage_outlined,
        label: l10n.qBank,
        route: '/instructor/question-bank',
        color: _InstructorV9Colors.indigo,
      ),
      _QuickAction(
        icon: Icons.description_outlined,
        label: l10n.examGen,
        route: '/instructor/exam-generator',
        color: _InstructorV9Colors.fuchsia,
      ),
      _QuickAction(
        icon: Icons.check_circle_outline_rounded,
        label: l10n.grading,
        route: '/instructor/grading',
        color: _InstructorV9Colors.rose,
      ),
      _QuickAction(
        icon: Icons.upload_file_outlined,
        label: l10n.upload,
        route: '/instructor/upload-materials',
        color: InstructorColors.primaryLighter,
      ),
      _QuickAction(
        icon: Icons.science_outlined,
        label: l10n.labs,
        route: '/instructor/labs',
        color: InstructorColors.cyan,
      ),
      // _QuickAction(
      //   icon: Icons.analytics_outlined,
      //   label: l10n.analytics,
      //   route: '/instructor/reports',
      //   color: InstructorColors.primaryDark,
      // ),
      _QuickAction(
        icon: Icons.forum_outlined,
        label: l10n.discuss,
        route: '/instructor/discussions',
        color: InstructorColors.teal,
      ),
    ];

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.quickActions, isDark: isDark),
          const SizedBox(height: 10),
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
                        child: _QuickActionTile(
                          action: action,
                          isDark: isDark,
                          onTap: () => context.push(action.route),
                        ),
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

class _InstructorV9CoursesCard extends StatelessWidget {
  final bool isDark;
  final InstructorV9Snapshot snapshot;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _InstructorV9CoursesCard({
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
            title: l10n.myCourses,
            isDark: isDark,
            actionLabel: l10n.viewAll,
            onActionTap: () => context.push('/instructor/courses'),
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
              text: l10n.noCoursesYet,
              actionLabel: l10n.viewAll,
              onTap: () => context.push('/instructor/courses'),
            )
          else
            for (var i = 0; i < courses.length; i++)
              _InstructorCourseRow(
                metrics: courses[i],
                isDark: isDark,
                isLast: i == courses.length - 1,
              ),
        ],
      ),
    );
  }
}

class _InstructorV9PendingGradingCard extends StatelessWidget {
  final bool isDark;
  final InstructorV9Snapshot snapshot;
  final bool isLoading;

  const _InstructorV9PendingGradingCard({
    required this.isDark,
    required this.snapshot,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = snapshot.pendingGrading.take(3).toList();

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.pendingGrading,
            isDark: isDark,
            badgeCount: snapshot.pendingGrading.length,
          ),
          const SizedBox(height: 6),
          if (isLoading && items.isEmpty)
            const _LoadingRows(count: 2, compact: true)
          else if (items.isEmpty)
            _CompactMessageRow(
              isDark: isDark,
              text: l10n.noPendingItems,
              actionLabel: l10n.grading,
              onTap: () => context.push('/instructor/grading'),
            )
          else
            for (final item in items)
              _PendingGradingRow(item: item, isDark: isDark),
        ],
      ),
    );
  }
}

class _InstructorV9UpcomingEventsCard extends StatelessWidget {
  final bool isDark;
  final List<InstructorV9EventItem> events;
  final bool isLoading;

  const _InstructorV9UpcomingEventsCard({
    required this.isDark,
    required this.events,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.upcomingEvents,
            isDark: isDark,
            actionLabel: l10n.calendar,
            onActionTap: () => context.push('/instructor/calendar'),
          ),
          const SizedBox(height: 6),
          if (isLoading && events.isEmpty)
            const _LoadingRows(count: 2, compact: true)
          else if (events.isEmpty)
            _CompactMessageRow(
              isDark: isDark,
              text: l10n.noUpcomingEvents,
              actionLabel: l10n.calendar,
              onTap: () => context.push('/instructor/calendar'),
            )
          else
            for (final event in events) _EventRow(event: event, isDark: isDark),
        ],
      ),
    );
  }
}

class _InstructorV9AskAiButton extends StatelessWidget {
  final bool isDark;

  const _InstructorV9AskAiButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/instructor/ai-teaching'),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _InstructorV9Colors.purple.withValues(alpha: 0.92),
                _InstructorV9Colors.pink.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _InstructorV9Colors.purple.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.askAI,
                style: const TextStyle(
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

class _InstructorCourseRow extends StatelessWidget {
  final InstructorV9CourseMetrics metrics;
  final bool isDark;
  final bool isLast;

  const _InstructorCourseRow({
    required this.metrics,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final course = metrics.course;
    final avg = InstructorDashboardV9Metrics.courseAverage(course);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : _InstructorV9Colors.innerLine(isDark),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  InstructorDashboardV9Metrics.courseTitle(course),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _InstructorV9Colors.primaryText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${course.enrolledCount} · ${avg.round()}%',
                style: TextStyle(
                  color: _InstructorV9Colors.mutedText(isDark),
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
              value: avg / 100,
              minHeight: 5,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.80),
              valueColor: const AlwaysStoppedAnimation<Color>(
                _InstructorV9Colors.purple,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              _StatusChip(
                label: '${metrics.pendingGrading} ${l10n.pending}',
                color: _InstructorV9Colors.pink,
              ),
              _StatusChip(
                label: '${metrics.newItems} ${l10n.newItems}',
                color: _InstructorV9Colors.purple,
              ),
              _StatusChip(
                label: '${metrics.activeQuizzes} ${l10n.quizzes}',
                color: _InstructorV9Colors.indigo,
              ),
              _StatusChip(
                label: '${metrics.unreadMessages} ${l10n.messages}',
                color: _InstructorV9Colors.rose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TinyActionButton(
                label: l10n.manage,
                isPrimary: true,
                onTap: () => context.push(
                  '/instructor/course-management',
                  extra: InstructorDashboardV9Metrics.toLegacyCourse(course),
                ),
              ),
              const SizedBox(width: 6),
              _TinyActionButton(
                label: l10n.materials,
                onTap: () => context.push('/instructor/upload-materials'),
              ),
              const SizedBox(width: 6),
              _MoreCourseButton(isDark: isDark, course: course),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingGradingRow extends StatelessWidget {
  final InstructorV9PendingGradingItem item;
  final bool isDark;

  const _PendingGradingRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _InstructorV9Colors.purple.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.studentName.isEmpty ? '?' : item.studentName[0],
                style: const TextStyle(
                  color: _InstructorV9Colors.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.taskLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _InstructorV9Colors.primaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.studentName} · ${InstructorDashboardV9Metrics.relativeSubmittedTime(item.submission.submittedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _InstructorV9Colors.mutedText(isDark),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _MicroButton(
            label: l10n.grade,
            isPrimary: true,
            onTap: () => context.push(
              '/instructor/assignments/${item.assignment.assignmentId}/submissions/${item.submission.id}/grading',
              extra: {
                'assignmentTitle': item.assignment.title,
                'maxScore': item.assignment.maxGrade,
                'assignmentDueDate': item.assignment.dueDate,
                'latePenaltyPercent': item.assignment.latePenaltyPercent,
                'isArchived': false,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final InstructorV9EventItem event;
  final bool isDark;

  const _EventRow({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            color: _InstructorV9Colors.purple,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _InstructorV9Colors.primaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat.MMMd(locale).format(event.date),
            style: TextStyle(
              color: _InstructorV9Colors.mutedText(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreCourseButton extends StatelessWidget {
  final bool isDark;
  final TeachingCourseModel course;

  const _MoreCourseButton({required this.isDark, required this.course});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 40,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: _InstructorV9Colors.secondaryText(isDark),
        ),
        color: isDark ? InstructorColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          switch (value) {
            case 'announcements':
              context.push('/instructor/announcements');
              break;
            case 'analytics':
              context.push('/instructor/reports');
              break;
            case 'settings':
              context.push('/instructor/settings');
              break;
            case 'archive':
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${course.course.code} ${l10n.archived}'),
                ),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          _menuItem(
            'announcements',
            Icons.campaign_outlined,
            l10n.announcements,
            isDark,
          ),
          _menuItem(
            'analytics',
            Icons.analytics_outlined,
            l10n.analytics,
            isDark,
          ),
          _menuItem('settings', Icons.settings_outlined, l10n.settings, isDark),
          _menuItem('archive', Icons.archive_outlined, l10n.archive, isDark),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    bool isDark,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: _InstructorV9Colors.secondaryText(isDark),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: TextStyle(color: _InstructorV9Colors.primaryText(isDark)),
          ),
        ],
      ),
    );
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
        color: _InstructorV9Colors.glassSurface(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _InstructorV9Colors.glassBorder(isDark)),
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
  final int? badgeCount;

  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.actionLabel,
    this.onActionTap,
    this.badgeCount,
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
              color: _InstructorV9Colors.primaryText(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (badgeCount != null && badgeCount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _InstructorV9Colors.pink.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$badgeCount',
              style: const TextStyle(
                color: _InstructorV9Colors.pink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: _InstructorV9Colors.purple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
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
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.action,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: isDark ? 0.18 : 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 17),
            ),
            const SizedBox(height: 4),
            Text(
              action.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _InstructorV9Colors.primaryText(isDark),
                fontSize: 9,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MicroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MicroButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isPrimary
                ? _InstructorV9Colors.purple
                : _InstructorV9Colors.secondaryButton(isDark),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isPrimary
                  ? Colors.white
                  : _InstructorV9Colors.secondaryText(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _TinyActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _TinyActionButton({
    required this.label,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    return Flexible(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: isPrimary
                  ? _InstructorV9Colors.purple
                  : _InstructorV9Colors.secondaryButton(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : _InstructorV9Colors.secondaryText(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final int badgeCount;

  const _CircleButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _InstructorV9Colors.controlSurface(isDark),
            shape: BoxShape.circle,
            border: Border.all(color: _InstructorV9Colors.hairline(isDark)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: _InstructorV9Colors.primaryText(isDark),
                size: 18,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 4,
                  right: 3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _InstructorV9Colors.yellow,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isDark ? InstructorColors.darkBg : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Color(0xFF713F12),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _InstructorV9Colors.secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _TinyActionButton(label: actionLabel, onTap: onTap),
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
    final isDark = context.read<ThemeBloc>().state.isDark;
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 5 : 8),
          child: Column(
            children: [
              Container(
                height: compact ? 12 : 14,
                decoration: BoxDecoration(
                  color: _InstructorV9Colors.skeleton(isDark),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 7),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: _InstructorV9Colors.skeleton(isDark),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _InstructorV9Colors {
  static const purple = InstructorColors.primary;
  static const pink = InstructorColors.primaryLight;
  static const fuchsia = InstructorColors.info;
  static const rose = InstructorColors.error;
  static const indigo = InstructorColors.accent;
  static const yellow = InstructorColors.warning;

  static Color background(bool isDark) => InstructorColors.background(isDark);

  static List<Color> pageGradient(bool isDark) {
    if (isDark) {
      return const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)];
    }
    return const [Color(0xFFEEF5FF), Color(0xFFF8FAFC), Color(0xFFECFEFF)];
  }

  static Color glassSurface(bool isDark) => isDark
      ? InstructorColors.darkCard.withValues(alpha: 0.86)
      : Colors.white.withValues(alpha: 0.78);

  static Color glassBorder(bool isDark) => isDark
      ? InstructorColors.darkBorder.withValues(alpha: 0.45)
      : InstructorColors.border.withValues(alpha: 0.72);

  static Color controlSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : InstructorColors.primarySurface.withValues(alpha: 0.72);

  static Color secondaryButton(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.14)
      : Colors.white.withValues(alpha: 0.82);

  static Color hairline(bool isDark) => isDark
      ? InstructorColors.darkBorder.withValues(alpha: 0.55)
      : InstructorColors.border.withValues(alpha: 0.82);

  static Color innerLine(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : InstructorColors.border.withValues(alpha: 0.62);

  static Color primaryText(bool isDark) =>
      InstructorColors.textPrimaryColor(isDark);

  static Color secondaryText(bool isDark) =>
      InstructorColors.textSecondaryColor(isDark);

  static Color mutedText(bool isDark) =>
      InstructorColors.textTertiaryColor(isDark);

  static Color skeleton(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.60);
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
