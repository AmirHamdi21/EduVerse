import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/quiz/quiz_api_models.dart';
import '../../services/api/quiz_api_service.dart';
import 'quiz_management_state.dart';

/// Manages quiz CRUD, questions, attempts, grading, and statistics.
/// Shared identically by Instructor and TA — both have full capabilities.
class QuizManagementCubit extends Cubit<QuizManagementState> {
  final QuizApiService _service;

  QuizManagementCubit({required QuizApiService quizApiService})
    : _service = quizApiService,
      super(const QuizMgmtInitial());

  // ── Load quizzes ─────────────────────────────────────────────────────────

  Future<void> loadQuizzes({int? courseId}) async {
    emit(const QuizMgmtLoading());

    final result = await _service.getAll(courseId: courseId);
    if (result.isFailure) {
      emit(QuizMgmtError(result.error?.message ?? 'Failed to load quizzes'));
      return;
    }

    emit(QuizMgmtLoaded(quizzes: result.data ?? []));
  }

  // ── Filters ──────────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    final s = state;
    if (s is QuizMgmtLoaded) emit(s.copyWith(searchQuery: query));
  }

  void setStatusFilter(String status) {
    final s = state;
    if (s is QuizMgmtLoaded) emit(s.copyWith(statusFilter: status));
  }

  void setCourseFilter(String course) {
    final s = state;
    if (s is QuizMgmtLoaded) emit(s.copyWith(courseFilter: course));
  }

  // ── Quiz CRUD ────────────────────────────────────────────────────────────

  Future<bool> createQuiz(Map<String, dynamic> data) async {
    final prev = state;
    emit(const QuizMgmtOperating('creating'));

    final result = await _service.create(data);
    if (result.isFailure) {
      emit(QuizMgmtError(result.error?.message ?? 'Failed to create quiz'));
      return false;
    }

    // Refresh the list
    if (prev is QuizMgmtLoaded) {
      final updated = [result.data!, ...prev.quizzes];
      emit(prev.copyWith(quizzes: updated));
    } else {
      await loadQuizzes();
    }
    return true;
  }

  Future<bool> updateQuiz(dynamic id, Map<String, dynamic> data) async {
    final prev = state;
    emit(const QuizMgmtOperating('updating'));

    final result = await _service.update(id, data);
    if (result.isFailure) {
      emit(QuizMgmtError(result.error?.message ?? 'Failed to update quiz'));
      return false;
    }

    if (prev is QuizMgmtLoaded) {
      final updated = prev.quizzes.map((q) {
        return q.id == id ? result.data! : q;
      }).toList();
      emit(prev.copyWith(quizzes: updated));
    } else {
      await loadQuizzes();
    }
    return true;
  }

  Future<bool> deleteQuiz(dynamic id) async {
    final prev = state;
    emit(const QuizMgmtOperating('deleting'));

    final result = await _service.delete(id);
    if (result.isFailure) {
      emit(QuizMgmtError(result.error?.message ?? 'Failed to delete quiz'));
      return false;
    }

    if (prev is QuizMgmtLoaded) {
      final updated = prev.quizzes.where((q) => q.id != id).toList();
      emit(prev.copyWith(quizzes: updated));
    } else {
      await loadQuizzes();
    }
    return true;
  }

  Future<bool> publishQuiz(int id) async {
    final now = DateTime.now().toIso8601String();
    return updateQuiz(id, {'availableFrom': now});
  }

  Future<bool> closeQuiz(int id) async {
    final now = DateTime.now().toIso8601String();
    return updateQuiz(id, {'availableUntil': now});
  }

  // ── Question Management ──────────────────────────────────────────────────

  Future<QuizQuestionModel?> addQuestion(
    dynamic quizId,
    Map<String, dynamic> data,
  ) async {
    final result = await _service.addQuestion(quizId, data);
    if (result.isFailure) return null;
    return result.data;
  }

  Future<QuizQuestionModel?> updateQuestion(
    dynamic quizId,
    dynamic questionId,
    Map<String, dynamic> data,
  ) async {
    final result = await _service.updateQuestion(quizId, questionId, data);
    if (result.isFailure) return null;
    return result.data;
  }

  Future<bool> deleteQuestion(dynamic quizId, dynamic questionId) async {
    final result = await _service.deleteQuestion(quizId, questionId);
    return result.isSuccess;
  }

  // ── Attempts ─────────────────────────────────────────────────────────────

  Future<void> loadAttempts(int quizId) async {
    final s = state;
    if (s is! QuizMgmtLoaded) return;

    final loading = Map<int, bool>.from(s.loadingAttempts);
    loading[quizId] = true;
    emit(s.copyWith(loadingAttempts: loading));

    final result = await _service.getAllAttempts(quizId: quizId);

    final loadingDone = Map<int, bool>.from(s.loadingAttempts);
    loadingDone[quizId] = false;

    if (result.isSuccess) {
      final map = Map<int, List<QuizAttemptModel>>.from(s.attemptsMap);
      map[quizId] = result.data ?? [];
      emit(s.copyWith(attemptsMap: map, loadingAttempts: loadingDone));
    } else {
      emit(s.copyWith(loadingAttempts: loadingDone));
    }
  }

  // ── Grading ──────────────────────────────────────────────────────────────

  Future<bool> gradeAttempt(
    dynamic attemptId,
    List<Map<String, dynamic>> grades,
  ) async {
    final result = await _service.gradeAttempt(attemptId, grades);
    return result.isSuccess;
  }

  // ── Statistics ───────────────────────────────────────────────────────────

  Future<void> loadStatistics(int quizId) async {
    final s = state;
    if (s is! QuizMgmtLoaded) return;

    final loading = Map<int, bool>.from(s.loadingStatistics);
    loading[quizId] = true;
    emit(s.copyWith(loadingStatistics: loading));

    final result = await _service.getStatistics(quizId);

    final loadingDone = Map<int, bool>.from(s.loadingStatistics);
    loadingDone[quizId] = false;

    if (result.isSuccess) {
      final map = Map<int, QuizStatisticsModel>.from(s.statisticsMap);
      map[quizId] = result.data!;
      emit(s.copyWith(statisticsMap: map, loadingStatistics: loadingDone));
    } else {
      emit(s.copyWith(loadingStatistics: loadingDone));
    }
  }

  // ── Fetch single quiz details ────────────────────────────────────────────

  Future<QuizModel?> fetchQuizDetails(dynamic quizId) async {
    final result = await _service.getById(quizId);
    if (result.isSuccess) return result.data;
    return null;
  }
}
