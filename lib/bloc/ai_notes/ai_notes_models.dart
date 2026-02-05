import 'package:flutter/material.dart';

/// Category/Course for notes
class NoteCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const NoteCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

/// AI-generated note model
class AINote {
  final String id;
  final String title;
  final String content;
  final String summary;
  final NoteCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorited;
  final bool isExpanded;
  final List<String> keyTopics;
  final List<String> tags;
  final NoteSource source;
  final AIGeneratedContent? aiContent;

  const AINote({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorited = false,
    this.isExpanded = false,
    this.keyTopics = const [],
    this.tags = const [],
    this.source = NoteSource.lecture,
    this.aiContent,
  });

  AINote copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    NoteCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorited,
    bool? isExpanded,
    List<String>? keyTopics,
    List<String>? tags,
    NoteSource? source,
    AIGeneratedContent? aiContent,
  }) {
    return AINote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorited: isFavorited ?? this.isFavorited,
      isExpanded: isExpanded ?? this.isExpanded,
      keyTopics: keyTopics ?? this.keyTopics,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      aiContent: aiContent ?? this.aiContent,
    );
  }
}

/// Source of the note
enum NoteSource {
  lecture,
  textbook,
  video,
  article,
  manual,
}

extension NoteSourceExtension on NoteSource {
  String get displayName {
    switch (this) {
      case NoteSource.lecture:
        return 'Lecture';
      case NoteSource.textbook:
        return 'Textbook';
      case NoteSource.video:
        return 'Video';
      case NoteSource.article:
        return 'Article';
      case NoteSource.manual:
        return 'Manual';
    }
  }

  IconData get icon {
    switch (this) {
      case NoteSource.lecture:
        return Icons.school_rounded;
      case NoteSource.textbook:
        return Icons.menu_book_rounded;
      case NoteSource.video:
        return Icons.video_library_rounded;
      case NoteSource.article:
        return Icons.article_rounded;
      case NoteSource.manual:
        return Icons.edit_note_rounded;
    }
  }
}

/// AI-generated additional content
class AIGeneratedContent {
  final List<String> flashcards;
  final List<QuizQuestion> practiceQuestions;
  final List<String> relatedConcepts;
  final String? mindMapData;

  const AIGeneratedContent({
    this.flashcards = const [],
    this.practiceQuestions = const [],
    this.relatedConcepts = const [],
    this.mindMapData,
  });
}

/// Practice quiz question
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

/// AI Study Recommendation
class StudyRecommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String? noteId;
  final DateTime? dueDate;
  final bool isNew;

  const StudyRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.noteId,
    this.dueDate,
    this.isNew = false,
  });
}

/// Type of recommendation
enum RecommendationType {
  reviewTopic,
  relatedConcept,
  upcomingQuiz,
  flashcardSuggestion,
}

extension RecommendationTypeExtension on RecommendationType {
  IconData get icon {
    switch (this) {
      case RecommendationType.reviewTopic:
        return Icons.rate_review_rounded;
      case RecommendationType.relatedConcept:
        return Icons.lightbulb_rounded;
      case RecommendationType.upcomingQuiz:
        return Icons.quiz_rounded;
      case RecommendationType.flashcardSuggestion:
        return Icons.style_rounded;
    }
  }

  Color get color {
    switch (this) {
      case RecommendationType.reviewTopic:
        return const Color(0xFF3B82F6);
      case RecommendationType.relatedConcept:
        return const Color(0xFF8B5CF6);
      case RecommendationType.upcomingQuiz:
        return const Color(0xFFF59E0B);
      case RecommendationType.flashcardSuggestion:
        return const Color(0xFF10B981);
    }
  }
}

/// Filter options for notes
enum NotesFilter {
  all,
  byCourse,
  byDate,
  favorites,
}

/// Sort options for notes
enum NotesSort {
  dateNewest,
  dateOldest,
  titleAZ,
  titleZA,
  courseAZ,
}

extension NotesSortExtension on NotesSort {
  String get displayName {
    switch (this) {
      case NotesSort.dateNewest:
        return 'Newest First';
      case NotesSort.dateOldest:
        return 'Oldest First';
      case NotesSort.titleAZ:
        return 'Title A-Z';
      case NotesSort.titleZA:
        return 'Title Z-A';
      case NotesSort.courseAZ:
        return 'Course A-Z';
    }
  }
}

/// Quick stats for the notes dashboard
class NotesQuickStats {
  final int totalNotes;
  final int favoritedCount;
  final int coursesCount;
  final int notesThisWeek;
  final Duration totalStudyTime;

  const NotesQuickStats({
    this.totalNotes = 0,
    this.favoritedCount = 0,
    this.coursesCount = 0,
    this.notesThisWeek = 0,
    this.totalStudyTime = Duration.zero,
  });
}

/// Predefined categories
class NoteCategories {
  static const machineLearning = NoteCategory(
    id: 'ml',
    name: 'Machine Learning',
    color: Color(0xFF3B82F6),
    icon: Icons.psychology_rounded,
  );

  static const dataStructures = NoteCategory(
    id: 'ds',
    name: 'Data Structures',
    color: Color(0xFF8B5CF6),
    icon: Icons.account_tree_rounded,
  );

  static const webDevelopment = NoteCategory(
    id: 'web',
    name: 'Web Development',
    color: Color(0xFF06B6D4),
    icon: Icons.web_rounded,
  );

  static const deepLearning = NoteCategory(
    id: 'dl',
    name: 'Deep Learning',
    color: Color(0xFFEC4899),
    icon: Icons.hub_rounded,
  );

  static const databases = NoteCategory(
    id: 'db',
    name: 'Database Systems',
    color: Color(0xFF10B981),
    icon: Icons.storage_rounded,
  );

  static const algorithms = NoteCategory(
    id: 'algo',
    name: 'Algorithms',
    color: Color(0xFFF59E0B),
    icon: Icons.code_rounded,
  );

  static const List<NoteCategory> all = [
    machineLearning,
    dataStructures,
    webDevelopment,
    deepLearning,
    databases,
    algorithms,
  ];
}
