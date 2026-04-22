import 'package:equatable/equatable.dart';

import '../../models/core/lab_attendance_model.dart';
import '../../models/core/lab_instruction_model.dart';
import '../../models/labs/lab_model.dart';
import '../../models/labs/lab_submission_model.dart';

abstract class LabDetailState extends Equatable {
  const LabDetailState();

  @override
  List<Object?> get props => const <Object?>[];
}

class LabDetailInitial extends LabDetailState {
  const LabDetailInitial();
}

class LabDetailLoading extends LabDetailState {
  const LabDetailLoading({this.cachedLab});

  final LabModel? cachedLab;

  @override
  List<Object?> get props => <Object?>[cachedLab];
}

class LabDetailLoaded extends LabDetailState {
  const LabDetailLoaded({
    required this.lab,
    this.instructions,
    this.submissions,
    this.attendance,
    this.isSubmittingGrade = false,
    this.isSubmittingAttendance = false,
    this.message,
    this.errorMessage,
  });

  final LabModel lab;
  final List<LabInstructionModel>? instructions;
  final List<LabSubmissionModel>? submissions;
  final List<LabAttendanceModel>? attendance;
  final bool isSubmittingGrade;
  final bool isSubmittingAttendance;
  final String? message;
  final String? errorMessage;

  LabDetailLoaded copyWith({
    LabModel? lab,
    List<LabInstructionModel>? instructions,
    List<LabSubmissionModel>? submissions,
    List<LabAttendanceModel>? attendance,
    bool? isSubmittingGrade,
    bool? isSubmittingAttendance,
    String? message,
    String? errorMessage,
    bool clearInstructions = false,
    bool clearSubmissions = false,
    bool clearAttendance = false,
    bool clearMessage = false,
    bool clearErrorMessage = false,
  }) {
    return LabDetailLoaded(
      lab: lab ?? this.lab,
      instructions: clearInstructions
          ? null
          : (instructions ?? this.instructions),
      submissions: clearSubmissions ? null : (submissions ?? this.submissions),
      attendance: clearAttendance ? null : (attendance ?? this.attendance),
      isSubmittingGrade: isSubmittingGrade ?? this.isSubmittingGrade,
      isSubmittingAttendance:
          isSubmittingAttendance ?? this.isSubmittingAttendance,
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    lab,
    instructions,
    submissions,
    attendance,
    isSubmittingGrade,
    isSubmittingAttendance,
    message,
    errorMessage,
  ];
}

class LabInstructionUpdating extends LabDetailLoaded {
  const LabInstructionUpdating({
    required super.lab,
    super.instructions,
    super.submissions,
    super.attendance,
    super.isSubmittingGrade,
    super.isSubmittingAttendance,
    super.message,
    super.errorMessage,
    this.updatingInstructionId,
  });

  final int? updatingInstructionId;

  @override
  List<Object?> get props => <Object?>[...super.props, updatingInstructionId];
}

class LabDetailError extends LabDetailState {
  const LabDetailError({
    required this.message,
    this.statusCode,
    this.cachedLab,
  });

  final String message;
  final int? statusCode;
  final LabModel? cachedLab;

  @override
  List<Object?> get props => <Object?>[message, statusCode, cachedLab];
}
