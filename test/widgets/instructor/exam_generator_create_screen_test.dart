import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/exam_generator/exam_shortage_panel.dart';
import 'package:edu_verse/models/exams/exam_shortage_model.dart';

void main() {
  testWidgets('shortage panel renders bucket details', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ExamShortagePanel(
          shortages: [ExamShortageModel(chapterId: 2, required: 5, available: 1)],
        ),
      ),
    );
    expect(find.textContaining('Chapter 2'), findsOneWidget);
  });
}
