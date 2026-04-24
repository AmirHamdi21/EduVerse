import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../models/auth_models.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/language/language_cubit.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../common/utils/responsive.dart';
import '../../services/api_service.dart';
import '../../services/demo_credentials.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _emailFieldController;
  late AnimationController _passwordFieldController;
  late AnimationController _forgotController;
  late AnimationController _buttonController;
  late AnimationController _signupController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _emailFadeAnimation;
  late Animation<Offset> _emailSlideAnimation;
  late Animation<double> _passwordFadeAnimation;
  late Animation<Offset> _passwordSlideAnimation;
  late Animation<double> _forgotFadeAnimation;
  late Animation<Offset> _forgotSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _signupFadeAnimation;
  late Animation<Offset> _signupSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    // Subtitle animation
    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
    );

    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _subtitleController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Email field animation
    _emailFieldController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _emailFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emailFieldController, curve: Curves.easeOut),
    );

    _emailSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _emailFieldController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Password field animation
    _passwordFieldController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _passwordFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _passwordFieldController, curve: Curves.easeOut),
    );

    _passwordSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _passwordFieldController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Forgot password animation
    _forgotController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _forgotFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _forgotController, curve: Curves.easeOut),
    );

    _forgotSlideAnimation =
        Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _forgotController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Sign up animation
    _signupController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _signupFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _signupController, curve: Curves.easeOut),
    );

    _signupSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _signupController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start cascading animations
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _titleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _subtitleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _emailFieldController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _passwordFieldController.forward();
    });

    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) _forgotController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _buttonController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1050), () {
      if (mounted) _signupController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    _forgotController.dispose();
    _buttonController.dispose();
    _signupController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final l = AppLocalizations.of(context);

    // Validate email and password format before API call
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(l.fieldRequired);
      return;
    }

    // Check for demo credentials first (development mode)
    final demoRole = DemoCredentials.validateDemoCredentials(email, password);
    if (demoRole != null) {
      // Demo login - bypass API and navigate directly
      final demoUser = DemoCredentials.getDemoUser(demoRole);
      final route = DemoCredentials.getDashboardRouteForUser(demoUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l.success} (Demo: $demoRole)'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go(route);
      return;
    }

    // Check if it's a demo email with wrong password
    if (DemoCredentials.isDemoEmail(email)) {
      _showErrorDialog('Invalid demo password. Check credentials.');
      return;
    }

    // Pre-check: Try to authenticate to see if email is verified
    try {
      final apiService = ApiService();
      // This will throw if email is not verified or doesn't exist
      await apiService.isEmailVerifiedAndExists(email, password);

      if (!mounted) return;

      // If we reach here, email is verified and credentials are correct
      // Proceed with normal login through BLoC
      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: false,
      );

      if (mounted) {
        context.read<AuthBloc>().add(LoginRequested(request));
      }
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString();

      if (errorMsg.contains('Email not verified')) {
        // Email is not verified - show verification warning
        _showWarningDialog(
          l.emailNotVerified,
          l.emailNotVerified,
          onRetry: () {
            context.read<AuthBloc>().add(
              ResendVerificationEmailRequested(email),
            );
          },
        );
      } else {
        // Generic error - could be invalid credentials, server error, etc
        _showErrorDialog(l.operationFailed);
      }
    }
  }

  void _showErrorDialog(String message) {
    _showModernDialog(
      title: AppLocalizations.of(context).error,
      message: message,
      icon: Icons.error_outline_rounded,
      accentColors: const [Color(0xFFFF5F6D), Color(0xFFFFA24D)],
    );
  }

  void _showWarningDialog(
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    _showModernDialog(
      title: title,
      message: message,
      icon: Icons.mark_email_unread_outlined,
      accentColors: const [Color(0xFFFFB347), Color(0xFFFF7A59)],
      primaryLabel: AppLocalizations.of(context).tryAgain,
      onPrimary: onRetry,
      secondaryLabel: AppLocalizations.of(context).cancel,
    );
  }

  Future<void> _showModernDialog({
    required String title,
    required String message,
    required IconData icon,
    required List<Color> accentColors,
    String? primaryLabel,
    VoidCallback? onPrimary,
    String? secondaryLabel,
  }) {
    final materialLocalizations = MaterialLocalizations.of(context);

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: materialLocalizations.modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, _, __) {
        return _LoginStatusDialog(
          title: title,
          message: message,
          icon: icon,
          accentColors: accentColors,
          primaryLabel: primaryLabel ?? materialLocalizations.okButtonLabel,
          onPrimary: onPrimary,
          secondaryLabel: secondaryLabel,
        );
      },
      transitionBuilder: (dialogContext, animation, _, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.success),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          // Navigate based on user role
          final route = DemoCredentials.getDashboardRouteForUser(state.user);
          context.go(route);
        } else if (state is AuthError) {
          if (state.message.toLowerCase().contains('verify')) {
            _showWarningDialog(
              l.emailNotVerified,
              state.message,
              onRetry: () {
                context.read<AuthBloc>().add(
                  ResendVerificationEmailRequested(
                    _emailController.text.trim(),
                  ),
                );
              },
            );
          } else {
            _showErrorDialog(state.message);
          }
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
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.darkBg1,
                          AppTheme.darkBg2,
                          AppTheme.darkBg3,
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEEF5FE),
                          Colors.white,
                          Color(0xFFFAF5FE),
                        ],
                      ),
              ),
              child: Stack(
                children: [
                  // Decorative circles (only in light mode)
                  // if (!isDark) ...[
                  Positioned(
                    left: responsive.p40,
                    top: responsive.p80,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: responsive.aspectRatioWidth(286),
                        height: responsive.aspectRatioHeight(286),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8EC5FF),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsive.p48,
                    top: responsive.p192,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: responsive.aspectRatioWidth(260),
                        height: responsive.aspectRatioHeight(260),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDAB2FF),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsive.p96,
                    top: responsive.p536,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: responsive.aspectRatioWidth(317),
                        height: responsive.aspectRatioHeight(317),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3B3FF),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsive.p104,
                    top: responsive.p376,
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: responsive.aspectRatioWidth(178),
                        height: responsive.aspectRatioHeight(178),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFBDDAFF),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: responsive.p176,
                    top: responsive.p456,
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: responsive.aspectRatioWidth(116),
                        height: responsive.aspectRatioHeight(116),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE9D4FF),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  // ],

                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(responsive.p24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkCardColor.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(
                                responsive.radius24,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 50,
                                  offset: const Offset(0, 25),
                                  spreadRadius: -12,
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo
                                  FadeTransition(
                                    opacity: _logoFadeAnimation,
                                    child: ScaleTransition(
                                      scale: _logoScaleAnimation,
                                      child: Container(
                                        width: responsive.aspectRatioWidth(100),
                                        height: responsive.aspectRatioHeight(
                                          100,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            responsive.aspectRatioWidth(40),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 15,
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          "assets/logo/logo.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p32),
                                  // Title
                                  FadeTransition(
                                    opacity: _titleFadeAnimation,
                                    child: SlideTransition(
                                      position: _titleSlideAnimation,
                                      child: Text(
                                        l.loginTitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: responsive.fontSize28,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p8),
                                  // Subtitle
                                  FadeTransition(
                                    opacity: _subtitleFadeAnimation,
                                    child: SlideTransition(
                                      position: _subtitleSlideAnimation,
                                      child: Text(
                                        l.loginSubtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: responsive.fontSize16,
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p32),
                                  // Email field
                                  FadeTransition(
                                    opacity: _emailFadeAnimation,
                                    child: SlideTransition(
                                      position: _emailSlideAnimation,
                                      child: _buildTextField(
                                        context: context,
                                        controller: _emailController,
                                        hint: l.email,
                                        icon: Icons.email_outlined,
                                        isDark: isDark,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l.fieldRequired;
                                          }
                                          if (!value.contains('@')) {
                                            return l.invalidEmail;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
                                  // Password field
                                  FadeTransition(
                                    opacity: _passwordFadeAnimation,
                                    child: SlideTransition(
                                      position: _passwordSlideAnimation,
                                      child: _buildTextField(
                                        context: context,
                                        controller: _passwordController,
                                        hint: l.password,
                                        icon: Icons.lock_outline,
                                        isDark: isDark,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: textSecondaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l.fieldRequired;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p8),
                                  // Forgot password
                                  FadeTransition(
                                    opacity: _forgotFadeAnimation,
                                    child: SlideTransition(
                                      position: _forgotSlideAnimation,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () =>
                                              context.push('/forgot-password'),
                                          child: Text(
                                            l.forgotPassword,
                                            style: TextStyle(
                                              color: Color(0xFF2B7FFF),
                                              fontSize: responsive.fontSize14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
                                  // Login button
                                  FadeTransition(
                                    opacity: _buttonFadeAnimation,
                                    child: SlideTransition(
                                      position: _buttonSlideAnimation,
                                      child: BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          final isLoading =
                                              state is AuthLoading;
                                          return SizedBox(
                                            width: double.infinity,
                                            height: responsive.buttonHeight,
                                            child: ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : _handleLogin,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        responsive.radius16,
                                                      ),
                                                ),
                                              ),
                                              child: Ink(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF00D2F2),
                                                          Color(0xFF2B7FFF),
                                                          Color(0xFF1347E5),
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        responsive.radius16,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: isLoading
                                                      ? SizedBox(
                                                          height: responsive
                                                              .iconMedium,
                                                          width: responsive
                                                              .iconMedium,
                                                          child: const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                      : Text(
                                                          l.loginButton,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: responsive
                                                                .fontSize16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p24),
                                  // Sign up
                                  FadeTransition(
                                    opacity: _signupFadeAnimation,
                                    child: SlideTransition(
                                      position: _signupSlideAnimation,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${l.dontHaveAccount} ",
                                            style: TextStyle(
                                              color: textSecondaryColor,
                                              fontSize: responsive.fontSize14,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                context.push('/register'),
                                            child: Text(
                                              l.signUp,
                                              style: TextStyle(
                                                color: Color(0xFF2B7FFF),
                                                fontWeight: FontWeight.w600,
                                                fontSize: responsive.fontSize14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
                                  // Demo Credentials
                                  _buildDemoCredentials(context, isDark),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // // Top left icon
                  // Positioned(
                  //   left: responsive.p16,
                  //   top: responsive.safeAreaTop + responsive.p8,
                  //   child: IconButton(
                  //     onPressed: () {
                  //       // context.go('/dashboard');
                  //       context.go('/instructor/dashboard');
                  //     },
                  //     icon: Icon(Icons.home),
                  //   ),
                  // ),
                  // Top right icons
                  Positioned(
                    right: responsive.p16,
                    top: responsive.safeAreaTop + responsive.p8,
                    child: Row(
                      children: [
                        BlocBuilder<LanguageCubit, Locale>(
                          builder: (context, locale) {
                            return _buildLanguageSwitchIcon(
                              context,
                              locale.languageCode,
                              isDark,
                            );
                          },
                        ),
                        SizedBox(width: responsive.p12),
                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, state) {
                            return _buildThemeToggleIcon(
                              context,
                              state.isDark,
                              isDark,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSwitchIcon(
    BuildContext context,
    String currentLanguage,
    bool isDark,
  ) {
    final responsive = context.responsive;
    return Container(
      width: responsive.aspectRatioWidth(50),
      height: responsive.aspectRatioHeight(50),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(
          color: isDark ? const Color(0xFF404756) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          onSelected: (String langCode) {
            context.read<LanguageCubit>().changeLanguage(langCode);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  SizedBox(width: responsive.p8),
                  Text(
                    'English',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: currentLanguage == 'en'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'en'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'en')
                    Padding(
                      padding: EdgeInsets.only(left: responsive.p8),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF2B7FFF),
                        size: responsive.iconSmall,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  SizedBox(width: responsive.p8),
                  Text(
                    'العربية',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: currentLanguage == 'ar'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'ar'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'ar')
                    Padding(
                      padding: EdgeInsets.only(left: responsive.p8),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF2B7FFF),
                        size: responsive.iconSmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.language,
            size: responsive.iconSmall,
            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF354152),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleIcon(
    BuildContext context,
    bool isDark,
    bool themeIsDark,
  ) {
    final responsive = context.responsive;
    return Container(
      width: responsive.aspectRatioWidth(50),
      height: responsive.aspectRatioHeight(50),
      decoration: BoxDecoration(
        color: themeIsDark
            ? AppTheme.darkCardColor
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(
          color: themeIsDark
              ? const Color(0xFF404756)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
          borderRadius: BorderRadius.circular(1000),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: responsive.iconSmall,
            color: themeIsDark
                ? AppTheme.darkTextPrimary
                : const Color(0xFF354152),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final responsive = context.responsive;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : const Color(0xFF354152);
    final hintColor = isDark
        ? AppTheme.darkTextSecondary
        : const Color(0xFF717182);
    final fillColor = isDark ? AppTheme.darkCardColor : const Color(0xFFF9FAFB);
    final borderColor = isDark
        ? const Color(0xFF404756)
        : const Color(0xFFE5E7EB);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: textColor,
        fontSize: responsive.fontSize16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: responsive.fontSize16),
        prefixIcon: Icon(icon, color: hintColor, size: responsive.iconSmall),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.p16,
          vertical: responsive.p16,
        ),
      ),
    );
  }

  Widget _buildDemoCredentials(BuildContext context, bool isDark) {
    final responsive = context.responsive;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : const Color(0xFF1E293B);
    final textSecondaryColor = isDark
        ? AppTheme.darkTextSecondary
        : const Color(0xFF697282);
    final cardColor = isDark ? AppTheme.darkCardColor : Colors.white;

    return Container(
      margin: EdgeInsets.only(top: responsive.p24),
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: isDark ? const Color(0xFF404756) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: responsive.iconSmall,
                color: const Color(0xFF2B7FFF),
              ),
              SizedBox(width: responsive.p8),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          ...DemoCredentials.getAllCredentials().map((cred) {
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.p8),
              child: InkWell(
                onTap: () {
                  _emailController.text = cred['email']!;
                  _passwordController.text = cred['password']!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${cred['role']} credentials loaded'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(responsive.radius8),
                child: Container(
                  padding: EdgeInsets.all(responsive.p8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsive.radius8),
                    color: isDark
                        ? const Color(0xFF1E2530).withOpacity(0.5)
                        : const Color(0xFFF9FAFB),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cred['role']!,
                              style: TextStyle(
                                fontSize: responsive.fontSize12,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: responsive.p4),
                            Text(
                              cred['email']!,
                              style: TextStyle(
                                fontSize: responsive.fontSize11,
                                color: textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: responsive.iconSmall * 0.7,
                        color: textSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _LoginStatusDialog extends StatelessWidget {
  const _LoginStatusDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColors,
    required this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
  });

  final String title;
  final String message;
  final IconData icon;
  final List<Color> accentColors;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF111827)
        : const Color(0xFFFDFEFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark
        ? const Color(0xFFD1D5DB)
        : const Color(0xFF475569);
    final secondaryColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF1F5F9);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.p24),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(responsive.radius24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(
                      alpha: isDark ? 0.94 : 0.98,
                    ),
                    borderRadius: BorderRadius.circular(responsive.radius24),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.12 : 0.8,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColors.first.withValues(alpha: 0.20),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -32,
                        right: -18,
                        child: _DialogGlow(
                          color: accentColors.last.withValues(alpha: 0.22),
                          size: 120,
                        ),
                      ),
                      Positioned(
                        left: -24,
                        bottom: -42,
                        child: _DialogGlow(
                          color: accentColors.first.withValues(alpha: 0.16),
                          size: 128,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(responsive.p24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(colors: accentColors),
                              ),
                            ),
                            SizedBox(height: responsive.p20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: responsive.p56,
                                  height: responsive.p56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: accentColors,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: responsive.iconLarge,
                                  ),
                                ),
                                SizedBox(width: responsive.p16),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: responsive.p4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: responsive.fontSize20,
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                          ),
                                        ),
                                        SizedBox(height: responsive.p10),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            fontSize: responsive.fontSize14,
                                            height: 1.45,
                                            color: bodyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.p24),
                            Row(
                              children: [
                                if (secondaryLabel != null) ...[
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: titleColor,
                                        backgroundColor: secondaryColor,
                                        padding: EdgeInsets.symmetric(
                                          vertical: responsive.p14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            responsive.radius16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        secondaryLabel!,
                                        style: TextStyle(
                                          fontSize: responsive.fontSize14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: responsive.p12),
                                ],
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onPrimary?.call();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      backgroundColor: accentColors.first,
                                      padding: EdgeInsets.symmetric(
                                        vertical: responsive.p14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          responsive.radius16,
                                        ),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: accentColors,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          responsive.radius16,
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        constraints: BoxConstraints(
                                          minHeight: responsive.p24,
                                        ),
                                        child: Text(
                                          primaryLabel,
                                          style: TextStyle(
                                            fontSize: responsive.fontSize14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogGlow extends StatelessWidget {
  const _DialogGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
