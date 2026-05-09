import 'question_bank_question_model.dart';

class QuestionBankPageModel {
  const QuestionBankPageModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<QuestionBankQuestionModel> data;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;

  factory QuestionBankPageModel.fromJson(
    Map<String, dynamic> json, {
    int page = 1,
    int limit = 20,
  }) {
    return QuestionBankPageModel(
      data: (json['data'] is List ? json['data'] as List : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(QuestionBankQuestionModel.fromJson)
          .toList(),
      total: _toInt(json['total']),
      page: page,
      limit: limit,
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
