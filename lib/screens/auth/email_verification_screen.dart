import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;

  const EmailVerificationScreen({super.key, this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _tokenController = TextEditingController();
  bool _isResending = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _handleVerifyEmail() {
    if (_tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Color(0xFFEF4444),
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
    if (widget.email == null || widget.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address not found'),
          backgroundColor: Color(0xFFEF4444),
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Color(0xFF10B981),
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
                  // Decorative circles (only in light mode)
                  // if (!isDark) ...[
                  Positioned(
                    left: 40,
                    top: 80,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 286,
                        height: 286,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8EC5FF),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 45,
                    top: 193,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDAB2FF),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 96,
                    top: 531,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 317,
                        height: 317,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3B3FF),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 107,
                    top: 372,
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 178,
                        height: 178,
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
                    left: 179,
                    top: 456,
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 116,
                        height: 116,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkCardColor.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 50,
                                  offset: const Offset(0, 25),
                                  spreadRadius: -12,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon
                                Container(
                                  width: 80,
                                  height: 80,
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
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                        spreadRadius: -4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mail_outline,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Title
                                Text(
                                  'Verify Your Email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Subtitle
                                Text(
                                  widget.email != null
                                      ? 'We sent a verification code to\n${widget.email}'
                                      : 'Enter the verification code sent to your email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Token field
                                _buildTextField(
                                  controller: _tokenController,
                                  hint: 'Enter verification code',
                                  icon: Icons.vpn_key_outlined,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 24),
                                // Verify button
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : _handleVerifyEmail,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            boxShadow: isLoading
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
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
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Verify Email',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
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
                                const SizedBox(height: 24),
                                // Resend button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Didn't receive the code? ",
                                      style: TextStyle(
                                        color: textSecondaryColor,
                                        fontSize: 16,
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
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Resend',
                                            style: TextStyle(
                                              color: _isResending
                                                  ? Colors.grey
                                                  : const Color(0xFF2B7FFF),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Back to login
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: textSecondaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
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
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
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
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 16),
        prefixIcon: Icon(icon, color: hintColor, size: 20),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
