import 'package:equatable/equatable.dart';
import '../../models/auth_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Initialize app - check if user is logged in
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// Login
class LoginRequested extends AuthEvent {
  final LoginRequest request;

  const LoginRequested(this.request);

  @override
  List<Object?> get props => [request];
}

// Register
class RegisterRequested extends AuthEvent {
  final RegisterRequest request;

  const RegisterRequested(this.request);

  @override
  List<Object?> get props => [request];
}

// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// Forgot Password
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

// Reset Password
class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested(this.token, this.newPassword);

  @override
  List<Object?> get props => [token, newPassword];
}

// Verify Email
class VerifyEmailRequested extends AuthEvent {
  final String token;

  const VerifyEmailRequested(this.token);

  @override
  List<Object?> get props => [token];
}

// Resend Verification Email
class ResendVerificationEmailRequested extends AuthEvent {
  final String email;

  const ResendVerificationEmailRequested(this.email);

  @override
  List<Object?> get props => [email];
}

// Refresh User Data
class RefreshUserDataRequested extends AuthEvent {
  const RefreshUserDataRequested();
}

// Refresh Token
class RefreshTokenRequested extends AuthEvent {
  final String refreshToken;

  const RefreshTokenRequested(this.refreshToken);

  @override
  List<Object?> get props => [refreshToken];
}
