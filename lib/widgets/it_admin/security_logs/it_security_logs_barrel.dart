import 'package:flutter/material.dart';

// Export all security logs widgets
export 'it_security_logs_app_bar.dart';
export 'it_security_stats_cards.dart';
export 'it_security_logs_tab_section.dart';
export 'it_security_logs_list.dart';
export 'it_access_requests_section.dart';
export 'it_role_permissions_section.dart';
export 'it_security_policies_section.dart';
export 'it_active_incidents_section.dart';
export 'it_ai_security_insights.dart';
export 'it_recent_security_actions.dart';
export 'it_incident_detail_sheet.dart';

/// Data models for IT Security Logs screen

enum LogEventType {
  loginSuccess,
  loginFailed,
  logout,
  breachAttempt,
  permissionChange,
  apiAccess,
  mfaEnabled,
  passwordChange,
  accountLocked,
  sessionExpired,
}

enum RiskLevel { low, medium, high, critical }

enum IncidentStatus { active, investigating, resolved, dismissed }

enum IncidentSeverity { info, warning, critical }

enum AccessRequestStatus { pending, approved, denied }

class SecurityLogEntry {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String userEmail;
  final LogEventType eventType;
  final String ipAddress;
  final String? location;
  final String? device;
  final RiskLevel riskLevel;
  final bool isFlagged;
  final String? details;

  SecurityLogEntry({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.eventType,
    required this.ipAddress,
    this.location,
    this.device,
    required this.riskLevel,
    this.isFlagged = false,
    this.details,
  });
}

class SecurityIncident {
  final String id;
  final String title;
  final String description;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final DateTime detectedAt;
  final int affectedAccounts;
  final String? assignedTo;
  final String? investigationNotes;
  final List<String> relatedIps;

  SecurityIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.detectedAt,
    this.affectedAccounts = 0,
    this.assignedTo,
    this.investigationNotes,
    this.relatedIps = const [],
  });

  SecurityIncident copyWith({
    String? id,
    String? title,
    String? description,
    IncidentSeverity? severity,
    IncidentStatus? status,
    DateTime? detectedAt,
    int? affectedAccounts,
    String? assignedTo,
    String? investigationNotes,
    List<String>? relatedIps,
  }) {
    return SecurityIncident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      affectedAccounts: affectedAccounts ?? this.affectedAccounts,
      assignedTo: assignedTo ?? this.assignedTo,
      investigationNotes: investigationNotes ?? this.investigationNotes,
      relatedIps: relatedIps ?? this.relatedIps,
    );
  }
}

class AccessRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String currentRole;
  final String requestedRole;
  final String reason;
  final DateTime requestedAt;
  final AccessRequestStatus status;

  AccessRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.currentRole,
    required this.requestedRole,
    required this.reason,
    required this.requestedAt,
    this.status = AccessRequestStatus.pending,
  });

  AccessRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? currentRole,
    String? requestedRole,
    String? reason,
    DateTime? requestedAt,
    AccessRequestStatus? status,
  }) {
    return AccessRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      currentRole: currentRole ?? this.currentRole,
      requestedRole: requestedRole ?? this.requestedRole,
      reason: reason ?? this.reason,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }
}

class UserRole {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int userCount;
  final List<String> permissions;

  UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.userCount,
    this.permissions = const [],
  });
}

class SecurityPolicy {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final String? value;
  final String? configureAction;

  SecurityPolicy({
    required this.id,
    required this.name,
    required this.description,
    this.isEnabled = false,
    this.value,
    this.configureAction,
  });

  SecurityPolicy copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
    String? value,
    String? configureAction,
  }) {
    return SecurityPolicy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      value: value ?? this.value,
      configureAction: configureAction ?? this.configureAction,
    );
  }
}

class AISecurityInsight {
  final String id;
  final String title;
  final String description;
  final IncidentSeverity severity;
  final IconData icon;

  AISecurityInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.icon,
  });
}

class RecentSecurityAction {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  RecentSecurityAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}

class SecurityStats {
  final int authEvents24h;
  final double authEventsTrend;
  final int failedLogins24h;
  final String? failedLoginsNote;
  final int breachAttempts;
  final int activeIncidents;
  final int privilegeChanges7d;
  final int authorizedChanges;

  SecurityStats({
    required this.authEvents24h,
    this.authEventsTrend = 0,
    required this.failedLogins24h,
    this.failedLoginsNote,
    required this.breachAttempts,
    required this.activeIncidents,
    required this.privilegeChanges7d,
    required this.authorizedChanges,
  });
}
