import 'package:equatable/equatable.dart';

enum QuestionBankQuestionType {
  mcq('mcq'),
  trueFalse('true_false'),
  fillBlanks('fill_blanks'),
  written('written'),
  essay('essay');

  const QuestionBankQuestionType(this.value);
  final String value;

  static QuestionBankQuestionType fromJson(dynamic value) {
    final raw = value?.toString();
    return QuestionBankQuestionType.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => QuestionBankQuestionType.mcq,
    );
  }

  String toJson() => value;
}

enum QuestionBankDifficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const QuestionBankDifficulty(this.value);
  final String value;

  static QuestionBankDifficulty fromJson(dynamic value) {
    final raw = value?.toString();
    return QuestionBankDifficulty.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => QuestionBankDifficulty.medium,
    );
  }

  String toJson() => value;
}

enum QuestionBankBloomLevel {
  remember('remember'),
  understand('understand'),
  apply('apply'),
  analyze('analyze'),
  evaluate('evaluate'),
  create('create');

  const QuestionBankBloomLevel(this.value);
  final String value;

  static QuestionBankBloomLevel fromJson(dynamic value) {
    final raw = value?.toString();
    return QuestionBankBloomLevel.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => QuestionBankBloomLevel.understand,
    );
  }

  String toJson() => value;
}

enum QuestionBankStatus {
  draft('draft'),
  pendingReview('pending_review'),
  approved('approved'),
  rejected('rejected'),
  archived('archived');

  const QuestionBankStatus(this.value);
  final String value;

  static QuestionBankStatus fromJson(dynamic value) {
    final raw = value?.toString();
    return QuestionBankStatus.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => QuestionBankStatus.draft,
    );
  }

  String toJson() => value;
}

enum QuestionBankAttachmentType {
  image('image'),
  document('document'),
  audio('audio'),
  video('video');

  const QuestionBankAttachmentType(this.value);
  final String value;

  static QuestionBankAttachmentType fromJson(dynamic value) {
    final raw = value?.toString();
    return QuestionBankAttachmentType.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => QuestionBankAttachmentType.image,
    );
  }

  String toJson() => value;
}

enum QuestionBankGroupType {
  passage('passage'),
  caseStudy('case_study'),
  imageSet('image_set'),
  multipart('multipart'),
  other('other');

  const QuestionBankGroupType(this.value);
  final String value;

  static QuestionBankGroupType fromJson(dynamic value) {
    final raw = value?.toString();
    return QuestionBankGroupType.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => QuestionBankGroupType.other,
    );
  }

  String toJson() => value;
}

enum ExamStatus {
  draft('draft'),
  published('published'),
  unpublished('unpublished'),
  archived('archived');

  const ExamStatus(this.value);
  final String value;

  static ExamStatus fromJson(dynamic value) {
    final raw = value?.toString();
    return ExamStatus.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ExamStatus.draft,
    );
  }

  String toJson() => value;
}

enum ExamDraftStatus {
  open('open'),
  finalized('finalized'),
  expired('expired'),
  failed('failed'),
  cancelled('cancelled');

  const ExamDraftStatus(this.value);
  final String value;

  static ExamDraftStatus fromJson(dynamic value) {
    final raw = value?.toString();
    return ExamDraftStatus.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ExamDraftStatus.open,
    );
  }

  String toJson() => value;
}

enum ExamMarkDistributionMode {
  manual('manual'),
  equal('equal'),
  weightNormalized('weight_normalized');

  const ExamMarkDistributionMode(this.value);
  final String value;

  static ExamMarkDistributionMode fromJson(dynamic value) {
    final raw = value?.toString();
    return ExamMarkDistributionMode.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ExamMarkDistributionMode.manual,
    );
  }

  String toJson() => value;
}

enum ExamRoundingPolicy {
  none('none'),
  nearest025('nearest_0_25'),
  nearest05('nearest_0_5'),
  nearest1('nearest_1');

  const ExamRoundingPolicy(this.value);
  final String value;

  static ExamRoundingPolicy fromJson(dynamic value) {
    final raw = value?.toString();
    return ExamRoundingPolicy.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ExamRoundingPolicy.none,
    );
  }

  String toJson() => value;
}

