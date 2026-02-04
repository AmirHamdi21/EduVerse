import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/screens/student/ai_quiz_generator_screen.dart';
import 'package:edu_verse/screens/student/assignments_screen.dart';
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
import 'package:edu_verse/widgets/student/ai_quiz/quiz_widgets/quiz_result_screen.dart';
import 'package:edu_verse/widgets/student/courses/courses_barrel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/screens/auth/email_verification_screen.dart';
import 'package:edu_verse/screens/onBoarding/onboarding1.dart';
import 'package:edu_verse/screens/onBoarding/onboarding2.dart';
import 'package:edu_verse/screens/onBoarding/onboarding_3.dart';
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
        path: '/onboarding1',
        builder: (context, state) => const Onboarding1(),
      ),
      GoRoute(
        path: '/onboarding2',
        builder: (context, state) => const Onboarding2(),
      ),
      GoRoute(
        path: '/onboarding3',
        builder: (context, state) => const Onboarding3(),
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
          final course = state.extra as CourseModel?;
          if (course == null) {
            return const Scaffold(
              body: Center(child: Text('Course not found')),
            );
          }
          return CourseDetailsScreen(course: course);
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
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
