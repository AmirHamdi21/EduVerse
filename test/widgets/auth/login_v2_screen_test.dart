import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_event.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/screens/auth/login_v2_screen.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _RecordingAuthBloc extends AuthBloc {
  _RecordingAuthBloc()
    : super(apiService: ApiService(), storageService: StorageService());

  final List<AuthEvent> recordedEvents = <AuthEvent>[];

  @override
  void add(AuthEvent event) {
    recordedEvents.add(event);
  }
}

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
}

class _TestLanguageCubit extends LanguageCubit {
  _TestLanguageCubit(Locale locale) : super() {
    emit(locale);
  }

  @override
  Future<void> changeLanguage(String languageCode) async {
    emit(Locale(languageCode));
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginV2Screen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('forgot-route'))),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('register-route'))),
      ),
    ],
  );
}

Widget _buildHarness({
  required _RecordingAuthBloc authBloc,
  required _TestThemeBloc themeBloc,
  required _TestLanguageCubit languageCubit,
  required GoRouter router,
}) {
  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<LanguageCubit>.value(value: languageCubit),
    ],
    child: BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
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
              routerConfig: router,
            );
          },
        );
      },
    ),
  );
}

Future<_HarnessHandles> _pumpLoginV2(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  bool isDark = false,
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  final handles = _HarnessHandles(
    authBloc: _RecordingAuthBloc(),
    themeBloc: _TestThemeBloc(isDark: isDark),
    languageCubit: _TestLanguageCubit(locale),
    router: _router(),
  );

  await tester.pumpWidget(
    _buildHarness(
      authBloc: handles.authBloc,
      themeBloc: handles.themeBloc,
      languageCubit: handles.languageCubit,
      router: handles.router,
    ),
  );
  await tester.pumpAndSettle();

  addTearDown(() async {
    handles.router.dispose();
    await handles.authBloc.close();
    await handles.themeBloc.close();
    await handles.languageCubit.close();
  });

  return handles;
}

class _HarnessHandles {
  _HarnessHandles({
    required this.authBloc,
    required this.themeBloc,
    required this.languageCubit,
    required this.router,
  });

  final _RecordingAuthBloc authBloc;
  final _TestThemeBloc themeBloc;
  final _TestLanguageCubit languageCubit;
  final GoRouter router;
}

void main() {
  group('LoginV2Screen', () {
    testWidgets('renders the localized iOS login in light and dark themes', (
      tester,
    ) async {
      await _pumpLoginV2(tester);

      expect(find.text('EduVerse'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pumpLoginV2(
        tester,
        locale: const Locale('ar'),
        isDark: true,
        size: const Size(768, 1024),
      );

      expect(find.text('إديفيرس'), findsOneWidget);
      expect(find.text('مرحبًا بعودتك'), findsOneWidget);
      expect(find.text('تذكرني'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows inline invalid email feedback after blur', (
      tester,
    ) async {
      await _pumpLoginV2(tester);

      await tester.enterText(
        find.byKey(const Key('login-v2-email-field')),
        'not-an-email',
      );
      await tester.tap(find.byKey(const Key('login-v2-password-field')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await _pumpLoginV2(tester);

      Finder passwordEditableText() => find.descendant(
        of: find.byKey(const Key('login-v2-password-field')),
        matching: find.byType(EditableText),
      );

      expect(
        tester.widget<EditableText>(passwordEditableText()).obscureText,
        isTrue,
      );

      await tester.tap(find.byKey(const Key('login-v2-password-toggle')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(passwordEditableText()).obscureText,
        isFalse,
      );
    });

    testWidgets('dispatches LoginRequested with rememberMe value', (
      tester,
    ) async {
      final handles = await _pumpLoginV2(tester);

      await tester.enterText(
        find.byKey(const Key('login-v2-email-field')),
        'student@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login-v2-password-field')),
        'secret',
      );
      await tester.tap(find.byKey(const Key('login-v2-remember-toggle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login-v2-submit-button')));
      await tester.pump();

      expect(handles.authBloc.recordedEvents, hasLength(1));
      final event = handles.authBloc.recordedEvents.single;
      expect(event, isA<LoginRequested>());
      final request = (event as LoginRequested).request;
      expect(request.email, 'student@example.com');
      expect(request.password, 'secret');
      expect(request.rememberMe, isFalse);
    });

    testWidgets('quick login menu fills local role credentials', (
      tester,
    ) async {
      await _pumpLoginV2(tester);

      await tester.ensureVisible(
        find.byKey(const Key('login-v2-quick-login-menu')),
      );
      await tester.tap(find.byKey(const Key('login-v2-quick-login-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('instructor.tarek@example.com'));
      await tester.pumpAndSettle();

      final emailField = tester.widget<TextFormField>(
        find.byKey(const Key('login-v2-email-field')),
      );
      final passwordField = tester.widget<TextFormField>(
        find.byKey(const Key('login-v2-password-field')),
      );

      expect(emailField.controller?.text, 'instructor.tarek@example.com');
      expect(passwordField.controller?.text, 'SecureP@ss123');
    });

    testWidgets('navigates to forgot-password and register routes', (
      tester,
    ) async {
      final handles = await _pumpLoginV2(tester);

      await tester.tap(find.byKey(const Key('login-v2-forgot-button')));
      await tester.pumpAndSettle();
      expect(find.text('forgot-route'), findsOneWidget);

      handles.router.go('/login');
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('login-v2-register-button')),
      );
      await tester.tap(find.byKey(const Key('login-v2-register-button')));
      await tester.pumpAndSettle();
      expect(find.text('register-route'), findsOneWidget);
    });
  });
}
