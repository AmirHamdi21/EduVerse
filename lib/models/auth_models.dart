// class RegisterRequest {
//   final String email;
//   final String password;
//   final String firstName;
//   final String lastName;
//   final String? phone;
//   final int? campusId;

//   RegisterRequest({
//     required this.email,
//     required this.password,
//     required this.firstName,
//     required this.lastName,
//     this.phone,
//     this.campusId,
//   });

//   Map<String, dynamic> toJson() => {
//     'email': email,
//     'password': password,
//     'firstName': firstName,
//     'lastName': lastName,
//     if (phone != null) 'phone': phone,
//     if (campusId != null) 'campusId': campusId,
//   };
// }

// class LoginRequest {
//   final String email;
//   final String password;
//   final bool rememberMe;

//   LoginRequest({
//     required this.email,
//     required this.password,
//     this.rememberMe = false,
//   });

//   Map<String, dynamic> toJson() => {
//     'email': email,
//     'password': password,
//     'rememberMe': rememberMe,
//   };
// }

// class AuthResponse {
//   final String accessToken;
//   final String refreshToken;
//   final String tokenType;
//   final int expiresIn;
//   final UserDto user;
//   final String timestamp;

//   AuthResponse({
//     required this.accessToken,
//     required this.refreshToken,
//     required this.tokenType,
//     required this.expiresIn,
//     required this.user,
//     required this.timestamp,
//   });

//   factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
//     accessToken: json['accessToken'],
//     refreshToken: json['refreshToken'],
//     tokenType: json['tokenType'] ?? 'Bearer',
//     expiresIn: json['expiresIn'],
//     user: UserDto.fromJson(json['user']),
//     timestamp: json['timestamp'],
//   );
// }

// class UserDto {
//   final int userId;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String? phone;
//   final String? profilePictureUrl;
//   final int? campusId;
//   final String status;
//   final bool emailVerified;
//   final String? lastLoginAt;
//   final String createdAt;
//   final List<String> roles;
//   final List<String> permissions;

//   UserDto({
//     required this.userId,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     this.phone,
//     this.profilePictureUrl,
//     this.campusId,
//     required this.status,
//     required this.emailVerified,
//     this.lastLoginAt,
//     required this.createdAt,
//     required this.roles,
//     required this.permissions,
//   });

//   factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
//     userId: json['userId'],
//     email: json['email'],
//     firstName: json['firstName'],
//     lastName: json['lastName'],
//     phone: json['phone'],
//     profilePictureUrl: json['profilePictureUrl'],
//     campusId: json['campusId'],
//     status: json['status'],
//     emailVerified: json['emailVerified'] ?? false,
//     lastLoginAt: json['lastLoginAt'],
//     createdAt: json['createdAt'],
//     roles: List<String>.from(json['roles'] ?? []),
//     permissions: List<String>.from(json['permissions'] ?? []),
//   );

//   Map<String, dynamic> toJson() => {
//     'userId': userId,
//     'email': email,
//     'firstName': firstName,
//     'lastName': lastName,
//     'phone': phone,
//     'profilePictureUrl': profilePictureUrl,
//     'campusId': campusId,
//     'status': status,
//     'emailVerified': emailVerified,
//     'lastLoginAt': lastLoginAt,
//     'createdAt': createdAt,
//     'roles': roles,
//     'permissions': permissions,
//   };

//   String get fullName => '$firstName $lastName';

//   String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
// }

// class MessageResponse {
//   final String message;
//   final bool success;
//   final String timestamp;

//   MessageResponse({
//     required this.message,
//     required this.success,
//     required this.timestamp,
//   });

//   factory MessageResponse.fromJson(Map<String, dynamic> json) =>
//       MessageResponse(
//         message: json['message'],
//         success: json['success'] ?? true,
//         timestamp: json['timestamp'],
//       );
// }

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? role;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    if (phone != null) 'phone': phone,
    if (role != null) 'role': role,
  };
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'rememberMe': rememberMe,
  };
}

