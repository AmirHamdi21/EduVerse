import 'package:flutter/material.dart';

// Export all performance report widgets
export 'it_performance_report_app_bar.dart';
export 'it_time_period_selector.dart';
export 'it_performance_overview_cards.dart';
export 'it_server_health_section.dart';
export 'it_performance_trends_section.dart';
export 'it_recent_alerts_section.dart';
export 'it_resource_utilization_section.dart';

/// Data models for IT System Performance Report screen

enum TimePeriod { today, week, month, custom }

enum ServerStatus { healthy, warning, critical, offline }

enum AlertSeverity { info, warning, critical }

enum AlertType { cpu, memory, disk, network, latency, error }

class PerformanceMetric {
  final String id;
  final String name;
  final double value;
  final double maxValue;
  final String unit;
  final IconData icon;
  final Color color;
  final double? trend;
  final bool isUp;

  const PerformanceMetric({
    required this.id,
    required this.name,
    required this.value,
    this.maxValue = 100,
    required this.unit,
    required this.icon,
    required this.color,
    this.trend,
    this.isUp = true,
  });

  double get percentage => (value / maxValue * 100).clamp(0, 100);
}

class ServerHealth {
  final String id;
  final String name;
  final String type;
  final ServerStatus status;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final String uptime;
  final DateTime lastChecked;

  const ServerHealth({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.uptime,
    required this.lastChecked,
  });

  String get statusText {
    switch (status) {
      case ServerStatus.healthy:
        return 'Healthy';
      case ServerStatus.warning:
        return 'Warning';
      case ServerStatus.critical:
        return 'Critical';
      case ServerStatus.offline:
        return 'Offline';
    }
  }

  Color get statusColor {
    switch (status) {
      case ServerStatus.healthy:
        return const Color(0xFF10B981);
      case ServerStatus.warning:
        return const Color(0xFFF59E0B);
      case ServerStatus.critical:
        return const Color(0xFFEF4444);
      case ServerStatus.offline:
        return const Color(0xFF6B7280);
    }
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'app':
      case 'application':
        return Icons.apps_rounded;
      case 'database':
      case 'db':
        return Icons.storage_rounded;
      case 'web':
        return Icons.language_rounded;
      case 'cache':
        return Icons.memory_rounded;
      case 'file':
        return Icons.folder_rounded;
      default:
        return Icons.dns_rounded;
    }
  }
}

class PerformanceAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isResolved;

  const PerformanceAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isResolved = false,
  });

  IconData get typeIcon {
    switch (type) {
      case AlertType.cpu:
        return Icons.memory_rounded;
      case AlertType.memory:
        return Icons.storage_rounded;
      case AlertType.disk:
        return Icons.disc_full_rounded;
      case AlertType.network:
        return Icons.wifi_rounded;
      case AlertType.latency:
        return Icons.speed_rounded;
      case AlertType.error:
        return Icons.error_rounded;
    }
  }

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.info:
        return const Color(0xFF3B82F6);
      case AlertSeverity.warning:
        return const Color(0xFFF59E0B);
      case AlertSeverity.critical:
        return const Color(0xFFEF4444);
    }
  }

  String get severityText {
    switch (severity) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

class TrendDataPoint {
  final DateTime time;
  final double value;

  const TrendDataPoint({
    required this.time,
    required this.value,
  });
}

class ResourceUtilization {
  final String name;
  final double used;
  final double total;
  final String unit;
  final Color color;

  const ResourceUtilization({
    required this.name,
    required this.used,
    required this.total,
    required this.unit,
    required this.color,
  });

  double get percentage => (used / total * 100).clamp(0, 100);
  String get usedFormatted => _formatSize(used);
  String get totalFormatted => _formatSize(total);

  String _formatSize(double size) {
    if (unit == 'GB' || unit == 'TB') {
      return '${size.toStringAsFixed(1)} $unit';
    }
    return '${size.round()} $unit';
  }
}

class PerformanceStats {
  final double avgCpuUsage;
  final double avgMemoryUsage;
  final double avgDiskUsage;
  final double avgResponseTime;
  final int activeUsers;
  final int totalRequests;
  final double errorRate;
  final double uptime;

  const PerformanceStats({
    required this.avgCpuUsage,
    required this.avgMemoryUsage,
    required this.avgDiskUsage,
    required this.avgResponseTime,
    required this.activeUsers,
    required this.totalRequests,
    required this.errorRate,
    required this.uptime,
  });
}
