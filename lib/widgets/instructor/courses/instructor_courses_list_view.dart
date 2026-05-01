import 'package:flutter/material.dart';

import '../../../models/instructor/extended_course_model.dart';
import 'instructor_course_shell_card.dart';

class InstructorCoursesListView extends StatelessWidget {
  final List<ExtendedCourse> courses;
  final CourseViewType viewType;
  final bool canDelete;
  final bool isSelectionMode;
  final Set<String> selectedCourseIds;
  final ValueChanged<ExtendedCourse> onTap;
  final ValueChanged<ExtendedCourse> onLongPress;
  final void Function(ExtendedCourse course, String action) onQuickAction;

  const InstructorCoursesListView({
    super.key,
    required this.courses,
    required this.viewType,
    required this.canDelete,
    required this.isSelectionMode,
    required this.selectedCourseIds,
    required this.onTap,
    required this.onLongPress,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (viewType == CourseViewType.compact) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = courses[index];
              return InstructorCourseShellCard(
                course: course,
                isSelected: selectedCourseIds.contains(course.course.id),
                isSelectionMode: isSelectionMode,
                canDelete: canDelete,
                compact: true,
                onTap: () => onTap(course),
                onLongPress: () => onLongPress(course),
                onQuickAction: (action) => onQuickAction(course, action),
              );
            },
          );
        }

        final useGrid =
            viewType == CourseViewType.grid && constraints.maxWidth >= 900;
        final crossAxisCount = constraints.maxWidth >= 1320 ? 3 : 2;

        if (!useGrid) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final course = courses[index];
              return InstructorCourseShellCard(
                course: course,
                isSelected: selectedCourseIds.contains(course.course.id),
                isSelectionMode: isSelectionMode,
                canDelete: canDelete,
                onTap: () => onTap(course),
                onLongPress: () => onLongPress(course),
                onQuickAction: (action) => onQuickAction(course, action),
              );
            },
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: constraints.maxWidth >= 1320 ? 0.84 : 0.8,
          ),
          itemBuilder: (context, index) {
            final course = courses[index];
            return InstructorCourseShellCard(
              course: course,
              isSelected: selectedCourseIds.contains(course.course.id),
              isSelectionMode: isSelectionMode,
              canDelete: canDelete,
              onTap: () => onTap(course),
              onLongPress: () => onLongPress(course),
              onQuickAction: (action) => onQuickAction(course, action),
            );
          },
        );
      },
    );
  }
}
