import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _firstNameController_anim;
  late AnimationController _lastNameController_anim;
  late AnimationController _emailFieldController;
  late AnimationController _phoneFieldController;
  late AnimationController _roleFieldController;
  late AnimationController _passwordFieldController;
  late AnimationController _confirmPasswordController_anim;
  late AnimationController _termsController;
  late AnimationController _registerButtonController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _firstNameFadeAnimation;
  late Animation<Offset> _firstNameSlideAnimation;
  late Animation<double> _lastNameFadeAnimation;
  late Animation<Offset> _lastNameSlideAnimation;
  late Animation<double> _emailFadeAnimation;
  late Animation<Offset> _emailSlideAnimation;
  late Animation<double> _phoneFadeAnimation;
  late Animation<Offset> _phoneSlideAnimation;
  late Animation<double> _roleFadeAnimation;
  late Animation<Offset> _roleSlideAnimation;
  late Animation<double> _passwordFadeAnimation;
  late Animation<Offset> _passwordSlideAnimation;
  late Animation<double> _confirmPasswordFadeAnimation;
  late Animation<Offset> _confirmPasswordSlideAnimation;
  late Animation<double> _termsFadeAnimation;
  late Animation<Offset> _termsSlideAnimation;
  late Animation<double> _registerButtonFadeAnimation;
  late Animation<Offset> _registerButtonSlideAnimation;

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

    // First name field animation
    _firstNameController_anim = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _firstNameFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _firstNameController_anim, curve: Curves.easeOut),
    );
    _firstNameSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _firstNameController_anim,
            curve: Curves.easeOutCubic,
          ),
        );

    // Last name field animation
    _lastNameController_anim = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _lastNameFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lastNameController_anim, curve: Curves.easeOut),
    );
    _lastNameSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _lastNameController_anim,
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

    // Phone field animation
    _phoneFieldController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _phoneFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _phoneFieldController, curve: Curves.easeOut),
    );
    _phoneSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _phoneFieldController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Role field animation
    _roleFieldController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _roleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _roleFieldController, curve: Curves.easeOut),
    );
    _roleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _roleFieldController,
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

    // Confirm password field animation
    _confirmPasswordController_anim = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _confirmPasswordFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _confirmPasswordController_anim,
        curve: Curves.easeOut,
      ),
    );
    _confirmPasswordSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _confirmPasswordController_anim,
            curve: Curves.easeOutCubic,
          ),
        );

    // Terms checkbox animation
    _termsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _termsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _termsController, curve: Curves.easeOut));
    _termsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _termsController, curve: Curves.easeOutCubic),
        );

    // Register button animation
    _registerButtonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _registerButtonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _registerButtonController, curve: Curves.easeOut),
    );
    _registerButtonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _registerButtonController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start cascading animations
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _titleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _firstNameController_anim.forward();
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _lastNameController_anim.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _emailFieldController.forward();
    });

    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) _phoneFieldController.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _roleFieldController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1050), () {
      if (mounted) _passwordFieldController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _confirmPasswordController_anim.forward();
    });

    Future.delayed(const Duration(milliseconds: 1350), () {
      if (mounted) _termsController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _registerButtonController.forward();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    _firstNameController_anim.dispose();
    _lastNameController_anim.dispose();
    _emailFieldController.dispose();
    _phoneFieldController.dispose();
    _roleFieldController.dispose();
    _passwordFieldController.dispose();
    _confirmPasswordController_anim.dispose();
    _termsController.dispose();
    _registerButtonController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final l = AppLocalizations.of(context);

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog(l.passwordMismatch);
      return;
    }

    if (!_agreeToTerms) {
      _showErrorDialog('${l.agree} ${l.termsOfService}');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Prepare registration request
    final request = RegisterRequest(
      email: email,
      password: password,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    context.read<AuthBloc>().add(RegisterRequested(request));
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: AppLocalizations.of(context).error,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
                            margin: EdgeInsets.only(
                              top: responsive.p20,
                              bottom: responsive.p20,
                            ),
                            padding: EdgeInsets.all(responsive.p24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkCardColor.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.6),
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
                                  SizedBox(height: responsive.p24),
                                  // Title
                                  FadeTransition(
                                    opacity: _titleFadeAnimation,
                                    child: SlideTransition(
                                      position: _titleSlideAnimation,
                                      child: Text(
                                        l.signupTitle,
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
                                  Text(
                                    l.signupSubtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: responsive.fontSize16,
                                      color: textSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(height: responsive.p24),
                                  // First name field
                                  FadeTransition(
                                    opacity: _firstNameFadeAnimation,
                                    child: SlideTransition(
                                      position: _firstNameSlideAnimation,
                                      child: _buildTextField(
                                        context: context,
                                        controller: _firstNameController,
                                        hint: l.firstName,
                                        icon: Icons.person_outline,
                                        isDark: isDark,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l.fieldRequired;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
                                  // Last name field
                                  FadeTransition(
                                    opacity: _lastNameFadeAnimation,
                                    child: SlideTransition(
                                      position: _lastNameSlideAnimation,
                                      child: _buildTextField(
                                        context: context,
                                        controller: _lastNameController,
                                        hint: l.lastName,
                                        icon: Icons.person_outline,
                                        isDark: isDark,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l.fieldRequired;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
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
                                  // Phone field
                                  FadeTransition(
                                    opacity: _phoneFadeAnimation,
                                    child: SlideTransition(
                                      position: _phoneSlideAnimation,
                                      child: _buildTextField(
                                        context: context,
                                        controller: _phoneController,
                                        hint: l.phoneNumber,
                                        icon: Icons.phone_outlined,
                                        isDark: isDark,
                                        validator: (value) => null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
                                  // Role field
                                  FadeTransition(
                                    opacity: _roleFadeAnimation,
                                    child: SlideTransition(
                                      position: _roleSlideAnimation,
                                      child: _buildRoleDropdown(
                                        isDark,
                                        textColor,
                                        textSecondaryColor,
                                        l,
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
                                            size: responsive.iconMedium,
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
                                          if (value.length < 6) {
                                            return l.passwordTooShort;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p16),
                                  // Confirm password field
                                  FadeTransition(
                                    opacity: _confirmPasswordFadeAnimation,
                                    child: SlideTransition(
                                      position: _confirmPasswordSlideAnimation,
                                      child: _buildTextField(
                                        context: context,
                                        controller: _confirmPasswordController,
                                        hint: l.confirmPassword,
                                        icon: Icons.lock_outline,
                                        isDark: isDark,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: textSecondaryColor,
                                            size: responsive.iconMedium,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
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
                                  SizedBox(height: responsive.p16),
                                  // Terms checkbox
                                  FadeTransition(
                                    opacity: _termsFadeAnimation,
                                    child: SlideTransition(
                                      position: _termsSlideAnimation,
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: _agreeToTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _agreeToTerms = value ?? false;
                                              });
                                            },
                                            activeColor: const Color(
                                              0xFF2B7FFF,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              l.termsOfService,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: responsive.fontSize14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: responsive.p24),
                                  // Register button
                                  FadeTransition(
                                    opacity: _registerButtonFadeAnimation,
                                    child: SlideTransition(
                                      position: _registerButtonSlideAnimation,
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
                                                  : _handleRegister,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        responsive.radius12,
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
                                                        responsive.radius12,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: isLoading
                                                      ? SizedBox(
                                                          height: responsive
                                                              .iconSmall,
                                                          width: responsive
                                                              .iconSmall,
                                                          child: const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                      : Text(
                                                          l.signupButton,
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
                                  SizedBox(height: responsive.p16),
                                  // Sign in
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${l.alreadyHaveAccount} ",
                                        style: TextStyle(
                                          color: textSecondaryColor,
                                          fontSize: responsive.fontSize14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: Text(
                                          l.signIn,
                                          style: TextStyle(
                                            color: const Color(0xFF2B7FFF),
                                            fontWeight: FontWeight.w600,
                                            fontSize: responsive.fontSize14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 48,
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
                        const SizedBox(width: 12),
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

  Widget _buildRoleDropdown(
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    AppLocalizations l,
  ) {
    final responsive = context.responsive;
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: isDark ? const Color(0xFF404756) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: textSecondaryColor,
            size: responsive.iconSmall,
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student account',
                  style: TextStyle(
                    color: textColor,
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.p4),
                Text(
                  'Public registration creates a student account. Instructor, TA, admin, and IT roles must be assigned by authorized staff.',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: responsive.fontSize13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  const SizedBox(width: 8),
                  Text(
                    'English',
                    style: TextStyle(
                      color: currentLanguage == 'en'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'en'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'en')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: Color(0xFF2B7FFF)),
                    ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'العربية',
                    style: TextStyle(
                      color: currentLanguage == 'ar'
                          ? const Color(0xFF2B7FFF)
                          : null,
                      fontWeight: currentLanguage == 'ar'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (currentLanguage == 'ar')
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: Color(0xFF2B7FFF)),
                    ),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.language,
            size: 20,
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
    return Container(
      width: 50,
      height: 50,
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
            size: 20,
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
}
