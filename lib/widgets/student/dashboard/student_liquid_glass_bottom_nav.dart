import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/shared/navigation/liquid_glass_role_bottom_nav.dart';
import 'package:flutter/material.dart';

class StudentLiquidGlassBottomNav extends StatelessWidget {
  const StudentLiquidGlassBottomNav({
    super.key,
    required this.isDark,
    required this.isVisible,
  });

  final bool isDark;
  final bool isVisible;

  static const double height = LiquidGlassRoleBottomNav.height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LiquidGlassRoleBottomNav(
      isDark: isDark,
      isVisible: isVisible,
      theme: const LiquidGlassNavTheme(
        primary: Color(0xFF155CFB),
        secondary: Color(0xFF06B6D4),
        action: Color(0xFF8B5CF6),
        lightTextPrimary: Color(0xFF101727),
        lightTextSecondary: Color(0xFF64748B),
        darkTextPrimary: Colors.white,
        darkTextSecondary: Colors.white70,
      ),
      mainItems: [
        LiquidGlassNavItem(
          icon: Icons.home_rounded,
          label: l10n.dashboard,
          route: '/dashboard',
        ),
        LiquidGlassNavItem(
          icon: Icons.menu_book_outlined,
          label: l10n.courses,
          route: '/courses',
        ),
        LiquidGlassNavItem(
          icon: Icons.bar_chart_rounded,
          label: l10n.grades,
          route: '/grades',
        ),
        LiquidGlassNavItem(
          icon: Icons.person_rounded,
          label: l10n.profile,
          route: '/profile',
        ),
      ],
      actionItem: LiquidGlassNavItem(
        icon: Icons.psychology_outlined,
        label: l10n.ai,
        route: '/ai-chat',
      ),
    );
  }
}
