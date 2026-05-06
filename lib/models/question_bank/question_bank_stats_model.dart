class QuestionBankStatsModel {
  const QuestionBankStatsModel({
    this.total = 0,
    this.draft = 0,
    this.underReview = 0,
    this.approved = 0,
    this.rejected = 0,
    this.archived = 0,
    this.attached = 0,
    this.grouped = 0,
  });

  final int total;
  final int draft;
  final int underReview;
  final int approved;
  final int rejected;
  final int archived;
  final int attached;
  final int grouped;

  int get attachedOrGrouped => attached + grouped;

  factory QuestionBankStatsModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankStatsModel(
      total: _toInt(json['total']),
      draft: _toInt(json['draft']),
      underReview: _toInt(json['underReview']),
      approved: _toInt(json['approved']),
      rejected: _toInt(json['rejected']),
      archived: _toInt(json['archived']),
      attached: _toInt(json['attached']),
      grouped: _toInt(json['grouped']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
