import 'package:flutter/material.dart';

/// User profile model
class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? coverUrl;
  final String role;
  final String? studentId;
  final String? university;
  final String? major;
  final String? minor;
  final String? level;
  final String? year;
  final String? expectedGraduation;
  final DateTime? dateOfBirth;
  final String? location;
  final String? bio;
  final double gpa;
  final int rank;
  final int coursesEnrolled;
  final int assignmentsCompleted;
  final SocialLinks? socialLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.coverUrl,
    this.role = 'Student',
    this.studentId,
    this.university,
    this.major,
    this.minor,
    this.level,
    this.year,
    this.expectedGraduation,
    this.dateOfBirth,
    this.location,
    this.bio,
    this.gpa = 0.0,
    this.rank = 0,
    this.coursesEnrolled = 0,
    this.assignmentsCompleted = 0,
    this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? coverUrl,
    String? role,
    String? studentId,
    String? university,
    String? major,
    String? minor,
    String? level,
    String? year,
    String? expectedGraduation,
    DateTime? dateOfBirth,
    String? location,
    String? bio,
    double? gpa,
    int? rank,
    int? coursesEnrolled,
    int? assignmentsCompleted,
    SocialLinks? socialLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      major: major ?? this.major,
      minor: minor ?? this.minor,
      level: level ?? this.level,
      year: year ?? this.year,
      expectedGraduation: expectedGraduation ?? this.expectedGraduation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      gpa: gpa ?? this.gpa,
      rank: rank ?? this.rank,
      coursesEnrolled: coursesEnrolled ?? this.coursesEnrolled,
      assignmentsCompleted: assignmentsCompleted ?? this.assignmentsCompleted,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Social links model
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

/// App settings model
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

/// Accent color options
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

/// Connected device model
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

/// Device type icons
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
