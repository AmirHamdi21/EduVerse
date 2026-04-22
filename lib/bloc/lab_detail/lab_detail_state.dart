import 'package:equatable/equatable.dart';

import '../../models/core/enums/lab_enums.dart';
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
  final LabModel? cachedLab;

  const LabDetailLoading({this.cachedLab});

  @override
  List<Object?> get props => <Object?>[cachedLab];
}

class LabDetailLoaded extends LabDetailState {
  final LabModel lab;
  final List<LabInstructionModel> instructions;
  final List<LabSubmissionModel> mySubmissions;
  final LabAttendanceStatus? attendanceStatus;
  final bool isLoadingInstructions;
  final bool isLoadingSubmissions;
  final bool isSubmitting;
  final double submitProgress;
  final bool isEnrolled;
  final String? errorMessage;
  final String? successMessage;

  const LabDetailLoaded({
    required this.lab,
    this.instructions = const <LabInstructionModel>[],
    this.mySubmissions = const <LabSubmissionModel>[],
    this.attendanceStatus,
    this.isLoadingInstructions = false,
    this.isLoadingSubmissions = false,
    this.isSubmitting = false,
    this.submitProgress = 0,
    this.isEnrolled = true,
    this.errorMessage,
    this.successMessage,
  });

  LabDetailLoaded copyWith({
    LabModel? lab,
    List<LabInstructionModel>? instructions,
    List<LabSubmissionModel>? mySubmissions,
    LabAttendanceStatus? attendanceStatus,
    bool? isLoadingInstructions,
    bool? isLoadingSubmissions,
    bool? isSubmitting,
    double? submitProgress,
    bool? isEnrolled,
    String? errorMessage,
    String? successMessage,
    bool clearAttendanceStatus = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return LabDetailLoaded(
      lab: lab ?? this.lab,
      instructions: instructions ?? this.instructions,
      mySubmissions: mySubmissions ?? this.mySubmissions,
      attendanceStatus: clearAttendanceStatus
          ? null
          : (attendanceStatus ?? this.attendanceStatus),
      isLoadingInstructions:
          isLoadingInstructions ?? this.isLoadingInstructions,
      isLoadingSubmissions: isLoadingSubmissions ?? this.isLoadingSubmissions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitProgress: submitProgress ?? this.submitProgress,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    lab,
    instructions,
    mySubmissions,
    attendanceStatus,
    isLoadingInstructions,
    isLoadingSubmissions,
    isSubmitting,
    submitProgress,
    isEnrolled,
    errorMessage,
    successMessage,
  ];
}

class LabDetailError extends LabDetailState {
  final String message;
  final LabModel? lab;

  const LabDetailError({required this.message, this.lab});

  @override
  List<Object?> get props => <Object?>[message, lab];
}
