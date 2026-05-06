import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/question_bank/question_attachment_payload.dart';
import 'package:edu_verse/models/question_bank/question_bank_enums.dart';
import 'package:edu_verse/models/question_bank/question_bank_form_payload.dart';
import 'package:edu_verse/models/question_bank/question_bank_option_model.dart';
import 'package:edu_verse/models/question_bank/question_bank_page_model.dart';
import 'package:edu_verse/models/question_bank/question_bank_question_model.dart';

void main() {
  test('parses question page data,total backend shape', () {
    final page = QuestionBankPageModel.fromJson(<String, dynamic>{
      'total': 1,
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 7,
          'questionId': 7,
          'courseId': 1,
          'chapterId': 2,
          'questionType': 'mcq',
          'difficulty': 'easy',
          'bloomLevel': 'remembering',
          'status': 'approved',
          'questionText': 'What is Dart?',
          'questionFileId': 11,
          'questionImageUrl': 'https://example.test/main.png',
          'attachments': <Map<String, dynamic>>[
            <String, dynamic>{
              'attachmentId': 4,
              'fileId': 9,
              'attachmentType': 'image',
              'displayOrder': 0,
              'isPrimary': true,
              'imageUrl': 'https://example.test/a.png',
            },
          ],
        },
      ],
    });

    expect(page.total, 1);
    expect(page.data.first.questionType, QuestionBankType.mcq);
    expect(page.data.first.questionImageUrl, 'https://example.test/main.png');
    expect(page.data.first.attachments.first.attachmentId, 4);
  });

  test('dirty edit payload omits unchanged fields and children', () {
    final original = QuestionBankQuestionModel.fromJson(<String, dynamic>{
      'id': 1,
      'questionId': 1,
      'courseId': 10,
      'chapterId': 20,
      'questionType': 'mcq',
      'difficulty': 'medium',
      'bloomLevel': 'understanding',
      'status': 'draft',
      'questionText': 'Original',
      'options': <Map<String, dynamic>>[
        <String, dynamic>{'optionText': 'A', 'isCorrect': true},
        <String, dynamic>{'optionText': 'B', 'isCorrect': false},
      ],
    });

    final payload = QuestionBankFormPayload(
      courseId: 10,
      chapterId: 20,
      questionType: QuestionBankType.mcq,
      difficulty: QuestionBankDifficulty.medium,
      bloomLevel: BloomLevel.understanding,
      questionText: 'Changed',
      options: const <QuestionBankOptionModel>[
        QuestionBankOptionModel(optionText: 'A', isCorrect: true),
        QuestionBankOptionModel(optionText: 'B', isCorrect: false),
      ],
    ).toDirtyUpdateJson(original);

    expect(payload, <String, dynamic>{'questionText': 'Changed'});
  });

  test('create payload includes ordered attachments', () {
    final payload = QuestionBankFormPayload(
      courseId: 10,
      chapterId: 20,
      questionType: QuestionBankType.mcq,
      difficulty: QuestionBankDifficulty.medium,
      bloomLevel: BloomLevel.understanding,
      questionText: 'Question with figures',
      options: const <QuestionBankOptionModel>[
        QuestionBankOptionModel(optionText: 'A', isCorrect: true),
        QuestionBankOptionModel(optionText: 'B', isCorrect: false),
      ],
      attachments: const <QuestionAttachmentPayload>[
        QuestionAttachmentPayload(
          fileId: 31,
          caption: 'Figure one',
          altText: 'First figure',
          displayOrder: 99,
          isPrimary: true,
        ),
        QuestionAttachmentPayload(
          fileId: 32,
          caption: 'Figure two',
          altText: 'Second figure',
        ),
      ],
    ).toCreateJson();

    final attachments = payload['attachments'] as List<dynamic>;
    expect(attachments.first, containsPair('fileId', 31));
    expect(attachments.first, containsPair('displayOrder', 0));
    expect(attachments.first, containsPair('isPrimary', true));
    expect(attachments.last, containsPair('fileId', 32));
    expect(attachments.last, containsPair('displayOrder', 1));
  });
}
