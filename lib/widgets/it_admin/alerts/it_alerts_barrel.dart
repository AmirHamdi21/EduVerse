// IT Alerts Barrel - Data Models and Exports
export 'it_alerts_app_bar.dart';
export 'it_alerts_stats_cards.dart';
export 'it_alerts_tab_bar.dart';
export 'it_alerts_rules_tab.dart';
export 'it_alerts_channels_tab.dart';
export 'it_alerts_suppress_tab.dart';
export 'it_alerts_escalation_tab.dart';
export 'it_alerts_history_tab.dart';
export 'it_create_rule_dialog.dart';
export 'it_ai_tuning_advisor.dart';
export 'it_alert_metrics_section.dart';

// Enums
enum AlertSeverity { critical, warning, info }

enum AlertStatus { active, muted, resolved, suppressed }

enum AlertTab { rules, channels, escalation, suppress, history }

enum ChannelType { slack, email, pagerDuty, sms, webhook }

// Data Models
class AlertStats {
  final int activeAlerts;
  final int resolvedAlerts;
  final int suppressedAlerts;
  final int noiseScore;
  final List<int> activeHistory;
  final List<int> resolvedHistory;

  const AlertStats({
    required this.activeAlerts,
    required this.resolvedAlerts,
    required this.suppressedAlerts,
    required this.noiseScore,
    required this.activeHistory,
    required this.resolvedHistory,
  });
}

class AlertRule {
  final String id;
  final String name;
  final String description;
  final String service;
  final AlertSeverity severity;
  final String metric;
  final String operator;
  final double threshold;
  final Duration forDuration;
  final bool isEnabled;
  final List<String> tags;
  final DateTime? lastTriggered;
  final int triggerCount;

  const AlertRule({
    required this.id,
    required this.name,
    required this.description,
    required this.service,
    required this.severity,
    required this.metric,
    required this.operator,
    required this.threshold,
    required this.forDuration,
    required this.isEnabled,
    required this.tags,
    this.lastTriggered,
    this.triggerCount = 0,
  });

  AlertRule copyWith({
    String? id,
    String? name,
    String? description,
    String? service,
    AlertSeverity? severity,
    String? metric,
    String? operator,
    double? threshold,
    Duration? forDuration,
    bool? isEnabled,
    List<String>? tags,
    DateTime? lastTriggered,
    int? triggerCount,
  }) {
    return AlertRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      service: service ?? this.service,
      severity: severity ?? this.severity,
      metric: metric ?? this.metric,
      operator: operator ?? this.operator,
      threshold: threshold ?? this.threshold,
      forDuration: forDuration ?? this.forDuration,
      isEnabled: isEnabled ?? this.isEnabled,
      tags: tags ?? this.tags,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      triggerCount: triggerCount ?? this.triggerCount,
    );
  }
}

class NotificationChannel {
  final String id;
  final String name;
  final ChannelType type;
  final String description;
  final Map<String, String> config;
  final bool isEnabled;
  final bool isVerified;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.config,
    required this.isEnabled,
    required this.isVerified,
  });

  NotificationChannel copyWith({
    String? id,
    String? name,
    ChannelType? type,
    String? description,
    Map<String, String>? config,
    bool? isEnabled,
    bool? isVerified,
  }) {
    return NotificationChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      config: config ?? this.config,
      isEnabled: isEnabled ?? this.isEnabled,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class SuppressionWindow {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> affectedServices;
  final bool isRecurring;
  final String? recurringPattern;
  final bool isActive;

  const SuppressionWindow({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.affectedServices,
    required this.isRecurring,
    this.recurringPattern,
    required this.isActive,
  });
}

class EscalationPolicy {
  final String id;
  final String name;
  final String description;
  final List<EscalationStep> steps;
  final bool isEnabled;

  const EscalationPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.isEnabled,
  });
}

class EscalationStep {
  final int stepNumber;
  final String target;
  final String targetType;
  final Duration delayAfter;

  const EscalationStep({
    required this.stepNumber,
    required this.target,
    required this.targetType,
    required this.delayAfter,
  });
}

class AlertHistoryEntry {
  final String id;
  final DateTime timestamp;
  final String ruleName;
  final AlertSeverity severity;
  final String status;
  final String? resolvedBy;
  final Duration? timeToAck;

  const AlertHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.ruleName,
    required this.severity,
    required this.status,
    this.resolvedBy,
    this.timeToAck,
  });
}

class AiSuggestion {
  final String id;
  final String type;
  final String title;
  final String description;
  final int confidence;
  final String? actionLabel;

  const AiSuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    this.actionLabel,
  });
}

class AlertMetric {
  final String name;
  final dynamic value;
  final String? unit;
  final double? change;
  final bool isUp;

  const AlertMetric({
    required this.name,
    required this.value,
    this.unit,
    this.change,
    this.isUp = true,
  });
}

class NoisyRule {
  final String name;
  final int count;

  const NoisyRule({required this.name, required this.count});
}
