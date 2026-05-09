class QuestionBankOptionModel {
  const QuestionBankOptionModel({
    this.id,
    required this.optionText,
    required this.isCorrect,
  });

  final int? id;
  final String optionText;
  final bool isCorrect;

  factory QuestionBankOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankOptionModel(
      id: _nullableInt(json['id'] ?? json['optionId']),
      optionText: json['optionText']?.toString() ?? '',
      isCorrect: _toBool(json['isCorrect']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'optionText': optionText,
      'isCorrect': isCorrect,
    };
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{'optionText': optionText, 'isCorrect': isCorrect};
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
