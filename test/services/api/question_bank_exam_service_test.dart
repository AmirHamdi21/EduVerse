import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/instructor/question_bank_exam_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/question_bank_exam_service.dart';

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
    final next = responses.isNotEmpty
        ? responses.removeAt(0)
        : <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}};
    final statusCode = next['statusCode'] as int? ?? 200;

    return ResponseBody.fromString(
      jsonEncode(next['data'] ?? <String, dynamic>{}),
      statusCode,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _questionJson({int id = 1}) {
  return <String, dynamic>{
    'id': id,
    'courseId': 10,
    'chapterId': 4,
    'questionType': 'mcq',
    'difficulty': 'medium',
    'bloomLevel': 'understand',
    'status': 'approved',
    'questionText': 'What is a queue?',
    'defaultWeight': 1,
    'options': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 100,
        'optionText': 'FIFO',
        'isCorrect': true,
        'optionOrder': 1,
      },
    ],
  };
}

void main() {
  group('QuestionBankExamService', () {
    test('getQuestions preserves hasAttachments false query value', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <Map<String, dynamic>>[_questionJson(id: 9)],
            'meta': <String, dynamic>{
              'total': 1,
              'page': 2,
              'limit': 5,
              'totalPages': 1,
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.getQuestions(
        courseId: 10,
        status: QuestionBankStatus.approved,
        hasAttachments: false,
        page: 2,
        limit: 5,
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.first.path, '/question-bank/questions');
      expect(adapter.requests.first.method, 'GET');
      expect(adapter.requests.first.queryParameters['courseId'], 10);
      expect(adapter.requests.first.queryParameters['status'], 'approved');
      expect(adapter.requests.first.queryParameters['hasAttachments'], false);
      expect(adapter.requests.first.queryParameters['page'], 2);
      expect(adapter.requests.first.queryParameters['limit'], 5);
      expect(result.data!.data.single.id, 9);
    });

    test('list endpoints clamp page and limit to backend bounds', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <Map<String, dynamic>>[],
            'total': 0,
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.getQuestions(page: 0, limit: 500);

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.queryParameters['page'], 1);
      expect(adapter.requests.single.queryParameters['limit'], 100);
      expect(result.data!.page, 1);
      expect(result.data!.limit, 100);
    });

    test('createChapter sends only strict backend DTO fields', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 201,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'id': 4,
              'courseId': 10,
              'name': 'Chapter 3',
              'chapterOrder': 3,
              'isActive': 1,
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.createChapter(
        courseId: 10,
        name: ' Chapter 3 ',
        chapterOrder: 3,
        description: 'ignored by strict backend DTO',
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/courses/10/chapters');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, <String, dynamic>{
        'name': 'Chapter 3',
        'chapterOrder': 3,
      });
    });

    test('updateChapter uses backend chapter patch endpoint', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'id': 4,
              'courseId': 10,
              'name': 'Updated chapter',
              'chapterOrder': 3,
              'isActive': 1,
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.updateChapter(
        courseId: 10,
        chapterId: 4,
        name: ' Updated chapter ',
        chapterOrder: 3,
        isActive: 1,
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/courses/10/chapters/4');
      expect(adapter.requests.single.method, 'PATCH');
      expect(adapter.requests.single.data, <String, dynamic>{
        'name': 'Updated chapter',
        'chapterOrder': 3,
        'isActive': 1,
      });
      expect(result.data!.name, 'Updated chapter');
    });

    test(
      'deleteChapter and explicit question delete use destructive routes',
      () async {
        final client = CoreApiClient.test();
        final adapter = _QueueAdapter(<Map<String, dynamic>>[
          <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{
              'message': 'Chapter deleted successfully',
            },
          },
          <String, dynamic>{
            'statusCode': 200,
            'data': <String, dynamic>{
              'message': 'Question archived successfully',
            },
          },
        ]);
        client.dio.httpClientAdapter = adapter;

        final service = QuestionBankExamService(coreApiClient: client);
        final chapterResult = await service.deleteChapter(
          courseId: 10,
          chapterId: 4,
        );
        final questionResult = await service.softDeleteQuestionByDelete(9);

        expect(chapterResult.isSuccess, isTrue);
        expect(questionResult.isSuccess, isTrue);
        expect(adapter.requests.first.path, '/courses/10/chapters/4');
        expect(adapter.requests.first.method, 'DELETE');
        expect(adapter.requests.last.path, '/question-bank/questions/9');
        expect(adapter.requests.last.method, 'DELETE');
      },
    );

    test('exportWord forces backend-supported html_doc format', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'fileName': 'exam-22.doc',
              'mimeType': 'application/msword',
              'content': base64Encode(utf8.encode('<html>exam</html>')),
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.exportWord(22, includeAnswerKey: false);

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/exams/22/export-word');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, <String, dynamic>{
        'format': 'html_doc',
        'includeAnswerKey': false,
      });
      expect(result.data!.fileName, 'exam-22.doc');
      expect(result.data!.mimeType, 'application/msword');
    });

    test('question update payload strips child response fields', () {
      final payload = QuestionBankExamService.buildQuestionUpdatePayload(
        questionText: '  Updated prompt  ',
        expectedAnswerText: null,
        options: const <QuestionBankOptionModel>[
          QuestionBankOptionModel(
            optionId: 5,
            optionText: '  Choice A ',
            isCorrect: true,
            optionOrder: 1,
          ),
        ],
        fillBlanks: const <QuestionBankFillBlankModel>[
          QuestionBankFillBlankModel(
            blankId: 8,
            blankKey: ' result ',
            acceptableAnswer: ' done ',
            isCaseSensitive: false,
          ),
        ],
      );

      expect(payload.containsKey('courseId'), isFalse);
      expect(payload['questionText'], 'Updated prompt');
      expect(payload['expectedAnswerText'], isNull);
      expect(payload['options'], <Map<String, dynamic>>[
        <String, dynamic>{'optionText': 'Choice A', 'isCorrect': true},
      ]);
      expect(payload['fillBlanks'], <Map<String, dynamic>>[
        <String, dynamic>{
          'blankKey': 'result',
          'acceptableAnswer': 'done',
          'isCaseSensitive': false,
        },
      ]);
    });

    test('addDraftItem posts only add endpoint DTO fields', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 201,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'id': 3,
              'questionId': 9,
              'chapterId': 4,
              'questionType': 'mcq',
              'difficulty': 'easy',
              'bloomLevel': 'remember',
              'weight': 1,
              'weightUnits': 2,
              'marks': 5,
              'itemOrder': 1,
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.addDraftItem(
        draftId: 44,
        questionId: 9,
        weightUnits: 2,
        marks: 5,
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/exams/drafts/44/items');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, <String, dynamic>{
        'questionId': 9,
        'weightUnits': 2.0,
        'marks': 5.0,
      });
      expect(
        (adapter.requests.single.data as Map).containsKey('weight'),
        isFalse,
      );
      expect(result.data!.id, 3);
    });

    test(
      'createQuestionsBatch applies strict nested course and chapter ids',
      () async {
        final client = CoreApiClient.test();
        final adapter = _QueueAdapter(<Map<String, dynamic>>[
          <String, dynamic>{
            'statusCode': 201,
            'data': <String, dynamic>{
              'data': <String, dynamic>{
                'questions': <Map<String, dynamic>>[_questionJson(id: 14)],
              },
            },
          },
        ]);
        client.dio.httpClientAdapter = adapter;

        final service = QuestionBankExamService(coreApiClient: client);
        final result = await service.createQuestionsBatch(
          courseId: 10,
          defaultChapterId: 4,
          questions: <Map<String, dynamic>>[
            QuestionBankExamService.buildQuestionPayload(
              courseId: 10,
              chapterId: 4,
              questionType: QuestionBankQuestionType.mcq,
              difficulty: QuestionBankDifficulty.medium,
              bloomLevel: QuestionBankBloomLevel.understand,
              questionText: 'What is FIFO?',
              options: const <QuestionBankOptionModel>[
                QuestionBankOptionModel(optionText: 'Queue', isCorrect: true),
              ],
            ),
            <String, dynamic>{
              'questionType': 'written',
              'difficulty': 'easy',
              'bloomLevel': 'remember',
              'questionText': 'Define stack.',
            },
          ],
        );

        expect(result.isSuccess, isTrue);
        expect(adapter.requests.single.path, '/question-bank/questions/batch');
        final data = adapter.requests.single.data as Map<String, dynamic>;
        expect(data['courseId'], 10);
        expect(data['defaultChapterId'], 4);
        expect(data['questions'], hasLength(2));
        expect(data['questions'][0]['courseId'], 10);
        expect(data['questions'][0]['chapterId'], 4);
        expect(data['questions'][1]['courseId'], 10);
        expect(data['questions'][1]['chapterId'], 4);
        expect(result.data!.single.id, 14);
      },
    );

    test('addQuestionAttachment omits isPrimary when false', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 201,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'id': 7,
              'fileId': 90,
              'attachmentType': 'image',
              'caption': 'Diagram',
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.addQuestionAttachment(
        questionId: 33,
        fileId: 90,
        attachmentType: 'image',
        caption: ' Diagram ',
      );

      expect(result.isSuccess, isTrue);
      expect(
        adapter.requests.single.path,
        '/question-bank/questions/33/attachments',
      );
      expect(adapter.requests.single.data, <String, dynamic>{
        'fileId': 90,
        'attachmentType': 'image',
        'caption': 'Diagram',
      });
    });

    test('reorderQuestionAttachments sends display order items', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}},
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.reorderQuestionAttachments(
        questionId: 33,
        attachmentIds: <int>[12, 10, 15],
      );

      expect(result.isSuccess, isTrue);
      expect(
        adapter.requests.single.path,
        '/question-bank/questions/33/attachments/reorder',
      );
      expect(adapter.requests.single.method, 'PATCH');
      expect(adapter.requests.single.data, <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{'attachmentId': 12, 'displayOrder': 0},
          <String, dynamic>{'attachmentId': 10, 'displayOrder': 1},
          <String, dynamic>{'attachmentId': 15, 'displayOrder': 2},
        ],
      });
    });

    test('updateQuestionAttachment preserves explicit null clears', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 200,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'id': 12,
              'attachmentType': 'image',
              'caption': null,
              'altText': null,
              'isPrimary': true,
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.updateQuestionAttachment(
        questionId: 33,
        attachmentId: 12,
        caption: null,
        altText: null,
        isPrimary: true,
      );

      expect(result.isSuccess, isTrue);
      expect(
        adapter.requests.single.path,
        '/question-bank/questions/33/attachments/12',
      );
      expect(adapter.requests.single.method, 'PATCH');
      expect(adapter.requests.single.data, <String, dynamic>{
        'caption': null,
        'altText': null,
        'isPrimary': true,
      });
      expect(result.data!.isPrimary, isTrue);
    });

    test('question create payload includes prompt image file id', () {
      final payload = QuestionBankExamService.buildQuestionPayload(
        courseId: 10,
        chapterId: 4,
        questionType: QuestionBankQuestionType.written,
        difficulty: QuestionBankDifficulty.easy,
        bloomLevel: QuestionBankBloomLevel.remember,
        questionFileId: 88,
        expectedAnswerText: 'Answer',
      );

      expect(payload['questionFileId'], 88);
      expect(payload['questionText'], isNull);
    });

    test('reorderGroupQuestions sends full visible order', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}},
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.reorderGroupQuestions(
        groupId: 5,
        questionIds: <int>[31, 20, 44],
      );

      expect(result.isSuccess, isTrue);
      expect(
        adapter.requests.single.path,
        '/question-bank/groups/5/questions/reorder',
      );
      expect(adapter.requests.single.method, 'PATCH');
      expect(adapter.requests.single.data, <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{'questionId': 31, 'itemOrder': 0},
          <String, dynamic>{'questionId': 20, 'itemOrder': 1},
          <String, dynamic>{'questionId': 44, 'itemOrder': 2},
        ],
      });
    });

    test('reorderDraftItems sends every loaded item once', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{'statusCode': 200, 'data': <String, dynamic>{}},
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.reorderDraftItems(
        draftId: 17,
        itemIds: <int>[8, 9],
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/exams/drafts/17/items/reorder');
      expect(adapter.requests.single.method, 'PATCH');
      expect(adapter.requests.single.data, <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{'itemId': 8, 'itemOrder': 0},
          <String, dynamic>{'itemId': 9, 'itemOrder': 1},
        ],
      });
    });

    test('addDraftSection uses section endpoint DTO fields', () async {
      final client = CoreApiClient.test();
      final adapter = _QueueAdapter(<Map<String, dynamic>>[
        <String, dynamic>{
          'statusCode': 201,
          'data': <String, dynamic>{
            'data': <String, dynamic>{
              'id': 4,
              'title': 'Part A',
              'sectionOrder': 0,
              'totalMarks': 20,
              'answerPolicy': 'answer_all',
            },
          },
        },
      ]);
      client.dio.httpClientAdapter = adapter;

      final service = QuestionBankExamService(coreApiClient: client);
      final result = await service.addDraftSection(
        draftId: 17,
        title: ' Part A ',
        totalMarks: 20,
      );

      expect(result.isSuccess, isTrue);
      expect(adapter.requests.single.path, '/exams/drafts/17/sections');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, <String, dynamic>{
        'title': 'Part A',
        'answerPolicy': 'answer_all',
        'totalMarks': 20.0,
      });
      expect(result.data!.id, 4);
    });
  });
}
