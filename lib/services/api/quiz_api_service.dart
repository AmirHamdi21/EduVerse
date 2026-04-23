import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/quiz/quiz_api_models.dart';
import 'core_api_client.dart';

/// Production quiz API service — mirrors the NestJS quizzes controller.
/// Uses [CoreApiClient] + [RetryHelper] + [ServiceResult] pattern.
class QuizApiService {
  final CoreApiClient _client;

  QuizApiService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  // ── Quiz CRUD ────────────────────────────────────────────────────────────

  Future<ServiceResult<List<QuizModel>>> getAll({int? courseId}) {
    return RetryHelper.execute<List<QuizModel>>(() async {
      final query = <String, dynamic>{};
      if (courseId != null) query['courseId'] = courseId;

      final response = await _client.dio.get(
        '/quizzes',
        queryParameters: query.isEmpty ? null : query,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(QuizModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load quizzes');
  }

  Future<ServiceResult<QuizModel>> getById(dynamic id) {
    return RetryHelper.execute<QuizModel>(() async {
      final response = await _client.dio.get('/quizzes/$id');
      return QuizModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load quiz details');
  }

  Future<ServiceResult<QuizModel>> create(Map<String, dynamic> data) {
    return RetryHelper.execute<QuizModel>(() async {
      final response = await _client.dio.post('/quizzes', data: data);
      return QuizModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create quiz');
  }

  Future<ServiceResult<QuizModel>> update(
    dynamic id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<QuizModel>(() async {
      final response = await _client.dio.put('/quizzes/$id', data: data);
      return QuizModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update quiz');
  }

  Future<ServiceResult<void>> delete(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/quizzes/$id');
    }, fallbackMessage: 'Failed to delete quiz');
  }

  // ── Questions ────────────────────────────────────────────────────────────

  /// Fetches all questions for a quiz (used when attempt response lacks them).
  Future<ServiceResult<List<QuizQuestionModel>>> getQuizQuestions(
    dynamic quizId,
  ) {
    return RetryHelper.execute<List<QuizQuestionModel>>(() async {
      final response = await _client.dio.get('/quizzes/$quizId/questions');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(QuizQuestionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load quiz questions');
  }


  Future<ServiceResult<QuizQuestionModel>> addQuestion(
    dynamic quizId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<QuizQuestionModel>(() async {
      final response = await _client.dio.post(
        '/quizzes/$quizId/questions',
        data: data,
      );
      return QuizQuestionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to add question');
  }

  Future<ServiceResult<QuizQuestionModel>> updateQuestion(
    dynamic quizId,
    dynamic questionId,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<QuizQuestionModel>(() async {
      final response = await _client.dio.put(
        '/quizzes/$quizId/questions/$questionId',
        data: data,
      );
      return QuizQuestionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update question');
  }

  Future<ServiceResult<void>> deleteQuestion(
    dynamic quizId,
    dynamic questionId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/quizzes/$quizId/questions/$questionId');
    }, fallbackMessage: 'Failed to delete question');
  }

  Future<ServiceResult<void>> reorderQuestions(
    dynamic quizId,
    List<int> questionIds,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.put(
        '/quizzes/$quizId/questions/reorder',
        data: <String, dynamic>{'questionIds': questionIds},
      );
    }, fallbackMessage: 'Failed to reorder questions');
  }

  // ── Attempts (Student) ───────────────────────────────────────────────────

  Future<ServiceResult<QuizAttemptModel>> startAttempt(dynamic quizId) {
    return RetryHelper.execute<QuizAttemptModel>(() async {
      final response = await _client.dio.post(
        '/quizzes/$quizId/attempts/start',
      );
      return QuizAttemptModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to start quiz attempt');
  }

  Future<ServiceResult<AttemptResultModel>> submitAttempt(
    dynamic attemptId,
    List<Map<String, dynamic>> answers,
  ) {
    return RetryHelper.execute<AttemptResultModel>(() async {
      final response = await _client.dio.post(
        '/quizzes/attempts/$attemptId/submit',
        data: <String, dynamic>{'answers': answers},
      );
      return AttemptResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to submit quiz');
  }

  Future<ServiceResult<QuizAttemptModel>> getAttempt(dynamic attemptId) {
    return RetryHelper.execute<QuizAttemptModel>(() async {
      final response = await _client.dio.get(
        '/quizzes/attempts/$attemptId',
      );
      return QuizAttemptModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load attempt');
  }

  Future<ServiceResult<List<QuizAttemptModel>>> getMyAttempts({
    int? quizId,
  }) {
    return RetryHelper.execute<List<QuizAttemptModel>>(() async {
      final query = <String, dynamic>{};
      if (quizId != null) query['quizId'] = quizId;

      final response = await _client.dio.get(
        '/quizzes/my-attempts',
        queryParameters: query.isEmpty ? null : query,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(QuizAttemptModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load your attempts');
  }

  Future<ServiceResult<QuizAttemptModel?>> getInProgressAttempt(
    dynamic quizId,
  ) {
    return RetryHelper.execute<QuizAttemptModel?>(() async {
      final response = await _client.dio.get(
        '/quizzes/my-attempts',
        queryParameters: <String, dynamic>{
          'quizId': quizId,
          'status': 'in_progress',
        },
      );

      final list = _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .toList();
      if (list.isEmpty) return null;
      return QuizAttemptModel.fromJson(list.first);
    }, fallbackMessage: 'Failed to check in-progress attempt');
  }

  Future<ServiceResult<QuizAttemptModel>> saveProgress(
    dynamic quizId,
    dynamic attemptId,
    List<Map<String, dynamic>> answers,
  ) {
    return RetryHelper.execute<QuizAttemptModel>(() async {
      final response = await _client.dio.patch(
        '/quizzes/$quizId/attempts/$attemptId/progress',
        data: <String, dynamic>{'answers': answers},
      );
      return QuizAttemptModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to save progress');
  }

  // ── Attempts (Instructor / TA) ───────────────────────────────────────────

  Future<ServiceResult<List<QuizAttemptModel>>> getAllAttempts({
    int? quizId,
  }) {
    return RetryHelper.execute<List<QuizAttemptModel>>(() async {
      final query = <String, dynamic>{};
      if (quizId != null) query['quizId'] = quizId;

      final response = await _client.dio.get(
        '/quizzes/attempts',
        queryParameters: query.isEmpty ? null : query,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(QuizAttemptModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load attempts');
  }

  Future<ServiceResult<QuizAttemptModel>> gradeAttempt(
    dynamic attemptId,
    List<Map<String, dynamic>> grades,
  ) {
    return RetryHelper.execute<QuizAttemptModel>(() async {
      final response = await _client.dio.post(
        '/quizzes/attempts/$attemptId/grade',
        data: <String, dynamic>{'grades': grades},
      );
      return QuizAttemptModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to grade attempt');
  }

  Future<ServiceResult<Map<String, dynamic>>> getPendingGrading(
    dynamic attemptId,
  ) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.get(
        '/quizzes/attempts/$attemptId/pending-grading',
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to load pending grading');
  }

  // ── Statistics & Progress ────────────────────────────────────────────────

  Future<ServiceResult<QuizStatisticsModel>> getStatistics(dynamic quizId) {
    return RetryHelper.execute<QuizStatisticsModel>(() async {
      final response = await _client.dio.get('/quizzes/$quizId/statistics');
      return QuizStatisticsModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load quiz statistics');
  }

  Future<ServiceResult<CourseProgressModel>> getCourseProgress(
    dynamic courseId,
  ) {
    return RetryHelper.execute<CourseProgressModel>(() async {
      final response = await _client.dio.get(
        '/quizzes/progress/course/$courseId',
      );
      return CourseProgressModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load course progress');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data;
    }
    return <dynamic>[];
  }
}
