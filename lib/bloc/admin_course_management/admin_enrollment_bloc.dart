import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/instructor/instructor_course_model.dart';
import '../../services/api/enrollment_service.dart';

enum AdminEnrollmentStatus {
  initial,
  loading,
  loaded,
  actionInProgress,
  conflictWarning,
  success,
  failure,
}

class EnrollmentConflictAction extends Equatable {
  final bool isDrop;
  final int? sectionId;
  final int? userId;
  final String? enrollmentId;
  final String? reason;
  final String warningMessage;

  const EnrollmentConflictAction({
    required this.isDrop,
    this.sectionId,
    this.userId,
    this.enrollmentId,
    this.reason,
    required this.warningMessage,
  });

  @override
  List<Object?> get props => <Object?>[
    isDrop,
    sectionId,
    userId,
    enrollmentId,
    reason,
    warningMessage,
  ];
}

class AdminEnrollmentState extends Equatable {
  static const Object _unset = Object();

  final AdminEnrollmentStatus status;
  final int? activeSectionId;
  final List<SectionStudentModel> students;
  final EnrollmentConflictAction? conflictAction;
  final String? errorMessage;
  final String? successMessage;

  const AdminEnrollmentState({
    this.status = AdminEnrollmentStatus.initial,
    this.activeSectionId,
    this.students = const <SectionStudentModel>[],
    this.conflictAction,
    this.errorMessage,
    this.successMessage,
  });

  AdminEnrollmentState copyWith({
    AdminEnrollmentStatus? status,
    Object? activeSectionId = _unset,
    List<SectionStudentModel>? students,
    Object? conflictAction = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return AdminEnrollmentState(
      status: status ?? this.status,
      activeSectionId: activeSectionId == _unset
          ? this.activeSectionId
          : activeSectionId as int?,
      students: students ?? this.students,
      conflictAction: conflictAction == _unset
          ? this.conflictAction
          : conflictAction as EnrollmentConflictAction?,
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
    status,
    activeSectionId,
    students,
    conflictAction,
    errorMessage,
    successMessage,
  ];
}

abstract class AdminEnrollmentEvent extends Equatable {
  const AdminEnrollmentEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadSectionStudents extends AdminEnrollmentEvent {
  final int sectionId;

  const LoadSectionStudents(this.sectionId);

  @override
  List<Object?> get props => <Object?>[sectionId];
}

class EnrollStudentToSection extends AdminEnrollmentEvent {
  final int sectionId;
  final int userId;
  final bool force;

  const EnrollStudentToSection({
    required this.sectionId,
    required this.userId,
    this.force = false,
  });

  @override
  List<Object?> get props => <Object?>[sectionId, userId, force];
}

class DropStudentEnrollment extends AdminEnrollmentEvent {
  final String enrollmentId;
  final String? reason;
  final bool force;

  const DropStudentEnrollment({
    required this.enrollmentId,
    this.reason,
    this.force = false,
  });

  @override
  List<Object?> get props => <Object?>[enrollmentId, reason, force];
}

class ConfirmConflictOverride extends AdminEnrollmentEvent {
  const ConfirmConflictOverride();
}

class ClearEnrollmentFeedback extends AdminEnrollmentEvent {
  const ClearEnrollmentFeedback();
}

class AdminEnrollmentBloc
    extends Bloc<AdminEnrollmentEvent, AdminEnrollmentState> {
  final EnrollmentService _enrollmentService;

  AdminEnrollmentBloc({required EnrollmentService enrollmentService})
    : _enrollmentService = enrollmentService,
      super(const AdminEnrollmentState()) {
    on<LoadSectionStudents>(_onLoadSectionStudents);
    on<EnrollStudentToSection>(_onEnrollStudentToSection);
    on<DropStudentEnrollment>(_onDropStudentEnrollment);
    on<ConfirmConflictOverride>(_onConfirmConflictOverride);
    on<ClearEnrollmentFeedback>(_onClearEnrollmentFeedback);
  }

  Future<void> _onLoadSectionStudents(
    LoadSectionStudents event,
    Emitter<AdminEnrollmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.loading,
        activeSectionId: event.sectionId,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _enrollmentService.getSectionStudentsLite(
      event.sectionId,
    );
    if (result.isFailure || result.data == null) {
      emit(
        state.copyWith(
          status: AdminEnrollmentStatus.failure,
          errorMessage:
              result.error?.message ?? 'Failed to load section students',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.loaded,
        students: result.data!,
        conflictAction: null,
      ),
    );
  }

  Future<void> _onEnrollStudentToSection(
    EnrollStudentToSection event,
    Emitter<AdminEnrollmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.actionInProgress,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _enrollmentService.adminRegisterStudent(
      sectionId: event.sectionId,
      userId: event.userId,
      force: event.force,
    );

    if (result.isFailure) {
      final statusCode = result.error?.statusCode;
      if (!event.force && statusCode == 409) {
        emit(
          state.copyWith(
            status: AdminEnrollmentStatus.conflictWarning,
            conflictAction: EnrollmentConflictAction(
              isDrop: false,
              sectionId: event.sectionId,
              userId: event.userId,
              warningMessage:
                  result.error?.message ?? 'Schedule conflict detected',
            ),
            errorMessage: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AdminEnrollmentStatus.failure,
          errorMessage: result.error?.message ?? 'Failed to enroll student',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.success,
        successMessage: 'Enrollment completed',
        conflictAction: null,
      ),
    );

    add(LoadSectionStudents(event.sectionId));
  }

  Future<void> _onDropStudentEnrollment(
    DropStudentEnrollment event,
    Emitter<AdminEnrollmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.actionInProgress,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _enrollmentService.adminDropEnrollment(
      enrollmentId: event.enrollmentId,
      reason: event.reason,
      force: event.force,
    );

    if (result.isFailure) {
      final statusCode = result.error?.statusCode;
      if (!event.force && statusCode == 400) {
        emit(
          state.copyWith(
            status: AdminEnrollmentStatus.conflictWarning,
            conflictAction: EnrollmentConflictAction(
              isDrop: true,
              enrollmentId: event.enrollmentId,
              reason: event.reason,
              warningMessage:
                  result.error?.message ?? 'Drop deadline passed. Force drop?',
            ),
            errorMessage: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AdminEnrollmentStatus.failure,
          errorMessage: result.error?.message ?? 'Failed to drop enrollment',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.success,
        successMessage: 'Enrollment dropped',
        conflictAction: null,
      ),
    );

    if (state.activeSectionId != null) {
      add(LoadSectionStudents(state.activeSectionId!));
    }
  }

  void _onConfirmConflictOverride(
    ConfirmConflictOverride event,
    Emitter<AdminEnrollmentState> emit,
  ) {
    final action = state.conflictAction;
    if (action == null) {
      return;
    }

    if (action.isDrop && action.enrollmentId != null) {
      add(
        DropStudentEnrollment(
          enrollmentId: action.enrollmentId!,
          reason: action.reason,
          force: true,
        ),
      );
      return;
    }

    if (!action.isDrop && action.sectionId != null && action.userId != null) {
      add(
        EnrollStudentToSection(
          sectionId: action.sectionId!,
          userId: action.userId!,
          force: true,
        ),
      );
    }
  }

  void _onClearEnrollmentFeedback(
    ClearEnrollmentFeedback event,
    Emitter<AdminEnrollmentState> emit,
  ) {
    emit(
      state.copyWith(
        status: AdminEnrollmentStatus.loaded,
        errorMessage: null,
        successMessage: null,
        conflictAction: null,
      ),
    );
  }
}
