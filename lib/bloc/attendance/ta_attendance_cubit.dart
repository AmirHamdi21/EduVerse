import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/instructor/instructor_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../services/api/attendance_service.dart';
import '../../services/api/enrollment_service.dart';
import 'ta_attendance_state.dart';

class TAAttendanceCubit extends Cubit<TAAttendanceState> {
  final AttendanceService _attendanceService;
  final EnrollmentService _enrollmentService;

  TAAttendanceCubit({
    required AttendanceService attendanceService,
    required EnrollmentService enrollmentService,
  }) : _attendanceService = attendanceService,
       _enrollmentService = enrollmentService,
       super(const TAAttendanceState());

  Future<void> loadAvailableLabs() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _enrollmentService.getTeachingCourses();

    if (!result.isSuccess || result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load labs',
        ),
      );
      return;
    }

    final all = result.data!;
    final taOnly = all.where((e) => e.role.toLowerCase() == 'ta').toList();
    final available = taOnly.isNotEmpty ? taOnly : all;
    final first = available.isNotEmpty ? available.first : null;

    emit(
      state.copyWith(
        isLoading: false,
        view: TAAttendanceView.upload,
        availableLabs: available,
        selectedSectionId: first?.sectionId,
        selectedLab: first?.section.sectionNumber ?? '',
        selectedCourse: first?.course.name ?? '',
      ),
    );

    await loadHistory();
  }

  void selectLab(TeachingCourseModel? section) {
    if (section == null) return;
    emit(
      state.copyWith(
        selectedSectionId: section.sectionId,
        selectedLab: section.section.sectionNumber,
        selectedCourse: section.course.name,
      ),
    );
  }

  void selectFile(File file) {
    emit(state.copyWith(selectedFile: file));
  }

  Future<void> processAttendance() async {
    final sectionId = state.selectedSectionId;
    final file = state.selectedFile;
    if (sectionId == null || file == null) {
      emit(state.copyWith(error: 'Select lab and photo first'));
      return;
    }

    emit(
      state.copyWith(
        view: TAAttendanceView.processing,
        isLoading: true,
        processingProgress: 0.15,
        clearError: true,
      ),
    );

    final session = await _attendanceService.createSession(
      sectionId: sectionId,
      sessionDate: _dateOnly(DateTime.now()),
      sessionType: 'lab',
    );
    if (!session.isSuccess || session.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          view: TAAttendanceView.upload,
          error:
              session.error?.message ?? 'Failed to create attendance session',
        ),
      );
      return;
    }

    emit(state.copyWith(processingProgress: 0.35));
    final upload = await _attendanceService.uploadAiPhoto(
      sessionId: session.data!.id,
      photo: file,
    );
    if (!upload.isSuccess || upload.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          view: TAAttendanceView.upload,
          error: upload.error?.message ?? 'Failed to upload photo for AI',
        ),
      );
      return;
    }

    emit(state.copyWith(processingProgress: 0.65));
    final poll = await _attendanceService.pollAiResult(
      upload.data!.processingId,
    );
    if (!poll.isSuccess || poll.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          view: TAAttendanceView.upload,
          error: poll.error?.message ?? 'AI processing failed',
        ),
      );
      return;
    }

    emit(state.copyWith(processingProgress: 0.85));
    final detail = await _attendanceService.getSessionDetails(session.data!.id);
    final rows = await _buildDetectedRows(
      sectionId: sectionId,
      detail: detail.data,
    );

    emit(
      state.copyWith(
        isLoading: false,
        view: TAAttendanceView.results,
        processingProgress: 1,
        activeSession: detail.data ?? session.data,
        detectedStudents: rows,
        totalDetected: poll.data!.matchedStudentsCount ?? rows.length,
        totalStudents: rows.length,
        aiResult: poll.data,
        isEditing: true,
      ),
    );
  }

  Future<List<DetectedStudentRow>> _buildDetectedRows({
    required int sectionId,
    AttendanceSessionModel? detail,
  }) async {
    final recordMap = <int, AttendanceRecordModel>{
      for (final r in (detail?.records ?? <AttendanceRecordModel>[]))
        r.userId: r,
    };

    final students = await _enrollmentService.getSectionStudentsLite(sectionId);
    if (students.isSuccess &&
        students.data != null &&
        students.data!.isNotEmpty) {
      return students.data!.map((SectionStudentModel student) {
        final r = recordMap[student.userId];
        return DetectedStudentRow(
          userId: student.userId,
          name: student.displayName,
          email: student.email ?? '',
          status: AttendanceRecordModel.normalizeStatus(r?.attendanceStatus),
          confidence: r?.confidenceScore,
        );
      }).toList();
    }

    return recordMap.values
        .map(
          (r) => DetectedStudentRow(
            userId: r.userId,
            name: r.displayName,
            email: r.email ?? '',
            status: AttendanceRecordModel.normalizeStatus(r.attendanceStatus),
            confidence: r.confidenceScore,
          ),
        )
        .toList();
  }

  void overrideStatus(int studentId, String newStatus) {
    final normalized = AttendanceRecordModel.normalizeStatus(newStatus);
    final updated = state.detectedStudents.map((s) {
      if (s.userId != studentId) return s;
      return s.copyWith(status: normalized);
    }).toList();
    emit(state.copyWith(detectedStudents: updated));
  }

  Future<void> saveResults() async {
    final session = state.activeSession;
    if (session == null) {
      emit(state.copyWith(error: 'No active session to save'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final records = state.detectedStudents
        .map(
          (s) => <String, dynamic>{
            'userId': s.userId,
            'attendanceStatus': s.status,
          },
        )
        .toList();

    final save = await _attendanceService.markBatchAttendance(
      sessionId: session.id,
      records: records,
    );

    if (!save.isSuccess) {
      emit(
        state.copyWith(
          isLoading: false,
          error: save.error?.message ?? 'Failed to save attendance',
        ),
      );
      return;
    }

    await _attendanceService.closeSession(session.id);
    await loadHistory();

    emit(
      state.copyWith(
        isLoading: false,
        view: TAAttendanceView.history,
        clearSelectedFile: true,
      ),
    );
  }

  Future<void> loadHistory() async {
    final result = await _attendanceService.getSessions(
      status: 'completed',
      sortBy: 'sessionDate',
      sortOrder: 'DESC',
      limit: 50,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(pastSessions: result.data!));
    }
  }

  Future<void> viewHistoryDetails(AttendanceSessionModel session) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final detail = await _attendanceService.getSessionDetails(session.id);
    if (!detail.isSuccess || detail.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: detail.error?.message ?? 'Failed to load session details',
        ),
      );
      return;
    }

    final rows = detail.data!.records
        .map(
          (r) => DetectedStudentRow(
            userId: r.userId,
            name: r.displayName,
            email: r.email ?? '',
            status: AttendanceRecordModel.normalizeStatus(r.attendanceStatus),
            confidence: r.confidenceScore,
          ),
        )
        .toList();

    emit(
      state.copyWith(
        isLoading: false,
        view: TAAttendanceView.results,
        activeSession: detail.data,
        detectedStudents: rows,
        totalDetected: rows.length,
        totalStudents: rows.length,
        isEditing: false,
      ),
    );
  }

  String exportCsv() {
    final buffer = StringBuffer('userId,name,email,status,confidence\n');
    for (final s in state.detectedStudents) {
      buffer.writeln(
        '${s.userId},"${s.name}","${s.email}",${s.status},${s.confidence ?? ''}',
      );
    }
    return buffer.toString();
  }

  void resetToUpload() {
    emit(
      state.copyWith(
        view: TAAttendanceView.upload,
        clearSelectedFile: true,
        clearActiveSession: true,
        clearAiResult: true,
        processingProgress: 0,
        detectedStudents: const <DetectedStudentRow>[],
        totalDetected: 0,
        totalStudents: 0,
        isEditing: false,
      ),
    );
  }

  void showResults() {
    emit(state.copyWith(view: TAAttendanceView.results));
  }

  void showHistory() {
    emit(state.copyWith(view: TAAttendanceView.history));
  }

  static String _dateOnly(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
