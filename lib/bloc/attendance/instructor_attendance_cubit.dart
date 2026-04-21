import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../services/api/attendance_service.dart';
import '../../services/api/enrollment_service.dart';
import 'instructor_attendance_state.dart';

class InstructorAttendanceCubit extends Cubit<InstructorAttendanceState> {
  final AttendanceService _attendanceService;
  final EnrollmentService _enrollmentService;

  InstructorAttendanceCubit({
    required AttendanceService attendanceService,
    required EnrollmentService enrollmentService,
  }) : _attendanceService = attendanceService,
       _enrollmentService = enrollmentService,
       super(
         InstructorAttendanceState(newSessionDate: _dateOnly(DateTime.now())),
       );

  Future<void> loadTeachingSections() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _enrollmentService.getTeachingCourses();
    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          isLoading: false,
          view: InstructorAttendanceView.classes,
          teachingSections: result.data!,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load teaching sections',
        ),
      );
    }
  }

  Future<void> openSection(TeachingCourseModel section, int sectionId) async {
    emit(
      state.copyWith(
        selectedSection: section,
        selectedSectionId: sectionId,
        view: InstructorAttendanceView.section,
      ),
    );
    await loadSessionsForSection(sectionId);
  }

  Future<void> loadSessionsForSection(int sectionId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.getSessions(
      sectionId: sectionId,
      limit: 30,
      sortBy: 'sessionDate',
      sortOrder: 'DESC',
    );

    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          isLoading: false,
          sessions: result.data!,
          view: InstructorAttendanceView.section,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load sessions',
        ),
      );
    }
  }

  void updateNewSessionDate(String date) {
    emit(state.copyWith(newSessionDate: date));
  }

  void updateNewSessionType(String type) {
    emit(state.copyWith(newSessionType: type));
  }

  Future<void> createSession() async {
    final sectionId = state.selectedSectionId;
    if (sectionId == null) {
      emit(state.copyWith(error: 'Select a section first'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.createSession(
      sectionId: sectionId,
      sessionDate: state.newSessionDate,
      sessionType: state.newSessionType,
    );

    if (result.isSuccess) {
      await loadSessionsForSection(sectionId);
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to create session',
        ),
      );
    }
  }

  Future<void> openRosterFromSession(AttendanceSessionModel session) async {
    await loadRosterData(session.id, session.isClosed);
  }

  Future<void> loadRosterData(int sessionId, bool readOnly) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final sessionResult = await _attendanceService.getSessionDetails(sessionId);
    if (!sessionResult.isSuccess || sessionResult.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error:
              sessionResult.error?.message ?? 'Failed to load session roster',
        ),
      );
      return;
    }

    final session = sessionResult.data!;
    final statusByUser = <int, AttendanceRecordModel>{
      for (final record in session.records) record.userId: record,
    };

    List<RosterRow> rows = <RosterRow>[];

    final selectedSectionId = state.selectedSectionId;
    if (selectedSectionId != null) {
      final sectionStudents = await _enrollmentService.getSectionStudentsLite(
        selectedSectionId,
      );
      if (sectionStudents.isSuccess && sectionStudents.data != null) {
        rows = sectionStudents.data!.map((SectionStudentModel student) {
          final matched = statusByUser[student.userId];
          final status = AttendanceRecordModel.normalizeStatus(
            matched?.attendanceStatus,
          );
          final name = student.displayName.trim().isEmpty
              ? (matched?.displayName ?? 'Student #${student.userId}')
              : student.displayName;

          return RosterRow(
            userId: student.userId,
            name: name,
            email: student.email ?? '',
            status: status,
            initialStatus: status,
            aiConfidence: matched?.confidenceScore,
            isAiMarked: (matched?.markedBy ?? '').toLowerCase() == 'ai',
          );
        }).toList();
      }
    }

    if (rows.isEmpty) {
      rows = session.records.map((record) {
        final status = AttendanceRecordModel.normalizeStatus(
          record.attendanceStatus,
        );
        return RosterRow(
          userId: record.userId,
          name: record.displayName,
          email: record.email ?? '',
          status: status,
          initialStatus: status,
          aiConfidence: record.confidenceScore,
          isAiMarked: (record.markedBy ?? '').toLowerCase() == 'ai',
        );
      }).toList();
    }

    emit(
      state.copyWith(
        isLoading: false,
        view: InstructorAttendanceView.roster,
        activeSession: session,
        rosterRows: rows,
        isRosterReadOnly: readOnly,
        isRosterDirty: rows.any((e) => e.isDirty),
        clearAiError: true,
      ),
    );
  }

  void backToClasses() {
    emit(
      state.copyWith(
        view: InstructorAttendanceView.classes,
        clearSelectedSection: true,
        clearSelectedSectionId: true,
        sessions: const <AttendanceSessionModel>[],
        clearActiveSession: true,
        rosterRows: const <RosterRow>[],
        isRosterReadOnly: false,
        isRosterDirty: false,
        clearAiPhoto: true,
        clearAiError: true,
        clearAiResult: true,
      ),
    );
  }

  void backToSection() {
    emit(
      state.copyWith(
        view: InstructorAttendanceView.section,
        clearActiveSession: true,
        rosterRows: const <RosterRow>[],
        isRosterReadOnly: false,
        isRosterDirty: false,
        clearAiPhoto: true,
        clearAiError: true,
        clearAiResult: true,
      ),
    );
  }

  void applyStatus(int userId, String status) {
    if (state.isRosterReadOnly) return;

    final normalized = AttendanceRecordModel.normalizeStatus(status);
    final nextRows = state.rosterRows.map((row) {
      if (row.userId != userId) return row;
      return row.copyWith(status: normalized);
    }).toList();

    emit(
      state.copyWith(
        rosterRows: nextRows,
        isRosterDirty: nextRows.any((r) => r.isDirty),
      ),
    );
  }

  void setAllStatus(String status) {
    if (state.isRosterReadOnly) return;
    final normalized = AttendanceRecordModel.normalizeStatus(status);
    final nextRows = state.rosterRows
        .map((row) => row.copyWith(status: normalized))
        .toList();

    emit(
      state.copyWith(
        rosterRows: nextRows,
        isRosterDirty: nextRows.any((r) => r.isDirty),
      ),
    );
  }

  Future<void> saveBatch() async {
    final session = state.activeSession;
    if (session == null) {
      emit(state.copyWith(error: 'No active session selected'));
      return;
    }

    final payload = state.rosterRows
        .map(
          (r) => <String, dynamic>{
            'userId': r.userId,
            'attendanceStatus': r.status,
          },
        )
        .toList();

    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.markBatchAttendance(
      sessionId: session.id,
      records: payload,
    );

    if (result.isSuccess) {
      await loadRosterData(session.id, state.isRosterReadOnly);
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to save attendance',
        ),
      );
    }
  }

  Future<void> closeSession() async {
    final session = state.activeSession;
    if (session == null) {
      emit(state.copyWith(error: 'No active session selected'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.closeSession(session.id);
    if (result.isSuccess) {
      final selectedSectionId = state.selectedSectionId;
      if (selectedSectionId != null) {
        await loadSessionsForSection(selectedSectionId);
      }

      final refreshed = await _attendanceService.getSessionDetails(session.id);
      emit(
        state.copyWith(
          isLoading: false,
          activeSession:
              refreshed.data ?? session.copyWith(status: 'completed'),
          isRosterReadOnly: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to close session',
        ),
      );
    }
  }

  void setAiFile(File? file) {
    emit(state.copyWith(aiPhoto: file, clearAiError: true));
  }

  Future<void> runAiAttendance() async {
    final session = state.activeSession;
    final photo = state.aiPhoto;
    if (session == null || photo == null) {
      emit(state.copyWith(aiError: 'Choose a photo and open a session first'));
      return;
    }

    emit(
      state.copyWith(
        isAiLoading: true,
        clearAiError: true,
        clearAiResult: true,
      ),
    );

    final upload = await _attendanceService.uploadAiPhoto(
      sessionId: session.id,
      photo: photo,
    );

    if (!upload.isSuccess || upload.data == null) {
      emit(
        state.copyWith(
          isAiLoading: false,
          aiError: upload.error?.message ?? 'Failed to upload AI photo',
        ),
      );
      return;
    }

    final poll = await _attendanceService.pollAiResult(
      upload.data!.processingId,
    );
    if (!poll.isSuccess || poll.data == null) {
      emit(
        state.copyWith(
          isAiLoading: false,
          aiError: poll.error?.message ?? 'AI processing failed',
        ),
      );
      return;
    }

    final result = poll.data!;
    await loadRosterData(session.id, state.isRosterReadOnly);
    emit(
      state.copyWith(
        isAiLoading: false,
        aiResult: result,
        aiUnknownCount: result.unmatchedFacesCount ?? 0,
      ),
    );
  }

  void applyAiResultsToRoster() {
    final result = state.aiResult;
    if (result == null || !result.isCompleted) {
      emit(state.copyWith(aiError: 'AI results are not ready yet'));
      return;
    }

    emit(state.copyWith(isRosterDirty: state.rosterRows.any((r) => r.isDirty)));
  }

  static String _dateOnly(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
