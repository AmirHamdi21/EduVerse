import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/quiz/quiz_api_models.dart';
import '../../services/api/quiz_api_service.dart';
import 'student_quiz_state.dart';

/// Manages the student quiz-taking lifecycle:
/// listing, starting, answering, auto-saving, submitting, and viewing results.
class StudentQuizCubit extends Cubit<StudentQuizState> {
  final QuizApiService _service;
  Timer? _autoSaveTimer;

  StudentQuizCubit({required QuizApiService quizApiService})
    : _service = quizApiService,
      super(const StudentQuizInitial());

  // ── List quizzes ─────────────────────────────────────────────────────────

  Future<void> loadQuizzes() async {
    emit(const StudentQuizLoading());

    final quizzesResult = await _service.getAll();
    if (quizzesResult.isFailure) {
      emit(
        StudentQuizError(
          quizzesResult.error?.message ?? 'Failed to load quizzes',
        ),
      );
      return;
    }

    final attemptsResult = await _service.getMyAttempts();
    final attempts = attemptsResult.isSuccess
        ? (attemptsResult.data ?? <QuizAttemptModel>[])
        : <QuizAttemptModel>[];

    // Only show published quizzes to students
    final publishedQuizzes = (quizzesResult.data ?? [])
        .where((q) => q.status == QuizStatusEnum.published)
        .toList();

    emit(StudentQuizzesLoaded(quizzes: publishedQuizzes, myAttempts: attempts));
  }

