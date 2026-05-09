import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/question_bank/question_bulk_editor.dart';

void main() {
  testWidgets('bulk editor shows row count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: QuestionBulkEditor(rowCount: 1, onAddRow: () {}, children: const []),
      ),
    );
    expect(find.textContaining('1 / 50'), findsOneWidget);
  });
}
