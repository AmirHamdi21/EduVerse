import 'package:flutter/material.dart';

/// Grade letter enumeration
enum GradeLetter {
  aPlus,
  a,
  aMinus,
  bPlus,
  b,
  bMinus,
  cPlus,
  c,
  cMinus,
  dPlus,
  d,
  f,
  pending,
}

extension GradeLetterExtension on GradeLetter {
  String get label {
    switch (this) {
      case GradeLetter.aPlus:
        return 'A+';
      case GradeLetter.a:
        return 'A';
      case GradeLetter.aMinus:
        return 'A-';
      case GradeLetter.bPlus:
        return 'B+';
      case GradeLetter.b:
        return 'B';
      case GradeLetter.bMinus:
        return 'B-';
      case GradeLetter.cPlus:
        return 'C+';
      case GradeLetter.c:
        return 'C';
      case GradeLetter.cMinus:
        return 'C-';
      case GradeLetter.dPlus:
        return 'D+';
      case GradeLetter.d:
        return 'D';
      case GradeLetter.f:
        return 'F';
      case GradeLetter.pending:
        return '-';
    }
  }

  Color get color {
    switch (this) {
      case GradeLetter.aPlus:
      case GradeLetter.a:
        return const Color(0xFF10B981);
      case GradeLetter.aMinus:
      case GradeLetter.bPlus:
        return const Color(0xFF22C55E);
      case GradeLetter.b:
      case GradeLetter.bMinus:
        return const Color(0xFF84CC16);
      case GradeLetter.cPlus:
      case GradeLetter.c:
        return const Color(0xFFEAB308);
      case GradeLetter.cMinus:
      case GradeLetter.dPlus:
        return const Color(0xFFF97316);
      case GradeLetter.d:
        return const Color(0xFFEF4444);
      case GradeLetter.f:
        return const Color(0xFFDC2626);
      case GradeLetter.pending:
        return const Color(0xFF94A3B8);
    }
  }

  double get gpa {
    switch (this) {
      case GradeLetter.aPlus:
        return 4.0;
      case GradeLetter.a:
        return 4.0;
      case GradeLetter.aMinus:
        return 3.7;
      case GradeLetter.bPlus:
        return 3.3;
      case GradeLetter.b:
        return 3.0;
      case GradeLetter.bMinus:
        return 2.7;
      case GradeLetter.cPlus:
        return 2.3;
      case GradeLetter.c:
        return 2.0;
      case GradeLetter.cMinus:
        return 1.7;
      case GradeLetter.dPlus:
        return 1.3;
      case GradeLetter.d:
        return 1.0;
      case GradeLetter.f:
        return 0.0;
      case GradeLetter.pending:
        return 0.0;
    }
  }
}

/// Assessment type enumeration
enum AssessmentType {
  exam,
  quiz,
  assignment,
  project,
  lab,
  presentation,
  midterm,
  finalExam,
  participation,
}

extension AssessmentTypeExtension on AssessmentType {
  String get label {
    switch (this) {
      case AssessmentType.exam:
        return 'Exam';
      case AssessmentType.quiz:
        return 'Quiz';
      case AssessmentType.assignment:
        return 'Assignment';
      case AssessmentType.project:
        return 'Project';
      case AssessmentType.lab:
        return 'Lab';
      case AssessmentType.presentation:
        return 'Presentation';
      case AssessmentType.midterm:
        return 'Midterm';
      case AssessmentType.finalExam:
        return 'Final Exam';
      case AssessmentType.participation:
        return 'Participation';
    }
  }

  IconData get icon {
    switch (this) {
      case AssessmentType.exam:
        return Icons.assignment_rounded;
      case AssessmentType.quiz:
        return Icons.quiz_rounded;
      case AssessmentType.assignment:
        return Icons.article_rounded;
      case AssessmentType.project:
        return Icons.folder_special_rounded;
      case AssessmentType.lab:
        return Icons.science_rounded;
      case AssessmentType.presentation:
        return Icons.present_to_all_rounded;
      case AssessmentType.midterm:
        return Icons.event_note_rounded;
      case AssessmentType.finalExam:
        return Icons.school_rounded;
      case AssessmentType.participation:
        return Icons.groups_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AssessmentType.exam:
        return const Color(0xFF6366F1);
      case AssessmentType.quiz:
        return const Color(0xFF8B5CF6);
      case AssessmentType.assignment:
        return const Color(0xFF3B82F6);
      case AssessmentType.project:
        return const Color(0xFF10B981);
      case AssessmentType.lab:
        return const Color(0xFF14B8A6);
      case AssessmentType.presentation:
        return const Color(0xFFF59E0B);
      case AssessmentType.midterm:
        return const Color(0xFFEC4899);
      case AssessmentType.finalExam:
        return const Color(0xFFEF4444);
      case AssessmentType.participation:
        return const Color(0xFF64748B);
    }
  }
}

/// Semester model
class SemesterModel {
  final String id;
  final String name;
  final String year;
  final bool isCurrent;
  final DateTime startDate;
  final DateTime endDate;

  const SemesterModel({
    required this.id,
    required this.name,
    required this.year,
    this.isCurrent = false,
    required this.startDate,
    required this.endDate,
  });

