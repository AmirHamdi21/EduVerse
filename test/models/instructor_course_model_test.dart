import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';

@Timeout(Duration(seconds: 30))
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
    test('parses nested user identity with grade and finalScore', () {
      final student = SectionStudentModel.fromJson(<String, dynamic>{
        'userId': 101,
        'status': 'enrolled',
        'grade': 88.5,
        'finalScore': 96.2,
        'enrollmentDate': '2026-04-01T00:00:00Z',
        'user': <String, dynamic>{
          'userId': 101,
          'fullName': 'Noura Adel',
          'email': 'noura.adel@eduverse.test',
          'profilePictureUrl': 'https://cdn.test/noura.png',
        },
        'course': <String, dynamic>{
          'id': 1,
          'name': 'Computer Science 101',
          'code': 'CS101',
        },
        'section': <String, dynamic>{'id': 6, 'sectionNumber': 1},
      });

      expect(student.userId, 101);
      expect(student.displayName, 'Noura Adel');
      expect(student.resolvedEmail, 'noura.adel@eduverse.test');
      expect(student.grade, 88.5);
      expect(student.finalScore, 96.2);
      expect(student.profilePictureUrl, 'https://cdn.test/noura.png');
    });

    test('falls back from flat names to email to Student #id', () {
      final withNames = SectionStudentModel.fromJson(<String, dynamic>{
        'userId': 7,
        'firstName': 'Mona',
        'lastName': 'Ali',
        'status': 'enrolled',
      });
      expect(withNames.displayName, 'Mona Ali');

      final withEmail = SectionStudentModel.fromJson(<String, dynamic>{
        'userId': 8,
        'email': 'student8@eduverse.test',
        'status': 'enrolled',
      });
      expect(withEmail.displayName, 'student8@eduverse.test');
      expect(withEmail.studentIdLabel, 'Student #8');

      final fallback = SectionStudentModel.fromJson(<String, dynamic>{
        'userId': 9,
        'status': 'enrolled',
      });
      expect(fallback.displayName, 'Student #9');
    });
  });
}
