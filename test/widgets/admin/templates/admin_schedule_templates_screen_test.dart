import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_periods_models.dart';
import 'package:edu_verse/screens/admin/templates/admin_schedule_templates_screen.dart';
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

class _FakeScheduleTemplatesService extends AdminPeriodsService {
  _FakeScheduleTemplatesService({required this.templates})
    : super(coreApiClient: CoreApiClient.test());

  final List<ScheduleTemplateModel> templates;

  @override
  Future<ServiceResult<PaginatedResult<ScheduleTemplateModel>>>
  getScheduleTemplates({
    int page = 1,
    int limit = 10,
    String? search,
    String? scheduleType,
    int? departmentId,
    bool? isActive,
  }) async {
    return ServiceResult<PaginatedResult<ScheduleTemplateModel>>.success(
      PaginatedResult<ScheduleTemplateModel>(
        items: templates,
        meta: PaginationMeta(
          page: page,
          limit: limit,
          total: templates.length,
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
  testWidgets('renders localized slots preview and creator summary', (
    WidgetTester tester,
  ) async {
    final service = _FakeScheduleTemplatesService(
      templates: <ScheduleTemplateModel>[
        ScheduleTemplateModel(
          templateId: 11,
          name: 'CS First Year Morning',
          description: 'Balanced morning schedule template',
          departmentName: 'Computer Science',
          scheduleType: 'LECTURE',
          isActive: true,
          creatorName: 'Admin User',
          slotCount: 3,
          slots: const <ScheduleTemplateSlotModel>[
            ScheduleTemplateSlotModel(
              dayOfWeek: 'MONDAY',
              startTime: '09:00',
              endTime: '10:00',
              slotType: 'LECTURE',
              building: 'B1',
              room: '201',
            ),
            ScheduleTemplateSlotModel(
              dayOfWeek: 'WEDNESDAY',
              startTime: '11:00',
              endTime: '12:00',
              slotType: 'LECTURE',
              building: 'B1',
              room: '202',
            ),
            ScheduleTemplateSlotModel(
              dayOfWeek: 'THURSDAY',
              startTime: '13:00',
              endTime: '14:00',
              slotType: 'LECTURE',
              building: 'B2',
              room: '101',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHost(AdminScheduleTemplatesScreen(periodsService: service)),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byType(AdminScheduleTemplatesScreen),
    );
    final AppLocalizations l10n = AppLocalizations.of(context);

    expect(find.text(l10n.adminScheduleTemplates), findsOneWidget);
    expect(find.text('CS First Year Morning'), findsOneWidget);
    expect(
      find.text(l10n.adminTemplateSlotsCreator(3, 'Admin User')),
      findsOneWidget,
    );
    expect(find.text(l10n.adminTemplateSlotsPreview), findsOneWidget);
    expect(
      find.text(
        l10n.adminTemplateSlotLine(
          l10n.adminDayMonday,
          '09:00',
          '10:00',
          'B1 • 201',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.adminMoreSlots(1)), findsOneWidget);
  });
}
