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
import '../../config/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  final List<String> _roles = ['student', 'instructor', 'ta', 'admin'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final request = RegisterRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    context.read<AuthBloc>().add(RegisterRequested(request));
    _formKey.currentState!.save();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    context.go('/verify-email');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go('/verify-email', extra: _emailController.text.trim());
            }
          });
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
                                    'Create Account',
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
                                    'Join EduVerse and start learning',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // First name field
                                  _buildTextField(
                                    controller: _firstNameController,
                                    hint: 'First Name',
                                    icon: Icons.person_outline,
                                    isDark: isDark,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Last name field
                                  _buildTextField(
                                    controller: _lastNameController,
                                    hint: 'Last Name',
                                    icon: Icons.person_outline,
                                    isDark: isDark,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  _buildTextField(
                                    controller: _emailController,
                                    hint: 'Email',
                                    icon: Icons.email_outlined,
                                    isDark: isDark,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Password field
                                  _buildTextField(
                                    controller: _passwordController,
                                    hint: 'Password',
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
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Confirm password field
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    hint: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: textSecondaryColor,
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
                                        return 'Please confirm your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Phone field
                                  _buildTextField(
                                    controller: _phoneController,
                                    hint: 'Phone Number',
                                    icon: Icons.phone_outlined,
                                    isDark: isDark,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Role selection dropdown
                                  _buildRoleDropdown(
                                    isDark,
                                    textColor,
                                    textSecondaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  // Terms checkbox
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF2B7FFF),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'I agree to the Terms and Conditions',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Register button
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      final isLoading = state is AuthLoading;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
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
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Center(
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
                                                      'Create Account',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
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
                                  const SizedBox(height: 16),
                                  // Sign in
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
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
  ) {
    final fillColor = isDark ? AppTheme.darkCardColor : const Color(0xFFF9FAFB);
    final borderColor = isDark
        ? const Color(0xFF404756)
        : const Color(0xFFE5E7EB);

    return DropdownButtonFormField<String>(
      value: _selectedRole,
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a role';
        }
        return null;
      },
      items: _roles.map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(
            role[0].toUpperCase() + role.substring(1),
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Role',
        labelStyle: TextStyle(color: textSecondaryColor, fontSize: 16),
        prefixIcon: Icon(Icons.school_outlined, color: textSecondaryColor),
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
      dropdownColor: isDark ? AppTheme.darkCardColor : Colors.white,
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
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
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
      obscureText: obscureText,
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
        suffixIcon: suffixIcon,
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
