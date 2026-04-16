import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/screens/admin/events/admin_campus_events_screen.dart';
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

class _FakeCampusEventsService extends AdminPeriodsService {
  _FakeCampusEventsService({required this.events})
    : super(coreApiClient: CoreApiClient.test());

  final List<CampusEventModel> events;

  @override
  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getCampusEvents({
    int page = 1,
    int limit = 10,
    String? search,
    String? eventType,
    String? status,
    String? fromDate,
    String? toDate,
    int? scopeId,
  }) async {
    return ServiceResult<PaginatedResult<CampusEventModel>>.success(
      PaginatedResult<CampusEventModel>(
        items: events,
        meta: PaginationMeta(
          page: page,
          limit: limit,
          total: events.length,
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
  testWidgets('renders event card with localized capacity and spots chips', (
    WidgetTester tester,
  ) async {
    final service = _FakeCampusEventsService(
      events: <CampusEventModel>[
        CampusEventModel(
          eventId: 77,
          title: 'AI Summit',
          description: 'A multi-track AI campus event',
          eventType: 'WORKSHOP',
          scopeId: null,
          startDateTime: DateTime(2026, 2, 14, 10, 0),
          endDateTime: DateTime(2026, 2, 14, 13, 30),
          location: 'Main Hall',
          building: 'B1',
          room: '201',
          isMandatory: true,
          registrationRequired: true,
          maxAttendees: 100,
          color: '#2B7FFF',
          status: 'published',
          tags: const <String>['ai', 'innovation'],
          registrationCount: 80,
          spotsRemaining: 20,
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHost(AdminCampusEventsScreen(periodsService: service)),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(AdminCampusEventsScreen),
    );
    final AppLocalizations l10n = AppLocalizations.of(context);

    expect(find.text(l10n.adminCampusEvents), findsOneWidget);
    expect(find.text('AI Summit'), findsOneWidget);
    expect(find.text(l10n.adminMandatory), findsOneWidget);
    expect(find.text(l10n.adminRegistrationRequired), findsOneWidget);
    expect(find.text(l10n.adminCapacityUsed(80, 100)), findsOneWidget);
    expect(find.text(l10n.adminSpotsRemaining(20)), findsOneWidget);
    expect(
      find.text(l10n.adminRegistrationCountWithCapacity(80, 100)),
      findsOneWidget,
    );
  });
}
