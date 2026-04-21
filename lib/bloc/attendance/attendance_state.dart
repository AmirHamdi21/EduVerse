import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../../models/attendance/student_attendance_summary_model.dart';
import '../../models/attendance/student_face_reference_model.dart';

enum AttendanceStatus { present, absent, late, excused }

enum ViewMode { calendar, list }

enum FilterOption { all, present, absent, late, excused }

class AttendanceRecord extends Equatable {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;
  final String? lectureTitle;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const AttendanceRecord({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.date,
    required this.status,
    this.note,
    this.lectureTitle,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
    id,
    courseId,
    courseName,
    courseCode,
    date,
    status,
    note,
    lectureTitle,
    startTime,
    endTime,
  ];
}

class CourseAttendance extends Equatable {
  final String courseId;
  final String courseName;
  final String courseCode;
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final List<int> gradientColors;

  const CourseAttendance({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.gradientColors,
  });

  factory CourseAttendance.fromApi(
    StudentAttendanceSummaryModel s,
    List<int> gradientColors,
  ) {
    return CourseAttendance(
      courseId: s.courseId.toString(),
      courseName: s.courseName,
      courseCode: s.courseCode,
      totalClasses: s.totalClasses,
      presentCount: s.attended,
      absentCount: s.absent,
      lateCount: s.lateCount,
      excusedCount: s.excused,
      gradientColors: gradientColors,
    );
  }

  double get attendancePercentage {
    if (totalClasses == 0) return 100.0;
    return ((presentCount + lateCount + excusedCount) / totalClasses) * 100;
  }

  @override
  List<Object?> get props => [
    courseId,
    courseName,
    courseCode,
    totalClasses,
    presentCount,
    absentCount,
    lateCount,
    excusedCount,
    gradientColors,
  ];
}

class AttendanceStatistics extends Equatable {
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final double overallPercentage;
  final List<WeeklyAttendance> weeklyTrend;

  const AttendanceStatistics({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.overallPercentage,
    required this.weeklyTrend,
  });

  @override
  List<Object?> get props => [
    totalClasses,
    presentCount,
    absentCount,
    lateCount,
    excusedCount,
    overallPercentage,
    weeklyTrend,
  ];
}

class WeeklyAttendance extends Equatable {
  final String week;
  final double percentage;

  const WeeklyAttendance({required this.week, required this.percentage});

  @override
  List<Object?> get props => [week, percentage];
}

class AttendanceState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<AttendanceRecord> allRecords;
  final List<AttendanceRecord> filteredRecords;
  final List<CourseAttendance> courseAttendances;
  final AttendanceStatistics? statistics;
  final DateTime selectedDate;
  final String? selectedCourseId;
  final FilterOption filterOption;
  final ViewMode viewMode;
  final int selectedTabIndex;
  final String searchQuery;
  final List<StudentFaceReferenceModel> faceReferences;
  final bool isFaceUploading;
  final String? faceUploadError;

  AttendanceState({
    this.isLoading = false,
    this.errorMessage,
    this.allRecords = const [],
    this.filteredRecords = const [],
    this.courseAttendances = const [],
    this.statistics,
    DateTime? selectedDate,
    this.selectedCourseId,
    this.filterOption = FilterOption.all,
    this.viewMode = ViewMode.calendar,
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.faceReferences = const <StudentFaceReferenceModel>[],
    this.isFaceUploading = false,
    this.faceUploadError,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AttendanceState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<AttendanceRecord>? allRecords,
    List<AttendanceRecord>? filteredRecords,
    List<CourseAttendance>? courseAttendances,
    AttendanceStatistics? statistics,
    DateTime? selectedDate,
    String? selectedCourseId,
    bool clearSelectedCourse = false,
    FilterOption? filterOption,
    ViewMode? viewMode,
    int? selectedTabIndex,
    String? searchQuery,
    List<StudentFaceReferenceModel>? faceReferences,
    bool? isFaceUploading,
    String? faceUploadError,
    bool clearFaceUploadError = false,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      courseAttendances: courseAttendances ?? this.courseAttendances,
      statistics: statistics ?? this.statistics,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCourseId: clearSelectedCourse
          ? null
          : selectedCourseId ?? this.selectedCourseId,
      filterOption: filterOption ?? this.filterOption,
      viewMode: viewMode ?? this.viewMode,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      faceReferences: faceReferences ?? this.faceReferences,
      isFaceUploading: isFaceUploading ?? this.isFaceUploading,
      faceUploadError: clearFaceUploadError
          ? null
          : faceUploadError ?? this.faceUploadError,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    allRecords,
    filteredRecords,
    courseAttendances,
    statistics,
    selectedDate,
    selectedCourseId,
    filterOption,
    viewMode,
    selectedTabIndex,
    searchQuery,
    faceReferences,
    isFaceUploading,
    faceUploadError,
  ];
}
