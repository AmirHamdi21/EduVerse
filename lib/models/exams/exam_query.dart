import '../instructor/question_bank_exam_models.dart';

class ExamQuery {
  const ExamQuery({this.courseId, this.status, int page = 1, int limit = 20})
    : page = page < 1 ? 1 : page,
      limit = limit < 1
          ? 1
          : limit > 100
          ? 100
          : limit;

  final int? courseId;
  final ExamStatus? status;
  final int page;
  final int limit;
}

class ExamDraftQuery {
  const ExamDraftQuery({
    this.courseId,
    this.status,
    int page = 1,
    int limit = 20,
  }) : page = page < 1 ? 1 : page,
       limit = limit < 1
           ? 1
           : limit > 100
           ? 100
           : limit;

  final int? courseId;
  final ExamDraftStatus? status;
  final int page;
  final int limit;
}
