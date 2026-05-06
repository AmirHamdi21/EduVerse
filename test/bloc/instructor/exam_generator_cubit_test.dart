import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/exams/exam_generation_rule_model.dart';

void main() {
  test('exam generation rule requires positive values', () {
    const rule = ExamGenerationRuleModel(
      chapterId: 1,
      count: 0,
      weightPerQuestion: 1,
    );

    expect(rule.validate(), contains('Count'));
  });
}
