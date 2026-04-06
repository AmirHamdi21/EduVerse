import 'package:equatable/equatable.dart';

/// Represents a course material (document, video, lecture, slide, or link).
///
/// Maps to the backend `/api/courses/{courseId}/materials` endpoints.
class CourseMaterialModel extends Equatable {
  final String materialId;
  final String courseId;
  final String? fileId;
  final String? driveFileId;
  final String materialType; // 'document' | 'video' | 'lecture' | 'slide' | 'link'
  final String title;
  final String? description;
  final String? externalUrl;
  final String? youtubeVideoId;
  final int? orderIndex;
  final int? weekNumber;
  final int? viewCount;
  final int? downloadCount;
  final int? uploadedBy;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CourseMaterialModel({
    required this.materialId,
    required this.courseId,
    this.fileId,
    this.driveFileId,
    required this.materialType,
    required this.title,
    this.description,
    this.externalUrl,
    this.youtubeVideoId,
    this.orderIndex,
    this.weekNumber,
    this.viewCount,
    this.downloadCount,
    this.uploadedBy,
    required this.isPublished,
    this.publishedAt,
    required this.createdAt,
    this.updatedAt,
  });

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

    return CourseMaterialModel(
      materialId: json['materialId']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      fileId: json['fileId']?.toString(),
      driveFileId: json['driveFileId']?.toString(),
      materialType: json['materialType'] as String? ?? 'document',
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
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'courseId': courseId,
      'fileId': fileId,
      'driveFileId': driveFileId,
      'materialType': materialType,
      'title': title,
      'description': description,
      'externalUrl': externalUrl,
      'youtubeVideoId': youtubeVideoId,
      'orderIndex': orderIndex,
      'weekNumber': weekNumber,
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'uploadedBy': uploadedBy,
      'isPublished': isPublished,
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
        materialType,
        title,
        description,
        externalUrl,
        youtubeVideoId,
        orderIndex,
        weekNumber,
        viewCount,
        downloadCount,
        uploadedBy,
        isPublished,
        publishedAt,
        createdAt,
        updatedAt,
      ];
}
