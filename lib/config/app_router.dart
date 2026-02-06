import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/screens/student/ai_quiz_generator_screen.dart';
import 'package:edu_verse/screens/student/assignments_screen.dart';
import 'package:edu_verse/screens/student/chat/chat_screen.dart';
import 'package:edu_verse/screens/student/chat/chat_swipe_settings_screen.dart';
import 'package:edu_verse/screens/student/ai_notes/ai_notes_screen.dart';
import 'package:edu_verse/screens/student/profile/profile_screen.dart';
import 'package:edu_verse/screens/student/profile/edit_profile_screen.dart';
import 'package:edu_verse/screens/student/settings/settings_screen.dart';
import 'package:edu_verse/screens/student/settings/appearance_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/language_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/notifications_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/email_notifications_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/two_factor_auth_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/connected_devices_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/privacy_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/login_history_screen.dart';
import 'package:edu_verse/screens/student/settings/ai_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/storage_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/help_center_screen.dart';
import 'package:edu_verse/screens/student/settings/about_screen.dart';
import 'package:edu_verse/screens/student/settings/email_preferences_screen.dart';
import 'package:edu_verse/screens/student/settings/do_not_disturb_screen.dart';
import 'package:edu_verse/screens/student/settings/terms_of_service_screen.dart';
import 'package:edu_verse/screens/student/settings/privacy_policy_screen.dart';
import 'package:edu_verse/screens/student/settings/blocked_users_screen.dart';
import 'package:edu_verse/screens/student/settings/swipe_actions_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/notification_swipe_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/chat_swipe_settings_screen.dart' as settings_chat;
import 'package:edu_verse/screens/student/settings/file_swipe_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/note_swipe_settings_screen.dart';
import 'package:edu_verse/screens/student/flashcards_screen.dart';
import 'package:edu_verse/screens/student/grades_screen.dart';
import 'package:edu_verse/screens/student/grade_analysis_screen.dart';
import 'package:edu_verse/screens/student/labs_screen.dart';
import 'package:edu_verse/screens/student/my_files/my_files_screen.dart';
import 'package:edu_verse/screens/student/notifications/notifications_screen.dart';
import 'package:edu_verse/screens/student/quiz_questions_screen.dart';
import 'package:edu_verse/screens/student/student_dashboard_screen.dart';
import 'package:edu_verse/screens/student/course_details_screen.dart';
import 'package:edu_verse/screens/student/tasks_screen.dart';
import 'package:edu_verse/screens/student/voice_to_text/voice_to_text_screen.dart';
import 'package:edu_verse/screens/student/attendance/attendance_screen.dart';
import 'package:edu_verse/screens/student/summarizer/summarizer_screen.dart';
import 'package:edu_verse/screens/student/smart_study/smart_study_screen.dart';
import 'package:edu_verse/screens/student/gamification/gamification_screen.dart';
import 'package:edu_verse/screens/student/ai_chat/ai_chat_screen.dart';
import 'package:edu_verse/screens/student/search/overall_search_screen.dart';
import 'package:edu_verse/screens/student/calendar/calendar_screen.dart';
import 'package:edu_verse/widgets/student/ai_quiz/quiz_widgets/quiz_result_screen.dart';
import 'package:edu_verse/widgets/student/courses/courses_barrel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/screens/auth/email_verification_screen.dart';
import 'package:edu_verse/screens/onBoarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../widgets/student/courses/course_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String?;
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: '/flashcards',
        builder: (context, state) => const FlashcardsScreen(),
      ),
      GoRoute(path: '/labs', builder: (context, state) => const LabsScreen()),
      GoRoute(
        path: '/assignments',
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
      GoRoute(
        path: '/ai-quiz-generator',
        builder: (context, state) => const AiQuizGeneratorScreen(),
      ),
      GoRoute(
        path: '/quiz-questions',
        builder: (context, state) {
          final quizSession = state.extra as QuizSession?;
          if (quizSession == null) {
            return const Scaffold(
              body: Center(child: Text('Course not found')),
            );
          }
          return QuizQuestionsScreen(quizSession: quizSession);
        }, // Placeholder
      ),
      GoRoute(
        path: '/quiz-result',
        builder: (context, state) {
          final quizSession = state.extra as QuizSession?;
          if (quizSession == null) {
            return const Scaffold(
              body: Center(child: Text('Course not found')),
            );
          }
          return QuizResultScreen(quizSession: quizSession);
        }, // Placeholder
      ),
      GoRoute(
        path: '/course-details',
        builder: (context, state) {
          final extra = state.extra;
          CourseModel? course;
          int initialTab = 0;
          
          if (extra is Map<String, dynamic>) {
            course = extra['course'] as CourseModel?;
            initialTab = extra['initialTab'] as int? ?? 0;
          } else if (extra is CourseModel) {
            course = extra;
          }
          
          if (course == null) {
            return const Scaffold(
              body: Center(child: Text('Course not found')),
            );
          }
          return CourseDetailsScreen(course: course, initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/grades',
        builder: (context, state) => const GradesScreen(),
      ),
      GoRoute(
        path: '/grade-analysis',
        builder: (context, state) => const GradeAnalysisScreen(),
      ),
      GoRoute(
        path: '/voice-to-text',
        builder: (context, state) => const VoiceToTextScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/my-files',
        builder: (context, state) => const MyFilesScreen(),
      ),
      GoRoute(
        path: '/summarizer',
        builder: (context, state) => const SummarizerScreen(),
      ),
      GoRoute(
        path: '/smart-study',
        builder: (context, state) => const SmartStudyScreen(),
      ),
      GoRoute(
        path: '/gamification',
        builder: (context, state) => const GamificationScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const OverallSearchScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/messages/swipe-settings',
        builder: (context, state) => const ChatSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/ai-notes',
        builder: (context, state) => const AiNotesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/email-notifications',
        builder: (context, state) => const EmailNotificationsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/two-factor-auth',
        builder: (context, state) => const TwoFactorAuthSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/connected-devices',
        builder: (context, state) => const ConnectedDevicesSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/login-history',
        builder: (context, state) => const LoginHistoryScreen(),
      ),
      GoRoute(
        path: '/settings/ai',
        builder: (context, state) => const AISettingsScreen(),
      ),
      GoRoute(
        path: '/settings/storage',
        builder: (context, state) => const StorageSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings/email',
        builder: (context, state) => const EmailPreferencesScreen(),
      ),
      GoRoute(
        path: '/settings/dnd',
        builder: (context, state) => const DoNotDisturbScreen(),
      ),
      GoRoute(
        path: '/settings/terms',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/settings/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/settings/blocked-users',
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions',
        builder: (context, state) => const SwipeActionsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions/notifications',
        builder: (context, state) => const NotificationSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions/chats',
        builder: (context, state) => const settings_chat.ChatSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions/files',
        builder: (context, state) => const FileSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions/notes',
        builder: (context, state) => const NoteSwipeSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
