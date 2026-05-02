import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
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
    'VideoPlayerWidget shows unavailable state when embedded player is disabled',
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
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

      expect(find.byIcon(Icons.ondemand_video_rounded), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
