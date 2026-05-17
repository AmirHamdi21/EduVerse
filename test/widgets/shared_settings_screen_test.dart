import 'package:dio/dio.dart';
import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_state.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/profile/profile_cubit.dart';
import 'package:edu_verse/bloc/profile/profile_models.dart';
import 'package:edu_verse/bloc/profile/profile_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/features/shared_settings/shared_settings_role.dart';
import 'package:edu_verse/features/shared_settings/shared_settings_screen.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/user_profile_service.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestThemeBloc extends ThemeBloc {
  _TestThemeBloc({required bool isDark})
    : super(storageService: StorageService()) {
    emit(
      ThemeChanged(
        isDark: isDark,
        themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light,
        fontSize: FontSizeOption.medium,
      ),
    );
  }

  @override
  void add(ThemeEvent event) {
    if (event is SetThemeModeEvent) {
      emit(
        ThemeChanged(
          isDark: event.mode == AppThemeMode.dark,
          themeMode: event.mode,
          fontSize: state.fontSize,
        ),
      );
      return;
    }
    super.add(event);
  }
}

class _TestAuthBloc extends AuthBloc {
  _TestAuthBloc(AuthState state)
    : super(apiService: ApiService(), storageService: StorageService()) {
    emit(state);
  }
}

class _TestProfileCubit extends ProfileCubit {
  _TestProfileCubit(ProfileState state)
    : super(
        userProfileService: UserProfileService(
          coreApiClient: CoreApiClient.test(dioOverride: Dio()),
        ),
      ) {
    emit(state);
  }
}

UserDto _user(String roleName) {
  return UserDto(
    userId: 10,
    email: 'mira@example.com',
    firstName: 'Mira',
    lastName: 'Hassan',
    roles: <RoleModel>[RoleModel(roleId: 1, roleName: roleName)],
  );
}

UserProfile _profile(String roleName) {
  return UserProfile(
    userId: 10,
    email: 'mira@example.com',
    firstName: 'Mira',
    lastName: 'Hassan',
    roles: <RoleModel>[RoleModel(roleId: 1, roleName: roleName)],
  );
}

Widget _harness({required SharedSettingsRole role, bool isDark = false}) {
  final roleName = role == SharedSettingsRole.ta
      ? 'ta'
      : role == SharedSettingsRole.instructor
      ? 'instructor'
      : 'student';

  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<AuthBloc>.value(
        value: _TestAuthBloc(AuthAuthenticated(_user(roleName))),
      ),
      BlocProvider<ProfileCubit>.value(
        value: _TestProfileCubit(
          ProfileLoaded(
            profile: _profile(roleName),
            settings: const AppSettings(),
          ),
        ),
      ),
      BlocProvider<ThemeBloc>.value(value: _TestThemeBloc(isDark: isDark)),
      BlocProvider<LanguageCubit>.value(value: LanguageCubit()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: SharedSettingsScreen(role: role),
    ),
  );
}

Future<void> _expectVisibleText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 500);
    await tester.pumpAndSettle();
  }
  expect(finder, findsOneWidget);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('student settings preserve the shared section order', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(role: SharedSettingsRole.student));
    await tester.pumpAndSettle();

    expect(find.text('Mira Hassan'), findsOneWidget);
    await _expectVisibleText(tester, 'Account');
    await _expectVisibleText(tester, 'Notifications');
    await _expectVisibleText(tester, 'Appearance');
    await _expectVisibleText(tester, 'Privacy & Security');
    await _expectVisibleText(tester, 'Learning');
    await _expectVisibleText(tester, 'Storage & Data');
    await _expectVisibleText(tester, 'Support');
    await _expectVisibleText(tester, 'About');
    await _expectVisibleText(tester, 'Danger Zone');
  });

  testWidgets('instructor settings use real profile data and teaching tools', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(role: SharedSettingsRole.instructor));
    await tester.pumpAndSettle();

    expect(find.text('Mira Hassan'), findsOneWidget);
    expect(find.text('Dr. Sarah Mitchell'), findsNothing);
    await _expectVisibleText(tester, 'Teaching Settings');
    await _expectVisibleText(tester, 'Grading Preferences');
    await _expectVisibleText(tester, 'Assignment Defaults');
    await _expectVisibleText(tester, 'Attendance Settings');
  });

  testWidgets('TA settings use real profile data and TA tools', (tester) async {
    await tester.pumpWidget(
      _harness(role: SharedSettingsRole.ta, isDark: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mira Hassan'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsNothing);
    await _expectVisibleText(tester, 'TA Tools');
    await _expectVisibleText(tester, 'AI Grading');
    await _expectVisibleText(tester, 'Analytics');
    await _expectVisibleText(tester, 'Office Hours');
  });

  testWidgets('delete account opens honest support dialog', (tester) async {
    await tester.pumpWidget(_harness(role: SharedSettingsRole.student));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Delete Account'), 500);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('Account deletion needs support'), findsOneWidget);
    expect(find.textContaining('EduVerse support'), findsOneWidget);
  });

  testWidgets('change password sheet dismisses from outside after validation', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(role: SharedSettingsRole.student));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsOneWidget);

    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    expect(find.text('Update Password'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
