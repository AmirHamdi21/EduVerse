class ApiTranscriptResponse {
  final int studentId;
  final String studentName;
  final double cumulativeGpa;
  final int totalCredits;
  final List<ApiTranscriptSemester> semesters;

  const ApiTranscriptResponse({
    required this.studentId,
    required this.studentName,
    required this.cumulativeGpa,
    required this.totalCredits,
    required this.semesters,
  });

  factory ApiTranscriptResponse.fromJson(Map<String, dynamic> json) {
    final semestersRaw = json['semesters'];
    final semestersList = semestersRaw is List
        ? semestersRaw
        : const <dynamic>[];

    return ApiTranscriptResponse(
      studentId: _parseInt(json['studentId']),
      studentName: (json['studentName'] ?? '').toString(),
      cumulativeGpa: _parseDouble(json['cumulativeGpa']),
      totalCredits: _parseInt(json['totalCredits']),
      semesters: semestersList
          .whereType<Map<String, dynamic>>()
          .map(ApiTranscriptSemester.fromJson)
          .toList(),
    );
  }
}

class ApiTranscriptSemester {
  final int semesterId;
  final String semesterName;
  final double gpa;
  final List<ApiTranscriptCourse> courses;

  const ApiTranscriptSemester({
    required this.semesterId,
    required this.semesterName,
    required this.gpa,
    required this.courses,
  });

  factory ApiTranscriptSemester.fromJson(Map<String, dynamic> json) {
    final coursesRaw = json['courses'];
    final coursesList = coursesRaw is List ? coursesRaw : const <dynamic>[];

    return ApiTranscriptSemester(
      semesterId: _parseInt(json['semesterId']),
      semesterName: (json['semesterName'] ?? '').toString(),
      gpa: _parseDouble(json['gpa']),
      courses: coursesList
          .whereType<Map<String, dynamic>>()
          .map(ApiTranscriptCourse.fromJson)
          .toList(),
    );
  }
}

class ApiTranscriptCourse {
  final int courseId;
  final String courseName;
  final int credits;
  final String letterGrade;
  final double score;
  final double maxScore;

  const ApiTranscriptCourse({
    required this.courseId,
    required this.courseName,
    required this.credits,
    required this.letterGrade,
    required this.score,
    required this.maxScore,
  });

  factory ApiTranscriptCourse.fromJson(Map<String, dynamic> json) {
    return ApiTranscriptCourse(
      courseId: _parseInt(json['courseId']),
      courseName: (json['courseName'] ?? '').toString(),
      credits: _parseInt(json['credits']),
      letterGrade: (json['letterGrade'] ?? '').toString(),
      score: _parseDouble(json['score']),
      maxScore: _parseDouble(json['maxScore']),
    );
  }
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

double _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
