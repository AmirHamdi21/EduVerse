import 'package:equatable/equatable.dart';

// Enums
enum SmartStudyTab { topicsToReview, studySchedule }

enum TopicDifficulty { easy, medium, hard, all }

enum TopicUrgency { high, medium, low, all }

enum TopicStatus { belowAverage, slightlyBehind, goodProgress, onTrack }

enum TaskType { lecture, quiz, flashcards, lab, review, practice }

// Models
class StudyTopic extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final double progressPercent;
  final TopicStatus status;
  final String statusMessage;
  final String recommendation;
  final String actionLabel;
  final String courseName;
  final TopicDifficulty difficulty;
  final TopicUrgency urgency;
  final DateTime lastStudied;

  const StudyTopic({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.progressPercent,
    required this.status,
    required this.statusMessage,
    required this.recommendation,
    required this.actionLabel,
    required this.courseName,
    required this.difficulty,
    required this.urgency,
    required this.lastStudied,
  });

  @override
  List<Object?> get props => [id, title, progressPercent, status, courseName];
}

class ScheduleTask extends Equatable {
  final String id;
  final String title;
  final TaskType type;
  final DateTime startTime;
  final DateTime endTime;
  final String courseName;
  final bool isCompleted;

  const ScheduleTask({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.courseName,
    this.isCompleted = false,
  });

  ScheduleTask copyWith({
    String? id,
    String? title,
    TaskType? type,
    DateTime? startTime,
    DateTime? endTime,
    String? courseName,
    bool? isCompleted,
  }) {
    return ScheduleTask(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      courseName: courseName ?? this.courseName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, type, startTime, endTime, isCompleted];
}

class AiInsight extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime? generatedAt;
  final bool isBookmarked;

  const AiInsight({
    required this.id,
    required this.title,
    required this.message,
    this.generatedAt,
    this.isBookmarked = false,
  });

  AiInsight copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? generatedAt,
    bool? isBookmarked,
  }) {
    return AiInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      generatedAt: generatedAt ?? this.generatedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [id, title, message, generatedAt, isBookmarked];
}

class DaySchedule extends Equatable {
  final DateTime date;
  final List<ScheduleTask> tasks;

  const DaySchedule({required this.date, required this.tasks});

  @override
  List<Object?> get props => [date, tasks];
}

// State
class SmartStudyState extends Equatable {
  final SmartStudyTab currentTab;
  final List<StudyTopic> topics;
  final List<StudyTopic> filteredTopics;
  final List<DaySchedule> weekSchedule;
  final AiInsight? aiInsight;
  final String? selectedCourse;
  final TopicDifficulty selectedDifficulty;
  final TopicUrgency selectedUrgency;
  final List<String> availableCourses;
  final bool isLoading;
  final bool isRegenerating;
  final bool isOptimizing;
  final bool isExporting;
  final bool isSyncing;
  final String? errorMessage;
  final String? successMessage;

  const SmartStudyState({
    this.currentTab = SmartStudyTab.topicsToReview,
    this.topics = const [],
    this.filteredTopics = const [],
    this.weekSchedule = const [],
    this.aiInsight,
    this.selectedCourse,
    this.selectedDifficulty = TopicDifficulty.all,
    this.selectedUrgency = TopicUrgency.all,
    this.availableCourses = const [],
    this.isLoading = false,
    this.isRegenerating = false,
    this.isOptimizing = false,
    this.isExporting = false,
    this.isSyncing = false,
    this.errorMessage,
    this.successMessage,
  });

  SmartStudyState copyWith({
    SmartStudyTab? currentTab,
    List<StudyTopic>? topics,
    List<StudyTopic>? filteredTopics,
    List<DaySchedule>? weekSchedule,
    AiInsight? aiInsight,
    String? selectedCourse,
    TopicDifficulty? selectedDifficulty,
    TopicUrgency? selectedUrgency,
    List<String>? availableCourses,
    bool? isLoading,
    bool? isRegenerating,
    bool? isOptimizing,
    bool? isExporting,
    bool? isSyncing,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearCourse = false,
    bool clearSuccess = false,
  }) {
    return SmartStudyState(
      currentTab: currentTab ?? this.currentTab,
      topics: topics ?? this.topics,
      filteredTopics: filteredTopics ?? this.filteredTopics,
      weekSchedule: weekSchedule ?? this.weekSchedule,
      aiInsight: aiInsight ?? this.aiInsight,
      selectedCourse: clearCourse
          ? null
          : (selectedCourse ?? this.selectedCourse),
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedUrgency: selectedUrgency ?? this.selectedUrgency,
      availableCourses: availableCourses ?? this.availableCourses,
      isLoading: isLoading ?? this.isLoading,
      isRegenerating: isRegenerating ?? this.isRegenerating,
      isOptimizing: isOptimizing ?? this.isOptimizing,
      isExporting: isExporting ?? this.isExporting,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    currentTab,
    topics,
    filteredTopics,
    weekSchedule,
    aiInsight,
    selectedCourse,
    selectedDifficulty,
    selectedUrgency,
    availableCourses,
    isLoading,
    isRegenerating,
    isOptimizing,
    isExporting,
    isSyncing,
    errorMessage,
    successMessage,
  ];
}
