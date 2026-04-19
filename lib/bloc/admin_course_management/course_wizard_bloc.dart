import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/core/course_model.dart';
import '../../models/courses/instructor_assignment_model.dart';
import '../../models/core/enums/course_enums.dart';
import '../../models/ta/ta_assignment_model.dart';
import '../../services/api/course_service.dart';
import '../../services/api/enrollment_service.dart';
import '../../services/api/schedule_service.dart';
import '../../services/api/section_service.dart';

enum CourseWizardStatus {
  initial,
  loading,
  stepSaved,
  completed,
  failure,
  conflict,
  inactiveSaved,
}

class WizardInstructorAssignment extends Equatable {
  final int userId;
  final String role;
  final String? responsibilities;

  const WizardInstructorAssignment({
    required this.userId,
    required this.role,
    this.responsibilities,
  });

  bool get isTa => role.trim().toLowerCase() == 'ta';

  @override
  List<Object?> get props => <Object?>[userId, role, responsibilities];
}

class CourseWizardState extends Equatable {
  static const Object _unset = Object();

  final int currentStep;
  final bool isEditMode;
  final bool allowDirectStepNavigation;
  final bool isSubmitting;
  final CourseWizardStatus status;
  final int? draftCourseId;
  final int? draftSectionId;
  final CourseModel? editingCourse;
  final Map<String, String> validationErrors;
  final String? errorMessage;
  final String? successMessage;

  const CourseWizardState({
    this.currentStep = 0,
    this.isEditMode = false,
    this.allowDirectStepNavigation = false,
    this.isSubmitting = false,
    this.status = CourseWizardStatus.initial,
    this.draftCourseId,
    this.draftSectionId,
    this.editingCourse,
    this.validationErrors = const <String, String>{},
    this.errorMessage,
    this.successMessage,
  });

