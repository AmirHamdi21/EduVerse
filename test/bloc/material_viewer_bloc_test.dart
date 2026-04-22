import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_event.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _FakeMaterialService extends MaterialService {
  _FakeMaterialService({this.shouldThrow = false})
    : super(coreApiClient: CoreApiClient.test());

  final bool shouldThrow;
  int recordViewCalls = 0;

  @override
  Future<void> recordView(dynamic courseId, dynamic materialId) async {
    recordViewCalls += 1;
    if (shouldThrow) {
      throw Exception('record view failed');
    }
  }
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

CourseMaterialModel _videoMaterial() {
  return CourseMaterialModel(
    materialId: 'm1',
    courseId: '7',
    materialType: 'video',
    title: 'Week 1 - Intro Video',
    externalUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    viewCount: 10,
    isPublished: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('MaterialViewerBloc', () {
    test('play video records view and emits loaded state', () async {
      final service = _FakeMaterialService();
      final bloc = MaterialViewerBloc(materialService: service);

      bloc.add(PlayVideo(courseId: 7, material: _videoMaterial()));
      await _flush();
      await _flush();

      expect(service.recordViewCalls, 1);
      expect(bloc.state.currentMaterial, isNotNull);
      expect(bloc.state.currentMaterial!.hasBeenViewed, isTrue);
      expect(bloc.state.currentMaterial!.viewCount, 11);
      expect(bloc.state.isViewRecorded, isTrue);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);

      await bloc.close();
    });

    test('play video surfaces record-view errors', () async {
      final service = _FakeMaterialService(shouldThrow: true);
      final bloc = MaterialViewerBloc(materialService: service);

      bloc.add(PlayVideo(courseId: 7, material: _videoMaterial()));
      await _flush();
      await _flush();

      expect(service.recordViewCalls, 1);
      expect(bloc.state.currentMaterial, isNotNull);
      expect(bloc.state.isViewRecorded, isFalse);
      expect(bloc.state.error, contains('record view failed'));
      expect(bloc.state.isLoading, isFalse);

      await bloc.close();
    });
  });
}