enum ExamExportFormat {
  htmlDoc('html_doc'),
  docx('docx'),
  pdf('pdf');

  const ExamExportFormat(this.value);
  final String value;

  static ExamExportFormat fromJson(dynamic value) {
    final raw = value?.toString();
    return ExamExportFormat.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ExamExportFormat.htmlDoc,
    );
  }

  String toJson() => value;
}

enum ExamSectionAnswerPolicy {
  answerAll('answer_all'),
  answerAny('answer_any');

  const ExamSectionAnswerPolicy(this.value);
  final String value;

  static ExamSectionAnswerPolicy fromJson(dynamic value) {
    final raw = value?.toString();
    return ExamSectionAnswerPolicy.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ExamSectionAnswerPolicy.answerAll,
    );
  }

  String toJson() => value;
}

class CourseChapterModel extends Equatable {
  const CourseChapterModel({
    required this.id,
    required this.courseId,
    required this.name,
    required this.chapterOrder,
    this.description,
    this.isActive = true,
  });

  final int id;
  final int courseId;
  final String name;
  final int chapterOrder;
  final String? description;
  final bool isActive;

  factory CourseChapterModel.fromJson(Map<String, dynamic> json) {
    return CourseChapterModel(
      id: _readInt(json, const ['id', 'chapterId']),
      courseId: _readInt(json, const ['courseId']),
      name: _readString(json, const ['name', 'title'], fallback: 'Chapter'),
      chapterOrder: _readInt(json, const [
        'chapterOrder',
        'order',
      ], fallback: 1),
      description: _readNullableString(json, const ['description']),
      isActive: _readBool(json, const ['isActive'], fallback: true),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    name,
    chapterOrder,
    description,
    isActive,
  ];
}

class QuestionBankOptionModel extends Equatable {
  const QuestionBankOptionModel({
    this.optionId,
    required this.optionText,
    this.isCorrect = false,
    this.optionOrder,
  });

  final int? optionId;
  final String optionText;
  final bool isCorrect;
  final int? optionOrder;

  factory QuestionBankOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankOptionModel(
      optionId: _readNullableInt(json, const ['optionId', 'id']),
      optionText: _readString(json, const ['optionText', 'text']),
      isCorrect: _readBool(json, const ['isCorrect']),
      optionOrder: _readNullableInt(json, const ['optionOrder']),
    );
  }

  Map<String, dynamic> toRequestJson() => <String, dynamic>{
    'optionText': optionText.trim(),
    'isCorrect': isCorrect,
  };

  @override
  List<Object?> get props => <Object?>[
    optionId,
    optionText,
    isCorrect,
    optionOrder,
  ];
}

class QuestionBankFillBlankModel extends Equatable {
  const QuestionBankFillBlankModel({
    this.blankId,
    required this.blankKey,
    required this.acceptableAnswer,
    this.isCaseSensitive = false,
  });

  final int? blankId;
  final String blankKey;
  final String acceptableAnswer;
  final bool isCaseSensitive;

  factory QuestionBankFillBlankModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankFillBlankModel(
      blankId: _readNullableInt(json, const ['blankId', 'id']),
      blankKey: _readString(json, const ['blankKey']),
      acceptableAnswer: _readString(json, const ['acceptableAnswer']),
      isCaseSensitive: _readBool(json, const ['isCaseSensitive']),
    );
  }

  Map<String, dynamic> toRequestJson() => <String, dynamic>{
    'blankKey': blankKey.trim(),
    'acceptableAnswer': acceptableAnswer.trim(),
    'isCaseSensitive': isCaseSensitive,
  };

  @override
  List<Object?> get props => <Object?>[
    blankId,
    blankKey,
    acceptableAnswer,
    isCaseSensitive,
  ];
}

class QuestionBankAttachmentModel extends Equatable {
  const QuestionBankAttachmentModel({
    required this.id,
    this.fileId,
    this.attachmentType,
    this.caption,
    this.altText,
    this.imageUrl,
    this.orderIndex = 0,
    this.isPrimary = false,
  });

