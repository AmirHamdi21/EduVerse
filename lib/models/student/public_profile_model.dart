import 'package:equatable/equatable.dart';

import '../auth_models.dart';
import '../../bloc/profile/profile_models.dart';

class PublicProfileModel extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String? _fullName;
  final String email;
  final String? role;
  final List<RoleModel> roles;
  final String? bio;
  final String? profilePictureUrl;
  final String? officeLocation;
  final SocialLinks socialLinks;
  final List<String> academicInterests;
  final List<String> skills;

  const PublicProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    String? fullName,
    required this.email,
    this.role,
    this.roles = const <RoleModel>[],
    this.bio,
    this.profilePictureUrl,
    this.officeLocation,
    this.socialLinks = const SocialLinks(),
    this.academicInterests = const <String>[],
    this.skills = const <String>[],
  }) : _fullName = fullName;

  String get displayName {
    final resolved = _fullName?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    final combined = '$firstName $lastName'.trim();
    if (combined.isNotEmpty) {
      return combined;
    }

    return 'User #$userId';
  }

  String get initials {
    final name = displayName.trim();
    if (name.isEmpty) {
      return 'U';
    }

    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }

    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return '$first$second'.toUpperCase();
  }

  String get primaryRoleLabel {
    final explicitRole = role?.trim();
    if (explicitRole != null && explicitRole.isNotEmpty) {
      return explicitRole;
    }

    if (roles.isEmpty) {
      return 'Course Instructor';
    }

    final raw = roles.first.roleName.trim().toLowerCase();
    switch (raw) {
      case 'student':
        return 'Student';
      case 'instructor':
        return 'Instructor';
      case 'ta':
      case 'teaching_assistant':
        return 'Teaching Assistant';
      case 'admin':
        return 'Administrator';
      case 'it_admin':
        return 'IT Administrator';
      default:
        return roles.first.roleName;
    }
  }

  String? get profileImageUrl => profilePictureUrl;

  String get fullName => displayName;

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return PublicProfileModel(
      userId: _parseInt(data['userId'] ?? data['id']),
      firstName: _parseString(data['firstName']),
      lastName: _parseString(data['lastName']),
      fullName: _parseNullableString(data['fullName']),
      email: _parseString(data['email']),
      role: _parseNullableString(data['role']),
      roles: _parseRoles(data['roles']),
      bio: _parseNullableString(data['bio']),
      profilePictureUrl: _parseNullableString(data['profilePictureUrl']),
      officeLocation: _parseNullableString(
        data['officeLocation'] ?? data['office'] ?? data['location'],
      ),
      socialLinks: SocialLinks.fromJson(data['socialLinks']),
      academicInterests: _parseStringList(data['academicInterests']),
      skills: _parseStringList(data['skills']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': _fullName,
      'email': email,
      'role': role,
      'roles': roles.map((role) => role.toJson()).toList(),
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'officeLocation': officeLocation,
      'socialLinks': socialLinks.toJson(),
      'academicInterests': academicInterests,
      'skills': skills,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    userId,
    firstName,
    lastName,
    _fullName,
    email,
    role,
    roles,
    bio,
    profilePictureUrl,
    officeLocation,
    socialLinks.entries,
    academicInterests,
    skills,
  ];
}

List<RoleModel> _parseRoles(dynamic rawRoles) {
  if (rawRoles is List) {
    return rawRoles.map<RoleModel>((role) {
      if (role is Map<String, dynamic>) {
        return RoleModel.fromJson(role);
      }
      return RoleModel(roleId: 0, roleName: role.toString());
    }).toList();
  }

  if (rawRoles is Map<String, dynamic>) {
    return <RoleModel>[RoleModel.fromJson(rawRoles)];
  }

  return const <RoleModel>[];
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const <String>[];
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

String _parseString(dynamic value) {
  return value?.toString().trim() ?? '';
}

String? _parseNullableString(dynamic value) {
  final result = value?.toString().trim() ?? '';
  if (result.isEmpty) {
    return null;
  }
  return result;
}
