import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/exams/exam_generation_form_data.dart';
import 'package:edu_verse/models/exams/exam_query.dart';
import 'package:edu_verse/models/instructor/question_bank_exam_models.dart';

void main() {
  group('ExamQuery', () {
    test('clamps page and limit to backend-safe bounds', () {
      const query = ExamQuery(page: -3, limit: 101);

      expect(query.page, 1);
      expect(query.limit, 100);
    });
  });

  group('ExamDraftQuery', () {
    test('clamps page and limit to backend-safe bounds', () {
      const query = ExamDraftQuery(page: 0, limit: 0);

      expect(query.page, 1);
      expect(query.limit, 1);
    });
  });

  group('Exam generation request DTOs', () {
    test('generation form data builds backend payload', () {
      const data = ExamGenerationFormData(
        courseId: 10,
        title: ' Midterm ',
        markDistributionMode: ExamMarkDistributionMode.weightNormalized,
        roundingPolicy: ExamRoundingPolicy.nearest025,
        rules: <ExamGenerationRuleModel>[
          ExamGenerationRuleModel(
            chapterId: 2,
            questionType: QuestionBankQuestionType.mcq,
            difficulty: QuestionBankDifficulty.medium,
            bloomLevel: QuestionBankBloomLevel.understand,
            count: 3,
            weightPerQuestion: 2,
          ),
        ],
      );

      expect(data.toJson(), <String, dynamic>{
        'courseId': 10,
        'title': 'Midterm',
        'markDistributionMode': 'weight_normalized',
        'roundingPolicy': 'nearest_0_25',
        'groupSelectionMode': 'independent',
        'rules': <Map<String, dynamic>>[
          <String, dynamic>{
            'chapterId': 2,
            'questionType': 'mcq',
            'difficulty': 'medium',
            'bloomLevel': 'understand',
            'count': 3,
            'weightPerQuestion': 2.0,
          },
        ],
      });
    });

    test('draft item form omits weight on add endpoint payload', () {
      const data = DraftItemFormData(questionId: 7, marks: 5);

      expect(data.toJson(), <String, dynamic>{'questionId': 7, 'marks': 5.0});
    });

    test('draft reorder DTOs expose backend order item shapes', () {
      const section = DraftSectionOrderItem(sectionId: 4, sectionOrder: 1);
      const item = DraftItemOrderItem(itemId: 8, itemOrder: 2);

      expect(section.toJson(), <String, dynamic>{
        'sectionId': 4,
        'sectionOrder': 1,
      });
      expect(item.toJson(), <String, dynamic>{'itemId': 8, 'itemOrder': 2});
    });
  });
}