  CourseWizardState copyWith({
    int? currentStep,
    bool? isEditMode,
    bool? allowDirectStepNavigation,
    bool? isSubmitting,
    CourseWizardStatus? status,
    Object? draftCourseId = _unset,
    Object? draftSectionId = _unset,
    Object? editingCourse = _unset,
    Map<String, String>? validationErrors,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return CourseWizardState(
      currentStep: currentStep ?? this.currentStep,
      isEditMode: isEditMode ?? this.isEditMode,
      allowDirectStepNavigation:
          allowDirectStepNavigation ?? this.allowDirectStepNavigation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      status: status ?? this.status,
      draftCourseId: draftCourseId == _unset
          ? this.draftCourseId
          : draftCourseId as int?,
      draftSectionId: draftSectionId == _unset
          ? this.draftSectionId
          : draftSectionId as int?,
      editingCourse: editingCourse == _unset
          ? this.editingCourse
          : editingCourse as CourseModel?,
      validationErrors: validationErrors ?? this.validationErrors,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currentStep,
    isEditMode,
    allowDirectStepNavigation,
    isSubmitting,
    status,
    draftCourseId,
    draftSectionId,
    editingCourse,
    validationErrors,
    errorMessage,
    successMessage,
  ];
}

abstract class CourseWizardEvent extends Equatable {
  const CourseWizardEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class InitializeWizard extends CourseWizardEvent {
  final CourseModel? course;

  const InitializeWizard({this.course});

  @override
  List<Object?> get props => <Object?>[course];
}

class ResetWizard extends CourseWizardEvent {
  const ResetWizard();
}

class ClearWizardFeedback extends CourseWizardEvent {
  const ClearWizardFeedback();
}

class GoToWizardStep extends CourseWizardEvent {
  final int step;

  const GoToWizardStep(this.step);

  @override
  List<Object?> get props => <Object?>[step];
}

class PreviousWizardStep extends CourseWizardEvent {
  const PreviousWizardStep();
}

class SubmitStep1 extends CourseWizardEvent {
  final Map<String, dynamic> payload;
  final String? desiredStatus;

  const SubmitStep1(this.payload, {this.desiredStatus});

  @override
  List<Object?> get props => <Object?>[payload, desiredStatus];
}

class SubmitStep2 extends CourseWizardEvent {
  final Map<String, dynamic> sectionPayload;
  final List<Map<String, dynamic>> schedulesPayload;
  final String? desiredStatus;

  const SubmitStep2({
    required this.sectionPayload,
    required this.schedulesPayload,
    this.desiredStatus,
  });

  @override
  List<Object?> get props => <Object?>[
    sectionPayload,
    schedulesPayload,
    desiredStatus,
  ];
}

class SubmitStep3 extends CourseWizardEvent {
  final List<WizardInstructorAssignment> assignments;

  const SubmitStep3(this.assignments);

  @override
  List<Object?> get props => <Object?>[assignments];
}

class DeleteCourseFromWizard extends CourseWizardEvent {
  final int courseId;

  const DeleteCourseFromWizard(this.courseId);

  @override
  List<Object?> get props => <Object?>[courseId];
}

class CourseWizardBloc extends Bloc<CourseWizardEvent, CourseWizardState> {
  final CourseService _courseService;
  final SectionService _sectionService;
  final ScheduleService _scheduleService;
  final EnrollmentService _enrollmentService;

  CourseWizardBloc({
    required CourseService courseService,
    required SectionService sectionService,
    required ScheduleService scheduleService,
    required EnrollmentService enrollmentService,
  }) : _courseService = courseService,
       _sectionService = sectionService,
       _scheduleService = scheduleService,
       _enrollmentService = enrollmentService,
       super(const CourseWizardState()) {
    on<InitializeWizard>(_onInitializeWizard);
    on<ResetWizard>(_onResetWizard);
    on<ClearWizardFeedback>(_onClearWizardFeedback);
    on<GoToWizardStep>(_onGoToWizardStep);
    on<PreviousWizardStep>(_onPreviousWizardStep);
    on<SubmitStep1>(_onSubmitStep1);
    on<SubmitStep2>(_onSubmitStep2);
    on<SubmitStep3>(_onSubmitStep3);
    on<DeleteCourseFromWizard>(_onDeleteCourseFromWizard);
  }

  void _onInitializeWizard(
    InitializeWizard event,
    Emitter<CourseWizardState> emit,
  ) {
    final course = event.course;
    if (course == null) {
      emit(const CourseWizardState());
      return;
    }

    final sectionId = course.sections != null && course.sections!.isNotEmpty
        ? course.sections!.first.id
        : null;

    emit(
      state.copyWith(
        isEditMode: true,
        allowDirectStepNavigation: course.courseStatus == CourseStatus.active,
        draftCourseId: course.id,
        draftSectionId: sectionId,
        editingCourse: course,
        currentStep: 0,
        status: CourseWizardStatus.initial,
        validationErrors: const <String, String>{},
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  void _onResetWizard(ResetWizard event, Emitter<CourseWizardState> emit) {
    emit(const CourseWizardState());
  }

  void _onClearWizardFeedback(
    ClearWizardFeedback event,
    Emitter<CourseWizardState> emit,
  ) {
    emit(
      state.copyWith(
        status: CourseWizardStatus.initial,
        errorMessage: null,
        successMessage: null,
        validationErrors: const <String, String>{},
      ),
    );
  }

  void _onGoToWizardStep(
    GoToWizardStep event,
    Emitter<CourseWizardState> emit,
  ) {
    if (event.step < 0 || event.step > 2) {
      return;
    }

    if (!state.allowDirectStepNavigation &&
        event.step > state.currentStep + 1) {
      return;
    }

    emit(state.copyWith(currentStep: event.step));
  }

  void _onPreviousWizardStep(
    PreviousWizardStep event,
    Emitter<CourseWizardState> emit,
  ) {
    if (state.currentStep <= 0) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: state.currentStep - 1,
        status: CourseWizardStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitStep1(
    SubmitStep1 event,
    Emitter<CourseWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        status: CourseWizardStatus.loading,
        errorMessage: null,
        successMessage: null,
        validationErrors: const <String, String>{},
      ),
    );

    final isUpdatingExisting = state.isEditMode && state.draftCourseId != null;
    final requestedStatus = _normalizeCourseStatus(
      event.desiredStatus ?? event.payload['status']?.toString(),
    );

    final payload = Map<String, dynamic>.from(event.payload);
    if (!isUpdatingExisting) {
      payload.remove('status');
    }

    final result = isUpdatingExisting
        ? await _courseService.updateCourseAdmin(state.draftCourseId!, payload)
        : await _courseService.createCourseAdmin(payload);

    if (result.isFailure || result.data == null) {
      final statusCode = result.error?.statusCode;
      final isConflict = statusCode == 409 || statusCode == 400;
      emit(
        state.copyWith(
          isSubmitting: false,
          status: isConflict
              ? CourseWizardStatus.conflict
              : CourseWizardStatus.failure,
          errorMessage:
              result.error?.message ?? 'Failed to save course details',
          validationErrors: _toValidationErrors(result.error?.message),
        ),
      );
      return;
    }

    var savedCourse = result.data!;

    if (!isUpdatingExisting &&
        requestedStatus != null &&
        requestedStatus != CourseStatus.active.value) {
      final postCreateStatusResult = await _courseService.updateCourseAdmin(
        savedCourse.id,
        <String, dynamic>{'status': requestedStatus},
      );

      if (postCreateStatusResult.isFailure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            isEditMode: true,
            status: CourseWizardStatus.failure,
            draftCourseId: savedCourse.id,
            editingCourse: savedCourse,
            errorMessage:
                postCreateStatusResult.error?.message ??
                'Course was created but status update failed',
          ),
        );
        return;
      }

      if (postCreateStatusResult.data != null) {
        savedCourse = postCreateStatusResult.data!;
      }
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        status: CourseWizardStatus.stepSaved,
        draftCourseId: savedCourse.id,
        editingCourse: savedCourse,
        currentStep: state.currentStep < 1 ? 1 : state.currentStep,
        successMessage: 'Step 1 saved',
      ),
    );
  }

  Future<void> _onSubmitStep2(
    SubmitStep2 event,
    Emitter<CourseWizardState> emit,
  ) async {
    if (state.draftCourseId == null) {
      emit(
        state.copyWith(
          status: CourseWizardStatus.failure,
          errorMessage: 'Course draft is missing. Save step 1 first.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        status: CourseWizardStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final isUpdatingExistingSection = state.draftSectionId != null;
    final requestedStatus = _normalizeSectionStatus(
      event.desiredStatus ?? event.sectionPayload['status']?.toString(),
    );

    final sectionPayload = Map<String, dynamic>.from(event.sectionPayload);
    if (!isUpdatingExistingSection) {
      sectionPayload.remove('status');
      sectionPayload.putIfAbsent('courseId', () => state.draftCourseId);
    }

    final sectionResult = isUpdatingExistingSection
        ? await _sectionService.update(state.draftSectionId!, sectionPayload)
        : await _sectionService.create(sectionPayload);

    if (sectionResult.isFailure || sectionResult.data == null) {
      await _saveAsInactive(
        emit,
        fallbackMessage:
            sectionResult.error?.message ??
            'Step 2 failed while saving section',
      );
      return;
    }

    var section = sectionResult.data!;

    if (!isUpdatingExistingSection &&
        requestedStatus != null &&
        requestedStatus != SectionStatus.open.value) {
      final postCreateStatusResult = await _sectionService.update(
        section.id,
        <String, dynamic>{'status': requestedStatus},
      );

      if (postCreateStatusResult.isFailure) {
        await _saveAsInactive(
          emit,
          fallbackMessage:
              postCreateStatusResult.error?.message ??
              'Step 2 failed while updating section status',
        );
        return;
      }

      if (postCreateStatusResult.data != null) {
        section = postCreateStatusResult.data!;
      }
    }

    for (final payload in event.schedulesPayload) {
      final schedulePayload = Map<String, dynamic>.from(payload);
      final dynamic scheduleId = schedulePayload.remove('id');

      final scheduleResult = scheduleId != null
          ? await _scheduleService.update(scheduleId, schedulePayload)
          : await _scheduleService.create(section.id, schedulePayload);

      if (scheduleResult.isFailure) {
        await _saveAsInactive(
          emit,
          fallbackMessage:
              scheduleResult.error?.message ??
              'Step 2 failed while saving schedule',
        );
        return;
      }
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        status: CourseWizardStatus.stepSaved,
        draftSectionId: section.id,
        currentStep: state.currentStep < 2 ? 2 : state.currentStep,
        successMessage: 'Step 2 saved',
      ),
    );
  }

  Future<void> _onSubmitStep3(
    SubmitStep3 event,
    Emitter<CourseWizardState> emit,
  ) async {
    if (state.draftSectionId == null) {
      emit(
        state.copyWith(
          status: CourseWizardStatus.failure,
          errorMessage: 'Section draft is missing. Save step 2 first.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        status: CourseWizardStatus.loading,
        errorMessage: null,
      ),
    );

    final sectionId = state.draftSectionId!;
    final uniqueAssignments = <String, WizardInstructorAssignment>{
      for (final assignment in event.assignments)
        '${assignment.role.trim().toLowerCase()}:${assignment.userId}':
            assignment,
    };

    if (state.isEditMode) {
      final existingInstructorsResult = await _enrollmentService
          .getSectionInstructors(sectionId);
      if (existingInstructorsResult.isFailure) {
        await _saveAsInactive(
          emit,
          fallbackMessage:
              existingInstructorsResult.error?.message ??
              'Step 3 failed while loading existing instructors',
        );
        return;
      }

      final existingTAsResult = await _enrollmentService.getSectionTAs(
        sectionId,
      );
      if (existingTAsResult.isFailure) {
        await _saveAsInactive(
          emit,
          fallbackMessage:
              existingTAsResult.error?.message ??
              'Step 3 failed while loading existing teaching assistants',
        );
        return;
      }

      final existingInstructors =
          existingInstructorsResult.data ?? const <InstructorAssignmentModel>[];
      final existingTAs = existingTAsResult.data ?? const <TAAssignmentModel>[];

      final existingInstructorByUserId = <int, InstructorAssignmentModel>{
        for (final item in existingInstructors)
          if (item.userId > 0) item.userId: item,
      };
      final existingTaByUserId = <int, TAAssignmentModel>{
        for (final item in existingTAs)
          if (item.userId > 0) item.userId: item,
      };

      final desiredInstructorAssignments = uniqueAssignments.values
          .where((item) => !item.isTa && item.userId > 0)
          .toList();
      final desiredTaAssignments = uniqueAssignments.values
          .where((item) => item.isTa && item.userId > 0)
          .toList();

      final remainingInstructorByUserId = <int, InstructorAssignmentModel>{
        ...existingInstructorByUserId,
      };
      final remainingTaByUserId = <int, TAAssignmentModel>{
        ...existingTaByUserId,
      };

      for (final assignment in desiredInstructorAssignments) {
        final desiredRole = _normalizeInstructorRole(assignment.role);
        final existing = remainingInstructorByUserId[assignment.userId];

        if (existing == null) {
          final addResult = await _enrollmentService
              .assignInstructorWithDetails(
                sectionId,
                assignment.userId,
                role: desiredRole,
              );

          if (addResult.isFailure && addResult.error?.statusCode != 409) {
            await _saveAsInactive(
              emit,
              fallbackMessage:
                  addResult.error?.message ??
                  'Step 3 failed while assigning instructors',
            );
            return;
          }
          continue;
        }

        final existingRole = _normalizeInstructorRole(existing.role);
        if (existingRole == desiredRole) {
          remainingInstructorByUserId.remove(assignment.userId);
          continue;
        }

        final removalResult = await _enrollmentService.removeInstructor(
          sectionId,
          existing.id,
        );
        if (removalResult.isFailure) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                removalResult.error?.message ??
                'Step 3 failed while updating instructor role',
          );
          return;
        }

        final addResult = await _enrollmentService.assignInstructorWithDetails(
          sectionId,
          assignment.userId,
          role: desiredRole,
        );

        if (addResult.isFailure && addResult.error?.statusCode != 409) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                addResult.error?.message ??
                'Step 3 failed while updating instructor role',
          );
          return;
        }

        remainingInstructorByUserId.remove(assignment.userId);
      }

      for (final assignment in desiredTaAssignments) {
        final desiredResponsibilities = _normalizeResponsibilities(
          assignment.responsibilities,
        );
        final existing = remainingTaByUserId[assignment.userId];

        if (existing == null) {
          final addResult = await _enrollmentService.assignTAWithDetails(
            sectionId,
            assignment.userId,
            responsibilities: desiredResponsibilities,
          );

          if (addResult.isFailure && addResult.error?.statusCode != 409) {
            await _saveAsInactive(
              emit,
              fallbackMessage:
                  addResult.error?.message ??
                  'Step 3 failed while assigning teaching assistants',
            );
            return;
          }
          continue;
        }

        final existingResponsibilities = _normalizeResponsibilities(
          existing.responsibilities,
        );
        if (existingResponsibilities == desiredResponsibilities) {
          remainingTaByUserId.remove(assignment.userId);
          continue;
        }

        final removalResult = await _enrollmentService.removeTA(
          sectionId,
          existing.id,
        );
        if (removalResult.isFailure) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                removalResult.error?.message ??
                'Step 3 failed while updating teaching assistant details',
          );
          return;
        }

        final addResult = await _enrollmentService.assignTAWithDetails(
          sectionId,
          assignment.userId,
          responsibilities: desiredResponsibilities,
        );

        if (addResult.isFailure && addResult.error?.statusCode != 409) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                addResult.error?.message ??
                'Step 3 failed while updating teaching assistant details',
          );
          return;
        }

