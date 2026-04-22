import 'dart:typed_data';

enum FileType {
  pdf,
  document,
  image,
  video,
  audio,
  spreadsheet,
  presentation,
  archive,
  code,
  other,
}

enum FileSortOption {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
  sizeSmallest,
  sizeLargest,
  typeAsc,
}

enum FileFilterOption {
  all,
  pdf,
  documents,
  images,
  videos,
  audio,
  recent,
  favorites,
}

enum ViewMode { grid, list }

enum UploadStatus { idle, picking, uploading, completed, failed }

class MyFile {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? thumbnailPath;
  final bool isFavorite;
  final String? folderId;
  final String? mimeType;
  final Uint8List? thumbnailData;

  const MyFile({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
    this.thumbnailPath,
    this.isFavorite = false,
    this.folderId,
    this.mimeType,
    this.thumbnailData,
  });

  MyFile copyWith({
    String? id,
    String? name,
    String? path,
    FileType? type,
    int? size,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? thumbnailPath,
    bool? isFavorite,
    String? folderId,
    String? mimeType,
    Uint8List? thumbnailData,
  }) {
    return MyFile(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId ?? this.folderId,
      mimeType: mimeType ?? this.mimeType,
      thumbnailData: thumbnailData ?? this.thumbnailData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.index,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'isFavorite': isFavorite,
      'folderId': folderId,
      'mimeType': mimeType,
    };
  }

  factory MyFile.fromJson(Map<String, dynamic> json) {
    return MyFile(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: FileType.values[json['type'] as int],
      size: json['size'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      folderId: json['folderId'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }

  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static FileType getTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
      case 'odt':
        return FileType.document;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
      case 'bmp':
        return FileType.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
      case 'wmv':
      case 'flv':
        return FileType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
      case 'm4a':
        return FileType.audio;
      case 'xls':
      case 'xlsx':
      case 'csv':
      case 'ods':
        return FileType.spreadsheet;
      case 'ppt':
      case 'pptx':
      case 'odp':
        return FileType.presentation;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FileType.archive;
      case 'dart':
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'html':
      case 'css':
      case 'json':
      case 'xml':
        return FileType.code;
      default:
        return FileType.other;
    }
  }
}

class MyFolder {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  final int fileCount;
  final int color;

  const MyFolder({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    this.fileCount = 0,
    this.color = 0xFF3B82F6,
  });

  MyFolder copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    int? fileCount,
    int? color,
  }) {
    return MyFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      fileCount: fileCount ?? this.fileCount,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'fileCount': fileCount,
      'color': color,
    };
  }

  factory MyFolder.fromJson(Map<String, dynamic> json) {
    return MyFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileCount: json['fileCount'] as int? ?? 0,
      color: json['color'] as int? ?? 0xFF3B82F6,
    );
  }
}

class UploadProgress {
  final String fileName;
  final double progress;
  final UploadStatus status;
  final String? errorMessage;

  const UploadProgress({
    required this.fileName,
    this.progress = 0.0,
    this.status = UploadStatus.idle,
    this.errorMessage,
  });

  UploadProgress copyWith({
    String? fileName,
    double? progress,
    UploadStatus? status,
    String? errorMessage,
  }) {
    return UploadProgress(
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StorageStats {
  final int usedSpace;
  final int totalSpace;
  final Map<FileType, int> typeDistribution;

  const StorageStats({
    this.usedSpace = 0,
    this.totalSpace = 1024 * 1024 * 1024, // 1GB default
    this.typeDistribution = const {},
  });

  double get usedPercentage => totalSpace > 0 ? usedSpace / totalSpace : 0;
  int get freeSpace => totalSpace - usedSpace;

  String get formattedUsed {
    if (usedSpace < 1024) return '$usedSpace B';
    if (usedSpace < 1024 * 1024) {
      return '${(usedSpace / 1024).toStringAsFixed(1)} KB';
    }
    if (usedSpace < 1024 * 1024 * 1024) {
      return '${(usedSpace / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(usedSpace / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedTotal {
    if (totalSpace < 1024 * 1024 * 1024) {
      return '${(totalSpace / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(totalSpace / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class MyFilesState {
  final List<MyFile> files;
  final List<MyFile> filteredFiles;
  final List<MyFolder> folders;
  final String? currentFolderId;
  final FileFilterOption filterOption;
  final FileSortOption sortOption;
  final ViewMode viewMode;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final MyFile? selectedFile;
  final Set<String> selectedFileIds;
  final bool isMultiSelectMode;
  final UploadProgress? uploadProgress;
  final StorageStats storageStats;

  const MyFilesState({
    this.files = const [],
    this.filteredFiles = const [],
    this.folders = const [],
    this.currentFolderId,
    this.filterOption = FileFilterOption.all,
    this.sortOption = FileSortOption.dateNewest,
    this.viewMode = ViewMode.grid,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.selectedFile,
    this.selectedFileIds = const {},
    this.isMultiSelectMode = false,
    this.uploadProgress,
    this.storageStats = const StorageStats(),
  });

  MyFilesState copyWith({
    List<MyFile>? files,
    List<MyFile>? filteredFiles,
    List<MyFolder>? folders,
    String? currentFolderId,
    FileFilterOption? filterOption,
    FileSortOption? sortOption,
    ViewMode? viewMode,
    String? searchQuery,
    bool? isLoading,
    String? error,
    MyFile? selectedFile,
    Set<String>? selectedFileIds,
    bool? isMultiSelectMode,
    UploadProgress? uploadProgress,
    StorageStats? storageStats,
    bool clearSelectedFile = false,
    bool clearError = false,
    bool clearCurrentFolder = false,
    bool clearUploadProgress = false,
  }) {
    return MyFilesState(
      files: files ?? this.files,
      filteredFiles: filteredFiles ?? this.filteredFiles,
      folders: folders ?? this.folders,
      currentFolderId: clearCurrentFolder
          ? null
          : (currentFolderId ?? this.currentFolderId),
      filterOption: filterOption ?? this.filterOption,
      sortOption: sortOption ?? this.sortOption,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedFile: clearSelectedFile
          ? null
          : (selectedFile ?? this.selectedFile),
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      uploadProgress: clearUploadProgress
          ? null
          : (uploadProgress ?? this.uploadProgress),
      storageStats: storageStats ?? this.storageStats,
    );
  }
}
