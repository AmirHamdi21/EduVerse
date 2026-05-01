import 'package:flutter/material.dart';

import '../../../models/instructor/extended_course_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import 'ta_course_shell_card.dart';

class TACoursesListView extends StatelessWidget {
  final List<TeachingCourseModel> courses;
  final Map<int, int> studentCounts;
  final CourseViewType viewType;
  final ValueChanged<TeachingCourseModel> onTap;
  final ValueChanged<TeachingCourseModel> onLabsTap;
  final ValueChanged<TeachingCourseModel> onGradingTap;
  final ValueChanged<TeachingCourseModel> onDiscussionsTap;

  const TACoursesListView({
    super.key,
    required this.courses,
    required this.studentCounts,
    required this.viewType,
    required this.onTap,
    required this.onLabsTap,
    required this.onGradingTap,
    required this.onDiscussionsTap,
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
              return TACourseShellCard(
                course: course,
                studentCount: studentCounts[course.sectionId] ?? course.enrolledCount,
                viewType: viewType,
                onTap: () => onTap(course),
                onLabsTap: () => onLabsTap(course),
                onGradingTap: () => onGradingTap(course),
                onDiscussionsTap: () => onDiscussionsTap(course),
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
              return TACourseShellCard(
                course: course,
                studentCount: studentCounts[course.sectionId] ?? course.enrolledCount,
                viewType: viewType,
                onTap: () => onTap(course),
                onLabsTap: () => onLabsTap(course),
                onGradingTap: () => onGradingTap(course),
                onDiscussionsTap: () => onDiscussionsTap(course),
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
            childAspectRatio: constraints.maxWidth >= 1320 ? 0.78 : 0.74,
          ),
          itemBuilder: (context, index) {
            final course = courses[index];
            return TACourseShellCard(
              course: course,
              studentCount: studentCounts[course.sectionId] ?? course.enrolledCount,
              viewType: viewType,
              onTap: () => onTap(course),
              onLabsTap: () => onLabsTap(course),
              onGradingTap: () => onGradingTap(course),
              onDiscussionsTap: () => onDiscussionsTap(course),
            );
          },
        );
      },
    );
  }
}
