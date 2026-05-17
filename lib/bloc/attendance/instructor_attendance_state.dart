import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../models/attendance/ai_processing_result_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/instructor/teaching_course_model.dart';

enum InstructorAttendanceView { classes, section, roster }

enum AttendanceUiMode { lecture, sessions }

class RosterRow extends Equatable {
  final int userId;
  final String name;
  final String email;
  final String status;
  final String initialStatus;
  final double? aiConfidence;
  final bool isAiMarked;

  const RosterRow({
    required this.userId,
    required this.name,
    required this.email,
    required this.status,
    required this.initialStatus,
    this.aiConfidence,
    this.isAiMarked = false,
  });

  bool get isDirty => status != initialStatus;

  String get aiSuggestedStatus => isAiMarked ? 'present' : 'absent';

  double? get aiConfidencePercent {
    final confidence = aiConfidence;
    if (confidence == null) {
      return isAiMarked && aiSuggestedStatus == 'present' ? 90 : null;
    }
    return confidence <= 1 ? confidence * 100 : confidence;
  }

  bool get needsAiReview =>
      aiSuggestedStatus != 'present' ||
      aiConfidencePercent == null ||
      aiConfidencePercent! < 85;

  RosterRow copyWith({
    int? userId,
    String? name,
    String? email,
    String? status,
    String? initialStatus,
    double? aiConfidence,
    bool? isAiMarked,
  }) {
    return RosterRow(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      initialStatus: initialStatus ?? this.initialStatus,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      isAiMarked: isAiMarked ?? this.isAiMarked,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    userId,
    name,
    email,
    status,
    initialStatus,
    aiConfidence,
    isAiMarked,
  ];
}

class AiReviewRow extends Equatable {
  final int userId;
  final String name;
  final String suggestedStatus;
  final double? confidencePercent;
  final bool needsReview;

  const AiReviewRow({
    required this.userId,
    required this.name,
    required this.suggestedStatus,
    required this.confidencePercent,
    required this.needsReview,
  });

  @override
  List<Object?> get props => <Object?>[
    userId,
    name,
    suggestedStatus,
    confidencePercent,
    needsReview,
  ];
}

class InstructorAttendanceState extends Equatable {
  final InstructorAttendanceView view;
  final AttendanceUiMode uiMode;
  final bool isLoading;
  final String? error;
  final List<TeachingCourseModel> teachingSections;
  final int? selectedSectionId;
  final TeachingCourseModel? selectedSection;
  final List<AttendanceSessionModel> sessions;
  final String newSessionDate;
  final String newSessionType;
  final AttendanceSessionModel? activeSession;
  final List<RosterRow> rosterRows;
  final bool isRosterReadOnly;
  final bool isRosterDirty;
  final bool isAiLoading;
  final String? aiError;
  final AiProcessingResultModel? aiResult;
  final int aiUnknownCount;
  final File? aiPhoto;

  const InstructorAttendanceState({
    this.view = InstructorAttendanceView.classes,
    this.uiMode = AttendanceUiMode.lecture,
    this.isLoading = false,
    this.error,
    this.teachingSections = const <TeachingCourseModel>[],
    this.selectedSectionId,
    this.selectedSection,
    this.sessions = const <AttendanceSessionModel>[],
    this.newSessionDate = '',
    this.newSessionType = 'lecture',
    this.activeSession,
    this.rosterRows = const <RosterRow>[],
    this.isRosterReadOnly = false,
    this.isRosterDirty = false,
    this.isAiLoading = false,
    this.aiError,
    this.aiResult,
    this.aiUnknownCount = 0,
    this.aiPhoto,
  });

  List<AttendanceSessionModel> get openSessions => sessions
      .where(
        (session) =>
            session.status == 'scheduled' || session.status == 'in_progress',
      )
      .toList();

