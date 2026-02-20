import 'package:flutter/material.dart';

// Export all backup widgets
export 'it_backup_app_bar.dart';
export 'it_backup_status_cards.dart';
export 'it_backup_tab_section.dart';
export 'it_backup_jobs_section.dart';
export 'it_restore_section.dart';
export 'it_integrity_section.dart';
export 'it_dr_runbooks_section.dart';
export 'it_ai_recommendations_section.dart';
export 'it_storage_distribution_section.dart';
export 'it_alert_settings_section.dart';

/// Data models for IT Backup screen

enum BackupStatus { completed, running, failed, scheduled, cancelled }

enum BackupType { full, incremental, differential, snapshot, archive }

enum RestorePointStatus { verified, pending, failed }

class BackupJob {
  final String id;
  final String name;
  final BackupType type;
  final BackupStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final double sizeGB;
  final String target;
  final double progress;
  final String? errorMessage;
  final Duration? duration;

  BackupJob({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.sizeGB,
    required this.target,
    this.progress = 100,
    this.errorMessage,
    this.duration,
  });

  BackupJob copyWith({
    String? id,
    String? name,
    BackupType? type,
    BackupStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? sizeGB,
    String? target,
    double? progress,
    String? errorMessage,
    Duration? duration,
  }) {
    return BackupJob(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sizeGB: sizeGB ?? this.sizeGB,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      duration: duration ?? this.duration,
    );
  }
}

class RestorePoint {
  final String id;
  final DateTime timestamp;
  final BackupType type;
  final double sizeGB;
  final RestorePointStatus status;
  final String source;
  final bool isVerified;

  RestorePoint({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.sizeGB,
    required this.status,
    required this.source,
    this.isVerified = false,
  });
}

class DRRunbook {
  final String id;
  final String name;
  final String description;
  final DateTime lastTested;
  final int rtoMinutes;
  final int rpoMinutes;
  final String status;
  final List<String> steps;
  final double successRate;

  DRRunbook({
    required this.id,
    required this.name,
    required this.description,
    required this.lastTested,
    required this.rtoMinutes,
    required this.rpoMinutes,
    required this.status,
    this.steps = const [],
    this.successRate = 100,
  });
}

class IntegrityCheck {
  final String id;
  final String backupName;
  final DateTime checkedAt;
  final bool passed;
  final String? errorDetails;
  final BackupType type;

  IntegrityCheck({
    required this.id,
    required this.backupName,
    required this.checkedAt,
    required this.passed,
    this.errorDetails,
    required this.type,
  });
}

class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final String type;
  final String actionLabel;
  final Color color;
  final IconData icon;
  final String priority;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.actionLabel,
    required this.color,
    required this.icon,
    this.priority = 'medium',
  });
}

class StorageItem {
  final String name;
  final double sizeGB;
  final Color color;
  final IconData icon;

  StorageItem({
    required this.name,
    required this.sizeGB,
    required this.color,
    required this.icon,
  });
}

class BackupStats {
  final String lastFullBackup;
  final int successful24h;
  final int failed24h;
  final String nextScheduled;
  final double storageUsedGB;
  final double storageTotalGB;
  final int recoveryScore;
  final int verifiedBackups;
  final int pendingVerification;

  BackupStats({
    required this.lastFullBackup,
    required this.successful24h,
    required this.failed24h,
    required this.nextScheduled,
    required this.storageUsedGB,
    required this.storageTotalGB,
    required this.recoveryScore,
    required this.verifiedBackups,
    required this.pendingVerification,
  });
}

class AlertSettings {
  final bool emailAlerts;
  final bool slackNotifications;
  final bool criticalOnly;

  AlertSettings({
    this.emailAlerts = true,
    this.slackNotifications = true,
    this.criticalOnly = false,
  });

  AlertSettings copyWith({
    bool? emailAlerts,
    bool? slackNotifications,
    bool? criticalOnly,
  }) {
    return AlertSettings(
      emailAlerts: emailAlerts ?? this.emailAlerts,
      slackNotifications: slackNotifications ?? this.slackNotifications,
      criticalOnly: criticalOnly ?? this.criticalOnly,
    );
  }
}
