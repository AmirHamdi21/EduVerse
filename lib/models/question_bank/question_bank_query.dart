import '../instructor/question_bank_exam_models.dart';

class QuestionBankQuery {
  const QuestionBankQuery({
    this.courseId,
    this.chapterId,
    this.groupId,
    this.questionType,
    this.difficulty,
    this.bloomLevel,
    this.status,
    this.search,
    this.hasAttachments,
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
  final int? groupId;
  final QuestionBankQuestionType? questionType;
  final QuestionBankDifficulty? difficulty;
  final QuestionBankBloomLevel? bloomLevel;
  final QuestionBankStatus? status;
  final String? search;
  final bool? hasAttachments;
  final int page;
  final int limit;
}

class QuestionBankListResponse<T> {
  const QuestionBankListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<T> data;
  final int total;
  final int page;
  final int limit;

  int get totalPages => total == 0 ? 0 : ((total + limit - 1) ~/ limit);
}
