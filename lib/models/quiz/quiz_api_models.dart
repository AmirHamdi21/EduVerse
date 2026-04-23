// ──────────────────────────────────────────────────────────────────────────────
// Quiz API Models — aligned 1:1 with the NestJS backend DTOs
// ──────────────────────────────────────────────────────────────────────────────

// ── Enums ────────────────────────────────────────────────────────────────────

enum QuizTypeEnum {
  practice,
  graded,
  survey;

  factory QuizTypeEnum.fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'practice':
        return QuizTypeEnum.practice;
      case 'graded':
        return QuizTypeEnum.graded;
      case 'survey':
        return QuizTypeEnum.survey;
      default:
        return QuizTypeEnum.graded;
    }
  }

  String toJson() => name;
}

enum QuestionTypeEnum {
  multipleChoice,
  trueFalse,
  shortAnswer,
  essay,
  matching;

  factory QuestionTypeEnum.fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'multiple_choice':
      case 'multiplechoice':
        return QuestionTypeEnum.multipleChoice;
      case 'true_false':
      case 'truefalse':
        return QuestionTypeEnum.trueFalse;
      case 'short_answer':
      case 'shortanswer':
        return QuestionTypeEnum.shortAnswer;
      case 'essay':
        return QuestionTypeEnum.essay;
      case 'matching':
        return QuestionTypeEnum.matching;
      default:
        return QuestionTypeEnum.multipleChoice;
    }
  }

  String toJson() {
    switch (this) {
      case QuestionTypeEnum.multipleChoice:
        return 'multiple_choice';
      case QuestionTypeEnum.trueFalse:
        return 'true_false';
      case QuestionTypeEnum.shortAnswer:
        return 'short_answer';
      case QuestionTypeEnum.essay:
        return 'essay';
      case QuestionTypeEnum.matching:
        return 'matching';
    }
  }
}

enum AttemptStatusEnum {
  inProgress,
  submitted,
  graded,
  expired;

  factory AttemptStatusEnum.fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return AttemptStatusEnum.inProgress;
      case 'submitted':
        return AttemptStatusEnum.submitted;
      case 'graded':
        return AttemptStatusEnum.graded;
      case 'expired':
        return AttemptStatusEnum.expired;
      default:
        return AttemptStatusEnum.inProgress;
    }
  }

  String toJson() {
    switch (this) {
      case AttemptStatusEnum.inProgress:
        return 'in_progress';
      case AttemptStatusEnum.submitted:
        return 'submitted';
      case AttemptStatusEnum.graded:
        return 'graded';
      case AttemptStatusEnum.expired:
        return 'expired';
    }
  }
}

enum ShowAnswersAfterEnum {
  never,
  submission,
  grading,
  dueDate;

  factory ShowAnswersAfterEnum.fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'never':
        return ShowAnswersAfterEnum.never;
      case 'submission':
        return ShowAnswersAfterEnum.submission;
      case 'grading':
        return ShowAnswersAfterEnum.grading;
      case 'due_date':
      case 'duedate':
        return ShowAnswersAfterEnum.dueDate;
      default:
        return ShowAnswersAfterEnum.never;
    }
  }

  String toJson() {
    switch (this) {
      case ShowAnswersAfterEnum.never:
        return 'never';
      case ShowAnswersAfterEnum.submission:
        return 'submission';
      case ShowAnswersAfterEnum.grading:
        return 'grading';
      case ShowAnswersAfterEnum.dueDate:
        return 'due_date';
    }
  }
}

enum QuizStatusEnum {
  draft,
  published,
  closed;

  factory QuizStatusEnum.fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'draft':
        return QuizStatusEnum.draft;
      case 'published':
        return QuizStatusEnum.published;
      case 'closed':
        return QuizStatusEnum.closed;
      default:
        return QuizStatusEnum.draft;
    }
  }

  String toJson() => name;
}

// ── Helper ───────────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double _parseDouble(dynamic v, [double fallback = 0.0]) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

// ── QuizModel ────────────────────────────────────────────────────────────────

class QuizModel {
  final int id;
  final int? courseId;
  final String title;
  final String? description;
  final String? instructions;
  final QuizTypeEnum quizType;
  final int? timeLimitMinutes;
  final int maxAttempts;
  final double passingScore;
  final bool randomizeQuestions;
  final bool showCorrectAnswers;
  final ShowAnswersAfterEnum showAnswersAfter;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final double weight;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Nested relations (may be null depending on endpoint)
  final Map<String, dynamic>? course;
  final Map<String, dynamic>? creator;
  final List<QuizQuestionModel>? questions;

  // Computed / summary fields returned by some endpoints
  final int questionCount;
  final double maxScore;

