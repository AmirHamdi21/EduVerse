import 'dart:ui';

import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_event.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_event.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/dashboard/instructor_dashboard_v9_metrics.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:edu_verse/widgets/shared/current_user_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InstructorDrawerV9 extends StatefulWidget {
  final InstructorV9Snapshot snapshot;

  const InstructorDrawerV9({
    super.key,
    this.snapshot = InstructorV9Snapshot.empty,
  });

  @override
  State<InstructorDrawerV9> createState() => _InstructorDrawerV9State();
}

class _InstructorDrawerV9State extends State<InstructorDrawerV9> {
  final Set<String> _expandedCategoryIds = <String>{'overview', 'teaching'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureDataLoaded();
    });
  }

  void _ensureDataLoaded() {
    final coursesBloc = context.read<InstructorCoursesBloc>();
    if (coursesBloc.state is! InstructorCoursesLoaded &&
        coursesBloc.state is! InstructorCoursesLoading) {
      coursesBloc.add(const LoadTeachingCourses());
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
                colors: _InstructorV9Colors.pageGradient(isDark),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _InstructorDrawerHeader(isDark: isDark),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _InstructorDrawerStats(
                      isDark: isDark,
                      snapshot: widget.snapshot,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      physics: const BouncingScrollPhysics(),
                      children: sections.map((section) {
                        return _DrawerCategory(
                          section: section,
                          isDark: isDark,
                          isExpanded: _expandedCategoryIds.contains(section.id),
                          currentPath: currentPath,
                          snapshot: widget.snapshot,
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
                    child: _InstructorDrawerBottom(isDark: isDark),
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
    router.go(item.route);
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
            route: '/instructor/dashboard',
          ),
          _DrawerItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            title: l10n.calendar,
            route: '/instructor/calendar',
          ),
          _DrawerItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            title: l10n.reportsAndAnalytics,
            route: '/instructor/reports',
          ),
        ],
      ),
      _DrawerSection(
        id: 'teaching',
        title: l10n.drawerTeaching,
        icon: Icons.school_rounded,
        items: [
          _DrawerItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            title: l10n.myCourses,
            route: '/instructor/courses',
          ),
          _DrawerItem(
            icon: Icons.tune_outlined,
            activeIcon: Icons.tune_rounded,
            title: l10n.manageCourses,
            route: '/instructor/course-management',
          ),
          _DrawerItem(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            title: l10n.roster,
            route: '/instructor/roster',
          ),
          _DrawerItem(
            icon: Icons.how_to_reg_outlined,
            activeIcon: Icons.how_to_reg_rounded,
            title: l10n.attendanceManager,
            route: '/instructor/attendance',
          ),
          _DrawerItem(
            icon: Icons.upload_file_outlined,
            activeIcon: Icons.upload_file_rounded,
            title: l10n.uploadMaterial,
            route: '/instructor/upload-materials',
          ),
          _DrawerItem(
            icon: Icons.science_outlined,
            activeIcon: Icons.science_rounded,
            title: l10n.labs,
            route: '/instructor/labs',
          ),
        ],
      ),
      _DrawerSection(
        id: 'assessment',
        title: l10n.drawerAssessment,
        icon: Icons.fact_check_rounded,
        items: [
          _DrawerItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            title: l10n.assignments,
            route: '/instructor/assignments',
            showsPendingBadge: true,
          ),
          _DrawerItem(
            icon: Icons.add_task_outlined,
            activeIcon: Icons.add_task_rounded,
            title: l10n.createAssignment,
            route: '/instructor/create-assignment',
          ),
          _DrawerItem(
            icon: Icons.grading_outlined,
            activeIcon: Icons.grading_rounded,
            title: l10n.gradingCenter,
            route: '/instructor/grading',
            showsPendingBadge: true,
          ),
          _DrawerItem(
            icon: Icons.quiz_outlined,
            activeIcon: Icons.quiz_rounded,
            title: l10n.quizManagement,
            route: '/instructor/quiz-management',
          ),
          _DrawerItem(
            icon: Icons.storage_outlined,
            activeIcon: Icons.storage_rounded,
            title: l10n.questionBank,
            route: '/instructor/question-bank',
          ),
          _DrawerItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description_rounded,
            title: l10n.examGenerator,
            route: '/instructor/exam-generator',
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
            title: l10n.aiTeachingAssistant,
            route: '/instructor/ai-teaching',
            isAi: true,
          ),
          _DrawerItem(
            icon: Icons.summarize_outlined,
            activeIcon: Icons.summarize_rounded,
            title: l10n.summarizerTitle,
            route: '/summarizer',
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
            route: '/instructor/discussions',
            activePrefixes: const ['/instructor/course/'],
          ),
          _DrawerItem(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            title: l10n.messages,
            route: '/instructor/messages',
            showsMessagesBadge: true,
          ),
          _DrawerItem(
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
            title: l10n.announcements,
            route: '/instructor/announcements',
          ),
          _DrawerItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            title: l10n.notifications,
            route: '/instructor/notifications',
            showsNotificationBadge: true,
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
            route: '/instructor/profile',
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            title: l10n.settings,
            route: '/instructor/settings',
          ),
        ],
      ),
    ];
  }
}

