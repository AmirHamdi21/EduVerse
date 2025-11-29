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

class RegistrationResponse {
  final String message;
  final UserDto user;

  RegistrationResponse({required this.message, required this.user});

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      RegistrationResponse(
        message: json['message'] ?? '',
        user: UserDto.fromJson(json['user']),
      );
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    user: UserDto.fromJson(json['user']),
  );
}

class UserDto {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profilePictureUrl;
  final int? campusId;
  final String status;
  final bool emailVerified;
  final String? lastLoginAt;
  final String createdAt;
  final List<String> roles;

  UserDto({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profilePictureUrl,
    this.campusId,
    required this.status,
    required this.emailVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.roles,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    userId: json['userId'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    profilePictureUrl: json['profilePictureUrl'],
    campusId: json['campusId'],
    status: json['status'],
    emailVerified: json['emailVerified'] ?? false,
    lastLoginAt: json['lastLoginAt'],
    createdAt: json['createdAt'],
    roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'profilePictureUrl': profilePictureUrl,
    'campusId': campusId,
    'status': status,
    'emailVerified': emailVerified,
    'lastLoginAt': lastLoginAt,
    'createdAt': createdAt,
    'roles': roles,
  };

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}

class MessageResponse {
  final String message;
  final bool success;

  MessageResponse({required this.message, required this.success});

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        message: json['message'],
        success: json['success'] ?? true,
      );
}
