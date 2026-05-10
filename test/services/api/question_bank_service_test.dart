import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/models/question_bank/question_bank_enums.dart';
import 'package:edu_verse/models/question_bank/question_bank_form_payload.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/question_bank_service.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.responses);
  final List<Map<String, dynamic>> responses;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final next = responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(next['data']),
      next['statusCode'] as int,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'getQuestions uses /question-bank/questions and parses data,total',
    () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter([
        {
          'statusCode': 200,
          'data': {
            'total': 1,
            'data': [
              {
                'id': 1,
                'questionId': 1,
                'courseId': 2,
                'chapterId': 3,
                'questionType': 'mcq',
                'difficulty': 'easy',
                'bloomLevel': 'remembering',
                'status': 'draft',
              },
            ],
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final result = await QuestionBankService(
        coreApiClient: client,
      ).getQuestions(courseId: 2, page: 1, limit: 20);

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/question-bank/questions');
      expect(result.data!.total, 1);
    },
  );

  test(
    'chapter update/delete and question delete use exact backend paths',
    () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter([
        {
          'statusCode': 200,
          'data': {
            'id': 3,
            'courseId': 2,
            'name': 'Updated',
            'chapterOrder': 4,
            'isActive': true,
          },
        },
        {'statusCode': 200, 'data': {}},
        {'statusCode': 200, 'data': {}},
        {'statusCode': 204, 'data': {}},
      ]);
      client.dio.httpClientAdapter = adapter;
      final service = QuestionBankService(coreApiClient: client);

      await service.updateChapter(
        courseId: 2,
        chapterId: 3,
        name: 'Updated',
        chapterOrder: 4,
        isActive: true,
      );
      await service.deleteChapter(courseId: 2, chapterId: 3);
      await service.deleteQuestion(9);
      await service.deleteUploadedFile(44);

      expect(adapter.requests[0].method, 'PATCH');
      expect(adapter.requests[0].path, '/courses/2/chapters/3');
      expect(adapter.requests[1].method, 'DELETE');
      expect(adapter.requests[1].path, '/courses/2/chapters/3');
      expect(adapter.requests[2].method, 'DELETE');
      expect(adapter.requests[2].path, '/question-bank/questions/9');
      expect(adapter.requests[3].method, 'DELETE');
      expect(adapter.requests[3].path, '/files/44');
    },
  );

  test('status action parses wrapped question response data', () async {
    final client = CoreApiClient.test();
    final adapter = _QueueAdapter([
      {
        'statusCode': 200,
        'data': {
          'message': 'Question approved successfully',
          'data': {
            'id': 9,
            'questionId': 9,
            'courseId': 2,
            'chapterId': 3,
            'questionType': 'mcq',
            'difficulty': 'easy',
            'bloomLevel': 'remembering',
            'status': 'approved',
          },
        },
      },
    ]);
    client.dio.httpClientAdapter = adapter;

    final result = await QuestionBankService(
      coreApiClient: client,
    ).statusAction(questionId: 9, action: 'approve');

    expect(result.isSuccess, isTrue);
    expect(adapter.requests.single.path, '/question-bank/questions/9/approve');
    expect(result.data!.id, 9);
    expect(result.data!.status, QuestionBankStatus.approved);
  });

  test('attachments and grouped batch use exact payload shapes', () async {
    final client = CoreApiClient.test();
    final adapter = _QueueAdapter([
      {
        'statusCode': 200,
        'data': {
          'id': 4,
          'fileId': 7,
          'attachmentType': 'image',
          'caption': 'Diagram',
          'displayOrder': 2,
          'isPrimary': 1,
        },
      },
      {'statusCode': 200, 'data': {}},
      {
        'statusCode': 200,
        'data': [
          {
            'id': 1,
            'questionId': 1,
            'courseId': 2,
            'chapterId': 3,
            'questionType': 'mcq',
            'difficulty': 'easy',
            'bloomLevel': 'remembering',
            'status': 'draft',
          },
        ],
      },
    ]);
    client.dio.httpClientAdapter = adapter;
    final service = QuestionBankService(coreApiClient: client);

    await service.updateAttachment(
      questionId: 5,
      attachmentId: 4,
      caption: 'Diagram',
      isPrimary: true,
    );
    await service.reorderAttachments(
      questionId: 5,
      items: [
        {'attachmentId': 4, 'displayOrder': 0},
      ],
    );
    await service.addGroupedQuestions(groupId: 8, questions: const []);

    expect(
      adapter.requests[0].path,
      '/question-bank/questions/5/attachments/4',
    );
    expect(adapter.requests[0].data, containsPair('isPrimary', true));
    expect(
      adapter.requests[1].path,
      '/question-bank/questions/5/attachments/reorder',
    );
    expect(adapter.requests[2].path, '/question-bank/groups/8/questions/batch');
    expect(adapter.requests[2].data, {'questions': <Object>[]});
  });

  test(
    'bulk create keeps nested courseId required by backend validation',
    () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter([
        {
          'statusCode': 200,
          'data': {'created': <Object>[], 'count': 0},
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      await QuestionBankService(coreApiClient: client).bulkCreateQuestions(
        courseId: 14,
        questions: const [
          QuestionBankFormPayload(
            courseId: 14,
            chapterId: 6,
            questionType: QuestionBankType.mcq,
            difficulty: QuestionBankDifficulty.medium,
            bloomLevel: BloomLevel.understanding,
            questionText: 'Question',
          ),
        ],
      );

      final data = adapter.requests.single.data as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>;
      expect(questions.single, containsPair('courseId', 14));
      expect(questions.single, containsPair('chapterId', 6));
    },
  );

  test('group image upload and metadata use dedicated backend shape', () async {
    final file = File('${Directory.systemTemp.path}/qb-group-image-test.png');
    await file.writeAsBytes(<int>[1, 2, 3]);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    final client = CoreApiClient.test();
    final adapter = _QueueAdapter([
      {
        'statusCode': 201,
        'data': {'fileId': 44, 'fileName': 'group.png'},
      },
      {
        'statusCode': 200,
        'data': {
          'id': 9,
          'courseId': 14,
          'chapterId': null,
          'sharedFileId': 44,
          'sharedFileCaption': 'Passage figure',
          'sharedFileAltText': 'Network diagram',
          'groupType': 'image_set',
        },
      },
    ]);
    client.dio.httpClientAdapter = adapter;
    final service = QuestionBankService(coreApiClient: client);

    final upload = await service.uploadGroupImage(file.path);
    await service.createGroup(
      courseId: 14,
      sharedFileId: upload.data!.fileId,
      sharedFileCaption: 'Passage figure',
      sharedFileAltText: 'Network diagram',
      groupType: QuestionGroupType.imageSet,
    );

    expect(adapter.requests[0].method, 'POST');
    expect(adapter.requests[0].path, '/question-bank/groups/upload-image');
    expect(adapter.requests[1].data, isNot(contains('chapterId')));
    expect(adapter.requests[1].data, containsPair('sharedFileId', 44));
    expect(
      adapter.requests[1].data,
      containsPair('sharedFileCaption', 'Passage figure'),
    );
    expect(
      adapter.requests[1].data,
      containsPair('sharedFileAltText', 'Network diagram'),
    );
  });
}
