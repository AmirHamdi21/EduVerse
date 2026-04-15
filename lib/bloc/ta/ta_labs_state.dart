import 'package:equatable/equatable.dart';

import '../../models/core/lab_attendance_model.dart';
import '../../models/labs/lab_model.dart';
import '../../models/labs/lab_submission_model.dart';

// ──────────────────────────────────────────────────────────────
// TALabsState hierarchy
// ──────────────────────────────────────────────────────────────

sealed class TALabsState extends Equatable {
  const TALabsState();

  @override
  List<Object?> get props => const <Object?>[];
}

// ── Labs List states ───────────────────────────────────────────

class TALabsInitial extends TALabsState {
  const TALabsInitial();
}

class TALabsLoading extends TALabsState {
  const TALabsLoading();
}

/// Loading state that preserves previously loaded labs for better UX.
/// Shows existing labs with a subtle refresh indicator instead of full-screen loader.
class TALabsLoadingWithCache extends TALabsState {
  const TALabsLoadingWithCache(this.cachedLabs);

  final List<LabModel> cachedLabs;

  @override
  List<Object?> get props => <Object?>[cachedLabs];
}

class TALabsLoaded extends TALabsState {
  const TALabsLoaded(this.labs);

  final List<LabModel> labs;

  @override
  List<Object?> get props => <Object?>[labs];
}

class TALabsError extends TALabsState {
  const TALabsError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// ── Lab Detail states ──────────────────────────────────────────

class TALabDetailLoading extends TALabsState {
  const TALabDetailLoading();
}

class TALabDetailLoaded extends TALabsState {
  const TALabDetailLoaded({
    required this.lab,
    required this.submissions,
    required this.attendance,
  });

  final LabModel lab;
  final List<LabSubmissionModel> submissions;
  final List<LabAttendanceModel> attendance;

  TALabDetailLoaded copyWith({
    LabModel? lab,
    List<LabSubmissionModel>? submissions,
    List<LabAttendanceModel>? attendance,
  }) {
    return TALabDetailLoaded(
      lab: lab ?? this.lab,
      submissions: submissions ?? this.submissions,
      attendance: attendance ?? this.attendance,
    );
  }

  @override
  List<Object?> get props => <Object?>[lab, submissions, attendance];
}

class TALabDetailError extends TALabsState {
  const TALabDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// ── Partial refresh states ─────────────────────────────────────

/// Emitted during attendance partial refresh — keeps existing data visible.
class TALabAttendanceRefreshing extends TALabsState {
  const TALabAttendanceRefreshing({
    required this.lab,
    required this.submissions,
    required this.attendance,
  });

  final LabModel lab;
  final List<LabSubmissionModel> submissions;
  final List<LabAttendanceModel> attendance;

  @override
  List<Object?> get props => <Object?>[lab, submissions, attendance];
}

// ── Grading states ─────────────────────────────────────────────

/// Emitted while PATCH grade request is in-flight.
class TALabGrading extends TALabsState {
  const TALabGrading();
}

/// Emitted after successful PATCH grade — BlocListener shows toast.
class TALabGradeSuccess extends TALabsState {
  const TALabGradeSuccess();
}

/// Emitted on PATCH grade failure — BlocListener shows error snackbar.
class TALabGradeError extends TALabsState {
  const TALabGradeError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
