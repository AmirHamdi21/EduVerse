import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/ai_service_endpoints.dart';
import '../../models/quiz/quiz_api_models.dart';

/// AI Quiz Generation service — mirrors the web's `quizAiGeneration.ts` 1:1.
///
/// Calls the deployed AI quiz service via a 3-step pipeline:
///   1. `uploadFile()`        → POST /api/v1/upload   → { uploadId }
///   2. `generateQuiz()`      → POST /api/v1/generate → { quizId, status, numQuestions }
///   3. `fetchGeneratedQuiz()`→ GET  /api/v1/quiz/:id → { quizId, questions, answerKey }
///
/// The convenience method `generateQuestions()` runs all 3 in sequence and
/// returns a list of [AiGeneratedQuestion] ready for the quiz builder UI.
class QuizAiService {
  /// Base URL for the deployed AI quiz service.
  /// Kept slash-trimmed so endpoint concatenation stays stable.
  static String get baseUrl => AiServiceEndpoints.aiQuizBaseUrl;

  /// AI question types accepted by the FastAPI endpoint.
  static const List<String> questionTypes = ['MCQ', 'FillBlank', 'Explain'];

  /// Difficulty levels accepted by the FastAPI endpoint.
  static const List<String> difficulties = ['easy', 'medium', 'hard'];

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // Step 1: Upload file
  // Web equivalent: fetch(`${AI_QUIZ_BASE_URL}/api/v1/upload`, ...)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Uploads a file (PDF, DOCX, or TXT) to the AI service.
  /// Returns the `uploadId` needed for generation.
  ///
  /// Throws [Exception] on failure with the backend's `detail` message.
  Future<String> uploadFile(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final Response response;
    try {
      response = await _dio.post('$baseUrl/api/v1/upload', data: formData);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Upload');
    }

    final data = response.data;
    if (data is Map && data.containsKey('uploadId')) {
      return data['uploadId'] as String;
    }

    throw Exception(
      'Upload: ${data is Map ? (data['detail'] ?? 'No uploadId returned') : 'Unexpected response'}',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Step 2: Generate quiz
  // Web equivalent: fetch(`${AI_QUIZ_BASE_URL}/api/v1/generate`, ...)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sends generation parameters to the AI service.
  /// Returns the `quizId` needed to fetch the generated questions.
  ///
  /// Parameters match the FastAPI endpoint exactly:
  /// - [uploadId]: from Step 1
  /// - [numQuestions]: 1–20
  /// - [questionType]: 'MCQ', 'FillBlank', or 'Explain'
  /// - [difficulty]: 'easy', 'medium', or 'hard'
  Future<AiGenerateResult> generateQuiz({
    required String uploadId,
    int numQuestions = 5,
    String questionType = 'MCQ',
    String difficulty = 'medium',
  }) async {
    final formData = FormData.fromMap({
      'uploadId': uploadId,
      'numQuestions': numQuestions.toString(),
      'questionType': questionType,
      'difficulty': difficulty,
      'saveAsFiles': 'false',
    });

    final Response response;
    try {
      response = await _dio.post('$baseUrl/api/v1/generate', data: formData);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Generate');
    }

    final data = response.data;
    if (data is Map && data.containsKey('quizId')) {
      return AiGenerateResult(
        quizId: data['quizId'] as String,
        status: (data['status'] ?? 'completed') as String,
        numQuestions: (data['numQuestions'] is int)
            ? data['numQuestions'] as int
            : int.tryParse(data['numQuestions']?.toString() ?? '0') ?? 0,
      );
    }

    throw Exception(
      'Generate: ${data is Map ? (data['detail'] ?? 'No quizId returned') : 'Unexpected response'}',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Step 3: Fetch generated quiz
  // Web equivalent: fetch(`${AI_QUIZ_BASE_URL}/api/v1/quiz/${quizId}`)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetches the generated quiz payload containing questions and answer key.
  /// Returns the raw [AiQuizPayload] which can be normalized with [normalizeAiRows].
  Future<AiQuizPayload> fetchGeneratedQuiz(String quizId) async {
    final Response response;
    try {
      response = await _dio.get('$baseUrl/api/v1/quiz/$quizId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Fetch quiz');
    }

    final data = response.data;
    if (data is Map && data.containsKey('quizId')) {
      return AiQuizPayload.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception(
      'Fetch quiz: ${data is Map ? (data['detail'] ?? 'Invalid response') : 'Unexpected response'}',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Convenience: Full pipeline (matches web's generateQuestionsFromAiService)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Runs the full 3-step pipeline: upload → generate → fetch → normalize.
  /// Returns a list of [AiGeneratedQuestion] ready for the quiz builder UI.
  Future<List<AiGeneratedQuestion>> generateQuestions({
    required File file,
    int numQuestions = 5,
    String questionType = 'MCQ',
    String difficulty = 'medium',
  }) async {
    // Step 1: Upload file
    final uploadId = await uploadFile(file);

    // Step 2: Generate
    final genResult = await generateQuiz(
      uploadId: uploadId,
      numQuestions: numQuestions,
      questionType: questionType,
      difficulty: difficulty,
    );

    // Step 3: Fetch generated quiz
    final payload = await fetchGeneratedQuiz(genResult.quizId);

    // Step 4: Normalize & map (matches web's normalizeAiRows + mapAiRowsToQuestionForms)
    return normalizeAiRows(payload);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Normalization (matches web's normalizeAiRows)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Normalizes the raw AI payload into a list of [AiGeneratedQuestion].
  /// Mirrors the web's `normalizeAiRows()` function exactly.
  static List<AiGeneratedQuestion> normalizeAiRows(AiQuizPayload payload) {
    final rawQuestions = payload.questions;
    final rawAnswerKey = payload.answerKey;

    // Build answer lookup keyed by "Question N"
    final answersByQ = <String, Map<String, dynamic>>{};
    for (final a in rawAnswerKey) {
      if (a is Map<String, dynamic> && a['questionId'] != null) {
        answersByQ[a['questionId'].toString()] = a;
      }
    }

    final result = <AiGeneratedQuestion>[];
    for (var i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i];
      if (q is! Map<String, dynamic>) continue;

      final qId = 'Question ${i + 1}';
      final ans = answersByQ[qId];
      final type = (q['type'] ?? 'MCQ') as String;
      final question = (q['question'] ?? '') as String;
      final rawOpts = q['options'];
      final options = rawOpts is List
          ? rawOpts.map((e) => e.toString()).toList()
          : <String>[];
      final answer = (ans?['correctAnswer'] ?? ans?['answer'] ?? '') as String;
      final reference = (ans?['reference'] ?? '') as String;

      result.add(
        AiGeneratedQuestion(
          type: type,
          questionText: question,
          options: options,
          correctAnswer: answer,
          reference: reference,
        ),
      );
    }
    return result;
  }

  // ── Error handling ──────────────────────────────────────────────────────

  Exception _handleDioError(DioException e, String step) {
    // Empty response (service down, 502, etc.)
    final responseData = e.response?.data;
    if (responseData == null || responseData.toString().trim().isEmpty) {
      return Exception(
        '$step: empty response (HTTP ${e.response?.statusCode ?? 'N/A'}). '
        'Make sure the AI quiz service is reachable at $baseUrl.',
      );
    }

    // JSON error detail from FastAPI
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) {
      return Exception('$step: ${data['detail']}');
    }

    // Connection errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception(
        '$step: Could not connect to AI quiz service at $baseUrl. '
        'Make sure the deployed AI quiz service is available.',
      );
    }

    return Exception('$step: ${e.message ?? 'Unknown error'}');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Response Models
// ═════════════════════════════════════════════════════════════════════════════

/// Result from Step 2 (generate).
class AiGenerateResult {
  final String quizId;
  final String status;
  final int numQuestions;

  const AiGenerateResult({
    required this.quizId,
    this.status = 'completed',
    this.numQuestions = 0,
  });
}

/// Raw payload from Step 3 (fetch quiz).
/// Contains the questions array and answer key from the AI service.
class AiQuizPayload {
  final String quizId;
  final String? uploadId;
  final String? questionType;
  final String? difficulty;
  final List<dynamic> questions;
  final List<dynamic> answerKey;

  const AiQuizPayload({
    required this.quizId,
    this.uploadId,
    this.questionType,
    this.difficulty,
    this.questions = const [],
    this.answerKey = const [],
  });

  factory AiQuizPayload.fromJson(Map<String, dynamic> json) {
    return AiQuizPayload(
      quizId: (json['quizId'] ?? '') as String,
      uploadId: json['uploadId'] as String?,
      questionType: json['questionType'] as String?,
      difficulty: json['difficulty'] as String?,
      questions: (json['questions'] as List?) ?? [],
      answerKey: (json['answerKey'] as List?) ?? [],
    );
  }
}

/// Represents a single question generated by the AI service.
/// Mirrors the web's `NormalizedAiRow` type.
class AiGeneratedQuestion {
  /// AI question type: 'MCQ', 'FillBlank', or 'Explain'
  final String type;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String reference;

  const AiGeneratedQuestion({
    required this.type,
    required this.questionText,
    this.options = const [],
    this.correctAnswer = '',
    this.reference = '',
  });

  /// Maps this AI question type to the backend-native [QuestionTypeEnum].
  /// MCQ → multipleChoice, FillBlank → shortAnswer, Explain → essay
  QuestionTypeEnum get mappedType {
    switch (type) {
      case 'MCQ':
        return QuestionTypeEnum.multipleChoice;
      case 'FillBlank':
        return QuestionTypeEnum.shortAnswer;
      case 'Explain':
        return QuestionTypeEnum.essay;
      default:
        return QuestionTypeEnum.multipleChoice;
    }
  }

  /// Pads MCQ options to at least 4 choices.
  /// Mirrors the web's `padMcqOptions()` function.
  List<String> get paddedOptions {
    final filtered = options.where((e) => e.trim().isNotEmpty).toList();
    while (filtered.length < 4) {
      filtered.add('Option ${String.fromCharCode(65 + filtered.length)}');
    }
    return filtered.take(8).toList();
  }

  /// Guesses the correct MCQ answer index from letter-style answers ('A', 'B', etc.)
  /// or from the full option text.
  /// Mirrors the web's `guessMcqAnswerIndex()` function.
  ///
  /// Returns the index as a String (e.g. '0', '1', '2', '3').
  String guessMcqAnswerIndex() {
    final cleaned = correctAnswer.trim().toUpperCase();

    // Direct letter match: A→0, B→1, C→2, D→3
    const letterMap = {
      'A': 0,
      'B': 1,
      'C': 2,
      'D': 3,
      'E': 4,
      'F': 5,
      'G': 6,
      'H': 7,
    };
    if (letterMap.containsKey(cleaned) &&
        letterMap[cleaned]! < options.length) {
      return letterMap[cleaned]!.toString();
    }

    // Try prefix match like "A) ..."
    for (var i = 0; i < options.length; i++) {
      if (options[i].trim().toUpperCase().startsWith('$cleaned)')) {
        return i.toString();
      }
    }

    // Fallback: try exact text match
    for (var i = 0; i < options.length; i++) {
      if (options[i].trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase()) {
        return i.toString();
      }
    }

    return '0';
  }

  /// For MCQ: returns the actual option text of the correct answer.
  /// For other types: returns the raw correctAnswer string.
  String get resolvedCorrectAnswer {
    if (type != 'MCQ') return correctAnswer;

    final idx = int.tryParse(guessMcqAnswerIndex());
    if (idx != null && idx >= 0 && idx < paddedOptions.length) {
      return paddedOptions[idx];
    }
    return options.isNotEmpty ? options.first : '';
  }
}
