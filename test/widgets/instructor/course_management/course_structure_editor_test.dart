import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/core/course_structure_model.dart';
import 'package:edu_verse/widgets/instructor/course_management/course_structure_editor.dart';
import 'package:edu_verse/widgets/instructor/course_management/structure_item_card.dart';

Widget _buildEditor({
  required List<CourseStructureModel> items,
  Map<int, int> materialCountsByWeek = const <int, int>{},
  CreateStructureItemCallback? onCreate,
  DeleteStructureItemCallback? onDelete,
  ReorderStructureItemsCallback? onReorder,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: CourseStructureEditor(
          items: items,
          materialCountsByWeek: materialCountsByWeek,
          isDark: false,
          onCreate: onCreate,
          onDelete: onDelete,
          onReorder: onReorder,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders structure item card with material count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildEditor(
        items: const <CourseStructureModel>[
          CourseStructureModel(
            organizationId: '1',
            courseId: '56',
            organizationType: 'lecture',
            title: 'Week 1: Intro',
            weekNumber: 1,
            orderIndex: 1,
          ),
        ],
        materialCountsByWeek: const <int, int>{1: 3},
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Week 1: Intro'), findsOneWidget);
    expect(find.text('3 materials'), findsOneWidget);
  });

  testWidgets('creates structure item from dialog', (
    WidgetTester tester,
  ) async {
    String? createdTitle;
    int? createdWeek;
    String? createdDescription;

    await tester.pumpWidget(
      _buildEditor(
        items: const <CourseStructureModel>[],
        onCreate: (title, weekNumber, description) {
          createdTitle = title;
          createdWeek = weekNumber;
          createdDescription = description;
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Week'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('structure-title-field')),
      'Week 4: Graphs',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('structure-week-field')),
      '4',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('structure-description-field')),
      'Graph traversal',
    );

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(createdTitle, 'Week 4: Graphs');
    expect(createdWeek, 4);
    expect(createdDescription, 'Graph traversal');
  });

  testWidgets('reorders items when move action is tapped', (
    WidgetTester tester,
  ) async {
    List<int>? reorderedIds;

    await tester.pumpWidget(
      _buildEditor(
        items: const <CourseStructureModel>[
          CourseStructureModel(
            organizationId: '101',
            courseId: '56',
            organizationType: 'lecture',
            title: 'Week 1: Intro',
            weekNumber: 1,
            orderIndex: 1,
          ),
          CourseStructureModel(
            organizationId: '102',
            courseId: '56',
            organizationType: 'lecture',
            title: 'Week 2: Trees',
            weekNumber: 2,
            orderIndex: 2,
          ),
        ],
        onReorder: (ids) => reorderedIds = ids,
      ),
    );
    await tester.pumpAndSettle();

    final firstCard = find.ancestor(
      of: find.text('Week 1: Intro'),
      matching: find.byType(StructureItemCard),
    );
    final moveDown = find.descendant(
      of: firstCard,
      matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
    );

    await tester.tap(moveDown);
    await tester.pumpAndSettle();

    expect(reorderedIds, <int>[102, 101]);
  });

  testWidgets('confirms and emits delete callback for structure item', (
    WidgetTester tester,
  ) async {
    CourseStructureModel? deleted;

    await tester.pumpWidget(
      _buildEditor(
        items: const <CourseStructureModel>[
          CourseStructureModel(
            organizationId: '101',
            courseId: '56',
            organizationType: 'lecture',
            title: 'Week 1: Intro',
            weekNumber: 1,
            orderIndex: 1,
          ),
        ],
        materialCountsByWeek: const <int, int>{1: 2},
        onDelete: (item) => deleted = item,
      ),
    );
    await tester.pumpAndSettle();

    final card = find.ancestor(
      of: find.text('Week 1: Intro'),
      matching: find.byType(StructureItemCard),
    );
    final deleteButton = find.descendant(
      of: card,
      matching: find.byIcon(Icons.delete_outline_rounded),
    );

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete Structure Item?'), findsOneWidget);
    expect(
      find.text('Materials in this week will become ungrouped (not deleted).'),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(deleted?.organizationId, '101');
  });
}
