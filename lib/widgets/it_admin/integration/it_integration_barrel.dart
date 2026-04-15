import 'package:flutter/material.dart';

// Export all integration widgets
export 'it_integration_app_bar.dart';
export 'it_integration_filter_section.dart';
export 'it_integration_card.dart';
export 'it_integration_list_section.dart';
export 'it_integration_detail_sheet.dart';
export 'it_integration_config_dialog.dart';
export 'it_integration_stats_card.dart';

/// Data models for IT Integration screen

enum IntegrationStatus { connected, disconnected, pending, error }

enum IntegrationCategory {
  all,
  lms,
  ai,
  storage,
  productivity,
  communication,
  analytics,
  security,
}

class IntegrationProvider {
  final String id;
  final String name;
  final String description;
  final String category;
  final IntegrationStatus status;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? lastSync;
  final String? apiType;
  final bool hasOAuth;
  final bool hasApiKey;
  final int? requestCount;
  final int? requestLimit;
  final double? uptime;
  final double? errorRate;
  final String? version;
  final bool isPopular;
  final List<String> features;
  final ConnectionSettings? connectionSettings;
  final PerformanceMetrics? performanceMetrics;

  IntegrationProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.lastSync,
    this.apiType,
    this.hasOAuth = false,
    this.hasApiKey = false,
    this.requestCount,
    this.requestLimit,
    this.uptime,
    this.errorRate,
    this.version,
    this.isPopular = false,
    this.features = const [],
    this.connectionSettings,
    this.performanceMetrics,
  });

  IntegrationProvider copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    IntegrationStatus? status,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    String? lastSync,
    String? apiType,
    bool? hasOAuth,
    bool? hasApiKey,
    int? requestCount,
    int? requestLimit,
    double? uptime,
    double? errorRate,
    String? version,
    bool? isPopular,
    List<String>? features,
    ConnectionSettings? connectionSettings,
    PerformanceMetrics? performanceMetrics,
  }) {
    return IntegrationProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      lastSync: lastSync ?? this.lastSync,
      apiType: apiType ?? this.apiType,
      hasOAuth: hasOAuth ?? this.hasOAuth,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      requestCount: requestCount ?? this.requestCount,
      requestLimit: requestLimit ?? this.requestLimit,
      uptime: uptime ?? this.uptime,
      errorRate: errorRate ?? this.errorRate,
      version: version ?? this.version,
      isPopular: isPopular ?? this.isPopular,
      features: features ?? this.features,
      connectionSettings: connectionSettings ?? this.connectionSettings,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
}

class ConnectionSettings {
  final String? apiKey;
  final String? apiEndpoint;
  final String? clientId;
  final String? clientSecret;
  final bool autoSync;
  final int syncInterval; // in minutes
  final int rateLimitPerMinute;
  final int timeout; // in seconds

  ConnectionSettings({
    this.apiKey,
    this.apiEndpoint,
    this.clientId,
    this.clientSecret,
    this.autoSync = true,
    this.syncInterval = 15,
    this.rateLimitPerMinute = 100,
    this.timeout = 30,
  });
}

class PerformanceMetrics {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double averageResponseTime; // in ms
  final double uptimePercentage;
  final DateTime? lastError;
  final String? lastErrorMessage;

  PerformanceMetrics({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.uptimePercentage,
    this.lastError,
    this.lastErrorMessage,
  });

  double get successRate =>
      totalRequests > 0 ? (successfulRequests / totalRequests) * 100 : 0;
}

class IntegrationActivity {
  final String id;
  final String integrationId;
  final String action;
  final String description;
  final DateTime timestamp;
  final bool isSuccess;

  IntegrationActivity({
    required this.id,
    required this.integrationId,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.isSuccess,
  });
}
