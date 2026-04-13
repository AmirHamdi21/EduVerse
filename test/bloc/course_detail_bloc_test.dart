import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_bloc.dart';
import 'package:edu_verse/features/courses/bloc/course_detail/course_detail_event.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _FakeCourseService extends CourseService {
  final List<CourseStructureModel> structure;
  final bool throwsError;

  _FakeCourseService({required this.structure, this.throwsError = false})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseStructureModel>> getCourseStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    if (throwsError) {
      throw Exception('structure failed');
    }
    return structure;
  }
}

class _FakeMaterialService extends MaterialService {
  final List<CourseMaterialModel> materials;
  final bool throwsError;

  _FakeMaterialService({required this.materials, this.throwsError = false})
    : super(coreApiClient: CoreApiClient.test());

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    if (throwsError) {
      throw Exception('materials failed');
    }

    if (weekNumber == null) {
      return materials;
    }

    return materials.where((m) => m.weekNumber == weekNumber).toList();
  }
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('CourseDetailBloc', () {
    test('loads structure and materials and computes bundles', () async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(
          structure: <CourseStructureModel>[
            CourseStructureModel(
              organizationId: 1,
              courseId: '1',
              materialId: 'm1',
              organizationType: 'video',
              title: 'Week 1 - Intro Video',
              weekNumber: 1,
              orderIndex: 0,
            ),
            CourseStructureModel(
              organizationId: 2,
              courseId: '1',
              materialId: 'm2',
              organizationType: 'document',
              title: 'Week 1 - Intro Slides',
              weekNumber: 1,
              orderIndex: 1,
            ),
          ],
        ),
        materialService: _FakeMaterialService(
          materials: <CourseMaterialModel>[
            CourseMaterialModel(
              materialId: 'm1',
              courseId: '1',
              materialType: 'video',
              title: 'Week 1 - Intro Video',
              weekNumber: 1,
              isPublished: true,
              createdAt: DateTime(2026, 1, 1),
            ),
            CourseMaterialModel(
              materialId: 'm2',
              courseId: '1',
              materialType: 'document',
              title: 'Week 1 - Intro Slides',
              weekNumber: 1,
              isPublished: true,
              createdAt: DateTime(2026, 1, 1),
            ),
          ],
        ),
      );

      bloc.add(const LoadCourseDetail(courseId: 1, initialTabIndex: 2));
      await _flush();
      await _flush();

      expect(bloc.state.selectedTabIndex, 2);
      expect(bloc.state.structure.length, 2);
      expect(bloc.state.materials.length, 2);
      expect(bloc.state.bundles.length, 1);
      expect(bloc.state.error, isNull);

      await bloc.close();
    });

    test('expand week and switch tab update state', () async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(
          structure: const <CourseStructureModel>[],
        ),
        materialService: _FakeMaterialService(
          materials: const <CourseMaterialModel>[],
        ),
      );

      bloc.add(const ExpandWeek(weekIndex: 3));
      await _flush();
      expect(bloc.state.selectedWeekIndex, 3);

      bloc.add(const SwitchTab(tabIndex: 1));
      await _flush();
      expect(bloc.state.selectedTabIndex, 1);

      await bloc.close();
    });

    test('error from service is surfaced in state', () async {
      final bloc = CourseDetailBloc(
        courseService: _FakeCourseService(
          structure: const <CourseStructureModel>[],
          throwsError: true,
        ),
        materialService: _FakeMaterialService(
          materials: const <CourseMaterialModel>[],
          throwsError: true,
        ),
      );

      bloc.add(const LoadCourseDetail(courseId: 7));
      await _flush();
      await _flush();

      expect(bloc.state.error, isNotNull);
      expect(bloc.state.isLoadingStructure, isFalse);
      expect(bloc.state.isLoadingMaterials, isFalse);

      await bloc.close();
    });
  });
}