  final int id;
  final int? fileId;
  final String? attachmentType;
  final String? caption;
  final String? altText;
  final String? imageUrl;
  final int orderIndex;
  final bool isPrimary;

  factory QuestionBankAttachmentModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankAttachmentModel(
      id: _readInt(json, const ['id', 'attachmentId']),
      fileId: _readNullableInt(json, const ['fileId']),
      attachmentType: _readNullableString(json, const ['attachmentType']),
      caption: _readNullableString(json, const ['caption']),
      altText: _readNullableString(json, const ['altText']),
      imageUrl: _readNullableString(json, const ['imageUrl', 'url']),
      orderIndex: _readInt(json, const [
        'orderIndex',
        'displayOrder',
      ], fallback: 0),
      isPrimary: _readBool(json, const ['isPrimary']),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    fileId,
    attachmentType,
    caption,
    altText,
    imageUrl,
    orderIndex,
    isPrimary,
  ];
}

class QuestionBankQuestionModel extends Equatable {
  const QuestionBankQuestionModel({
    required this.id,
    required this.courseId,
    required this.chapterId,
    required this.questionType,
    required this.difficulty,
    required this.bloomLevel,
    required this.status,
    this.questionText,
    this.expectedAnswerText,
    this.hints,
    this.explanation,
    this.defaultWeight,
    this.groupId,
    this.groupItemOrder,
    this.createdAt,
    this.updatedAt,
    this.options = const <QuestionBankOptionModel>[],
    this.fillBlanks = const <QuestionBankFillBlankModel>[],
    this.attachments = const <QuestionBankAttachmentModel>[],
  });

  final int id;
  final int courseId;
  final int chapterId;
  final QuestionBankQuestionType questionType;
  final QuestionBankDifficulty difficulty;
  final QuestionBankBloomLevel bloomLevel;
  final QuestionBankStatus status;
  final String? questionText;
  final String? expectedAnswerText;
  final String? hints;
  final String? explanation;
  final double? defaultWeight;
  final int? groupId;
  final int? groupItemOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<QuestionBankOptionModel> options;
  final List<QuestionBankFillBlankModel> fillBlanks;
  final List<QuestionBankAttachmentModel> attachments;

  factory QuestionBankQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionBankQuestionModel(
      id: _readInt(json, const ['id', 'questionId']),
      courseId: _readInt(json, const ['courseId']),
      chapterId: _readInt(json, const ['chapterId']),
      questionType: QuestionBankQuestionType.fromJson(json['questionType']),
      difficulty: QuestionBankDifficulty.fromJson(json['difficulty']),
      bloomLevel: QuestionBankBloomLevel.fromJson(json['bloomLevel']),
      status: QuestionBankStatus.fromJson(json['status']),
      questionText: _readNullableString(json, const ['questionText']),
      expectedAnswerText: _readNullableString(json, const [
        'expectedAnswerText',
      ]),
      hints: _readNullableString(json, const ['hints']),
      explanation: _readNullableString(json, const ['explanation']),
      defaultWeight: _readNullableDouble(json, const ['defaultWeight']),
      groupId: _readNullableInt(json, const ['groupId']),
      groupItemOrder: _readNullableInt(json, const ['groupItemOrder']),
      createdAt: _readNullableDate(json, const ['createdAt']),
      updatedAt: _readNullableDate(json, const ['updatedAt']),
      options: _readList(json['options'], QuestionBankOptionModel.fromJson),
      fillBlanks: _readList(
        json['fillBlanks'],
        QuestionBankFillBlankModel.fromJson,
      ),
      attachments: _readList(
        json['attachments'],
        QuestionBankAttachmentModel.fromJson,
      ),
    );
  }

  String get displayText {
    final text = questionText?.trim();
    return text == null || text.isEmpty ? 'Image based question' : text;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    chapterId,
    questionType,
    difficulty,
    bloomLevel,
    status,
    questionText,
    expectedAnswerText,
    hints,
    explanation,
    defaultWeight,
    groupId,
    groupItemOrder,
    createdAt,
    updatedAt,
    options,
    fillBlanks,
    attachments,
  ];
}

