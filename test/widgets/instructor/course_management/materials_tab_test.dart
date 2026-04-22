import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
import 'package:edu_verse/widgets/instructor/course_management/materials_tab.dart';

Widget _buildTab(
  List<MaterialModel> materials, {
  String? partialFailureMessage,
  List<String> failedMaterialIds = const <String>[],
  VoidCallback? onRetryFailedMaterials,
}) {
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
            partialFailureMessage: partialFailureMessage,
            failedMaterialIds: failedMaterialIds,
            onRetryFailedMaterials: onRetryFailedMaterials,
            isDark: false,
            l10n: AppLocalizations.of(context),
          ),
        );
      },
    ),
  );
}

@Timeout(Duration(seconds: 30))
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

  testWidgets('keeps material action buttons at least 48x48', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTab(const <MaterialModel>[
        MaterialModel(
          id: 'm1',
          title: 'Week 1 Slides',
          type: 'document',
          fileSize: '1.2 MB',
          fileUrl: 'https://example.com/slide.pdf',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    final keys = <String>[
      'material-action-visibility',
      'material-action-edit',
      'material-action-delete',
    ];

    for (final key in keys) {
      final size = tester.getSize(find.byKey(ValueKey<String>(key)).first);
      expect(size.width >= 48, isTrue);
      expect(size.height >= 48, isTrue);
    }
  });

  testWidgets('shows empty state when no materials are available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTab(const <MaterialModel>[]));
    await tester.pump();

    expect(find.text('No materials yet'), findsOneWidget);
  });

  testWidgets('shows partial failure banner and retry action', (
    WidgetTester tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      _buildTab(
        const <MaterialModel>[],
        partialFailureMessage: 'structure failed',
        failedMaterialIds: const <String>['m1'],
        onRetryFailedMaterials: () => retried = true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('structure failed'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
