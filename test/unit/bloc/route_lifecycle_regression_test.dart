import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/bloc/attendance/instructor_attendance_cubit.dart';
import 'package:edu_verse/bloc/instructor/instructor_assignments_cubit.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/attendance_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _DelayedEnrollmentService extends EnrollmentService {
  _DelayedEnrollmentService({required this.courses})
    : super(coreApiClient: CoreApiClient.test());

  final List<TeachingCourseModel> courses;
  static const Duration _delay = Duration(milliseconds: 50);

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses({
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(_delay);
    return ServiceResult<List<TeachingCourseModel>>.success(courses);
  }
}

class _DelayedAssignmentService extends AssignmentService {
  _DelayedAssignmentService() : super(coreApiClient: CoreApiClient.test());

  static const Duration _delay = Duration(milliseconds: 50);

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
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(_delay);
    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      PaginatedResponse<AssignmentModel>(
        data: <AssignmentModel>[_assignment()],
        total: 1,
        page: page ?? 1,
        limit: limit ?? 20,
        totalPages: 1,
      ),
    );
  }
}

class _DelayedAttendanceService extends AttendanceService {
  _DelayedAttendanceService() : super(coreApiClient: CoreApiClient.test());
}

class _DelayedCourseService extends CourseService {
  _DelayedCourseService() : super(coreApiClient: CoreApiClient.test());

  static const Duration _delay = Duration(milliseconds: 50);

  @override
  Future<List<CourseStructureModel>> getCourseStructure(
    dynamic courseId, {
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(_delay);
    return <CourseStructureModel>[
      const CourseStructureModel(
        organizationId: 1,
        courseId: '7',
        organizationType: 'lecture',
        title: 'Week 1',
        weekNumber: 1,
        orderIndex: 1,
      ),
    ];
  }
}

class _DelayedMaterialService extends MaterialService {
  _DelayedMaterialService() : super(coreApiClient: CoreApiClient.test());

  static const Duration _delay = Duration(milliseconds: 50);

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(_delay);
    return <CourseMaterialModel>[
      CourseMaterialModel(
        materialId: 'm1',
        courseId: courseId.toString(),
        materialType: materialType ?? 'video',
        title: 'Intro Video',
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 1,
    'userId': 3,
    'courseId': 7,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': 7,
      'departmentId': 1,
      'code': 'CS507',
      'name': 'Lifecycle Testing',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 1,
      'courseId': 7,
      'semesterId': 1,
      'sectionNumber': 'A',
      'maxCapacity': 25,
      'currentEnrollment': 20,
      'status': 'active',
    },
    'semester': <String, dynamic>{
      'id': 1,
      'name': 'Spring 2026',
      'term': 'spring',
      'year': 2026,
    },
  });
}

AssignmentModel _assignment() {
  return AssignmentModel(
    id: '11',
    assignmentId: 11,
    courseId: 7,
    title: 'Async Safety',
    description: 'Lifecycle regression',
    courseName: 'Lifecycle Testing',
    courseCode: 'CS507',
    instructorName: 'Test Instructor',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime(2026, 6, 1),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: api.AssignmentStatus.published,
    submissionType: api.SubmissionType.file,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 20,
  );
}

void main() {
  test(
    'InstructorAssignmentsCubit ignores delayed responses after close',
    () async {
      final cubit = InstructorAssignmentsCubit(
        assignmentService: _DelayedAssignmentService(),
        enrollmentService: _DelayedEnrollmentService(
          courses: <TeachingCourseModel>[_teachingCourse()],
        ),
      );

      final future = cubit.loadTeachingCourses();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await cubit.close();

      await expectLater(future, completes);
    },
  );

  test(
    'InstructorAttendanceCubit ignores delayed section load after close',
    () async {
      final cubit = InstructorAttendanceCubit(
        attendanceService: _DelayedAttendanceService(),
        enrollmentService: _DelayedEnrollmentService(
          courses: <TeachingCourseModel>[_teachingCourse()],
        ),
      );

      final future = cubit.loadTeachingSections();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await cubit.close();

      await expectLater(future, completes);
    },
  );

  test('CourseDetailBloc ignores delayed load responses after close', () async {
    final bloc = CourseDetailBloc(
      courseService: _DelayedCourseService(),
      materialService: _DelayedMaterialService(),
    );

    bloc.add(
      const LoadCourseDetail(courseId: 7, sectionId: 1, initialTabIndex: 0),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));
    await bloc.close();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(bloc.isClosed, isTrue);
  });
}
