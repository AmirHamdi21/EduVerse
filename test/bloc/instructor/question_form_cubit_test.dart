import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/question_bank/question_bank_enums.dart';
import 'package:edu_verse/models/question_bank/question_bank_form_payload.dart';

void main() {
  test('question form validates missing course', () {
    final payload = QuestionBankFormPayload(
      questionType: QuestionBankType.mcq,
      difficulty: QuestionBankDifficulty.medium,
      bloomLevel: BloomLevel.understanding,
    );

    expect(payload.validate(), contains('Course'));
  });
}
