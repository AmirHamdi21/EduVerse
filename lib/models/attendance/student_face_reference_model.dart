import 'package:equatable/equatable.dart';

/// Maps GET /attendance/face-references/me response items.
class StudentFaceReferenceModel extends Equatable {
  final int id;
  final int userId;
  final String storagePath;
  final String? mimeType;
  final int? fileSize;
  final bool isPrimary;
  final String? createdAt;
  final String? signedUrl;

  const StudentFaceReferenceModel({
    required this.id,
    required this.userId,
    required this.storagePath,
    this.mimeType,
    this.fileSize,
    this.isPrimary = false,
    this.createdAt,
    this.signedUrl,
  });

  factory StudentFaceReferenceModel.fromJson(Map<String, dynamic> json) {
    return StudentFaceReferenceModel(
      id: _toInt(json['id']),
      userId: _toInt(json['userId']),
      storagePath: json['storagePath']?.toString() ?? '',
      mimeType: json['mimeType']?.toString(),
      fileSize: _toNullableInt(json['fileSize']),
      isPrimary: json['isPrimary'] == true,
      createdAt: json['createdAt']?.toString(),
      signedUrl: json['signedUrl']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    storagePath,
    mimeType,
    fileSize,
    isPrimary,
    createdAt,
    signedUrl,
  ];
}
