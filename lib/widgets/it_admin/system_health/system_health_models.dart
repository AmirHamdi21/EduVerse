// Models for System Health
import 'package:flutter/material.dart';

class SystemHealthMetric {
  final String id;
  final String name;
  final double value;
  final double maxValue;
  final String unit;
  final String status;
  final String trend;
  final IconData icon;
  final List<double> history;

  const SystemHealthMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.status,
    required this.trend,
    required this.icon,
    required this.history,
  });
}

class HealthService {
  final String id;
  final String name;
  final String status;
  final String description;
  final String lastCheck;
  final double uptime;
  final IconData icon;

  const HealthService({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    required this.lastCheck,
    required this.uptime,
    required this.icon,
  });
}

class HealthAlert {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String time;
  final String source;

  const HealthAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.time,
    required this.source,
  });
}
