import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/assignments/assignment_bloc.dart';
import '../../../bloc/assignments/assignment_event.dart';
import '../../../bloc/assignments/assignment_state.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/courses/courses_bloc.dart';
import '../../../bloc/courses/courses_event.dart';
import '../../../bloc/courses/courses_state.dart';
import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../shared/current_user_identity.dart';
import 'student_dashboard_metrics.dart';

class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  final Set<String> _expandedCategoryIds = <String>{'overview', 'learning'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureDrawerDataLoaded();
    });
  }

  void _ensureDrawerDataLoaded() {
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

    final notificationCubit = context.read<NotificationCubit>();
    if (notificationCubit.state.status == NotificationLoadingStatus.initial) {
      notificationCubit.loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final currentPath = GoRouterState.of(context).uri.path;
        final sections = _buildSections(l10n);

        return Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _DrawerColors.pageGradient(isDark),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _DrawerProfileHeader(isDark: isDark),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DrawerStatsCard(isDark: isDark),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      physics: const BouncingScrollPhysics(),
                      children: sections.map((section) {
                        final isExpanded = _expandedCategoryIds.contains(
                          section.id,
                        );
                        return _DrawerCategory(
                          section: section,
                          isDark: isDark,
                          isExpanded: isExpanded,
                          currentPath: currentPath,
                          onToggle: () {
                            setState(() {
                              if (_expandedCategoryIds.contains(section.id)) {
                                _expandedCategoryIds.remove(section.id);
                              } else {
                                _expandedCategoryIds.add(section.id);
                              }
                            });
                          },
                          onItemTap: (item) => _openDrawerItem(
                            currentPath: currentPath,
                            item: item,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _DrawerBottomSection(isDark: isDark),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDrawerItem({
    required String currentPath,
    required _DrawerItem item,
  }) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    if (item.matches(currentPath)) return;
    router.push(item.route);
  }

  List<_DrawerSection> _buildSections(AppLocalizations l10n) {
    return [
      _DrawerSection(
        id: 'overview',
        title: l10n.drawerOverview,
        icon: Icons.space_dashboard_rounded,
        items: [
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            title: l10n.dashboard,
            route: '/dashboard',
          ),
          _DrawerItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            title: l10n.calendar,
            route: '/calendar',
          ),
          _DrawerItem(
            icon: Icons.app_registration_outlined,
            activeIcon: Icons.app_registration_rounded,
            title: l10n.registration,
            route: '/registration',
          ),
        ],
      ),
      _DrawerSection(
        id: 'learning',
        title: l10n.drawerLearning,
        icon: Icons.menu_book_rounded,
        items: [
          _DrawerItem(
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories_rounded,
            title: l10n.courses,
            route: '/courses',
          ),
          _DrawerItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            title: l10n.assignments,
            route: '/assignments',
          ),
          _DrawerItem(
            icon: Icons.checklist_rounded,
            activeIcon: Icons.fact_check_rounded,
            title: l10n.tasks,
            route: '/tasks',
          ),
          _DrawerItem(
            icon: Icons.science_outlined,
            activeIcon: Icons.science_rounded,
            title: l10n.labs,
            route: '/labs',
          ),
          _DrawerItem(
            icon: Icons.quiz_outlined,
            activeIcon: Icons.quiz_rounded,
            title: l10n.quizzes,
            route: '/student/quizzes',
          ),
          _DrawerItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events_rounded,
            title: l10n.grades,
            route: '/grades',
          ),
          _DrawerItem(
            icon: Icons.event_available_outlined,
            activeIcon: Icons.event_available_rounded,
            title: l10n.attendance,
            route: '/attendance',
          ),
        ],
      ),
      _DrawerSection(
        id: 'ai',
        title: l10n.drawerAiTools,
        icon: Icons.auto_awesome_rounded,
        isAi: true,
        items: [
          _DrawerItem(
            icon: Icons.psychology_outlined,
            activeIcon: Icons.psychology_rounded,
            title: l10n.aiAssistant,
            route: '/ai-chat',
            isAi: true,
          ),
          _DrawerItem(
            icon: Icons.tips_and_updates_outlined,
            activeIcon: Icons.tips_and_updates_rounded,
            title: l10n.aiQuiz,
            route: '/ai-quiz-generator',
            isAi: true,
          ),
          _DrawerItem(
            icon: Icons.layers_outlined,
            activeIcon: Icons.layers_rounded,
            title: l10n.flashcards,
            route: '/flashcards',
            isAi: true,
          ),
          _DrawerItem(
            icon: Icons.summarize_outlined,
            activeIcon: Icons.summarize_rounded,
            title: l10n.summarizerTitle,
            route: '/summarizer',
            isAi: true,
          ),
          _DrawerItem(
            icon: Icons.mic_none_rounded,
            activeIcon: Icons.mic_rounded,
            title: l10n.voiceToTextTitle,
            route: '/voice-to-text',
            isAi: true,
          ),
          _DrawerItem(
            icon: Icons.military_tech_outlined,
            activeIcon: Icons.military_tech_rounded,
            title: l10n.gamificationTitle,
            route: '/gamification',
            isAi: true,
          ),
        ],
      ),
      _DrawerSection(
        id: 'communication',
        title: l10n.drawerCommunication,
        icon: Icons.forum_rounded,
        items: [
          _DrawerItem(
            icon: Icons.forum_outlined,
            activeIcon: Icons.forum_rounded,
            title: l10n.discussions,
            route: '/discussions',
            activePrefixes: const ['/course/'],
          ),
          _DrawerItem(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            title: l10n.messages,
            route: '/messages',
          ),
          _DrawerItem(
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
            title: l10n.announcements,
            route: '/student/announcements',
          ),
          _DrawerItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            title: l10n.notifications,
            route: '/notifications',
          ),
        ],
      ),
      _DrawerSection(
        id: 'account',
        title: l10n.drawerAccount,
        icon: Icons.person_rounded,
        items: [
          _DrawerItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            title: l10n.profile,
            route: '/profile',
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            title: l10n.settings,
            route: '/settings',
          ),
        ],
      ),
    ];
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  final bool isDark;

  const _DrawerProfileHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Student',
    );

    return _DrawerGlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push('/profile');
            },
            child: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _DrawerColors.primaryBlueLight,
                        _DrawerColors.aiPurple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _DrawerColors.primaryBlue.withValues(
                          alpha: 0.24,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      identity.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: _DrawerColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _DrawerColors.glassSurface(isDark),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _DrawerColors.primaryText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _DrawerColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.activeLearner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _DrawerColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _DrawerIconButton(
            isDark: isDark,
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _DrawerStatsCard extends StatelessWidget {
  final bool isDark;

  const _DrawerStatsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _DrawerGlassCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, coursesState) {
          return BlocBuilder<AssignmentBloc, AssignmentState>(
            builder: (context, assignmentState) {
              final coursesLoading =
                  coursesState is CoursesLoading &&
                  StudentDashboardMetrics.courseCount(coursesState) == 0;
              final assignmentsLoading =
                  assignmentState.isListLoading &&
                  assignmentState.assignments.isEmpty;
              final coursesValue = coursesLoading
                  ? '--'
                  : '${StudentDashboardMetrics.courseCount(coursesState)}';
              final progressValue = coursesLoading
                  ? '--'
                  : '${StudentDashboardMetrics.averageProgressPercent(coursesState)}%';
              final tasksValue = assignmentsLoading
                  ? '--'
                  : '${StudentDashboardMetrics.pendingAssignmentCount(assignmentState)}';

              return Row(
                children: [
                  Expanded(
                    child: _DrawerStatItem(
                      isDark: isDark,
                      value: coursesValue,
                      label: l10n.courses,
                      icon: Icons.menu_book_rounded,
                      color: _DrawerColors.primaryBlue,
                    ),
                  ),
                  _DrawerStatDivider(isDark: isDark),
                  Expanded(
                    child: _DrawerStatItem(
                      isDark: isDark,
                      value: progressValue,
                      label: l10n.progress,
                      icon: Icons.trending_up_rounded,
                      color: _DrawerColors.aiPurple,
                    ),
                  ),
                  _DrawerStatDivider(isDark: isDark),
                  Expanded(
                    child: _DrawerStatItem(
                      isDark: isDark,
                      value: tasksValue,
                      label: l10n.tasks,
                      icon: Icons.task_alt_rounded,
                      color: _DrawerColors.cyan,
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

class _DrawerCategory extends StatelessWidget {
  final _DrawerSection section;
  final bool isDark;
  final bool isExpanded;
  final String currentPath;
  final VoidCallback onToggle;
  final ValueChanged<_DrawerItem> onItemTap;

  const _DrawerCategory({
    required this.section,
    required this.isDark,
    required this.isExpanded,
    required this.currentPath,
    required this.onToggle,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveItem = section.items.any(
      (item) => item.matches(currentPath),
    );
    final unreadNotifications = context.select<NotificationCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );
    final pendingAssignments = context.select<AssignmentBloc, int>(
      (bloc) => StudentDashboardMetrics.pendingAssignmentCount(bloc.state),
    );
    final accent = section.isAi
        ? _DrawerColors.aiPurple
        : _DrawerColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _DrawerGlassCard(
        isDark: isDark,
        padding: const EdgeInsets.all(6),
        radius: 20,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(section.icon, color: accent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          section.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasActiveItem
                                ? accent
                                : _DrawerColors.primaryText(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _DrawerColors.mutedText(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: section.items.map((item) {
                  return _DrawerNavItem(
                    item: item,
                    isDark: isDark,
                    isActive: item.matches(currentPath),
                    badgeCount: _badgeCountFor(
                      item,
                      unreadNotifications: unreadNotifications,
                      pendingAssignments: pendingAssignments,
                    ),
                    onTap: () => onItemTap(item),
                  );
                }).toList(),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }

  int _badgeCountFor(
    _DrawerItem item, {
    required int unreadNotifications,
    required int pendingAssignments,
  }) {
    if (item.route == '/notifications') return unreadNotifications;
    if (item.route == '/assignments' || item.route == '/tasks') {
      return pendingAssignments;
    }
    return 0;
  }
}

class _DrawerNavItem extends StatelessWidget {
  final _DrawerItem item;
  final bool isDark;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.item,
    required this.isDark,
    required this.isActive,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = item.isAi
        ? _DrawerColors.aiPurple
        : _DrawerColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        accent.withValues(alpha: 0.18),
                        accent.withValues(alpha: 0.08),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isActive
                        ? accent.withValues(alpha: 0.14)
                        : _DrawerColors.controlSurface(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? accent : _DrawerColors.mutedText(isDark),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? accent
                          : _DrawerColors.primaryText(isDark),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  _DrawerCountBadge(
                    count: badgeCount,
                    isDark: isDark,
                    color: _badgeColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _badgeColor {
    if (item.route == '/notifications') return _DrawerColors.red;
    if (item.route == '/assignments' || item.route == '/tasks') {
      return _DrawerColors.amber;
    }
    return item.isAi ? _DrawerColors.aiPurple : _DrawerColors.primaryBlue;
  }
}

class _DrawerCountBadge extends StatelessWidget {
  final int count;
  final bool isDark;
  final Color color;

  const _DrawerCountBadge({
    required this.count,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.95),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.22 : 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _DrawerBottomSection extends StatelessWidget {
  final bool isDark;

  const _DrawerBottomSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DrawerGlassCard(
          isDark: isDark,
          padding: const EdgeInsets.all(4),
          radius: 16,
          child: Row(
            children: [
              Expanded(
                child: _ThemeChoice(
                  isDark: isDark,
                  isActive: !isDark,
                  icon: Icons.light_mode_rounded,
                  label: l10n.light,
                  onTap: () {
                    if (isDark) {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    }
                  },
                ),
              ),
              Expanded(
                child: _ThemeChoice(
                  isDark: isDark,
                  isActive: isDark,
                  icon: Icons.dark_mode_rounded,
                  label: l10n.dark,
                  onTap: () {
                    if (!isDark) {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final router = GoRouter.of(context);
              final authBloc = context.read<AuthBloc>();
              Navigator.of(context).pop();
              authBloc.add(const LogoutRequested());
              router.go('/login');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _DrawerColors.red.withValues(
                  alpha: isDark ? 0.10 : 0.04,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _DrawerColors.red.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: _DrawerColors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.logout,
                    style: const TextStyle(
                      color: _DrawerColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final bool isDark;
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.isDark,
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBackground = isDark
        ? Color.lerp(_DrawerColors.primaryBlue, Colors.white, 0.12)!
        : Colors.white;
    final activeForeground = isDark ? Colors.white : _DrawerColors.primaryBlue;
    final activeBorder = isDark
        ? Color.lerp(_DrawerColors.primaryBlueLight, Colors.white, 0.36)!
        : _DrawerColors.primaryBlue.withValues(alpha: 0.24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? activeBorder : Colors.transparent,
              width: 1.1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _DrawerColors.primaryBlue.withValues(
                        alpha: isDark ? 0.32 : 0.12,
                      ),
                      blurRadius: isDark ? 16 : 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? activeForeground
                    : _DrawerColors.mutedText(isDark),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? activeForeground
                        : _DrawerColors.mutedText(isDark),
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
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

class _DrawerGlassCard extends StatelessWidget {
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double radius;

  const _DrawerGlassCard({
    required this.isDark,
    required this.padding,
    required this.child,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: _DrawerColors.glassSurface(isDark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _DrawerColors.glassBorder(isDark)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.18)
                    : _DrawerColors.primaryBlue.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DrawerStatItem extends StatelessWidget {
  final bool isDark;
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _DrawerStatItem({
    required this.isDark,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _DrawerColors.primaryText(isDark),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _DrawerColors.mutedText(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DrawerStatDivider extends StatelessWidget {
  final bool isDark;

  const _DrawerStatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: _DrawerColors.glassBorder(isDark),
    );
  }
}

class _DrawerIconButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerIconButton({
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _DrawerColors.controlSurface(isDark),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _DrawerColors.mutedText(isDark), size: 20),
        ),
      ),
    );
  }
}

class _DrawerColors {
  static const primaryBlue = Color(0xFF155CFB);
  static const primaryBlueLight = Color(0xFF2B7FFF);
  static const aiPurple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF06B6D4);
  static const amber = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);

  static List<Color> pageGradient(bool isDark) {
    if (isDark) {
      return const [Color(0xFF0B1120), Color(0xFF111C35), Color(0xFF0F172A)];
    }
    return const [Color(0xFFE6EFFD), Color(0xFFF8FBFF), Color(0xFFF1E9FF)];
  }

  static Color glassSurface(bool isDark) => isDark
      ? const Color(0xFF172442).withValues(alpha: 0.88)
      : Colors.white.withValues(alpha: 0.92);

  static Color glassBorder(bool isDark) => isDark
      ? const Color(0xFF6EA8FF).withValues(alpha: 0.18)
      : const Color(0xFFD8E4FF).withValues(alpha: 0.95);

  static Color controlSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : const Color(0xFFF3F7FF).withValues(alpha: 0.95);

  static Color primaryText(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF101727);

  static Color mutedText(bool isDark) =>
      isDark ? Colors.white60 : const Color(0xFF64748B);
}

class _DrawerSection {
  final String id;
  final String title;
  final IconData icon;
  final bool isAi;
  final List<_DrawerItem> items;

  const _DrawerSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
    this.isAi = false,
  });
}

class _DrawerItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String route;
  final bool isAi;
  final List<String> activePrefixes;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
    this.isAi = false,
    this.activePrefixes = const [],
  });

  bool matches(String path) {
    if (route == '/dashboard') return path == route;
    if (path == route || path.startsWith('$route/')) return true;
    return activePrefixes.any((prefix) => path.startsWith(prefix));
  }
}
