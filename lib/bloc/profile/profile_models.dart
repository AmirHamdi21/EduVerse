import 'package:flutter/material.dart';

import '../../models/auth_models.dart';

class UserProfile {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? _fullName;
  final String? phone;
  final String? profilePictureUrl;
  final String? bio;
  final SocialLinks socialLinks;
  final List<String> academicInterests;
  final List<String> skills;
  final List<RoleModel> roles;
  final String status;
  final bool emailVerified;
  final String createdAt;
  final double profileCompleteness;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    String? fullName,
    this.phone,
    this.profilePictureUrl,
    this.bio,
    this.socialLinks = const SocialLinks(),
    this.academicInterests = const <String>[],
    this.skills = const <String>[],
    this.roles = const <RoleModel>[],
    this.status = 'active',
    this.emailVerified = false,
    this.createdAt = '',
    this.profileCompleteness = 0,
  }) : _fullName = fullName;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserProfile(
      userId: _parseInt(data['userId'] ?? data['id']),
      email: _parseString(data['email']),
      firstName: _parseString(data['firstName']),
      lastName: _parseString(data['lastName']),
      fullName: _parseNullableString(data['fullName']),
      phone: _parseNullableString(data['phone']),
      profilePictureUrl: _parseNullableString(data['profilePictureUrl']),
      bio: _parseNullableString(data['bio']),
      socialLinks: SocialLinks.fromJson(data['socialLinks']),
      academicInterests: _parseStringList(data['academicInterests']),
      skills: _parseStringList(data['skills']),
      roles: _parseRoles(data['roles']),
      status: _parseString(data['status'], fallback: 'active'),
      emailVerified: _parseBool(data['emailVerified']),
      createdAt: _parseString(data['createdAt']),
      profileCompleteness: _parseDouble(data['profileCompleteness']),
    );
  }

  String get displayName {
    final resolved = _fullName?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }
    final combined = '$firstName $lastName'.trim();
    return combined.isEmpty ? email : combined;
  }

  String get initials {
    final resolved = displayName.trim();
    if (resolved.isEmpty) {
      return 'U';
    }

    final parts = resolved
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

  String get primaryRoleName =>
      roles.isNotEmpty ? roles.first.roleName : 'student';

  String get primaryRoleLabel => _formatRoleLabel(primaryRoleName);

  String get fullNameValue => displayName;

  String get fullName => displayName;

  String? get phoneNumber => phone;

  String? get avatarUrl => profilePictureUrl;

  String get role => primaryRoleLabel;

  UserProfile copyWith({
    int? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? profilePictureUrl,
    String? bio,
    SocialLinks? socialLinks,
    List<String>? academicInterests,
    List<String>? skills,
    List<RoleModel>? roles,
    String? status,
    bool? emailVerified,
    String? createdAt,
    double? profileCompleteness,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? _fullName,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      academicInterests: academicInterests ?? this.academicInterests,
      skills: skills ?? this.skills,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
    );
  }
}

class SocialLinks {
  final String? personalWebsite;
  final String? github;
  final String? linkedin;
  final String? twitter;

  const SocialLinks({
    this.personalWebsite,
    this.github,
    this.linkedin,
    this.twitter,
  });

  factory SocialLinks.fromJson(dynamic json) {
    if (json is! Map) {
      return const SocialLinks();
    }

    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = _parseNullableString(json[key]);
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
      return null;
    }

    return SocialLinks(
      personalWebsite: pick(const <String>['personalWebsite', 'website']),
      github: pick(const <String>['github']),
      linkedin: pick(const <String>['linkedin']),
      twitter: pick(const <String>['twitter', 'x']),
    );
  }

  bool get hasAny =>
      personalWebsite != null ||
      github != null ||
      linkedin != null ||
      twitter != null;

  Map<String, String> toJson() {
    return <String, String>{
      if (personalWebsite != null && personalWebsite!.trim().isNotEmpty)
        'personalWebsite': personalWebsite!.trim(),
      if (github != null && github!.trim().isNotEmpty) 'github': github!.trim(),
      if (linkedin != null && linkedin!.trim().isNotEmpty)
        'linkedin': linkedin!.trim(),
      if (twitter != null && twitter!.trim().isNotEmpty)
        'twitter': twitter!.trim(),
    };
  }

  List<MapEntry<String, String>> get entries => <MapEntry<String, String>>[
    if (personalWebsite != null && personalWebsite!.trim().isNotEmpty)
      MapEntry<String, String>('Website', personalWebsite!.trim()),
    if (github != null && github!.trim().isNotEmpty)
      MapEntry<String, String>('GitHub', github!.trim()),
    if (linkedin != null && linkedin!.trim().isNotEmpty)
      MapEntry<String, String>('LinkedIn', linkedin!.trim()),
    if (twitter != null && twitter!.trim().isNotEmpty)
      MapEntry<String, String>('Twitter', twitter!.trim()),
  ];

  SocialLinks copyWith({
    String? personalWebsite,
    String? github,
    String? linkedin,
    String? twitter,
  }) {
    return SocialLinks(
      personalWebsite: personalWebsite ?? this.personalWebsite,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      twitter: twitter ?? this.twitter,
    );
  }
}

