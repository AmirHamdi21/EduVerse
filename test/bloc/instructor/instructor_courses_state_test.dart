import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';

TeachingCourseModel _course() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 1,
    'userId': 10,
    'courseId': 56,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': 56,
      'departmentId': 1,
      'code': 'CS401',
      'name': 'Compiler Design',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 1,
      'courseId': 56,
      'semesterId': 3,
      'sectionNumber': 'A',
      'maxCapacity': 20,
      'currentEnrollment': 15,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 3,
      'name': 'Spring 2026',
      'term': 'spring',
      'year': 2026,
    },
  });
}

@Timeout(Duration(seconds: 30))
void main() {
  group('InstructorCoursesState', () {
    test('InstructorCoursesLoaded supports value equality', () {
      final first = InstructorCoursesLoaded(<TeachingCourseModel>[_course()]);
      final second = InstructorCoursesLoaded(<TeachingCourseModel>[_course()]);

      expect(first, second);
    });

    test('InstructorCoursesLoaded includes nested metrics in equality', () {
      final first = InstructorCoursesLoaded(
        <TeachingCourseModel>[_course()],
        deadlines: const <DeadlineCardModel>[
          DeadlineCardModel(
            id: '1',
            title: 'HW1',
            type: DeadlineType.assignment,
            dueDate: null,
            status: DeadlineStatus.upcoming,
            courseId: 56,
          ),
        ],
        sectionStudents: const <SectionStudentModel>[
          SectionStudentModel(userId: 7, status: 'enrolled'),
        ],
      );

      final second = InstructorCoursesLoaded(
        <TeachingCourseModel>[_course()],
        deadlines: const <DeadlineCardModel>[
          DeadlineCardModel(
            id: '1',
            title: 'HW1',
            type: DeadlineType.assignment,
            dueDate: null,
            status: DeadlineStatus.upcoming,
            courseId: 56,
          ),
        ],
        sectionStudents: const <SectionStudentModel>[
          SectionStudentModel(userId: 7, status: 'enrolled'),
        ],
      );

      expect(first, second);
    });

    test('InstructorCoursesError stores message', () {
      const state = InstructorCoursesError('network failed');

      expect(state.message, 'network failed');
      expect(state.props, equals(const <Object?>['network failed']));
    });
  });
}
