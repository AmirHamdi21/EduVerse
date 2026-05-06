class QuestionBankUploadResponse {
  const QuestionBankUploadResponse({
    required this.fileId,
    this.fileName,
    this.mimeType,
    this.storagePath,
    this.imageUrl,
  });

  final int fileId;
  final String? fileName;
  final String? mimeType;
  final String? storagePath;
  final String? imageUrl;

  factory QuestionBankUploadResponse.fromJson(Map<String, dynamic> json) {
    return QuestionBankUploadResponse(
      fileId: _toInt(json['fileId'] ?? json['id']),
      fileName: _nullableString(json['fileName'] ?? json['originalName']),
      mimeType: _nullableString(json['mimeType']),
      storagePath: _nullableString(json['storagePath'] ?? json['path']),
      imageUrl: _nullableString(json['imageUrl']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
