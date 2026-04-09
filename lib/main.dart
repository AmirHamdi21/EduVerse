import 'dart:io';
import 'dart:async';

import 'package:edu_verse/bloc/admin_notifications/admin_notification_cubit.dart';
import 'package:edu_verse/bloc/assignments/assignments_cubit.dart';
import 'package:edu_verse/bloc/attendance/attendance_cubit.dart';
import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_event.dart';
import 'package:edu_verse/bloc/chat/chat_bloc.dart';
import 'package:edu_verse/bloc/discussions/discussion_bloc.dart';
import 'package:edu_verse/bloc/ai_notes/ai_notes_cubit.dart';
import 'package:edu_verse/bloc/profile/profile_cubit.dart';
import 'package:edu_verse/bloc/grades/grades_cubit.dart';
import 'package:edu_verse/bloc/labs/labs_cubit.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/smart_study/smart_study_cubit.dart';
import 'package:edu_verse/bloc/summarizer/summarizer_cubit.dart';
import 'package:edu_verse/bloc/tasks/tasks_cubit.dart';
import 'package:edu_verse/bloc/search/search_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_router.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/session_expiry_notifier.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hide status bar & navigation bar
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
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
  late AttendanceCubit _attendanceCubit;
  late SummarizerCubit _summarizerCubit;
  late SmartStudyCubit _smartStudyCubit;
  late ChatBloc _chatBloc;
  late DiscussionBloc _discussionBloc;
  late AINoteCubit _aiNoteCubit;
  late ProfileCubit _profileCubit;
  late SearchCubit _searchCubit;
  late AdminNotificationCubit _adminNotificationCubit;
  late CoursesBloc _coursesBloc;
  StreamSubscription<String>? _sessionExpirySubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
    _attendanceCubit = AttendanceCubit()..loadAttendance();
    _summarizerCubit = SummarizerCubit();
    _smartStudyCubit = SmartStudyCubit();
    _chatBloc = ChatBloc();
    _discussionBloc = DiscussionBloc();
    _aiNoteCubit = AINoteCubit();
    _profileCubit = ProfileCubit()..loadProfile();
    _searchCubit = SearchCubit();
    _adminNotificationCubit = AdminNotificationCubit();

    _sessionExpirySubscription = SessionExpiryNotifier.stream.listen((message) {
      if (!mounted) {
        return;
      }

      _authBloc.add(const LogoutRequested());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        AppRouter.router.go('/login');
        _scaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      });
    });

    // ── Course API layer (Phase 1) ─────────────────────────
    final coreApiClient = CoreApiClient(storageService: _storageService);
    _coursesBloc = CoursesBloc(
      courseService: CourseService(coreApiClient: coreApiClient),
      enrollmentService: EnrollmentService(coreApiClient: coreApiClient),
      materialService: MaterialService(coreApiClient: coreApiClient),
      communicationService: CommunicationService(coreApiClient: coreApiClient),
    );

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
    _tasksCubit.close();
    _labsCubit.close();
    _assignmentsCubit.close();
    _gradesCubit.close();
    _attendanceCubit.close();
    _summarizerCubit.close();
    _smartStudyCubit.close();
    _chatBloc.close();
    _discussionBloc.close();
    _aiNoteCubit.close();
    _profileCubit.close();
    _searchCubit.close();
    _adminNotificationCubit.close();
    _coursesBloc.close();
    _sessionExpirySubscription?.cancel();
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
        BlocProvider.value(value: _attendanceCubit),
        BlocProvider.value(value: _summarizerCubit),
        BlocProvider.value(value: _smartStudyCubit),
        BlocProvider.value(value: _chatBloc),
        BlocProvider.value(value: _discussionBloc),
        BlocProvider.value(value: _aiNoteCubit),
        BlocProvider.value(value: _profileCubit),
        BlocProvider.value(value: _searchCubit),
        BlocProvider.value(value: _adminNotificationCubit),
        BlocProvider.value(value: _coursesBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'EduVerse App',
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: _scaffoldMessengerKey,
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
