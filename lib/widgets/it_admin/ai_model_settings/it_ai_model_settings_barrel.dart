import 'package:flutter/material.dart';

// Export all AI model settings widgets
export 'it_ai_model_settings_app_bar.dart';
export 'it_ai_providers_section.dart';
export 'it_api_keys_section.dart';
export 'it_governance_rules_section.dart';
export 'it_system_limits_section.dart';
export 'it_ai_request_logs_section.dart';
export 'it_save_config_dialog.dart';

/// Data models for IT AI Model Settings screen

enum AIProvider { openai, gemini, claude }

enum AIModel {
  gpt4Turbo,
  gpt4,
  gpt35Turbo,
  geminiPro,
  gemini15Pro,
  claude3Opus,
  claude3Sonnet,
  claude35Sonnet,
}

enum RequestStatus { success, failed, pending, rateLimited }

class AIProviderConfig {
  final AIProvider provider;
  final AIModel model;
  final bool isEnabled;
  final String? apiKey;
  final DateTime? lastUsed;

  const AIProviderConfig({
    required this.provider,
    required this.model,
    this.isEnabled = true,
    this.apiKey,
    this.lastUsed,
  });

  AIProviderConfig copyWith({
    AIProvider? provider,
    AIModel? model,
    bool? isEnabled,
    String? apiKey,
    DateTime? lastUsed,
  }) {
    return AIProviderConfig(
      provider: provider ?? this.provider,
      model: model ?? this.model,
      isEnabled: isEnabled ?? this.isEnabled,
      apiKey: apiKey ?? this.apiKey,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  String get providerName {
    switch (provider) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.gemini:
        return 'Gemini';
      case AIProvider.claude:
        return 'Claude';
    }
  }

  String get modelName {
    switch (model) {
      case AIModel.gpt4Turbo:
        return 'GPT-4.1 Turbo';
      case AIModel.gpt4:
        return 'GPT-4';
      case AIModel.gpt35Turbo:
        return 'GPT-3.5 Turbo';
      case AIModel.geminiPro:
        return 'Gemini Pro';
      case AIModel.gemini15Pro:
        return 'Gemini 1.5 Pro';
      case AIModel.claude3Opus:
        return 'Claude 3 Opus';
      case AIModel.claude3Sonnet:
        return 'Claude 3 Sonnet';
      case AIModel.claude35Sonnet:
        return 'Claude 3.5 Sonnet';
    }
  }

  IconData get providerIcon {
    switch (provider) {
      case AIProvider.openai:
        return Icons.auto_awesome;
      case AIProvider.gemini:
        return Icons.diamond_outlined;
      case AIProvider.claude:
        return Icons.psychology;
    }
  }

  Color get providerColor {
    switch (provider) {
      case AIProvider.openai:
        return const Color(0xFF10A37F);
      case AIProvider.gemini:
        return const Color(0xFF4285F4);
      case AIProvider.claude:
        return const Color(0xFFD97706);
    }
  }
}

class GovernanceRules {
  final bool enableAIForStudents;
  final bool enableAIForInstructors;
  final bool enableAIForTA;
  final bool analyzeStudentSubmissions;
  final int maxResponseLength;
  final bool storeAILogs;
  final bool enableContentFilters;
  final bool blockSensitiveTopics;

  const GovernanceRules({
    this.enableAIForStudents = true,
    this.enableAIForInstructors = true,
    this.enableAIForTA = true,
    this.analyzeStudentSubmissions = true,
    this.maxResponseLength = 4096,
    this.storeAILogs = true,
    this.enableContentFilters = true,
    this.blockSensitiveTopics = false,
  });

  GovernanceRules copyWith({
    bool? enableAIForStudents,
    bool? enableAIForInstructors,
    bool? enableAIForTA,
    bool? analyzeStudentSubmissions,
    int? maxResponseLength,
    bool? storeAILogs,
    bool? enableContentFilters,
    bool? blockSensitiveTopics,
  }) {
    return GovernanceRules(
      enableAIForStudents: enableAIForStudents ?? this.enableAIForStudents,
      enableAIForInstructors: enableAIForInstructors ?? this.enableAIForInstructors,
      enableAIForTA: enableAIForTA ?? this.enableAIForTA,
      analyzeStudentSubmissions: analyzeStudentSubmissions ?? this.analyzeStudentSubmissions,
      maxResponseLength: maxResponseLength ?? this.maxResponseLength,
      storeAILogs: storeAILogs ?? this.storeAILogs,
      enableContentFilters: enableContentFilters ?? this.enableContentFilters,
      blockSensitiveTopics: blockSensitiveTopics ?? this.blockSensitiveTopics,
    );
  }
}

class SystemLimits {
  final int dailyRequestsPerUser;
  final int instructorUsage;
  final int instructorLimit;
  final int studentUsage;
  final int studentLimit;
  final int taUsage;
  final int taLimit;
  final bool highLoadWarningEnabled;
  final int highLoadThreshold;

  const SystemLimits({
    this.dailyRequestsPerUser = 10000,
    this.instructorUsage = 2500,
    this.instructorLimit = 5000,
    this.studentUsage = 1200,
    this.studentLimit = 3000,
    this.taUsage = 1450,
    this.taLimit = 2500,
    this.highLoadWarningEnabled = true,
    this.highLoadThreshold = 80,
  });

  SystemLimits copyWith({
    int? dailyRequestsPerUser,
    int? instructorUsage,
    int? instructorLimit,
    int? studentUsage,
    int? studentLimit,
    int? taUsage,
    int? taLimit,
    bool? highLoadWarningEnabled,
    int? highLoadThreshold,
  }) {
    return SystemLimits(
      dailyRequestsPerUser: dailyRequestsPerUser ?? this.dailyRequestsPerUser,
      instructorUsage: instructorUsage ?? this.instructorUsage,
      instructorLimit: instructorLimit ?? this.instructorLimit,
      studentUsage: studentUsage ?? this.studentUsage,
      studentLimit: studentLimit ?? this.studentLimit,
      taUsage: taUsage ?? this.taUsage,
      taLimit: taLimit ?? this.taLimit,
      highLoadWarningEnabled: highLoadWarningEnabled ?? this.highLoadWarningEnabled,
      highLoadThreshold: highLoadThreshold ?? this.highLoadThreshold,
    );
  }
}

class AIRequestLog {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final AIProvider provider;
  final AIModel model;
  final RequestStatus status;
  final int tokensUsed;
  final int responseTime;
  final String? errorMessage;

  const AIRequestLog({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.provider,
    required this.model,
    required this.status,
    this.tokensUsed = 0,
    this.responseTime = 0,
    this.errorMessage,
  });

  String get statusText {
    switch (status) {
      case RequestStatus.success:
        return 'Success';
      case RequestStatus.failed:
        return 'Failed';
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.rateLimited:
        return 'Rate Limited';
    }
  }

  Color get statusColor {
    switch (status) {
      case RequestStatus.success:
        return const Color(0xFF10B981);
      case RequestStatus.failed:
        return const Color(0xFFEF4444);
      case RequestStatus.pending:
        return const Color(0xFFF59E0B);
      case RequestStatus.rateLimited:
        return const Color(0xFF8B5CF6);
    }
  }
}

class AIRequestStats {
  final double successRate;
  final int activeProviders;
  final int requestsPerMinute;
  final int totalRequests;

  const AIRequestStats({
    required this.successRate,
    required this.activeProviders,
    required this.requestsPerMinute,
    required this.totalRequests,
  });
}