  SemesterModel copyWith({
    String? id,
    String? name,
    String? year,
    bool? isCurrent,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      isCurrent: isCurrent ?? this.isCurrent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Assessment grade model
class AssessmentGrade {
  final String id;
  final String name;
  final AssessmentType type;
  final double score;
  final double maxScore;
  final double weight;
  final DateTime? gradedDate;
  final String? feedback;
  final bool isGraded;

  const AssessmentGrade({
    required this.id,
    required this.name,
    required this.type,
    required this.score,
    required this.maxScore,
    required this.weight,
    this.gradedDate,
    this.feedback,
    this.isGraded = true,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;
  double get weightedScore => (percentage / 100) * weight;

  GradeLetter get gradeLetter {
    if (!isGraded) return GradeLetter.pending;
    if (percentage >= 97) return GradeLetter.aPlus;
    if (percentage >= 93) return GradeLetter.a;
    if (percentage >= 90) return GradeLetter.aMinus;
    if (percentage >= 87) return GradeLetter.bPlus;
    if (percentage >= 83) return GradeLetter.b;
    if (percentage >= 80) return GradeLetter.bMinus;
    if (percentage >= 77) return GradeLetter.cPlus;
    if (percentage >= 73) return GradeLetter.c;
    if (percentage >= 70) return GradeLetter.cMinus;
    if (percentage >= 67) return GradeLetter.dPlus;
    if (percentage >= 60) return GradeLetter.d;
    return GradeLetter.f;
  }

  AssessmentGrade copyWith({
    String? id,
    String? name,
    AssessmentType? type,
    double? score,
    double? maxScore,
    double? weight,
    DateTime? gradedDate,
    String? feedback,
    bool? isGraded,
  }) {
    return AssessmentGrade(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      gradedDate: gradedDate ?? this.gradedDate,
      feedback: feedback ?? this.feedback,
      isGraded: isGraded ?? this.isGraded,
    );
  }
}

/// Course grade model
class CourseGrade {
  final String id;
  final String courseCode;
  final String courseName;
  final String instructor;
  final int creditHours;
  final String semesterId;
  final List<AssessmentGrade> assessments;
  final Color courseColor;
  final String? imageUrl;

  const CourseGrade({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.instructor,
    required this.creditHours,
    required this.semesterId,
    required this.assessments,
    required this.courseColor,
    this.imageUrl,
  });

  double get totalScore {
    if (assessments.isEmpty) return 0;
    return assessments
        .where((a) => a.isGraded)
        .fold(0.0, (sum, a) => sum + a.weightedScore);
  }

  double get maxPossibleScore {
    if (assessments.isEmpty) return 0;
    return assessments
        .where((a) => a.isGraded)
        .fold(0.0, (sum, a) => sum + a.weight);
  }

  double get currentPercentage {
    if (maxPossibleScore == 0) return 0;
    return (totalScore / maxPossibleScore) * 100;
  }

  double get projectedPercentage {
    if (assessments.isEmpty) return 0;
    final gradedWeight = assessments
        .where((a) => a.isGraded)
        .fold(0.0, (sum, a) => sum + a.weight);
    if (gradedWeight == 0) return 0;
    return totalScore / gradedWeight * 100;
  }

  GradeLetter get currentGrade {
    final pct = currentPercentage;
    if (pct >= 97) return GradeLetter.aPlus;
    if (pct >= 93) return GradeLetter.a;
    if (pct >= 90) return GradeLetter.aMinus;
    if (pct >= 87) return GradeLetter.bPlus;
    if (pct >= 83) return GradeLetter.b;
    if (pct >= 80) return GradeLetter.bMinus;
    if (pct >= 77) return GradeLetter.cPlus;
    if (pct >= 73) return GradeLetter.c;
    if (pct >= 70) return GradeLetter.cMinus;
    if (pct >= 67) return GradeLetter.dPlus;
    if (pct >= 60) return GradeLetter.d;
    return GradeLetter.f;
  }

  int get gradedCount => assessments.where((a) => a.isGraded).length;
  int get pendingCount => assessments.where((a) => !a.isGraded).length;

  CourseGrade copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    String? instructor,
    int? creditHours,
    String? semesterId,
    List<AssessmentGrade>? assessments,
    Color? courseColor,
    String? imageUrl,
  }) {
    return CourseGrade(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      instructor: instructor ?? this.instructor,
      creditHours: creditHours ?? this.creditHours,
      semesterId: semesterId ?? this.semesterId,
      assessments: assessments ?? this.assessments,
      courseColor: courseColor ?? this.courseColor,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Overall grade statistics
class GradeStatistics {
  final double cumulativeGPA;
  final double semesterGPA;
  final int totalCredits;
  final int completedCredits;
  final int totalCourses;
  final int passedCourses;
  final GradeLetter highestGrade;
  final GradeLetter lowestGrade;
  final double averagePercentage;
  final Map<GradeLetter, int> gradeDistribution;

  const GradeStatistics({
    required this.cumulativeGPA,
    required this.semesterGPA,
    required this.totalCredits,
    required this.completedCredits,
    required this.totalCourses,
    required this.passedCourses,
    required this.highestGrade,
    required this.lowestGrade,
    required this.averagePercentage,
    required this.gradeDistribution,
  });

  double get passRate =>
      totalCourses > 0 ? (passedCourses / totalCourses) * 100 : 0;
  double get creditCompletionRate =>
      totalCredits > 0 ? (completedCredits / totalCredits) * 100 : 0;
}

/// Grade trend data point
class GradeTrendPoint {
  final String semesterName;
  final double gpa;
  final int creditHours;

  const GradeTrendPoint({
    required this.semesterName,
    required this.gpa,
    required this.creditHours,
  });
}
