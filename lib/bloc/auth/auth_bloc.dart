// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../services/api_service.dart';
// import '../../services/storage_service.dart';
// import 'auth_event.dart';
// import 'auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final ApiService _apiService;
//   final StorageService _storageService;

//   AuthBloc({
//     required ApiService apiService,
//     required StorageService storageService,
//   }) : _apiService = apiService,
//        _storageService = storageService,
//        super(const AuthInitial()) {
//     // Register event handlers
//     on<AuthCheckRequested>(_onAuthCheckRequested);
//     on<LoginRequested>(_onLoginRequested);
//     on<RegisterRequested>(_onRegisterRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//     on<ForgotPasswordRequested>(_onForgotPasswordRequested);
//     on<ResetPasswordRequested>(_onResetPasswordRequested);
//     on<VerifyEmailRequested>(_onVerifyEmailRequested);
//     on<RefreshUserDataRequested>(_onRefreshUserDataRequested);
//     on<RefreshTokenRequested>(_onRefreshTokenRequested);
//   }

//   // Check if user is already logged in
//   Future<void> _onAuthCheckRequested(
//     AuthCheckRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     try {
//       final isLoggedIn = await _storageService.isLoggedIn();
//       if (isLoggedIn) {
//         final user = await _storageService.getUserData();
//         if (user != null) {
//           emit(AuthAuthenticated(user));
//         } else {
//           emit(const AuthUnauthenticated());
//         }
//       } else {
//         emit(const AuthUnauthenticated());
//       }
//     } catch (e) {
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // Login
//   Future<void> _onLoginRequested(
//     LoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading());
//     try {
//       final response = await _apiService.login(event.request);

//       // Save tokens and user data
//       await _storageService.saveTokens(
//         response.accessToken,
//         response.refreshToken,
//       );
//       await _storageService.saveUserData(response.user);

//       emit(AuthAuthenticated(response.user));
//     } catch (e) {
//       emit(AuthError(e.toString().replaceAll('Exception: ', '')));
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // Register
//   Future<void> _onRegisterRequested(
//     RegisterRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading());
//     try {
//       final response = await _apiService.register(event.request);

//       // Save tokens and user data
//       await _storageService.saveTokens(
//         response.accessToken,
//         response.refreshToken,
//       );
//       await _storageService.saveUserData(response.user);

//       // Check if email verification is needed
//       if (!response.user.emailVerified) {
//         emit(AuthEmailVerificationNeeded(response.user));
//       } else {
//         emit(AuthAuthenticated(response.user));
//       }
//     } catch (e) {
//       emit(AuthError(e.toString().replaceAll('Exception: ', '')));
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // Logout
//   Future<void> _onLogoutRequested(
//     LogoutRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     try {
//       await _apiService.logout();
//     } catch (e) {
//       // Continue with logout even if API call fails
//     } finally {
//       await _storageService.clearAll();
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // Forgot Password
//   Future<void> _onForgotPasswordRequested(
//     ForgotPasswordRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading());
//     try {
//       final response = await _apiService.forgotPassword(event.email);
//       emit(AuthOperationSuccess(response.message));

//       // Return to previous state after showing success
//       final currentUser = await _storageService.getUserData();
//       if (currentUser != null) {
//         emit(AuthAuthenticated(currentUser));
//       } else {
//         emit(const AuthUnauthenticated());
//       }
//     } catch (e) {
//       emit(AuthError(e.toString().replaceAll('Exception: ', '')));

//       // Return to previous state
//       final currentUser = await _storageService.getUserData();
//       if (currentUser != null) {
//         emit(AuthAuthenticated(currentUser));
//       } else {
//         emit(const AuthUnauthenticated());
//       }
//     }
//   }

//   // Reset Password
//   Future<void> _onResetPasswordRequested(
//     ResetPasswordRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading());
//     try {
//       final response = await _apiService.resetPassword(
//         event.token,
//         event.newPassword,
//       );
//       emit(AuthOperationSuccess(response.message));
//       emit(const AuthUnauthenticated());
//     } catch (e) {
//       emit(AuthError(e.toString().replaceAll('Exception: ', '')));
//       emit(const AuthUnauthenticated());
//     }
//   }

