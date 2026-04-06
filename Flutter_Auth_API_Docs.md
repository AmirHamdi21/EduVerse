# EduVerse API - Authentication Documentation for Flutter

This document provides comprehensive details on the Authentication endpoints (`Register`, `Login`, `Refresh Token`, `Get Me`, and `Logout`). It is specifically designed to aid in the integration of the Flutter application, complete with expected request shapes, response formats, and Flutter/Dart implementation tips based on the backend DTO representations.

---

## Base URL Configuration

Ensure you have the Base URL dynamically configured depending on your environment.
- **Local Dev (Android Emulator)**: `http://10.0.2.2:8081` (Maps to your PC's `localhost:8081`)
- **Local Dev (iOS Simulator / Web)**: `http://localhost:8081`
- **Local Dev (Physical Device)**: `http://<YOUR_LOCAL_IP>:8081`
- **Production**: `<PRODUCTION_URL>`

## General Headers
For all endpoints except public ones, the JWT `accessToken` must be passed in the `Authorization` header as follows:
```text
Authorization: Bearer <your_access_token>
```

---

## 1. Register User

**Endpoint:** `POST /api/auth/register`
**Access:** Public
**Description:** Creates a new user account. The default backend role is `student` unless explicitly provided.

### Request Body (`RegisterRequestDto`)
```json
{
  "email": "student@example.com",     // Required: Valid email string
  "password": "SecureP@ss123",        // Required: Min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char (@$!%*?&)
  "firstName": "John",                // Required: String (2-50 chars)
  "lastName": "Doe",                  // Required: String (2-50 chars)
  "phone": "+1234567890",             // Optional: International phone number format
  "role": "student"                   // Optional: Enum ('student', 'instructor', 'ta', 'admin', 'it_admin')
}
```

### Success Response (HTTP 201 Created)
Returns the created user data along with the session tokens.

```json
{
  "user": {
    "userId": 1,
    "email": "student@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "isEmailVerified": false,
    "roles": [{"roleName": "student"}]
  },
  "accessToken": "eyJhbG...",
  "refreshToken": "eyJhbG..."
}
```

### Error Responses
- **400 Bad Request**: Invalid body payload or password requirements not met. Check validation errors in JSON.
- **409 Conflict**: User with this email already exists.

---

## 2. Login

**Endpoint:** `POST /api/auth/login`
**Access:** Public
**Description:** Authenticates a user and returns a short-lived `accessToken` and a long-lived `refreshToken`.

### Request Body (`LoginRequestDto`)
```json
{
  "email": "student@example.com", // Required: Valid email string
  "password": "SecureP@ss123",    // Required: Password string
  "rememberMe": true              // Optional: Extends refresh token expiry (e.g. from 7 to 30 days)
}
```

### Success Response (HTTP 200 OK)
Returns user data, tokens, and token expiration data.

```json
{
  "user": {
    "userId": 1,
    "email": "student@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "roles": [
      {
        "roleId": 1,
        "roleName": "student"
      }
    ]
  },
  "accessToken": "eyJhbG...",
  "refreshToken": "eyJhbG...",
  "expiresIn": 900 // Expiration of access token in seconds (usually 15 minutes)
}
```

### Error Responses
- **400 Bad Request**: Invalid credentials (wrong password or email).
- **401 Unauthorized**: Account is disabled.

---

## 3. Refresh Token

**Endpoint:** `POST /api/auth/refresh-token`
**Access:** Public (uses the `refreshToken` in the body instead of a Bearer token)
**Description:** Generates a new `accessToken` when the current one has expired.

### Request Body (`TokenRefreshRequestDto`)
```json
{
  "refreshToken": "eyJhbG..." // Required: The persistent refresh token
}
```

### Success Response (HTTP 200 OK)
Returns fresh tokens. Note that the backend might also rotate (provide a new) refresh token. Always update both tokens in your local secure storage.

```json
{
  "accessToken": "new_eyJhbG...",
  "refreshToken": "new_or_same_eyJhbG...",
  "expiresIn": 900
}
```

### Error Responses
- **401 Unauthorized**: Invalid or expired refresh token. If you receive this, the session is permanently dead. Force the user to log out and return to the Login Screen.

---

## 4. Get Current User (Me)

**Endpoint:** `GET /api/auth/me`
**Access:** Protected (Requires `Bearer accessToken`)
**Description:** Retrieves the complete profile of the currently authenticated user. Highly recommended to use this during application startup to verify the session and hydrate the BLoC/State.

### Request
No body required. Must include Header:
```text
Authorization: Bearer <accessToken>
```

### Success Response (HTTP 200 OK)
```json
{
  "userId": 1,
  "email": "student@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "fullName": "John Doe",
  "phone": "+1234567890",
  "status": "active",
  "emailVerified": true,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "roles": [
    {
      "roleId": 1,
      "roleName": "student"
    }
  ]
}
```

### Error Responses
- **401 Unauthorized**: Invalid or expired token. If this happens organically during app use, your local interceptor should automatically request `/api/auth/refresh-token` before showing an error.

---

## 5. Logout

**Endpoint:** `POST /api/auth/logout`
**Access:** Protected (Requires `Bearer accessToken`)
**Description:** Invalidates the backend session to prevent token reuse.

### Request Body
Must include Header:
```text
Authorization: Bearer <accessToken>
```
Body:
```json
{
  "refreshToken": "eyJhbG..." // Required: Invalidates this specific token on backend
}
```

### Success Response (HTTP 200 OK)
```json
{
  "message": "Logged out successfully"
}
```

---

## Flutter & Dart Implementation Tips

To assist you on the frontend side, here are recommended approaches for implementing this flow in Flutter:

### 1. Data Models (Using `freezed` & `json_serializable`)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int userId,
    required String email,
    required String firstName,
    required String lastName,
    String? fullName,
    String? phone,
    required String status,
    @Default(false) bool emailVerified,
    @Default([]) List<RoleModel> roles,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

@freezed
class RoleModel with _$RoleModel {
  const factory RoleModel({
    required int roleId,
    required String roleName,
  }) = _RoleModel;

  factory RoleModel.fromJson(Map<String, dynamic> json) => _$RoleModelFromJson(json);
}
```

### 2. Dio Interceptor for Token Refresh Flow

Since the `accessToken` expires quickly (15 mins), you need an automated process to refresh the token mid-flight. Using a `Dio` interceptor is the standard and most resilient way:

```dart
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageRepository storage; // Your implementation of flutter_secure_storage
  
  AuthInterceptor(this.dio, this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the server tells us our token is invalid (401)
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/login')) {
      final refreshToken = await storage.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Attempt to fetch a new token
          final response = await dio.post('/api/auth/refresh-token', data: {
            'refreshToken': refreshToken,
          });
          
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];

          // Save new tokens locally
          await storage.saveTokens(
            accessToken: newAccessToken, 
            refreshToken: newRefreshToken
          );

          // Retry the failed request with the new access token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          // Re-fetch failed request
          final cloneReq = await dio.fetch(requestOptions);
          return handler.resolve(cloneReq);
        } catch (e) {
          // Refresh token failed or is expired -> Fully Log Out user
          await storage.clearAll();
          // TODO: Yield an unauthenticated state in your AuthBloc or dispatch a logout event.
          return handler.next(err);
        }
      }
    }
    
    return handler.next(err);
  }
}
```
