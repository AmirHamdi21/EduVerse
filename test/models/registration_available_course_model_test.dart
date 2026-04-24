import 'package:edu_verse/models/registration/registration_available_course_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistrationAvailableCourseModel', () {
    test('parses backend available-courses payload', () {
      final model = RegistrationAvailableCourseModel.fromJson(<String, dynamic>{
        'id': '77',
        'name': 'Data Structures',
        'code': 'CS201',
        'description': 'Core data structures and analysis',
        'credits': '3',
        'level': 'sophomore',
        'departmentId': '1',
        'departmentName': 'Computer Science',
        'canEnroll': true,
        'enrollmentStatus': 'enrolled',
        'prerequisites': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 4,
            'courseId': 77,
            'prerequisiteCourseId': 12,
            'courseCode': 'CS101',
            'courseName': 'Programming Fundamentals',
            'isMandatory': true,
          },
        ],
        'sections': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 31,
            'sectionNumber': 'A',
            'maxCapacity': 40,
            'currentEnrollment': 32,
            'availableSeats': 8,
            'location': 'B-201',
            'semesterId': 2,
            'semesterName': 'Fall 2026',
          },
        ],
      });

      expect(model.id, 77);
      expect(model.credits, 3);
      expect(model.departmentId, 1);
      expect(model.isAlreadyEnrolled, isTrue);
      expect(model.sections.first.availableSeats, 8);
      expect(model.prerequisites.first.courseCode, 'CS101');
    });

    test('handles missing enrollmentStatus safely', () {
      final model = RegistrationAvailableCourseModel.fromJson(<String, dynamic>{
        'id': 12,
        'name': 'Algorithms',
        'code': 'CS301',
        'description': '',
        'credits': 3,
        'level': 'junior',
        'departmentId': 1,
        'departmentName': 'Unknown',
        'canEnroll': false,
        'prerequisites': <dynamic>[],
        'sections': <dynamic>[],
      });

      expect(model.enrollmentStatus, isNull);
      expect(model.normalizedEnrollmentStatus, 'not_enrolled');
      expect(model.isAlreadyEnrolled, isFalse);
    });

    test('falls back availableSeats when omitted', () {
      final model = RegistrationAvailableCourseModel.fromJson(<String, dynamic>{
        'id': 9,
        'name': 'Networks',
        'code': 'CS330',
        'description': '',
        'credits': 3,
        'level': 'junior',
        'departmentId': 1,
        'departmentName': 'Computer Science',
        'canEnroll': true,
        'prerequisites': <dynamic>[],
        'sections': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 91,
            'sectionNumber': 'B',
            'maxCapacity': 40,
            'currentEnrollment': 38,
            'location': 'Lab 4',
            'semesterId': 2,
            'semesterName': 'Fall 2026',
          },
        ],
      });

      expect(model.sections.first.availableSeats, 2);
      expect(model.sections.first.isFull, isFalse);
    });
  });
}
