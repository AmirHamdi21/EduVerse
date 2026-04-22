import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/core/drive_file_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/screens/instructor/create_assignment_screen.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService(this.freshAssignment)
    : super(coreApiClient: CoreApiClient.test());

  final AssignmentModel freshAssignment;

  @override
  Future<ServiceResult<AssignmentModel>> getById(dynamic id) async {
    return ServiceResult<AssignmentModel>.success(freshAssignment);
  }
}

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.courses)
    : super(coreApiClient: CoreApiClient.test());

  final List<TeachingCourseModel> courses;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return ServiceResult<List<TeachingCourseModel>>.success(courses);
  }
}

TeachingCourseModel _course() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 2,
    'courseId': 99,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': 99,
      'departmentId': 1,
      'code': 'CS999',
      'name': 'Advanced Engineering',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': 99,
      'semesterId': 3,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 25,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 3,
      'name': 'Fall 2026',
      'term': 'fall',
      'year': 2026,
    },
  });
}

AssignmentModel _staleEditableAssignment() {
  return AssignmentModel(
    id: '42',
    assignmentId: 42,
    courseId: 99,
    title: 'Compiler Assignment',
    description: 'Implement lexical analyzer',
    courseName: 'Advanced Engineering',
    courseCode: 'CS999',
    instructorName: 'Dr. Edit',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime(2026, 12, 25, 10, 0),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.file,
    maxFileSizeMb: 10,
    instructionsText: 'Use DFA construction.',
  );
}

AssignmentModel _freshEditableAssignment() {
  return AssignmentModel(
    id: '42',
    assignmentId: 42,
    courseId: 99,
    title: 'Compiler Assignment',
    description: 'Implement lexical analyzer',
    courseName: 'Advanced Engineering',
    courseCode: 'CS999',
    instructorName: 'Dr. Edit',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime(2026, 12, 25, 10, 0),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.file,
    maxFileSizeMb: 10,
    instructionsText: 'Use DFA construction.',
    instructionFiles: const <DriveFileModel>[
      DriveFileModel(
        driveFileId: 7,
        driveId: 'abc123',
        fileName: 'rubric.pdf',
        webViewLink: 'https://drive.google.com/file/d/abc123/view',
        downloadUrl: 'https://drive.google.com/uc?id=abc123&export=download',
        iframeUrl: 'https://drive.google.com/file/d/abc123/preview',
      ),
    ],
  );
}

void main() {
  testWidgets(
    're-opening edit screen shows previously uploaded instruction files',
    (WidgetTester tester) async {
      final staleAssignment = _staleEditableAssignment();
      final freshAssignment = _freshEditableAssignment();

      await tester.pumpWidget(
        MaterialApp(
          home: CreateAssignmentScreen(
            assignment: staleAssignment,
            assignmentId: staleAssignment.assignmentId,
            assignmentService: _FakeAssignmentService(freshAssignment),
            enrollmentService: _FakeEnrollmentService(<TeachingCourseModel>[
              _course(),
            ]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final fileName = find.text('rubric.pdf');
      await tester.scrollUntilVisible(
        fileName,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(fileName, findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    },
  );
}
