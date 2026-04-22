import '../../models/discussion/discussion_models.dart';
import 'core_api_client.dart';

class DiscussionDetailResult {
  final DiscussionThread thread;
  final DiscussionReplyPage replies;

  const DiscussionDetailResult({required this.thread, required this.replies});
}

abstract class IDiscussionService {
  Future<DiscussionThreadPage> getThreads({
    int? courseId,
    int page = 1,
    int limit = 20,
  });

  Future<DiscussionDetailResult> getThreadDetail(
    int threadId, {
    int page = 1,
    int limit = 20,
  });

  Future<DiscussionThread> createThread({
    required int courseId,
    required String title,
    required String description,
  });

  Future<DiscussionThread> updateThread({
    required int threadId,
    required String title,
    required String description,
  });

  Future<void> deleteThread(int threadId);

  Future<DiscussionReply> postReply({
    required int threadId,
    required String messageText,
    int? parentMessageId,
  });

  Future<DiscussionReply> updateReply({
    required int replyId,
    required String messageText,
  });

  Future<void> deleteReply(int replyId);

  Future<void> togglePin(int threadId);

  Future<void> toggleLock(int threadId);

  Future<void> markAnswer(int replyId);

  Future<void> endorseReply(int replyId);
}

class DiscussionService implements IDiscussionService {
  final CoreApiClient _client;

  DiscussionService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  @override
  Future<DiscussionThreadPage> getThreads({
    int? courseId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/discussions',
      queryParameters: {
        if (courseId != null) 'courseId': courseId,
        'page': page,
        'limit': limit,
      },
    );

    final payload = _asMap(response.data);
    final data = _extractDataNode(payload);
    final list = _extractList(data ?? payload);
    final threads = list
        .map((item) => DiscussionThread.fromJson(_normalizeThreadJson(item)))
        .toList(growable: false);

    return DiscussionThreadPage(
      data: _sortPinnedFirst(threads),
      meta: _extractMeta(
        root: payload,
        fallbackPage: page,
        fallbackLimit: limit,
        resultLength: threads.length,
      ),
    );
  }

  @override
  Future<DiscussionDetailResult> getThreadDetail(
    int threadId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/discussions/$threadId',
      queryParameters: {'page': page, 'limit': limit},
    );

    final payload = _asMap(response.data);
    final data = _extractDataNode(payload) ?? payload;

    final rawThread = _asMap(data['thread'] ?? data);
    final rawRepliesContainer = _asMap(data['replies']);

    final thread = DiscussionThread.fromJson(_normalizeThreadJson(rawThread));

    final replyList = _extractList(
      rawRepliesContainer.isEmpty ? data['replies'] : rawRepliesContainer,
    );

    final replies = replyList
        .map(
          (item) =>
              DiscussionReply.fromJson(_normalizeReplyJson(item, thread.id)),
        )
        .toList(growable: false);

    final meta = _extractMeta(
      root: rawRepliesContainer.isNotEmpty ? rawRepliesContainer : payload,
      fallbackPage: page,
      fallbackLimit: limit,
      resultLength: replies.length,
    );

