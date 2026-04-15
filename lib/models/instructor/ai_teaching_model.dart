// Models for AI Teaching Assistant screen

import 'package:flutter/material.dart';

/// AI Mode types for specialized assistance
enum AIMode {
  createContent,
  analyzeData,
  rewriteEnhance,
  courseInsights,
  communication,
}

/// Extension for AIMode properties
extension AIModeExtension on AIMode {
  String get title {
    switch (this) {
      case AIMode.createContent:
        return 'Create Content';
      case AIMode.analyzeData:
        return 'Analyze Data';
      case AIMode.rewriteEnhance:
        return 'Rewrite/Enhance';
      case AIMode.courseInsights:
        return 'Course Insights';
      case AIMode.communication:
        return 'Communication';
    }
  }

  String get description {
    switch (this) {
      case AIMode.createContent:
        return 'Generate questions, assignments, labs';
      case AIMode.analyzeData:
        return 'Student performance & patterns';
      case AIMode.rewriteEnhance:
        return 'Improve & simplify materials';
      case AIMode.courseInsights:
        return 'Recommendations & improvements';
      case AIMode.communication:
        return 'Announcements & emails';
    }
  }
}

/// Chat message model
class AIChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final List<String>? suggestions;

  const AIChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.suggestions,
  });

  AIChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    List<String>? suggestions,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

/// Message status
enum MessageStatus { sending, sent, error }

/// Quick action model
class QuickAction {
  final String id;
  final String label;
  final String prompt;
  final IconData icon;

  const QuickAction({
    required this.id,
    required this.label,
    required this.prompt,
    required this.icon,
  });
}

/// Predefined quick actions
class QuickActions {
  static const List<QuickAction> defaultActions = [
    QuickAction(
      id: 'mcq',
      label: 'Generate 10 MCQs',
      prompt: 'Generate 10 multiple choice questions about the current topic',
      icon: Icons.quiz_rounded,
    ),
    QuickAction(
      id: 'summarize',
      label: 'Summarize Lecture',
      prompt: 'Summarize the key points of my lecture content',
      icon: Icons.summarize_rounded,
    ),
    QuickAction(
      id: 'lab',
      label: 'Create Lab Exercise',
      prompt: 'Create a practical lab exercise for students',
      icon: Icons.science_rounded,
    ),
    QuickAction(
      id: 'rubric',
      label: 'Generate Rubric',
      prompt: 'Generate a grading rubric for this assignment',
      icon: Icons.grading_rounded,
    ),
  ];
}