//   // Verify Email
//   Future<void> _onVerifyEmailRequested(
//     VerifyEmailRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading());
//     try {
//       final response = await _apiService.verifyEmail(event.token);
//       emit(AuthOperationSuccess(response.message));

//       // Refresh user data after verification
//       final currentUser = await _storageService.getUserData();
//       if (currentUser != null) {
//         emit(AuthAuthenticated(currentUser));
//       } else {
//         emit(const AuthUnauthenticated());
//       }
//     } catch (e) {
//       emit(AuthError(e.toString().replaceAll('Exception: ', '')));

//       final currentUser = await _storageService.getUserData();
//       if (currentUser != null) {
//         emit(AuthAuthenticated(currentUser));
//       } else {
//         emit(const AuthUnauthenticated());
//       }
//     }
//   }

//   // Refresh User Data
//   Future<void> _onRefreshUserDataRequested(
//     RefreshUserDataRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     try {
//       final user = await _apiService.getCurrentUser();
//       await _storageService.saveUserData(user);
//       emit(AuthAuthenticated(user));
//     } catch (e) {
//       // Keep current state if refresh fails
//     }
//   }

//   // Refresh Token
//   Future<void> _onRefreshTokenRequested(
//     RefreshTokenRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     try {
//       final response = await _apiService.refreshToken(event.refreshToken);
//       await _storageService.saveTokens(
//         response.accessToken,
//         response.refreshToken,
//       );
//       await _storageService.saveUserData(response.user);
//       emit(AuthAuthenticated(response.user));
//     } catch (e) {
//       // Token refresh failed, logout
//       await _storageService.clearAll();
//       emit(const AuthUnauthenticated());
//     }
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthBloc({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService,
       super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<RefreshUserDataRequested>(_onRefreshUserDataRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  // Check if user is already logged in
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _storageService.getUserData();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  // Login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _apiService.login(event.request);

      // Save tokens and user data
      await _storageService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await _storageService.saveUserData(response.user);

      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  // Register
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _apiService.register(event.request);

      // After registration, user needs to verify email before login
      // Backend returns user with emailVerified = false and status = PENDING
      // Do NOT save tokens - user must verify email first
      emit(AuthEmailVerificationNeeded(response.user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  // Logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Get refresh token before clearing storage
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        await _apiService.logout(refreshToken);
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _storageService.clearAll();
      emit(const AuthUnauthenticated());
    }
  }

  // Forgot Password
  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _apiService.forgotPassword(event.email);
      emit(AuthOperationSuccess(response.message));

      // Return to previous state after showing success
      final currentUser = await _storageService.getUserData();
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));

      // Return to previous state
      final currentUser = await _storageService.getUserData();
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    }
  }

  // Reset Password
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _apiService.resetPassword(
        event.token,
        event.newPassword,
      );
      emit(AuthOperationSuccess(response.message));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  // Verify Email
  Future<void> _onVerifyEmailRequested(
    VerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _apiService.verifyEmail(event.token);

      // After verification, refresh user data from server
      final user = await _apiService.getCurrentUser();
      await _storageService.saveUserData(user);

      emit(AuthOperationSuccess(response.message));
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));

      final currentUser = await _storageService.getUserData();
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    }
  }

  // Resend Verification Email
  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _apiService.resendVerificationEmail(event.email);
      emit(AuthOperationSuccess(response.message));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthUnauthenticated());
    }
  }

  // Refresh User Data
  Future<void> _onRefreshUserDataRequested(
    RefreshUserDataRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _apiService.getCurrentUser();
      await _storageService.saveUserData(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Keep current state if refresh fails
    }
  }

  // Refresh Token
  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await _apiService.refreshToken(event.refreshToken);
      await _storageService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await _storageService.saveUserData(response.user);
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      // Token refresh failed, logout
      await _storageService.clearAll();
      emit(const AuthUnauthenticated());
    }
  }
}