    return DiscussionDetailResult(
      thread: thread,
      replies: DiscussionReplyPage(data: replies, meta: meta),
    );
  }

  @override
  Future<DiscussionThread> createThread({
    required int courseId,
    required String title,
    required String description,
  }) async {
    final response = await _client.dio.post(
      '/discussions',
      data: {'courseId': courseId, 'title': title, 'description': description},
    );

    final map = _extractModelPayload(response.data);
    return DiscussionThread.fromJson(_normalizeThreadJson(map));
  }

  @override
  Future<DiscussionThread> updateThread({
    required int threadId,
    required String title,
    required String description,
  }) async {
    final response = await _client.dio.put(
      '/discussions/$threadId',
      data: {'title': title, 'description': description},
    );

    final map = _extractModelPayload(response.data);
    return DiscussionThread.fromJson(_normalizeThreadJson(map));
  }

  @override
  Future<void> deleteThread(int threadId) async {
    await _client.dio.delete('/discussions/$threadId');
  }

  @override
  Future<DiscussionReply> postReply({
    required int threadId,
    required String messageText,
    int? parentMessageId,
  }) async {
    final response = await _client.dio.post(
      '/discussions/$threadId/reply',
      data: {
        'messageText': messageText,
        if (parentMessageId != null) 'parentMessageId': parentMessageId,
      },
    );

    final map = _extractModelPayload(response.data);
    return DiscussionReply.fromJson(_normalizeReplyJson(map, threadId));
  }

  @override
  Future<DiscussionReply> updateReply({
    required int replyId,
    required String messageText,
  }) async {
    final response = await _client.dio.put(
      '/discussions/replies/$replyId',
      data: {'messageText': messageText},
    );

    final map = _extractModelPayload(response.data);
    return DiscussionReply.fromJson(_normalizeReplyJson(map, null));
  }

  @override
  Future<void> deleteReply(int replyId) async {
    await _client.dio.delete('/discussions/replies/$replyId');
  }

  @override
  Future<void> togglePin(int threadId) async {
    await _client.dio.patch('/discussions/$threadId/pin');
  }

  @override
  Future<void> toggleLock(int threadId) async {
    await _client.dio.patch('/discussions/$threadId/lock');
  }

  @override
  Future<void> markAnswer(int replyId) async {
    await _client.dio.patch('/discussions/replies/$replyId/mark-answer');
  }

  @override
  Future<void> endorseReply(int replyId) async {
    await _client.dio.patch('/discussions/replies/$replyId/endorse');
  }

  List<DiscussionThread> _sortPinnedFirst(List<DiscussionThread> threads) {
    final sorted = [...threads];
    sorted.sort((a, b) {
      final pinnedCompare = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
      if (pinnedCompare != 0) {
        return pinnedCompare;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  Map<String, dynamic>? _extractDataNode(Map<String, dynamic> payload) {
    final directData = payload['data'];
    if (directData is Map<String, dynamic>) {
      return directData;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) {
      return payload.map(_asMap).where((item) => item.isNotEmpty).toList();
    }

    final map = _asMap(payload);

    for (final key in const ['data', 'items', 'threads', 'replies']) {
      final value = map[key];
      if (value is List) {
        return value.map(_asMap).where((item) => item.isNotEmpty).toList();
      }
      if (value is Map<String, dynamic> && value['data'] is List) {
        return _extractList(value['data']);
      }
    }

    return const <Map<String, dynamic>>[];
  }

  PaginationMeta _extractMeta({
    required Map<String, dynamic> root,
    required int fallbackPage,
    required int fallbackLimit,
    required int resultLength,
  }) {
    final candidates = <Map<String, dynamic>>[
      root,
      _asMap(root['meta']),
      _asMap(root['pagination']),
      _asMap(_asMap(root['data'])['meta']),
      _asMap(_asMap(root['data'])['pagination']),
    ];

    for (final candidate in candidates) {
      if (candidate.isEmpty) {
        continue;
      }
      final page =
          _asInt(candidate['page']) ?? _asInt(candidate['currentPage']);
      final limit =
          _asInt(candidate['limit']) ??
          _asInt(candidate['pageSize']) ??
          _asInt(candidate['perPage']);
      final total =
          _asInt(candidate['total']) ?? _asInt(candidate['totalItems']);
      final hasMore =
          _asBool(candidate['hasMore']) ??
          _asBool(candidate['hasNext']) ??
          ((page != null && limit != null && total != null)
              ? page * limit < total
              : null);

      if (page != null || limit != null || total != null || hasMore != null) {
        return PaginationMeta(
          page: page ?? fallbackPage,
          limit: limit ?? fallbackLimit,
          total: total ?? resultLength,
          hasMore: hasMore ?? resultLength >= fallbackLimit,
        );
      }
    }

    return PaginationMeta(
      page: fallbackPage,
      limit: fallbackLimit,
      total: resultLength,
      hasMore: resultLength >= fallbackLimit,
    );
  }

  Map<String, dynamic> _extractModelPayload(dynamic payload) {
    final map = _asMap(payload);
    final dataMap = _asMap(map['data']);
    if (dataMap.isNotEmpty) {
      return dataMap;
    }
    return map;
  }

  /// Safely coerce a value that might be a String into an int (or null).
  /// Returns the value unchanged if it is already an int/num, or converts
  /// a String representation to int. Returns null for anything else.
  dynamic _coerceInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return value; // leave as-is for non-numeric types (e.g. Map for createdBy)
  }

  /// Safely coerce a value that might be a tinyint (0/1) into a Dart bool.
  /// MySQL tinyint columns come back as integers 0 or 1, but freezed expects
  /// a bool. Without this conversion, `json['isPinned'] as bool?` throws
  /// "type 'int' is not a subtype of type 'bool?' in type cast".
  dynamic _coerceBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is num) return value != 0;
    final s = value.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return value;
  }

  Map<String, dynamic> _normalizeThreadJson(Map<String, dynamic> source) {
    final normalized = Map<String, dynamic>.from(source);

    if (!normalized.containsKey('description') &&
        normalized.containsKey('content')) {
      normalized['description'] = normalized['content'];
    }
    if (!normalized.containsKey('courseId') &&
        normalized.containsKey('forumId')) {
      normalized['courseId'] = normalized['forumId'];
    }

    final createdBy = normalized['createdBy'];
    if (createdBy is Map<String, dynamic>) {
      normalized['createdByName'] =
          createdBy['fullName'] ??
          createdBy['name'] ??
          createdBy['displayName'] ??
          createdBy['email'];
      normalized['createdBy'] = createdBy['userId'] ?? createdBy['id'] ?? 0;
    }

    if (!normalized.containsKey('createdByName')) {
      final user = _asMap(normalized['user']);
      normalized['createdByName'] =
          user['fullName'] ?? user['name'] ?? user['displayName'] ?? '';
    }

    // Coerce all numeric fields that freezed expects as num/int.
    // The backend may return these as strings (e.g. "5" instead of 5),
    // which causes "type String is not a subtype of type num" at runtime.
    for (final key in const [
      'id',
      'courseId',
      'createdBy',
      'viewCount',
      'replyCount',
    ]) {
      if (normalized.containsKey(key)) {
        normalized[key] = _coerceInt(normalized[key]);
      }
    }

    // Coerce tinyint → bool for boolean fields.
    // MySQL tinyint columns return 0/1 as int, but freezed expects bool.
    for (final key in const ['isPinned', 'isLocked']) {
      if (normalized.containsKey(key)) {
        normalized[key] = _coerceBool(normalized[key]);
      }
    }

    return normalized;
  }

  Map<String, dynamic> _normalizeReplyJson(
    Map<String, dynamic> source,
    int? fallbackThreadId,
  ) {
    final normalized = Map<String, dynamic>.from(source);

    if (!normalized.containsKey('messageText') &&
        normalized.containsKey('message')) {
      normalized['messageText'] = normalized['message'];
    }
    if (!normalized.containsKey('messageText') &&
        normalized.containsKey('content')) {
      normalized['messageText'] = normalized['content'];
    }

    if (!normalized.containsKey('threadId') && fallbackThreadId != null) {
      normalized['threadId'] = fallbackThreadId;
    }

    final author = _asMap(normalized['author']);
    if (author.isNotEmpty) {
      normalized['userId'] =
          author['userId'] ?? author['id'] ?? normalized['userId'];
      normalized['userName'] =
          author['fullName'] ??
          author['name'] ??
          author['displayName'] ??
          normalized['userName'];
    }

    final createdBy = normalized['createdBy'];
    if (createdBy is Map<String, dynamic>) {
      normalized['userId'] =
          createdBy['userId'] ?? createdBy['id'] ?? normalized['userId'];
      normalized['userName'] =
          createdBy['fullName'] ??
          createdBy['name'] ??
          createdBy['displayName'] ??
          normalized['userName'];
    }

    // Coerce all numeric fields that freezed expects as num/int.
    for (final key in const [
      'id',
      'threadId',
      'userId',
      'parentMessageId',
      'endorsedBy',
    ]) {
      if (normalized.containsKey(key)) {
        normalized[key] = _coerceInt(normalized[key]);
      }
    }

    // Coerce tinyint → bool for boolean fields.
    for (final key in const ['isAnswer', 'isEndorsed']) {
      if (normalized.containsKey(key)) {
        normalized[key] = _coerceBool(normalized[key]);
      }
    }

    return normalized;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool? _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value == 1;
    }
    final normalized = value?.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return null;
  }
}
