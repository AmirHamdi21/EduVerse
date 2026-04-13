import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_bloc.dart';
import 'package:edu_verse/bloc/course_structure/course_structure_event.dart';
import 'package:edu_verse/bloc/course_structure/course_structure_state.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_event.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_event.dart';
import 'package:edu_verse/bloc/materials/materials_state.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart'
    as assignment_api;
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/core/paginated_response.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart'
    hide AssignmentModel;
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/models/labs/lab_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _FakeEnrollmentService extends EnrollmentService {
  _FakeEnrollmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses() async {
    return ServiceResult<List<TeachingCourseModel>>.success(
      <TeachingCourseModel>[_teachingCourse()],
    );
  }

  @override
  Future<ServiceResult<List<SectionStudentModel>>> getSectionStudentsLite(
    dynamic sectionId,
  ) async {
    return ServiceResult<List<SectionStudentModel>>.success(
      const <SectionStudentModel>[
        SectionStudentModel(
          userId: 5,
          firstName: 'Lina',
          lastName: 'Hassan',
          email: 'lina@example.com',
          enrollmentStatus: 'enrolled',
        ),
      ],
    );
  }
}

class _FakeAssignmentService extends AssignmentService {
  _FakeAssignmentService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<PaginatedResponse<AssignmentModel>>> getAll({
    int? courseId,
    int? sectionId,
    assignment_api.AssignmentStatus? status,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    return ServiceResult<PaginatedResponse<AssignmentModel>>.success(
      const PaginatedResponse<AssignmentModel>(
        data: <AssignmentModel>[],
        total: 0,
        page: 1,
        limit: 20,
        totalPages: 1,
      ),
    );
  }
}

class _FakeLabService extends LabService {
  _FakeLabService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<ServiceResult<List<LabModel>>> getAll({int? courseId}) async {
    return ServiceResult<List<LabModel>>.success(const <LabModel>[]);
  }
}

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService({
    List<CourseMaterialModel>? materials,
    this.failOnGetMaterials = false,
    this.failOnToggleVisibility = false,
  }) : _materials = List<CourseMaterialModel>.from(
         materials ?? _defaultMaterials(),
       ),
       super(coreApiClient: CoreApiClient.test());

  final List<CourseMaterialModel> _materials;
  final bool failOnGetMaterials;
  final bool failOnToggleVisibility;

  static List<CourseMaterialModel> _defaultMaterials() {
    return <CourseMaterialModel>[
      CourseMaterialModel(
        materialId: '1',
        courseId: '56',
        materialType: 'video',
        title: 'Week 1 - Intro - Video',
        weekNumber: 1,
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      ),
      CourseMaterialModel(
        materialId: '2',
        courseId: '56',
        materialType: 'document',
        title: 'Week 1 - Intro - Slides',
        weekNumber: 1,
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      ),
      CourseMaterialModel(
        materialId: '3',
        courseId: '56',
        materialType: 'link',
        title: 'Week 2 Reading',
        weekNumber: 2,
        isPublished: true,
        createdAt: DateTime(2026, 1, 2),
      ),
    ];
  }

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    if (failOnGetMaterials) {
      throw Exception('materials unavailable');
    }

    return List<CourseMaterialModel>.from(_materials);
  }

  @override
  Future<CourseMaterialModel> toggleVisibility(
    dynamic courseId,
    dynamic materialId, {
    required bool isPublished,
  }) async {
    if (failOnToggleVisibility) {
      throw Exception('toggle failed');
    }

    final index = _materials.indexWhere(
      (material) => material.materialId == materialId.toString(),
    );
    if (index < 0) {
      throw Exception('material not found');
    }

    final updated = _materials[index].copyWith(isPublished: isPublished);
    _materials[index] = updated;
    return updated;
  }
}

class _FakeCourseService extends CourseService {
  _FakeCourseService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseStructureModel>> getStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    return const <CourseStructureModel>[
      CourseStructureModel(
        organizationId: 1,
        courseId: '56',
        organizationType: 'lecture',
        title: 'Week 1 Intro',
        weekNumber: 1,
        orderIndex: 1,
      ),
      CourseStructureModel(
        organizationId: 2,
        courseId: '56',
        organizationType: 'lecture',
        title: 'Week 2 Trees',
        weekNumber: 2,
        orderIndex: 2,
      ),
    ];
  }
}

