import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_screen.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/services/onboarding_completion_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      final isDark = event.mode == AppThemeMode.dark;
      emit(
        ThemeChanged(
          isDark: isDark,
          themeMode: event.mode,
          fontSize: state.fontSize,
        ),
      );
      return;
    }
    super.add(event);
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

class _HarnessHandles {
  _HarnessHandles({
    required this.router,
    required this.themeBloc,
    required this.languageCubit,
  });

  final GoRouter router;
  final _TestThemeBloc themeBloc;
  final _TestLanguageCubit languageCubit;
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingV6Screen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('login-route'))),
      ),
    ],
  );
}

Widget _buildHarness(_HarnessHandles handles) {
  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeBloc>.value(value: handles.themeBloc),
      BlocProvider<LanguageCubit>.value(value: handles.languageCubit),
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
              routerConfig: handles.router,
            );
          },
        );
      },
    ),
  );
}

Future<_HarnessHandles> _pumpOnboarding(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  bool isDark = true,
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  final handles = _HarnessHandles(
    router: _router(),
    themeBloc: _TestThemeBloc(isDark: isDark),
    languageCubit: _TestLanguageCubit(locale),
  );

  await tester.pumpWidget(_buildHarness(handles));
  await tester.pumpAndSettle();

  addTearDown(() async {
    handles.router.dispose();
    await handles.themeBloc.close();
    await handles.languageCubit.close();
  });

  return handles;
}

Future<void> _tapAndFinishAnimation(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('OnboardingV6Screen', () {
    testWidgets(
      'renders all four English slides and opens login on completion',
      (tester) async {
        await _pumpOnboarding(tester);

        expect(find.text('AUDIO LESSONS'), findsOneWidget);
        expect(find.text('Learn while\nyou walk.'), findsOneWidget);

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-cta')),
        );
        expect(find.text('AI TUTOR'), findsOneWidget);
        expect(find.text('Ask anything,\nanytime.'), findsOneWidget);

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-cta')),
        );
        expect(find.text('INSTANT INSIGHT'), findsOneWidget);
        expect(find.text('See ideas\nclick into place.'), findsOneWidget);

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-cta')),
        );
        expect(find.text('YOUR PREFERENCES'), findsOneWidget);
        expect(find.text('Make it\nfeel like you.'), findsOneWidget);
        expect(find.text('Changes apply instantly'), findsOneWidget);
        expect(find.byKey(const Key('onboarding-v6-skip')), findsNothing);

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-cta')),
        );
        expect(
          await const OnboardingCompletionService().hasCompletedOnboarding(),
          isTrue,
        );
        expect(find.text('login-route'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('skip jumps to preferences and dots jump to story slides', (
      tester,
    ) async {
      await _pumpOnboarding(tester);

      await _tapAndFinishAnimation(
        tester,
        find.byKey(const Key('onboarding-v6-skip')),
      );
      expect(find.text('Make it\nfeel like you.'), findsOneWidget);
      expect(find.text('YOUR PREFERENCES'), findsOneWidget);
      expect(find.byKey(const Key('onboarding-v6-skip')), findsNothing);

      await _tapAndFinishAnimation(
        tester,
        find.byKey(const Key('onboarding-v6-dot-1')),
      );
      expect(find.text('Ask anything,\nanytime.'), findsOneWidget);
      expect(
        find.text('A patient, brilliant tutor that meets you where you are.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'preference controls update the real language and theme blocs',
      (tester) async {
        final handles = await _pumpOnboarding(tester);

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-skip')),
        );

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-lang-ar')),
        );
        expect(handles.languageCubit.state.languageCode, 'ar');
        expect(find.text('ليصبح التطبيق\nمناسباً لك.'), findsOneWidget);
        expect(
          Directionality.of(
            tester.element(find.byKey(const Key('onboarding-v6-root'))),
          ),
          TextDirection.rtl,
        );

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-theme-light')),
        );
        expect(handles.themeBloc.state.themeMode, AppThemeMode.light);
        expect(handles.themeBloc.state.isDark, isFalse);

        await _tapAndFinishAnimation(
          tester,
          find.byKey(const Key('onboarding-v6-theme-dark')),
        );
        expect(handles.themeBloc.state.themeMode, AppThemeMode.dark);
        expect(handles.themeBloc.state.isDark, isTrue);
      },
    );

    testWidgets('renders localized Arabic story content in RTL', (
      tester,
    ) async {
      await _pumpOnboarding(tester, locale: const Locale('ar'));

      expect(find.text('دروس صوتية'), findsOneWidget);
      expect(find.text('تعلّم وأنت\nتمشي.'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('onboarding-v6-root'))),
        ),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
