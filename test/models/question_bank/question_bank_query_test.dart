import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/instructor/question_bank_exam_models.dart';
import 'package:edu_verse/models/question_bank/course_chapter_model.dart';
import 'package:edu_verse/models/question_bank/question_form_data.dart';
import 'package:edu_verse/models/question_bank/question_bank_query.dart';

void main() {
  group('QuestionBankQuery', () {
    test('clamps page and limit to backend-safe bounds', () {
      const query = QuestionBankQuery(page: 0, limit: 500);

      expect(query.page, 1);
      expect(query.limit, 100);
    });

    test('keeps valid pagination values unchanged', () {
      const query = QuestionBankQuery(page: 3, limit: 40);

      expect(query.page, 3);
      expect(query.limit, 40);
    });
  });

  group('Question bank request DTOs', () {
    test('chapter requests use strict backend DTO fields', () {
      const create = CreateChapterRequest(name: ' Intro ', chapterOrder: 1);
      const update = UpdateChapterRequest(
        name: ' Basics ',
        chapterOrder: 2,
        isActive: 1,
      );

      expect(create.toJson(), <String, dynamic>{
        'name': 'Intro',
        'chapterOrder': 1,
      });
      expect(update.toJson(), <String, dynamic>{
        'name': 'Basics',
        'chapterOrder': 2,
        'isActive': 1,
      });
    });

    test('question form data strips response-only child fields', () {
      const data = QuestionFormData(<String, dynamic>{
        'questionText': 'Prompt',
        'options': <Map<String, dynamic>>[
          <String, dynamic>{
            'optionId': 7,
            'optionOrder': 2,
            'optionText': ' Choice ',
            'isCorrect': true,
          },
        ],
        'fillBlanks': <Map<String, dynamic>>[
          <String, dynamic>{
            'blankId': 9,
            'blankKey': ' result ',
            'acceptableAnswer': ' done ',
            'isCaseSensitive': false,
          },
        ],
      });

      expect(data.toJson()['options'], <Map<String, dynamic>>[
        <String, dynamic>{'optionText': 'Choice', 'isCorrect': true},
      ]);
      expect(data.toJson()['fillBlanks'], <Map<String, dynamic>>[
        <String, dynamic>{
          'blankKey': 'result',
          'acceptableAnswer': 'done',
          'isCaseSensitive': false,
        },
      ]);
    });

    test('attachment create omits false multipart-sensitive boolean', () {
      const data = QuestionAttachmentCreateRequest(
        fileId: 4,
        attachmentType: QuestionBankAttachmentType.image,
        isPrimary: false,
      );

      expect(data.toJson(), <String, dynamic>{
        'fileId': 4,
        'attachmentType': 'image',
      });
    });

    test('attachment update preserves explicit null clears', () {
      const data = QuestionAttachmentUpdateRequest(
        caption: null,
        altText: null,
      );

      expect(data.toJson(), <String, dynamic>{
        'caption': null,
        'altText': null,
      });
    });
  });
}
