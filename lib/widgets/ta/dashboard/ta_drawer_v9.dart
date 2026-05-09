import 'dart:ui';

import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_event.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_state.dart';
import 'package:edu_verse/bloc/ta/ta_courses_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_courses_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/widgets/shared/current_user_identity.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_dashboard_v9_metrics.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TADrawerV9 extends StatefulWidget {
  final TAV9Snapshot snapshot;

  const TADrawerV9({super.key, this.snapshot = TAV9Snapshot.empty});

  @override
  State<TADrawerV9> createState() => _TADrawerV9State();
}

class _TADrawerV9State extends State<TADrawerV9> {
  final Set<String> _expandedCategoryIds = <String>{'overview', 'workflow'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureDataLoaded();
    });
  }

  void _ensureDataLoaded() {
    final coursesCubit = context.read<TACoursesCubit>();
    final status = coursesCubit.state.coursesStatus;
    if (status is! TASubTabLoaded<List<TeachingCourseModel>> &&
        status is! TASubTabLoading<List<TeachingCourseModel>>) {
      coursesCubit.fetchTACourses();
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
        final path = GoRouterState.of(context).uri.path;
        final sections = _sections(l10n);

        for (final section in sections) {
          if (section.items.any((item) => item.matches(path))) {
            _expandedCategoryIds.add(section.id);
          }
        }

        return Drawer(
          width: 350,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _TADrawerV9Colors.pageGradient(isDark),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _ProfileHeader(isDark: isDark),
                  _QuickStats(snapshot: widget.snapshot, isDark: isDark),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (final section in sections) ...[
                          _DrawerSectionCard(
                            section: section,
                            isDark: isDark,
                            isExpanded: _expandedCategoryIds.contains(
                              section.id,
                            ),
                            currentPath: path,
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
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  _DrawerBottom(isDark: isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<_DrawerSection> _sections(AppLocalizations l10n) {
    return <_DrawerSection>[
      _DrawerSection(
        id: 'overview',
        title: l10n.drawerOverview,
        icon: Icons.dashboard_rounded,
        items: <_DrawerItem>[
          _DrawerItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            title: l10n.dashboard,
            route: '/ta/dashboard',
          ),
          _DrawerItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            title: l10n.calendar,
            route: '/ta/calendar',
          ),
          _DrawerItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics_rounded,
            title: l10n.taAnalyticsTitle,
            route: '/ta/analytics',
          ),
        ],
      ),
      _DrawerSection(
        id: 'workflow',
        title: 'Workflow',
        icon: Icons.task_alt_rounded,
        items: <_DrawerItem>[
          _DrawerItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            title: l10n.assignments,
            route: '/ta/assignments',
            showsPendingBadge: true,
          ),
          _DrawerItem(
            icon: Icons.grading_outlined,
            activeIcon: Icons.grading_rounded,
            title: l10n.taGradingCenter,
            route: '/ta/grading',
            showsPendingBadge: true,
          ),
          _DrawerItem(
            icon: Icons.science_outlined,
            activeIcon: Icons.science_rounded,
            title: l10n.taLabsTitle,
            route: '/ta/labs',
            showsLabBadge: true,
          ),
          _DrawerItem(
            icon: Icons.how_to_reg_outlined,
            activeIcon: Icons.how_to_reg_rounded,
            title: l10n.attendanceManager,
            route: '/ta/attendance',
          ),
        ],
      ),
      _DrawerSection(
        id: 'courses',
        title: l10n.drawerTeaching,
        icon: Icons.school_rounded,
        items: <_DrawerItem>[
          _DrawerItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            title: l10n.taAssignedCourses,
            route: '/ta/courses',
          ),
          _DrawerItem(
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            title: 'Student Roster',
            route: '/ta/roster',
          ),
          _DrawerItem(
            icon: Icons.quiz_outlined,
            activeIcon: Icons.quiz_rounded,
            title: 'Quiz Management',
            route: '/ta/quiz-management',
          ),
        ],
      ),
      _DrawerSection(
        id: 'ai',
        title: l10n.drawerAiTools,
        icon: Icons.auto_awesome_rounded,
        isAi: true,
        items: <_DrawerItem>[
          _DrawerItem(
            icon: Icons.psychology_outlined,
            activeIcon: Icons.psychology_rounded,
            title: l10n.taAIAssistant,
            route: '/ta/ai-assistant',
            isAi: true,
          ),
        ],
      ),
      _DrawerSection(
        id: 'communication',
        title: l10n.drawerCommunication,
        icon: Icons.forum_rounded,
        items: <_DrawerItem>[
          _DrawerItem(
            icon: Icons.forum_outlined,
            activeIcon: Icons.forum_rounded,
            title: l10n.taDiscussTitle,
            route: '/ta/discussions',
          ),
          _DrawerItem(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            title: l10n.messages,
            route: '/ta/messages',
          ),
          _DrawerItem(
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
            title: l10n.announcementsManager,
            route: '/ta/announcements',
          ),
          _DrawerItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            title: l10n.taNotifications,
            route: '/ta/notifications',
            showsNotificationBadge: true,
          ),
        ],
      ),
      _DrawerSection(
        id: 'account',
        title: l10n.drawerAccount,
        icon: Icons.person_rounded,
        items: <_DrawerItem>[
          _DrawerItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            title: l10n.profile,
            route: '/ta/profile',
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            title: l10n.settings,
            route: '/ta/settings',
          ),
        ],
      ),
    ];
  }
}

class _ProfileHeader extends StatelessWidget {
  final bool isDark;

  const _ProfileHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final identity = CurrentUserIdentity.fromAuthState(
      context.watch<AuthBloc>().state,
      fallbackName: 'Teaching Assistant',
    );

