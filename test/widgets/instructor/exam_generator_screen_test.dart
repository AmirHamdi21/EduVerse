import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/widgets/instructor/exam_generator/exam_generator_skeletons.dart';

void main() {
  testWidgets('exam generator skeleton renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamGeneratorSkeletons()));
    expect(find.byType(ExamGeneratorSkeletons), findsOneWidget);
  });
}
