import 'package:equatable/equatable.dart';

class DriveFileModel extends Equatable {
  final int fileId;
  final int driveFileId;
  final String driveId;
  final String fileName;
  final String webViewLink;
  final String downloadUrl;
  final String iframeUrl;

  const DriveFileModel({
    this.fileId = 0,
    required this.driveFileId,
    required this.driveId,
    required this.fileName,
    required this.webViewLink,
    required this.downloadUrl,
    required this.iframeUrl,
  });

  factory DriveFileModel.fromJson(Map<String, dynamic> json) {
    final resolvedDriveId = _parseString(json['driveId']);
    final resolvedFileId = _parseInt(
      json['fileId'] ??
          json['instructionFileId'] ??
          json['instruction_file_id'] ??
          json['id'],
    );

    return DriveFileModel(
      fileId: resolvedFileId,
      driveFileId: _parseInt(
        json['driveFileId'] ?? json['drive_file_id'] ?? json['id'],
      ),
      driveId: resolvedDriveId,
      fileName: _parseString(json['fileName'] ?? json['name']),
      webViewLink: _parseString(json['webViewLink']),
      downloadUrl: _parseString(json['webContentLink'] ?? json['downloadUrl']),
      iframeUrl: 'https://drive.google.com/file/d/$resolvedDriveId/preview',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fileId': fileId,
      'driveFileId': driveFileId,
      'driveId': driveId,
      'fileName': fileName,
      'webViewLink': webViewLink,
      'downloadUrl': downloadUrl,
      'iframeUrl': iframeUrl,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  @override
  List<Object?> get props => <Object?>[
    fileId,
    driveFileId,
    driveId,
    fileName,
    webViewLink,
    downloadUrl,
    iframeUrl,
  ];
}
