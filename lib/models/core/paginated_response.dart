class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final rawData = json['data'];
    final rawMeta = json['meta'];

    final data = rawData is List
        ? rawData
              .whereType<Map<String, dynamic>>()
              .map<T>(itemFromJson)
              .toList()
        : <T>[];

    final meta = rawMeta is Map<String, dynamic>
        ? rawMeta
        : <String, dynamic>{};

    return PaginatedResponse<T>(
      data: data,
      total: _parseInt(meta['total']),
      page: _parseInt(meta['page'], fallback: 1),
      limit: _parseInt(meta['limit'], fallback: 10),
      totalPages: _parseInt(meta['totalPages'], fallback: 1),
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
