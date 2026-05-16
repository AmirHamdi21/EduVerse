import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_screen.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/auth_models.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/onboarding_completion_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
  _TestAuthBloc(AuthState initialState)
    : super(apiService: ApiService(), storageService: StorageService()) {
    emit(initialState);
  }
}

class _SplashHarness {
  _SplashHarness({
    required this.router,
    required this.themeBloc,
    required this.authBloc,
  });

  final GoRouter router;
  final _TestThemeBloc themeBloc;
  final _TestAuthBloc authBloc;
}

UserDto _userWithRole(String roleName) {
  return UserDto(
    userId: 7,
    email: 'user@example.com',
    firstName: 'Test',
    lastName: 'User',
    roles: <RoleModel>[RoleModel(roleId: 1, roleName: roleName)],
  );
}

GoRouter _router(Duration minimumDisplayDuration) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) =>
            SplashV8Screen(minimumDisplayDuration: minimumDisplayDuration),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('onboarding-route'))),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('login-route'))),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('admin-dashboard'))),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('student-dashboard'))),
      ),
    ],
  );
}

Widget _buildHarness({
  required _SplashHarness handles,
  required Locale locale,
}) {
  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<AuthBloc>.value(value: handles.authBloc),
      BlocProvider<ThemeBloc>.value(value: handles.themeBloc),
    ],
    child: BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: handles.router,
        );
      },
    ),
  );
}

Future<_SplashHarness> _pumpSplash(
  WidgetTester tester, {
  AuthState authState = const AuthInitial(),
  Locale locale = const Locale('en'),
  bool isDark = true,
  Duration minimumDisplayDuration = Duration.zero,
  Map<String, Object> prefs = const <String, Object>{},
  Size size = const Size(390, 844),
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  final handles = _SplashHarness(
    router: _router(minimumDisplayDuration),
    themeBloc: _TestThemeBloc(isDark: isDark),
    authBloc: _TestAuthBloc(authState),
  );

  await tester.pumpWidget(_buildHarness(handles: handles, locale: locale));

  addTearDown(() async {
    handles.router.dispose();
    await handles.themeBloc.close();
    await handles.authBloc.close();
  });

  return handles;
}

Future<void> _finishRouteFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await tester.pump();
}

void main() {
  group('SplashV8Screen', () {
    testWidgets('bundles the splash background image asset', (tester) async {
      final data = await rootBundle.load('assets/images/splash_screen.jpg');

      expect(data.lengthInBytes, greaterThan(0));
      expect(
        const SplashV8Screen().minimumDisplayDuration,
        const Duration(milliseconds: 6500),
      );
      expect(
        SplashV8Timing.timelineDuration,
        const Duration(milliseconds: 3800),
      );
    });

    testWidgets('renders dark EduVerse copy', (tester) async {
      await _pumpSplash(tester);
      await tester.pump(SplashV8Timing.timelineDuration);

      expect(find.text('EDUVERSE · MMXXVI'), findsOneWidget);
      expect(find.text('SHAPING YOUR PATH'), findsOneWidget);
      expect(find.text('EduVerse'), findsOneWidget);
      expect(find.text('A future you teach yourself.'), findsOneWidget);
      expect(find.byKey(const Key('splash-v8-loader')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders adapted light mode styling', (tester) async {
      await _pumpSplash(tester, isDark: false);
      await tester.pump(SplashV8Timing.timelineDuration);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF2F2F7));
      expect(find.text('EduVerse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Arabic copy in RTL', (tester) async {
      await _pumpSplash(tester, locale: const Locale('ar'));
      await tester.pump(SplashV8Timing.timelineDuration);

      expect(find.text('إديفيرس · ٢٠٢٦'), findsOneWidget);
      expect(find.text('إديفيرس'), findsOneWidget);
      expect(find.text('مستقبل تتعلمه بطريقتك.'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('splash-v8-root'))),
        ),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('fresh unauthenticated launch opens onboarding', (
      tester,
    ) async {
      await _pumpSplash(
        tester,
        authState: const AuthUnauthenticated(),
        minimumDisplayDuration: Duration.zero,
      );
      await _finishRouteFrame(tester);

      expect(find.text('onboarding-route'), findsOneWidget);
    });

    testWidgets('completed onboarding unauthenticated launch opens login', (
      tester,
    ) async {
      await _pumpSplash(
        tester,
        authState: const AuthUnauthenticated(),
        minimumDisplayDuration: Duration.zero,
        prefs: const <String, Object>{
          OnboardingCompletionService.onboardingV6CompletedKey: true,
        },
      );
      await _finishRouteFrame(tester);

      expect(find.text('login-route'), findsOneWidget);
    });

    testWidgets('authenticated launch opens the matching role dashboard', (
      tester,
    ) async {
      await _pumpSplash(
        tester,
        authState: AuthAuthenticated(_userWithRole('admin')),
        minimumDisplayDuration: Duration.zero,
      );
      await _finishRouteFrame(tester);

      expect(find.text('admin-dashboard'), findsOneWidget);
    });

    testWidgets('common phone sizes avoid visible overflow', (tester) async {
      for (final size in <Size>[
        const Size(320, 568),
        const Size(390, 844),
        const Size(430, 932),
      ]) {
        await _pumpSplash(tester, size: size);
        await tester.pump(SplashV8Timing.timelineDuration);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
