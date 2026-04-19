import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/widgets/student/course_details/document_preview_widget.dart';

class _NoopMaterialService extends MaterialService {
  _NoopMaterialService() : super(coreApiClient: CoreApiClient.test());

  @override
  Future<void> recordView(dynamic courseId, dynamic materialId) async {}
}

void main() {
  testWidgets(
    'DocumentPreviewWidget shows preview with download action',
    (tester) async {
      final material = CourseMaterialModel(
        materialId: '201',
        courseId: '5',
        materialType: 'document',
        title: 'Week 1 Slides',
        isPublished: true,
        createdAt: DateTime(2026, 1, 1),
        file: const DriveFileModel(
          driveId: 'drive-file-1',
          fileName: 'week1_slides.pdf',
          mimeType: 'application/pdf',
          fileSize: 1024,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) =>
                MaterialViewerBloc(materialService: _NoopMaterialService()),
            child: Scaffold(
              body: DocumentPreviewWidget(
                courseId: 5,
                material: material,
                enableWebView: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Week 1 Slides'), findsOneWidget);
      expect(
        find.textContaining('drive.google.com/file/d/drive-file-1/preview'),
        findsOneWidget,
      );
      expect(find.text('Download for offline'), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
