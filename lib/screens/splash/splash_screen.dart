import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../common/utils/responsive.dart';
import '../../generated_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check when splash screen loads
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // Add a minimum display time for splash screen
        await Future.delayed(const Duration(seconds: 4));

        if (!mounted) return;

        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        } else if (state is AuthUnauthenticated) {
          // context.go('/login');
          // context.go('/onboarding1');
          context.go('/dashboard');
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final textColor = isDark
              ? AppTheme.darkTextPrimary
              : const Color(0xFF1E293B);
          final textSecondaryColor = isDark
              ? AppTheme.darkTextSecondary
              : const Color(0xFF697282);
          return Scaffold(
            backgroundColor: isDark
                ? AppTheme.darkSurfaceColor
                : const Color(0xFFF8FAFC),
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xff020618),
                          Color(0xff162456),
                          Color(0xff0F172B),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.onBoardingbackgroundLight,
                          Colors.white,
                          AppTheme.onBoardingbackgroundCyan,
                        ],
                      ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(responsive.p32),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.onBoardingcyan.withOpacity(0.15)
                            : AppTheme.onBoardingprimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: responsive.iconExtraLarge,
                        color: isDark
                            ? AppTheme.onBoardingcyan
                            : AppTheme.onBoardingprimary,
                      ),
                    ),
                    SizedBox(height: responsive.p24),
                    Text(
                      l!.splashTitle,
                      style: TextStyle(
                        color: textColor,
                        fontSize: responsive.fontSize32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: responsive.p8),
                    Text(
                      l.splashSubtitle,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: responsive.fontSize16,
                      ),
                    ),
                    SizedBox(height: responsive.p48),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark
                            ? AppTheme.onBoardingcyan
                            : AppTheme.onBoardingprimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
