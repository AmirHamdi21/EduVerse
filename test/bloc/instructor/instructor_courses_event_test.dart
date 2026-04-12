import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_courses_event.dart';

void main() {
  group('InstructorCoursesEvent', () {
    test('SelectCourse supports value equality', () {
      expect(const SelectCourse(10), const SelectCourse(10));
      expect(const SelectCourse(10), isNot(const SelectCourse(11)));
    });

    test('LoadDeadlines supports value equality', () {
      expect(const LoadDeadlines(99), const LoadDeadlines(99));
      expect(const LoadDeadlines(99), isNot(const LoadDeadlines(100)));
    });

    test('LoadSectionStudents supports value equality', () {
      expect(const LoadSectionStudents(8), const LoadSectionStudents(8));
      expect(const LoadSectionStudents(8), isNot(const LoadSectionStudents(9)));
    });

    test('LoadEngagementMetrics stores all fields in props', () {
      const event = LoadEngagementMetrics(
        courseId: 12,
        totalEnrolledStudents: 40,
      );

      expect(event.props, equals(const <Object?>[12, 40]));
    });
  });
}
