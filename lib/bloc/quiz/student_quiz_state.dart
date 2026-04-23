import '../../models/quiz/quiz_api_models.dart';

// ── Base State ───────────────────────────────────────────────────────────────

abstract class StudentQuizState {
  const StudentQuizState();
}

class StudentQuizInitial extends StudentQuizState {
  const StudentQuizInitial();
}

class StudentQuizLoading extends StudentQuizState {
  const StudentQuizLoading();
}

class StudentQuizzesLoaded extends StudentQuizState {
  final List<QuizModel> quizzes;
  final List<QuizAttemptModel> myAttempts;
  final String searchQuery;
  final String statusFilter;

  const StudentQuizzesLoaded({
    required this.quizzes,
    this.myAttempts = const [],
    this.searchQuery = '',
    this.statusFilter = 'all',
  });

  List<QuizModel> get filteredQuizzes {
    return quizzes.where((q) {
      final matchesSearch = searchQuery.isEmpty ||
          q.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          q.courseName.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = statusFilter == 'all' ||
          q.status.toJson() == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int remainingAttempts(int quizId) {
    final quizAttempts = myAttempts.where((a) => a.quizId == quizId).toList();
    final quiz = quizzes.where((q) => q.id == quizId).firstOrNull;
    if (quiz == null) return 0;
    return quiz.maxAttempts - quizAttempts.length;
  }

  QuizAttemptModel? inProgressAttempt(int quizId) {
    try {
      return myAttempts.firstWhere(
        (a) => a.quizId == quizId && a.status == AttemptStatusEnum.inProgress,
      );
    } catch (_) {
      return null;
    }
  }

  StudentQuizzesLoaded copyWith({
    List<QuizModel>? quizzes,
    List<QuizAttemptModel>? myAttempts,
    String? searchQuery,
    String? statusFilter,
  }) {
    return StudentQuizzesLoaded(
      quizzes: quizzes ?? this.quizzes,
      myAttempts: myAttempts ?? this.myAttempts,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class StudentQuizStarting extends StudentQuizState {
  const StudentQuizStarting();
}

class StudentQuizActive extends StudentQuizState {
  final QuizAttemptModel attempt;
  final List<QuizQuestionModel> questions;
  final Map<int, AttemptAnswerModel> answers;
  final int currentQuestionIndex;
  final int? timeLimitMinutes;
  final DateTime startedAt;

  const StudentQuizActive({
    required this.attempt,
    required this.questions,
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.timeLimitMinutes,
    required this.startedAt,
  });

  QuizQuestionModel get currentQuestion => questions[currentQuestionIndex];
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get canGoNext => currentQuestionIndex < questions.length - 1;
  bool get canGoPrevious => currentQuestionIndex > 0;
  int get answeredCount => answers.length;
  int get totalQuestions => questions.length;

  StudentQuizActive copyWith({
    QuizAttemptModel? attempt,
    List<QuizQuestionModel>? questions,
    Map<int, AttemptAnswerModel>? answers,
    int? currentQuestionIndex,
    int? timeLimitMinutes,
    DateTime? startedAt,
  }) {
    return StudentQuizActive(
      attempt: attempt ?? this.attempt,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class StudentQuizSubmitting extends StudentQuizState {
  const StudentQuizSubmitting();
}

class StudentQuizResultLoaded extends StudentQuizState {
  final AttemptResultModel result;
  final QuizModel? quiz;

  const StudentQuizResultLoaded({required this.result, this.quiz});
}

class StudentQuizError extends StudentQuizState {
  final String message;
  const StudentQuizError(this.message);
}
