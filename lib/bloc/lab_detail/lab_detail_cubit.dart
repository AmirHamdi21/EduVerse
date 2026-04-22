import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

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

class LabDetailCubit extends Cubit<LabDetailState> {
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

  void setCachedEnrolledCourses(List<CourseModel> courses) {
    _cachedEnrolledCourses = List<CourseModel>.from(courses);
  }

  void seedWithLab(LabModel lab) {
    final current = _loadedStateOrNull;

    if (current != null) {
      emit(
        current.copyWith(
          lab: lab,
          instructions: _sortInstructions(lab.instructions),
        ),
      );
      return;
    }

    emit(
      LabDetailLoaded(
        lab: lab,
        instructions: _sortInstructions(lab.instructions),
        isLoadingInstructions: false,
        isLoadingSubmissions: false,
      ),
    );
  }

  Future<void> loadLab(dynamic labId) async {
    final cachedLab = state is LabDetailLoaded
        ? (state as LabDetailLoaded).lab
        : null;

    emit(LabDetailLoading(cachedLab: cachedLab));

    final result = await _labService.getById(labId);
    if (!result.isSuccess || result.data == null) {
      emit(
        LabDetailError(
          message: result.error?.message ?? 'Failed to load lab details',
          lab: cachedLab,
        ),
      );
      return;
    }

    final lab = result.data!;
    final orderedInstructions = _sortInstructions(lab.instructions);

    emit(
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

    emit(
      current.copyWith(
        isLoadingInstructions: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _labService.getInstructions(labId);
    final refreshed = _loadedStateOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
        refreshed.copyWith(
          isLoadingInstructions: false,
          errorMessage:
              result.error?.message ?? 'Failed to load lab instructions',
        ),
      );
      return;
    }

    emit(
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

    emit(current.copyWith(isLoadingSubmissions: true, clearErrorMessage: true));

    final result = await _labService.getMySubmission(labId);
    final refreshed = _loadedStateOrNull;
    if (refreshed == null) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      emit(
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

    emit(
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

    final result = await _labService.getAttendance(labId);
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

    emit(refreshed.copyWith(attendanceStatus: status));
  }

  Future<bool> checkEnrollment(int courseId) async {
    if (_cachedEnrolledCourses.isNotEmpty) {
      final isEnrolled = _cachedEnrolledCourses
          .where((course) => course.id == courseId)
          .isNotEmpty;
      _updateEnrollmentFlag(isEnrolled);
      return isEnrolled;
    }

    final result = await _enrollmentService.getMyCourses();
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
        emit(
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

    emit(
      current.copyWith(
        isSubmitting: true,
        submitProgress: 0,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _labService.submit(labId, submissionText: text.trim());
    if (!result.isSuccess) {
      await _submissionEventTracker.logSubmissionFailure(
        labId.toString(),
        result.error?.message ?? 'Failed to submit lab work',
      );

      final refreshed = _loadedStateOrNull;
      if (refreshed != null) {
        emit(
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

    final refreshed = _loadedStateOrNull;
    if (refreshed != null) {
      emit(
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
      emit(
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
        emit(
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

    emit(
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
      onSendProgress: (sent, total) {
        final progressState = _loadedStateOrNull;
        if (progressState == null || total <= 0) {
          return;
        }

        emit(
          progressState.copyWith(
            isSubmitting: true,
            submitProgress: sent / total,
            clearErrorMessage: true,
            clearSuccessMessage: true,
          ),
        );
      },
    );

    if (!result.isSuccess) {
      await _submissionEventTracker.logSubmissionFailure(
        labId.toString(),
        result.error?.message ?? 'Failed to upload lab submission',
      );

      final refreshed = _loadedStateOrNull;
      if (refreshed != null) {
        emit(
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

    final refreshed = _loadedStateOrNull;
    if (refreshed != null) {
      emit(
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

    emit(current.copyWith(clearErrorMessage: true, clearSuccessMessage: true));
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

    emit(current.copyWith(isEnrolled: isEnrolled));
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
