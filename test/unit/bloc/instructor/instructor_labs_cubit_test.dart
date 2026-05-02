import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/instructor/instructor_labs_cubit.dart';
import 'package:edu_verse/bloc/instructor/instructor_labs_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/core/enums/lab_enums.dart' as api;
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/core/shared_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService(this.result)
    : super(coreApiClient: CoreApiClient.test());

  ServiceResult<List<TeachingCourseModel>> result;

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses({
    CancelToken? cancelToken,
  }) async {
    return result;
  }
}

class _FakeLabService extends LabService {
  _FakeLabService({required this.page1Result})
    : super(coreApiClient: CoreApiClient.test());

  ServiceResult<PaginatedResponse<LabModel>> page1Result;
  ServiceResult<PaginatedResponse<LabModel>>? page2Result;

  ServiceResult<LabModel>? createResult;
  ServiceResult<LabModel>? updateResult;
  ServiceResult<void>? deleteResult;

  int? lastCourseId;
  int? lastPage;

  Map<String, dynamic>? lastCreatePayload;
  dynamic lastUpdateId;
  Map<String, dynamic>? lastUpdatePayload;
  dynamic lastDeleteId;

  @override
  Future<ServiceResult<PaginatedResponse<LabModel>>> getAllPaginated({
    int? courseId,
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
    CancelToken? cancelToken,
  }) async {
    lastCourseId = courseId;
    lastPage = page;

    if (page == 2 && page2Result != null) {
      return page2Result!;
    }

    return page1Result;
  }

  @override
  Future<ServiceResult<LabModel>> create(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    lastCreatePayload = data;
    return createResult ??
        ServiceResult<LabModel>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'create failed',
          ),
        );
  }

  @override
  Future<ServiceResult<LabModel>> update(
    dynamic id,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    lastUpdateId = id;
    lastUpdatePayload = data;
    return updateResult ??
        ServiceResult<LabModel>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'update failed',
          ),
        );
  }

  @override
  Future<ServiceResult<void>> delete(
    dynamic id, {
    CancelToken? cancelToken,
  }) async {
    lastDeleteId = id;
    return deleteResult ??
        ServiceResult<void>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'delete failed',
          ),
        );
  }
}

