import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/widgets/instructor/assignments/grading_panel.dart';

void main() {
  testWidgets('shows late penalty breakdown and computed final score', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradingPanel(
            maxScore: 100,
            initialScore: 80,
            latePenaltyPercent: 10,
            daysLate: 1,
            onSave: (_, __) async {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Original Score: 80'), findsOneWidget);
    expect(find.text('Late Penalty: 10% × 1 day(s)'), findsOneWidget);
    expect(find.text('Final Score: 72'), findsOneWidget);
  });

  testWidgets('hides late penalty breakdown for on-time submissions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradingPanel(
            maxScore: 100,
            initialScore: 80,
            latePenaltyPercent: 10,
            daysLate: 0,
            onSave: (_, __) async {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Original Score:'), findsNothing);
    expect(find.textContaining('Final Score:'), findsNothing);
  });
}
