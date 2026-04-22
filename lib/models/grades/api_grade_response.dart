class ApiGradeResponse {
  final int id;
  final int userId;
  final int courseId;
  final String gradeType;
  final int? assignmentId;
  final int? quizId;
  final int? labId;
  final double score;
  final double maxScore;
  final double? percentage;
  final String? letterGrade;
  final String? feedback;
  final int? gradedBy;
  final DateTime? gradedAt;
  final int isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ApiCourseInfo course;
  final ApiAssignmentInfo? assignment;

  const ApiGradeResponse({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.gradeType,
    this.assignmentId,
    this.quizId,
    this.labId,
    required this.score,
    required this.maxScore,
    this.percentage,
    this.letterGrade,
    this.feedback,
    this.gradedBy,
    this.gradedAt,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.course,
    this.assignment,
  });

  factory ApiGradeResponse.fromJson(Map<String, dynamic> json) {
    final courseJson = _asMap(json['course']);
    final assignmentJson = _asMap(json['assignment']);

    return ApiGradeResponse(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      courseId: _parseInt(json['courseId']),
      gradeType: (json['gradeType'] ?? '').toString().trim().toLowerCase(),
      assignmentId: _parseNullableInt(json['assignmentId']),
      quizId: _parseNullableInt(json['quizId']),
      labId: _parseNullableInt(json['labId']),
      score: _parseDouble(json['score']),
      maxScore: _parseDouble(json['maxScore']),
      percentage: _parseNullableDouble(json['percentage']),
      letterGrade: _parseNullableString(json['letterGrade']),
      feedback: _parseNullableString(json['feedback']),
      gradedBy: _parseNullableInt(json['gradedBy']),
      gradedAt: _parseNullableDateTime(json['gradedAt']),
      isPublished: _parseInt(json['isPublished']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      course: ApiCourseInfo.fromJson(courseJson),
      assignment: assignmentJson == null
          ? null
          : ApiAssignmentInfo.fromJson(assignmentJson),
    );
  }
}

class ApiCourseInfo {
  final int id;
  final String name;
  final String code;
  final int credits;

  const ApiCourseInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
  });

  factory ApiCourseInfo.fromJson(Map<String, dynamic>? json) {
    return ApiCourseInfo(
      id: _parseInt(json?['id']),
      name: (json?['name'] ?? '').toString(),
      code: (json?['code'] ?? '').toString(),
      credits: _parseInt(json?['credits']),
    );
  }
}

class ApiAssignmentInfo {
  final int id;
  final String title;

  const ApiAssignmentInfo({required this.id, required this.title});

  factory ApiAssignmentInfo.fromJson(Map<String, dynamic>? json) {
    return ApiAssignmentInfo(
      id: _parseInt(json?['id']),
      title: (json?['title'] ?? '').toString(),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

String? _parseNullableString(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
