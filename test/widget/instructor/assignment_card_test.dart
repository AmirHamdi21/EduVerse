import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/models/assignments/assignment_model.dart';
import 'package:edu_verse/models/core/enums/assignment_enums.dart' as api;
import 'package:edu_verse/widgets/instructor/assignments/assignment_card.dart';

AssignmentModel _assignment({
  required int id,
  required api.AssignmentStatus status,
  required String title,
}) {
  return AssignmentModel(
    id: id.toString(),
    assignmentId: id,
    courseId: 1,
    title: title,
    description: 'description',
    courseName: 'Course',
    courseCode: 'C1',
    instructorName: 'Instructor',
    type: AssignmentType.document,
    status: AssignmentStatus.pending,
    priority: AssignmentPriority.medium,
    dueDate: DateTime(2026, 6, 1),
    maxGrade: 100,
    createdAt: DateTime(2026, 1, 1),
    apiStatus: status,
    submissionType: api.SubmissionType.file,
    lateSubmissionAllowed: true,
    maxFileSizeMb: 10,
  );
}

void main() {
  testWidgets('renders status badges for all lifecycle statuses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              AssignmentCard(
                assignment: _assignment(
                  id: 1,
                  status: api.AssignmentStatus.draft,
                  title: 'A1',
                ),
                onViewSubmissions: () {},
              ),
              AssignmentCard(
                assignment: _assignment(
                  id: 2,
                  status: api.AssignmentStatus.published,
                  title: 'A2',
                ),
                onViewSubmissions: () {},
              ),
              AssignmentCard(
                assignment: _assignment(
                  id: 3,
                  status: api.AssignmentStatus.closed,
                  title: 'A3',
                ),
                onViewSubmissions: () {},
              ),
              AssignmentCard(
                assignment: _assignment(
                  id: 4,
                  status: api.AssignmentStatus.archived,
                  title: 'A4',
                ),
                onViewSubmissions: () {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Published'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
  });

  testWidgets('hides management actions in read-only mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssignmentCard(
            assignment: _assignment(
              id: 9,
              status: api.AssignmentStatus.published,
              title: 'Read only',
            ),
            canManage: false,
            onViewSubmissions: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
    expect(find.text('View Submissions'), findsOneWidget);
  });
}