  // Derived status based on availability dates
  QuizStatusEnum get status {
    final now = DateTime.now();
    if (availableFrom == null && availableUntil == null) {
      return QuizStatusEnum.draft;
    }
    if (availableUntil != null && now.isAfter(availableUntil!)) {
      return QuizStatusEnum.closed;
    }
    if (availableFrom != null && now.isAfter(availableFrom!)) {
      return QuizStatusEnum.published;
    }
    return QuizStatusEnum.draft;
  }

  String get courseName {
    if (course == null) return 'Unknown Course';
    return (course!['name'] ?? course!['title'] ?? 'Unknown Course') as String;
  }

  String get creatorName {
    if (creator == null) return '';
    final first = creator!['firstName'] ?? '';
    final last = creator!['lastName'] ?? '';
    return '$first $last'.trim();
  }

  const QuizModel({
    required this.id,
    this.courseId,
    required this.title,
    this.description,
    this.instructions,
    this.quizType = QuizTypeEnum.graded,
    this.timeLimitMinutes,
    this.maxAttempts = 1,
    this.passingScore = 50.0,
    this.randomizeQuestions = false,
    this.showCorrectAnswers = false,
    this.showAnswersAfter = ShowAnswersAfterEnum.never,
    this.availableFrom,
    this.availableUntil,
    this.weight = 1.0,
    this.createdAt,
    this.updatedAt,
    this.course,
    this.creator,
    this.questions,
    this.questionCount = 0,
    this.maxScore = 0.0,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    List<QuizQuestionModel>? questions;
    final rawQ = json['questions'];
    if (rawQ is List) {
      questions = rawQ
          .whereType<Map<String, dynamic>>()
          .map(QuizQuestionModel.fromJson)
          .toList();
    }

    return QuizModel(
      id: _parseInt(json['id']),
      courseId: json['courseId'] != null ? _parseInt(json['courseId']) : null,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      quizType: QuizTypeEnum.fromJson(json['quizType'] as String?),
      timeLimitMinutes: json['timeLimit'] != null
          ? _parseInt(json['timeLimit'])
          : (json['timeLimitMinutes'] != null
              ? _parseInt(json['timeLimitMinutes'])
              : null),
      maxAttempts: _parseInt(json['maxAttempts'], 1),
      passingScore: _parseDouble(json['passingScore'], 50.0),
      randomizeQuestions: json['randomizeQuestions'] == true,
      showCorrectAnswers: json['showCorrectAnswers'] == true,
      showAnswersAfter:
          ShowAnswersAfterEnum.fromJson(json['showAnswersAfter'] as String?),
      availableFrom: _parseDate(json['availableFrom']),
      availableUntil: _parseDate(json['availableUntil']),
      weight: _parseDouble(json['weight'], 1.0),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      course: json['course'] is Map<String, dynamic>
          ? json['course'] as Map<String, dynamic>
          : null,
      creator: json['creator'] is Map<String, dynamic>
          ? json['creator'] as Map<String, dynamic>
          : null,
      questions: questions,
      questionCount: _parseInt(
        json['questionCount'] ?? (questions?.length ?? 0),
      ),
      maxScore: _parseDouble(json['maxScore']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (courseId != null) 'courseId': courseId,
        'title': title,
        if (description != null) 'description': description,
        if (instructions != null) 'instructions': instructions,
        'quizType': quizType.toJson(),
        if (timeLimitMinutes != null) 'timeLimit': timeLimitMinutes,
        'maxAttempts': maxAttempts,
        'passingScore': passingScore,
        'randomizeQuestions': randomizeQuestions,
        'showCorrectAnswers': showCorrectAnswers,
        'showAnswersAfter': showAnswersAfter.toJson(),
        if (availableFrom != null)
          'availableFrom': availableFrom!.toIso8601String(),
        if (availableUntil != null)
          'availableUntil': availableUntil!.toIso8601String(),
        'weight': weight,
      };

  QuizModel copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    String? instructions,
    QuizTypeEnum? quizType,
    int? timeLimitMinutes,
    int? maxAttempts,
    double? passingScore,
    bool? randomizeQuestions,
    bool? showCorrectAnswers,
    ShowAnswersAfterEnum? showAnswersAfter,
    DateTime? availableFrom,
    DateTime? availableUntil,
    double? weight,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? course,
    Map<String, dynamic>? creator,
    List<QuizQuestionModel>? questions,
    int? questionCount,
    double? maxScore,
  }) {
    return QuizModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      quizType: quizType ?? this.quizType,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      passingScore: passingScore ?? this.passingScore,
      randomizeQuestions: randomizeQuestions ?? this.randomizeQuestions,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      showAnswersAfter: showAnswersAfter ?? this.showAnswersAfter,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      course: course ?? this.course,
      creator: creator ?? this.creator,
      questions: questions ?? this.questions,
      questionCount: questionCount ?? this.questionCount,
      maxScore: maxScore ?? this.maxScore,
    );
  }
}

