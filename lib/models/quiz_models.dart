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

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
    this.correctAnswer,
    this.userAnswer,
    this.userAnswers,
  });

  bool get isAnswered =>
      userAnswer != null || (userAnswers != null && userAnswers!.isNotEmpty);

  bool get isCorrect {
    if (type == QuizType.trueFalse || type == QuizType.mcq) {
      return userAnswer == correctAnswer;
    }
    return false;
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

  int get correctCount => questions.where((q) => q.isCorrect).length;

  double get score => (correctCount / questions.length) * 100;

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
  }

  void submitMultipleAnswers(List<String> answers) {
    currentQuestion.userAnswers = answers;
  }

  void skipQuestion() {
    if (canGoNext) {
      nextQuestion();
    }
  }
}
