// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/auth_models.dart';
// import 'storage_service.dart';

// class ApiService {
//   // Change this to your backend URL
//   static const String baseUrl =
//       'http://192.168.1.4:8081/api'; // Android emulator
//   // For iOS simulator use: 'http://localhost:8081/api'
//   // For real device use your computer's IP: 'http://192.168.x.x:8081/api'

//   final StorageService _storage = StorageService();

//   // Get headers with authorization token
//   Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     if (includeAuth) {
//       final token = await _storage.getAccessToken();
//       if (token != null) {
//         headers['Authorization'] = 'Bearer $token';
//       }
//     }

//     return headers;
//   }

//   // Register new user
//   Future<AuthResponse> register(RegisterRequest request) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/register'),
//         headers: await _getHeaders(),
//         body: jsonEncode(request.toJson()),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return AuthResponse.fromJson(jsonDecode(response.body));
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Registration failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Login user
//   Future<AuthResponse> login(LoginRequest request) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: await _getHeaders(),
//         body: jsonEncode(request.toJson()),
//       );

//       if (response.statusCode == 200) {
//         return AuthResponse.fromJson(jsonDecode(response.body));
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Login failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Forgot password
//   Future<MessageResponse> forgotPassword(String email) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password'),
//         headers: await _getHeaders(),
//         body: jsonEncode({'email': email}),
//       );

//       if (response.statusCode == 200) {
//         return MessageResponse.fromJson(jsonDecode(response.body));
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Request failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Reset password
//   Future<MessageResponse> resetPassword(
//     String token,
//     String newPassword,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/reset-password'),
//         headers: await _getHeaders(),
//         body: jsonEncode({'token': token, 'newPassword': newPassword}),
//       );

//       if (response.statusCode == 200) {
//         return MessageResponse.fromJson(jsonDecode(response.body));
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Reset failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Verify email
//   Future<MessageResponse> verifyEmail(String token) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/verify-email'),
//         headers: await _getHeaders(),
//         body: jsonEncode({'token': token}),
//       );

//       if (response.statusCode == 200) {
//         return MessageResponse.fromJson(jsonDecode(response.body));
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Verification failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Get current user
//   Future<UserDto> getCurrentUser() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/auth/me'),
//         headers: await _getHeaders(includeAuth: true),
//       );

//       if (response.statusCode == 200) {
//         return UserDto.fromJson(jsonDecode(response.body));
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Failed to get user data');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Refresh token
//   Future<AuthResponse> refreshToken(String refreshToken) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/refresh-token'),
//         headers: await _getHeaders(),
//         body: jsonEncode({'refreshToken': refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         return AuthResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Token refresh failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }

//   // Logout
//   Future<MessageResponse> logout() async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/logout'),
//         headers: await _getHeaders(includeAuth: true),
//       );

//       if (response.statusCode == 200) {
//         return MessageResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Logout failed');
//       }
//     } catch (e) {
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }
// }

import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'storage_service.dart';
import 'auth_interceptor.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:8081/api'; // Android emulator
  // For iOS simulator use: 'http://localhost:8081/api'
  // For real device use your computer's IP: 'http://192.168.1.11:8081/api'
  //'http://10.0.2.2:8081/api';
  // https://awab-elsadig-eduverse-backend.hf.space
  final StorageService _storage = StorageService();
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add the auth interceptor for automatic token management
    _dio.interceptors.add(
      AuthInterceptor(dio: _dio, storage: _storage, baseUrl: baseUrl),
    );
  }

  /// Helper to extract a clean error message from Dio errors
  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'].toString();
    }
    return fallback;
  }

  // Register new user
  Future<RegistrationResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegistrationResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Registration failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Login failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Forgot password
  Future<MessageResponse> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(response.data);
      } else {
        throw Exception('Request failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Request failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Reset password
  Future<MessageResponse> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(response.data);
      } else {
        throw Exception('Reset failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Reset failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Verify email
  Future<MessageResponse> verifyEmail(String token) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(response.data);
      } else {
        throw Exception('Verification failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Verification failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get current user
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        return UserDto.fromJson(response.data);
      } else {
        throw Exception('Failed to get user data');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to get user data'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Refresh token
  Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return TokenRefreshResponse.fromJson(response.data);
      } else {
        throw Exception('Token refresh failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Token refresh failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Resend verification email
  Future<MessageResponse> resendVerificationEmail(String email) async {
    try {
      final response = await _dio.post(
        '/auth/resend-verification-email',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(response.data);
      } else {
        throw Exception('Resend verification failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Resend verification failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Logout
  Future<MessageResponse> logout(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(response.data);
      } else {
        throw Exception('Logout failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Logout failed'));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Try to login to verify email is registered and verified
  Future<bool> isEmailVerifiedAndExists(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return true; // Email exists and is verified
      } else {
        return false;
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, '');

      // Check if error is specifically about verification
      if (message.toLowerCase().contains('verify')) {
        throw Exception('Email not verified');
      } else {
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register and check if email already exists during response
  Future<RegistrationResponse> registerAndCheckEmail(
    RegisterRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegistrationResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Registration failed');

      // Check for email already exists error
      if (message.toLowerCase().contains('already exists') ||
          message.toLowerCase().contains('already registered')) {
        throw Exception('Email already registered');
      } else {
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Check if email exists for password reset
  Future<bool> emailExistsForPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/auth/resend-verification-email',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return true; // Email exists in system
      } else {
        return false;
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, '');

      if (message.toLowerCase().contains('not found')) {
        return false; // Email doesn't exist
      } else {
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
