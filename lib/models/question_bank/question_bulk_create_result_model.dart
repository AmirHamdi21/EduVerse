import 'question_bank_question_model.dart';

class QuestionBulkCreateFailureModel {
  const QuestionBulkCreateFailureModel({
    required this.rowIndex,
    required this.message,
  });

  final int rowIndex;
  final String message;

  factory QuestionBulkCreateFailureModel.fromJson(Map<String, dynamic> json) {
    return QuestionBulkCreateFailureModel(
      rowIndex: _toInt(json['rowIndex']),
      message: json['message']?.toString() ?? 'Question could not be created',
    );
  }
}

class QuestionBulkCreateResultModel {
  const QuestionBulkCreateResultModel({
    required this.created,
    required this.failed,
  });

  final List<QuestionBankQuestionModel> created;
  final List<QuestionBulkCreateFailureModel> failed;

  bool get hasFailures => failed.isNotEmpty;

  factory QuestionBulkCreateResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionBulkCreateResultModel(
      created: _asList(json['created'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList(),
      failed: _asList(json['failed'])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBulkCreateFailureModel.fromJson)
          .toList(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const <dynamic>[];
}
