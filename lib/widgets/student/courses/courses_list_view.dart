import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/core/enrollment_model.dart';
import 'course_card.dart';
import 'empty_courses_message.dart';

/// Renders enrolled courses with responsive tablet handling and staggered entry
/// animations.
class CoursesListView extends StatefulWidget {
  final List<CourseEnrollmentModel> enrollments;

  const CoursesListView({super.key, required this.enrollments});

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
    _pendingAnimations = <Future<void>>[];
    for (int i = 0; i < _animationControllers.length; i++) {
      final animation = Future<void>.delayed(
        Duration(milliseconds: i * 120),
        () {
          if (mounted && i < _animationControllers.length) {
            _animationControllers[i].forward();
          }
        },
      );
      _pendingAnimations!.add(animation);
    }
  }

  @override
  void didUpdateWidget(covariant CoursesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enrollments.length != widget.enrollments.length) {
      _disposeAnimations();
      _initializeAnimations();
    }
  }

  void _disposeAnimations() {
    for (final controller in _animationControllers) {
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

        if (widget.enrollments.isEmpty) {
          return EmptyCoursesMessage(isDark: isDark);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool useGrid = width >= 960;
            final int crossAxisCount = width >= 1260 ? 3 : 2;

            if (!useGrid) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.enrollments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 18),
                itemBuilder: (context, index) => CourseCard(
                  enrollment: widget.enrollments[index],
                  animation: CurvedAnimation(
                    parent: _animationControllers[index],
                    curve: Curves.easeOut,
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.enrollments.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) => CourseCard(
                enrollment: widget.enrollments[index],
                animation: CurvedAnimation(
                  parent: _animationControllers[index],
                  curve: Curves.easeOut,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
