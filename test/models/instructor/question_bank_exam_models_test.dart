import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/instructor/question_bank_exam_models.dart';
import 'package:edu_verse/services/api/question_bank_exam_service.dart';

void main() {
  group('Question bank and exam models', () {
    test('option request JSON strips response-only fields', () {
      const option = QuestionBankOptionModel(
        optionId: 42,
        optionText: '  Binary search  ',
        isCorrect: true,
        optionOrder: 3,
      );

      expect(option.toRequestJson(), <String, dynamic>{
        'optionText': 'Binary search',
        'isCorrect': true,
      });
    });

    test('fill blank request JSON strips response-only blank id', () {
      const blank = QuestionBankFillBlankModel(
        blankId: 7,
        blankKey: ' answer ',
        acceptableAnswer: ' 42 ',
        isCaseSensitive: true,
      );

      expect(blank.toRequestJson(), <String, dynamic>{
        'blankKey': 'answer',
        'acceptableAnswer': '42',
        'isCaseSensitive': true,
      });
    });

    test('draft item add payload omits non-whitelisted weight field', () {
      final payload = QuestionBankExamService.buildAddDraftItemPayload(
        questionId: 12,
        weightUnits: 2,
        marks: 5,
        overrideReason: '  approved override  ',
      );

      expect(payload, <String, dynamic>{
        'questionId': 12,
        'weightUnits': 2.0,
        'marks': 5.0,
        'overrideReason': 'approved override',
      });
      expect(payload.containsKey('weight'), isFalse);
      expect(payload.containsKey('draftSectionId'), isFalse);
    });

    test('attachment model reads backend displayOrder alias', () {
      final attachment =
          QuestionBankAttachmentModel.fromJson(const <String, dynamic>{
            'id': 9,
            'fileId': 44,
            'attachmentType': 'image',
            'displayOrder': 3,
            'isPrimary': true,
          });

      expect(attachment.orderIndex, 3);
      expect(attachment.isPrimary, isTrue);
    });

    test('new enums round-trip backend strings', () {
      expect(
        QuestionBankAttachmentType.fromJson('document').toJson(),
        'document',
      );
      expect(
        QuestionBankGroupType.fromJson('case_study').toJson(),
        'case_study',
      );
      expect(ExamDraftStatus.fromJson('expired').toJson(), 'expired');
      expect(
        ExamRoundingPolicy.fromJson('nearest_0_25').toJson(),
        'nearest_0_25',
      );
      expect(ExamExportFormat.fromJson('html_doc').toJson(), 'html_doc');
    });

    test('draft helper getters order items and lock expired drafts', () {
      final draft = ExamDraftModel.fromJson(<String, dynamic>{
        'id': 4,
        'courseId': 10,
        'title': 'Draft',
        'status': 'expired',
        'expiresAt': DateTime.now()
            .subtract(const Duration(minutes: 1))
            .toIso8601String(),
        'sections': <Map<String, dynamic>>[
          <String, dynamic>{'id': 9, 'title': 'B', 'sectionOrder': 1},
          <String, dynamic>{'id': 8, 'title': 'A', 'sectionOrder': 0},
        ],
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 2,
            'questionId': 12,
            'chapterId': 3,
            'questionType': 'written',
            'difficulty': 'medium',
            'bloomLevel': 'understand',
            'weight': 1,
            'weightUnits': 1,
            'itemOrder': 1,
            'draftSectionId': 9,
          },
          <String, dynamic>{
            'id': 1,
            'questionId': 11,
            'chapterId': 3,
            'questionType': 'mcq',
            'difficulty': 'easy',
            'bloomLevel': 'remember',
            'weight': 1,
            'weightUnits': 1,
            'itemOrder': 0,
          },
        ],
      });

      expect(draft.isEditable, isFalse);
      expect(draft.isExpired, isTrue);
      expect(draft.hasSections, isTrue);
      expect(draft.orderedSections.map((item) => item.id), <int>[8, 9]);
      expect(draft.orderedItems.map((item) => item.id), <int>[1, 2]);
      expect(draft.itemsForSection(9).single.id, 2);
    });
  });
}
