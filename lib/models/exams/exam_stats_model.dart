class ExamStatsModel {
  const ExamStatsModel({
    this.drafts = 0,
    this.openDrafts = 0,
    this.expiringSoonDrafts = 0,
    this.savedExams = 0,
    this.publishedExams = 0,
    this.archivedExams = 0,
    this.approvedQuestionPool = 0,
  });

  final int drafts;
  final int openDrafts;
  final int expiringSoonDrafts;
  final int savedExams;
  final int publishedExams;
  final int archivedExams;
  final int approvedQuestionPool;

  factory ExamStatsModel.fromJson(Map<String, dynamic> json) {
    return ExamStatsModel(
      drafts: _toInt(json['drafts']),
      openDrafts: _toInt(json['openDrafts']),
      expiringSoonDrafts: _toInt(json['expiringSoonDrafts']),
      savedExams: _toInt(json['savedExams']),
      publishedExams: _toInt(json['publishedExams']),
      archivedExams: _toInt(json['archivedExams']),
      approvedQuestionPool: _toInt(json['approvedQuestionPool']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
