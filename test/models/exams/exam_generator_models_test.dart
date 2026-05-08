import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/exams/exam_full_detail_model.dart';
import 'package:edu_verse/models/exams/exam_export_options_model.dart';
import 'package:edu_verse/models/exams/exam_export_response_model.dart';
import 'package:edu_verse/models/exams/exam_generator_enums.dart';
import 'package:edu_verse/models/exams/exam_page_model.dart';
import 'package:edu_verse/models/exams/exam_response_model.dart';
import 'package:edu_verse/models/exams/exam_shortage_model.dart';

void main() {
  test('parses exam page data,meta backend shape', () {
    final page = ExamPageModel<ExamResponseModel>.fromJson(<String, dynamic>{
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 3,
          'courseId': 4,
          'title': 'Midterm',
          'status': 'draft',
        },
      ],
      'meta': <String, dynamic>{
        'total': 1,
        'page': 1,
        'limit': 20,
        'totalPages': 1,
      },
    }, ExamResponseModel.fromJson);

    expect(page.data.first.title, 'Midterm');
    expect(page.totalPages, 1);
  });

  test('parses shortage and decodes base64 export', () {
    final shortage = ExamShortageModel.fromJson(<String, dynamic>{
      'chapterId': 8,
      'required': 5,
      'available': 2,
    });
    expect(shortage.available, 2);

    final export = ExamExportResponseModel.fromJson(<String, dynamic>{
      'fileName': 'exam-1.doc',
      'mimeType': 'application/msword',
      'content': base64Encode(utf8.encode('<html>ok</html>')),
    });
    expect(utf8.decode(export.decodedBytes), '<html>ok</html>');
  });

  test('serializes paper export mark visibility options', () {
    final json = const ExamExportOptionsModel(
      format: ExamExportFormat.pdf,
      showTotalMarks: false,
      showQuestionMarks: false,
    ).toJson();

    expect(json['format'], 'pdf');
    expect(json['showTotalMarks'], isFalse);
    expect(json['showQuestionMarks'], isFalse);
  });

  test('groups saved exam top-level items into their sections', () {
    final detail = ExamFullDetailModel.fromJson(<String, dynamic>{
      'id': 10,
      'courseId': 4,
      'title': 'Final',
      'status': 'draft',
      'sections': <Map<String, dynamic>>[
        <String, dynamic>{'id': 7, 'title': 'MCQ', 'totalMarks': 20},
      ],
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'sectionId': 7,
          'itemOrder': 0,
          'marks': 5,
          'snapshot': <String, dynamic>{'questionText': 'Inside section'},
        },
        <String, dynamic>{
          'id': 2,
          'sectionId': null,
          'itemOrder': 1,
          'marks': 5,
          'snapshot': <String, dynamic>{'questionText': 'Unassigned'},
        },
      ],
    });

    expect(detail.sections.single.items, hasLength(1));
    expect(detail.sections.single.items.single.questionText, 'Inside section');
    expect(detail.unsectionedItems, hasLength(1));
    expect(detail.unsectionedItems.single.questionText, 'Unassigned');
  });
}
