class ExamPageModel<T> {
  const ExamPageModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory ExamPageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return ExamPageModel<T>(
      data: (json['data'] is List ? json['data'] as List : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList(),
      total: _toInt(meta['total']),
      page: _toInt(meta['page']),
      limit: _toInt(meta['limit']),
      totalPages: _toInt(meta['totalPages']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
