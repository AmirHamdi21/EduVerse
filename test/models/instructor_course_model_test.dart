import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';

void main() {
  group('TeachingCourseModel.fromJson', () {
    test('parses nested objects and decimal statistics from strings', () {
      final model = TeachingCourseModel.fromJson(<String, dynamic>{
        'sectionId': '12',
        'userId': '34',
        'courseId': '56',
        'role': 'instructor',
        'enrolledCount': '30',
        'capacity': '40',
        'averageGrade': '87.5',
        'attendanceRate': '92.3',
        'course': <String, dynamic>{
          'id': 56,
          'departmentId': 2,
          'code': 'CS401',
          'name': 'Compiler Design',
          'credits': 3,
          'level': 'senior',
          'status': 'active',
        },
        'section': <String, dynamic>{
          'id': 12,
          'courseId': 56,
          'semesterId': 1,
          'sectionNumber': 'A1',
          'maxCapacity': 40,
          'currentEnrollment': 30,
          'status': 'active',
          'schedules': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'sectionId': 12,
              'dayOfWeek': 'MONDAY',
              'startTime': '09:00:00',
              'endTime': '10:30:00',
              'scheduleType': 'LECTURE',
              'room': 'R1',
              'building': 'Main',
            },
          ],
        },
        'semester': <String, dynamic>{
          'id': 1,
          'name': 'Spring 2026',
          'term': 'spring',
          'year': 2026,
        },
      });

      expect(model.sectionId, 12);
      expect(model.userId, 34);
      expect(model.courseId, 56);
      expect(model.enrolledCount, 30);
      expect(model.capacity, 40);
      expect(model.averageGrade, 87.5);
      expect(model.attendanceRate, 92.3);
      expect(model.course.courseCode, 'CS401');
      expect(model.section.schedules, isNotNull);
      expect(model.section.schedules!.length, 1);
      expect(model.section.schedules!.first.room, 'R1');
    });

    test('falls back to section counts when top-level counts are missing', () {
      final model = TeachingCourseModel.fromJson(<String, dynamic>{
        'sectionId': 5,
        'courseId': 9,
        'course': <String, dynamic>{
          'id': 9,
          'departmentId': 1,
          'code': 'MATH201',
          'name': 'Linear Algebra',
          'credits': 4,
          'level': 'sophomore',
          'status': 'active',
        },
        'section': <String, dynamic>{
          'id': 5,
          'courseId': 9,
          'semesterId': 2,
          'sectionNumber': 'B2',
          'maxCapacity': 35,
          'currentEnrollment': 22,
          'status': 'active',
        },
        'semester': <String, dynamic>{
          'id': 2,
          'name': 'Fall 2026',
          'term': 'fall',
          'year': 2026,
        },
      });

      expect(model.enrolledCount, 22);
      expect(model.capacity, 35);
    });
  });

  group('SectionStudentModel.fromJson', () {
    test('parses grade and attendance from string values', () {
      final student = SectionStudentModel.fromJson(<String, dynamic>{
        'userId': '101',
        'firstName': 'Lina',
        'lastName': 'Hassan',
        'email': 'lina@example.com',
        'enrollmentStatus': 'enrolled',
        'grade': '88.5',
        'attendanceRate': '96.2',
      });

      expect(student.userId, 101);
      expect(student.fullName, 'Lina Hassan');
      expect(student.grade, 88.5);
      expect(student.attendanceRate, 96.2);
    });
  });
}
