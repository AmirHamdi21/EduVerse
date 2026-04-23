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
      emit(StudentQuizError(
        quizzesResult.error?.message ?? 'Failed to load quizzes',
      ));
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

    emit(StudentQuizzesLoaded(
      quizzes: publishedQuizzes,
      myAttempts: attempts,
    ));
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

  Future<void> startQuiz(int quizId) async {
    emit(const StudentQuizStarting());

    // Check for in-progress attempt first
    final ipResult = await _service.getInProgressAttempt(quizId);
    if (ipResult.isSuccess && ipResult.data != null) {
      final attempt = ipResult.data!;
      _emitActiveState(attempt);
      return;
    }

    // Start new attempt
    final result = await _service.startAttempt(quizId);
    if (result.isFailure) {
      emit(StudentQuizError(
        result.error?.message ?? 'Failed to start quiz',
      ));
      return;
    }

    _emitActiveState(result.data!);
  }

  Future<void> _emitActiveState(QuizAttemptModel attempt) async {
    var questions = attempt.questions ?? [];

    // If the attempt response didn't include questions, fetch them separately
    if (questions.isEmpty) {
      final qResult = await _service.getQuizQuestions(attempt.quizId);
      if (qResult.isSuccess && qResult.data != null && qResult.data!.isNotEmpty) {
        questions = qResult.data!;
      }
    }

    // Guard: if still no questions, emit error instead of crashing
    if (questions.isEmpty) {
      emit(const StudentQuizError(
        'This quiz has no questions yet. Please try again later.',
      ));
      return;
    }

    final existingAnswers = <int, AttemptAnswerModel>{};
    for (final a in attempt.answers) {
      existingAnswers[a.questionId] = a;
    }

    emit(StudentQuizActive(
      attempt: attempt,
      questions: questions,
      answers: existingAnswers,
      timeLimitMinutes: attempt.quiz?.timeLimitMinutes,
      startedAt: attempt.startedAt ?? DateTime.now(),
    ));

    _startAutoSave();
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void nextQuestion() {
    final current = state;
    if (current is StudentQuizActive && current.canGoNext) {
      emit(current.copyWith(
        currentQuestionIndex: current.currentQuestionIndex + 1,
      ));
    }
  }

  void previousQuestion() {
    final current = state;
    if (current is StudentQuizActive && current.canGoPrevious) {
      emit(current.copyWith(
        currentQuestionIndex: current.currentQuestionIndex - 1,
      ));
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

  void submitAnswer(int questionId, {String? selectedOption, String? text}) {
    final current = state;
    if (current is! StudentQuizActive) return;

    final updated = Map<int, AttemptAnswerModel>.from(current.answers);
    updated[questionId] = AttemptAnswerModel(
      questionId: questionId,
      selectedOption: selectedOption,
      answerText: text,
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
      emit(StudentQuizError(
        result.error?.message ?? 'Failed to submit quiz',
      ));
      return;
    }

    emit(StudentQuizResultLoaded(
      result: result.data!,
      quiz: current.attempt.quiz,
    ));
  }

  // ── View past result ─────────────────────────────────────────────────────

  Future<void> viewAttemptResult(int attemptId) async {
    emit(const StudentQuizLoading());

    final result = await _service.getAttempt(attemptId);
    if (result.isFailure) {
      emit(StudentQuizError(
        result.error?.message ?? 'Failed to load attempt result',
      ));
      return;
    }

    final attempt = result.data!;
    emit(StudentQuizResultLoaded(
      result: AttemptResultModel(
        attemptId: attempt.id,
        quizId: attempt.quizId,
        score: attempt.scoreObtained,
        maxScore: attempt.maxScore,
        percentage: attempt.scorePercentage,
        passed: attempt.scorePercentage >= (attempt.quiz?.passingScore ?? 50),
      ),
      quiz: attempt.quiz,
    ));
  }

  // ── Back to list ─────────────────────────────────────────────────────────

  void backToList() => loadQuizzes();

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
