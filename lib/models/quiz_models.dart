enum QuizType { mcq, trueFalse, shortAnswer }

enum DifficultyLevel { easy, medium, hard }

class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;
  final QuizType type;
  final String? correctAnswer;
  String? userAnswer;
  List<String>? userAnswers;
  bool isSkipped;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
    this.correctAnswer,
    this.userAnswer,
    this.userAnswers,
    this.isSkipped = false,
  });

  bool get isAnswered {
    if (isSkipped) return false;
    if (type == QuizType.shortAnswer) {
      return userAnswer != null && userAnswer!.trim().isNotEmpty;
    }
    return userAnswer != null || (userAnswers != null && userAnswers!.isNotEmpty);
  }

  bool get isCorrect {
    if (type == QuizType.trueFalse || type == QuizType.mcq) {
      return userAnswer == correctAnswer;
    }
    return false;
  }

  void clearAnswer() {
    userAnswer = null;
    userAnswers = null;
    isSkipped = false;
  }
}

class QuizSession {
  final String id;
  final String courseId;
  final String courseName;
  final QuizType quizType;
  final DifficultyLevel difficultyLevel;
  final List<QuizQuestion> questions;
  final bool includeWeakTopics;
  int currentQuestionIndex;
  DateTime createdAt;

  QuizSession({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.quizType,
    required this.difficultyLevel,
    required this.questions,
    required this.includeWeakTopics,
    this.currentQuestionIndex = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  QuizQuestion get currentQuestion => questions[currentQuestionIndex];

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  bool get canGoNext => currentQuestionIndex < questions.length - 1;

  bool get canGoPrevious => currentQuestionIndex > 0;

  int get answeredCount => questions.where((q) => q.isAnswered).length;

  int get skippedCount => questions.where((q) => q.isSkipped).length;

  int get unansweredCount => questions.length - answeredCount - skippedCount;

  int get correctCount => questions.where((q) => q.isCorrect).length;

  double get score => questions.isEmpty ? 0 : (correctCount / questions.length) * 100;

  void nextQuestion() {
    if (canGoNext) {
      currentQuestionIndex++;
    }
  }

  void previousQuestion() {
    if (canGoPrevious) {
      currentQuestionIndex--;
    }
  }

  void submitAnswer(String answer) {
    currentQuestion.userAnswer = answer;
    currentQuestion.isSkipped = false;
  }

  void submitMultipleAnswers(List<String> answers) {
    currentQuestion.userAnswers = answers;
    currentQuestion.isSkipped = false;
  }

  void skipQuestion() {
    // Mark current question as skipped only if not already answered
    if (!currentQuestion.isAnswered) {
      currentQuestion.isSkipped = true;
    }
    if (canGoNext) {
      nextQuestion();
    }
  }

  void clearCurrentAnswer() {
    currentQuestion.clearAnswer();
  }
}
