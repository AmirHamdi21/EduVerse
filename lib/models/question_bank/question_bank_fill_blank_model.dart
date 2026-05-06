class QuestionBankFillBlankModel {
  const QuestionBankFillBlankModel({
    this.id,
    required this.blankKey,
    required this.acceptableAnswer,
    this.isCaseSensitive = false,
  });

  final int? id;
  final String blankKey;
  final String acceptableAnswer;
  final bool isCaseSensitive;

  factory QuestionBankFillBlankModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankFillBlankModel(
      id: _nullableInt(json['id'] ?? json['blankId']),
      blankKey: json['blankKey']?.toString() ?? '',
      acceptableAnswer: json['acceptableAnswer']?.toString() ?? '',
      isCaseSensitive: _toBool(json['isCaseSensitive']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'blankKey': blankKey,
      'acceptableAnswer': acceptableAnswer,
      'isCaseSensitive': isCaseSensitive,
    };
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'blankKey': blankKey,
      'acceptableAnswer': acceptableAnswer,
      'isCaseSensitive': isCaseSensitive,
    };
  }
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}
