import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/route_request_controller.dart';
import '../../models/core/course_model.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/core/enums/enrollment_enums.dart';
import '../../models/core/enums/lab_enums.dart';
import '../../models/core/lab_instruction_model.dart';
import '../../models/labs/lab_model.dart';
import '../../models/labs/lab_submission_model.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/lab_service.dart';
import '../../utils/submission_event_tracker.dart';
import 'lab_detail_state.dart';

class LabDetailCubit extends Cubit<LabDetailState>
    with SafeRouteCubitMixin<LabDetailState> {
  LabDetailCubit({
    required LabService labService,
    required EnrollmentService enrollmentService,
    SubmissionEventTracker? submissionEventTracker,
    List<CourseModel> cachedEnrolledCourses = const <CourseModel>[],
  }) : _labService = labService,
       _enrollmentService = enrollmentService,
       _submissionEventTracker =
           submissionEventTracker ?? SubmissionEventTracker(),
       _cachedEnrolledCourses = List<CourseModel>.from(cachedEnrolledCourses),
       super(const LabDetailInitial());

  final LabService _labService;
  final EnrollmentService _enrollmentService;
  final SubmissionEventTracker _submissionEventTracker;
  List<CourseModel> _cachedEnrolledCourses;
  late final RouteRequestController _labRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _instructionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _submissionsRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _attendanceRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _enrollmentRequest = trackRouteRequest(
    RouteRequestController(),
  );
  late final RouteRequestController _submitRequest = trackRouteRequest(
    RouteRequestController(),
  );

  void setCachedEnrolledCourses(List<CourseModel> courses) {
    _cachedEnrolledCourses = List<CourseModel>.from(courses);
  }

  void seedWithLab(LabModel lab) {
    final current = _loadedStateOrNull;

    if (current != null) {
      emitIfOpen(
        current.copyWith(
          lab: lab,
          instructions: _sortInstructions(lab.instructions),
        ),
      );
      return;
    }

    emitIfOpen(
      LabDetailLoaded(
        lab: lab,
        instructions: _sortInstructions(lab.instructions),
        isLoadingInstructions: false,
        isLoadingSubmissions: false,
      ),
    );
  }

  Future<void> initialize(dynamic labId) async {
    await loadLab(labId);
    if (_loadedStateOrNull == null) {
      return;
    }

    await Future.wait<void>(<Future<void>>[
      loadInstructions(labId),
      loadMySubmissions(labId),
      loadAttendance(labId),
    ]);
  }

  Future<void> loadLab(dynamic labId) async {
    final requestId = _labRequest.begin();
    final cachedLab = state is LabDetailLoaded
        ? (state as LabDetailLoaded).lab
        : null;

    emitIfOpen(LabDetailLoading(cachedLab: cachedLab));

    final result = await _labService.getById(
      labId,
      cancelToken: _labRequest.token,
    );
    if (!isRequestCurrent(_labRequest, requestId)) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        LabDetailError(
          message: result.error?.message ?? 'Failed to load lab details',
          lab: cachedLab,
        ),
      );
      return;
    }

    final lab = result.data!;
    final orderedInstructions = _sortInstructions(lab.instructions);

    emitIfOpen(
      LabDetailLoaded(
        lab: lab,
        instructions: orderedInstructions,
        isLoadingInstructions: false,
        isLoadingSubmissions: false,
      ),
    );
  }

  Future<void> loadInstructions(dynamic labId) async {
    final current = _loadedStateOrNull;
    if (current == null) {
      return;
    }

    final requestId = _instructionsRequest.begin();
    emitIfOpen(
      current.copyWith(
        isLoadingInstructions: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _labService.getInstructions(
      labId,
      cancelToken: _instructionsRequest.token,
    );
    if (!isRequestCurrent(_instructionsRequest, requestId)) {
      return;
    }

    final refreshed = _loadedStateOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        refreshed.copyWith(
          isLoadingInstructions: false,
          errorMessage:
              result.error?.message ?? 'Failed to load lab instructions',
        ),
      );
      return;
    }

    emitIfOpen(
      refreshed.copyWith(
        instructions: _sortInstructions(result.data!),
        isLoadingInstructions: false,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> loadMySubmissions(dynamic labId) async {
    final current = _loadedStateOrNull;
    if (current == null) {
      return;
    }

    final requestId = _submissionsRequest.begin();
    emitIfOpen(
      current.copyWith(isLoadingSubmissions: true, clearErrorMessage: true),
    );

    final result = await _labService.getMySubmission(
      labId,
      cancelToken: _submissionsRequest.token,
    );
    if (!isRequestCurrent(_submissionsRequest, requestId)) {
      return;
    }

    final refreshed = _loadedStateOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emitIfOpen(
        refreshed.copyWith(
          isLoadingSubmissions: false,
          errorMessage:
              result.error?.message ?? 'Failed to load your submissions',
        ),
      );
      return;
    }

    final submissions = List<LabSubmissionModel>.from(result.data!)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    emitIfOpen(
      refreshed.copyWith(
        mySubmissions: submissions,
        isLoadingSubmissions: false,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> loadAttendance(dynamic labId) async {
    final current = _loadedStateOrNull;
    if (current == null) {
      return;
    }

    final requestId = _attendanceRequest.begin();
    final result = await _labService.getAttendance(
      labId,
      cancelToken: _attendanceRequest.token,
    );
    if (!isRequestCurrent(_attendanceRequest, requestId)) {
      return;
    }

    final refreshed = _loadedStateOrNull;
    if (refreshed == null || !result.isSuccess || result.data == null) {
      return;
    }

    final attendance = result.data!;
    if (attendance.isEmpty) {
      return;
    }

    LabAttendanceStatus status = attendance.first.attendanceStatus;
    for (final item in attendance) {
      if (item.attendanceStatus == LabAttendanceStatus.present) {
        status = LabAttendanceStatus.present;
        break;
      }
    }

    emitIfOpen(refreshed.copyWith(attendanceStatus: status));
  }

  Future<bool> checkEnrollment(int courseId) async {
    if (_cachedEnrolledCourses.isNotEmpty) {
      final isEnrolled = _cachedEnrolledCourses
          .where((course) => course.id == courseId)
          .isNotEmpty;
      _updateEnrollmentFlag(isEnrolled);
      return isEnrolled;
    }

    final requestId = _enrollmentRequest.begin();
    final result = await _enrollmentService.getMyCourses(
      cancelToken: _enrollmentRequest.token,
    );
    if (!isRequestCurrent(_enrollmentRequest, requestId)) {
      return false;
    }

    if (!result.isSuccess || result.data == null) {
      _updateEnrollmentFlag(false);
      return false;
    }

    _cachedEnrolledCourses = _extractEnrolledCourses(result.data!);
    final isEnrolled = _cachedEnrolledCourses
        .where((course) => course.id == courseId)
        .isNotEmpty;
    _updateEnrollmentFlag(isEnrolled);
    return isEnrolled;
  }

  Future<bool> submitText(dynamic labId, String text) async {
    final current = _loadedStateOrNull;
    if (current == null) {
      return false;
    }

    if (text.trim().isEmpty) {
      emit(
        current.copyWith(
          errorMessage: 'Please add text before submitting.',
          clearSuccessMessage: true,
        ),
      );
      return false;
    }

    final isEnrolled = await checkEnrollment(current.lab.courseId);
    if (!isEnrolled) {
      final refreshed = _loadedStateOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage:
                'You must be enrolled in this course to submit lab work',
            clearSuccessMessage: true,
            isSubmitting: false,
          ),
        );
      }
      return false;
    }

    final requestId = _submitRequest.begin();
    emitIfOpen(
      current.copyWith(
        isSubmitting: true,
        submitProgress: 0,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _labService.submit(
      labId,
      submissionText: text.trim(),
      cancelToken: _submitRequest.token,
    );
    if (!isRequestCurrent(_submitRequest, requestId)) {
      return false;
    }

    if (!result.isSuccess) {
      await _submissionEventTracker.logSubmissionFailure(
        labId.toString(),
        result.error?.message ?? 'Failed to submit lab work',
      );

      final refreshed = _loadedStateOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            isSubmitting: false,
            submitProgress: 0,
            errorMessage: result.error?.message ?? 'Failed to submit lab work',
          ),
        );
      }
      return false;
    }

    await _submissionEventTracker.logSubmission(labId.toString());
    await loadMySubmissions(labId);
    if (!isRequestCurrent(_submitRequest, requestId)) {
      return false;
    }

    final refreshed = _loadedStateOrNull;
    if (refreshed != null) {
      emitIfOpen(
        refreshed.copyWith(
          isSubmitting: false,
          submitProgress: 0,
          successMessage: 'Submission sent successfully.',
          clearErrorMessage: true,
        ),
      );
    }
    return true;
  }

  Future<bool> submitFile(
    dynamic labId,
    String filePath, {
    String? submissionText,
  }) async {
    final current = _loadedStateOrNull;
    if (current == null) {
      return false;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      emitIfOpen(
        current.copyWith(
          errorMessage: 'Selected file no longer exists.',
          clearSuccessMessage: true,
        ),
      );
      return false;
    }

    final isEnrolled = await checkEnrollment(current.lab.courseId);
    if (!isEnrolled) {
      final refreshed = _loadedStateOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            errorMessage:
                'You must be enrolled in this course to submit lab work',
            clearSuccessMessage: true,
            isSubmitting: false,
          ),
        );
      }
      return false;
    }

    final requestId = _submitRequest.begin();
    emitIfOpen(
      current.copyWith(
        isSubmitting: true,
        submitProgress: 0,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _labService.submitFile(
      labId,
      file,
      submissionText: submissionText,
      cancelToken: _submitRequest.token,
      onSendProgress: (sent, total) {
        final progressState = _loadedStateOrNull;
        if (progressState == null ||
            total <= 0 ||
            !isRequestCurrent(_submitRequest, requestId)) {
          return;
        }

        emitIfOpen(
          progressState.copyWith(
            isSubmitting: true,
            submitProgress: sent / total,
            clearErrorMessage: true,
            clearSuccessMessage: true,
          ),
        );
      },
    );
    if (!isRequestCurrent(_submitRequest, requestId)) {
      return false;
    }

    if (!result.isSuccess) {
      await _submissionEventTracker.logSubmissionFailure(
        labId.toString(),
        result.error?.message ?? 'Failed to upload lab submission',
      );

      final refreshed = _loadedStateOrNull;
      if (refreshed != null) {
        emitIfOpen(
          refreshed.copyWith(
            isSubmitting: false,
            submitProgress: 0,
            errorMessage:
                result.error?.message ?? 'Failed to upload lab submission',
          ),
        );
      }
      return false;
    }

    await _submissionEventTracker.logSubmission(labId.toString());
    await loadMySubmissions(labId);
    if (!isRequestCurrent(_submitRequest, requestId)) {
      return false;
    }

    final refreshed = _loadedStateOrNull;
    if (refreshed != null) {
      emitIfOpen(
        refreshed.copyWith(
          isSubmitting: false,
          submitProgress: 1,
          successMessage: 'Submission sent successfully.',
          clearErrorMessage: true,
        ),
      );
    }
    return true;
  }

  void clearMessages() {
    final current = _loadedStateOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(
      current.copyWith(clearErrorMessage: true, clearSuccessMessage: true),
    );
  }

  LabDetailLoaded? get _loadedStateOrNull {
    final current = state;
    if (current is LabDetailLoaded) {
      return current;
    }
    return null;
  }

  void _updateEnrollmentFlag(bool isEnrolled) {
    final current = _loadedStateOrNull;
    if (current == null) {
      return;
    }

    emitIfOpen(current.copyWith(isEnrolled: isEnrolled));
  }

  List<LabInstructionModel> _sortInstructions(
    List<LabInstructionModel> values,
  ) {
    final sorted = List<LabInstructionModel>.from(values);
    sorted.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sorted;
  }

  List<CourseModel> _extractEnrolledCourses(
    List<CourseEnrollmentModel> enrollments,
  ) {
    final byId = <int, CourseModel>{};
    for (final enrollment in enrollments) {
      if (enrollment.enrollmentStatus != EnrollmentStatus.enrolled) {
        continue;
      }

      final course = enrollment.course;
      if (course == null) {
        continue;
      }

      byId[course.id] = course;
    }

    return byId.values.toList();
  }
}
