import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/enrollment_model.dart';
import 'course_card.dart';

/// Renders a list of enrolled courses with staggered entry animations.
///
/// Accepts [List<CourseEnrollmentModel>] from [CoursesBloc] state and
/// delegates rendering to individual [CourseCard] widgets.
class CoursesListView extends StatefulWidget {
  final List<CourseEnrollmentModel> enrollments;

  const CoursesListView({
    super.key,
    required this.enrollments,
  });

  @override
  State<CoursesListView> createState() => _CoursesListViewState();
}

class _CoursesListViewState extends State<CoursesListView>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  List<Future<void>>? _pendingAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.enrollments.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    _pendingAnimations = [];
    for (int i = 0; i < _animationControllers.length; i++) {
      final animation = Future.delayed(Duration(milliseconds: i * 120), () {
        if (mounted && i < _animationControllers.length) {
          _animationControllers[i].forward();
        }
      });
      _pendingAnimations?.add(animation);
    }
  }

  @override
  void didUpdateWidget(CoursesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enrollments.length != widget.enrollments.length) {
      _pendingAnimations = null;
      _disposeAnimations();
      _initializeAnimations();
    }
  }

  void _disposeAnimations() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _pendingAnimations = null;
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        if (widget.enrollments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: isDark ? Colors.white30 : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noData,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.enrollments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => CourseCard(
            enrollment: widget.enrollments[index],
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationControllers[index],
                curve: Curves.easeOut,
              ),
            ),
          ),
        );
      },
    );
  }
}
