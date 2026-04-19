import 'package:equatable/equatable.dart';

class PublicProfileModel extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? role;
  final String? bio;
  final String? profileImageUrl;
  final String? officeLocation;

  const PublicProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role,
    this.bio,
    this.profileImageUrl,
    this.officeLocation,
  });

  String get fullName {
    final value = '$firstName $lastName'.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return 'User #$userId';
  }

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return PublicProfileModel(
      userId: _parseInt(data['userId'] ?? data['id']),
      firstName: _asString(data['firstName']),
      lastName: _asString(data['lastName']),
      email: _asString(data['email']),
      role: _nullableString(data['role'] ?? data['userType']),
      bio: _nullableString(data['bio']),
      profileImageUrl: _nullableString(
        data['profileImageUrl'] ?? data['avatarUrl'],
      ),
      officeLocation: _nullableString(
        data['officeLocation'] ?? data['office'] ?? data['location'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'officeLocation': officeLocation,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    userId,
    firstName,
    lastName,
    email,
    role,
    bio,
    profileImageUrl,
    officeLocation,
  ];
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) {
  final result = value?.toString().trim() ?? '';
  return result;
}

String? _nullableString(dynamic value) {
  final result = value?.toString().trim() ?? '';
  if (result.isEmpty) {
    return null;
  }
  return result;
}
