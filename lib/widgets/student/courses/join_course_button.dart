import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../common/utils/student_courses_theme.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class JoinCourseButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool compact;
  final bool showPulse;
  final bool useHeroGradient;

  const JoinCourseButton({
    super.key,
    this.onPressed,
    this.compact = false,
    this.showPulse = true,
    this.useHeroGradient = false,
  });

  @override
  State<JoinCourseButton> createState() => _JoinCourseButtonState();
}

class _JoinCourseButtonState extends State<JoinCourseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isRepeating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool shouldAnimate = widget.showPulse && TickerMode.of(context);
    if (shouldAnimate && !_isRepeating) {
      _controller.repeat(reverse: true);
      _isRepeating = true;
    } else if (!shouldAnimate && _isRepeating) {
      _controller.stop();
      _isRepeating = false;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final gradient = widget.useHeroGradient
            ? (isDark
                  ? StudentCoursesTheme.headerGradientDark
                  : StudentCoursesTheme.heroGradientLight)
            : StudentCoursesTheme.primaryGradient;

        return Padding(
          padding: widget.compact ? EdgeInsets.zero : const EdgeInsets.all(4),
          child: Semantics(
            button: true,
            label: l10n.joinCourse,
            hint: l10n.studentCourseJoinHint,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(widget.compact ? 22 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: StudentCoursesTheme.brandBlue.withValues(
                        alpha: 0.36,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _onPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        widget.compact ? 22 : 28,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.add_rounded, size: widget.compact ? 18 : 20),
                  label: Text(
                    l10n.joinCourse,
                    style: TextStyle(
                      fontSize: widget.compact ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPressed(BuildContext context) {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push('/registration');
      return;
    }

    Navigator.of(context).pushNamed('/registration');
  }
}
