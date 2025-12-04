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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import 'storage_service.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl =
      'http://192.168.1.4:8081/api'; // Android emulator
  // For iOS simulator use: 'http://localhost:8081/api'
  // For real device use your computer's IP: 'http://192.168.x.x:8081/api'

  final StorageService _storage = StorageService();

  // Get headers with authorization token
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Register new user
  Future<RegistrationResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegistrationResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Forgot password
  Future<MessageResponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Request failed');
      }
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: await _getHeaders(),
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Reset failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Verify email
  Future<MessageResponse> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: await _getHeaders(),
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Verification failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get current user
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        return UserDto.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get user data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: await _getHeaders(),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Resend verification email
  Future<MessageResponse> resendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification-email'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Resend verification failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Logout
  Future<MessageResponse> logout(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        return MessageResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Try to login to verify email is registered and verified
  // If login fails due to unverified email, returns specific error
  // This leverages the backend's existing login validation
  Future<bool> isEmailVerifiedAndExists(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return true; // Email exists and is verified
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? '';
        
        // Check if error is specifically about verification
        if (message.toLowerCase().contains('verify')) {
          throw Exception('Email not verified');
        } else {
          throw Exception(message);
        }
      }
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  // Register and check if email already exists during response
  Future<RegistrationResponse> registerAndCheckEmail(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegistrationResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Registration failed';
        
        // Check for email already exists error
        if (message.toLowerCase().contains('already exists') || 
            message.toLowerCase().contains('already registered')) {
          throw Exception('Email already registered');
        } else {
          throw Exception(message);
        }
      }
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }

  // Check if email exists for password reset
  // Since backend doesn't have a dedicated endpoint, we'll use register check
  // or return a generic message if the resend endpoint fails
  Future<bool> emailExistsForPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification-email'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true; // Email exists in system
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? '';
        
        if (message.toLowerCase().contains('not found')) {
          return false; // Email doesn't exist
        } else {
          throw Exception(message);
        }
      }
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }
}
