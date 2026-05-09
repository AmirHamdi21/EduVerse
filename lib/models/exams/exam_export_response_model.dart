import 'dart:convert';
import 'dart:typed_data';

class ExamExportResponseModel {
  const ExamExportResponseModel({
    required this.fileName,
    required this.mimeType,
    required this.content,
  });

  final String fileName;
  final String mimeType;
  final String content;

  Uint8List get decodedBytes => base64Decode(content);

  factory ExamExportResponseModel.fromJson(Map<String, dynamic> json) {
    return ExamExportResponseModel(
      fileName: json['fileName']?.toString() ?? 'exam.doc',
      mimeType: json['mimeType']?.toString() ?? 'application/msword',
      content: json['content']?.toString() ?? '',
    );
  }
}
