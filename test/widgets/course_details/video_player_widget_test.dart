import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/widgets/student/course_details/video_player_widget.dart';

class _NoopMaterialService extends MaterialService {
  _NoopMaterialService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<void> recordView(dynamic courseId, dynamic materialId) async {}
}

void main() {
  testWidgets(
    'VideoPlayerWidget shows player container and controls',
    (tester) async {
      final material = CourseMaterialModel(
        materialId: '101',
        courseId: '5',
        materialType: 'video',
        title: 'Intro Lecture',
        externalUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) =>
                MaterialViewerBloc(materialService: _NoopMaterialService()),
            child: Scaffold(
              body: VideoPlayerWidget(
                courseId: 5,
                material: material,
                enableEmbeddedPlayer: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Intro Lecture'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
