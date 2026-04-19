import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_event.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/assignments/assignment_submission_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/enums/lab_enums.dart' as lab_api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart'
    hide AssignmentModel;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService({
    required this.coursesResult,
    required this.studentsResult,
  }) : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<TeachingCourseModel>> coursesResult;
  ServiceResult<List<SectionStudentModel>> studentsResult;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return coursesResult;
  }

  @override
  Future<ServiceResult<List<SectionStudentModel>>> getSectionStudentsLite(
    dynamic sectionId,
  ) async {
    return studentsResult;
  }
}

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService({
    required this.assignmentsResult,
    required this.submissionsByAssignment,
  }) : super(coreApiClient: CoreApiClient.test());

  ServiceResult<PaginatedResponse<AssignmentModel>> assignmentsResult;
  Map<String, ServiceResult<List<AssignmentSubmissionModel>>>
  submissionsByAssignment;

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    return assignmentsResult;
  }

  @override
  Future<ServiceResult<List<AssignmentSubmissionModel>>> getSubmissions(
    dynamic assignmentId,
  ) async {
    return submissionsByAssignment[assignmentId.toString()] ??
        ServiceResult<List<AssignmentSubmissionModel>>.success(
          const <AssignmentSubmissionModel>[],
        );
  }
}

class _FakeLabService extends LabService {
  _FakeLabService({required this.labsResult})
    : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<LabModel>> labsResult;

  @override
  Future<ServiceResult<List<LabModel>>> getAll({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    return labsResult;
  }
}

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService({required this.materials})
    : super(coreApiClient: CoreApiClient.test());

