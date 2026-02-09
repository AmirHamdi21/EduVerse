// Models for Upload Materials screen

import 'package:flutter/material.dart';

/// Material type enum
enum CourseMaterialType {
  document,
  video,
  audio,
  image,
  link,
  archive,
  presentation,
  spreadsheet,
  other,
}

/// Extension for CourseMaterialType properties
extension MaterialTypeExtension on CourseMaterialType {
  String get title {
    switch (this) {
      case CourseMaterialType.document:
        return 'Document';
      case CourseMaterialType.video:
        return 'Video';
      case CourseMaterialType.audio:
        return 'Audio';
      case CourseMaterialType.image:
        return 'Image';
      case CourseMaterialType.link:
        return 'Link';
      case CourseMaterialType.archive:
        return 'Archive';
      case CourseMaterialType.presentation:
        return 'Presentation';
      case CourseMaterialType.spreadsheet:
        return 'Spreadsheet';
      case CourseMaterialType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case CourseMaterialType.document:
        return Icons.description_rounded;
      case CourseMaterialType.video:
        return Icons.video_library_rounded;
      case CourseMaterialType.audio:
        return Icons.audiotrack_rounded;
      case CourseMaterialType.image:
        return Icons.image_rounded;
      case CourseMaterialType.link:
        return Icons.link_rounded;
      case CourseMaterialType.archive:
        return Icons.folder_zip_rounded;
      case CourseMaterialType.presentation:
        return Icons.slideshow_rounded;
      case CourseMaterialType.spreadsheet:
        return Icons.table_chart_rounded;
      case CourseMaterialType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get color {
    switch (this) {
      case CourseMaterialType.document:
        return const Color(0xFF3B82F6); // Blue
      case CourseMaterialType.video:
        return const Color(0xFFEF4444); // Red
      case CourseMaterialType.audio:
        return const Color(0xFF8B5CF6); // Purple
      case CourseMaterialType.image:
        return const Color(0xFF10B981); // Green
      case CourseMaterialType.link:
        return const Color(0xFF0EA5E9); // Sky blue
      case CourseMaterialType.archive:
        return const Color(0xFFF59E0B); // Amber
      case CourseMaterialType.presentation:
        return const Color(0xFFEC4899); // Pink
      case CourseMaterialType.spreadsheet:
        return const Color(0xFF22C55E); // Green
      case CourseMaterialType.other:
        return const Color(0xFF6B7280); // Gray
    }
  }

  List<String> get extensions {
    switch (this) {
      case CourseMaterialType.document:
        return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'];
      case CourseMaterialType.video:
        return ['mp4', 'avi', 'mov', 'mkv', 'webm', 'flv'];
      case CourseMaterialType.audio:
        return ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a'];
      case CourseMaterialType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'];
      case CourseMaterialType.link:
        return [];
      case CourseMaterialType.archive:
        return ['zip', 'rar', '7z', 'tar', 'gz'];
      case CourseMaterialType.presentation:
        return ['ppt', 'pptx', 'key', 'odp'];
      case CourseMaterialType.spreadsheet:
        return ['xls', 'xlsx', 'csv', 'ods'];
      case CourseMaterialType.other:
        return [];
    }
  }
}

/// Upload status enum
enum UploadStatus {
  pending,
  uploading,
  processing,
  completed,
  failed,
}

/// Course material model
class CourseMaterial {
  final String id;
  final String name;
  final String? description;
  final CourseMaterialType type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String courseId;
  final String? moduleId;
  final DateTime uploadedAt;
  final UploadStatus status;
  final double? uploadProgress;
  final bool isVisible;
  final int downloadCount;
  final List<String>? tags;

  const CourseMaterial({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.courseId,
    this.moduleId,
    required this.uploadedAt,
    this.status = UploadStatus.pending,
    this.uploadProgress,
    this.isVisible = true,
    this.downloadCount = 0,
    this.tags,
  });

  CourseMaterial copyWith({
    String? id,
    String? name,
    String? description,
    CourseMaterialType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? courseId,
    String? moduleId,
    DateTime? uploadedAt,
    UploadStatus? status,
    double? uploadProgress,
    bool? isVisible,
    int? downloadCount,
    List<String>? tags,
  }) {
    return CourseMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      courseId: courseId ?? this.courseId,
      moduleId: moduleId ?? this.moduleId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isVisible: isVisible ?? this.isVisible,
      downloadCount: downloadCount ?? this.downloadCount,
      tags: tags ?? this.tags,
    );
  }

  String get formattedSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    if (fileSize! < 1024 * 1024 * 1024) return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Upload queue item for tracking uploads
class UploadQueueItem {
  final String id;
  final String fileName;
  final int fileSize;
  final CourseMaterialType type;
  final UploadStatus status;
  final double progress;
  final String? errorMessage;

  const UploadQueueItem({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.type,
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
  });

  UploadQueueItem copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    CourseMaterialType? type,
    UploadStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return UploadQueueItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Course module for organizing materials
class CourseModule {
  final String id;
  final String name;
  final int materialCount;

  const CourseModule({
    required this.id,
    required this.name,
    this.materialCount = 0,
  });
}

/// Course for selection
class CourseOption {
  final String id;
  final String name;
  final String code;
  final List<CourseModule> modules;

  const CourseOption({
    required this.id,
    required this.name,
    required this.code,
    this.modules = const [],
  });
}
