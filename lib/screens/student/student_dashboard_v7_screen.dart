import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/bloc/assignments/assignment_event.dart';
import 'package:edu_verse/bloc/assignments/assignment_state.dart';
import 'package:edu_verse/bloc/attendance/attendance_cubit.dart';
import 'package:edu_verse/bloc/attendance/attendance_state.dart';
import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:edu_verse/bloc/courses/courses_event.dart';
import 'package:edu_verse/bloc/courses/courses_state.dart';
import 'package:edu_verse/bloc/grades/grades_cubit.dart';
import 'package:edu_verse/bloc/grades/grades_state.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/widgets/shared/current_user_identity.dart';
import 'package:edu_verse/widgets/student/dashboard/student_dashboard_metrics.dart';
import 'package:edu_verse/widgets/student/dashboard/student_drawer.dart';
import 'package:edu_verse/widgets/student/dashboard/student_liquid_glass_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class StudentDashboardV7Screen extends StatefulWidget {
  const StudentDashboardV7Screen({super.key});

  @override
  State<StudentDashboardV7Screen> createState() =>
      _StudentDashboardV7ScreenState();
}

class _StudentDashboardV7ScreenState extends State<StudentDashboardV7Screen> {
  final ValueNotifier<bool> _bottomNavVisibleNotifier = ValueNotifier<bool>(
    true,
  );
  ScrollDirection _lastBottomNavScrollDirection = ScrollDirection.idle;
  double _bottomNavDirectionalScroll = 0;

  @override
  void initState() {
    super.initState();
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
    final coursesBloc = context.read<CoursesBloc>();
    if (coursesBloc.state is! CoursesLoaded &&
        coursesBloc.state is! CoursesLoading) {
      coursesBloc.add(const StudentCoursesFetched());
    }

    final assignmentBloc = context.read<AssignmentBloc>();
    final assignmentState = assignmentBloc.state;
    if (assignmentState.assignments.isEmpty && !assignmentState.isListLoading) {
      assignmentBloc.add(const FetchAssignments(courseId: null));
    }
  }