class _InstructorDrawerHeader extends StatelessWidget {
  final bool isDark;

  const _InstructorDrawerHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Instructor',
    );

    return _GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.go('/instructor/profile');
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
                        _InstructorV9Colors.purple,
                        _InstructorV9Colors.pink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _InstructorV9Colors.purple.withValues(
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
                        fontSize: 23,
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
                      color: _InstructorV9Colors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _InstructorV9Colors.glassSurface(isDark),
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
                    color: _InstructorV9Colors.primaryText(isDark),
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
                    color: _InstructorV9Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.activeInstructor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _InstructorV9Colors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IconButtonShell(
            isDark: isDark,
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _InstructorDrawerStats extends StatelessWidget {
  final bool isDark;
  final InstructorV9Snapshot snapshot;

  const _InstructorDrawerStats({required this.isDark, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final courses = context.select<InstructorCoursesBloc, int>((bloc) {
      return InstructorDashboardV9Metrics.courseCount(
        InstructorDashboardV9Metrics.teachingCoursesFromState(bloc.state),
      );
    });
    final students = context.select<InstructorCoursesBloc, int>((bloc) {
      return InstructorDashboardV9Metrics.totalStudents(
        InstructorDashboardV9Metrics.teachingCoursesFromState(bloc.state),
      );
    });

    return _GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              isDark: isDark,
              value: '$courses',
              label: l10n.courses,
              icon: Icons.menu_book_rounded,
              color: _InstructorV9Colors.purple,
            ),
          ),
          _StatDivider(isDark: isDark),
          Expanded(
            child: _StatItem(
              isDark: isDark,
              value: '$students',
              label: l10n.students,
              icon: Icons.groups_rounded,
              color: _InstructorV9Colors.indigo,
            ),
          ),
          _StatDivider(isDark: isDark),
          Expanded(
            child: _StatItem(
              isDark: isDark,
              value: '${snapshot.pendingGrading.length}',
              label: l10n.pending,
              icon: Icons.grading_rounded,
              color: _InstructorV9Colors.pink,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerCategory extends StatelessWidget {
  final _DrawerSection section;
  final bool isDark;
  final bool isExpanded;
  final String currentPath;
  final InstructorV9Snapshot snapshot;
  final VoidCallback onToggle;
  final ValueChanged<_DrawerItem> onItemTap;

  const _DrawerCategory({
    required this.section,
    required this.isDark,
    required this.isExpanded,
    required this.currentPath,
    required this.snapshot,
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
    final messageCount = InstructorDashboardV9Metrics.messageCount(
      snapshot.courses,
    );
    final accent = section.isAi
        ? _InstructorV9Colors.pink
        : _InstructorV9Colors.purple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _GlassCard(
        isDark: isDark,
        radius: 20,
        padding: const EdgeInsets.all(6),
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
                          color: accent.withValues(alpha: 0.13),
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
                                : _InstructorV9Colors.primaryText(isDark),
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
                          color: _InstructorV9Colors.mutedText(isDark),
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
                      pendingGrading: snapshot.pendingGrading.length,
                      messages: messageCount,
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
    required int pendingGrading,
    required int messages,
  }) {
    if (item.showsNotificationBadge) return unreadNotifications;
    if (item.showsPendingBadge) return pendingGrading;
    if (item.showsMessagesBadge) return messages;
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
        ? _InstructorV9Colors.pink
        : _InstructorV9Colors.purple;

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
                        accent.withValues(alpha: 0.19),
                        _InstructorV9Colors.pink.withValues(alpha: 0.08),
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
                        ? accent.withValues(alpha: 0.15)
                        : _InstructorV9Colors.controlSurface(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive
                        ? accent
                        : _InstructorV9Colors.mutedText(isDark),
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
                          : _InstructorV9Colors.primaryText(isDark),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  _CountBadge(
                    count: badgeCount,
                    isDark: isDark,
                    color: item.showsNotificationBadge
                        ? _InstructorV9Colors.yellow
                        : _InstructorV9Colors.pink,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructorDrawerBottom extends StatelessWidget {
  final bool isDark;

  const _InstructorDrawerBottom({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassCard(
          isDark: isDark,
          radius: 16,
          padding: const EdgeInsets.all(4),
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
                color: _InstructorV9Colors.red.withValues(
                  alpha: isDark ? 0.10 : 0.04,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _InstructorV9Colors.red.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: _InstructorV9Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.logout,
                    style: const TextStyle(
                      color: _InstructorV9Colors.red,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? _InstructorV9Colors.purple : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? (isDark ? Colors.white : _InstructorV9Colors.purple)
                    : _InstructorV9Colors.mutedText(isDark),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? (isDark ? Colors.white : _InstructorV9Colors.purple)
                        : _InstructorV9Colors.mutedText(isDark),
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

class _GlassCard extends StatelessWidget {
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double radius;

  const _GlassCard({
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
            color: _InstructorV9Colors.glassSurface(isDark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _InstructorV9Colors.glassBorder(isDark)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.18)
                    : _InstructorV9Colors.purple.withValues(alpha: 0.07),
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

class _StatItem extends StatelessWidget {
  final bool isDark;
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
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
            color: _InstructorV9Colors.primaryText(isDark),
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
            color: _InstructorV9Colors.mutedText(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;

  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: _InstructorV9Colors.glassBorder(isDark),
    );
  }
}

class _IconButtonShell extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonShell({
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
            color: _InstructorV9Colors.controlSurface(isDark),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _InstructorV9Colors.mutedText(isDark),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isDark;
  final Color color;

  const _CountBadge({
    required this.count,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    final textColor = color == _InstructorV9Colors.yellow
        ? const Color(0xFF713F12)
        : Colors.white;

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
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _InstructorV9Colors {
  static const purple = InstructorColors.primary;
  static const pink = InstructorColors.accent;
  static const indigo = InstructorColors.info;
  static const yellow = InstructorColors.warning;
  static const success = InstructorColors.success;
  static const red = InstructorColors.error;

  static List<Color> pageGradient(bool isDark) {
    if (isDark) {
      return const [
        InstructorColors.darkBg,
        InstructorColors.darkCard,
        InstructorColors.darkBg,
      ];
    }
    return const [
      InstructorColors.primarySurface,
      InstructorColors.surface,
      InstructorColors.cyanLight,
    ];
  }

  static Color glassSurface(bool isDark) => isDark
      ? InstructorColors.darkCard.withValues(alpha: 0.88)
      : Colors.white.withValues(alpha: 0.78);

  static Color glassBorder(bool isDark) => isDark
      ? InstructorColors.darkBorder.withValues(alpha: 0.46)
      : InstructorColors.border.withValues(alpha: 0.74);

  static Color controlSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : InstructorColors.primarySurface.withValues(alpha: 0.72);

  static Color primaryText(bool isDark) =>
      InstructorColors.textPrimaryColor(isDark);

  static Color mutedText(bool isDark) =>
      InstructorColors.textSecondaryColor(isDark);
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
  final bool showsNotificationBadge;
  final bool showsPendingBadge;
  final bool showsMessagesBadge;
  final List<String> activePrefixes;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
    this.isAi = false,
    this.showsNotificationBadge = false,
    this.showsPendingBadge = false,
    this.showsMessagesBadge = false,
    this.activePrefixes = const [],
  });

  bool matches(String path) {
    if (path == route || path.startsWith('$route/')) return true;
    return activePrefixes.any((prefix) => path.startsWith(prefix));
  }
}
