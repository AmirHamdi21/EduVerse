import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/shared/navigation/liquid_glass_role_bottom_nav.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';

class TALiquidGlassBottomNav extends StatelessWidget {
  const TALiquidGlassBottomNav({
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
        primary: TAColors.primary,
        secondary: TAColors.cyan,
        action: TAColors.secondary,
        lightTextPrimary: TAColors.textPrimary,
        lightTextSecondary: TAColors.textSecondary,
        darkTextPrimary: TAColors.darkTextPrimary,
        darkTextSecondary: TAColors.darkTextSecondary,
      ),
      mainItems: [
        LiquidGlassNavItem(
          icon: Icons.home_rounded,
          label: l10n.home,
          route: '/ta/dashboard',
        ),
        LiquidGlassNavItem(
          icon: Icons.list_alt_rounded,
          label: l10n.tasks,
          route: '/ta/assignments',
        ),
        LiquidGlassNavItem(
          icon: Icons.fact_check_rounded,
          label: l10n.grading,
          route: '/ta/grading',
        ),
        LiquidGlassNavItem(
          icon: Icons.bar_chart_rounded,
          label: l10n.stats,
          route: '/ta/analytics',
        ),
      ],
      actionItem: LiquidGlassNavItem(
        icon: Icons.auto_awesome_rounded,
        label: l10n.ai,
        route: '/ta/ai-assistant',
      ),
    );
  }
}
