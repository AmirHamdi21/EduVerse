import 'dart:io';
import 'dart:async';

import 'package:edu_verse/bloc/admin_notifications/admin_notification_cubit.dart';
import 'package:edu_verse/bloc/assignments/assignment_bloc.dart';
import 'package:edu_verse/bloc/assignments/assignment_event.dart';
import 'package:edu_verse/bloc/attendance/attendance_cubit.dart';
import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_event.dart';
import 'package:edu_verse/bloc/auth/auth_state.dart';
import 'package:edu_verse/bloc/chat/chat_bloc.dart';
import 'package:edu_verse/bloc/chat/chat_event.dart';
import 'package:edu_verse/bloc/discussions/discussion_bloc.dart';
import 'package:edu_verse/bloc/ai_notes/ai_notes_cubit.dart';
import 'package:edu_verse/bloc/profile/profile_cubit.dart';
import 'package:edu_verse/bloc/grades/grades_cubit.dart';
import 'package:edu_verse/bloc/labs/labs_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_cubit.dart';
import 'package:edu_verse/services/api/quiz_api_service.dart';
import 'package:edu_verse/bloc/materials/materials_bloc.dart';
import 'package:edu_verse/bloc/course_structure/course_structure_bloc.dart';
import 'package:edu_verse/bloc/admin_course_management/course_list_bloc.dart'
    as admin_course_list;