  List<AiReviewRow> get aiReviewRows {
    if (aiResult == null) {
      return const <AiReviewRow>[];
    }

    return rosterRows
        .map(
          (row) => AiReviewRow(
            userId: row.userId,
            name: row.name,
            suggestedStatus: row.aiSuggestedStatus,
            confidencePercent: row.aiConfidencePercent,
            needsReview: row.needsAiReview,
          ),
        )
        .toList();
  }

  List<AiReviewRow> get aiNeedsReviewRows {
    final rows = aiReviewRows.where((row) => row.needsReview).toList();
    rows.sort((a, b) {
      final left = a.confidencePercent ?? -1;
      final right = b.confidencePercent ?? -1;
      if (left != right) {
        return left.compareTo(right);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return rows;
  }

  List<RosterRow> get displayedRosterRows {
    if (aiResult == null || aiNeedsReviewRows.isEmpty) {
      return rosterRows;
    }

    final reviewIds = aiNeedsReviewRows.map((row) => row.userId).toSet();
    final rows = <RosterRow>[...rosterRows];
    rows.sort((a, b) {
      final leftPriority = reviewIds.contains(a.userId) ? 0 : 1;
      final rightPriority = reviewIds.contains(b.userId) ? 0 : 1;
      if (leftPriority != rightPriority) {
        return leftPriority.compareTo(rightPriority);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return rows;
  }

  InstructorAttendanceState copyWith({
    InstructorAttendanceView? view,
    AttendanceUiMode? uiMode,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<TeachingCourseModel>? teachingSections,
    int? selectedSectionId,
    bool clearSelectedSectionId = false,
    TeachingCourseModel? selectedSection,
    bool clearSelectedSection = false,
    List<AttendanceSessionModel>? sessions,
    String? newSessionDate,
    String? newSessionType,
    AttendanceSessionModel? activeSession,
    bool clearActiveSession = false,
    List<RosterRow>? rosterRows,
    bool? isRosterReadOnly,
    bool? isRosterDirty,
    bool? isAiLoading,
    String? aiError,
    bool clearAiError = false,
    AiProcessingResultModel? aiResult,
    bool clearAiResult = false,
    int? aiUnknownCount,
    File? aiPhoto,
    bool clearAiPhoto = false,
  }) {
    return InstructorAttendanceState(
      view: view ?? this.view,
      uiMode: uiMode ?? this.uiMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      teachingSections: teachingSections ?? this.teachingSections,
      selectedSectionId: clearSelectedSectionId
          ? null
          : selectedSectionId ?? this.selectedSectionId,
      selectedSection: clearSelectedSection
          ? null
          : selectedSection ?? this.selectedSection,
      sessions: sessions ?? this.sessions,
      newSessionDate: newSessionDate ?? this.newSessionDate,
      newSessionType: newSessionType ?? this.newSessionType,
      activeSession: clearActiveSession
          ? null
          : activeSession ?? this.activeSession,
      rosterRows: rosterRows ?? this.rosterRows,
      isRosterReadOnly: isRosterReadOnly ?? this.isRosterReadOnly,
      isRosterDirty: isRosterDirty ?? this.isRosterDirty,
      isAiLoading: isAiLoading ?? this.isAiLoading,
      aiError: clearAiError ? null : aiError ?? this.aiError,
      aiResult: clearAiResult ? null : aiResult ?? this.aiResult,
      aiUnknownCount: aiUnknownCount ?? this.aiUnknownCount,
      aiPhoto: clearAiPhoto ? null : aiPhoto ?? this.aiPhoto,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    view,
    uiMode,
    isLoading,
    error,
    teachingSections,
    selectedSectionId,
    selectedSection,
    sessions,
    newSessionDate,
    newSessionType,
    activeSession,
    rosterRows,
    isRosterReadOnly,
    isRosterDirty,
    isAiLoading,
    aiError,
    aiResult,
    aiUnknownCount,
    aiPhoto,
  ];
}
