import 'package:edu_verse/bloc/assignments/assignments_cubit.dart';
import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/grades/grades_cubit.dart';
import 'package:edu_verse/bloc/labs/labs_cubit.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/tasks/tasks_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_router.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StorageService _storageService;
  late ThemeBloc _themeBloc;
  late AuthBloc _authBloc;
  late LanguageCubit _languageCubit;
  late NotificationCubit _notificationCubit;
  late TasksCubit _tasksCubit;
  late LabsCubit _labsCubit;
  late AssignmentsCubit _assignmentsCubit;
  late GradesCubit _gradesCubit;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _themeBloc = ThemeBloc(storageService: _storageService);
    _authBloc = AuthBloc(
      apiService: ApiService(),
      storageService: _storageService,
    );
    _languageCubit = LanguageCubit();
    _notificationCubit = NotificationCubit()..loadNotifications();
    _tasksCubit = TasksCubit()..loadTasks();
    _labsCubit = LabsCubit()..loadLabs();
    _assignmentsCubit = AssignmentsCubit()..loadAssignments();
    _gradesCubit = GradesCubit()..loadGrades();
    // Initialize theme and language from storage
    _initializeTheme();
    _initializeLanguage();
  }

  Future<void> _initializeTheme() async {
    await _themeBloc.initTheme();
  }

  Future<void> _initializeLanguage() async {
    await _languageCubit.initialize();
  }

  @override
  void dispose() {
    _themeBloc.close();
    _authBloc.close();
    _languageCubit.close();
    _notificationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeBloc),
        BlocProvider.value(value: _languageCubit),
        BlocProvider.value(value: _notificationCubit),
        BlocProvider.value(value: _tasksCubit),
        BlocProvider.value(value: _labsCubit),
        BlocProvider.value(value: _assignmentsCubit),
        BlocProvider.value(value: _gradesCubit),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'EduVerse App',
                debugShowCheckedModeBanner: false,
                locale: locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
