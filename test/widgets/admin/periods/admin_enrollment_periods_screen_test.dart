import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/screens/admin/periods/admin_enrollment_periods_screen.dart';
import 'package:edu_verse/services/api/admin_periods_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/storage_service.dart';

class _FakeStorageService extends StorageService {
  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<int> getFontSize() async => 1;

  @override
  Future<void> setDarkMode(bool isDark) async {}

  @override
  Future<void> setFontSize(int sizeIndex) async {}
}

class _FakeEnrollmentPeriodsService extends AdminPeriodsService {
  _FakeEnrollmentPeriodsService({required this.periods})
    : super(coreApiClient: CoreApiClient.test());

  final List<EnrollmentPeriodModel> periods;

  @override
  Future<ServiceResult<List<EnrollmentPeriodModel>>>
  getEnrollmentPeriods() async {
    return ServiceResult<List<EnrollmentPeriodModel>>.success(periods);
  }
}

Widget _buildHost(Widget child) {
  final themeBloc = ThemeBloc(storageService: _FakeStorageService());

  return BlocProvider<ThemeBloc>.value(
    value: themeBloc,
    child: MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
      home: child,
    ),
  );
}

void main() {
  testWidgets('renders localized enrollment period details', (
    WidgetTester tester,
  ) async {
    final service = _FakeEnrollmentPeriodsService(
      periods: <EnrollmentPeriodModel>[
        EnrollmentPeriodModel(
          id: 1,
          semester: 'Spring 2026',
          department: 'Computer Science',
          registrationStart: DateTime(2026, 1, 1),
          registrationEnd: DateTime(2026, 1, 31),
          totalStudents: 200,
          registeredStudents: 120,
          description: 'Main semester registration window',
          status: 'active',
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHost(AdminEnrollmentPeriodsScreen(periodsService: service)),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(AdminEnrollmentPeriodsScreen),
    );
    final AppLocalizations l10n = AppLocalizations.of(context);

    expect(find.text(l10n.adminEnrollmentPeriods), findsOneWidget);
    expect(find.text('Spring 2026'), findsOneWidget);
    expect(
      find.text(l10n.adminDateRange('2026-01-01', '2026-01-31')),
      findsOneWidget,
    );
    expect(find.text(l10n.adminEnrollmentRegistered(120, 200)), findsOneWidget);
  });
}
