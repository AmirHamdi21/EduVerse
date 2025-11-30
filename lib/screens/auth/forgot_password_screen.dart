import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/language/language_cubit.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendReset() {
    final l = AppLocalizations.of(context);
    
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _emailSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l!.passwordResetSent),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
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
                // Top right icons
                Positioned(
                  right: 16,
                  top: 48,
                  child: Row(
                    children: [
                      _buildTopIcon(Icons.language, isDark),
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
                                ? AppTheme.darkCardColor.withOpacity(0.6)
                                : Colors.white.withOpacity(0.6),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo
                                Container(
                                  width: 100,
                                  height: 100,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    "assets/images/logo.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Title
                                Text(
                                  l.forgotPasswordTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Subtitle
                                Text(
                                  l.forgotPasswordSubtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Email field
                                _buildTextField(
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
                                const SizedBox(height: 32),
                                // Send reset link button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _emailSent
                                        ? null
                                        : _handleSendReset,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF00D2F2),
                                            Color(0xFF2B7FFF),
                                            Color(0xFF1347E5),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: _emailSent
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Link Sent!',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                l.resetPasswordButton,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Back to login
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${l.alreadyHaveAccount} ',
                                      style: TextStyle(
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: Text(
                                        l.signIn,
                                        style: const TextStyle(
                                          color: Color(0xFF2B7FFF),
                                          fontWeight: FontWeight.w600,
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
                // Top right icons
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
    );
  }

  Widget _buildLanguageSwitchIcon(
    BuildContext context,
    String currentLanguage,
    bool isDark,
  ) {
    return Container(
      width: 50,
      height: 50,
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

  Widget _buildTopIcon(IconData icon, bool isDark) {
    return Container(
      width: 50,
      height: 50,
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
      child: Icon(
        icon,
        size: 20,
        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF354152),
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
    String? Function(String?)? validator,
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
      validator: validator,
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