// ── QuizQuestionModel ────────────────────────────────────────────────────────

class QuizQuestionModel {
  final int id;
  final int? quizId;
  final QuestionTypeEnum questionType;
  final String questionText;
  final List<Map<String, dynamic>> options;
  final dynamic correctAnswer;
  final String? explanation;
  final double points;
  final int? difficultyLevelId;
  final int orderIndex;

  const QuizQuestionModel({
    required this.id,
    this.quizId,
    this.questionType = QuestionTypeEnum.multipleChoice,
    required this.questionText,
    this.options = const [],
    this.correctAnswer,
    this.explanation,
    this.points = 1.0,
    this.difficultyLevelId,
    this.orderIndex = 0,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> options = [];
    final rawOpts = json['options'];
    if (rawOpts is List) {
      options = rawOpts.map((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is String) return <String, dynamic>{'text': e};
        return <String, dynamic>{};
      }).toList();
    }

    return QuizQuestionModel(
      id: _parseInt(json['id']),
      quizId: json['quizId'] != null ? _parseInt(json['quizId']) : null,
      questionType:
          QuestionTypeEnum.fromJson(json['questionType'] as String?),
      questionText: (json['questionText'] ?? json['text'] ?? '') as String,
      options: options,
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'] as String?,
      points: _parseDouble(json['points'], 1.0),
      difficultyLevelId: json['difficultyLevelId'] != null
          ? _parseInt(json['difficultyLevelId'])
          : null,
      orderIndex: _parseInt(json['orderIndex']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionType': questionType.toJson(),
        'questionText': questionText,
        'options': options,
        if (correctAnswer != null) 'correctAnswer': correctAnswer,
        if (explanation != null) 'explanation': explanation,
        'points': points,
        if (difficultyLevelId != null) 'difficultyLevelId': difficultyLevelId,
        'orderIndex': orderIndex,
      };

  QuizQuestionModel copyWith({
    int? id,
    int? quizId,
    QuestionTypeEnum? questionType,
    String? questionText,
    List<Map<String, dynamic>>? options,
    dynamic correctAnswer,
    String? explanation,
    double? points,
    int? difficultyLevelId,
    int? orderIndex,
  }) {
    return QuizQuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      difficultyLevelId: difficultyLevelId ?? this.difficultyLevelId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

// ── AttemptAnswerModel ───────────────────────────────────────────────────────

class AttemptAnswerModel {
  final int? id;
  final int? attemptId;
  final int questionId;
  final String? selectedOption;
  final String? answerText;
  final bool? isCorrect;
  final double? pointsEarned;

  const AttemptAnswerModel({
    this.id,
    this.attemptId,
    required this.questionId,
    this.selectedOption,
    this.answerText,
    this.isCorrect,
    this.pointsEarned,
  });

  factory AttemptAnswerModel.fromJson(Map<String, dynamic> json) {
    return AttemptAnswerModel(
      id: json['id'] != null ? _parseInt(json['id']) : null,
      attemptId:
          json['attemptId'] != null ? _parseInt(json['attemptId']) : null,
      questionId: _parseInt(json['questionId']),
      selectedOption: json['selectedOption'] as String?,
      answerText: json['answerText'] as String?,
      isCorrect: json['isCorrect'] as bool?,
      pointsEarned: json['pointsEarned'] != null
          ? _parseDouble(json['pointsEarned'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionId': questionId,
        if (selectedOption != null) 'selectedOption': selectedOption,
        if (answerText != null) 'answerText': answerText,
      };
}

// ── QuizAttemptModel ─────────────────────────────────────────────────────────

class QuizAttemptModel {
  final int id;
  final int quizId;
  final int? userId;
  final int attemptNumber;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final double? score;
  final int? timeTakenMinutes;
  final AttemptStatusEnum status;
  final List<AttemptAnswerModel> answers;
  final List<QuizQuestionModel>? questions;
  final QuizModel? quiz;
  final Map<String, dynamic>? user;

  // Computed
  int get questionCount => questions?.length ?? 0;

  double get maxScore {
    if (questions == null || questions!.isEmpty) return 0;
    return questions!.fold(0.0, (sum, q) => sum + q.points);
  }

  double get scoreObtained => score ?? 0.0;

  double get scorePercentage {
    if (maxScore == 0) return 0;
    return (scoreObtained / maxScore) * 100;
  }

  String get userName {
    if (user == null) return 'Unknown';
    final first = user!['firstName'] ?? '';
    final last = user!['lastName'] ?? '';
    return '$first $last'.trim();
  }

  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    this.userId,
    this.attemptNumber = 1,
    this.startedAt,
    this.submittedAt,
    this.score,
    this.timeTakenMinutes,
    this.status = AttemptStatusEnum.inProgress,
    this.answers = const [],
    this.questions,
    this.quiz,
    this.user,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    List<AttemptAnswerModel> answers = [];
    final rawA = json['answers'];
    if (rawA is List) {
      answers = rawA
          .whereType<Map<String, dynamic>>()
          .map(AttemptAnswerModel.fromJson)
          .toList();
    }

    List<QuizQuestionModel>? questions;
    final rawQ = json['questions'];
    if (rawQ is List) {
      questions = rawQ
          .whereType<Map<String, dynamic>>()
          .map(QuizQuestionModel.fromJson)
          .toList();
    }

    return QuizAttemptModel(
      id: _parseInt(json['id']),
      quizId: _parseInt(json['quizId']),
      userId: json['userId'] != null ? _parseInt(json['userId']) : null,
      attemptNumber: _parseInt(json['attemptNumber'], 1),
      startedAt: _parseDate(json['startedAt']),
      submittedAt: _parseDate(json['submittedAt']),
      score: json['score'] != null ? _parseDouble(json['score']) : null,
      timeTakenMinutes: json['timeTakenMinutes'] != null
          ? _parseInt(json['timeTakenMinutes'])
          : null,
      status: AttemptStatusEnum.fromJson(json['status'] as String?),
      answers: answers,
      questions: questions,
      quiz: json['quiz'] is Map<String, dynamic>
          ? QuizModel.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
      user: json['user'] is Map<String, dynamic>
          ? json['user'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'quizId': quizId,
        'status': status.toJson(),
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

// ── AttemptResultModel ───────────────────────────────────────────────────────

class AttemptResultModel {
  final int attemptId;
  final int quizId;
  final String quizTitle;
  final double score;
  final double maxScore;
  final double percentage;
  final bool passed;
  final int? timeTakenMinutes;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final List<Map<String, dynamic>> questions;

  const AttemptResultModel({
    required this.attemptId,
    required this.quizId,
    this.quizTitle = '',
    this.score = 0,
    this.maxScore = 0,
    this.percentage = 0,
    this.passed = false,
    this.timeTakenMinutes,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.skippedCount = 0,
    this.questions = const [],
  });

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> questions = [];
    final rawQ = json['questions'];
    if (rawQ is List) {
      questions = rawQ.whereType<Map<String, dynamic>>().toList();
    }

    return AttemptResultModel(
      attemptId: _parseInt(json['attemptId'] ?? json['id']),
      quizId: _parseInt(json['quizId']),
      quizTitle: (json['quizTitle'] ?? json['title'] ?? '') as String,
      score: _parseDouble(json['score']),
      maxScore: _parseDouble(json['maxScore'] ?? json['totalPoints']),
      percentage: _parseDouble(json['percentage'] ?? json['scorePercentage']),
      passed: json['passed'] == true,
      timeTakenMinutes: json['timeTakenMinutes'] != null
          ? _parseInt(json['timeTakenMinutes'])
          : null,
      correctCount: _parseInt(json['correctCount']),
      wrongCount: _parseInt(json['wrongCount']),
      skippedCount: _parseInt(json['skippedCount']),
      questions: questions,
    );
  }
}

// ── QuizStatisticsModel ──────────────────────────────────────────────────────

class QuizStatisticsModel {
  final int totalAttempts;
  final double averageScore;
  final double highestScore;
  final double lowestScore;
  final double passRate;
  final List<Map<String, dynamic>> questionStats;

  const QuizStatisticsModel({
    this.totalAttempts = 0,
    this.averageScore = 0,
    this.highestScore = 0,
    this.lowestScore = 0,
    this.passRate = 0,
    this.questionStats = const [],
  });

  factory QuizStatisticsModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> questionStats = [];
    final rawQS = json['questionStats'] ?? json['questionStatistics'];
    if (rawQS is List) {
      questionStats = rawQS.whereType<Map<String, dynamic>>().toList();
    }

    return QuizStatisticsModel(
      totalAttempts: _parseInt(json['totalAttempts']),
      averageScore: _parseDouble(json['averageScore']),
      highestScore: _parseDouble(json['highestScore']),
      lowestScore: _parseDouble(json['lowestScore']),
      passRate: _parseDouble(json['passRate']),
      questionStats: questionStats,
    );
  }
}

// ── CourseProgressModel ──────────────────────────────────────────────────────

class CourseProgressModel {
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final double passingRate;

  const CourseProgressModel({
    this.totalQuizzes = 0,
    this.completedQuizzes = 0,
    this.averageScore = 0,
    this.passingRate = 0,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      totalQuizzes: _parseInt(json['totalQuizzes']),
      completedQuizzes: _parseInt(json['completedQuizzes']),
      averageScore: _parseDouble(json['averageScore']),
      passingRate: _parseDouble(json['passingRate']),
    );
  }
}
