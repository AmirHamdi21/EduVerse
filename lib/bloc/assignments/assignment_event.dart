import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../models/assignments/assignment_model.dart';
import 'assignment_state.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FetchAssignments extends AssignmentEvent {
  final int? courseId;

  const FetchAssignments({this.courseId});

  @override
  List<Object?> get props => <Object?>[courseId];
}

class RefreshAssignments extends AssignmentEvent {
  final int? courseId;

  const RefreshAssignments({this.courseId});

  @override
  List<Object?> get props => <Object?>[courseId];
}

class SelectAssignment extends AssignmentEvent {
  final AssignmentModel assignment;

  const SelectAssignment({required this.assignment});

  @override
  List<Object?> get props => <Object?>[assignment];
}

class FetchMySubmission extends AssignmentEvent {
  final int assignmentId;

  const FetchMySubmission({required this.assignmentId});

  @override
  List<Object?> get props => <Object?>[assignmentId];
}

class SubmitTextAssignment extends AssignmentEvent {
  final int assignmentId;
  final String? submissionText;
  final String? submissionLink;

  const SubmitTextAssignment({
    required this.assignmentId,
    this.submissionText,
    this.submissionLink,
  });

  @override
  List<Object?> get props => <Object?>[
    assignmentId,
    submissionText,
    submissionLink,
  ];
}

class SubmitFileAssignment extends AssignmentEvent {
  final int assignmentId;
  final File file;
  final String? submissionText;
  final String? submissionLink;

  const SubmitFileAssignment({
    required this.assignmentId,
    required this.file,
    this.submissionText,
    this.submissionLink,
  });

  @override
  List<Object?> get props => <Object?>[
    assignmentId,
    file.path,
    submissionText,
    submissionLink,
  ];
}

class SetAssignmentFilterStatus extends AssignmentEvent {
  final AssignmentFilterStatus filterStatus;

  const SetAssignmentFilterStatus({required this.filterStatus});

  @override
  List<Object?> get props => <Object?>[filterStatus];
}

class SetAssignmentSearchQuery extends AssignmentEvent {
  final String query;

  const SetAssignmentSearchQuery({required this.query});

  @override
  List<Object?> get props => <Object?>[query];
}

class ClearError extends AssignmentEvent {
  const ClearError();
}