  // ── Filters ──────────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    final current = state;
    if (current is StudentQuizzesLoaded) {
      emit(current.copyWith(searchQuery: query));
    }
  }

  void setStatusFilter(String status) {
    final current = state;
    if (current is StudentQuizzesLoaded) {
      emit(current.copyWith(statusFilter: status));
    }
  }

  // ── Start quiz ───────────────────────────────────────────────────────────
  // Mirrors the web's QuizzesTab.handleStartQuiz flow:
  // 1. Fetch full quiz (gets questions)  2. Check in-progress  3. Start/resume

  Future<void> startQuiz(int quizId) async {
    emit(const StudentQuizStarting());

    // 1. Fetch full quiz with questions (the web always does this first)
    final quizResult = await _service.getById(quizId);
    if (quizResult.isFailure) {
      emit(
        StudentQuizError(
          quizResult.error?.message ?? 'Failed to load quiz details',
        ),
      );
      return;
    }
    final fullQuiz = quizResult.data!;
    final effectiveTimeLimit =
        (fullQuiz.timeLimitMinutes != null && fullQuiz.timeLimitMinutes! > 0)
        ? fullQuiz.timeLimitMinutes
        : null;

    // 2. Check for existing in-progress attempt
    final ipResult = await _service.getInProgressAttempt(quizId);

    QuizAttemptModel attempt;
    Map<int, AttemptAnswerModel> savedAnswers = {};
    DateTime activeStartedAt = DateTime.now();

    if (ipResult.isSuccess && ipResult.data != null) {
      attempt = ipResult.data!;

      final shouldRestartAttempt =
          attempt.status != AttemptStatusEnum.inProgress ||
          (effectiveTimeLimit != null &&
              attempt.startedAt != null &&
              DateTime.now().difference(attempt.startedAt!).inSeconds >=
                  effectiveTimeLimit * 60);

      if (shouldRestartAttempt) {
        // Attempt is stale/expired — request a fresh start from backend.
        final newResult = await _service.startAttempt(quizId);
        if (newResult.isFailure) {
          emit(
            StudentQuizError(
              newResult.error?.message ?? 'Failed to start new attempt',
            ),
          );
          return;
        }
        attempt = newResult.data!;
        savedAnswers = {};

        // Match web behavior: restarted attempt always gets a fresh local timer window.
        activeStartedAt = DateTime.now();
      } else {
        // Restore saved answers from the existing attempt.
        for (final a in attempt.answers) {
          savedAnswers[a.questionId] = a;
        }
        activeStartedAt = attempt.startedAt ?? DateTime.now();
      }
    } else {
      // 3. Start new attempt
      final startResult = await _service.startAttempt(quizId);
      if (startResult.isFailure) {
        emit(
          StudentQuizError(
            startResult.error?.message ?? 'Failed to start quiz',
          ),
        );
        return;
      }
      attempt = startResult.data!;
      // Match web behavior: a newly started attempt always begins with full time.
      activeStartedAt = DateTime.now();
    }

    // Get questions: prefer attempt payload, then full quiz payload, then fallback endpoint.
    var questions = _extractQuestions(attempt);
    if (questions.isEmpty) {
      questions = fullQuiz.questions ?? [];
    }
    if (questions.isEmpty) {
      final qResult = await _service.getQuizQuestions(quizId);
      if (qResult.isSuccess && qResult.data != null) {
        questions = qResult.data!;
      }
    }

    // Guard: no questions available
    if (questions.isEmpty) {
      emit(
        const StudentQuizError(
          'This quiz has no questions yet. Please try again later.',
        ),
      );
      return;
    }

    emit(
      StudentQuizActive(
        attempt: attempt,
        questions: questions,
        answers: savedAnswers,
        timeLimitMinutes: effectiveTimeLimit,
        startedAt: activeStartedAt,
      ),
    );

    _startAutoSave();
  }

  List<QuizQuestionModel> _extractQuestions(QuizAttemptModel attempt) {
    if (attempt.questions != null && attempt.questions!.isNotEmpty) {
      return attempt.questions!;
    }
    final nested = attempt.quiz?.questions;
    if (nested != null && nested.isNotEmpty) {
      return nested;
    }
    return <QuizQuestionModel>[];
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void nextQuestion() {
    final current = state;
    if (current is StudentQuizActive && current.canGoNext) {
      emit(
        current.copyWith(
          currentQuestionIndex: current.currentQuestionIndex + 1,
        ),
      );
    }
  }

  void previousQuestion() {
    final current = state;
    if (current is StudentQuizActive && current.canGoPrevious) {
      emit(
        current.copyWith(
          currentQuestionIndex: current.currentQuestionIndex - 1,
        ),
      );
    }
  }

  void goToQuestion(int index) {
    final current = state;
    if (current is StudentQuizActive &&
        index >= 0 &&
        index < current.questions.length) {
      emit(current.copyWith(currentQuestionIndex: index));
    }
  }

  // ── Answering ────────────────────────────────────────────────────────────

  void submitAnswer(
    int questionId, {
    String? selectedOption,
    String? text,
    List<Map<String, String>>? matchingAnswers,
  }) {
    final current = state;
    if (current is! StudentQuizActive) return;

    final updated = Map<int, AttemptAnswerModel>.from(current.answers);
    updated[questionId] = AttemptAnswerModel(
      questionId: questionId,
      selectedOption: selectedOption,
      answerText: text,
      matchingAnswers: matchingAnswers ?? const [],
    );

    emit(current.copyWith(answers: updated));
  }

  // ── Auto-save ────────────────────────────────────────────────────────────

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => saveProgress(),
    );
  }

  Future<void> saveProgress() async {
    final current = state;
    if (current is! StudentQuizActive) return;
    if (current.answers.isEmpty) return;

    final answersPayload = current.answers.values
        .map((a) => a.toJson())
        .toList();

    await _service.saveProgress(
      current.attempt.quizId,
      current.attempt.id,
      answersPayload,
    );
  }

  // ── Submit quiz ──────────────────────────────────────────────────────────

  Future<void> submitQuiz() async {
    final current = state;
    if (current is! StudentQuizActive) return;

    _autoSaveTimer?.cancel();
    emit(const StudentQuizSubmitting());

    final answersPayload = current.answers.values
        .map((a) => a.toJson())
        .toList();

    final result = await _service.submitAttempt(
      current.attempt.id,
      answersPayload,
    );

    if (result.isFailure) {
      emit(StudentQuizError(result.error?.message ?? 'Failed to submit quiz'));
      return;
    }

    emit(
      StudentQuizResultLoaded(result: result.data!, quiz: current.attempt.quiz),
    );
  }

  // ── View past result ─────────────────────────────────────────────────────

  Future<void> viewAttemptResult(int attemptId) async {
    emit(const StudentQuizLoading());

    final result = await _service.getAttempt(attemptId);
    if (result.isFailure) {
      emit(
        StudentQuizError(
          result.error?.message ?? 'Failed to load attempt result',
        ),
      );
      return;
    }

    final attempt = result.data!;
    emit(
      StudentQuizResultLoaded(
        result: AttemptResultModel(
          attemptId: attempt.id,
          quizId: attempt.quizId,
          score: attempt.scoreObtained,
          maxScore: attempt.maxScore,
          percentage: attempt.scorePercentage,
          passed: attempt.scorePercentage >= (attempt.quiz?.passingScore ?? 50),
        ),
        quiz: attempt.quiz,
      ),
    );
  }

  // ── Back to list ─────────────────────────────────────────────────────────

  void backToList() => loadQuizzes();

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
