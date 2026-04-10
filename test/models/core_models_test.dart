import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';

void main() {
  group('CourseModel', () {
    test('fromJson parses a complete payload correctly', () {
      final json = {
        'courseId': 1,
        'courseCode': 'CS101',
        'courseName': 'Intro to Computer Science',
        'description': 'A beginner course.',
        'credits': 3,
        'departmentId': 5,
        'department': {'id': 5, 'name': 'Computer Science', 'code': 'CS'},
        'level': 'FRESHMAN',
        'status': 'ACTIVE',
        'prerequisites': [
          {'courseId': 0, 'courseName': 'None'},
        ],
      };

      final model = CourseModel.fromJson(json);

      expect(model.courseId, 1);
      expect(model.courseCode, 'CS101');
      expect(model.courseName, 'Intro to Computer Science');
      expect(model.description, 'A beginner course.');
      expect(model.credits, 3);
      expect(model.departmentId, 5);
      expect(model.departmentName, 'Computer Science');
      expect(model.level, 'FRESHMAN');
      expect(model.status, 'ACTIVE');
      expect(model.prerequisites, isNotNull);
      expect(model.prerequisites!.length, 1);
    });

    test('fromJson handles string courseId gracefully', () {
      final json = {
        'courseId': '42',
        'courseCode': 'MATH200',
        'courseName': 'Linear Algebra',
        'credits': '4',
      };

      final model = CourseModel.fromJson(json);

      expect(model.courseId, 42);
      expect(model.credits, 4);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'courseId': 10,
        'courseCode': 'PHY100',
        'courseName': 'Physics I',
        'credits': 3,
      };

      final model = CourseModel.fromJson(json);

      expect(model.description, isNull);
      expect(model.departmentId, 0);
      expect(model.departmentName, isNull);
      expect(model.level, 'unknown');
      expect(model.status, 'unknown');
      expect(model.prerequisites, isNull);
    });

    test('toJson produces valid map', () {
      const model = CourseModel(
        id: 1,
        departmentId: 5,
        code: 'CS101',
        name: 'Test',
        credits: 3,
        courseLevel: CourseLevel.freshman,
        courseStatus: CourseStatus.active,
      );

      final json = model.toJson();

      expect(json['courseId'], 1);
      expect(json['courseCode'], 'CS101');
    });

    test('Equatable equality works', () {
      const a = CourseModel(
        id: 1,
        departmentId: 5,
        code: 'CS101',
        name: 'Test',
        credits: 3,
        courseLevel: CourseLevel.freshman,
        courseStatus: CourseStatus.active,
      );
      const b = CourseModel(
        id: 1,
        departmentId: 5,
        code: 'CS101',
        name: 'Test',
        credits: 3,
        courseLevel: CourseLevel.freshman,
        courseStatus: CourseStatus.active,
      );

      expect(a, equals(b));
    });
  });

  group('CourseEnrollmentModel', () {
    test('fromJson parses a complete payload with nested course', () {
      final json = {
        'id': '101',
        'courseId': '1',
        'userId': 42,
        'sectionId': 1,
        'enrollmentDate': '2026-01-15T00:00:00.000Z',
        'role': 'student',
        'status': 'enrolled',
        'course': {
          'id': 1,
          'departmentId': 5,
          'code': 'CS101',
          'name': 'Intro to CS',
          'credits': 3,
          'level': 'FRESHMAN',
          'status': 'ACTIVE',
        },
        'createdAt': '2026-01-15T10:00:00.000Z',
        'updatedAt': '2026-01-15T10:00:00.000Z',
      };

      final model = CourseEnrollmentModel.fromJson(json);

      expect(model.id, '101');
      expect(model.courseId, '1');
      expect(model.userId, 42);
      expect(model.role, 'student');
      expect(model.status, 'enrolled');
      expect(model.course, isNotNull);
      expect(model.course!.courseCode, 'CS101');
    });

    test('fromJson handles missing course (null)', () {
      final json = {
        'id': '102',
        'courseId': '2',
        'userId': 43,
        'sectionId': 2,
        'enrollmentDate': '2026-02-01T00:00:00.000Z',
        'role': 'instructor',
        'status': 'enrolled',
        'createdAt': '2026-02-01T00:00:00.000Z',
        'updatedAt': '2026-02-01T00:00:00.000Z',
      };

      final model = CourseEnrollmentModel.fromJson(json);

      expect(model.course, isNull);
      expect(model.role, 'instructor');
    });

    test('toJson round-trips correctly', () {
      final json = {
        'id': '101',
        'courseId': '1',
        'userId': 42,
        'sectionId': 1,
        'enrollmentDate': '2026-01-15T00:00:00.000Z',
        'role': 'student',
        'status': 'enrolled',
        'createdAt': '2026-01-15T10:00:00.000Z',
        'updatedAt': '2026-01-15T10:00:00.000Z',
      };

      final model = CourseEnrollmentModel.fromJson(json);
      final output = model.toJson();

      expect(output['id'], '101');
      expect(output['userId'], 42);
    });
  });

  group('CourseStructureModel', () {
    test('fromJson parses without nested material', () {
      final json = {
        'organizationId': 'org-1',
        'courseId': '1',
        'organizationType': 'lecture',
        'title': 'Week 1: Introduction',
        'weekNumber': 1,
        'orderIndex': 0,
        'description': 'Intro lecture',
        'createdAt': '2026-01-10T08:00:00.000Z',
        'updatedAt': '2026-01-10T08:00:00.000Z',
      };

      final model = CourseStructureModel.fromJson(json);

      expect(model.organizationId, 'org-1');
      expect(model.organizationType, 'lecture');
      expect(model.weekNumber, 1);
      expect(model.material, isNull);
    });

    test('fromJson parses with nested material', () {
      final json = {
        'organizationId': 'org-2',
        'courseId': '1',
        'materialId': 'mat-1',
        'material': {
          'materialId': 'mat-1',
          'courseId': '1',
          'materialType': 'slide',
          'title': 'Lecture 1 Slides',
          'isPublished': 1,
          'createdAt': '2026-01-10T08:00:00.000Z',
        },
        'organizationType': 'lab',
        'title': 'Lab 1',
        'weekNumber': 1,
        'orderIndex': 1,
      };

      final model = CourseStructureModel.fromJson(json);

      expect(model.material, isNotNull);
      expect(model.material!.title, 'Lecture 1 Slides');
      expect(model.material!.isPublished, true);
    });
  });
}
