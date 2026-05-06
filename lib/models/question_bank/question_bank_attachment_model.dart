import 'question_bank_enums.dart';

class QuestionBankAttachmentModel {
  const QuestionBankAttachmentModel({
    required this.attachmentId,
    required this.fileId,
    required this.attachmentType,
    this.caption,
    this.altText,
    required this.displayOrder,
    required this.isPrimary,
    this.storagePath,
    this.imageUrl,
  });

  final int attachmentId;
  final int fileId;
  final QuestionAttachmentType attachmentType;
  final String? caption;
  final String? altText;
  final int displayOrder;
  final bool isPrimary;
  final String? storagePath;
  final String? imageUrl;

  factory QuestionBankAttachmentModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankAttachmentModel(
      attachmentId: _toInt(json['attachmentId'] ?? json['id']),
      fileId: _toInt(json['fileId']),
      attachmentType: QuestionAttachmentType.fromJson(json['attachmentType']),
      caption: _nullableString(json['caption']),
      altText: _nullableString(json['altText']),
      displayOrder: _toInt(json['displayOrder']),
      isPrimary: _toBool(json['isPrimary']),
      storagePath: _nullableString(json['storagePath']),
      imageUrl: _nullableString(json['imageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'attachmentId': attachmentId,
      'fileId': fileId,
      'attachmentType': attachmentType.value,
      'caption': caption,
      'altText': altText,
      'displayOrder': displayOrder,
      'isPrimary': isPrimary,
      'storagePath': storagePath,
      'imageUrl': imageUrl,
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
