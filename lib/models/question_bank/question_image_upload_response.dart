class QuestionImageUploadResponse {
  const QuestionImageUploadResponse({
    required this.fileId,
    this.fileName,
    this.originalFileName,
    this.fileSize,
    this.mimeType,
    this.folderId,
    this.uploadedBy,
    this.uploaderName,
    this.createdAt,
    this.versionCount,
    this.imageUrl,
  });

  final int fileId;
  final String? fileName;
  final String? originalFileName;
  final int? fileSize;
  final String? mimeType;
  final int? folderId;
  final int? uploadedBy;
  final String? uploaderName;
  final DateTime? createdAt;
  final int? versionCount;
  final String? imageUrl;

  factory QuestionImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return QuestionImageUploadResponse(
      fileId: _readInt(json, const <String>['fileId', 'id']),
      fileName: _readString(json, const <String>['fileName', 'name']),
      originalFileName: _readString(json, const <String>['originalFileName']),
      fileSize: _readNullableInt(json, const <String>['fileSize', 'size']),
      mimeType: _readString(json, const <String>['mimeType', 'mimetype']),
      folderId: _readNullableInt(json, const <String>['folderId']),
      uploadedBy: _readNullableInt(json, const <String>['uploadedBy']),
      uploaderName: _readString(json, const <String>['uploaderName']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      versionCount: _readNullableInt(json, const <String>['versionCount']),
      imageUrl: _readString(json, const <String>['imageUrl', 'url']),
    );
  }
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  return _readNullableInt(json, keys) ?? 0;
}

int? _readNullableInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}
