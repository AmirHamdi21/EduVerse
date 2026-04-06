import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class _WelcomeService {
  String messageForLocale(Locale locale);
}

class _MockWelcomeService implements _WelcomeService {
  @override
  String messageForLocale(Locale locale) {
    return locale.languageCode == 'ar'
        ? 'مرحبا من الاختبار'
        : 'Hello from test';
  }
}

class _MockThemeCubit extends Cubit<ThemeState> {
  _MockThemeCubit({required bool isDark})
    : super(
        ThemeChanged(
          isDark: isDark,
          themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light,
          fontSize: FontSizeOption.medium,
        ),
      );

  void setDark(bool isDark) {
    emit(
      ThemeChanged(
        isDark: isDark,
        themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light,
        fontSize: FontSizeOption.medium,
      ),
    );
  }
}

class _MockLanguageCubit extends Cubit<Locale> {
  _MockLanguageCubit(Locale initialLocale) : super(initialLocale);

  void setLocale(Locale locale) => emit(locale);
}

class _TestSafeRoot extends StatelessWidget {
  final _MockThemeCubit themeCubit;
  final _MockLanguageCubit languageCubit;
  final _WelcomeService welcomeService;

  const _TestSafeRoot({
    required this.themeCubit,
    required this.languageCubit,
    required this.welcomeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<_MockThemeCubit>.value(value: themeCubit),
        BlocProvider<_MockLanguageCubit>.value(value: languageCubit),
      ],
      child: BlocBuilder<_MockThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<_MockLanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
                home: _TestSafeHome(welcomeService: welcomeService),
              );
            },
          );
        },
      ),
    );
  }
}

class _TestSafeHome extends StatelessWidget {
  final _WelcomeService welcomeService;

  const _TestSafeHome({required this.welcomeService});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<_MockThemeCubit>().state;
    final locale = context.watch<_MockLanguageCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Safe Root')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              welcomeService.messageForLocale(locale),
              key: const Key('welcome-text'),
            ),
            const SizedBox(height: 8),
            Text(
              'locale:${locale.languageCode}',
              key: const Key('locale-text'),
            ),
            const SizedBox(height: 8),
            Text(
              'theme:${themeState.isDark ? 'dark' : 'light'}',
              key: const Key('theme-text'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('toggle-theme-button'),
              onPressed: () {
                context.read<_MockThemeCubit>().setDark(!themeState.isDark);
              },
              child: const Text('Toggle Theme'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('toggle-locale-button'),
              onPressed: () {
                final next = locale.languageCode == 'en'
                    ? const Locale('ar')
                    : const Locale('en');
                context.read<_MockLanguageCubit>().setLocale(next);
              },
              child: const Text('Toggle Locale'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Test-safe root smoke tests', () {
    testWidgets('renders visible app shell with mocked blocs/services', (
      WidgetTester tester,
    ) async {
      final themeCubit = _MockThemeCubit(isDark: false);
      final languageCubit = _MockLanguageCubit(const Locale('en'));

      await tester.pumpWidget(
        _TestSafeRoot(
          themeCubit: themeCubit,
          languageCubit: languageCubit,
          welcomeService: _MockWelcomeService(),
        ),
      );

      expect(find.text('Test Safe Root'), findsOneWidget);
      expect(find.byKey(const Key('welcome-text')), findsOneWidget);
      expect(find.text('Hello from test'), findsOneWidget);
      expect(find.text('locale:en'), findsOneWidget);
      expect(find.text('theme:light'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await themeCubit.close();
      await languageCubit.close();
    });

    testWidgets('updates visible UI when mocked blocs change state', (
      WidgetTester tester,
    ) async {
      final themeCubit = _MockThemeCubit(isDark: false);
      final languageCubit = _MockLanguageCubit(const Locale('en'));

      await tester.pumpWidget(
        _TestSafeRoot(
          themeCubit: themeCubit,
          languageCubit: languageCubit,
          welcomeService: _MockWelcomeService(),
        ),
      );

      await tester.tap(find.byKey(const Key('toggle-theme-button')));
      await tester.pumpAndSettle();
      expect(find.text('theme:dark'), findsOneWidget);

      await tester.tap(find.byKey(const Key('toggle-locale-button')));
      await tester.pumpAndSettle();
      expect(find.text('locale:ar'), findsOneWidget);
      expect(find.text('مرحبا من الاختبار'), findsOneWidget);

      await themeCubit.close();
      await languageCubit.close();
    });
  });
}
