import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/materials/course_material_model.dart';
import '../../../../services/api/material_service.dart';
import 'material_viewer_event.dart';
import 'material_viewer_state.dart';

typedef MaterialDownloadExecutor =
    Future<String> Function({
      required CourseMaterialModel material,
      required void Function(double progress) onProgress,
    });

class MaterialViewerBloc
    extends Bloc<MaterialViewerEvent, MaterialViewerState> {
  final MaterialService _materialService;
  final MaterialDownloadExecutor _downloadExecutor;

  MaterialViewerBloc({
    required MaterialService materialService,
    MaterialDownloadExecutor? downloadExecutor,
  }) : _materialService = materialService,
       _downloadExecutor = downloadExecutor ?? _downloadWithFlutterDownloader,
       super(const MaterialViewerState()) {
    on<PlayVideo>(_onPlayVideo);
    on<RecordView>(_onRecordView);
    on<DownloadMaterial>(_onDownloadMaterial);
  }

  Future<void> _onPlayVideo(
    PlayVideo event,
    Emitter<MaterialViewerState> emit,
  ) async {
    emit(
      state.copyWith(
        currentMaterial: event.material,
        isLoading: true,
        isViewRecorded: false,
        clearError: true,
      ),
    );

    add(RecordView(courseId: event.courseId, material: event.material));
  }

  Future<void> _onRecordView(
    RecordView event,
    Emitter<MaterialViewerState> emit,
  ) async {
    try {
      await _materialService.recordView(
        event.courseId,
        event.material.materialId,
      );

      final current = state.currentMaterial ?? event.material;
      final updated = current.copyWith(
        hasBeenViewed: true,
        viewCount: (current.viewCount ?? 0) + 1,
      );

      emit(
        state.copyWith(
          currentMaterial: updated,
          isLoading: false,
          isViewRecorded: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isViewRecorded: false,
          error: _toMessage(error),
        ),
      );
    }
  }

  Future<void> _onDownloadMaterial(
    DownloadMaterial event,
    Emitter<MaterialViewerState> emit,
  ) async {
    emit(
      state.copyWith(
        currentMaterial: event.material,
        isDownloading: true,
        downloadProgress: 0,
        clearError: true,
        clearDownloadedFilePath: true,
      ),
    );

    try {
      final filePath = await _downloadExecutor(
        material: event.material,
        onProgress: (progress) {
          if (isClosed) return;
          emit(
            state.copyWith(
              isDownloading: true,
              downloadProgress: progress.clamp(0, 1),
            ),
          );
        },
      );

      await _rememberDownload(event.material, filePath);

      emit(
        state.copyWith(
          isDownloading: false,
          downloadProgress: 1,
          downloadedFilePath: filePath,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isDownloading: false, error: _toMessage(error)));
    }
  }

  static Future<String> _downloadWithFlutterDownloader({
    required CourseMaterialModel material,
    required void Function(double progress) onProgress,
  }) async {
    final downloadUrl =
        material.file?.downloadUrl ??
        material.externalUrl ??
        material.file?.webViewLink;

    if (downloadUrl == null || downloadUrl.trim().isEmpty) {
      throw Exception('No download URL is available for this material.');
    }

    final fileName = material.file?.fileName.trim().isNotEmpty == true
        ? material.file!.fileName
        : _sanitizeFileName(material.title);

    final saveDir = await _resolveDownloadDirectory();
    onProgress(0.05);

    final taskId = await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: saveDir.path,
      fileName: fileName,
      showNotification: false,
      openFileFromNotification: false,
      saveInPublicStorage: true,
    );

    if (taskId == null) {
      throw Exception('Unable to start download.');
    }

    const maxRetries = 600; // 600 * 350ms = ~3.5 min timeout
    var retries = 0;

    while (retries < maxRetries) {
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE task_id = "$taskId"',
      );

      final task = tasks == null || tasks.isEmpty ? null : tasks.first;
      if (task != null) {
        onProgress((task.progress / 100).clamp(0, 1));

        if (task.status == DownloadTaskStatus.complete) {
          final path = '${saveDir.path}${Platform.pathSeparator}$fileName';
          return path;
        }

        if (task.status == DownloadTaskStatus.failed ||
            task.status == DownloadTaskStatus.canceled) {
          throw Exception('Download failed. Please try again.');
        }
      }

      retries++;
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }

    throw Exception(
      'Download timed out. Please check your connection and try again.',
    );
  }

  static Future<Directory> _resolveDownloadDirectory() async {
    Directory? baseDir;

    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    }

    baseDir ??= await getApplicationDocumentsDirectory();

    final downloads = Directory(
      '${baseDir.path}${Platform.pathSeparator}eduverse_downloads',
    );

    if (!await downloads.exists()) {
      await downloads.create(recursive: true);
    }

    return downloads;
  }

  static String _sanitizeFileName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'material_${DateTime.now().millisecondsSinceEpoch}.bin';
    }

    final normalized = trimmed
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return normalized;
  }

  static Future<void> _rememberDownload(
    CourseMaterialModel material,
    String filePath,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'course_material_downloads';

    final nextEntry = jsonEncode(<String, dynamic>{
      'materialId': material.materialId,
      'title': material.title,
      'filePath': filePath,
      'savedAt': DateTime.now().toIso8601String(),
    });

    final existing = prefs.getStringList(key) ?? <String>[];
    final filtered = existing.where((row) {
      try {
        final decoded = jsonDecode(row) as Map<String, dynamic>;
        return decoded['materialId']?.toString() != material.materialId;
      } catch (_) {
        return true;
      }
    }).toList();

    filtered.insert(0, nextEntry);
    if (filtered.length > 30) {
      filtered.removeRange(30, filtered.length);
    }

    await prefs.setStringList(key, filtered);
  }

  String _toMessage(Object error) {
    return error.toString().replaceAll('Exception: ', '').trim();
  }
}
