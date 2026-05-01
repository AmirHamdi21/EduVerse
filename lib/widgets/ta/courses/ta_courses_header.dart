import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/common/utils/ta_courses_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TACoursesHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget tabBar;
  final Widget? stats;
  final Widget? searchBar;
  final Widget? trailingAction;
  final VoidCallback onMenuTap;
  final bool showSearch;

  const TACoursesHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tabBar,
    required this.onMenuTap,
    this.stats,
    this.searchBar,
    this.trailingAction,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 560;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSearch)
                  _HeaderChrome(
                    isDark: isDark,
                    isNarrow: isNarrow,
                    searchBar: searchBar,
                    trailingAction: trailingAction,
                    onMenuTap: onMenuTap,
                  ),
                if (showSearch) const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? TACoursesTheme.headerGradientDark
                        : TACoursesTheme.heroGradientLight,
                    borderRadius: TACoursesTheme.shellRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                    isNarrow ? 16 : 20,
                    isNarrow ? 18 : 20,
                    isNarrow ? 16 : 20,
                    isNarrow ? 14 : 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isNarrow ? 28 : 34,
                          fontWeight: FontWeight.w800,
                          height: 1.06,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      if (stats != null) ...[
                        const SizedBox(height: 12),
                        stats!,
                      ],
                      const SizedBox(height: 14),
                      tabBar,
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HeaderChrome extends StatelessWidget {
  final bool isDark;
  final bool isNarrow;
  final Widget? searchBar;
  final Widget? trailingAction;
  final VoidCallback onMenuTap;

  const _HeaderChrome({
    required this.isDark,
    required this.isNarrow,
    required this.searchBar,
    required this.trailingAction,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final backIcon = textDirection == TextDirection.rtl
        ? Icons.arrow_forward_ios_rounded
        : Icons.arrow_back_ios_new_rounded;

    final menuButton = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? TACoursesTheme.darkSurfaceRaised
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: TACoursesTheme.pillRadius,
        border: Border.all(color: TACoursesTheme.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _goToDashboard(context),
        icon: Icon(
          backIcon,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          size: 20,
        ),
      ),
    );

    final logoBadge = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? TACoursesTheme.darkSurfaceRaised
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: TACoursesTheme.pillRadius,
        border: Border.all(color: TACoursesTheme.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              menuButton,
              const SizedBox(width: 12),
              logoBadge,
              const Spacer(),
              if (trailingAction != null) trailingAction!,
            ],
          ),
          if (searchBar != null) ...[const SizedBox(height: 12), searchBar!],
        ],
      );
    }

    return Row(
      children: [
        menuButton,
        const SizedBox(width: 12),
        logoBadge,
        const SizedBox(width: 12),
        if (searchBar != null) Expanded(child: searchBar!),
        if (trailingAction != null) ...[
          const SizedBox(width: 12),
          trailingAction!,
        ],
      ],
    );
  }

  void _goToDashboard(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null) {
      context.go('/ta/dashboard');
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacementNamed('/ta/dashboard');
  }
}
