// IT Profile Barrel - Data Models and Exports
export 'it_profile_header.dart';
export 'it_profile_quick_actions.dart';
export 'it_profile_permissions_section.dart';
export 'it_profile_tab_bar.dart';
export 'it_profile_personal_tab.dart';
export 'it_profile_notifications_tab.dart';
export 'it_profile_security_tab.dart';
export 'it_profile_preferences_tab.dart';
export 'it_change_password_dialog.dart';
export 'it_setup_mfa_dialog.dart';

// Enums
enum ProfileTab { personal, notifications, security, preferences }

enum ThemeModeOption { light, dark, auto }

enum AccentColorOption { cyan, teal, purple }

enum SessionDevice { desktop, mobile, tablet }

// Data Models
class ITAdminProfile {
  final String id;
  final String fullName;
  final String email;
  final String employeeId;
  final String role;
  final String department;
  final String phone;
  final String timezone;
  final String language;
  final String? avatarUrl;
  final bool isActive;
  final DateTime lastLogin;
  final List<String> permissions;

  const ITAdminProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.employeeId,
    required this.role,
    required this.department,
    required this.phone,
    required this.timezone,
    required this.language,
    this.avatarUrl,
    required this.isActive,
    required this.lastLogin,
    required this.permissions,
  });

  ITAdminProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? employeeId,
    String? role,
    String? department,
    String? phone,
    String? timezone,
    String? language,
    String? avatarUrl,
    bool? isActive,
    DateTime? lastLogin,
    List<String>? permissions,
  }) {
    return ITAdminProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      permissions: permissions ?? this.permissions,
    );
  }
}

class NotificationPreferences {
  final bool securityAlerts;
  final bool systemOutageUpdates;
  final bool integrationWarnings;
  final bool aiAnomalyNotifications;
  final bool emailDelivery;
  final bool smsDelivery;
  final bool inAppDelivery;
  final bool slackDelivery;

  const NotificationPreferences({
    required this.securityAlerts,
    required this.systemOutageUpdates,
    required this.integrationWarnings,
    required this.aiAnomalyNotifications,
    required this.emailDelivery,
    required this.smsDelivery,
    required this.inAppDelivery,
    required this.slackDelivery,
  });

  NotificationPreferences copyWith({
    bool? securityAlerts,
    bool? systemOutageUpdates,
    bool? integrationWarnings,
    bool? aiAnomalyNotifications,
    bool? emailDelivery,
    bool? smsDelivery,
    bool? inAppDelivery,
    bool? slackDelivery,
  }) {
    return NotificationPreferences(
      securityAlerts: securityAlerts ?? this.securityAlerts,
      systemOutageUpdates: systemOutageUpdates ?? this.systemOutageUpdates,
      integrationWarnings: integrationWarnings ?? this.integrationWarnings,
      aiAnomalyNotifications:
          aiAnomalyNotifications ?? this.aiAnomalyNotifications,
      emailDelivery: emailDelivery ?? this.emailDelivery,
      smsDelivery: smsDelivery ?? this.smsDelivery,
      inAppDelivery: inAppDelivery ?? this.inAppDelivery,
      slackDelivery: slackDelivery ?? this.slackDelivery,
    );
  }
}

class ActiveSession {
  final String id;
  final String name;
  final SessionDevice device;
  final String ip;
  final String location;
  final DateTime lastActive;
  final bool isCurrentSession;

  const ActiveSession({
    required this.id,
    required this.name,
    required this.device,
    required this.ip,
    required this.location,
    required this.lastActive,
    required this.isCurrentSession,
  });
}

class ApiToken {
  final String id;
  final String name;
  final String preview;
  final DateTime expiresAt;
  final bool isActive;

  const ApiToken({
    required this.id,
    required this.name,
    required this.preview,
    required this.expiresAt,
    required this.isActive,
  });
}

class ActivityLogEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String severity;
  final String result;

  const ActivityLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.severity,
    required this.result,
  });
}

class UIPreferences {
  final ThemeModeOption themeMode;
  final AccentColorOption accentColor;
  final String uiDensity;
  final bool advancedMetricsMode;

  const UIPreferences({
    required this.themeMode,
    required this.accentColor,
    required this.uiDensity,
    required this.advancedMetricsMode,
  });

  UIPreferences copyWith({
    ThemeModeOption? themeMode,
    AccentColorOption? accentColor,
    String? uiDensity,
    bool? advancedMetricsMode,
  }) {
    return UIPreferences(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      uiDensity: uiDensity ?? this.uiDensity,
      advancedMetricsMode: advancedMetricsMode ?? this.advancedMetricsMode,
    );
  }
}
