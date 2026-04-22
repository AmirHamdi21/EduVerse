import 'dart:typed_data';

enum SummarizationType { keyPoints, brief, detailed, bulletPoints, mindMap }

enum SummaryStatus { idle, uploading, processing, completed, error }

enum InputSource { file, text }

class UploadedFile {
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime uploadedAt;
  final Uint8List? thumbnailData;

  const UploadedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.uploadedAt,
    this.thumbnailData,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}

class Summary {
  final String id;
  final String title;
  final String content;
  final SummarizationType type;
  final DateTime createdAt;
  final String? sourceFileName;
  final InputSource source;
  final bool isFavorite;
  final List<String> keyPoints;

  const Summary({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.sourceFileName,
    required this.source,
    this.isFavorite = false,
    this.keyPoints = const [],
  });

  Summary copyWith({
    String? id,
    String? title,
    String? content,
    SummarizationType? type,
    DateTime? createdAt,
    String? sourceFileName,
    InputSource? source,
    bool? isFavorite,
    List<String>? keyPoints,
  }) {
    return Summary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      source: source ?? this.source,
      isFavorite: isFavorite ?? this.isFavorite,
      keyPoints: keyPoints ?? this.keyPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'sourceFileName': sourceFileName,
      'source': source.index,
      'isFavorite': isFavorite,
      'keyPoints': keyPoints,
    };
  }

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: SummarizationType.values[json['type'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      sourceFileName: json['sourceFileName'] as String?,
      source: InputSource.values[json['source'] as int],
      isFavorite: json['isFavorite'] as bool? ?? false,
      keyPoints:
          (json['keyPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class UploadProgress {
  final String fileName;
  final double progress;
  final bool isCompleted;
  final String? error;

  const UploadProgress({
    required this.fileName,
    this.progress = 0.0,
    this.isCompleted = false,
    this.error,
  });

  UploadProgress copyWith({
    String? fileName,
    double? progress,
    bool? isCompleted,
    String? error,
  }) {
    return UploadProgress(
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}

class SummarizerState {
  final List<Summary> summaries;
  final List<Summary> filteredSummaries;
  final UploadedFile? uploadedFile;
  final String textInput;
  final SummarizationType selectedType;
  final SummaryStatus status;
  final String? errorMessage;
  final Summary? currentSummary;
  final UploadProgress? uploadProgress;
  final bool isLoading;
  final String searchQuery;
  final InputSource activeInputSource;
  final Summary? selectedSummaryForView;

  const SummarizerState({
    this.summaries = const [],
    this.filteredSummaries = const [],
    this.uploadedFile,
    this.textInput = '',
    this.selectedType = SummarizationType.keyPoints,
    this.status = SummaryStatus.idle,
    this.errorMessage,
    this.currentSummary,
    this.uploadProgress,
    this.isLoading = false,
    this.searchQuery = '',
    this.activeInputSource = InputSource.file,
    this.selectedSummaryForView,
  });

  bool get hasInput => uploadedFile != null || textInput.trim().isNotEmpty;
  bool get canGenerate => hasInput && status != SummaryStatus.processing;

  SummarizerState copyWith({
    List<Summary>? summaries,
    List<Summary>? filteredSummaries,
    UploadedFile? uploadedFile,
    String? textInput,
    SummarizationType? selectedType,
    SummaryStatus? status,
    String? errorMessage,
    Summary? currentSummary,
    UploadProgress? uploadProgress,
    bool? isLoading,
    String? searchQuery,
    InputSource? activeInputSource,
    Summary? selectedSummaryForView,
    bool clearUploadedFile = false,
    bool clearError = false,
    bool clearUploadProgress = false,
    bool clearCurrentSummary = false,
    bool clearSelectedSummary = false,
  }) {
    return SummarizerState(
      summaries: summaries ?? this.summaries,
      filteredSummaries: filteredSummaries ?? this.filteredSummaries,
      uploadedFile: clearUploadedFile
          ? null
          : (uploadedFile ?? this.uploadedFile),
      textInput: textInput ?? this.textInput,
      selectedType: selectedType ?? this.selectedType,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentSummary: clearCurrentSummary
          ? null
          : (currentSummary ?? this.currentSummary),
      uploadProgress: clearUploadProgress
          ? null
          : (uploadProgress ?? this.uploadProgress),
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      activeInputSource: activeInputSource ?? this.activeInputSource,
      selectedSummaryForView: clearSelectedSummary
          ? null
          : (selectedSummaryForView ?? this.selectedSummaryForView),
    );
  }
}
