import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import 'package:edu_verse/features/courses/bloc/material_viewer/material_viewer_event.dart';
import 'package:edu_verse/models/materials/course_material_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/material_service.dart';

class _NoopMaterialService extends MaterialService {
  _NoopMaterialService() : super(coreApiClient: CoreApiClient.test());
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  test('download flow transitions to complete and file exists', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final tempDir = await Directory.systemTemp.createTemp('eduverse_download');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final material = CourseMaterialModel(
      materialId: 'doc-1',
      courseId: '5',
      materialType: 'document',
      title: 'Lab Sheet',
      isPublished: true,
      createdAt: DateTime(2026, 1, 1),
      file: const DriveFileModel(
        driveId: 'drive-doc-1',
        fileName: 'lab_sheet.pdf',
        downloadUrl: 'https://example.com/lab_sheet.pdf',
        mimeType: 'application/pdf',
        fileSize: 2048,
      ),
    );

    final bloc = MaterialViewerBloc(
      materialService: _NoopMaterialService(),
      downloadExecutor: ({required material, required onProgress}) async {
        onProgress(0.25);
        onProgress(0.75);
        final filePath =
            '${tempDir.path}${Platform.pathSeparator}lab_sheet.pdf';
        await File(filePath).writeAsString('pdf-bytes');
        onProgress(1.0);
        return filePath;
      },
    );

    bloc.add(DownloadMaterial(courseId: 5, material: material));

    for (var i = 0; i < 80; i++) {
      await _flush();
      if (bloc.state.downloadedFilePath != null || bloc.state.error != null) {
        break;
      }
    }

    expect(bloc.state.error, isNull);
    expect(bloc.state.isDownloading, isFalse);
    expect(bloc.state.downloadProgress, 1.0);
    expect(bloc.state.downloadedFilePath, isNotNull);
    expect(await File(bloc.state.downloadedFilePath!).exists(), isTrue);

    await bloc.close();
  });
}
