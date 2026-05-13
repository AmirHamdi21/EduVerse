import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../services/api/attendance_service.dart';
import '../../services/api/enrollment_service.dart';
import 'instructor_attendance_state.dart';

class InstructorAttendanceCubit extends Cubit<InstructorAttendanceState>
    with SafeRouteCubitMixin<InstructorAttendanceState> {
  final AttendanceService _attendanceService;
  final EnrollmentService _enrollmentService;
  late final RouteRequestController _sectionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _sessionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _sessionMutationRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _rosterRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _attendanceMutationRequest =
      trackRouteRequest(RouteRequestController());
  late final RouteRequestController _aiRequest = trackRouteRequest(
    RouteRequestController(),
  );

  InstructorAttendanceCubit({
    required AttendanceService attendanceService,
    required EnrollmentService enrollmentService,
  }) : _attendanceService = attendanceService,
       _enrollmentService = enrollmentService,
       super(
         InstructorAttendanceState(newSessionDate: _dateOnly(DateTime.now())),
       );

  Future<void> loadTeachingSections({int? preferredSectionId}) async {
    final requestId = _sectionsRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final result = await _enrollmentService.getTeachingCourses(
      cancelToken: _sectionsRequest.token,
    );
    if (!isRequestCurrent(_sectionsRequest, requestId)) {
      return;
    }
    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load teaching sections',
        ),
      );
      return;
    }

    final sections = result.data!;
    final selectedSection = _resolveSelectedSection(
      preferredSectionId ?? state.selectedSectionId,
      sections,
    );

    emitIfOpen(
      state.copyWith(
        isLoading: false,
        teachingSections: sections,
        selectedSectionId: selectedSection?.sectionId,
        selectedSection: selectedSection,
        view: state.uiMode == AttendanceUiMode.lecture
            ? InstructorAttendanceView.classes
            : InstructorAttendanceView.section,
      ),
    );

    if (state.uiMode == AttendanceUiMode.sessions && selectedSection != null) {
      await loadSessionsForSection(selectedSection.sectionId);
    }
  }

  void setUiMode(AttendanceUiMode uiMode) {
    emitIfOpen(
      state.copyWith(
        uiMode: uiMode,
        view: uiMode == AttendanceUiMode.lecture
            ? InstructorAttendanceView.classes
            : InstructorAttendanceView.section,
        clearActiveSession: uiMode == AttendanceUiMode.sessions,
        rosterRows: uiMode == AttendanceUiMode.sessions
            ? const <RosterRow>[]
            : state.rosterRows,
        isRosterReadOnly: uiMode == AttendanceUiMode.sessions
            ? false
            : state.isRosterReadOnly,
        isRosterDirty: uiMode == AttendanceUiMode.sessions
            ? false
            : state.isRosterDirty,
        clearAiPhoto: uiMode == AttendanceUiMode.sessions,
        clearAiError: uiMode == AttendanceUiMode.sessions,
        clearAiResult: uiMode == AttendanceUiMode.sessions,
      ),
    );

    if (uiMode == AttendanceUiMode.sessions) {
      final section =
          state.selectedSection ??
          (state.teachingSections.isNotEmpty
              ? state.teachingSections.first
              : null);
      if (section != null) {
        selectSectionForSessions(section.sectionId);
      }
    }
  }

  Future<void> selectSectionForSessions(int sectionId) async {
    final section = _resolveSelectedSection(sectionId, state.teachingSections);
    if (section == null) {
      emitIfOpen(state.copyWith(error: 'Select a section first'));
      return;
    }

    emitIfOpen(
      state.copyWith(
        selectedSectionId: section.sectionId,
        selectedSection: section,
        view: InstructorAttendanceView.section,
        clearError: true,
      ),
    );
    await loadSessionsForSection(section.sectionId);
  }

  Future<void> openSection(TeachingCourseModel section, int sectionId) async {
    emitIfOpen(
      state.copyWith(
        selectedSection: section,
        selectedSectionId: sectionId,
        view: InstructorAttendanceView.section,
        newSessionDate: _dateOnly(DateTime.now()),
        isRosterDirty: false,
        clearError: true,
      ),
    );
    await loadSessionsForSection(sectionId);
  }

  Future<void> loadSessionsForSection(int sectionId) async {
    final requestId = _sessionsRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.getSessions(
      sectionId: sectionId,
      limit: 30,
      sortBy: 'sessionDate',
      sortOrder: 'DESC',
      cancelToken: _sessionsRequest.token,
    );
    if (!isRequestCurrent(_sessionsRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load sessions',
        ),
      );
      return;
    }

    emitIfOpen(
      state.copyWith(
        isLoading: false,
        sessions: result.data!,
        view: InstructorAttendanceView.section,
      ),
    );
  }

  Future<void> createSession() async {
    final sectionId = state.selectedSectionId;
    if (sectionId == null) {
      emitIfOpen(state.copyWith(error: 'Select a section first'));
      return;
    }

    final requestId = _sessionMutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.createSession(
      sectionId: sectionId,
      sessionDate: state.newSessionDate,
      sessionType: state.newSessionType,
      cancelToken: _sessionMutationRequest.token,
    );
    if (!isRequestCurrent(_sessionMutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to create session',
        ),
      );
      return;
    }

    await openRosterFromSession(result.data!);
  }

  Future<void> updateSession({
    required int sessionId,
    required String sessionDate,
    required String sessionType,
  }) async {
    final requestId = _sessionMutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.updateSession(
      sessionId,
      <String, dynamic>{'sessionDate': sessionDate, 'sessionType': sessionType},
      cancelToken: _sessionMutationRequest.token,
    );
    if (!isRequestCurrent(_sessionMutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to update session',
        ),
      );
      return;
    }

    final sectionId = state.selectedSectionId;
    if (sectionId != null) {
      await loadSessionsForSection(sectionId);
    } else {
      emitIfOpen(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteSession(int sessionId) async {
    final requestId = _sessionMutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.deleteSession(
      sessionId,
      cancelToken: _sessionMutationRequest.token,
    );
    if (!isRequestCurrent(_sessionMutationRequest, requestId)) {
      return;
    }
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to delete session',
        ),
      );
      return;
    }

    final sectionId = state.selectedSectionId;
    if (sectionId != null) {
      await loadSessionsForSection(sectionId);
    } else {
      emitIfOpen(state.copyWith(isLoading: false));
    }
  }

  void updateNewSessionDate(String date) {
    emitIfOpen(state.copyWith(newSessionDate: date));
  }

  void updateNewSessionType(String type) {
    emitIfOpen(state.copyWith(newSessionType: type));
  }

  void backToClasses() {
    emitIfOpen(
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

  Future<void> openRosterFromSession(AttendanceSessionModel session) async {
    final readOnly =
        session.status == 'completed' || session.status == 'cancelled';
    await loadRosterData(session.id, readOnly);
  }

  Future<void> loadRosterData(
    int sessionId,
    bool readOnly, {
    bool preserveLocalStatuses = true,
  }) async {
    final requestId = _rosterRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));

    final previousRowsByUser = <int, RosterRow>{
      if (preserveLocalStatuses && state.activeSession?.id == sessionId)
        for (final row in state.rosterRows) row.userId: row,
    };

    final sessionResult = await _attendanceService.getSessionDetails(
      sessionId,
      cancelToken: _rosterRequest.token,
    );
    if (!isRequestCurrent(_rosterRequest, requestId)) {
      return;
    }
    if (!sessionResult.isSuccess || sessionResult.data == null) {
      emitIfOpen(
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
        cancelToken: _rosterRequest.token,
      );
      if (!isRequestCurrent(_rosterRequest, requestId)) {
        return;
      }
      if (sectionStudents.isSuccess && sectionStudents.data != null) {
        rows = sectionStudents.data!.map((SectionStudentModel student) {
          final matched = statusByUser[student.userId];
          final status = AttendanceRecordModel.normalizeStatus(
            matched?.attendanceStatus,
          );
          final fallbackName = matched?.displayName.isNotEmpty == true
              ? matched!.displayName
              : student.studentIdLabel;
          final resolvedName = student.displayName == student.studentIdLabel
              ? fallbackName
              : student.displayName;
          final resolvedEmail = student.resolvedEmail.isNotEmpty
              ? student.resolvedEmail
              : (matched?.email ?? '');
          final previousRow = previousRowsByUser[student.userId];

          return RosterRow(
            userId: student.userId,
            name: resolvedName,
            email: resolvedEmail,
            status: previousRow?.status ?? status,
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
        final previousRow = previousRowsByUser[record.userId];
        return RosterRow(
          userId: record.userId,
          name: record.displayName,
          email: record.email ?? '',
          status: previousRow?.status ?? status,
          initialStatus: status,
          aiConfidence: record.confidenceScore,
          isAiMarked: (record.markedBy ?? '').toLowerCase() == 'ai',
        );
      }).toList();
    }

    rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    emitIfOpen(
      state.copyWith(
        isLoading: false,
        view: InstructorAttendanceView.roster,
        activeSession: session,
        rosterRows: rows,
        isRosterReadOnly: readOnly,
        isRosterDirty: rows.any((row) => row.isDirty),
        clearAiError: true,
        clearAiResult: true,
        clearAiPhoto: true,
      ),
    );
  }

  void backToSection() {
    final sectionId = state.selectedSectionId;
    emitIfOpen(
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
    if (sectionId != null) {
      loadSessionsForSection(sectionId);
    }
  }

  void applyStatus(int userId, String status) {
    if (state.isRosterReadOnly) {
      return;
    }

    final normalized = AttendanceRecordModel.normalizeStatus(status);
    final nextRows = state.rosterRows.map((row) {
      if (row.userId != userId) {
        return row;
      }
      return row.copyWith(status: normalized);
    }).toList();

    emitIfOpen(
      state.copyWith(
        rosterRows: nextRows,
        isRosterDirty: nextRows.any((row) => row.isDirty),
      ),
    );
  }

  void setAllStatus(String status) {
    if (state.isRosterReadOnly) {
      return;
    }

    final normalized = AttendanceRecordModel.normalizeStatus(status);
    final nextRows = state.rosterRows
        .map((row) => row.copyWith(status: normalized))
        .toList();
    emitIfOpen(
      state.copyWith(
        rosterRows: nextRows,
        isRosterDirty: nextRows.any((row) => row.isDirty),
      ),
    );
  }

  Future<void> saveBatch() async {
    final session = state.activeSession;
    if (session == null) {
      emitIfOpen(state.copyWith(error: 'No active session selected'));
      return;
    }

    final payload = state.rosterRows
        .map(
          (row) => <String, dynamic>{
            'userId': row.userId,
            'attendanceStatus': row.status,
          },
        )
        .toList();

    final requestId = _attendanceMutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.markBatchAttendance(
      sessionId: session.id,
      records: payload,
      cancelToken: _attendanceMutationRequest.token,
    );
    if (!isRequestCurrent(_attendanceMutationRequest, requestId)) {
      return;
    }

    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to save attendance',
        ),
      );
      return;
    }

    final updatedRows = state.rosterRows
        .map((row) => row.copyWith(initialStatus: row.status))
        .toList();
    emitIfOpen(
      state.copyWith(
        isLoading: false,
        rosterRows: updatedRows,
        isRosterDirty: false,
      ),
    );
  }

  Future<void> closeSession() async {
    final session = state.activeSession;
    if (session == null) {
      emitIfOpen(state.copyWith(error: 'No active session selected'));
      return;
    }

    final requestId = _sessionMutationRequest.begin();
    emitIfOpen(state.copyWith(isLoading: true, clearError: true));
    final result = await _attendanceService.closeSession(
      session.id,
      cancelToken: _sessionMutationRequest.token,
    );
    if (!isRequestCurrent(_sessionMutationRequest, requestId)) {
      return;
    }
    if (!result.isSuccess) {
      emitIfOpen(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to close session',
        ),
      );
      return;
    }

    emitIfOpen(
      state.copyWith(
        isLoading: false,
        activeSession: session.copyWith(status: 'completed'),
        isRosterReadOnly: true,
      ),
    );
  }

  void setAiFile(File? file) {
    emitIfOpen(state.copyWith(aiPhoto: file, clearAiError: true));
  }

  Future<void> runAiAttendance() async {
    final session = state.activeSession;
    final photo = state.aiPhoto;
    if (session == null || photo == null) {
      emitIfOpen(
        state.copyWith(aiError: 'Choose a photo and open a session first'),
      );
      return;
    }

    final requestId = _aiRequest.begin();
    emitIfOpen(
      state.copyWith(
        isAiLoading: true,
        clearAiError: true,
        clearAiResult: true,
      ),
    );

    final upload = await _attendanceService.uploadAiPhoto(
      sessionId: session.id,
      photo: photo,
      cancelToken: _aiRequest.token,
    );
    if (!isRequestCurrent(_aiRequest, requestId)) {
      return;
    }
    if (!upload.isSuccess || upload.data == null) {
      emitIfOpen(
        state.copyWith(
          isAiLoading: false,
          aiError: upload.error?.message ?? 'Failed to upload AI photo',
        ),
      );
      return;
    }

    final poll = await _attendanceService.pollAiResult(
      upload.data!.processingId,
      cancelToken: _aiRequest.token,
    );
    if (!isRequestCurrent(_aiRequest, requestId)) {
      return;
    }
    if (!poll.isSuccess || poll.data == null) {
      emitIfOpen(
        state.copyWith(
          isAiLoading: false,
          aiError: poll.error?.message ?? 'AI processing failed',
        ),
      );
      return;
    }

    final result = poll.data!;
    await loadRosterData(
      session.id,
      state.isRosterReadOnly,
      preserveLocalStatuses: false,
    );
    if (!isRequestCurrent(_aiRequest, requestId)) {
      return;
    }
    emitIfOpen(
      state.copyWith(
        isAiLoading: false,
        aiResult: result,
        aiUnknownCount: result.unmatchedFacesCount ?? 0,
      ),
    );
  }

  void applyAiResultsToRoster() {
    if (state.isRosterReadOnly) {
      emitIfOpen(
        state.copyWith(
          aiError: 'Session is closed - open an active session to apply.',
        ),
      );
      return;
    }

    if (state.aiReviewRows.isEmpty) {
      emitIfOpen(state.copyWith(aiError: 'No AI results to review yet'));
      return;
    }

    var changed = 0;
    final nextRows = state.rosterRows.map((row) {
      final suggested = row.aiSuggestedStatus;
      if (row.status != suggested) {
        changed += 1;
      }
      return row.copyWith(status: suggested);
    }).toList();

    emitIfOpen(
      state.copyWith(
        rosterRows: nextRows,
        isRosterDirty: changed > 0 || nextRows.any((row) => row.isDirty),
        clearAiError: true,
      ),
    );
  }

  static TeachingCourseModel? _resolveSelectedSection(
    int? selectedSectionId,
    List<TeachingCourseModel> sections,
  ) {
    if (sections.isEmpty) {
      return null;
    }

    if (selectedSectionId == null) {
      return sections.first;
    }

    for (final section in sections) {
      if (section.sectionId == selectedSectionId) {
        return section;
      }
    }

    return sections.first;
  }

  static String _dateOnly(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day';
  }
}
