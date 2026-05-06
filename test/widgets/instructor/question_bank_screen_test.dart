import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/widgets/instructor/question_bank/question_bank_skeletons.dart';

void main() {
  testWidgets('question bank skeleton renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QuestionBankSkeletons()));
    expect(find.byType(QuestionBankSkeletons), findsOneWidget);
  });
}
