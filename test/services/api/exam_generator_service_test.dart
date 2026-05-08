import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/exam_generator_service.dart';

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
  test('getExams parses data,meta and does not prepend api', () async {
    final client = CoreApiClient.test();
    final adapter = _QueueAdapter([
      {
        'statusCode': 200,
        'data': {
          'data': [
            {'id': 1, 'courseId': 2, 'title': 'Exam', 'status': 'draft'},
          ],
          'meta': {'total': 1, 'page': 1, 'limit': 20, 'totalPages': 1},
        },
      },
    ]);
    client.dio.httpClientAdapter = adapter;

    final result = await ExamGeneratorService(coreApiClient: client).getExams();

    expect(result.isSuccess, isTrue);
    expect(adapter.requests.single.path, '/exams');
    expect(result.data!.data.single.title, 'Exam');
  });

  test('generatePreview maps object-shaped shortage errors', () async {
    final client = CoreApiClient.test();
    final adapter = _QueueAdapter([
      {
        'statusCode': 400,
        'data': {
          'message': {
            'message': 'Insufficient question pool for one or more buckets',
            'shortages': [
              {'chapterId': 2, 'required': 5, 'available': 1},
            ],
          },
        },
      },
    ]);
    client.dio.httpClientAdapter = adapter;

    final result = await ExamGeneratorService(
      coreApiClient: client,
    ).generatePreview(courseId: 1, title: 'Exam');

    expect(result.isFailure, isTrue);
    expect(result.error!.message, contains('Insufficient'));
  });

  test('section and item mutation endpoints use exact backend paths', () async {
    final client = CoreApiClient.test();
    final adapter = _QueueAdapter([
      {
        'statusCode': 200,
        'data': {'id': 3, 'draftId': 2, 'title': 'A', 'sectionOrder': 0},
      },
      {'statusCode': 200, 'data': {}},
      {'statusCode': 200, 'data': {}},
      {
        'statusCode': 200,
        'data': {'id': 4, 'draftId': 2, 'questionId': 9, 'itemOrder': 0},
      },
      {'statusCode': 200, 'data': {}},
      {'statusCode': 200, 'data': {}},
    ]);
    client.dio.httpClientAdapter = adapter;
    final service = ExamGeneratorService(coreApiClient: client);

    await service.updateSection(draftId: 2, sectionId: 3, title: 'A');
    await service.reorderSections(
      draftId: 2,
      items: [
        {'sectionId': 3, 'sectionOrder': 0},
      ],
    );
    await service.deleteSection(draftId: 2, sectionId: 3);
    await service.addItem(draftId: 2, questionId: 9);
    await service.updateItem(
      draftId: 2,
      itemId: 4,
      replacementQuestionId: 10,
      marks: 5,
      overrideReason: 'Manual replacement',
    );
    await service.updateItem(draftId: 2, itemId: 4, clearDraftSection: true);

    expect(adapter.requests[0].method, 'PATCH');
    expect(adapter.requests[0].path, '/exams/drafts/2/sections/3');
    expect(adapter.requests[1].path, '/exams/drafts/2/sections/reorder');
    expect(adapter.requests[2].method, 'DELETE');
    expect(adapter.requests[2].path, '/exams/drafts/2/sections/3');
    expect(adapter.requests[3].path, '/exams/drafts/2/items');
    expect(adapter.requests[4].path, '/exams/drafts/2/items/4');
    expect(adapter.requests[4].data, containsPair('replacementQuestionId', 10));
    expect(adapter.requests[5].path, '/exams/drafts/2/items/4');
    expect(adapter.requests[5].data, containsPair('draftSectionId', null));
  });
}
