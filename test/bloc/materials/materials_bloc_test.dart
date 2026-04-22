import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/materials/materials_event.dart';
import 'package:edu_verse/bloc/materials/materials_state.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService({required this.materials})
    : super(coreApiClient: CoreApiClient.test());

  final List<CourseMaterialModel> materials;
  int getMaterialsCalls = 0;
  int? lastWeekNumber;
  String? lastUploadType;
  final List<String> deletedIds = <String>[];
  final List<String> updatedIds = <String>[];
  final Set<String> failDeleteIds = <String>{};
  final Set<String> failUpdateIds = <String>{};
  final Set<String> failUploadPaths = <String>{};
  final Set<String> unauthorizedVideoPaths = <String>{};

  @override
  Future<List<CourseMaterialModel>> getMaterials(
    dynamic courseId, {
    String? materialType,
    int? weekNumber,
    String? search,
  }) async {
    getMaterialsCalls += 1;
    return List<CourseMaterialModel>.from(materials);
  }

  @override
  Future<CourseMaterialModel> uploadDocument(
    dynamic courseId, {
    required File file,
    required String title,
    int? weekNumber,
    bool isPublished = true,
    ProgressCallback? onSendProgress,
  }) async {
    if (failUploadPaths.contains(file.path)) {
      throw Exception('document upload failed');
    }
    lastWeekNumber = weekNumber;
    lastUploadType = 'document';
    final model = CourseMaterialModel(
      materialId: '${materials.length + 1}',
      courseId: courseId.toString(),
      materialType: 'document',
      title: title,
      weekNumber: weekNumber,
      isPublished: isPublished,
      createdAt: DateTime(2026, 1, 1),
    );
    materials.add(model);
    return model;
  }

  @override
  Future<CourseMaterialModel> uploadVideo(
    dynamic courseId, {
    required File file,
    required String title,
    int? weekNumber,
    bool isPublished = true,
    ProgressCallback? onSendProgress,
  }) async {
    if (unauthorizedVideoPaths.contains(file.path)) {
      final request = RequestOptions(
        path: '/courses/$courseId/materials/video',
      );
      throw DioException(
        requestOptions: request,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: 401,
          data: <String, dynamic>{
            'error': 'YouTube not authorized. Please contact admin.',
          },
        ),
        type: DioExceptionType.badResponse,
      );
    }

    if (failUploadPaths.contains(file.path)) {
      throw Exception('video upload failed');
    }
    lastWeekNumber = weekNumber;
    lastUploadType = 'video';
    onSendProgress?.call(100, 100);
    final model = CourseMaterialModel(
      materialId: '${materials.length + 1}',
      courseId: courseId.toString(),
      materialType: 'video',
      title: title,
      weekNumber: weekNumber,
      isPublished: isPublished,
      createdAt: DateTime(2026, 1, 1),
    );
    materials.add(model);
    return model;
  }

  @override
  Future<CourseMaterialModel> uploadTextLink(
    dynamic courseId, {
    required String title,
    required String url,
    required String type,
    int? weekNumber,
    bool isPublished = true,
  }) async {
    lastWeekNumber = weekNumber;
    lastUploadType = 'link';
    final model = CourseMaterialModel(
      materialId: '${materials.length + 1}',
      courseId: courseId.toString(),
      materialType: type,
      title: title,
      externalUrl: url,
      weekNumber: weekNumber,
      isPublished: isPublished,
      createdAt: DateTime(2026, 1, 1),
    );
    materials.add(model);
    return model;
  }

  @override
  Future<CourseMaterialModel> updateMaterialDetails(
    dynamic courseId,
    dynamic materialId,
    Map<String, dynamic> body,
  ) async {
    final id = materialId.toString();
    updatedIds.add(id);
    if (failUpdateIds.contains(id)) {
      throw Exception('update failed');
    }

    return CourseMaterialModel(
      materialId: id,
      courseId: courseId.toString(),
      materialType: body['type']?.toString() ?? 'document',
      title: body['title']?.toString() ?? 'Updated',
      isPublished: true,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<void> deleteMaterial(dynamic courseId, dynamic materialId) async {
    final id = materialId.toString();
    if (failDeleteIds.contains(id)) {
      throw Exception('delete failed');
    }
    deletedIds.add(id);
  }

  @override
  Future<CourseMaterialModel> toggleVisibility(
    dynamic courseId,
    dynamic materialId, {
    required bool isPublished,
  }) async {
    return CourseMaterialModel(
      materialId: materialId.toString(),
      courseId: courseId.toString(),
      materialType: 'document',
      title: 'Visibility Toggle',
      isPublished: isPublished,
      createdAt: DateTime(2026, 1, 1),
    );
  }
}

CourseMaterialModel _material({
  required String id,
  required String title,
  required String type,
  int? week,
}) {
  return CourseMaterialModel(
    materialId: id,
    courseId: '1',
    materialType: type,
    title: title,
    weekNumber: week,
    isPublished: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('MaterialsBloc', () {
    test('loads materials and grouped bundles', () async {
      final service = _FakeMaterialService(
        materials: <CourseMaterialModel>[
          _material(id: '1', title: 'Week 1 - Video', type: 'video', week: 1),
          _material(
            id: '2',
            title: 'Week 1 - Slides',
            type: 'document',
            week: 1,
          ),
        ],
      );
      final bloc = MaterialsBloc(materialService: service);

      bloc.add(const LoadMaterials(1));
      await _flush();
      await _flush();

      expect(bloc.state, isA<MaterialsLoaded>());
      final state = bloc.state as MaterialsLoaded;
      expect(state.materials.length, 2);
      expect(state.bundles.length, 1);
      expect(service.getMaterialsCalls, 1);

      await bloc.close();
    });

    test(
      'uploads document with week number then refreshes materials',
      () async {
        final service = _FakeMaterialService(
          materials: <CourseMaterialModel>[],
        );
        final bloc = MaterialsBloc(materialService: service);

        bloc.add(
          const UploadMaterial(
            courseId: 1,
            uploadId: 'upload-1',
            title: 'Lecture Notes',
            materialType: 'document',
            filePath: 'C:/tmp/lecture.pdf',
            weekNumber: 5,
          ),
        );
        await _flush();
        await _flush();
        await _flush();

        expect(service.lastUploadType, 'document');
        expect(service.lastWeekNumber, 5);
        expect(bloc.state, isA<MaterialsLoaded>());

        await bloc.close();
      },
    );

    test('toggle visibility triggers refresh-after-operation', () async {
      final service = _FakeMaterialService(
        materials: <CourseMaterialModel>[
          _material(id: '3', title: 'Doc', type: 'document'),
        ],
      );
      final bloc = MaterialsBloc(materialService: service);

      bloc.add(
        const ToggleMaterialVisibility(
          courseId: 1,
          materialId: '3',
          isPublished: false,
        ),
      );
      await _flush();
      await _flush();
      await _flush();

      expect(service.getMaterialsCalls, greaterThanOrEqualTo(1));
      expect(bloc.state, isA<MaterialsLoaded>());

      await bloc.close();
    });

    test(
      'delete emits partial failure and keeps failed ids for retry',
      () async {
        final service = _FakeMaterialService(
          materials: <CourseMaterialModel>[
            _material(id: '1', title: 'Doc 1', type: 'document'),
            _material(id: '2', title: 'Doc 2', type: 'document'),
          ],
        );
        service.failDeleteIds.add('2');
        final bloc = MaterialsBloc(materialService: service);
        final emitted = <MaterialsState>[];
        final sub = bloc.stream.listen(emitted.add);

        bloc.add(
          const DeleteMaterial(courseId: 1, materialIds: <String>['1', '2']),
        );
        await _flush();
        await _flush();
        await _flush();

        final errorState = emitted.whereType<MaterialsError>().first;
        expect(errorState.failedMaterialIds, <String>['2']);
        expect(errorState.message, contains('retry?'));
        expect(bloc.state, isA<MaterialsLoaded>());

        await sub.cancel();
        await bloc.close();
      },
    );

    test('bundle upload reports failed files when some items fail', () async {
      final service = _FakeMaterialService(materials: <CourseMaterialModel>[]);
      service.failUploadPaths.add('C:/tmp/notes.pdf');
      final bloc = MaterialsBloc(materialService: service);
      final emitted = <MaterialsState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(
        const UploadMaterial(
          courseId: 1,
          uploadId: 'bundle-1',
          title: 'Week 6 Bundle',
          materialType: 'bundle',
          weekNumber: 6,
          bundleVideoPath: 'C:/tmp/lecture.mp4',
          bundleDocumentPaths: <String>['C:/tmp/notes.pdf'],
        ),
      );
      await _flush();
      await _flush();
      await _flush();

      final errorState = emitted.whereType<MaterialsError>().first;
      expect(errorState.message, contains('failed'));
      expect(bloc.state, isA<MaterialsLoaded>());

      await sub.cancel();
      await bloc.close();
    });

    test(
      'bundle-level update tracks partial failures then refreshes',
      () async {
        final service = _FakeMaterialService(
          materials: <CourseMaterialModel>[
            _material(
              id: '11',
              title: 'Week 3 - Video',
              type: 'video',
              week: 3,
            ),
            _material(
              id: '12',
              title: 'Week 3 - Slides',
              type: 'document',
              week: 3,
            ),
          ],
        );
        service.failUpdateIds.add('12');
        final bloc = MaterialsBloc(materialService: service);
        final emitted = <MaterialsState>[];
        final sub = bloc.stream.listen(emitted.add);

        bloc.add(
          const UpdateMaterial(
            courseId: 1,
            materialId: '11',
            materialIds: <String>['11', '12'],
            payload: <String, dynamic>{'title': 'Week 3 Bundle'},
          ),
        );

        await _flush();
        await _flush();
        await _flush();

        final errorState = emitted.whereType<MaterialsError>().first;
        expect(errorState.failedMaterialIds, const <String>['12']);
        expect(errorState.message, contains('materials updated'));
        expect(service.updatedIds, containsAll(const <String>['11', '12']));
        expect(bloc.state, isA<MaterialsLoaded>());

        await sub.cancel();
        await bloc.close();
      },
    );

    test('video upload emits YouTube authorization message on 401', () async {
      final service = _FakeMaterialService(materials: <CourseMaterialModel>[]);
      service.unauthorizedVideoPaths.add('C:/tmp/yt.mp4');
      final bloc = MaterialsBloc(materialService: service);
      final emitted = <MaterialsState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(
        const UploadMaterial(
          courseId: 1,
          uploadId: 'yt-1',
          title: 'Week 7 Video',
          materialType: 'video',
          filePath: 'C:/tmp/yt.mp4',
          weekNumber: 7,
        ),
      );

      await _flush();
      await _flush();
      await _flush();

      final errorState = emitted.whereType<MaterialsError>().last;
      expect(errorState.message, 'YouTube not authorized. Contact admin.');
      expect(bloc.state, isA<MaterialsError>());

      await sub.cancel();
      await bloc.close();
    });
  });
}
