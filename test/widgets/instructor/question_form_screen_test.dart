import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/widgets/instructor/question_bank/question_form_hero.dart';

void main() {
  testWidgets('question form hero renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuestionFormHero(title: 'Studio', subtitle: 'Build', tiles: {'A': '1'}),
      ),
    );
    expect(find.text('Studio'), findsOneWidget);
  });
}
