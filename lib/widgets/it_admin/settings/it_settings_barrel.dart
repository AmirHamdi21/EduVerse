// Barrel file for IT Admin Settings widgets
import 'package:flutter/material.dart';

export 'it_settings_app_bar.dart';
export 'it_environment_section.dart';
export 'it_service_config_section.dart';
export 'it_service_card.dart';
export 'it_security_section.dart';
export 'it_notification_section.dart';
export 'it_maintenance_section.dart';
export 'it_integration_section.dart';

// Data models
class EnvironmentConfig {
  final String id;
  final String name;
  final String status;
  final bool isSelected;
  final IconData icon;

  EnvironmentConfig({
    required this.id,
    required this.name,
    required this.status,
    this.isSelected = false,
    required this.icon,
  });
}

class ServiceConfig {
  final String id;
  final String name;
  final String version;
  final String status;
  final String region;
  final String lastUpdated;
  final IconData icon;

  ServiceConfig({
    required this.id,
    required this.name,
    required this.version,
    required this.status,
    required this.region,
    required this.lastUpdated,
    required this.icon,
  });
}

class SecuritySetting {
  final String id;
  final String title;
  final String description;
  final bool isEnabled;
  final IconData icon;
  final String? lastUpdated;

  SecuritySetting({
    required this.id,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.icon,
    this.lastUpdated,
  });
}

class NotificationSetting {
  final String id;
  final String title;
  final String description;
  final bool isEnabled;
  final String channel;
  final IconData icon;

  NotificationSetting({
    required this.id,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.channel,
    required this.icon,
  });
}

class MaintenanceWindow {
  final String id;
  final String title;
  final String schedule;
  final String nextRun;
  final bool isActive;
  final String type;

  MaintenanceWindow({
    required this.id,
    required this.title,
    required this.schedule,
    required this.nextRun,
    required this.isActive,
    required this.type,
  });
}

class IntegrationConfig {
  final String id;
  final String name;
  final String type;
  final String status;
  final String lastSync;
  final IconData icon;

  IntegrationConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lastSync,
    required this.icon,
  });
}
