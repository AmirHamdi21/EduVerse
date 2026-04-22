import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedIndex = 0;

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
                  Expanded(child: _buildNavigationMenu(isDark, menuItems)),
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
                  context.push('/admin/profile');
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AdminColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 28,
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
                    color: AdminColors.success,
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
                  l10n.admin,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
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
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🔐 ${l10n.adminRole}',
                    style: TextStyle(
                      color: AdminColors.primary,
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
              onTap: () {
                Navigator.pop(context);
                context.push('/admin/search');
              },
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
                  Icons.search_rounded,
                  color: AdminColors.getTextTertiaryColor(isDark),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                  color: AdminColors.getTextTertiaryColor(isDark),
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
          _buildStatItem(isDark, '12.8K', l10n.users, Icons.people_rounded),
          _buildStatDivider(isDark),
          _buildStatItem(isDark, '342', l10n.courses, Icons.school_rounded),
          _buildStatDivider(isDark),
          _buildStatItem(isDark, '98.7%', l10n.uptime, Icons.speed_rounded),
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
        Icon(icon, color: AdminColors.primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
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
        icon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard,
        title: l10n.dashboard,
        route: '/admin/dashboard',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        title: l10n.userManagement,
        route: '/admin/users',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings_rounded,
        title: l10n.rolePermissionsManagement,
        route: '/admin/roles',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
        title: l10n.courseManagement,
        route: '/admin/courses',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        title: l10n.adminEnrollmentPeriods,
        route: '/admin/enrollment-periods',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.event_outlined,
        activeIcon: Icons.event_rounded,
        title: l10n.adminCampusEvents,
        route: '/admin/campus-events',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.view_week_outlined,
        activeIcon: Icons.view_week_rounded,
        title: l10n.adminScheduleTemplates,
        route: '/admin/schedule-templates',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.schedule_outlined,
        activeIcon: Icons.schedule_rounded,
        title: l10n.officeHours,
        route: '/admin/office-hours',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.people_alt_outlined,
        activeIcon: Icons.people_alt_rounded,
        title: l10n.assignStaff,
        route: '/admin/staff',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.business_outlined,
        activeIcon: Icons.business_rounded,
        title: l10n.departmentsAndPrograms,
        route: '/admin/departments',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        title: l10n.reportsAnalytics,
        route: '/admin/analytics',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.security_outlined,
        activeIcon: Icons.security,
        title: l10n.securityAndActivityLogs,
        route: '/admin/security',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign,
        title: l10n.announcements,
        route: '/admin/announcements',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.fact_check_outlined,
        activeIcon: Icons.fact_check,
        title: l10n.attendance,
        route: '/admin/attendance',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.backup_rounded,
        activeIcon: Icons.backup,
        title: l10n.backupDataCenter,
        route: '/admin/backup-center',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.payments_rounded,
        activeIcon: Icons.payments,
        title: l10n.paymentManagement,
        route: '/admin/payments',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.fact_check_outlined,
        activeIcon: Icons.fact_check_rounded,
        title: l10n.auditCompliance,
        route: '/admin/audit',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.hub_outlined,
        activeIcon: Icons.hub_rounded,
        title: l10n.integrationsApi,
        route: '/admin/integrations',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        title: l10n.aiInsights,
        route: '/admin/ai-insights',
        category: 'ai',
        isHighlighted: true,
      ),
      _MenuItem(
        icon: Icons.shield_outlined,
        activeIcon: Icons.shield,
        title: l10n.systemHealth,
        route: '/admin/analytics',
        category: 'ai',
        isHighlighted: true,
      ),
      _MenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        title: l10n.messages,
        route: '/admin/messages',
        badge: '3',
        category: 'communication',
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        title: l10n.notifications,
        route: '/admin/notifications',
        badge: '12',
        category: 'communication',
      ),
      _MenuItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        title: l10n.profile,
        route: '/admin/profile',
        category: 'account',
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        title: l10n.settings,
        route: '/admin/settings',
        category: 'account',
      ),
    ];
  }

  Widget _buildNavigationMenu(bool isDark, List<_MenuItem> items) {
    final l10n = AppLocalizations.of(context);
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
        _buildSectionLabel(isDark, l10n.mainMenu.toUpperCase()),
        ...mainItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.adminAiAndSystemSection.toUpperCase()),
        ...aiItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.communication.toUpperCase()),
        ...communicationItems.asMap().entries.map(
          (e) => _buildNavItem(isDark, e.value, items.indexOf(e.value)),
        ),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.account.toUpperCase()),
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
        label,
        style: TextStyle(
          color: AdminColors.getTextTertiaryColor(isDark),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(bool isDark, _MenuItem item, int index) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
            if (item.route.isNotEmpty && item.route != '/admin/dashboard') {
              context.push(item.route);
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
                          ? [AdminColors.secondary, AdminColors.primary]
                          : [
                              AdminColors.primary.withValues(alpha: 0.15),
                              AdminColors.secondary.withValues(alpha: 0.1),
                            ],
                    )
                  : item.isHighlighted
                  ? LinearGradient(
                      colors: [
                        AdminColors.secondary.withValues(alpha: 0.1),
                        AdminColors.primary.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: item.isHighlighted && !isSelected
                  ? Border.all(
                      color: AdminColors.secondary.withValues(alpha: 0.3),
                    )
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
                              : AdminColors.primary.withValues(alpha: 0.1))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? (item.isHighlighted
                              ? Colors.white
                              : AdminColors.primary)
                        : item.isHighlighted
                        ? AdminColors.secondary
                        : AdminColors.getTextTertiaryColor(isDark),
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
                                : AdminColors.primary)
                          : item.isHighlighted
                          ? AdminColors.secondary
                          : AdminColors.getTextColor(isDark),
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
                          : AdminColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: isSelected
                            ? (item.isHighlighted
                                  ? Colors.white
                                  : AdminColors.primary)
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
                      color: AdminColors.secondary,
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
                context.read<AuthBloc>().add(const LogoutRequested());
                context.go('/login');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AdminColors.error.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AdminColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.logout,
                      style: TextStyle(
                        color: AdminColors.error,
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
              ? (isDark ? AdminColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark ? AdminColors.primary : Colors.black)
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
                  ? (isDark ? Colors.white : AdminColors.primary)
                  : AdminColors.getTextTertiaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? (isDark ? Colors.white : AdminColors.primary)
                    : AdminColors.getTextTertiaryColor(isDark),
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
