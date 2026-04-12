import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/instructor/upload_materials_model.dart';
import '../../services/api/material_service.dart';
import '../../utils/bundle_detector.dart';
import 'materials_event.dart';
import 'materials_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final MaterialService _materialService;

  MaterialsBloc({required MaterialService materialService})
    : _materialService = materialService,
      super(const MaterialsInitial()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<UploadMaterial>(_onUploadMaterial);
    on<UpdateMaterial>(_onUpdateMaterial);
    on<DeleteMaterial>(_onDeleteMaterial);
    on<ToggleMaterialVisibility>(_onToggleMaterialVisibility);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(const MaterialsLoading());

    try {
      final materials = await _materialService.getMaterials(event.courseId);
      final bundles = BundleDetector.groupMaterialsIntoBundles(materials);

      emit(
        MaterialsLoaded(
          courseId: event.courseId,
          materials: materials,
          bundles: bundles,
        ),
      );
    } catch (error) {
      emit(MaterialsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUploadMaterial(
    UploadMaterial event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      if (event.isBundle) {
        await _uploadBundle(event, emit);
      } else {
        await _uploadSingle(event, emit);
      }

      add(LoadMaterials(event.courseId));
    } catch (error) {
      emit(MaterialsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _uploadSingle(
    UploadMaterial event,
    Emitter<MaterialsState> emit,
  ) async {
    final now = DateTime.now();

    if (event.materialType == 'document' && event.filePath != null) {
      await _materialService.uploadDocument(
        event.courseId,
        file: File(event.filePath!),
        title: event.title,
        weekNumber: event.weekNumber,
        isPublished: event.isPublished,
      );

      emit(
        UploadProgress(
          UploadProgressState(
            uploadId: event.uploadId,
            fileName: event.title,
            fileSize: 0,
            bytesSent: 1,
            totalBytes: 1,
            status: UploadProgressStatus.completed,
            stepLabel: 'Document uploaded',
            startedAt: now,
            completedAt: DateTime.now(),
          ),
        ),
      );
      return;
    }

    if (event.materialType == 'video' && event.filePath != null) {
      var lastProgressEmit = DateTime.fromMillisecondsSinceEpoch(0);

      await _materialService.uploadVideo(
        event.courseId,
        file: File(event.filePath!),
        title: event.title,
        weekNumber: event.weekNumber,
        isPublished: event.isPublished,
        onSendProgress: (sent, total) {
          final now = DateTime.now();
          if (now.difference(lastProgressEmit).inMilliseconds < 500) {
            return;
          }
          lastProgressEmit = now;

          emit(
            UploadProgress(
              UploadProgressState(
                uploadId: event.uploadId,
                fileName: event.title,
                fileSize: total,
                bytesSent: sent,
                totalBytes: total,
                status: UploadProgressStatus.uploading,
                stepLabel: 'Uploading video',
                startedAt: now,
              ),
            ),
          );
        },
      );

      emit(
        UploadProgress(
          UploadProgressState(
            uploadId: event.uploadId,
            fileName: event.title,
            fileSize: 0,
            bytesSent: 1,
            totalBytes: 1,
            status: UploadProgressStatus.completed,
            stepLabel: 'Video uploaded',
            startedAt: now,
            completedAt: DateTime.now(),
          ),
        ),
      );
      return;
    }

    if ((event.materialType == 'link' || event.materialType == 'text') &&
        event.linkUrl != null &&
        event.linkUrl!.isNotEmpty) {
      await _materialService.uploadTextLink(
        event.courseId,
        title: event.title,
        url: event.linkUrl!,
        type: 'link',
        weekNumber: event.weekNumber,
        isPublished: event.isPublished,
      );

      emit(
        UploadProgress(
          UploadProgressState(
            uploadId: event.uploadId,
            fileName: event.title,
            fileSize: 0,
            bytesSent: 1,
            totalBytes: 1,
            status: UploadProgressStatus.completed,
            stepLabel: 'Link created',
            startedAt: now,
            completedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  Future<void> _uploadBundle(
    UploadMaterial event,
    Emitter<MaterialsState> emit,
  ) async {
    final failed = <String>[];
    final startedAt = DateTime.now();

    if (event.bundleVideoPath != null && event.bundleVideoPath!.isNotEmpty) {
      try {
        await _materialService.uploadVideo(
          event.courseId,
          file: File(event.bundleVideoPath!),
          title: '${event.title} - Video',
          weekNumber: event.weekNumber,
          isPublished: event.isPublished,
        );

        emit(
          UploadProgress(
            UploadProgressState(
              uploadId: event.uploadId,
              fileName: event.title,
              fileSize: 0,
              bytesSent: 1,
              totalBytes: 1,
              status: UploadProgressStatus.uploading,
              stepLabel: 'Uploaded bundle video',
              startedAt: startedAt,
            ),
          ),
        );
      } catch (_) {
        failed.add(event.bundleVideoPath!);
      }
    }

    for (var i = 0; i < event.bundleDocumentPaths.length; i++) {
      final path = event.bundleDocumentPaths[i];
      try {
        await _materialService.uploadDocument(
          event.courseId,
          file: File(path),
          title: '${event.title} - ${i + 1}',
          weekNumber: event.weekNumber,
          isPublished: event.isPublished,
        );

        emit(
          UploadProgress(
            UploadProgressState(
              uploadId: event.uploadId,
              fileName: event.title,
              fileSize: 0,
              bytesSent: i + 1,
              totalBytes: event.bundleDocumentPaths.length,
              status: UploadProgressStatus.uploading,
              stepLabel:
                  'Uploading document ${i + 1} of ${event.bundleDocumentPaths.length}',
              startedAt: startedAt,
            ),
          ),
        );
      } catch (_) {
        failed.add(path);
      }
    }

    if (failed.isNotEmpty) {
      emit(
        MaterialsError(
          '${failed.length} bundle item(s) failed to upload',
          failedMaterialIds: failed,
        ),
      );
      return;
    }

    emit(
      UploadProgress(
        UploadProgressState(
          uploadId: event.uploadId,
          fileName: event.title,
          fileSize: 0,
          bytesSent: event.bundleDocumentPaths.length,
          totalBytes: event.bundleDocumentPaths.length,
          status: UploadProgressStatus.completed,
          stepLabel: 'Bundle upload completed',
          startedAt: startedAt,
          completedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _onUpdateMaterial(
    UpdateMaterial event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      await _materialService.updateMaterialDetails(
        event.courseId,
        event.materialId,
        event.payload,
      );
      add(LoadMaterials(event.courseId));
    } catch (error) {
      emit(MaterialsError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteMaterial(
    DeleteMaterial event,
    Emitter<MaterialsState> emit,
  ) async {
    final failed = <String>[];

    for (final materialId in event.materialIds) {
      try {
        await _materialService.deleteMaterial(event.courseId, materialId);
      } catch (_) {
        failed.add(materialId);
      }
    }

    if (failed.isNotEmpty) {
      emit(
        MaterialsError(
          '${event.materialIds.length - failed.length} of ${event.materialIds.length} materials deleted',
          failedMaterialIds: failed,
        ),
      );
    }

    add(LoadMaterials(event.courseId));
  }

  Future<void> _onToggleMaterialVisibility(
    ToggleMaterialVisibility event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      await _materialService.toggleVisibility(
        event.courseId,
        event.materialId,
        isPublished: event.isPublished,
      );
      add(LoadMaterials(event.courseId));
    } catch (error) {
      emit(MaterialsError(error.toString().replaceAll('Exception: ', '')));
    }
  }
}
