import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

class EmailVerificationScreen extends StatefulWidget {
  final String? email;

  const EmailVerificationScreen({super.key, this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  final _tokenController = TextEditingController();
  bool _isResending = false;

  late AnimationController _iconController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _tokenFieldController;
  late AnimationController _verifyButtonController;
  late AnimationController _resendButtonController;
  late AnimationController _backLinkController;

  late Animation<double> _iconFadeAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _tokenFadeAnimation;
  late Animation<Offset> _tokenSlideAnimation;
  late Animation<double> _verifyFadeAnimation;
  late Animation<Offset> _verifySlideAnimation;
  late Animation<double> _resendFadeAnimation;
  late Animation<Offset> _resendSlideAnimation;
  late Animation<double> _backLinkFadeAnimation;
  late Animation<Offset> _backLinkSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Icon animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _iconFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOut));
    _iconScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutBack),
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

    // Token field animation
    _tokenFieldController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tokenFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tokenFieldController, curve: Curves.easeOut),
    );
    _tokenSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _tokenFieldController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Verify button animation
    _verifyButtonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _verifyFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _verifyButtonController, curve: Curves.easeOut),
    );
    _verifySlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _verifyButtonController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Resend button animation
    _resendButtonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _resendFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resendButtonController, curve: Curves.easeOut),
    );
    _resendSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _resendButtonController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Back link animation
    _backLinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _backLinkFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backLinkController, curve: Curves.easeOut),
    );
    _backLinkSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _backLinkController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start cascading animations
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _titleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _subtitleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _tokenFieldController.forward();
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _verifyButtonController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _resendButtonController.forward();
    });
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) _backLinkController.forward();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _iconController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _tokenFieldController.dispose();
    _verifyButtonController.dispose();
    _resendButtonController.dispose();
    _backLinkController.dispose();
    super.dispose();
  }

  void _handleVerifyEmail() {
    final l = AppLocalizations.of(context);

    if (_tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l!.verificationCodeRequired),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      VerifyEmailRequested(_tokenController.text.trim()),
    );
  }

  void _handleResendEmail() {
    final l = AppLocalizations.of(context);

    if (widget.email == null || widget.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l!.emailNotFound),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isResending = true);
    context.read<AuthBloc>().add(
      ResendVerificationEmailRequested(widget.email!),
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
              content: Text(l!.emailVerifiedSuccessfully),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/dashboard');
        } else if (state is AuthOperationSuccess) {
          setState(() => _isResending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          setState(() => _isResending = false);
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
                  // Decorative circles
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
                                  ? AppTheme.darkCardColor.withValues(
                                      alpha: 0.7,
                                    )
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(
                                responsive.radius24,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 50,
                                  offset: const Offset(0, 25),
                                  spreadRadius: -12,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon with animation
                                FadeTransition(
                                  opacity: _iconFadeAnimation,
                                  child: ScaleTransition(
                                    scale: _iconScaleAnimation,
                                    child: Container(
                                      width: responsive.aspectRatioWidth(80),
                                      height: responsive.aspectRatioHeight(80),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF50A2FF),
                                            Color(0xFF155CFB),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 4),
                                            spreadRadius: -4,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.mail_outline,
                                        color: Colors.white,
                                        size: responsive.iconLarge,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.p32),
                                // Title with animation
                                FadeTransition(
                                  opacity: _titleFadeAnimation,
                                  child: SlideTransition(
                                    position: _titleSlideAnimation,
                                    child: Text(
                                      l.verifyEmailTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: responsive.fontSize24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.p12),
                                // Subtitle with animation
                                FadeTransition(
                                  opacity: _subtitleFadeAnimation,
                                  child: SlideTransition(
                                    position: _subtitleSlideAnimation,
                                    child: Text(
                                      widget.email != null
                                          ? '${l.verifyEmailSubtitle}\n${widget.email}'
                                          : l.verifyEmailSubtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: textSecondaryColor,
                                        fontSize: responsive.fontSize16,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.p32),
                                // Token field with animation
                                FadeTransition(
                                  opacity: _tokenFadeAnimation,
                                  child: SlideTransition(
                                    position: _tokenSlideAnimation,
                                    child: _buildTextField(
                                      context: context,
                                      controller: _tokenController,
                                      hint: l.verificationCodeHint,
                                      icon: Icons.vpn_key_outlined,
                                      isDark: isDark,
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.p24),
                                // Verify button with animation
                                FadeTransition(
                                  opacity: _verifyFadeAnimation,
                                  child: SlideTransition(
                                    position: _verifySlideAnimation,
                                    child: BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        final isLoading = state is AuthLoading;
                                        return SizedBox(
                                          width: double.infinity,
                                          height: responsive.buttonHeight,
                                          child: ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : _handleVerifyEmail,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                gradient: isLoading
                                                    ? null
                                                    : const LinearGradient(
                                                        colors: [
                                                          Color(0xFF00D2F2),
                                                          Color(0xFF2B7FFF),
                                                          Color(0xFF1347E5),
                                                        ],
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: isLoading
                                                    ? null
                                                    : [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                          spreadRadius: -4,
                                                        ),
                                                      ],
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
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
                                                        l.verifyButton,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: responsive
                                                              .fontSize16,
                                                          fontWeight:
                                                              FontWeight.w400,
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
                                // Resend button with animation
                                FadeTransition(
                                  opacity: _resendFadeAnimation,
                                  child: SlideTransition(
                                    position: _resendSlideAnimation,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${l.enterVerificationCode}? ",
                                          style: TextStyle(
                                            color: textSecondaryColor,
                                            fontSize: responsive.fontSize16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            return TextButton(
                                              onPressed: _isResending
                                                  ? null
                                                  : _handleResendEmail,
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                l.resendCodeButton,
                                                style: TextStyle(
                                                  color: _isResending
                                                      ? Colors.grey
                                                      : const Color(0xFF2B7FFF),
                                                  fontSize:
                                                      responsive.fontSize16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsive.p16),
                                // Back to login with animation
                                FadeTransition(
                                  opacity: _backLinkFadeAnimation,
                                  child: SlideTransition(
                                    position: _backLinkSlideAnimation,
                                    child: TextButton(
                                      onPressed: () => context.go('/login'),
                                      child: Text(
                                        'Back to Login',
                                        style: TextStyle(
                                          color: textSecondaryColor,
                                          fontSize: responsive.fontSize14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
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
      style: TextStyle(
        color: textColor,
        fontSize: responsive.fontSize16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: responsive.fontSize16),
        prefixIcon: Icon(icon, color: hintColor, size: responsive.iconSmall),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.p16,
          vertical: responsive.p16,
        ),
      ),
    );
  }
}