  final List<CourseMaterialModel> materials;

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    return materials;
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 99,
    'courseId': 56,
    'role': 'instructor',
    'enrolledCount': 4,
    'capacity': 20,
    'averageGrade': '86.5',
    'attendanceRate': '91.0',
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
      'id': 12,
      'courseId': 56,
      'semesterId': 3,
      'sectionNumber': 'A',
      'maxCapacity': 20,
      'currentEnrollment': 4,
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

AssignmentModel _assignment({required String id, required DateTime dueDate}) {
  return AssignmentModel(
    id: id,
    assignmentId: int.tryParse(id) ?? 1,
    courseId: 56,
    title: 'Assignment $id',
    description: 'desc',
    courseName: 'Compiler Design',
    courseCode: 'CS401',
    instructorName: 'Instructor',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: dueDate,
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.text,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

LabModel _lab({required String id, required DateTime dueDate}) {
  return LabModel(
    id: id,
    courseId: 56,
    title: 'Lab $id',
    dueDate: dueDate,
    maxScore: 100,
    weight: 0,
    status: lab_api.LabStatus.published,
  );
}

AssignmentSubmissionModel _submission({
  required int id,
  required int userId,
  required int assignmentId,
}) {
  return AssignmentSubmissionModel(
    id: id,
    assignmentId: assignmentId,
    userId: userId,
    submissionStatus: api.SubmissionStatus.submitted,
    isLate: false,
    attemptNumber: 1,
    submittedAt: DateTime(2026, 1, 1),
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

@Timeout(Duration(seconds: 30))
void main() {
  group('InstructorCoursesBloc', () {
    test('loads teaching courses successfully', () async {
      final bloc = InstructorCoursesBloc(
        enrollmentService: _FakeEnrollmentService(
          coursesResult: ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse()],
          ),
          studentsResult: ServiceResult<List<SectionStudentModel>>.success(
            const <SectionStudentModel>[],
          ),
        ),
        assignmentService: _FakeAssignmentService(
          assignmentsResult:
              ServiceResult<PaginatedResponse<AssignmentModel>>.success(
                const PaginatedResponse<AssignmentModel>(
                  data: <AssignmentModel>[],
                  total: 0,
                  page: 1,
                  limit: 1,
                  totalPages: 1,
                ),
              ),
          submissionsByAssignment:
              const <String, ServiceResult<List<AssignmentSubmissionModel>>>{},
        ),
        labService: _FakeLabService(
          labsResult: ServiceResult<List<LabModel>>.success(const <LabModel>[]),
        ),
      );

      bloc.add(const LoadTeachingCourses());
      await _flush();
      await _flush();

      expect(bloc.state, isA<InstructorCoursesLoaded>());
      final state = bloc.state as InstructorCoursesLoaded;
      expect(state.courses.length, 1);
      expect(state.courses.first.course.courseCode, 'CS401');

      await bloc.close();
    });

    test('emits error when teaching courses request fails', () async {
      final bloc = InstructorCoursesBloc(
        enrollmentService: _FakeEnrollmentService(
          coursesResult: ServiceResult<List<TeachingCourseModel>>.failure(
            const ServiceError(
              type: ServiceErrorType.network,
              message: 'network down',
            ),
          ),
          studentsResult: ServiceResult<List<SectionStudentModel>>.success(
            const <SectionStudentModel>[],
          ),
        ),
        assignmentService: _FakeAssignmentService(
          assignmentsResult:
              ServiceResult<PaginatedResponse<AssignmentModel>>.success(
                const PaginatedResponse<AssignmentModel>(
                  data: <AssignmentModel>[],
                  total: 0,
                  page: 1,
                  limit: 1,
                  totalPages: 1,
                ),
              ),
          submissionsByAssignment:
              const <String, ServiceResult<List<AssignmentSubmissionModel>>>{},
        ),
        labService: _FakeLabService(
          labsResult: ServiceResult<List<LabModel>>.success(const <LabModel>[]),
        ),
      );

      bloc.add(const LoadTeachingCourses());
      await _flush();
      await _flush();

      expect(bloc.state, isA<InstructorCoursesError>());
      expect((bloc.state as InstructorCoursesError).message, 'network down');

      await bloc.close();
    });

    test('loads upcoming deadlines from assignments and labs', () async {
      final now = DateTime.now();
      final bloc = InstructorCoursesBloc(
        enrollmentService: _FakeEnrollmentService(
          coursesResult: ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse()],
          ),
          studentsResult: ServiceResult<List<SectionStudentModel>>.success(
            const <SectionStudentModel>[],
          ),
        ),
        assignmentService: _FakeAssignmentService(
          assignmentsResult:
              ServiceResult<PaginatedResponse<AssignmentModel>>.success(
                PaginatedResponse<AssignmentModel>(
                  data: <AssignmentModel>[
                    _assignment(
                      id: '1',
                      dueDate: now.add(const Duration(days: 1)),
                    ),
                    _assignment(
                      id: '2',
                      dueDate: now.subtract(const Duration(days: 1)),
                    ),
                  ],
                  total: 2,
                  page: 1,
                  limit: 20,
                  totalPages: 1,
                ),
              ),
          submissionsByAssignment:
              const <String, ServiceResult<List<AssignmentSubmissionModel>>>{},
        ),
        labService: _FakeLabService(
          labsResult: ServiceResult<List<LabModel>>.success(<LabModel>[
            _lab(id: '9', dueDate: now.add(const Duration(days: 2))),
          ]),
        ),
      );

      bloc.add(const LoadTeachingCourses());
      await _flush();
      await _flush();

      bloc.add(const LoadDeadlines(56));
      await _flush();
      await _flush();
      await _flush();

      expect(bloc.state, isA<InstructorCoursesLoaded>());
      final loaded = bloc.state as InstructorCoursesLoaded;
      expect(loaded.deadlines.length, 2);
      expect(
        loaded.deadlines.first.dueDate!.isBefore(
          loaded.deadlines.last.dueDate!,
        ),
        isTrue,
      );

      await bloc.close();
    });

    test('loads section students into loaded state', () async {
      final bloc = InstructorCoursesBloc(
        enrollmentService: _FakeEnrollmentService(
          coursesResult: ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse()],
          ),
          studentsResult: ServiceResult<List<SectionStudentModel>>.success(
            const <SectionStudentModel>[
              SectionStudentModel(
                userId: 1,
                status: 'enrolled',
                grade: 90,
                finalScore: 95,
                courseCode: 'CS101',
                courseName: 'Computer Science 101',
              ),
            ],
          ),
        ),
        assignmentService: _FakeAssignmentService(
          assignmentsResult:
              ServiceResult<PaginatedResponse<AssignmentModel>>.success(
                const PaginatedResponse<AssignmentModel>(
                  data: <AssignmentModel>[],
                  total: 0,
                  page: 1,
                  limit: 1,
                  totalPages: 1,
                ),
              ),
          submissionsByAssignment:
              const <String, ServiceResult<List<AssignmentSubmissionModel>>>{},
        ),
        labService: _FakeLabService(
          labsResult: ServiceResult<List<LabModel>>.success(const <LabModel>[]),
        ),
      );

      bloc.add(const LoadTeachingCourses());
      await _flush();
      await _flush();

      bloc.add(const LoadSectionStudents(12));
      await _flush();
      await _flush();

      expect(bloc.state, isA<InstructorCoursesLoaded>());
      final loaded = bloc.state as InstructorCoursesLoaded;
      expect(loaded.selectedSectionId, 12);
      expect(loaded.sectionStudents.length, 1);
      expect(loaded.sectionStudents.first.displayName, 'Student #1');

      await bloc.close();
    });

    test(
      'computes engagement metrics from materials and submissions',
      () async {
        final assignmentOne = _assignment(
          id: '11',
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );
        final assignmentTwo = _assignment(
          id: '12',
          dueDate: DateTime.now().add(const Duration(days: 2)),
        );

        final bloc = InstructorCoursesBloc(
          enrollmentService: _FakeEnrollmentService(
            coursesResult: ServiceResult<List<TeachingCourseModel>>.success(
              <TeachingCourseModel>[_teachingCourse()],
            ),
            studentsResult: ServiceResult<List<SectionStudentModel>>.success(
              const <SectionStudentModel>[],
            ),
          ),
          assignmentService: _FakeAssignmentService(
            assignmentsResult:
                ServiceResult<PaginatedResponse<AssignmentModel>>.success(
                  PaginatedResponse<AssignmentModel>(
                    data: <AssignmentModel>[assignmentOne, assignmentTwo],
                    total: 2,
                    page: 1,
                    limit: 20,
                    totalPages: 1,
                  ),
                ),
            submissionsByAssignment:
                <String, ServiceResult<List<AssignmentSubmissionModel>>>{
                  '11': ServiceResult<List<AssignmentSubmissionModel>>.success(
                    <AssignmentSubmissionModel>[
                      _submission(id: 1, userId: 1, assignmentId: 11),
                      _submission(id: 2, userId: 2, assignmentId: 11),
                    ],
                  ),
                  '12': ServiceResult<List<AssignmentSubmissionModel>>.success(
                    <AssignmentSubmissionModel>[
                      _submission(id: 3, userId: 2, assignmentId: 12),
                      _submission(id: 4, userId: 3, assignmentId: 12),
                    ],
                  ),
                },
          ),
          labService: _FakeLabService(
            labsResult: ServiceResult<List<LabModel>>.success(
              const <LabModel>[],
            ),
          ),
          materialService: _FakeMaterialService(
            materials: <CourseMaterialModel>[
              CourseMaterialModel(
                materialId: 'm1',
                courseId: '56',
                materialType: 'document',
                title: 'Week 1 Handout',
                viewCount: 10,
                downloadCount: 2,
                isPublished: true,
                createdAt: DateTime(2026, 1, 1),
              ),
              CourseMaterialModel(
                materialId: 'm2',
                courseId: '56',
                materialType: 'video',
                title: 'Week 1 Video',
                viewCount: 4,
                downloadCount: 1,
                isPublished: true,
                createdAt: DateTime(2026, 1, 1),
              ),
            ],
          ),
        );

        bloc.add(const LoadTeachingCourses());
        await _flush();
        await _flush();

        bloc.add(
          const LoadEngagementMetrics(courseId: 56, totalEnrolledStudents: 4),
        );
        await _flush();
        await _flush();
        await _flush();

        expect(bloc.state, isA<InstructorCoursesLoaded>());
        final loaded = bloc.state as InstructorCoursesLoaded;
        expect(loaded.engagementMetrics, isNotNull);
        expect(loaded.engagementMetrics!.totalMaterialViews, 14);
        expect(loaded.engagementMetrics!.totalMaterialDownloads, 3);
        expect(loaded.engagementMetrics!.totalSubmissions, 4);
        expect(loaded.engagementMetrics!.assignmentSubmissionRate, 75.0);

        await bloc.close();
      },
    );
  });
}