class QuestionBankGroupModel extends Equatable {
  const QuestionBankGroupModel({
    required this.id,
    required this.courseId,
    required this.chapterId,
    this.title,
    this.sharedPrompt,
    this.sharedFileId,
    this.groupType,
    this.itemCount = 0,
  });

  final int id;
  final int courseId;
  final int chapterId;
  final String? title;
  final String? sharedPrompt;
  final int? sharedFileId;
  final String? groupType;
  final int itemCount;

  factory QuestionBankGroupModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return QuestionBankGroupModel(
      id: _readInt(json, const ['id', 'groupId']),
      courseId: _readInt(json, const ['courseId']),
      chapterId: _readInt(json, const ['chapterId']),
      title: _readNullableString(json, const ['title']),
      sharedPrompt: _readNullableString(json, const ['sharedPrompt']),
      sharedFileId: _readNullableInt(json, const ['sharedFileId']),
      groupType: _readNullableString(json, const ['groupType']),
      itemCount: items is List
          ? items.length
          : _readInt(json, const ['itemCount', 'questionsCount'], fallback: 0),
    );
  }

  String get displayTitle {
    final value = title?.trim();
    return value == null || value.isEmpty ? 'Untitled group' : value;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    chapterId,
    title,
    sharedPrompt,
    sharedFileId,
    groupType,
    itemCount,
  ];
}

class ExamGenerationRuleModel extends Equatable {
  const ExamGenerationRuleModel({
    required this.chapterId,
    required this.questionType,
    required this.difficulty,
    required this.bloomLevel,
    required this.count,
    required this.weightPerQuestion,
  });

  final int chapterId;
  final QuestionBankQuestionType questionType;
  final QuestionBankDifficulty difficulty;
  final QuestionBankBloomLevel bloomLevel;
  final int count;
  final double weightPerQuestion;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'chapterId': chapterId,
    'questionType': questionType.toJson(),
    'difficulty': difficulty.toJson(),
    'bloomLevel': bloomLevel.toJson(),
    'count': count,
    'weightPerQuestion': weightPerQuestion,
  };

  @override
  List<Object?> get props => <Object?>[
    chapterId,
    questionType,
    difficulty,
    bloomLevel,
    count,
    weightPerQuestion,
  ];
}

class ExamGenerationSectionModel extends Equatable {
  const ExamGenerationSectionModel({
    required this.title,
    required this.totalMarks,
    this.instructions,
    this.answerPolicy = ExamSectionAnswerPolicy.answerAll,
    this.requiredAnswerCount,
    this.rules = const <ExamGenerationRuleModel>[],
  });

  final String title;
  final double totalMarks;
  final String? instructions;
  final ExamSectionAnswerPolicy answerPolicy;
  final int? requiredAnswerCount;
  final List<ExamGenerationRuleModel> rules;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title.trim(),
    'totalMarks': totalMarks,
    if (instructions != null && instructions!.trim().isNotEmpty)
      'instructions': instructions!.trim(),
    'answerPolicy': answerPolicy.toJson(),
    if (requiredAnswerCount != null) 'requiredAnswerCount': requiredAnswerCount,
    'rules': rules.map((item) => item.toJson()).toList(),
  };

  @override
  List<Object?> get props => <Object?>[
    title,
    totalMarks,
    instructions,
    answerPolicy,
    requiredAnswerCount,
    rules,
  ];
}

