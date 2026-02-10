import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TADrawer extends StatefulWidget {
  final String? currentRoute;
  final bool? isDark;

  const TADrawer({super.key, this.currentRoute, this.isDark});

  @override
  State<TADrawer> createState() => _TADrawerState();
}

class _TADrawerState extends State<TADrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _getSelectedIndexFromRoute(List<_MenuItem> items) {
    if (widget.currentRoute == null) return 0;
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == widget.currentRoute) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        final menuItems = _buildMenuItems(l10n);

        return Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildProfileHeader(isDark, l10n),
                  _buildQuickStats(isDark, l10n),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildNavigationMenu(isDark, menuItems, l10n),
                  ),
                  _buildBottomSection(isDark, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/ta/profile');
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: TAColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: TAColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: TAColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sarah Anderson',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🎓 ${l10n.ta}',
                    style: const TextStyle(
                      color: TAColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(isDark, '4', l10n.courses, Icons.school_rounded),
          _buildStatDivider(isDark),
          _buildStatItem(isDark, '36', l10n.taGraded, Icons.grading_rounded),
          _buildStatDivider(isDark),
          _buildStatItem(
            isDark,
            '8',
            l10n.pending,
            Icons.pending_actions_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    bool isDark,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: TAColors.primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.06),
    );
  }

  List<_MenuItem> _buildMenuItems(AppLocalizations l10n) {
    return [
      _MenuItem(
        icon: Icons.space_dashboard_rounded,
        activeIcon: Icons.space_dashboard,
        title: l10n.dashboard,
        route: '/ta/dashboard',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.school_outlined,
        activeIcon: Icons.school,
        title: l10n.taAssignedCourses,
        route: '/ta/courses',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.science_outlined,
        activeIcon: Icons.science,
        title: l10n.taLabsTitle,
        route: '/ta/labs',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        title: l10n.taStudentPerformance,
        route: '/ta/student-performance',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.grading_outlined,
        activeIcon: Icons.grading,
        title: l10n.taGradingCenter,
        route: '/ta/grading',
        badge: '12',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.auto_fix_high_outlined,
        activeIcon: Icons.auto_fix_high,
        title: l10n.taGradingTitle,
        route: '/ta/ai-grading',
        isHighlighted: true,
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        title: l10n.taLabResTitle,
        route: '/ta/lab-resources',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
        title: l10n.taInboxTitle,
        route: '/ta/student-inbox',
        badge: '3',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.rate_review_outlined,
        activeIcon: Icons.rate_review,
        title: l10n.taReviewSubmissions,
        route: '/ta/reviews',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.upload_file_outlined,
        activeIcon: Icons.upload_file,
        title: l10n.taUploadTitle,
        route: '/ta/upload-materials',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        title: l10n.taAnalyticsTitle,
        route: '/ta/analytics',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.forum_outlined,
        activeIcon: Icons.forum,
        title: l10n.taDiscussions,
        route: '/ta/discussions',
        badge: '5',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.access_time_rounded,
        activeIcon: Icons.access_time_filled,
        title: l10n.taOfficeHours,
        route: '/ta/office-hours',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.how_to_reg_outlined,
        activeIcon: Icons.how_to_reg,
        title: l10n.attendanceManager,
        route: '/ta/attendance',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        title: l10n.calendar,
        route: '/ta/calendar',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        title: l10n.taAIAssistant,
        route: '/ta/ai-assistant',
        isHighlighted: true,
        category: 'ai',
      ),
      _MenuItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        title: l10n.aiAssistant,
        route: '/ta/ai-assistant',
        isHighlighted: true,
        category: 'ai',
      ),
      _MenuItem(
        icon: Icons.forum_outlined,
        activeIcon: Icons.forum,
        title: l10n.taDiscussTitle,
        route: '/ta/discussions',
        badge: '5',
        category: 'communication',
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        title: l10n.messages,
        route: '/ta/messages',
        badge: '3',
        category: 'communication',
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        title: l10n.taNotifications,
        route: '/ta/notifications',
        badge: '2',
        category: 'communication',
      ),
      _MenuItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person,
        title: l10n.profile,
        route: '/ta/profile',
        category: 'account',
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        title: l10n.settings,
        route: '/ta/settings',
        category: 'account',
      ),
    ];
  }

  Widget _buildNavigationMenu(
    bool isDark,
    List<_MenuItem> items,
    AppLocalizations l10n,
  ) {
    final mainItems = items.where((i) => i.category == 'main').toList();
    final aiItems = items.where((i) => i.category == 'ai').toList();
    final communicationItems = items
        .where((i) => i.category == 'communication')
        .toList();
    final accountItems = items.where((i) => i.category == 'account').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionLabel(isDark, l10n.mainMenu),
        ...mainItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.aiTools),
        ...aiItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.connect),
        ...communicationItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.account),
        ...accountItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(bool isDark, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(bool isDark, _MenuItem item, int index) {
    final isSelected = widget.currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (item.route.isNotEmpty && item.route != widget.currentRoute) {
              context.go(item.route);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: item.isHighlighted
                          ? [TAColors.primary, TAColors.primaryLight]
                          : [
                              TAColors.primary.withValues(alpha: 0.15),
                              TAColors.primaryLight.withValues(alpha: 0.1),
                            ],
                    )
                  : item.isHighlighted
                  ? LinearGradient(
                      colors: [
                        TAColors.primary.withValues(alpha: 0.1),
                        TAColors.primaryLight.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: item.isHighlighted && !isSelected
                  ? Border.all(color: TAColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (item.isHighlighted
                              ? Colors.white.withValues(alpha: 0.2)
                              : TAColors.primary.withValues(alpha: 0.1))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? (item.isHighlighted ? Colors.white : TAColors.primary)
                        : item.isHighlighted
                        ? TAColors.primary
                        : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected
                          ? (item.isHighlighted
                                ? Colors.white
                                : TAColors.primary)
                          : item.isHighlighted
                          ? TAColors.primary
                          : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : TAColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: isSelected
                            ? (item.isHighlighted
                                  ? Colors.white
                                  : TAColors.primary)
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (item.isHighlighted && !isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: TAColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    isDark,
                    icon: Icons.light_mode_rounded,
                    label: l10n.lightMode,
                    isActive: !isDark,
                    onTap: () {
                      if (isDark) {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _buildThemeOption(
                    isDark,
                    icon: Icons.dark_mode_rounded,
                    label: l10n.darkMode,
                    isActive: isDark,
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
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: TAColors.error.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    bool isDark, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? TAColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark ? TAColors.primary : Colors.black)
                        .withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                  : (isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? (isDark ? Colors.white : TAColors.primary)
                    : (isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String route;
  final String? badge;
  final bool isHighlighted;
  final String category;

  _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
    this.badge,
    this.isHighlighted = false,
    required this.category,
  });
}
