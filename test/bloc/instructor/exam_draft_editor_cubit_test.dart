import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/exams/exam_draft_model.dart';
import 'package:edu_verse/models/exams/exam_generator_enums.dart';

void main() {
  test('expired draft is not editable', () {
    final draft = ExamDraftModel(
      id: 1,
      courseId: 1,
      title: 'Draft',
      seed: 's',
      markDistributionMode: ExamMarkDistributionMode.weightNormalized,
      roundingPolicy: ExamRoundingPolicy.none,
      status: ExamDraftStatus.open,
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );

    expect(draft.isEditable, isFalse);
  });
}
