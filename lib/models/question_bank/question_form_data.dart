import '../instructor/question_bank_exam_models.dart';

typedef QuestionRequestMap = Map<String, dynamic>;

class QuestionFormData {
  const QuestionFormData(this.values);

  final Map<String, dynamic> values;

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>.from(values);
    _stripQuestionChildResponseFields(data);
    return data;
  }
}

class QuestionAttachmentCreateRequest {
  const QuestionAttachmentCreateRequest({
    required this.fileId,
    required this.attachmentType,
    this.caption,
    this.altText,
    this.isPrimary = false,
    this.displayOrder,
  });

  final int fileId;
  final QuestionBankAttachmentType attachmentType;
  final String? caption;
  final String? altText;
  final bool isPrimary;
  final int? displayOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fileId': fileId,
      'attachmentType': attachmentType.toJson(),
      if (_hasText(caption)) 'caption': caption!.trim(),
      if (_hasText(altText)) 'altText': altText!.trim(),
      if (isPrimary) 'isPrimary': true,
      if (displayOrder != null) 'displayOrder': displayOrder,
    };
  }
}

class QuestionAttachmentUpdateRequest {
  const QuestionAttachmentUpdateRequest({
    this.caption = _noChange,
    this.altText = _noChange,
    this.isPrimary,
    this.displayOrder,
  });

  final Object? caption;
  final Object? altText;
  final bool? isPrimary;
  final int? displayOrder;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    _putNullableTrimmed(data, 'caption', caption);
    _putNullableTrimmed(data, 'altText', altText);
    if (isPrimary != null) data['isPrimary'] = isPrimary;
    if (displayOrder != null) data['displayOrder'] = displayOrder;
    return data;
  }
}

class QuestionAttachmentUploadMetadata {
  const QuestionAttachmentUploadMetadata({
    this.caption,
    this.altText,
    this.isPrimary = false,
    this.displayOrder,
  });

  final String? caption;
  final String? altText;
  final bool isPrimary;
  final int? displayOrder;
}

class QuestionAttachmentOrderItem {
  const QuestionAttachmentOrderItem({
    required this.attachmentId,
    required this.displayOrder,
  });

  final int attachmentId;
  final int displayOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'attachmentId': attachmentId,
      'displayOrder': displayOrder,
    };
  }
}

class QuestionGroupFormData {
  const QuestionGroupFormData(this.values);

  final Map<String, dynamic> values;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);
}

class QuestionGroupQuery {
  const QuestionGroupQuery({
    this.courseId,
    this.chapterId,
    int page = 1,
    int limit = 20,
  }) : page = page < 1 ? 1 : page,
       limit = limit < 1
           ? 1
           : limit > 100
           ? 100
           : limit;

  final int? courseId;
  final int? chapterId;
  final int page;
  final int limit;
}

class QuestionGroupOrderItem {
  const QuestionGroupOrderItem({
    required this.questionId,
    required this.itemOrder,
  });

  final int questionId;
  final int itemOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'questionId': questionId, 'itemOrder': itemOrder};
  }
}

Map<String, dynamic> questionFormDataToJson(Object data) {
  if (data is QuestionFormData) return data.toJson();
  if (data is Map<String, dynamic>) {
    final json = Map<String, dynamic>.from(data);
    _stripQuestionChildResponseFields(json);
    return json;
  }
  throw ArgumentError.value(data, 'data', 'Unsupported question form data');
}

Map<String, dynamic> questionGroupFormDataToJson(Object data) {
  if (data is QuestionGroupFormData) return data.toJson();
  if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
  throw ArgumentError.value(data, 'data', 'Unsupported question group data');
}

void _stripQuestionChildResponseFields(Map<String, dynamic> data) {
  final options = data['options'];
  if (options is List) {
    data['options'] = options
        .whereType<Map<String, dynamic>>()
        .map((item) {
          return <String, dynamic>{
            if (_hasText(item['optionText']?.toString()))
              'optionText': item['optionText'].toString().trim(),
            'isCorrect': item['isCorrect'] == true,
          };
        })
        .toList(growable: false);
  }
  final fillBlanks = data['fillBlanks'];
  if (fillBlanks is List) {
    data['fillBlanks'] = fillBlanks
        .whereType<Map<String, dynamic>>()
        .map((item) {
          return <String, dynamic>{
            if (_hasText(item['blankKey']?.toString()))
              'blankKey': item['blankKey'].toString().trim(),
            if (_hasText(item['acceptableAnswer']?.toString()))
              'acceptableAnswer': item['acceptableAnswer'].toString().trim(),
            'isCaseSensitive': item['isCaseSensitive'] == true,
          };
        })
        .toList(growable: false);
  }
}

void _putNullableTrimmed(Map<String, dynamic> data, String key, Object? value) {
  if (identical(value, _noChange)) return;
  if (value == null) {
    data[key] = null;
    return;
  }
  final text = value.toString().trim();
  data[key] = text.isEmpty ? null : text;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

const Object _noChange = Object();
