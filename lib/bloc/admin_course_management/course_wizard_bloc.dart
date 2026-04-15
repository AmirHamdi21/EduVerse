import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/core/course_model.dart';
import '../../models/core/enrollment_model.dart';
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

  bool get isTa => role.toLowerCase() == 'ta';

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

  const SubmitStep1(this.payload);

  @override
  List<Object?> get props => <Object?>[payload];
}

class SubmitStep2 extends CourseWizardEvent {
  final Map<String, dynamic> sectionPayload;
  final List<Map<String, dynamic>> schedulesPayload;

  const SubmitStep2({
    required this.sectionPayload,
    required this.schedulesPayload,
  });

  @override
  List<Object?> get props => <Object?>[sectionPayload, schedulesPayload];
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

    final result = state.isEditMode && state.draftCourseId != null
        ? await _courseService.updateCourseAdmin(
            state.draftCourseId!,
            event.payload,
          )
        : await _courseService.createCourseAdmin(event.payload);

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

    emit(
      state.copyWith(
        isSubmitting: false,
        status: CourseWizardStatus.stepSaved,
        draftCourseId: result.data!.id,
        editingCourse: result.data,
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

    final sectionPayload = Map<String, dynamic>.from(event.sectionPayload);
    if (state.draftSectionId == null) {
      sectionPayload.putIfAbsent('courseId', () => state.draftCourseId);
    }

    final sectionResult = state.draftSectionId != null
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

    final section = sectionResult.data!;

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

      for (final EnrollmentModel instructor
          in (existingInstructorsResult.data ?? const <EnrollmentModel>[])) {
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

      for (final TAAssignmentModel ta
          in (existingTAsResult.data ?? const <TAAssignmentModel>[])) {
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
    }

    final uniqueAssignments = <String, WizardInstructorAssignment>{
      for (final assignment in event.assignments)
        '${assignment.role.toLowerCase()}:${assignment.userId}': assignment,
    };

    for (final assignment in uniqueAssignments.values) {
      final result = assignment.isTa
          ? await _enrollmentService.assignTAWithDetails(
              sectionId,
              assignment.userId,
              responsibilities: assignment.responsibilities,
            )
          : await _enrollmentService.assignInstructorWithDetails(
              sectionId,
              assignment.userId,
              role: assignment.role,
              responsibilities: assignment.responsibilities,
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
}
