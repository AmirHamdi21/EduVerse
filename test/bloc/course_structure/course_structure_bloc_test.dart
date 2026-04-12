import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/course_structure/course_structure_bloc.dart';
import 'package:edu_verse/bloc/course_structure/course_structure_event.dart';
import 'package:edu_verse/bloc/course_structure/course_structure_state.dart';
import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/course_service.dart';

class _FakeCourseService extends CourseService {
  _FakeCourseService({required this.items})
    : super(coreApiClient: CoreApiClient.test());

  final List<CourseStructureModel> items;
  Map<String, dynamic>? lastCreatePayload;
  Map<String, dynamic>? lastUpdatePayload;
  String? deletedItemId;
  List<int>? reorderedIds;

  @override
  Future<List<CourseStructureModel>> getStructure(
    dynamic courseId, {
    bool forceRefresh = false,
  }) async {
    return List<CourseStructureModel>.from(items);
  }

  @override
  Future<CourseStructureModel> createStructureItem(
    dynamic courseId,
    Map<String, dynamic> body,
  ) async {
    lastCreatePayload = body;
    return items.first;
  }

  @override
  Future<CourseStructureModel> updateStructureItem(
    dynamic courseId,
    dynamic itemId,
    Map<String, dynamic> body,
  ) async {
    lastUpdatePayload = body;
    return items.first;
  }

  @override
  Future<void> deleteStructureItem(dynamic courseId, dynamic itemId) async {
    deletedItemId = itemId.toString();
  }

  @override
  Future<void> reorderStructureItems(
    dynamic courseId,
    List<int> itemIds,
  ) async {
    reorderedIds = itemIds;
  }
}

CourseStructureModel _item({required String id, required int week}) {
  return CourseStructureModel(
    organizationId: id,
    courseId: '1',
    organizationType: 'lecture',
    title: 'Week $week Topic',
    weekNumber: week,
    orderIndex: week,
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('CourseStructureBloc', () {
    test('loads structure items', () async {
      final service = _FakeCourseService(
        items: <CourseStructureModel>[_item(id: '1', week: 1)],
      );
      final bloc = CourseStructureBloc(courseService: service);

      bloc.add(const LoadStructure(1));
      await _flush();
      await _flush();

      expect(bloc.state, isA<StructureLoaded>());
      final state = bloc.state as StructureLoaded;
      expect(state.courseId, 1);
      expect(state.items.length, 1);

      await bloc.close();
    });

    test('create item sends payload and refreshes list', () async {
      final service = _FakeCourseService(
        items: <CourseStructureModel>[_item(id: '1', week: 1)],
      );
      final bloc = CourseStructureBloc(courseService: service);

      bloc.add(
        const CreateStructureItem(
          courseId: 1,
          title: 'Week 2',
          weekNumber: 2,
          description: 'Stacks',
        ),
      );
      await _flush();
      await _flush();
      await _flush();

      expect(service.lastCreatePayload, isNotNull);
      expect(service.lastCreatePayload!['title'], 'Week 2');
      expect(service.lastCreatePayload!['weekNumber'], 2);
      expect(bloc.state, isA<StructureLoaded>());

      await bloc.close();
    });

    test('update, delete, and reorder operations trigger refresh', () async {
      final service = _FakeCourseService(
        items: <CourseStructureModel>[
          _item(id: '1', week: 1),
          _item(id: '2', week: 2),
        ],
      );
      final bloc = CourseStructureBloc(courseService: service);

      bloc.add(
        const UpdateStructureItem(
          courseId: 1,
          itemId: '1',
          payload: <String, dynamic>{'title': 'Updated'},
        ),
      );
      await _flush();
      await _flush();

      bloc.add(const DeleteStructureItem(courseId: 1, itemId: '2'));
      await _flush();
      await _flush();

      bloc.add(const ReorderStructureItems(courseId: 1, itemIds: <int>[2, 1]));
      await _flush();
      await _flush();

      expect(service.lastUpdatePayload, <String, dynamic>{'title': 'Updated'});
      expect(service.deletedItemId, '2');
      expect(service.reorderedIds, <int>[2, 1]);
      expect(bloc.state, isA<StructureLoaded>());

      await bloc.close();
    });
  });
}
