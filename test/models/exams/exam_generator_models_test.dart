import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/exams/exam_export_response_model.dart';
import 'package:edu_verse/models/exams/exam_page_model.dart';
import 'package:edu_verse/models/exams/exam_response_model.dart';
import 'package:edu_verse/models/exams/exam_shortage_model.dart';

void main() {
  test('parses exam page data,meta backend shape', () {
    final page = ExamPageModel<ExamResponseModel>.fromJson(
      <String, dynamic>{
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
      },
      ExamResponseModel.fromJson,
    );

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
}
