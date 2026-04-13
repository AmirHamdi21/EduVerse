import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/screens/student/ai_quiz_generator_screen.dart';
import 'package:edu_verse/screens/student/assignments_screen.dart';
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
import 'package:edu_verse/screens/student/settings/chat_swipe_settings_screen.dart'
    as settings_chat;
import 'package:edu_verse/screens/student/settings/file_swipe_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/note_swipe_settings_screen.dart';
import 'package:edu_verse/screens/student/settings/share_app/share_app_screen.dart';
import 'package:edu_verse/screens/student/settings/share_app/qr_code_share_screen.dart';
import 'package:edu_verse/screens/student/settings/share_app/apk_share_screen.dart';
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
import 'package:edu_verse/features/courses/screens/course_list_screen.dart';
import 'package:edu_verse/features/courses/screens/course_detail_screen.dart';
// Instructor screens
import 'package:edu_verse/screens/instructor/dashboard/instructor_dashboard_screen.dart';
import 'package:edu_verse/screens/instructor/courses/instructor_courses_screen.dart';
import 'package:edu_verse/screens/instructor/grading_center/grading_center_screen.dart';
import 'package:edu_verse/screens/instructor/assignments/instructor_assignments_screen.dart';
import 'package:edu_verse/screens/instructor/assignments/assignment_submissions_screen.dart';
import 'package:edu_verse/screens/instructor/assignments/submission_grading_screen.dart';
import 'package:edu_verse/screens/instructor/labs/instructor_labs_screen.dart';
import 'package:edu_verse/screens/instructor/labs/lab_detail_screen.dart';
import 'package:edu_verse/screens/instructor/course_management/course_management_screen.dart';
import 'package:edu_verse/screens/instructor/video/instructor_video_player_screen.dart';
import 'package:edu_verse/screens/instructor/announcements/announcement_manager_screen.dart';
import 'package:edu_verse/screens/instructor/attendance/attendance_manager_screen.dart';
import 'package:edu_verse/screens/instructor/create_assignment_screen.dart';
import 'package:edu_verse/screens/instructor/reports/reports_analytics_screen.dart';
import 'package:edu_verse/screens/instructor/ai_teaching/ai_teaching_screen.dart';
import 'package:edu_verse/screens/instructor/upload_materials/upload_materials_screen.dart';
import 'package:edu_verse/screens/instructor/calendar/instructor_calendar_screen.dart';
import 'package:edu_verse/screens/instructor/search/instructor_search_screen.dart';
import 'package:edu_verse/screens/instructor/notifications/instructor_notifications_screen.dart';
import 'package:edu_verse/screens/instructor/profile/instructor_profile_screen.dart';
import 'package:edu_verse/screens/instructor/profile/instructor_edit_profile_screen.dart';
import 'package:edu_verse/screens/instructor/settings/instructor_settings_screen.dart';
import 'package:edu_verse/models/assignments/assignment_model.dart'
    as assignment_models;
