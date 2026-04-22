import 'package:equatable/equatable.dart';

import '../../../../models/materials/course_material_model.dart';

class MaterialViewerState extends Equatable {
  final CourseMaterialModel? currentMaterial;
  final bool isViewRecorded;
  final bool isLoading;
  final String? error;
  final bool isDownloading;
  final double downloadProgress;
  final String? downloadedFilePath;

  const MaterialViewerState({
    this.currentMaterial,
    this.isViewRecorded = false,
    this.isLoading = false,
    this.error,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.downloadedFilePath,
  });

  MaterialViewerState copyWith({
    CourseMaterialModel? currentMaterial,
    bool? isViewRecorded,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isDownloading,
    double? downloadProgress,
    String? downloadedFilePath,
    bool clearDownloadedFilePath = false,
  }) {
    return MaterialViewerState(
      currentMaterial: currentMaterial ?? this.currentMaterial,
      isViewRecorded: isViewRecorded ?? this.isViewRecorded,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedFilePath: clearDownloadedFilePath
          ? null
          : (downloadedFilePath ?? this.downloadedFilePath),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currentMaterial,
    isViewRecorded,
    isLoading,
    error,
    isDownloading,
    downloadProgress,
    downloadedFilePath,
  ];
}