/// Model for a user role object returned by the backend.
/// The backend now returns roles as objects: {"roleId": 1, "roleName": "student"}
class RoleModel {
  final int roleId;
  final String roleName;

  const RoleModel({required this.roleId, required this.roleName});

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      RoleModel(roleId: json['roleId'] ?? 0, roleName: json['roleName'] ?? '');

  Map<String, dynamic> toJson() => {'roleId': roleId, 'roleName': roleName};

  @override
  String toString() => roleName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleModel &&
          runtimeType == other.runtimeType &&
          roleId == other.roleId &&
          roleName == other.roleName;

  @override
  int get hashCode => roleId.hashCode ^ roleName.hashCode;
}

/// Response from POST /api/auth/register
/// The new backend returns user + tokens upon registration.
class RegistrationResponse {
  final UserDto user;
  final String accessToken;
  final String refreshToken;

  RegistrationResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      RegistrationResponse(
        user: UserDto.fromJson(json['user']),
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
      );
}

/// Response from POST /api/auth/login
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int? expiresIn;
  final UserDto user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    expiresIn: json['expiresIn'],
    user: UserDto.fromJson(json['user']),
  );
}

/// Response from POST /api/auth/refresh-token
/// This endpoint only returns new tokens, NOT user data.
class TokenRefreshResponse {
  final String accessToken;
  final String refreshToken;
  final int? expiresIn;

  TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) =>
      TokenRefreshResponse(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        expiresIn: json['expiresIn'],
      );
}

class UserDto {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? fullName;
  final String? phone;
  final String? profilePictureUrl;
  final int? campusId;
  final String status;
  final bool emailVerified;
  final String? lastLoginAt;
  final String createdAt;
  final List<RoleModel> roles;

  UserDto({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.phone,
    this.profilePictureUrl,
    this.campusId,
    this.status = 'active',
    this.emailVerified = false,
    this.lastLoginAt,
    this.createdAt = '',
    this.roles = const [],
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Parse roles: backend sends [{roleId, roleName}] objects
    List<RoleModel> parsedRoles = [];
    if (json['roles'] != null) {
      parsedRoles = (json['roles'] as List).map((r) {
        if (r is Map<String, dynamic>) {
          return RoleModel.fromJson(r);
        }
        // Fallback: if the backend still sends a plain string in some edge case
        return RoleModel(roleId: 0, roleName: r.toString());
      }).toList();
    }

    return UserDto(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'],
      phone: json['phone'],
      profilePictureUrl: json['profilePictureUrl'],
      campusId: json['campusId'],
      status: json['status'] ?? 'active',
      emailVerified: json['emailVerified'] ?? json['isEmailVerified'] ?? false,
      lastLoginAt: json['lastLoginAt'],
      createdAt: json['createdAt'] ?? '',
      roles: parsedRoles,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName ?? '$firstName $lastName',
    'phone': phone,
    'profilePictureUrl': profilePictureUrl,
    'campusId': campusId,
    'status': status,
    'emailVerified': emailVerified,
    'lastLoginAt': lastLoginAt,
    'createdAt': createdAt,
    'roles': roles.map((r) => r.toJson()).toList(),
  };

  /// Computed full name from first + last
  String get displayName => fullName ?? '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  /// Helper: check if the user has a given role name (case-insensitive)
  bool hasRole(String roleName) =>
      roles.any((r) => r.roleName.toLowerCase() == roleName.toLowerCase());

  /// Helper: get the primary (first) role name, or 'student' as default
  String get primaryRoleName =>
      roles.isNotEmpty ? roles.first.roleName : 'student';
}

class MessageResponse {
  final String message;
  final bool success;

  MessageResponse({required this.message, required this.success});

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        message: json['message'] ?? '',
        success: json['success'] ?? true,
      );
}
