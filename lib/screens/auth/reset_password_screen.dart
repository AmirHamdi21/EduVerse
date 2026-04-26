import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../common/utils/responsive.dart';
import '../../generated_l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordScreen({super.key, this.initialToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar(l10n.passwordsDontMatch, isError: true);
      return;
    }

    context.read<AuthBloc>().add(
      ResetPasswordRequested(
        _tokenController.text.trim(),
        _newPasswordController.text,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOperationSuccess) {
          _showSnackBar(state.message);
          context.go('/login');
        } else if (state is AuthError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.p24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: EdgeInsets.all(responsive.p24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(responsive.radius24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.lock_reset_rounded,
                          size: responsive.iconLarge,
                          color: const Color(0xFF2B7FFF),
                        ),
                        SizedBox(height: responsive.p16),
                        Text(
                          'Reset Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: responsive.fontSize24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: responsive.p8),
                        Text(
                          'Enter the reset token from your email and choose a new password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: responsive.fontSize14,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: responsive.p24),
                        _buildField(
                          controller: _tokenController,
                          hint: 'Reset token',
                          icon: Icons.vpn_key_outlined,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return l10n.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsive.p16),
                        _buildField(
                          controller: _newPasswordController,
                          hint: l10n.newPassword,
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureNewPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return l10n.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsive.p16),
                        _buildField(
                          controller: _confirmPasswordController,
                          hint: l10n.confirmPassword,
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return l10n.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsive.p24),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return SizedBox(
                              height: responsive.buttonHeight,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2B7FFF),
                                  foregroundColor: Colors.white,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Reset Password'),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.p12),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(l10n.signIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final responsive = context.responsive;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 2),
        ),
      ),
    );
  }
}
