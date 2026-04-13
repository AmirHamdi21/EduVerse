import '../assignments/assignment_submission_model.dart';
import '../core/enums/assignment_enums.dart';

extension AssignmentSubmissionUiState on AssignmentSubmissionModel {
  bool get isGradedState {
    return submissionStatus == SubmissionStatus.graded ||
        submissionStatus == SubmissionStatus.returned;
  }

  String get statusKey {
    if (isLate) {
      return 'late';
    }
    return isGradedState ? 'graded' : 'pending';
  }
}