TeachingCourseModel _teachingCourse({required int courseId}) {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 12,
    'userId': 2,
    'courseId': courseId,
    'role': 'instructor',
    'course': <String, dynamic>{
      'id': courseId,
      'departmentId': 1,
      'code': 'CS$courseId',
      'name': 'Course $courseId',
      'credits': 3,
      'level': 'senior',
      'status': 'active',
    },
    'section': <String, dynamic>{
      'id': 12,
      'courseId': courseId,
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

LabModel _lab({
  required int id,
  required int courseId,
  required String title,
  api.LabStatus status = api.LabStatus.draft,
}) {
  return LabModel(
    id: id.toString(),
    labId: id,
    courseId: courseId,
    title: title,
    description: 'Description for $title',
    dueDate: DateTime(2026, 6, 1),
    maxScore: 100,
    status: status,
    course: CourseInfo(
      id: courseId,
      name: 'Course $courseId',
      code: 'CS$courseId',
    ),
  );
}

void main() {
  group('InstructorLabsCubit', () {
    test('loadLabs emits loading then loaded state', () async {
      final fakeLabService = _FakeLabService(
        page1Result: ServiceResult<PaginatedResponse<LabModel>>.success(
          PaginatedResponse<LabModel>(
            data: <LabModel>[
              _lab(id: 1, courseId: 10, title: 'Lab A'),
              _lab(id: 2, courseId: 10, title: 'Lab B'),
            ],
            total: 2,
            page: 1,
            limit: 50,
            totalPages: 1,
          ),
        ),
      );

      final cubit = InstructorLabsCubit(
        labService: fakeLabService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse(courseId: 10)],
          ),
        ),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<dynamic>[
          isA<InstructorLabsLoading>(),
          isA<InstructorLabsLoaded>(),
        ]),
      );

      await cubit.loadLabs(courseId: '10');
      await expectation;

      final state = cubit.state as InstructorLabsLoaded;
      expect(state.labs.length, 2);
      expect(state.filteredLabs.length, 2);
      expect(state.currentPage, 1);
      expect(state.hasMorePages, isFalse);
      expect(fakeLabService.lastCourseId, 10);

      await cubit.close();
    });

    test('loadLabs emits error state when API fails', () async {
      final fakeLabService = _FakeLabService(
        page1Result: ServiceResult<PaginatedResponse<LabModel>>.failure(
          const ServiceError(
            type: ServiceErrorType.server,
            message: 'Failed to load labs',
          ),
        ),
      );

      final cubit = InstructorLabsCubit(
        labService: fakeLabService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse(courseId: 10)],
          ),
        ),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<dynamic>[
          isA<InstructorLabsLoading>(),
          isA<InstructorLabsError>(),
        ]),
      );

      await cubit.loadLabs(courseId: '10');
      await expectation;

      final state = cubit.state as InstructorLabsError;
      expect(state.message, 'Failed to load labs');

      await cubit.close();
    });

    test('filterLabs applies search and status filters', () async {
      final fakeLabService = _FakeLabService(
        page1Result: ServiceResult<PaginatedResponse<LabModel>>.success(
          PaginatedResponse<LabModel>(
            data: <LabModel>[
              _lab(
                id: 1,
                courseId: 10,
                title: 'Chemistry Basics',
                status: api.LabStatus.published,
              ),
              _lab(
                id: 2,
                courseId: 10,
                title: 'Physics Draft',
                status: api.LabStatus.draft,
              ),
              _lab(
                id: 3,
                courseId: 10,
                title: 'Archived Lab',
                status: api.LabStatus.archived,
              ),
            ],
            total: 3,
            page: 1,
            limit: 50,
            totalPages: 1,
          ),
        ),
      );

      final cubit = InstructorLabsCubit(
        labService: fakeLabService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse(courseId: 10)],
          ),
        ),
      );

      await cubit.loadLabs(courseId: '10');
      cubit.filterLabs(searchQuery: 'chem', status: 'published');

      final state = cubit.state as InstructorLabsLoaded;
      expect(state.searchQuery, 'chem');
      expect(state.selectedStatus, 'published');
      expect(state.filteredLabs.length, 1);
      expect(state.filteredLabs.first.title, 'Chemistry Basics');

      await cubit.close();
    });

    test('clearFilters resets search and status filters', () async {
      final fakeLabService = _FakeLabService(
        page1Result: ServiceResult<PaginatedResponse<LabModel>>.success(
          PaginatedResponse<LabModel>(
            data: <LabModel>[
              _lab(
                id: 1,
                courseId: 10,
                title: 'Chemistry Basics',
                status: api.LabStatus.published,
              ),
              _lab(
                id: 2,
                courseId: 10,
                title: 'Physics Draft',
                status: api.LabStatus.draft,
              ),
            ],
            total: 2,
            page: 1,
            limit: 50,
            totalPages: 1,
          ),
        ),
      );

      final cubit = InstructorLabsCubit(
        labService: fakeLabService,
        enrollmentService: _FakeEnrollmentService(
          ServiceResult<List<TeachingCourseModel>>.success(
            <TeachingCourseModel>[_teachingCourse(courseId: 10)],
          ),
        ),
      );

      await cubit.loadLabs(courseId: '10');
      cubit.filterLabs(searchQuery: 'chem', status: 'published');
      cubit.clearFilters();

      final state = cubit.state as InstructorLabsLoaded;
      expect(state.searchQuery, '');
      expect(state.selectedStatus, 'all');
      expect(state.filteredLabs.length, state.labs.length);

      await cubit.close();
    });
  });
}