import 'package:edu_verse/models/instructor/instructor_course_model.dart';
// TA, Admin, IT Admin screens (placeholders for development)
import 'package:edu_verse/screens/ta/ta_dashboard_screen.dart';
import 'package:edu_verse/screens/ta/courses/ta_courses_list_screen.dart';
import 'package:edu_verse/screens/ta/courses/ta_course_detail_screen.dart';
import 'package:edu_verse/screens/ta/labs/ta_labs_list_screen.dart';
import 'package:edu_verse/screens/ta/labs/ta_lab_detail_screen.dart';
import 'package:edu_verse/screens/ta/student_performance/ta_student_performance_screen.dart';
import 'package:edu_verse/screens/ta/notifications/ta_notifications_screen.dart';
import 'package:edu_verse/screens/ta/upload_materials/ta_upload_materials_screen.dart';
import 'package:edu_verse/screens/ta/ai_grading/ta_ai_grading_screen.dart';
import 'package:edu_verse/screens/ta/student_inbox/ta_student_inbox_screen.dart';
import 'package:edu_verse/screens/ta/lab_resources/ta_lab_resources_screen.dart';
import 'package:edu_verse/screens/ta/analytics/ta_analytics_screen.dart';
import 'package:edu_verse/screens/ta/settings/ta_settings_screen.dart';
import 'package:edu_verse/screens/ta/profile/ta_profile_screen.dart';
import 'package:edu_verse/screens/ta/profile/ta_edit_profile_screen.dart';
import 'package:edu_verse/screens/ta/office_hours/ta_office_hours_screen.dart';
import 'package:edu_verse/screens/ta/calendar/ta_calendar_screen.dart';
import 'package:edu_verse/screens/ta/search/ta_search_screen.dart';
import 'package:edu_verse/screens/ta/attendance/ta_attendance_screen.dart';
import 'package:edu_verse/screens/ta/ai_assistant/ta_ai_assistant_screen.dart';
import 'package:edu_verse/screens/admin/admin_dashboard_screen.dart';
import 'package:edu_verse/screens/admin/users/admin_user_management_screen.dart';
import 'package:edu_verse/screens/admin/users/admin_add_new_user_screen.dart';
import 'package:edu_verse/screens/admin/roles/admin_roles_screen.dart';
import 'package:edu_verse/screens/admin/courses/admin_course_management_screen.dart';
import 'package:edu_verse/screens/admin/courses/admin_add_course_screen.dart';
import 'package:edu_verse/screens/admin/staff/admin_assign_staff_screen.dart';
import 'package:edu_verse/screens/admin/departments/admin_departments_screen.dart';
import 'package:edu_verse/screens/admin/analytics/admin_analytics_screen.dart';
import 'package:edu_verse/screens/admin/security/admin_security_screen.dart';
import 'package:edu_verse/screens/admin/backup/admin_backup_center_screen.dart';
import 'package:edu_verse/screens/admin/payments/admin_payments_screen.dart';
import 'package:edu_verse/screens/admin/audit/admin_audit_screen.dart';
import 'package:edu_verse/screens/admin/integrations/admin_integrations_screen.dart';
import 'package:edu_verse/screens/admin/profile/admin_profile_screen.dart';
import 'package:edu_verse/screens/admin/profile/admin_edit_profile_screen.dart';
import 'package:edu_verse/screens/admin/notifications/admin_notifications_screen.dart';
import 'package:edu_verse/screens/admin/notifications/admin_notification_swipe_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_semester_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_registration_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_blocked_users_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_appearance_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_language_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_branding_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_logo_assets_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_password_policy_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_two_factor_policy_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_email_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_sms_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_push_notifications_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_webhooks_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_api_settings_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_cloud_storage_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_payment_gateways_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_video_conferencing_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_backup_restore_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_system_updates_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_developer_options_screen.dart';
import 'package:edu_verse/screens/admin/settings/admin_system_logs_screen.dart';
import 'package:edu_verse/screens/admin/attendance/admin_attendance_screen.dart';
import 'package:edu_verse/screens/admin/search/admin_search_screen.dart';
import 'package:edu_verse/screens/admin/ai_insights/admin_ai_insights_screen.dart';
import 'package:edu_verse/screens/it_admin/it_admin_dashboard_screen.dart';
import 'package:edu_verse/screens/it_admin/it_system_settings_screen.dart';
import 'package:edu_verse/screens/it_admin/settings/it_settings_screen.dart';
import 'package:edu_verse/screens/it_admin/it_integration_screen.dart';
import 'package:edu_verse/screens/it_admin/it_backup_screen.dart';
import 'package:edu_verse/screens/it_admin/it_security_logs_screen.dart';
import 'package:edu_verse/screens/it_admin/it_ai_model_settings_screen.dart';
import 'package:edu_verse/screens/it_admin/it_performance_report_screen.dart';
import 'package:edu_verse/screens/it_admin/it_alerts_screen.dart';
import 'package:edu_verse/screens/it_admin/it_profile_screen.dart';
import 'package:edu_verse/screens/it_admin/it_edit_profile_screen.dart';
import 'package:edu_verse/screens/it_admin/it_system_health_screen.dart';
import 'package:edu_verse/screens/it_admin/it_server_management_screen.dart';
import 'package:edu_verse/screens/it_admin/it_api_management_screen.dart';
import 'package:edu_verse/screens/it_admin/it_error_logs_screen.dart';
import 'package:edu_verse/screens/it_admin/it_database_screen.dart';
import 'package:edu_verse/screens/it_admin/it_cloud_services_screen.dart';
import 'package:edu_verse/screens/it_admin/search/it_search_screen.dart';
import 'package:edu_verse/screens/shared/shared_chat_screen.dart';
import 'package:edu_verse/screens/shared/discussion_screen.dart';
import 'package:edu_verse/screens/shared/chat/new_conversation_screen.dart';
import 'package:edu_verse/screens/shared/chat/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/screens/auth/email_verification_screen.dart';
import 'package:edu_verse/screens/onBoarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../models/core/enrollment_model.dart';

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
        builder: (context, state) => const CourseListScreen(),
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
          int initialTab = 0;

          // Live enrollment from CoursesBloc
          if (extra is CourseEnrollmentModel) {
            return CourseDetailScreen(
              enrollment: extra,
              initialTabIndex: initialTab,
            );
          }

          // Map-style extras (from dashboard section)
          if (extra is Map<String, dynamic>) {
            final enrollment = extra['enrollment'] as CourseEnrollmentModel?;
            final legacyCourse = extra['course'] as CourseModel?;
            initialTab = extra['initialTab'] as int? ?? 0;

            if (enrollment != null) {
              return CourseDetailScreen(
                enrollment: enrollment,
                initialTabIndex: initialTab,
              );
            }
            if (legacyCourse != null) {
              return CourseDetailsScreen(
                legacyCourse: legacyCourse,
                initialTab: initialTab,
              );
            }
          }

          // Legacy CourseModel direct pass
          if (extra is CourseModel) {
            return CourseDetailsScreen(
              legacyCourse: extra,
              initialTab: initialTab,
            );
          }

          return const Scaffold(body: Center(child: Text('Course not found')));
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
        builder: (context, state) => const SharedChatScreen(
          accentColor: Color(0xFF3B82F6), // Student blue
        ),
      ),
      GoRoute(
        path: '/course/:courseId/discussions',
        builder: (context, state) {
          final courseId = int.tryParse(state.pathParameters['courseId'] ?? '');
          if (courseId == null || courseId <= 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid course discussions route')),
            );
          }

          return DiscussionScreen(
            courseId: courseId,
            accentColor: const Color(0xFF3B82F6),
            title: 'Course Discussions',
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () => Navigator.of(context).maybePop(),
          );
        },
      ),
      GoRoute(
        path: '/discussions',
        builder: (context, state) => const DiscussionScreen(
          accentColor: Color(0xFF3B82F6),
          title: 'Discussions',
          leadingIcon: Icons.arrow_back_ios_new_rounded,
        ),
      ),
      GoRoute(
        path: '/messages/new',
        builder: (context, state) => const NewConversationScreen(),
      ),
      GoRoute(
        path: '/messages/profile/:userId',
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '');
          if (userId == null || userId <= 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid user profile request')),
            );
          }
          return UserProfileScreen(userId: userId);
        },
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
        builder: (context, state) =>
            const settings_chat.ChatSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions/files',
        builder: (context, state) => const FileSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/swipe-actions/notes',
        builder: (context, state) => const NoteSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/share-app',
        builder: (context, state) => const ShareAppScreen(),
      ),
      GoRoute(
        path: '/settings/share-app/qr',
        builder: (context, state) => const QrCodeShareScreen(),
      ),
      GoRoute(
        path: '/settings/share-app/apk',
        builder: (context, state) => const ApkShareScreen(),
      ),

      // ============ INSTRUCTOR ROUTES ============
      GoRoute(
        path: '/instructor/dashboard',
        builder: (context, state) => const InstructorDashboardScreen(),
      ),
      GoRoute(
        path: '/instructor/courses',
        builder: (context, state) => const InstructorCoursesScreen(),
      ),
      GoRoute(
        path: '/instructor/courses/:courseId',
        builder: (context, state) {
          final courseId = int.tryParse(state.pathParameters['courseId'] ?? '');
          final course = state.extra as InstructorCourseModel?;
          return CourseManagementScreen(course: course, courseId: courseId);
        },
      ),
      GoRoute(
        path: '/instructor/courses/:courseId/video/:videoId',
        builder: (context, state) {
          final videoId = state.pathParameters['videoId'] ?? '';
          final course = state.extra as InstructorCourseModel?;
          final videoTitle =
              state.uri.queryParameters['title']?.trim().isNotEmpty == true
              ? state.uri.queryParameters['title']!.trim()
              : 'Course Video';

          return InstructorVideoPlayerScreen(
            videoId: videoId,
            courseName: course?.name ?? 'Course Video',
            videoTitle: videoTitle,
          );
        },
      ),
      GoRoute(
        path: '/instructor/grading',
        builder: (context, state) => const GradingCenterScreen(),
      ),
      GoRoute(
        path: '/instructor/assignments',
        builder: (context, state) => const InstructorAssignmentsScreen(),
      ),
      GoRoute(
        path: '/instructor/labs',
        builder: (context, state) => const InstructorLabsScreen(),
      ),
      GoRoute(
        path: '/instructor/labs/:labId',
        builder: (context, state) {
          final labId = state.pathParameters['labId'] ?? '';
          if (labId.trim().isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid lab detail route')),
            );
          }

          final tabParam = (state.uri.queryParameters['tab'] ?? '')
              .trim()
              .toLowerCase();
          final initialTab = switch (tabParam) {
            'submissions' => 1,
            'attendance' => 2,
            _ => 0,
          };

          return LabDetailScreen(labId: labId, initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/instructor/assignments/create',
        builder: (context, state) {
          assignment_models.AssignmentModel? assignment;
          int? assignmentId;

          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final rawAssignment = extra['assignment'];
            if (rawAssignment is assignment_models.AssignmentModel) {
              assignment = rawAssignment;
            }
            final rawId = extra['assignmentId'];
            if (rawId is int) {
              assignmentId = rawId;
            } else if (rawId is String) {
              assignmentId = int.tryParse(rawId);
            }
          }

          return CreateAssignmentScreen(
            assignment: assignment,
            assignmentId: assignmentId,
          );
        },
      ),
      GoRoute(
        path: '/instructor/assignments/:assignmentId/submissions',
        builder: (context, state) {
          final assignmentId = int.tryParse(
            state.pathParameters['assignmentId'] ?? '',
          );
          if (assignmentId == null || assignmentId <= 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid assignment submissions route')),
            );
          }

          String? assignmentTitle;
          double? maxScore;
          DateTime? assignmentDueDate;
          double latePenaltyPercent = 0;
          bool isArchived = false;
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            assignmentTitle = extra['assignmentTitle'] as String?;
            final rawMaxScore = extra['maxScore'];
            if (rawMaxScore is num) {
              maxScore = rawMaxScore.toDouble();
            }
            final rawDueDate = extra['assignmentDueDate'];
            if (rawDueDate is DateTime) {
              assignmentDueDate = rawDueDate;
            } else if (rawDueDate is String) {
              assignmentDueDate = DateTime.tryParse(rawDueDate);
            }
            final rawPenalty = extra['latePenaltyPercent'];
            if (rawPenalty is num) {
              latePenaltyPercent = rawPenalty.toDouble();
            }
            final rawArchived = extra['isArchived'];
            if (rawArchived is bool) {
              isArchived = rawArchived;
            }
          }

          return AssignmentSubmissionsScreen(
            assignmentId: assignmentId,
            assignmentTitle: assignmentTitle,
            maxScore: maxScore,
            assignmentDueDate: assignmentDueDate,
            latePenaltyPercent: latePenaltyPercent,
            isArchived: isArchived,
          );
        },
      ),
      GoRoute(
        path:
            '/instructor/assignments/:assignmentId/submissions/:submissionId/grading',
        builder: (context, state) {
          final assignmentId = int.tryParse(
            state.pathParameters['assignmentId'] ?? '',
          );
          final submissionId = int.tryParse(
            state.pathParameters['submissionId'] ?? '',
          );

          if (assignmentId == null ||
              assignmentId <= 0 ||
              submissionId == null ||
              submissionId <= 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid grading route')),
            );
          }

          String? assignmentTitle;
          double? maxScore;
          DateTime? assignmentDueDate;
          double latePenaltyPercent = 0;
          bool isArchived = false;
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            assignmentTitle = extra['assignmentTitle'] as String?;
            final rawMaxScore = extra['maxScore'];
            if (rawMaxScore is num) {
              maxScore = rawMaxScore.toDouble();
            }
            final rawDueDate = extra['assignmentDueDate'];
            if (rawDueDate is DateTime) {
              assignmentDueDate = rawDueDate;
            } else if (rawDueDate is String) {
              assignmentDueDate = DateTime.tryParse(rawDueDate);
            }
            final rawPenalty = extra['latePenaltyPercent'];
            if (rawPenalty is num) {
              latePenaltyPercent = rawPenalty.toDouble();
            }
            final rawArchived = extra['isArchived'];
            if (rawArchived is bool) {
              isArchived = rawArchived;
            }
          }

          return SubmissionGradingScreen(
            assignmentId: assignmentId,
            submissionId: submissionId,
            assignmentTitle: assignmentTitle,
            maxScore: maxScore,
            assignmentDueDate: assignmentDueDate,
            latePenaltyPercent: latePenaltyPercent,
            isArchived: isArchived,
          );
        },
      ),
      GoRoute(
        path: '/instructor/course-management',
        builder: (context, state) {
          final course = state.extra as InstructorCourseModel?;
          return CourseManagementScreen(
            course: course,
            courseId: int.tryParse(course?.id ?? ''),
          );
        },
      ),
      GoRoute(
        path: '/instructor/announcements',
        builder: (context, state) => const AnnouncementManagerScreen(),
      ),
      GoRoute(
        path: '/instructor/attendance',
        builder: (context, state) => const AttendanceManagerScreen(),
      ),
      GoRoute(
        path: '/instructor/create-assignment',
        builder: (context, state) {
          assignment_models.AssignmentModel? assignment;
          int? assignmentId;

          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final rawAssignment = extra['assignment'];
            if (rawAssignment is assignment_models.AssignmentModel) {
              assignment = rawAssignment;
            }
            final rawId = extra['assignmentId'];
            if (rawId is int) {
              assignmentId = rawId;
            } else if (rawId is String) {
              assignmentId = int.tryParse(rawId);
            }
          }

          return CreateAssignmentScreen(
            assignment: assignment,
            assignmentId: assignmentId,
          );
        },
      ),
      GoRoute(
        path: '/instructor/reports',
        builder: (context, state) => const ReportsAnalyticsScreen(),
      ),
      GoRoute(
        path: '/instructor/ai-teaching',
        builder: (context, state) => const AITeachingScreen(),
      ),
      GoRoute(
        path: '/instructor/upload-materials',
        builder: (context, state) => const UploadMaterialsScreen(),
      ),
      GoRoute(
        path: '/instructor/calendar',
        builder: (context, state) => const InstructorCalendarScreen(),
      ),
      GoRoute(
        path: '/instructor/search',
        builder: (context, state) => const InstructorSearchScreen(),
      ),
      GoRoute(
        path: '/instructor/notifications',
        builder: (context, state) => const InstructorNotificationsScreen(),
      ),
      GoRoute(
        path: '/instructor/profile',
        builder: (context, state) => const InstructorProfileScreen(),
      ),
      GoRoute(
        path: '/instructor/edit-profile',
        builder: (context, state) => const InstructorEditProfileScreen(),
      ),
      GoRoute(
        path: '/instructor/settings',
        builder: (context, state) => const InstructorSettingsScreen(),
      ),
      GoRoute(
        path: '/instructor/messages',
        builder: (context, state) => const SharedChatScreen(
          accentColor: Color(0xFF4F46E5), // Instructor indigo
        ),
      ),
      GoRoute(
        path: '/instructor/discussions',
        builder: (context, state) => const DiscussionScreen(
          accentColor: Color(0xFF4F46E5),
          title: 'Instructor Discussions',
          leadingIcon: Icons.arrow_back_ios_new_rounded,
        ),
      ),
      GoRoute(
        path: '/instructor/course/:courseId/discussions',
        builder: (context, state) {
          final courseId = int.tryParse(state.pathParameters['courseId'] ?? '');
          if (courseId == null || courseId <= 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid instructor discussion route')),
            );
          }
          return DiscussionScreen(
            courseId: courseId,
            accentColor: const Color(0xFF4F46E5),
            title: 'Course Discussions',
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () => Navigator.of(context).maybePop(),
          );
        },
      ),

      // ============ TA ROUTES (Placeholder) ============
      GoRoute(
        path: '/ta/dashboard',
        builder: (context, state) => const TADashboardScreen(),
      ),
      GoRoute(
        path: '/ta/courses',
        builder: (context, state) => const TACoursesListScreen(),
      ),
      GoRoute(
        path: '/ta/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id'] ?? '1';
          return TACourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/ta/labs',
        builder: (context, state) => const TALabsListScreen(),
      ),
      GoRoute(
        path: '/ta/lab/:id',
        builder: (context, state) {
          final labId = state.pathParameters['id'] ?? '1';
          return TALabDetailScreen(labId: labId);
        },
      ),
      GoRoute(
        path: '/ta/student-performance',
        builder: (context, state) => const TAStudentPerformanceScreen(),
      ),
      GoRoute(
        path: '/ta/notifications',
        builder: (context, state) => const TANotificationsScreen(),
      ),
      GoRoute(
        path: '/ta/discussions',
        builder: (context, state) {
          final courseId = int.tryParse(
            state.uri.queryParameters['courseId'] ?? '',
          );
          return DiscussionScreen(
            courseId: courseId,
            accentColor: const Color(0xFF4F46E5),
            title: 'TA Discussions',
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () => Navigator.of(context).maybePop(),
          );
        },
      ),
      GoRoute(
        path: '/ta/course/:courseId/discussions',
        builder: (context, state) {
          final courseId = int.tryParse(state.pathParameters['courseId'] ?? '');
          if (courseId == null || courseId <= 0) {
            return const Scaffold(
              body: Center(child: Text('Invalid TA discussion route')),
            );
          }
          return DiscussionScreen(
            courseId: courseId,
            accentColor: const Color(0xFF4F46E5),
            title: 'Course Discussions',
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () => Navigator.of(context).maybePop(),
          );
        },
      ),
      GoRoute(
        path: '/ta/upload-materials',
        builder: (context, state) => const TAUploadMaterialsScreen(),
      ),
      GoRoute(
        path: '/ta/ai-grading',
        builder: (context, state) => const TAAIGradingScreen(),
      ),
      GoRoute(
        path: '/ta/student-inbox',
        builder: (context, state) => const TAStudentInboxScreen(),
      ),
      GoRoute(
        path: '/ta/lab-resources',
        builder: (context, state) => const TALabResourcesScreen(),
      ),
      GoRoute(
        path: '/ta/analytics',
        builder: (context, state) => const TAAnalyticsScreen(),
      ),
      GoRoute(
        path: '/ta/settings',
        builder: (context, state) => const TASettingsScreen(),
      ),
      GoRoute(
        path: '/ta/profile',
        builder: (context, state) => const TAProfileScreen(),
      ),
      GoRoute(
        path: '/ta/edit-profile',
        builder: (context, state) => const TAEditProfileScreen(),
      ),
      GoRoute(
        path: '/ta/office-hours',
        builder: (context, state) => const TAOfficeHoursScreen(),
      ),
      GoRoute(
        path: '/ta/calendar',
        builder: (context, state) => const TACalendarScreen(),
      ),
      GoRoute(
        path: '/ta/search',
        builder: (context, state) => const TASearchScreen(),
      ),
      GoRoute(
        path: '/ta/attendance',
        builder: (context, state) => const TAAttendanceScreen(),
      ),
      GoRoute(
        path: '/ta/ai-assistant',
        builder: (context, state) => const TAAIAssistantScreen(),
      ),
      GoRoute(
        path: '/ta/messages',
        builder: (context, state) => const SharedChatScreen(
          accentColor: Color(0xFF4F46E5), // TA indigo
        ),
      ),

      // ============ ADMIN ROUTES ============
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/users/add',
        builder: (context, state) => const AdminAddNewUserScreen(),
      ),
      GoRoute(
        path: '/admin/users/edit/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id'] ?? '';
          return AdminAddNewUserScreen(key: ValueKey(userId));
        },
      ),
      GoRoute(
        path: '/admin/roles',
        builder: (context, state) => const AdminRolesScreen(),
      ),
      GoRoute(
        path: '/admin/courses',
        builder: (context, state) => const AdminCourseManagementScreen(),
      ),
      GoRoute(
        path: '/admin/courses/add',
        builder: (context, state) => const AdminAddCourseScreen(),
      ),
      GoRoute(
        path: '/admin/staff',
        builder: (context, state) => const AdminAssignStaffScreen(),
      ),
      GoRoute(
        path: '/admin/departments',
        builder: (context, state) => const AdminDepartmentsScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/security',
        builder: (context, state) => const AdminSecurityScreen(),
      ),
      GoRoute(
        path: '/admin/backup-center',
        builder: (context, state) => const AdminBackupCenterScreen(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AdminAuditScreen(),
      ),
      GoRoute(
        path: '/admin/integrations',
        builder: (context, state) => const AdminIntegrationsScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
      GoRoute(
        path: '/admin/edit-profile',
        builder: (context, state) => const AdminEditProfileScreen(),
      ),
      GoRoute(
        path: '/admin/attendance',
        builder: (context, state) => const AdminAttendanceScreen(),
      ),
      GoRoute(
        path: '/admin/search',
        builder: (context, state) => const AdminSearchScreen(),
      ),
      GoRoute(
        path: '/admin/messages',
        builder: (context, state) => const SharedChatScreen(
          accentColor: Color(0xFF4F46E5), // Admin indigo
        ),
      ),
      GoRoute(
        path: '/admin/discussions',
        builder: (context, state) => const DiscussionScreen(
          accentColor: Color(0xFF4F46E5),
          title: 'Admin Discussions',
          leadingIcon: Icons.arrow_back_ios_new_rounded,
        ),
      ),
      GoRoute(
        path: '/admin/ai-insights',
        builder: (context, state) => const AdminAIInsightsScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/notifications/swipe-settings',
        builder: (context, state) =>
            const AdminNotificationSwipeSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/semester',
        builder: (context, state) => const AdminSemesterSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/registration',
        builder: (context, state) => const AdminRegistrationSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/blocked-users',
        builder: (context, state) => const AdminBlockedUsersScreen(),
      ),
      GoRoute(
        path: '/admin/settings/appearance',
        builder: (context, state) => const AdminAppearanceSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/language',
        builder: (context, state) => const AdminLanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/branding',
        builder: (context, state) => const AdminBrandingSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/logo-assets',
        builder: (context, state) => const AdminLogoAssetsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/password-policy',
        builder: (context, state) => const AdminPasswordPolicyScreen(),
      ),
      GoRoute(
        path: '/admin/settings/two-factor',
        builder: (context, state) => const AdminTwoFactorPolicyScreen(),
      ),
      GoRoute(
        path: '/admin/settings/email',
        builder: (context, state) => const AdminEmailSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/sms',
        builder: (context, state) => const AdminSmsSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/push-notifications',
        builder: (context, state) => const AdminPushNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/webhooks',
        builder: (context, state) => const AdminWebhooksScreen(),
      ),
      GoRoute(
        path: '/admin/settings/api',
        builder: (context, state) => const AdminApiSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/cloud-storage',
        builder: (context, state) => const AdminCloudStorageScreen(),
      ),
      GoRoute(
        path: '/admin/settings/payment-gateways',
        builder: (context, state) => const AdminPaymentGatewaysScreen(),
      ),
      GoRoute(
        path: '/admin/settings/video-conferencing',
        builder: (context, state) => const AdminVideoConferencingScreen(),
      ),
      GoRoute(
        path: '/admin/settings/backup-restore',
        builder: (context, state) => const AdminBackupRestoreScreen(),
      ),
      GoRoute(
        path: '/admin/settings/system-updates',
        builder: (context, state) => const AdminSystemUpdatesScreen(),
      ),
      GoRoute(
        path: '/admin/settings/developer-options',
        builder: (context, state) => const AdminDeveloperOptionsScreen(),
      ),
      GoRoute(
        path: '/admin/settings/system-logs',
        builder: (context, state) => const AdminSystemLogsScreen(),
      ),

      // ============ IT ADMIN ROUTES ============
      GoRoute(
        path: '/it-admin/dashboard',
        builder: (context, state) => const ITAdminDashboardScreen(),
      ),
      GoRoute(
        path: '/it-admin/settings',
        builder: (context, state) => const ITSystemSettingsScreen(),
      ),
      GoRoute(
        path: '/it-admin/account-settings',
        builder: (context, state) => const ITSettingsScreen(),
      ),
      GoRoute(
        path: '/it-admin/integrations',
        builder: (context, state) => const ITIntegrationScreen(),
      ),
      GoRoute(
        path: '/it-admin/backup',
        builder: (context, state) => const ITBackupScreen(),
      ),
      GoRoute(
        path: '/it-admin/security-logs',
        builder: (context, state) => const ITSecurityLogsScreen(),
      ),
      GoRoute(
        path: '/it-admin/ai-settings',
        builder: (context, state) => const ITAIModelSettingsScreen(),
      ),
      GoRoute(
        path: '/it-admin/performance',
        builder: (context, state) => const ITPerformanceReportScreen(),
      ),
      GoRoute(
        path: '/it-admin/alerts',
        builder: (context, state) => const ITAlertsScreen(),
      ),
      GoRoute(
        path: '/it-admin/profile',
        builder: (context, state) => const ITProfileScreen(),
      ),
      GoRoute(
        path: '/it-admin/edit-profile',
        builder: (context, state) => const ITEditProfileScreen(),
      ),
      GoRoute(
        path: '/it-admin/system-health',
        builder: (context, state) => const ITSystemHealthScreen(),
      ),
      GoRoute(
        path: '/it-admin/servers',
        builder: (context, state) => const ITServerManagementScreen(),
      ),
      GoRoute(
        path: '/it-admin/api',
        builder: (context, state) => const ITApiManagementScreen(),
      ),
      GoRoute(
        path: '/it-admin/logs',
        builder: (context, state) => const ITErrorLogsScreen(),
      ),
      GoRoute(
        path: '/it-admin/database',
        builder: (context, state) => const ITDatabaseScreen(),
      ),
      GoRoute(
        path: '/it-admin/cloud',
        builder: (context, state) => const ITCloudServicesScreen(),
      ),
      GoRoute(
        path: '/it-admin/messages',
        builder: (context, state) => const SharedChatScreen(
          accentColor: Color(0xFF3B82F6), // IT Admin blue
        ),
      ),
      GoRoute(
        path: '/it-admin/discussions',
        builder: (context, state) => const DiscussionScreen(
          accentColor: Color(0xFF3B82F6),
          title: 'IT Admin Discussions',
          leadingIcon: Icons.arrow_back_ios_new_rounded,
        ),
      ),
      GoRoute(
        path: '/it-admin/search',
        builder: (context, state) => const ITSearchScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
