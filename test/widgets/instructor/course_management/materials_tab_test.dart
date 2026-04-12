import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/widgets/instructor/course_management/materials_tab.dart';

Widget _buildTab(List<MaterialModel> materials) {
  return MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
    home: Builder(
      builder: (context) {
        return Scaffold(
          body: MaterialsTab(
            materials: materials,
            isDark: false,
            l10n: AppLocalizations.of(context),
          ),
        );
      },
    ),
  );
}

void main() {
  testWidgets('shows empty state when there are no materials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTab(const <MaterialModel>[]));
    await tester.pumpAndSettle();

    expect(find.text('No materials yet'), findsOneWidget);
  });

  testWidgets('renders material cards in list', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTab(const <MaterialModel>[
        MaterialModel(
          id: 'm1',
          title: 'Week 1 Slides',
          type: 'document',
          fileSize: '1.2 MB',
          fileUrl: 'https://example.com/slide.pdf',
        ),
        MaterialModel(
          id: 'm2',
          title: 'Week 1 Lecture',
          type: 'video',
          fileSize: '50.0 MB',
          fileUrl: 'https://example.com/video.mp4',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Week 1 Slides'), findsOneWidget);
    expect(find.text('Week 1 Lecture'), findsOneWidget);
  });
}
