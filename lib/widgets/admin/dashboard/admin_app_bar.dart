import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/notifications/notification_cubit.dart';
import '../../../bloc/notifications/notification_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminAppBar extends StatelessWidget {
  const AdminAppBar({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 21) return '🌆';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        SystemChrome.setSystemUIOverlayStyle(
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );

        return SliverAppBar(
          title: Row(
            children: [
              Text(
                l10n.appTitle,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          pinned: true,
          expandedHeight: 160,
          collapsedHeight: 70,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: AdminColors.getTextColor(isDark),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            _buildActionButton(
              context,
              icon: Icons.search_rounded,
              isDark: isDark,
              onTap: () => context.push('/admin/search'),
            ),
            const SizedBox(width: 6),
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, notificationState) {
                return _buildNotificationButton(
                  context,
                  isDark: isDark,
                  unreadCount: notificationState.unreadCount,
                  onTap: () => context.push('/admin/notifications'),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: AdminColors.getBackgroundGradient(isDark),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: TextStyle(
                                        color: AdminColors.getTextSecondaryColor(isDark),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getGreetingEmoji(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: isDark
                                        ? [Colors.white, Colors.white.withValues(alpha: 0.9)]
                                        : [const Color(0xFF0F172A), const Color(0xFF334155)],
                                  ).createShader(bounds),
                                  child: Text(
                                    l10n.admin,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildProfileAvatar(isDark, context),
                        ],
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

  Widget _buildNotificationButton(
    BuildContext context, {
    required bool isDark,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_rounded,
                color: AdminColors.getTextColor(isDark),
                size: 20,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: AdminColors.error,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AdminColors.darkSurface : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            icon,
            color: AdminColors.getTextColor(isDark),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isDark, BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/admin/profile'),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AdminColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.08),
            width: 2,
          ),
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
    );
  }
}
