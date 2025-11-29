import 'package:equatable/equatable.dart';
import '../../models/auth_models.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

// Authenticated state
class AuthAuthenticated extends AuthState {
  final UserDto user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Success states for specific operations
class AuthOperationSuccess extends AuthState {
  final String message;

  const AuthOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Email verification needed
class AuthEmailVerificationNeeded extends AuthState {
  final UserDto user;

  const AuthEmailVerificationNeeded(this.user);

  @override
  List<Object?> get props => [user];
}