class ExamResponseModel extends Equatable {
  const ExamResponseModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.status,
    this.totalMarks,
    this.itemCount,
    this.sectionCount,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int courseId;
  final String title;
  final ExamStatus status;
  final double? totalMarks;
  final int? itemCount;
  final int? sectionCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ExamResponseModel.fromJson(Map<String, dynamic> json) {
    return ExamResponseModel(
      id: _readInt(json, const ['id', 'examId']),
      courseId: _readInt(json, const ['courseId']),
      title: _readString(json, const ['title'], fallback: 'Exam'),
      status: ExamStatus.fromJson(json['status']),
      totalMarks: _readNullableDouble(json, const ['totalMarks']),
      itemCount: _readNullableInt(json, const ['itemCount', 'itemsCount']),
      sectionCount: _readNullableInt(json, const [
        'sectionCount',
        'sectionsCount',
      ]),
      createdAt: _readNullableDate(json, const ['createdAt']),
      updatedAt: _readNullableDate(json, const ['updatedAt']),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    title,
    status,
    totalMarks,
    itemCount,
    sectionCount,
    createdAt,
    updatedAt,
  ];

  bool get isDraft => status == ExamStatus.draft;
  bool get isPublished => status == ExamStatus.published;
  bool get isArchived => status == ExamStatus.archived;
  bool get canPublish => isDraft || status == ExamStatus.unpublished;
  bool get canUnpublish => isPublished;
  bool get canArchive => !isArchived;
}

class ExamDraftSectionModel extends Equatable {
  const ExamDraftSectionModel({
    required this.id,
    required this.title,
    required this.sectionOrder,
    this.instructions,
    this.totalMarks,
    this.answerPolicy = ExamSectionAnswerPolicy.answerAll,
    this.requiredAnswerCount,
  });

  final int id;
  final String title;
  final int sectionOrder;
  final String? instructions;
  final double? totalMarks;
  final ExamSectionAnswerPolicy answerPolicy;
  final int? requiredAnswerCount;

  factory ExamDraftSectionModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftSectionModel(
      id: _readInt(json, const ['id', 'draftSectionId']),
      title: _readString(json, const ['title'], fallback: 'Section'),
      sectionOrder: _readInt(json, const ['sectionOrder'], fallback: 0),
      instructions: _readNullableString(json, const ['instructions']),
      totalMarks: _readNullableDouble(json, const ['totalMarks']),
      answerPolicy: ExamSectionAnswerPolicy.fromJson(json['answerPolicy']),
      requiredAnswerCount: _readNullableInt(json, const [
        'requiredAnswerCount',
      ]),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    sectionOrder,
    instructions,
    totalMarks,
    answerPolicy,
    requiredAnswerCount,
  ];
}

class ExamDraftItemModel extends Equatable {
  const ExamDraftItemModel({
    required this.id,
    required this.questionId,
    required this.chapterId,
    required this.questionType,
    required this.difficulty,
    required this.bloomLevel,
    required this.weight,
    required this.weightUnits,
    required this.itemOrder,
    this.draftSectionId,
    this.marks,
    this.overrideReason,
    this.question,
  });

  final int id;
  final int questionId;
  final int chapterId;
  final QuestionBankQuestionType questionType;
  final QuestionBankDifficulty difficulty;
  final QuestionBankBloomLevel bloomLevel;
  final double weight;
  final double weightUnits;
  final int itemOrder;
  final int? draftSectionId;
  final double? marks;
  final String? overrideReason;
  final QuestionBankQuestionModel? question;

  factory ExamDraftItemModel.fromJson(Map<String, dynamic> json) {
    final rawQuestion = json['question'];
    return ExamDraftItemModel(
      id: _readInt(json, const ['id', 'itemId']),
      questionId: _readInt(json, const ['questionId']),
      chapterId: _readInt(json, const ['chapterId']),
      questionType: QuestionBankQuestionType.fromJson(json['questionType']),
      difficulty: QuestionBankDifficulty.fromJson(json['difficulty']),
      bloomLevel: QuestionBankBloomLevel.fromJson(json['bloomLevel']),
      weight: _readDouble(json, const ['weight'], fallback: 1),
      weightUnits: _readDouble(json, const ['weightUnits'], fallback: 1),
      itemOrder: _readInt(json, const ['itemOrder'], fallback: 0),
      draftSectionId: _readNullableInt(json, const ['draftSectionId']),
      marks: _readNullableDouble(json, const ['marks']),
      overrideReason: _readNullableString(json, const ['overrideReason']),
      question: rawQuestion is Map<String, dynamic>
          ? QuestionBankQuestionModel.fromJson(rawQuestion)
          : null,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    questionId,
    chapterId,
    questionType,
    difficulty,
    bloomLevel,
    weight,
    weightUnits,
    itemOrder,
    draftSectionId,
    marks,
    overrideReason,
    question,
  ];
}

class ExamDraftModel extends Equatable {
  const ExamDraftModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.status,
    this.totalMarks,
    this.markDistributionMode = ExamMarkDistributionMode.manual,
    this.seed,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.items = const <ExamDraftItemModel>[],
    this.sections = const <ExamDraftSectionModel>[],
  });