  Future<void> _refreshDashboard() async {
    context.read<CoursesBloc>().add(const StudentCoursesFetched());
    context.read<AssignmentBloc>().add(
      const RefreshAssignments(courseId: null),
    );
    await Future.wait<void>([
      context.read<GradesCubit>().refreshGrades(),
      context.read<AttendanceCubit>().loadAttendance(),
      context.read<NotificationCubit>().loadNotifications(),
    ]);
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

        return Scaffold(
          backgroundColor: _DashboardColors.background(isDark),
          drawer: const StudentDrawer(),
          body: SafeArea(
            bottom: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _DashboardColors.pageGradient(isDark),
                ),
              ),
              child: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: _handleDashboardScroll,
                    child: RefreshIndicator(
                      color: _DashboardColors.primaryBlue,
                      onRefresh: _refreshDashboard,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 76),
                        children: [
                          _CenteredDashboardContent(
                            child: _StudentV7TopBar(isDark: isDark),
                          ),
                          _CenteredDashboardContent(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  _StudentV7StatsCard(isDark: isDark),
                                  const SizedBox(height: 12),
                                  _StudentV7QuickAccessCard(isDark: isDark),
                                  const SizedBox(height: 12),
                                  _StudentV7CoursesCard(isDark: isDark),
                                  const SizedBox(height: 12),
                                  _StudentV7InsightCard(isDark: isDark),
                                  const SizedBox(height: 12),
                                  _StudentV7TodoCard(isDark: isDark),
                                  const SizedBox(height: 12),
                                  _StudentV7AskAiButton(isDark: isDark),
                                ],
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
                      return StudentLiquidGlassBottomNav(
                        isDark: isDark,
                        isVisible: isBottomNavVisible,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CenteredDashboardContent extends StatelessWidget {
  final Widget child;

  const _CenteredDashboardContent({required this.child});

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

class _StudentV7TopBar extends StatelessWidget {
  final bool isDark;

  const _StudentV7TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Student',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.menu_rounded,
            isDark: isDark,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _DashboardColors.controlSurface(isDark),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _DashboardColors.hairline(isDark)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 17,
                      color: _DashboardColors.mutedText(isDark),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.searchCoursesTasks,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _DashboardColors.mutedText(isDark),
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
              return _CircleIconButton(
                icon: Icons.notifications_rounded,
                isDark: isDark,
                badgeCount: state.unreadCount,
                onTap: () => context.push('/notifications'),
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _DashboardColors.primaryBlueLight,
                    _DashboardColors.aiPurple,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _DashboardColors.primaryBlue.withValues(alpha: 0.25),
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

class _StudentV7StatsCard extends StatelessWidget {
  final bool isDark;

  const _StudentV7StatsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Student',
    );

    return BlocBuilder<GradesCubit, GradesState>(
      builder: (context, gradesState) {
        return BlocBuilder<CoursesBloc, CoursesState>(
          builder: (context, coursesState) {
            return BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, attendanceState) {
                return BlocBuilder<AssignmentBloc, AssignmentState>(
                  builder: (context, assignmentState) {
                    final gpa = gradesState.statistics?.cumulativeGPA;
                    final attendance =
                        attendanceState.statistics?.overallPercentage;
                    final termProgress =
                        StudentDashboardMetrics.termProgressPercent(
                          coursesState,
                        );
                    final nextDue = StudentDashboardMetrics.nextDueDate(
                      assignmentState,
                    );

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
                              color: _DashboardColors.secondaryText(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniStat(
                                  value: gpa == null
                                      ? '--'
                                      : gpa.clamp(0.0, 4.0).toStringAsFixed(2),
                                  label: l10n.gpa,
                                  color: _DashboardColors.primaryBlue,
                                ),
                              ),
                              Expanded(
                                child: _MiniStat(
                                  value: attendance == null
                                      ? '--%'
                                      : '${attendance.clamp(0.0, 100.0).round()}%',
                                  label: l10n.attendance,
                                  color: _DashboardColors.cyan,
                                ),
                              ),
                              Expanded(
                                child: _MiniStat(
                                  value: termProgress == null
                                      ? '--'
                                      : '$termProgress%',
                                  label: l10n.term,
                                  color: _DashboardColors.aiPurple,
                                ),
                              ),
                              Expanded(
                                child: _MiniStat(
                                  value: nextDue == null
                                      ? '--'
                                      : _DashboardData.shortDueLabel(nextDue),
                                  label: l10n.next,
                                  color: _DashboardColors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StudentV7QuickAccessCard extends StatelessWidget {
  final bool isDark;

  const _StudentV7QuickAccessCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.menu_book_outlined,
        label: l10n.courses,
        route: '/courses',
        color: _DashboardColors.primaryBlue,
      ),
      _QuickAction(
        icon: Icons.psychology_outlined,
        label: l10n.aiQuiz,
        route: '/ai-quiz-generator',
        color: _DashboardColors.aiPurple,
      ),
      _QuickAction(
        icon: Icons.layers_outlined,
        label: l10n.flashcards,
        route: '/flashcards',
        color: _DashboardColors.cyan,
      ),
      _QuickAction(
        icon: Icons.checklist_rounded,
        label: l10n.tasks,
        route: '/tasks',
        color: _DashboardColors.amber,
      ),
      _QuickAction(
        icon: Icons.science_outlined,
        label: l10n.labs,
        route: '/labs',
        color: const Color(0xFFEC4899),
      ),
      _QuickAction(
        icon: Icons.assignment_outlined,
        label: l10n.assignments,
        route: '/assignments',
        color: const Color(0xFF4F46E5),
      ),
      _QuickAction(
        icon: Icons.forum_outlined,
        label: l10n.discussions,
        route: '/discussions',
        color: const Color(0xFF0D9488),
      ),
      _QuickAction(
        icon: Icons.auto_awesome_rounded,
        label: l10n.askAI,
        route: '/ai-chat',
        color: const Color(0xFFC026D3),
      ),
    ];

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.quickAccess, isDark: isDark),
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
                  spacing: constraints.maxWidth < 600 ? 10 : 12,
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

class _StudentV7CoursesCard extends StatelessWidget {
  final bool isDark;

  const _StudentV7CoursesCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          final enrollments = StudentDashboardMetrics.enrollmentsFromState(
            state,
          );
          final visible = enrollments.take(3).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: l10n.myCoursesSection,
                isDark: isDark,
                actionLabel: l10n.viewAll,
                onActionTap: () => context.push('/courses'),
              ),
              const SizedBox(height: 6),
              if (state is CoursesLoading && visible.isEmpty)
                const _CompactLoadingRows(count: 3)
              else if (state is CoursesError && visible.isEmpty)
                _CompactMessageRow(
                  isDark: isDark,
                  text: state.message,
                  actionLabel: l10n.retry,
                  onTap: () => context.read<CoursesBloc>().add(
                    const StudentCoursesFetched(),
                  ),
                )
              else if (visible.isEmpty)
                _CompactMessageRow(
                  isDark: isDark,
                  text: l10n.noCoursesYet,
                  actionLabel: l10n.viewAll,
                  onTap: () => context.push('/courses'),
                )
              else
                for (var i = 0; i < visible.length; i++)
                  _CourseRow(
                    enrollment: visible[i],
                    isDark: isDark,
                    isLast: i == visible.length - 1,
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentV7InsightCard extends StatelessWidget {
  final bool isDark;

  const _StudentV7InsightCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: BlocBuilder<GradesCubit, GradesState>(
        builder: (context, gradesState) {
          return BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, attendanceState) {
              final insight = _DashboardData.resolveInsight(
                l10n: l10n,
                gradesState: gradesState,
                attendanceState: attendanceState,
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _DashboardColors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: _DashboardColors.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.insight,
                          style: TextStyle(
                            color: _DashboardColors.primaryText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          insight,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _DashboardColors.secondaryText(isDark),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentV7TodoCard extends StatelessWidget {
  final bool isDark;

  const _StudentV7TodoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      child: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, assignmentState) {
          final items = _DashboardData.reminders(
            assignmentState: assignmentState,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: l10n.toDoSmartReminders,
                isDark: isDark,
                actionLabel: l10n.viewAll,
                onActionTap: () => context.push('/assignments'),
              ),
              const SizedBox(height: 6),
              if (assignmentState.isListLoading && items.isEmpty)
                const _CompactLoadingRows(count: 3, compact: true)
              else if (assignmentState.error != null && items.isEmpty)
                _CompactMessageRow(
                  isDark: isDark,
                  text: assignmentState.error!,
                  actionLabel: l10n.retry,
                  onTap: () => context.read<AssignmentBloc>().add(
                    const FetchAssignments(courseId: null),
                  ),
                )
              else if (items.isEmpty)
                _CompactMessageRow(
                  isDark: isDark,
                  text: l10n.noUpcomingTasks,
                  actionLabel: l10n.viewAll,
                  onTap: () => context.push('/assignments'),
                )
              else
                for (final item in items)
                  _ReminderRow(
                    item: item,
                    isDark: isDark,
                    onTap: () => context.push('/assignments'),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentV7AskAiButton extends StatelessWidget {
  final bool isDark;

  const _StudentV7AskAiButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/ai-chat'),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_DashboardColors.aiPurple, _DashboardColors.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _DashboardColors.aiPurple.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
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
        color: _DashboardColors.glassSurface(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _DashboardColors.glassBorder(isDark),
          width: isDark ? 1.1 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.16)
                : _DashboardColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: isDark ? 10 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
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
    final isDark = context.read<ThemeBloc>().state.isDark;
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _DashboardColors.mutedText(isDark),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
              color: _DashboardColors.primaryText(isDark),
              fontSize: 14,
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
                color: _DashboardColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
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
                color: action.color.withValues(alpha: isDark ? 0.18 : 0.12),
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
                color: _DashboardColors.primaryText(isDark),
                fontSize: 8,
                height: 1.08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseEnrollmentModel enrollment;
  final bool isDark;
  final bool isLast;

  const _CourseRow({
    required this.enrollment,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final course = enrollment.course;
    final progress = StudentDashboardMetrics.courseProgress(enrollment);
    final percent = (progress * 100).round();
    final courseId = course?.id ?? int.tryParse(enrollment.courseId) ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : _DashboardColors.innerLine(isDark),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.name ?? l10n.courses,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _DashboardColors.primaryText(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((course?.code ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        course!.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _DashboardColors.mutedText(isDark),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: _DashboardColors.secondaryText(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.75),
              valueColor: const AlwaysStoppedAnimation<Color>(
                _DashboardColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TinyActionButton(
                label: l10n.continueButton,
                isPrimary: true,
                onTap: () => context.push(
                  '/course-details',
                  extra: {'enrollment': enrollment, 'initialTab': 0},
                ),
              ),
              const SizedBox(width: 6),
              _TinyActionButton(
                label: l10n.materials,
                onTap: () => context.push(
                  '/course-details',
                  extra: {'enrollment': enrollment, 'initialTab': 0},
                ),
              ),
              const SizedBox(width: 6),
              _TinyActionButton(
                label: l10n.discussions,
                onTap: courseId <= 0
                    ? null
                    : () => context.push('/course/$courseId/discussions'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final _ReminderItem item;
  final bool isDark;
  final VoidCallback onTap;

  const _ReminderRow({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.isUrgent
                      ? _DashboardColors.red
                      : _DashboardColors.primaryBlueLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _DashboardColors.primaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.due}: ${DateFormat.MMMd(locale).format(item.dueDate)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _DashboardColors.mutedText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final int badgeCount;

  const _CircleIconButton({
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
            color: _DashboardColors.controlSurface(isDark),
            shape: BoxShape.circle,
            border: Border.all(color: _DashboardColors.hairline(isDark)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: _DashboardColors.primaryText(isDark), size: 18),
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
                      color: _DashboardColors.red,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isDark ? const Color(0xFF101827) : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
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
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: isPrimary
                  ? _DashboardColors.primaryBlue
                  : _DashboardColors.secondaryButton(isDark),
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
                      : _DashboardColors.secondaryText(isDark),
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
                color: _DashboardColors.secondaryText(isDark),
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

class _CompactLoadingRows extends StatelessWidget {
  final int count;
  final bool compact;

  const _CompactLoadingRows({required this.count, this.compact = false});

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
                  color: _DashboardColors.skeleton(isDark),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 7),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: _DashboardColors.skeleton(isDark),
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

class _DashboardData {
  static String shortDueLabel(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    if (difference.isNegative) return '0h';
    if (difference.inHours < 24) {
      return '${difference.inHours <= 0 ? 1 : difference.inHours}h';
    }
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat.MMMd().format(dueDate);
  }

  static String resolveInsight({
    required AppLocalizations l10n,
    required GradesState gradesState,
    required AttendanceState attendanceState,
  }) {
    final lowCourses =
        gradesState.courses
            .where((course) => course.currentPercentage > 0)
            .where((course) => course.currentPercentage < 70)
            .toList()
          ..sort((a, b) => a.currentPercentage.compareTo(b.currentPercentage));

    if (lowCourses.isNotEmpty) {
      final course = lowCourses.first;
      return '${l10n.weakTopic}: ${course.courseName} · ${l10n.tryReviewing} ${course.courseCode}';
    }

    final attendance = attendanceState.statistics?.overallPercentage;
    if (attendance != null && attendance < 85) {
      return '${l10n.attendance}: ${attendance.round()}% · ${l10n.tryReviewing} ${l10n.calendar}';
    }

    return '${l10n.studySuggestion}: ${l10n.youPerform} ${l10n.studying} ${l10n.inTheMorning}';
  }

  static List<_ReminderItem> reminders({
    required AssignmentState assignmentState,
  }) {
    final assignments = StudentDashboardMetrics.pendingAssignments(
      assignmentState,
    );

    return assignments.take(3).map((assignment) {
      return _ReminderItem(
        title: assignment.title,
        dueDate: assignment.dueDate,
        isUrgent:
            assignment.isOverdue ||
            assignment.dueDate.difference(DateTime.now()).inHours <= 24,
      );
    }).toList();
  }
}

class _DashboardColors {
  static const primaryBlue = Color(0xFF155CFB);
  static const primaryBlueLight = Color(0xFF2B7FFF);
  static const aiPurple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF06B6D4);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);

  static Color background(bool isDark) =>
      isDark ? const Color(0xFF0B1120) : const Color(0xFFE6EFFD);

  static List<Color> pageGradient(bool isDark) {
    if (isDark) {
      return const [Color(0xFF0B1120), Color(0xFF111C35), Color(0xFF0F172A)];
    }
    return const [Color(0xFFE6EFFD), Color(0xFFF3F7FF), Color(0xFFF1E9FF)];
  }

  static Color glassSurface(bool isDark) => isDark
      ? const Color(0xFF172442).withValues(alpha: 0.86)
      : Colors.white.withValues(alpha: 0.90);

  static Color glassBorder(bool isDark) => isDark
      ? const Color(0xFF6EA8FF).withValues(alpha: 0.18)
      : const Color(0xFFD8E4FF).withValues(alpha: 0.95);

  static Color controlSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white.withValues(alpha: 0.82);

  static Color secondaryButton(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.14)
      : const Color(0xFFF8FAFF).withValues(alpha: 0.98);

  static Color hairline(bool isDark) => isDark
      ? const Color(0xFF6EA8FF).withValues(alpha: 0.16)
      : const Color(0xFFD8E4FF).withValues(alpha: 0.95);

  static Color innerLine(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : const Color(0xFFE4ECFF).withValues(alpha: 0.95);

  static Color primaryText(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF101727);

  static Color secondaryText(bool isDark) =>
      isDark ? Colors.white70 : const Color(0xFF354152);

  static Color mutedText(bool isDark) =>
      isDark ? Colors.white54 : const Color(0xFF64748B);

  static Color skeleton(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFE2E8F0).withValues(alpha: 0.85);
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

class _ReminderItem {
  final String title;
  final DateTime dueDate;
  final bool isUrgent;

  const _ReminderItem({
    required this.title,
    required this.dueDate,
    required this.isUrgent,
  });
}
