import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/common/service_error.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/admin/admin_student_management_models.dart';
import 'package:edu_verse/screens/admin/users/admin_user_management_screen.dart';
import 'package:edu_verse/services/api/admin_student_management_service.dart';
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

class _FakeStudentService extends AdminStudentManagementService {
  _FakeStudentService({this.pageModel, this.failureMessage})
    : super(coreApiClient: CoreApiClient.test());

  final AdminStudentsPageModel? pageModel;
  final String? failureMessage;

  @override
  Future<ServiceResult<AdminStudentsPageModel>> getStudents({
    int page = 1,
    int size = 10,
    String? search,
    String? status,
  }) async {
    if (failureMessage != null) {
      return ServiceResult<AdminStudentsPageModel>.failure(
        ServiceError(type: ServiceErrorType.server, message: failureMessage!),
      );
    }

    return ServiceResult<AdminStudentsPageModel>.success(
      pageModel ??
          const AdminStudentsPageModel(
            items: <AdminStudentModel>[],
            page: 1,
            size: 10,
            total: 0,
            totalPages: 1,
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
  testWidgets('renders endpoint-backed student rows', (
    WidgetTester tester,
  ) async {
    final service = _FakeStudentService(
      pageModel: AdminStudentsPageModel(
        items: <AdminStudentModel>[
          AdminStudentModel(
            id: 11,
            studentId: 'STU-11',
            firstName: 'Lina',
            lastName: 'Hassan',
            email: 'lina.hassan@eduverse.test',
            year: 'Senior',
            enrolledCourses: const <String>['CS401 - AI Fundamentals'],
            status: 'active',
          ),
        ],
        page: 1,
        size: 10,
        total: 1,
        totalPages: 1,
      ),
    );

    await tester.pumpWidget(
      _buildHost(AdminUserManagementScreen(studentService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lina Hassan'), findsOneWidget);
    expect(find.textContaining('STU-11'), findsOneWidget);
    expect(find.text('CS401 - AI Fundamentals'), findsOneWidget);
  });

  testWidgets('shows error state when endpoint load fails', (
    WidgetTester tester,
  ) async {
    final service = _FakeStudentService(failureMessage: 'Unable to fetch');

    await tester.pumpWidget(
      _buildHost(AdminUserManagementScreen(studentService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to fetch'), findsOneWidget);
  });
}
