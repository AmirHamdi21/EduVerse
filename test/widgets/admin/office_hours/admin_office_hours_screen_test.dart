import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/screens/admin/office_hours/admin_office_hours_screen.dart';
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

class _FakeOfficeHoursService extends AdminPeriodsService {
  _FakeOfficeHoursService({required this.slots, required this.staff})
    : super(coreApiClient: CoreApiClient.test());

  final List<OfficeHourSlotModel> slots;
  final List<AdminStaffSummaryModel> staff;

  @override
  Future<ServiceResult<List<AdminStaffSummaryModel>>> getStaffMembers() async {
    return ServiceResult<List<AdminStaffSummaryModel>>.success(staff);
  }

  @override
  Future<ServiceResult<PaginatedResult<OfficeHourSlotModel>>> getOfficeHours({
    int page = 1,
    int limit = 10,
    int? instructorId,
    String? dayOfWeek,
  }) async {
    return ServiceResult<PaginatedResult<OfficeHourSlotModel>>.success(
      PaginatedResult<OfficeHourSlotModel>(
        items: slots,
        meta: PaginationMeta(
          page: page,
          limit: limit,
          total: slots.length,
          totalPages: 1,
        ),
      ),
    );
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
  testWidgets('renders localized office-hours filters and slot summary', (
    WidgetTester tester,
  ) async {
    final service = _FakeOfficeHoursService(
      staff: const <AdminStaffSummaryModel>[
        AdminStaffSummaryModel(
          userId: 9,
          fullName: 'Dr. Leila Hassan',
          email: 'leila@eduverse.test',
          roles: <String>['instructor'],
        ),
      ],
      slots: const <OfficeHourSlotModel>[
        OfficeHourSlotModel(
          slotId: 1,
          instructorId: 9,
          dayOfWeek: 'MONDAY',
          startTime: '09:00',
          endTime: '10:00',
          location: 'Room 101',
          mode: 'in_person',
          maxAppointments: 5,
          currentAppointments: 1,
          isActive: true,
          notes: 'Bring your project proposal',
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHost(AdminOfficeHoursScreen(periodsService: service)),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(AdminOfficeHoursScreen),
    );
    final AppLocalizations l10n = AppLocalizations.of(context);

    expect(find.text(l10n.officeHours), findsOneWidget);
    expect(find.text(l10n.adminFilterByMode), findsOneWidget);
    expect(find.text(l10n.adminFilterByRole), findsOneWidget);
    expect(find.text('Dr. Leila Hassan'), findsOneWidget);
    expect(find.text(l10n.adminAppointmentsRatio(1, 5)), findsOneWidget);
    expect(find.text('${l10n.adminModeInPerson} • Room 101'), findsOneWidget);
  });
}
