import 'question_bank_enums.dart';

class QuestionAttachmentPayload {
  const QuestionAttachmentPayload({
    this.fileId,
    this.attachmentType = QuestionAttachmentType.image,
    this.caption,
    this.altText,
    this.displayOrder = 0,
    this.isPrimary = false,
    this.fileName,
    this.imageUrl,
  });

  final int? fileId;
  final QuestionAttachmentType attachmentType;
  final String? caption;
  final String? altText;
  final int displayOrder;
  final bool isPrimary;
  final String? fileName;
  final String? imageUrl;

  QuestionAttachmentPayload copyWith({
    int? fileId,
    QuestionAttachmentType? attachmentType,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
    String? fileName,
    String? imageUrl,
  }) {
    return QuestionAttachmentPayload(
      fileId: fileId ?? this.fileId,
      attachmentType: attachmentType ?? this.attachmentType,
      caption: caption ?? this.caption,
      altText: altText ?? this.altText,
      displayOrder: displayOrder ?? this.displayOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      fileName: fileName ?? this.fileName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      if (fileId != null) 'fileId': fileId,
      'attachmentType': attachmentType.value,
      if (_hasText(caption)) 'caption': caption!.trim(),
      if (_hasText(altText)) 'altText': altText!.trim(),
      'displayOrder': displayOrder,
      'isPrimary': isPrimary,
    };
  }

  String? validate({bool requireFileId = true}) {
    if (requireFileId && (fileId == null || fileId! <= 0)) {
      return 'File id is required';
    }
    if (displayOrder < 0) return 'Display order cannot be negative';
    return null;
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