TeachingCourseModel _teachingCourse() {
  return TeachingCourseModel.fromJson(<String, dynamic>{
    'sectionId': 11,
    'userId': 7,
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
      'id': 11,
      'courseId': 56,
      'semesterId': 1,
      'sectionNumber': 'A',
      'maxCapacity': 30,
      'currentEnrollment': 22,
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

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < timeout) {
    await _flush();
    if (condition()) {
      return;
    }
  }

  throw TestFailure(
    'Timed out waiting for condition after ${timeout.inMilliseconds}ms',
  );
}

void main() {
  test(
    'phase5 core flow loads instructor courses, materials bundles, structure',
    () async {
      final materialService = _FakeMaterialService();

      final instructorBloc = InstructorCoursesBloc(
        enrollmentService: _FakeEnrollmentService(),
        assignmentService: _FakeAssignmentService(),
        labService: _FakeLabService(),
        materialService: materialService,
      );
      final materialsBloc = MaterialsBloc(materialService: materialService);
      final structureBloc = CourseStructureBloc(
        courseService: _FakeCourseService(),
      );

      instructorBloc.add(const LoadTeachingCourses());
      materialsBloc.add(const LoadMaterials(56));
      structureBloc.add(const LoadStructure(56));

      await _waitUntil(
        () =>
            instructorBloc.state is InstructorCoursesLoaded &&
            materialsBloc.state is MaterialsLoaded &&
            structureBloc.state is StructureLoaded,
      );

      expect(instructorBloc.state, isA<InstructorCoursesLoaded>());
      expect(materialsBloc.state, isA<MaterialsLoaded>());
      expect(structureBloc.state, isA<StructureLoaded>());

      final materialsState = materialsBloc.state as MaterialsLoaded;
      expect(materialsState.materials.length, 3);
      expect(materialsState.bundles.length, 2);
      expect(
        materialsState.bundles.any(
          (bundle) =>
              bundle.baseTitle.contains('Week 1') && bundle.totalMaterials == 2,
        ),
        isTrue,
      );

      final structureState = structureBloc.state as StructureLoaded;
      expect(structureState.items.length, 2);

      await instructorBloc.close();
      await materialsBloc.close();
      await structureBloc.close();
    },
  );

  test('phase5 visibility toggle reflects within 1 second', () async {
    final materialService = _FakeMaterialService();
    final materialsBloc = MaterialsBloc(materialService: materialService);

    materialsBloc.add(const LoadMaterials(56));
    await _waitUntil(() => materialsBloc.state is MaterialsLoaded);

    final stopwatch = Stopwatch()..start();
    materialsBloc.add(
      const ToggleMaterialVisibility(
        courseId: 56,
        materialId: '1',
        isPublished: false,
      ),
    );

    await _waitUntil(() {
      final state = materialsBloc.state;
      if (state is! MaterialsLoaded) {
        return false;
      }

      return state.materials.any(
        (material) =>
            material.materialId == '1' && material.isPublished == false,
      );
    });
    stopwatch.stop();

    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));

    await materialsBloc.close();
  });

  test(
    'phase5 mid-flow toggle failure emits error while other blocs stay loaded',
    () async {
      final materialService = _FakeMaterialService(
        failOnToggleVisibility: true,
      );

      final instructorBloc = InstructorCoursesBloc(
        enrollmentService: _FakeEnrollmentService(),
        assignmentService: _FakeAssignmentService(),
        labService: _FakeLabService(),
        materialService: materialService,
      );
      final materialsBloc = MaterialsBloc(materialService: materialService);
      final structureBloc = CourseStructureBloc(
        courseService: _FakeCourseService(),
      );

      instructorBloc.add(const LoadTeachingCourses());
      materialsBloc.add(const LoadMaterials(56));
      structureBloc.add(const LoadStructure(56));

      await _waitUntil(
        () =>
            instructorBloc.state is InstructorCoursesLoaded &&
            materialsBloc.state is MaterialsLoaded &&
            structureBloc.state is StructureLoaded,
      );

      materialsBloc.add(
        const ToggleMaterialVisibility(
          courseId: 56,
          materialId: '1',
          isPublished: false,
        ),
      );

      await _waitUntil(() => materialsBloc.state is MaterialsError);

      expect(instructorBloc.state, isA<InstructorCoursesLoaded>());
      expect(structureBloc.state, isA<StructureLoaded>());
      final errorState = materialsBloc.state as MaterialsError;
      expect(errorState.message, contains('toggle failed'));

      await instructorBloc.close();
      await materialsBloc.close();
      await structureBloc.close();
    },
  );
}
