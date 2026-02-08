// Model for instructor assignment/lab creation

enum AssignmentType {
  assignment,
  lab,
  project,
}

extension AssignmentTypeExtension on AssignmentType {
  String get displayName {
    switch (this) {
      case AssignmentType.assignment:
        return 'Assignment';
      case AssignmentType.lab:
        return 'Lab';
      case AssignmentType.project:
        return 'Project';
    }
  }

  String get icon {
    switch (this) {
      case AssignmentType.assignment:
        return '📝';
      case AssignmentType.lab:
        return '🔬';
      case AssignmentType.project:
        return '📊';
    }
  }
}

enum QuestionType {
  shortAnswer,
  longAnswer,
  multipleChoice,
  trueFalse,
  fileUpload,
  code,
}

extension QuestionTypeExtension on QuestionType {
  String get displayName {
    switch (this) {
      case QuestionType.shortAnswer:
        return 'Short Answer';
      case QuestionType.longAnswer:
        return 'Long Answer';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fileUpload:
        return 'File Upload';
      case QuestionType.code:
        return 'Code';
    }
  }
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
  veryHard,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.veryHard:
        return 'Very Hard';
    }
  }

  double get value {
    switch (this) {
      case DifficultyLevel.easy:
        return 0.0;
      case DifficultyLevel.medium:
        return 0.33;
      case DifficultyLevel.hard:
        return 0.66;
      case DifficultyLevel.veryHard:
        return 1.0;
    }
  }

  static DifficultyLevel fromValue(double value) {
    if (value <= 0.16) return DifficultyLevel.easy;
    if (value <= 0.5) return DifficultyLevel.medium;
    if (value <= 0.83) return DifficultyLevel.hard;
    return DifficultyLevel.veryHard;
  }
}

class AssignmentQuestion {
  final String id;
  final String questionText;
  final QuestionType type;
  final int points;
  final String? hint;
  final List<String>? options; // For multiple choice
  final String? correctAnswer;

  AssignmentQuestion({
    required this.id,
    this.questionText = '',
    this.type = QuestionType.shortAnswer,
    this.points = 10,
    this.hint,
    this.options,
    this.correctAnswer,
  });

  AssignmentQuestion copyWith({
    String? id,
    String? questionText,
    QuestionType? type,
    int? points,
    String? hint,
    List<String>? options,
    String? correctAnswer,
  }) {
    return AssignmentQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      points: points ?? this.points,
      hint: hint ?? this.hint,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }
}

class AssignmentAttachment {
  final String id;
  final String name;
  final String? path;
  final String? url;
  final int sizeBytes;
  final String mimeType;

  AssignmentAttachment({
    required this.id,
    required this.name,
    this.path,
    this.url,
    required this.sizeBytes,
    required this.mimeType,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class AssignmentDraft {
  final String id;
  final AssignmentType type;
  final String title;
  final String shortDescription;
  final String? courseId;
  final String? courseName;
  final String? moduleId;
  final String? moduleName;
  final String instructions;
  final List<AssignmentQuestion> questions;
  final List<AssignmentAttachment> attachments;
  final DateTime? dueDate;
  final DateTime? dueTime;
  final bool allowLateSubmissions;
  final bool plagiarismDetection;
  final bool groupWork;
  final bool autoGrading;
  final DifficultyLevel difficulty;
  final DateTime createdAt;
  final DateTime? lastModified;

  AssignmentDraft({
    required this.id,
    this.type = AssignmentType.assignment,
    this.title = '',
    this.shortDescription = '',
    this.courseId,
    this.courseName,
    this.moduleId,
    this.moduleName,
    this.instructions = '',
    this.questions = const [],
    this.attachments = const [],
    this.dueDate,
    this.dueTime,
    this.allowLateSubmissions = false,
    this.plagiarismDetection = true,
    this.groupWork = false,
    this.autoGrading = false,
    this.difficulty = DifficultyLevel.medium,
    required this.createdAt,
    this.lastModified,
  });

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);

  bool get isValid =>
      title.isNotEmpty &&
      courseId != null &&
      moduleId != null &&
      dueDate != null;

  AssignmentDraft copyWith({
    String? id,
    AssignmentType? type,
    String? title,
    String? shortDescription,
    String? courseId,
    String? courseName,
    String? moduleId,
    String? moduleName,
    String? instructions,
    List<AssignmentQuestion>? questions,
    List<AssignmentAttachment>? attachments,
    DateTime? dueDate,
    DateTime? dueTime,
    bool? allowLateSubmissions,
    bool? plagiarismDetection,
    bool? groupWork,
    bool? autoGrading,
    DifficultyLevel? difficulty,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return AssignmentDraft(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      instructions: instructions ?? this.instructions,
      questions: questions ?? this.questions,
      attachments: attachments ?? this.attachments,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      allowLateSubmissions: allowLateSubmissions ?? this.allowLateSubmissions,
      plagiarismDetection: plagiarismDetection ?? this.plagiarismDetection,
      groupWork: groupWork ?? this.groupWork,
      autoGrading: autoGrading ?? this.autoGrading,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class CourseModule {
  final String id;
  final String name;
  final int weekNumber;

  CourseModule({
    required this.id,
    required this.name,
    required this.weekNumber,
  });
}

class CourseOption {
  final String id;
  final String code;
  final String name;
  final List<CourseModule> modules;

  CourseOption({
    required this.id,
    required this.code,
    required this.name,
    required this.modules,
  });

  String get displayName => '$code — $name';
}
