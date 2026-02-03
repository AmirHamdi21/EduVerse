import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskCategory { assignment, exam, project, lab, reading, other }

enum TaskStatus { pending, inProgress, completed, overdue }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFF3B82F6);
      case TaskPriority.high:
        return const Color(0xFFF59E0B);
      case TaskPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.assignment:
        return 'Assignment';
      case TaskCategory.exam:
        return 'Exam';
      case TaskCategory.project:
        return 'Project';
      case TaskCategory.lab:
        return 'Lab';
      case TaskCategory.reading:
        return 'Reading';
      case TaskCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.assignment:
        return const Color(0xFF8B5CF6);
      case TaskCategory.exam:
        return const Color(0xFFEF4444);
      case TaskCategory.project:
        return const Color(0xFF3B82F6);
      case TaskCategory.lab:
        return const Color(0xFF10B981);
      case TaskCategory.reading:
        return const Color(0xFFF59E0B);
      case TaskCategory.other:
        return const Color(0xFF6B7280);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.assignment:
        return Icons.assignment_outlined;
      case TaskCategory.exam:
        return Icons.quiz_outlined;
      case TaskCategory.project:
        return Icons.folder_outlined;
      case TaskCategory.lab:
        return Icons.science_outlined;
      case TaskCategory.reading:
        return Icons.menu_book_outlined;
      case TaskCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFF6B7280);
      case TaskStatus.inProgress:
        return const Color(0xFF3B82F6);
      case TaskStatus.completed:
        return const Color(0xFF10B981);
      case TaskStatus.overdue:
        return const Color(0xFFEF4444);
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String? courseName;
  final String? courseCode;
  final TaskCategory category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? estimatedMinutes;
  final List<String>? subtasks;
  final List<String>? completedSubtasks;
  final bool isBookmarked;
  final String? attachmentUrl;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.courseName,
    this.courseCode,
    required this.category,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.completedAt,
    this.estimatedMinutes,
    this.subtasks,
    this.completedSubtasks,
    this.isBookmarked = false,
    this.attachmentUrl,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseName,
    String? courseCode,
    TaskCategory? category,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? estimatedMinutes,
    List<String>? subtasks,
    List<String>? completedSubtasks,
    bool? isBookmarked,
    String? attachmentUrl,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      subtasks: subtasks ?? this.subtasks,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  bool get isOverdue =>
      status != TaskStatus.completed && dueDate.isBefore(DateTime.now());

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  double get subtaskProgress {
    if (subtasks == null || subtasks!.isEmpty) return 0;
    if (completedSubtasks == null || completedSubtasks!.isEmpty) return 0;
    return completedSubtasks!.length / subtasks!.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseName': courseName,
      'courseCode': courseCode,
      'category': category.index,
      'priority': priority.index,
      'status': status.index,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'subtasks': subtasks,
      'completedSubtasks': completedSubtasks,
      'isBookmarked': isBookmarked,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      courseName: map['courseName'] as String?,
      courseCode: map['courseCode'] as String?,
      category: TaskCategory.values[map['category'] as int],
      priority: TaskPriority.values[map['priority'] as int],
      status: TaskStatus.values[map['status'] as int],
      dueDate: DateTime.parse(map['dueDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      estimatedMinutes: map['estimatedMinutes'] as int?,
      subtasks: (map['subtasks'] as List<dynamic>?)?.cast<String>(),
      completedSubtasks:
          (map['completedSubtasks'] as List<dynamic>?)?.cast<String>(),
      isBookmarked: map['isBookmarked'] as bool? ?? false,
      attachmentUrl: map['attachmentUrl'] as String?,
    );
  }
}
