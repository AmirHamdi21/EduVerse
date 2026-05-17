import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_service.dart';

class InstructorWalkthroughService extends WalkthroughCompletionService {
  const InstructorWalkthroughService();

  Future<bool> isInstructorCompleted(int userId) {
    return isCompleted(WalkthroughRole.instructor, userId);
  }

  Future<void> markInstructorCompleted(int userId) {
    return markCompleted(WalkthroughRole.instructor, userId);
  }
}
