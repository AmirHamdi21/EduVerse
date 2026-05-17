import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:edu_verse/widgets/shared/navigation/liquid_glass_role_bottom_nav.dart';
import 'package:flutter/material.dart';

class InstructorLiquidGlassBottomNav extends StatelessWidget {
  const InstructorLiquidGlassBottomNav({
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
        primary: InstructorColors.primary,
        secondary: InstructorColors.info,
        action: InstructorColors.info,
        lightTextPrimary: InstructorColors.textPrimary,
        lightTextSecondary: InstructorColors.textSecondary,
        darkTextPrimary: InstructorColors.darkTextPrimary,
        darkTextSecondary: InstructorColors.darkTextSecondary,
      ),
      mainItems: [
        LiquidGlassNavItem(
          icon: Icons.home_rounded,
          label: l10n.home,
          route: '/instructor/dashboard',
        ),
        LiquidGlassNavItem(
          icon: Icons.menu_book_rounded,
          label: l10n.courses,
          route: '/instructor/courses',
        ),
        LiquidGlassNavItem(
          icon: Icons.storage_rounded,
          label: l10n.questionBank,
          route: '/instructor/question-bank',
        ),
        LiquidGlassNavItem(
          icon: Icons.description_rounded,
          label: l10n.examGenerator,
          route: '/instructor/exam-generator',
        ),
      ],
      actionItem: LiquidGlassNavItem(
        icon: Icons.auto_awesome_rounded,
        label: l10n.ai,
        route: '/instructor/ai-teaching',
      ),
    );
  }
}
