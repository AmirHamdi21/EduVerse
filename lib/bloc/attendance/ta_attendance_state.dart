import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../models/attendance/ai_processing_result_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/instructor/teaching_course_model.dart';

enum TAAttendanceView { upload, processing, results, history }

class DetectedStudentRow extends Equatable {
  final int userId;
  final String name;
  final String email;
  final String status;
  final double? confidence;

  const DetectedStudentRow({
    required this.userId,
    required this.name,
    required this.email,
    required this.status,
    this.confidence,
  });

  DetectedStudentRow copyWith({
    int? userId,
    String? name,
    String? email,
    String? status,
    double? confidence,
  }) {
    return DetectedStudentRow(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  List<Object?> get props => [userId, name, email, status, confidence];
}

class TAAttendanceState extends Equatable {
  final TAAttendanceView view;
  final bool isLoading;
  final String? error;

  final List<TeachingCourseModel> availableLabs;
  final int? selectedSectionId;
  final String selectedLab;
  final String selectedCourse;
  final File? selectedFile;

  final double processingProgress;

  final List<DetectedStudentRow> detectedStudents;
  final int totalDetected;
  final int totalStudents;
  final bool isEditing;

  final List<AttendanceSessionModel> pastSessions;
  final AttendanceSessionModel? activeSession;
  final AiProcessingResultModel? aiResult;

  const TAAttendanceState({
    this.view = TAAttendanceView.upload,
    this.isLoading = false,
    this.error,
    this.availableLabs = const <TeachingCourseModel>[],
    this.selectedSectionId,
    this.selectedLab = '',
    this.selectedCourse = '',
    this.selectedFile,
    this.processingProgress = 0,
    this.detectedStudents = const <DetectedStudentRow>[],
    this.totalDetected = 0,
    this.totalStudents = 0,
    this.isEditing = false,
    this.pastSessions = const <AttendanceSessionModel>[],
    this.activeSession,
    this.aiResult,
  });

  TAAttendanceState copyWith({
    TAAttendanceView? view,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<TeachingCourseModel>? availableLabs,
    int? selectedSectionId,
    bool clearSelectedSectionId = false,
    String? selectedLab,
    String? selectedCourse,
    File? selectedFile,
    bool clearSelectedFile = false,
    double? processingProgress,
    List<DetectedStudentRow>? detectedStudents,
    int? totalDetected,
    int? totalStudents,
    bool? isEditing,
    List<AttendanceSessionModel>? pastSessions,
    AttendanceSessionModel? activeSession,
    bool clearActiveSession = false,
    AiProcessingResultModel? aiResult,
    bool clearAiResult = false,
  }) {
    return TAAttendanceState(
      view: view ?? this.view,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      availableLabs: availableLabs ?? this.availableLabs,
      selectedSectionId: clearSelectedSectionId
          ? null
          : selectedSectionId ?? this.selectedSectionId,
      selectedLab: selectedLab ?? this.selectedLab,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      selectedFile: clearSelectedFile
          ? null
          : selectedFile ?? this.selectedFile,
      processingProgress: processingProgress ?? this.processingProgress,
      detectedStudents: detectedStudents ?? this.detectedStudents,
      totalDetected: totalDetected ?? this.totalDetected,
      totalStudents: totalStudents ?? this.totalStudents,
      isEditing: isEditing ?? this.isEditing,
      pastSessions: pastSessions ?? this.pastSessions,
      activeSession: clearActiveSession
          ? null
          : activeSession ?? this.activeSession,
      aiResult: clearAiResult ? null : aiResult ?? this.aiResult,
    );
  }

  @override
  List<Object?> get props => [
    view,
    isLoading,
    error,
    availableLabs,
    selectedSectionId,
    selectedLab,
    selectedCourse,
    selectedFile,
    processingProgress,
    detectedStudents,
    totalDetected,
    totalStudents,
    isEditing,
    pastSessions,
    activeSession,
    aiResult,
  ];
}