  final int id;
  final int courseId;
  final String title;
  final ExamDraftStatus status;
  final double? totalMarks;
  final ExamMarkDistributionMode markDistributionMode;
  final String? seed;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ExamDraftItemModel> items;
  final List<ExamDraftSectionModel> sections;

  factory ExamDraftModel.fromJson(Map<String, dynamic> json) {
    return ExamDraftModel(
      id: _readInt(json, const ['id', 'draftId']),
      courseId: _readInt(json, const ['courseId']),
      title: _readString(json, const ['title'], fallback: 'Exam draft'),
      status: ExamDraftStatus.fromJson(json['status']),
      totalMarks: _readNullableDouble(json, const ['totalMarks']),
      markDistributionMode: ExamMarkDistributionMode.fromJson(
        json['markDistributionMode'],
      ),
      seed: _readNullableString(json, const ['seed']),
      expiresAt: _readNullableDate(json, const ['expiresAt']),
      createdAt: _readNullableDate(json, const ['createdAt']),
      updatedAt: _readNullableDate(json, const ['updatedAt']),
      items: _readList(json['items'], ExamDraftItemModel.fromJson),
      sections: _readList(json['sections'], ExamDraftSectionModel.fromJson),
    );
  }

  int get itemCount => items.length;

  bool get isExpired {
    final expiry = expiresAt;
    return status == ExamDraftStatus.expired ||
        (expiry != null && DateTime.now().isAfter(expiry));
  }

  bool get isEditable => status == ExamDraftStatus.open && !isExpired;

  Duration? get expiresIn {
    final expiry = expiresAt;
    return expiry?.difference(DateTime.now());
  }

  bool get hasSections => sections.isNotEmpty;

  List<ExamDraftSectionModel> get orderedSections {
    return [...sections]
      ..sort((left, right) => left.sectionOrder.compareTo(right.sectionOrder));
  }

  List<ExamDraftItemModel> get orderedItems {
    return [...items]
      ..sort((left, right) => left.itemOrder.compareTo(right.itemOrder));
  }

  List<ExamDraftItemModel> itemsForSection(int? sectionId) {
    return orderedItems
        .where((item) => item.draftSectionId == sectionId)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    title,
    status,
    totalMarks,
    markDistributionMode,
    seed,
    expiresAt,
    createdAt,
    updatedAt,
    items,
    sections,
  ];
}

class ExamExportModel extends Equatable {
  const ExamExportModel({
    required this.fileName,
    required this.mimeType,
    required this.content,
  });

  final String fileName;
  final String mimeType;
  final String content;

  factory ExamExportModel.fromJson(Map<String, dynamic> json) {
    return ExamExportModel(
      fileName: _readString(json, const ['fileName'], fallback: 'exam.doc'),
      mimeType: _readString(json, const [
        'mimeType',
      ], fallback: 'application/msword'),
      content: _readString(json, const ['content']),
    );
  }

  @override
  List<Object?> get props => <Object?>[fileName, mimeType, content];
}

List<T> _readList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) {
    return <T>[];
  }
  return value
      .whereType<Map<String, dynamic>>()
      .map<T>(fromJson)
      .toList(growable: false);
}

int _readInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  return _readNullableInt(json, keys) ?? fallback;
}

int? _readNullableInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

double _readDouble(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  return _readNullableDouble(json, keys) ?? fallback;
}

double? _readNullableDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  return _readNullableString(json, keys) ?? fallback;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString();
    return text;
  }
  return null;
}

bool _readBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value?.toString().toLowerCase();
    if (raw == 'true' || raw == '1') return true;
    if (raw == 'false' || raw == '0') return false;
  }
  return fallback;
}

DateTime? _readNullableDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}
