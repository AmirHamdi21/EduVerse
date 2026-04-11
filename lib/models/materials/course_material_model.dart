import 'package:equatable/equatable.dart';

/// Represents a course material (document, video, lecture, slide, or link).
///
/// Maps to the backend `/api/courses/{courseId}/materials` endpoints.
class CourseMaterialModel extends Equatable {
  final String materialId;
  final String courseId;
  final String? fileId;
  final String? driveFileId;
  final DriveFileModel? file;
  final String
  materialType; // 'document' | 'video' | 'lecture' | 'slide' | 'link'
  final String title;
  final String? description;
  final String? externalUrl;
  final String? _youtubeVideoId;
  final int? orderIndex;
  final int? weekNumber;
  final int? viewCount;
  final int? downloadCount;
  final int? uploadedBy;
  final bool isPublished;
  final bool hasBeenViewed;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CourseMaterialModel({
    required this.materialId,
    required this.courseId,
    this.fileId,
    this.driveFileId,
    this.file,
    required this.materialType,
    required this.title,
    this.description,
    this.externalUrl,
    String? youtubeVideoId,
    this.orderIndex,
    this.weekNumber,
    this.viewCount,
    this.downloadCount,
    this.uploadedBy,
    required this.isPublished,
    this.hasBeenViewed = false,
    this.publishedAt,
    required this.createdAt,
    this.updatedAt,
  }) : _youtubeVideoId = youtubeVideoId;

  /// Extracts the YouTube video ID from either the explicit API field
  /// or the external URL when possible.
  String? get youtubeVideoId {
    if (_youtubeVideoId != null && _youtubeVideoId.isNotEmpty) {
      return _youtubeVideoId;
    }

    final url = externalUrl;
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      return segment.isNotEmpty ? segment : null;
    }

    if (uri.queryParameters.containsKey('v')) {
      final value = uri.queryParameters['v'];
      return (value != null && value.isNotEmpty) ? value : null;
    }

    final match = RegExp(
      r'(?:embed/|shorts/)([A-Za-z0-9_-]{11})',
    ).firstMatch(url);
    return match?.group(1);
  }

  /// Returns a YouTube thumbnail URL when a valid video id is available.
  String? get thumbnailUrl {
    final videoId = youtubeVideoId;
    if (videoId == null || videoId.isEmpty) {
      return null;
    }
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  /// Returns a Google Drive preview URL for inline rendering.
  String? get drivePreviewUrl {
    final direct = file?.iframeUrl;
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final driveId = file?.driveId ?? driveFileId;
    if (driveId == null || driveId.isEmpty) {
      return null;
    }

    return 'https://drive.google.com/file/d/$driveId/preview';
  }

  factory CourseMaterialModel.fromJson(Map<String, dynamic> json) {
    // isPublished can come as int (0/1) or bool from the backend
    final rawPublished = json['isPublished'];
    final bool published;
    if (rawPublished is bool) {
      published = rawPublished;
    } else if (rawPublished is int) {
      published = rawPublished == 1;
    } else {
      published = false;
    }

    final rawFile = json['file'];
    final parsedFile = rawFile is Map<String, dynamic>
        ? DriveFileModel.fromJson(rawFile)
        : null;

    final createdAt = _parseDateTime(json['createdAt']);

    return CourseMaterialModel(
      materialId: (json['materialId'] ?? json['id'])?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      fileId: json['fileId']?.toString(),
      driveFileId: json['driveFileId']?.toString() ?? parsedFile?.driveId,
      file: parsedFile,
      materialType:
          (json['materialType'] ?? json['type']) as String? ?? 'document',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      externalUrl: json['externalUrl'] as String?,
      youtubeVideoId: json['youtubeVideoId'] as String?,
      orderIndex: json['orderIndex'] is int
          ? json['orderIndex'] as int
          : json['orderIndex'] != null
          ? int.tryParse(json['orderIndex'].toString())
          : null,
      weekNumber: json['weekNumber'] is int
          ? json['weekNumber'] as int
          : json['weekNumber'] != null
          ? int.tryParse(json['weekNumber'].toString())
          : null,
      viewCount: json['viewCount'] is int
          ? json['viewCount'] as int
          : json['viewCount'] != null
          ? int.tryParse(json['viewCount'].toString())
          : null,
      downloadCount: json['downloadCount'] is int
          ? json['downloadCount'] as int
          : json['downloadCount'] != null
          ? int.tryParse(json['downloadCount'].toString())
          : null,
      uploadedBy: json['uploadedBy'] is int
          ? json['uploadedBy'] as int
          : json['uploadedBy'] != null
          ? int.tryParse(json['uploadedBy'].toString())
          : null,
      isPublished: published,
      hasBeenViewed: json['hasBeenViewed'] == true,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  CourseMaterialModel copyWith({
    int? viewCount,
    int? downloadCount,
    bool? hasBeenViewed,
  }) {
    return CourseMaterialModel(
      materialId: materialId,
      courseId: courseId,
      fileId: fileId,
      driveFileId: driveFileId,
      file: file,
      materialType: materialType,
      title: title,
      description: description,
      externalUrl: externalUrl,
      youtubeVideoId: _youtubeVideoId,
      orderIndex: orderIndex,
      weekNumber: weekNumber,
      viewCount: viewCount ?? this.viewCount,
      downloadCount: downloadCount ?? this.downloadCount,
      uploadedBy: uploadedBy,
      isPublished: isPublished,
      hasBeenViewed: hasBeenViewed ?? this.hasBeenViewed,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'courseId': courseId,
      'fileId': fileId,
      'driveFileId': driveFileId,
      'file': file?.toJson(),
      'materialType': materialType,
      'title': title,
      'description': description,
      'externalUrl': externalUrl,
      'youtubeVideoId': _youtubeVideoId,
      'orderIndex': orderIndex,
      'weekNumber': weekNumber,
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'uploadedBy': uploadedBy,
      'isPublished': isPublished,
      'hasBeenViewed': hasBeenViewed,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    materialId,
    courseId,
    fileId,
    driveFileId,
    file,
    materialType,
    title,
    description,
    externalUrl,
    _youtubeVideoId,
    orderIndex,
    weekNumber,
    viewCount,
    downloadCount,
    uploadedBy,
    isPublished,
    hasBeenViewed,
    publishedAt,
    createdAt,
    updatedAt,
  ];
}

class DriveFileModel extends Equatable {
  final String driveId;
  final String fileName;
  final String? webViewLink;
  final String? iframeUrl;
  final String? downloadUrl;
  final String? mimeType;
  final int? fileSize;

  const DriveFileModel({
    required this.driveId,
    required this.fileName,
    this.webViewLink,
    this.iframeUrl,
    this.downloadUrl,
    this.mimeType,
    this.fileSize,
  });

  factory DriveFileModel.fromJson(Map<String, dynamic> json) {
    return DriveFileModel(
      driveId: json['driveId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      webViewLink: json['webViewLink']?.toString(),
      iframeUrl: json['iframeUrl']?.toString(),
      downloadUrl: json['downloadUrl']?.toString(),
      mimeType: json['mimeType']?.toString(),
      fileSize: json['fileSize'] is int
          ? json['fileSize'] as int
          : int.tryParse(json['fileSize']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'driveId': driveId,
      'fileName': fileName,
      'webViewLink': webViewLink,
      'iframeUrl': iframeUrl,
      'downloadUrl': downloadUrl,
      'mimeType': mimeType,
      'fileSize': fileSize,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    driveId,
    fileName,
    webViewLink,
    iframeUrl,
    downloadUrl,
    mimeType,
    fileSize,
  ];
}
