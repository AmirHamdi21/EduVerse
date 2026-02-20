import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITDrawer extends StatefulWidget {
  final String currentRoute;
  final bool isDark;

  const ITDrawer({super.key, required this.currentRoute, required this.isDark});

  @override
  State<ITDrawer> createState() => _ITDrawerState();
}

class _ITDrawerState extends State<ITDrawer>
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
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0891B2).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.computer_rounded,
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
                    color: const Color(0xFF10B981),
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
                  l10n.itAdmin,
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
                    color: const Color(0xFF0891B2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🖥️ ${l10n.itSystemAdmin}',
                    style: const TextStyle(
                      color: Color(0xFF0891B2),
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
          _buildStatItem(isDark, '99.9%', l10n.itUptime, Icons.timer_rounded),
          _buildStatDivider(isDark),
          _buildStatItem(isDark, '2', l10n.itIncidents, Icons.warning_rounded),
          _buildStatDivider(isDark),
          _buildStatItem(isDark, '8', l10n.itServers, Icons.dns_rounded),
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
        Icon(icon, color: const Color(0xFF0891B2), size: 20),
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
        route: '/it-admin/dashboard',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.monitor_heart_outlined,
        activeIcon: Icons.monitor_heart,
        title: l10n.itSystemHealth,
        route: '/it-admin/system-health',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.dns_outlined,
        activeIcon: Icons.dns,
        title: l10n.itServerManagement,
        route: '/it-admin/servers',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.security_outlined,
        activeIcon: Icons.security,
        title: l10n.securityLogs,
        route: '/it-admin/security-logs',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.backup_outlined,
        activeIcon: Icons.backup,
        title: l10n.itBackupRecovery,
        route: '/it-admin/backup',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.api_outlined,
        activeIcon: Icons.api,
        title: l10n.itApiManagement,
        route: '/it-admin/api',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.hub_outlined,
        activeIcon: Icons.hub,
        title: l10n.itIntegrations,
        route: '/it-admin/integrations',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.psychology_outlined,
        activeIcon: Icons.psychology,
        title: l10n.itAiModelSettings,
        route: '/it-admin/ai-settings',
        category: 'main',
      ),
      _MenuItem(
        icon: Icons.bug_report_outlined,
        activeIcon: Icons.bug_report,
        title: l10n.itErrorLogs,
        route: '/it-admin/logs',
        category: 'monitoring',
      ),
      _MenuItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        title: l10n.itPerformance,
        route: '/it-admin/performance',
        category: 'monitoring',
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        title: l10n.itAlerts,
        route: '/it-admin/alerts',
        badge: '3',
        category: 'monitoring',
      ),
      _MenuItem(
        icon: Icons.storage_outlined,
        activeIcon: Icons.storage,
        title: l10n.itDatabase,
        route: '/it-admin/database',
        category: 'infrastructure',
      ),
      _MenuItem(
        icon: Icons.cloud_outlined,
        activeIcon: Icons.cloud,
        title: l10n.itCloudServices,
        route: '/it-admin/cloud',
        category: 'infrastructure',
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        title: l10n.settings,
        route: '/it-admin/settings',
        category: 'account',
      ),
      _MenuItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        title: l10n.itProfileScreen,
        route: '/it-admin/profile',
        category: 'account',
      ),
    ];
  }

  Widget _buildNavigationMenu(bool isDark, List<_MenuItem> items) {
    final mainItems = items.where((i) => i.category == 'main').toList();
    final monitoringItems = items
        .where((i) => i.category == 'monitoring')
        .toList();
    final infrastructureItems = items
        .where((i) => i.category == 'infrastructure')
        .toList();
    final accountItems = items.where((i) => i.category == 'account').toList();
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionLabel(isDark, l10n.itMainMenu),
        ...mainItems.map((item) => _buildNavItem(isDark, item)),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.itMonitoring),
        ...monitoringItems.map((item) => _buildNavItem(isDark, item)),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.itInfrastructure),
        ...infrastructureItems.map((item) => _buildNavItem(isDark, item)),
        const SizedBox(height: 16),
        _buildSectionLabel(isDark, l10n.itAccount),
        ...accountItems.map((item) => _buildNavItem(isDark, item)),
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

  Widget _buildNavItem(bool isDark, _MenuItem item) {
    final isSelected = widget.currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (item.route.isNotEmpty && !isSelected) {
              context.push(item.route);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? Colors.white
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
                          ? Colors.white
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
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
              onTap: () => context.go('/login'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.logout,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
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
              ? (isDark ? const Color(0xFF0891B2) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF0891B2) : Colors.black)
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
                  ? (isDark ? Colors.white : const Color(0xFF0891B2))
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
                    ? (isDark ? Colors.white : const Color(0xFF0891B2))
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
  final String category;

  _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
    this.badge,
    required this.category,
  });
}
