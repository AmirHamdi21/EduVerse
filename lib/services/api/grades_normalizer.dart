import 'package:flutter/material.dart';

import '../../models/grades/api_grade_response.dart';
import '../../models/grades/grade_model.dart';

class GradesNormalizer {
  static const String _defaultSemesterId = 'fall_2025';

  static const List<Color> _coursePalette = <Color>[
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
    Color(0xFF0EA5E9),
  ];

  static List<CourseGrade> groupByCourse(List<ApiGradeResponse> grades) {
    if (grades.isEmpty) {
      return const <CourseGrade>[];
    }

    final grouped = <int, List<ApiGradeResponse>>{};
    for (final grade in grades) {
      grouped
          .putIfAbsent(grade.courseId, () => <ApiGradeResponse>[])
          .add(grade);
    }

    final courses = <CourseGrade>[];

    for (final entry in grouped.entries) {
      final courseGrades = entry.value.toList()
        ..sort((a, b) {
          final aDate = a.gradedAt ?? a.createdAt;
          final bDate = b.gradedAt ?? b.createdAt;
          return aDate.compareTo(bDate);
        });

      if (courseGrades.isEmpty) {
        continue;
      }

      final base = courseGrades.first;
      final totalMaxScore = courseGrades.fold<double>(
        0.0,
        (sum, item) => sum + (item.maxScore > 0 ? item.maxScore : 0),
      );
      final assessmentCount = courseGrades.length;

      final assessments = <AssessmentGrade>[];
      for (var i = 0; i < courseGrades.length; i++) {
        final grade = courseGrades[i];
        final computedWeight = totalMaxScore > 0
            ? (grade.maxScore / totalMaxScore) * 100
            : (assessmentCount > 0 ? 100.0 / assessmentCount : 0.0);

        assessments.add(
          AssessmentGrade(
            id: grade.id.toString(),
            name: _assessmentName(grade, i),
            type: mapGradeType(grade.gradeType),
            score: grade.score,
            maxScore: grade.maxScore,
            weight: computedWeight,
            gradedDate: grade.gradedAt,
            feedback: grade.feedback,
            isGraded: grade.isPublished == 1,
          ),
        );
      }

      courses.add(
        CourseGrade(
          id: base.courseId.toString(),
          courseCode: base.course.code.isNotEmpty
              ? base.course.code
              : 'C-${base.courseId}',
          courseName: base.course.name.isNotEmpty
              ? base.course.name
              : 'Course ${base.courseId}',
          instructor: 'Instructor',
          creditHours: base.course.credits > 0 ? base.course.credits : 3,
          semesterId: _defaultSemesterId,
          assessments: assessments,
          courseColor: courseColor(base.courseId),
        ),
      );
    }

    courses.sort((a, b) => a.courseName.compareTo(b.courseName));
    return courses;
  }

  static GradeStatistics computeStatistics(List<CourseGrade> courses) {
    if (courses.isEmpty) {
      return const GradeStatistics(
        cumulativeGPA: 0,
        semesterGPA: 0,
        totalCredits: 0,
        completedCredits: 0,
        totalCourses: 0,
        passedCourses: 0,
        highestGrade: GradeLetter.pending,
        lowestGrade: GradeLetter.pending,
        averagePercentage: 0,
        gradeDistribution: <GradeLetter, int>{},
      );
    }

    double totalGpaPoints = 0;
    int totalCredits = 0;
    int completedCredits = 0;
    int passedCourses = 0;
    double totalPercentage = 0;
    GradeLetter? highest;
    GradeLetter? lowest;
    final distribution = <GradeLetter, int>{};

    for (final course in courses) {
      if (course.gradedCount <= 0) {
        continue;
      }

      final currentGrade = course.currentGrade;
      totalCredits += course.creditHours;
      totalGpaPoints += currentGrade.gpa * course.creditHours;
      totalPercentage += course.currentPercentage;

      if (course.pendingCount == 0) {
        completedCredits += course.creditHours;
      }

      if (course.currentPercentage >= 60) {
        passedCourses += 1;
      }

      distribution[currentGrade] = (distribution[currentGrade] ?? 0) + 1;

      if (highest == null || currentGrade.gpa > highest.gpa) {
        highest = currentGrade;
      }
      if (lowest == null || currentGrade.gpa < lowest.gpa) {
        lowest = currentGrade;
      }
    }

    final totalCourses = courses.length;
    final computedGpa = totalCredits > 0 ? totalGpaPoints / totalCredits : 0.0;

    return GradeStatistics(
      cumulativeGPA: computedGpa,
      semesterGPA: computedGpa,
      totalCredits: totalCredits,
      completedCredits: completedCredits,
      totalCourses: totalCourses,
      passedCourses: passedCourses,
      highestGrade: highest ?? GradeLetter.pending,
      lowestGrade: lowest ?? GradeLetter.pending,
      averagePercentage: totalCourses > 0 ? totalPercentage / totalCourses : 0.0,
      gradeDistribution: distribution,
    );
  }

  static AssessmentType mapGradeType(String rawType) {
    switch (rawType.toLowerCase().trim()) {
      case 'assignment':
        return AssessmentType.assignment;
      case 'quiz':
        return AssessmentType.quiz;
      case 'lab':
        return AssessmentType.lab;
      case 'exam':
        return AssessmentType.exam;
      case 'final':
        return AssessmentType.finalExam;
      case 'participation':
        return AssessmentType.participation;
      case 'project':
        return AssessmentType.project;
      case 'presentation':
        return AssessmentType.presentation;
      case 'midterm':
        return AssessmentType.midterm;
      case 'other':
      default:
        return AssessmentType.exam;
    }
  }

  static Color courseColor(int courseId) {
    final normalizedIndex = courseId.abs() % _coursePalette.length;
    return _coursePalette[normalizedIndex];
  }

  static String _assessmentName(ApiGradeResponse grade, int index) {
    final assignmentTitle = grade.assignment?.title.trim();
    if (assignmentTitle != null && assignmentTitle.isNotEmpty) {
      return assignmentTitle;
    }

    final label = mapGradeType(grade.gradeType).label;
    return '$label ${index + 1}';
  }
}