    return _DrawerGlass(
      isDark: isDark,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.go('/ta/profile');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: TAColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: TAColors.primary.withValues(alpha: 0.26),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      identity.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: TAColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? TAColors.darkCard : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _TADrawerV9Colors.primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    l10n.ta,
                    style: const TextStyle(
                      color: TAColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _IconBubble(
            icon: Icons.close_rounded,
            isDark: isDark,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final TAV9Snapshot snapshot;
  final bool isDark;

  const _QuickStats({required this.snapshot, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _DrawerGlass(
      isDark: isDark,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.school_outlined,
            value: '${snapshot.courses.length}',
            label: l10n.courses,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _StatCell(
            icon: Icons.task_alt_outlined,
            value: '${snapshot.tasks.length}',
            label: 'Tasks',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _StatCell(
            icon: Icons.grading_outlined,
            value: '${snapshot.pendingGrading}',
            label: l10n.pending,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _DrawerSectionCard extends StatelessWidget {
  final _DrawerSection section;
  final bool isDark;
  final bool isExpanded;
  final String currentPath;
  final TAV9Snapshot snapshot;
  final VoidCallback onToggle;

  const _DrawerSectionCard({
    required this.section,
    required this.isDark,
    required this.isExpanded,
    required this.currentPath,
    required this.snapshot,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = section.isAi ? TAColors.pink : TAColors.primary;
    return _DrawerGlass(
      isDark: isDark,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(section.icon, color: accent, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      section.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _TADrawerV9Colors.primaryText(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _TADrawerV9Colors.mutedText(isDark),
                  ),
                ],
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
                  selected: item.matches(currentPath),
                  badgeCount: _badgeCountFor(context, item, snapshot),
                );
              }).toList(),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  int _badgeCountFor(
    BuildContext context,
    _DrawerItem item,
    TAV9Snapshot snapshot,
  ) {
    if (item.showsNotificationBadge) {
      return context.watch<NotificationCubit>().state.unreadCount;
    }
    if (item.showsPendingBadge) return snapshot.pendingGrading;
    if (item.showsLabBadge) {
      return snapshot.courses.fold<int>(
        0,
        (sum, course) => sum + course.pendingLabs,
      );
    }
    return 0;
  }
}

class _DrawerNavItem extends StatelessWidget {
  final _DrawerItem item;
  final bool isDark;
  final bool selected;
  final int badgeCount;

  const _DrawerNavItem({
    required this.item,
    required this.isDark,
    required this.selected,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final accent = item.isAi ? TAColors.pink : TAColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.pop(context);
          final current = GoRouterState.of(context).uri.path;
          if (item.route != current) context.go(item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      accent.withValues(alpha: isDark ? 0.28 : 0.16),
                      TAColors.primaryLight.withValues(
                        alpha: isDark ? 0.15 : 0.10,
                      ),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: 0.16)
                      : _TADrawerV9Colors.controlSurface(isDark),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  color: selected
                      ? accent
                      : _TADrawerV9Colors.mutedText(isDark),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? accent
                        : _TADrawerV9Colors.primaryText(isDark),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.showsNotificationBadge
                        ? TAColors.warning
                        : TAColors.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: item.showsNotificationBadge
                          ? const Color(0xFF713F12)
                          : Colors.white,
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

class _DrawerBottom extends StatelessWidget {
  final bool isDark;

  const _DrawerBottom({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          _DrawerGlass(
            isDark: isDark,
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: l10n.lightMode,
                    isActive: !isDark,
                    isDark: isDark,
                    onTap: () {
                      if (isDark) {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: l10n.darkMode,
                    isActive: isDark,
                    isDark: isDark,
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
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: TAColors.error.withValues(alpha: isDark ? 0.14 : 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TAColors.error.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: TAColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.logout,
                    style: const TextStyle(
                      color: TAColors.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerGlass extends StatelessWidget {
  final bool isDark;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _DrawerGlass({
    required this.isDark,
    required this.margin,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: _TADrawerV9Colors.glassSurface(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _TADrawerV9Colors.glassBorder(isDark)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconBubble({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _TADrawerV9Colors.controlSurface(isDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _TADrawerV9Colors.mutedText(isDark), size: 20),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: TAColors.primary, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _TADrawerV9Colors.primaryText(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _TADrawerV9Colors.secondaryText(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: _TADrawerV9Colors.innerLine(isDark),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? TAColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark ? TAColors.primary : Colors.black)
                        .withValues(alpha: 0.12),
                    blurRadius: 9,
                    offset: const Offset(0, 3),
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
                  ? (isDark ? Colors.white : TAColors.primary)
                  : _TADrawerV9Colors.mutedText(isDark),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  color: isActive
                      ? (isDark ? Colors.white : TAColors.primary)
                      : _TADrawerV9Colors.mutedText(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  final bool showsLabBadge;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
    this.isAi = false,
    this.showsNotificationBadge = false,
    this.showsPendingBadge = false,
    this.showsLabBadge = false,
  });

  bool matches(String path) => path == route || path.startsWith('$route/');
}

class _TADrawerV9Colors {
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
      ? TAColors.darkCard.withValues(alpha: 0.88)
      : Colors.white.withValues(alpha: 0.78);

  static Color glassBorder(bool isDark) => isDark
      ? TAColors.darkBorder.withValues(alpha: 0.46)
      : TAColors.border.withValues(alpha: 0.74);

  static Color controlSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : TAColors.primarySurface.withValues(alpha: 0.72);

  static Color primaryText(bool isDark) => TAColors.textPrimaryColor(isDark);

  static Color secondaryText(bool isDark) =>
      TAColors.textSecondaryColor(isDark);

  static Color mutedText(bool isDark) => TAColors.textTertiaryColor(isDark);

  static Color innerLine(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : TAColors.border.withValues(alpha: 0.70);
}