class UpdateUserProfileRequest {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profilePictureUrl;
  final String? bio;
  final SocialLinks socialLinks;
  final List<String> academicInterests;
  final List<String> skills;

  const UpdateUserProfileRequest({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profilePictureUrl,
    this.bio,
    this.socialLinks = const SocialLinks(),
    this.academicInterests = const <String>[],
    this.skills = const <String>[],
  });

  factory UpdateUserProfileRequest.fromProfile(UserProfile profile) {
    return UpdateUserProfileRequest(
      firstName: profile.firstName,
      lastName: profile.lastName,
      phone: profile.phone,
      profilePictureUrl: profile.profilePictureUrl,
      bio: profile.bio,
      socialLinks: profile.socialLinks,
      academicInterests: profile.academicInterests,
      skills: profile.skills,
    );
  }

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'academicInterests': academicInterests
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      'skills': skills
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      'socialLinks': socialLinks.toJson(),
    };

    payload['phone'] = (phone ?? '').trim();
    payload['profilePictureUrl'] = (profilePictureUrl ?? '').trim();
    payload['bio'] = (bio ?? '').trim();

    return payload;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}

class AppSettings {
  final bool pushNotifications;
  final bool emailAlerts;
  final bool aiSuggestions;
  final bool autoDarkMode;
  final bool weeklyPerformanceSummary;
  final ThemeMode themeMode;
  final AccentColor accentColor;
  final bool twoFactorAuth;
  final String languageCode;

  const AppSettings({
    this.pushNotifications = true,
    this.emailAlerts = true,
    this.aiSuggestions = true,
    this.autoDarkMode = false,
    this.weeklyPerformanceSummary = true,
    this.themeMode = ThemeMode.light,
    this.accentColor = AccentColor.blue,
    this.twoFactorAuth = false,
    this.languageCode = 'en',
  });

  AppSettings copyWith({
    bool? pushNotifications,
    bool? emailAlerts,
    bool? aiSuggestions,
    bool? autoDarkMode,
    bool? weeklyPerformanceSummary,
    ThemeMode? themeMode,
    AccentColor? accentColor,
    bool? twoFactorAuth,
    String? languageCode,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      autoDarkMode: autoDarkMode ?? this.autoDarkMode,
      weeklyPerformanceSummary:
          weeklyPerformanceSummary ?? this.weeklyPerformanceSummary,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

enum AccentColor { blue, purple, green, orange, pink, teal }

extension AccentColorExtension on AccentColor {
  Color get color {
    switch (this) {
      case AccentColor.blue:
        return const Color(0xFF3B82F6);
      case AccentColor.purple:
        return const Color(0xFF8B5CF6);
      case AccentColor.green:
        return const Color(0xFF10B981);
      case AccentColor.orange:
        return const Color(0xFFF59E0B);
      case AccentColor.pink:
        return const Color(0xFFEC4899);
      case AccentColor.teal:
        return const Color(0xFF14B8A6);
    }
  }

  String get name {
    switch (this) {
      case AccentColor.blue:
        return 'Blue';
      case AccentColor.purple:
        return 'Purple';
      case AccentColor.green:
        return 'Green';
      case AccentColor.orange:
        return 'Orange';
      case AccentColor.pink:
        return 'Pink';
      case AccentColor.teal:
        return 'Teal';
    }
  }
}

class ConnectedDevice {
  final String id;
  final String name;
  final String type;
  final String? location;
  final DateTime lastActive;
  final bool isCurrentDevice;

  const ConnectedDevice({
    required this.id,
    required this.name,
    required this.type,
    this.location,
    required this.lastActive,
    this.isCurrentDevice = false,
  });
}

extension DeviceTypeExtension on String {
  IconData get deviceIcon {
    switch (toLowerCase()) {
      case 'iphone':
      case 'mobile':
      case 'phone':
        return Icons.phone_iphone_rounded;
      case 'ipad':
      case 'tablet':
        return Icons.tablet_mac_rounded;
      case 'macbook':
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'desktop':
      case 'pc':
        return Icons.desktop_mac_rounded;
      default:
        return Icons.devices_rounded;
    }
  }
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

  if (rawRoles != null) {
    return <RoleModel>[RoleModel(roleId: 0, roleName: rawRoles.toString())];
  }

  return const <RoleModel>[];
}

List<String> _parseStringList(dynamic rawList) {
  if (rawList is List) {
    return rawList
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  return const <String>[];
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

double _parseDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

String _parseString(dynamic value, {String fallback = ''}) {
  final parsed = value?.toString().trim() ?? '';
  return parsed.isEmpty ? fallback : parsed;
}

String? _parseNullableString(dynamic value) {
  final parsed = value?.toString().trim() ?? '';
  return parsed.isEmpty ? null : parsed;
}

bool _parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  return fallback;
}

String _formatRoleLabel(String rawRole) {
  switch (rawRole.trim().toLowerCase()) {
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
      if (rawRole.trim().isEmpty) {
        return 'Student';
      }

      return rawRole
          .replaceAll('_', ' ')
          .split(' ')
          .where((part) => part.trim().isNotEmpty)
          .map(
            (part) =>
                '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
          )
          .join(' ');
  }
}
