import 'package:edu_verse/screens/student/student_dashboard_screen.dart';
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
import '../screens/dashboard_screen.dart';

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
      // GoRoute(
      //   path: '/dashboard',
      //   builder: (context, state) => const DashboardScreen(),
      // ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