import 'package:edu_verse/bloc/admin_course_management/course_wizard_bloc.dart';
import 'package:edu_verse/bloc/admin_course_management/admin_enrollment_bloc.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/notifications/notification_cubit.dart';
import 'package:edu_verse/bloc/smart_study/smart_study_cubit.dart';
import 'package:edu_verse/bloc/summarizer/summarizer_cubit.dart';
import 'package:edu_verse/bloc/tasks/tasks_cubit.dart';
import 'package:edu_verse/bloc/search/search_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/ta/ta_courses_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_labs_cubit.dart';
import 'package:edu_verse/config/app_router.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/session_expiry_notifier.dart';
import 'package:edu_verse/services/api/course_service.dart';
import 'package:edu_verse/services/api/assignment_service.dart';
import 'package:edu_verse/services/api/attendance_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/lab_service.dart';
import 'package:edu_verse/services/api/material_service.dart';
import 'package:edu_verse/services/api/schedule_service.dart';
import 'package:edu_verse/services/api/section_service.dart';
import 'package:edu_verse/services/api/communication_service.dart';
import 'package:edu_verse/services/api/public_profile_service.dart';
import 'package:edu_verse/services/api/user_profile_service.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/grades_service.dart';
import 'package:edu_verse/services/api/student_stats_service.dart';
import 'package:edu_verse/services/api/notification_api_service.dart';
import 'package:edu_verse/services/notifications/device_notification_preferences_service.dart';
import 'package:edu_verse/services/notifications/notification_socket_service.dart';
import 'package:edu_verse/bloc/courses/courses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDownloader.initialize(debug: false, ignoreSsl: false);
  }

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late StorageService _storageService;
  late ThemeBloc _themeBloc;
  late AuthBloc _authBloc;
  late LanguageCubit _languageCubit;
  late NotificationCubit _notificationCubit;
  late TasksCubit _tasksCubit;
  late LabsCubit _labsCubit;
  late AssignmentBloc _assignmentBloc;
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
  late InstructorCoursesBloc _instructorCoursesBloc;
  late MaterialsBloc _materialsBloc;
  late CourseStructureBloc _courseStructureBloc;
  late TACoursesCubit _taCoursesCubit;
  late TALabsCubit _taLabsCubit;
  late admin_course_list.CourseListBloc _adminCourseListBloc;
  late CourseWizardBloc _courseWizardBloc;
  late AdminEnrollmentBloc _adminEnrollmentBloc;
  late QuizManagementCubit _quizManagementCubit;
  late StudentQuizCubit _studentQuizCubit;
  late SectionService _sectionService;
  late ScheduleService _scheduleService;
  late CourseService _courseService;
  late AssignmentService _assignmentService;
  late AttendanceService _attendanceService;
  late EnrollmentService _enrollmentService;
  late LabService _labService;
  late MaterialService _materialService;
  late CommunicationService _communicationService;
  late PublicProfileService _publicProfileService;
  late UserProfileService _userProfileService;
  late OfficeHoursService _officeHoursService;
  late StudentStatsService _studentStatsService;
  late NotificationApiService _notificationApiService;
  late NotificationSocketService _notificationSocketService;
  late DeviceNotificationPreferencesService
  _deviceNotificationPreferencesService;
  StreamSubscription<String>? _sessionExpirySubscription;
  StreamSubscription<dynamic>? _incomingNotificationSubscription;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _storageService = StorageService();
    _themeBloc = ThemeBloc(storageService: _storageService);
    _authBloc = AuthBloc(
      apiService: ApiService(),
      storageService: _storageService,
    );
    _languageCubit = LanguageCubit();

    final coreApiClient = CoreApiClient(storageService: _storageService);
    _courseService = CourseService(coreApiClient: coreApiClient);
    _assignmentService = AssignmentService(coreApiClient: coreApiClient);
    _attendanceService = AttendanceService(coreApiClient: coreApiClient);
    _enrollmentService = EnrollmentService(coreApiClient: coreApiClient);
    _labService = LabService(coreApiClient: coreApiClient);
    _materialService = MaterialService(coreApiClient: coreApiClient);
    _sectionService = SectionService(coreApiClient: coreApiClient);
    _scheduleService = ScheduleService(coreApiClient: coreApiClient);
    _communicationService = CommunicationService(coreApiClient: coreApiClient);
    _publicProfileService = PublicProfileService(coreApiClient: coreApiClient);
    _userProfileService = UserProfileService(coreApiClient: coreApiClient);
    _officeHoursService = OfficeHoursService(coreApiClient: coreApiClient);
    _studentStatsService = StudentStatsService(coreApiClient: coreApiClient);
    _notificationApiService = NotificationApiService(
      coreApiClient: coreApiClient,
    );
    _notificationSocketService = NotificationSocketService(
      storageService: _storageService,
    );
    _deviceNotificationPreferencesService =
        DeviceNotificationPreferencesService();

    _notificationCubit = NotificationCubit(
      notificationApiService: _notificationApiService,
      notificationSocketService: _notificationSocketService,
    )..loadNotifications();
    _tasksCubit = TasksCubit()..loadTasks();
    _gradesCubit = GradesCubit(
      gradesService: GradesService(coreApiClient: coreApiClient),
      studentStatsService: _studentStatsService,
      storageService: _storageService,
    );
    _attendanceCubit = AttendanceCubit(attendanceService: _attendanceService)
      ..loadAttendance();
    _summarizerCubit = SummarizerCubit();
    _smartStudyCubit = SmartStudyCubit();
    _chatBloc = ChatBloc();
    _discussionBloc = DiscussionBloc();
    _aiNoteCubit = AINoteCubit();
    _profileCubit = ProfileCubit(userProfileService: _userProfileService)
      ..loadProfile();
    _searchCubit = SearchCubit();
    _adminNotificationCubit = AdminNotificationCubit(
      notificationApiService: _notificationApiService,
    );

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

    _incomingNotificationSubscription = _notificationCubit.incomingNotifications
        .listen((notification) async {
          if (!mounted) return;
          final devicePreferences = await _deviceNotificationPreferencesService
              .load();
          if (!devicePreferences.foregroundAlertsEnabled) {
            return;
          }

          if (devicePreferences.vibrationEnabled) {
            HapticFeedback.mediumImpact();
          }
          if (devicePreferences.soundEnabled) {
            SystemSound.play(SystemSoundType.click);
          }

          final content =
              devicePreferences.showPreview &&
                  notification.message.trim().isNotEmpty
              ? '${notification.title}: ${notification.message}'
              : notification.title;

          _scaffoldMessengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(content),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
        });

    // ── Course API layer (Phase 1+) ────────────────────────

    _labsCubit = LabsCubit(
      enrollmentService: _enrollmentService,
      labService: _labService,
    )..loadEnrolledCourses();

    _assignmentBloc = AssignmentBloc(
      assignmentService: _assignmentService,
      enrollmentService: _enrollmentService,
    )..add(const FetchAssignments(courseId: null));

    _coursesBloc = CoursesBloc(
      courseService: _courseService,
      enrollmentService: _enrollmentService,
      materialService: _materialService,
      communicationService: _communicationService,
      assignmentService: _assignmentService,
      labService: _labService,
      publicProfileService: _publicProfileService,
      officeHoursService: _officeHoursService,
      studentStatsService: _studentStatsService,
    );

    _instructorCoursesBloc = InstructorCoursesBloc(
      enrollmentService: _enrollmentService,
      assignmentService: _assignmentService,
      labService: _labService,
      materialService: _materialService,
    );
    _materialsBloc = MaterialsBloc(materialService: _materialService);
    _courseStructureBloc = CourseStructureBloc(courseService: _courseService);

    _taCoursesCubit = TACoursesCubit(
      enrollmentService: _enrollmentService,
      sectionService: _sectionService,
      labService: _labService,
      courseService: _courseService,
      materialService: _materialService,
      assignmentService: _assignmentService,
    );
    _taLabsCubit = TALabsCubit(labService: _labService);

    _adminCourseListBloc = admin_course_list.CourseListBloc(
      courseService: _courseService,
      sectionService: _sectionService,
      scheduleService: _scheduleService,
      enrollmentService: _enrollmentService,
    );

    _courseWizardBloc = CourseWizardBloc(
      courseService: _courseService,
      sectionService: _sectionService,
      scheduleService: _scheduleService,
      enrollmentService: _enrollmentService,
    );

    _adminEnrollmentBloc = AdminEnrollmentBloc(
      enrollmentService: _enrollmentService,
    );

    final quizApiService = QuizApiService(coreApiClient: coreApiClient);
    _quizManagementCubit = QuizManagementCubit(quizApiService: quizApiService);
    _studentQuizCubit = StudentQuizCubit(quizApiService: quizApiService);

    // Initialize theme and language from storage
    _initializeTheme();
    _initializeLanguage();
    _restoreSystemUiOverlays();
  }

  Future<void> _restoreSystemUiOverlays() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _restoreSystemUiOverlays();
    }
  }

  Future<void> _initializeTheme() async {
    await _themeBloc.initTheme();
  }

  Future<void> _initializeLanguage() async {
    await _languageCubit.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeBloc.close();
    _authBloc.close();
    _languageCubit.close();
    _notificationCubit.close();
    _tasksCubit.close();
    _labsCubit.close();
    _assignmentBloc.close();
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
    _instructorCoursesBloc.close();
    _materialsBloc.close();
    _courseStructureBloc.close();
    _taCoursesCubit.close();
    _taLabsCubit.close();
    _adminCourseListBloc.close();
    _courseWizardBloc.close();
    _adminEnrollmentBloc.close();
    _quizManagementCubit.close();
    _studentQuizCubit.close();
    _sessionExpirySubscription?.cancel();
    _incomingNotificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AttendanceService>.value(value: _attendanceService),
        RepositoryProvider<EnrollmentService>.value(value: _enrollmentService),
        RepositoryProvider<NotificationApiService>.value(
          value: _notificationApiService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _themeBloc),
          BlocProvider.value(value: _languageCubit),
          BlocProvider.value(value: _notificationCubit),
          BlocProvider.value(value: _tasksCubit),
          BlocProvider.value(value: _labsCubit),
          BlocProvider.value(value: _assignmentBloc),
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
          BlocProvider.value(value: _instructorCoursesBloc),
          BlocProvider.value(value: _materialsBloc),
          BlocProvider.value(value: _courseStructureBloc),
          BlocProvider.value(value: _taCoursesCubit),
          BlocProvider.value(value: _taLabsCubit),
          BlocProvider.value(value: _adminCourseListBloc),
          BlocProvider.value(value: _courseWizardBloc),
          BlocProvider.value(value: _adminEnrollmentBloc),
          BlocProvider.value(value: _quizManagementCubit),
          BlocProvider.value(value: _studentQuizCubit),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is AuthAuthenticated &&
                  current is AuthAuthenticated &&
                  previous.user.userId != current.user.userId),
          listener: (context, authState) {
            if (authState is AuthAuthenticated) {
              _chatBloc.add(ChatSessionStarted(authState.user.userId));
              return;
            }

            if (authState is AuthUnauthenticated) {
              _chatBloc.add(const ChatSessionEnded());
            }
          },
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
                    themeMode: themeState.isDark
                        ? ThemeMode.dark
                        : ThemeMode.light,
                    routerConfig: AppRouter.router,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