        remainingTaByUserId.remove(assignment.userId);
      }

      for (final instructor in remainingInstructorByUserId.values) {
        final removalResult = await _enrollmentService.removeInstructor(
          sectionId,
          instructor.id,
        );
        if (removalResult.isFailure) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                removalResult.error?.message ??
                'Step 3 failed while replacing instructors',
          );
          return;
        }
      }

      for (final ta in remainingTaByUserId.values) {
        final removalResult = await _enrollmentService.removeTA(
          sectionId,
          ta.id,
        );
        if (removalResult.isFailure) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                removalResult.error?.message ??
                'Step 3 failed while replacing teaching assistants',
          );
          return;
        }
      }
    } else {
      for (final assignment in uniqueAssignments.values) {
        final desiredResponsibilities = _normalizeResponsibilities(
          assignment.responsibilities,
        );
        final result = assignment.isTa
            ? await _enrollmentService.assignTAWithDetails(
                sectionId,
                assignment.userId,
                responsibilities: desiredResponsibilities,
              )
            : await _enrollmentService.assignInstructorWithDetails(
                sectionId,
                assignment.userId,
                role: _normalizeInstructorRole(assignment.role),
              );

        if (result.isFailure) {
          await _saveAsInactive(
            emit,
            fallbackMessage:
                result.error?.message ?? 'Step 3 failed while assigning staff',
          );
          return;
        }
      }
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        status: CourseWizardStatus.completed,
        successMessage: 'Course workflow completed',
      ),
    );
  }

  Future<void> _onDeleteCourseFromWizard(
    DeleteCourseFromWizard event,
    Emitter<CourseWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        status: CourseWizardStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _courseService.softDeleteCourse(event.courseId);
    if (result.isFailure) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: CourseWizardStatus.failure,
          errorMessage: result.error?.message ?? 'Failed to delete course',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        status: CourseWizardStatus.completed,
        successMessage: 'Course deleted successfully',
      ),
    );
  }

  Future<void> _saveAsInactive(
    Emitter<CourseWizardState> emit, {
    required String fallbackMessage,
  }) async {
    if (state.draftCourseId != null) {
      await _courseService.updateCourseAdmin(
        state.draftCourseId!,
        const <String, dynamic>{'status': 'INACTIVE'},
      );
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        status: CourseWizardStatus.inactiveSaved,
        errorMessage: fallbackMessage,
      ),
    );
  }

  Map<String, String> _toValidationErrors(String? message) {
    if (message == null || message.trim().isEmpty) {
      return const <String, String>{};
    }

    final lower = message.toLowerCase();
    if (lower.contains('code')) {
      return <String, String>{'code': message};
    }

    if (lower.contains('name')) {
      return <String, String>{'name': message};
    }

    return <String, String>{'general': message};
  }

  String _normalizeInstructorRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'primary';
    }
    return normalized;
  }

  String? _normalizeResponsibilities(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String? _normalizeCourseStatus(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _normalizeSectionStatus(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
