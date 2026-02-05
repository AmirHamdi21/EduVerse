import 'package:flutter_bloc/flutter_bloc.dart';
import 'smart_study_state.dart';

class SmartStudyCubit extends Cubit<SmartStudyState> {
  SmartStudyCubit() : super(const SmartStudyState());

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final topics = _generateMockTopics();
      final courses = topics.map((t) => t.courseName).toSet().toList();
      final schedule = _generateMockSchedule();
      final insight = _generateMockInsight();

      emit(state.copyWith(
        topics: topics,
        filteredTopics: topics,
        availableCourses: courses,
        weekSchedule: schedule,
        aiInsight: insight,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load study plan. Please try again.',
      ));
    }
  }

  void changeTab(SmartStudyTab tab) {
    emit(state.copyWith(currentTab: tab));
  }

  void filterByCourse(String? course) {
    emit(state.copyWith(
      selectedCourse: course,
      clearCourse: course == null,
    ));
    _applyFilters();
  }

  void filterByDifficulty(TopicDifficulty difficulty) {
    emit(state.copyWith(selectedDifficulty: difficulty));
    _applyFilters();
  }

  void filterByUrgency(TopicUrgency urgency) {
    emit(state.copyWith(selectedUrgency: urgency));
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<StudyTopic>.from(state.topics);

    if (state.selectedCourse != null) {
      filtered = filtered.where((t) => t.courseName == state.selectedCourse).toList();
    }

    if (state.selectedDifficulty != TopicDifficulty.all) {
      filtered = filtered.where((t) => t.difficulty == state.selectedDifficulty).toList();
    }

    if (state.selectedUrgency != TopicUrgency.all) {
      filtered = filtered.where((t) => t.urgency == state.selectedUrgency).toList();
    }

    emit(state.copyWith(filteredTopics: filtered));
  }

  Future<void> regeneratePlan() async {
    emit(state.copyWith(isRegenerating: true, clearError: true));

    try {
      await Future.delayed(const Duration(seconds: 2));

      final topics = _generateMockTopics(shuffle: true);
      final schedule = _generateMockSchedule(shuffle: true);
      final insight = _generateMockInsight();

      emit(state.copyWith(
        topics: topics,
        filteredTopics: topics,
        weekSchedule: schedule,
        aiInsight: insight,
        isRegenerating: false,
      ));

      _applyFilters();
    } catch (e) {
      emit(state.copyWith(
        isRegenerating: false,
        errorMessage: 'Failed to regenerate plan. Please try again.',
      ));
    }
  }

  Future<void> optimizeSchedule() async {
    emit(state.copyWith(isOptimizing: true, clearError: true));

    try {
      await Future.delayed(const Duration(seconds: 1));

      final schedule = _generateMockSchedule(optimized: true);

      emit(state.copyWith(
        weekSchedule: schedule,
        isOptimizing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isOptimizing: false,
        errorMessage: 'Failed to optimize schedule. Please try again.',
      ));
    }
  }

  void toggleTaskCompletion(String taskId) {
    final updatedSchedule = state.weekSchedule.map((day) {
      final updatedTasks = day.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(isCompleted: !task.isCompleted);
        }
        return task;
      }).toList();
      return DaySchedule(date: day.date, tasks: updatedTasks);
    }).toList();

    emit(state.copyWith(weekSchedule: updatedSchedule));
  }

  void startTopicAction(String topicId) {
    // This would navigate to the appropriate screen based on the topic
    // For now, the navigation would be handled by the UI
    // In real app: navigate to review/quiz/practice screen
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  // Mock data generators
  List<StudyTopic> _generateMockTopics({bool shuffle = false}) {
    final topics = [
      StudyTopic(
        id: '1',
        title: 'Neural Networks Fundamentals',
        imageUrl: 'assets/images/neural_networks.png',
        progressPercent: 0.45,
        status: TopicStatus.belowAverage,
        statusMessage: 'Below class average by 12%',
        recommendation: 'Revisit Lecture 3 slides',
        actionLabel: 'Start Review',
        courseName: 'Deep Learning',
        difficulty: TopicDifficulty.hard,
        urgency: TopicUrgency.high,
        lastStudied: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudyTopic(
        id: '2',
        title: 'Data Structures & Algorithms',
        imageUrl: 'assets/images/data_structures.png',
        progressPercent: 0.62,
        status: TopicStatus.slightlyBehind,
        statusMessage: 'Slightly behind on quizzes',
        recommendation: 'Take AI Quiz on Big O Notation',
        actionLabel: 'Take Quiz',
        courseName: 'Algorithms',
        difficulty: TopicDifficulty.medium,
        urgency: TopicUrgency.medium,
        lastStudied: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StudyTopic(
        id: '3',
        title: 'Machine Learning Basics',
        imageUrl: 'assets/images/machine_learning.png',
        progressPercent: 0.78,
        status: TopicStatus.goodProgress,
        statusMessage: 'Good progress, minor gaps',
        recommendation: 'Practice supervised learning exercises',
        actionLabel: 'Practice Now',
        courseName: 'ML Fundamentals',
        difficulty: TopicDifficulty.medium,
        urgency: TopicUrgency.low,
        lastStudied: DateTime.now().subtract(const Duration(days: 1)),
      ),
      StudyTopic(
        id: '4',
        title: 'Database Design Principles',
        imageUrl: 'assets/images/database.png',
        progressPercent: 0.35,
        status: TopicStatus.belowAverage,
        statusMessage: 'Needs immediate attention',
        recommendation: 'Review normalization concepts',
        actionLabel: 'Start Review',
        courseName: 'Database Systems',
        difficulty: TopicDifficulty.hard,
        urgency: TopicUrgency.high,
        lastStudied: DateTime.now().subtract(const Duration(days: 7)),
      ),
      StudyTopic(
        id: '5',
        title: 'Web Development Basics',
        imageUrl: 'assets/images/web_dev.png',
        progressPercent: 0.88,
        status: TopicStatus.onTrack,
        statusMessage: 'Excellent progress!',
        recommendation: 'Continue with advanced topics',
        actionLabel: 'Continue',
        courseName: 'Web Technologies',
        difficulty: TopicDifficulty.easy,
        urgency: TopicUrgency.low,
        lastStudied: DateTime.now(),
      ),
    ];

    if (shuffle) {
      topics.shuffle();
    }

    return topics;
  }

  List<DaySchedule> _generateMockSchedule({bool shuffle = false, bool optimized = false}) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final schedules = [
      DaySchedule(
        date: monday,
        tasks: [
          ScheduleTask(
            id: 't1',
            title: 'Neural Networks Review',
            type: TaskType.lecture,
            startTime: DateTime(monday.year, monday.month, monday.day, 18, 0),
            endTime: DateTime(monday.year, monday.month, monday.day, 19, 0),
            courseName: 'Deep Learning',
          ),
          ScheduleTask(
            id: 't2',
            title: 'Data Structures Quiz',
            type: TaskType.quiz,
            startTime: DateTime(monday.year, monday.month, monday.day, 19, 30),
            endTime: DateTime(monday.year, monday.month, monday.day, 20, 0),
            courseName: 'Algorithms',
          ),
        ],
      ),
      DaySchedule(
        date: monday.add(const Duration(days: 1)),
        tasks: [
          ScheduleTask(
            id: 't3',
            title: 'Machine Learning Flashcards',
            type: TaskType.flashcards,
            startTime: DateTime(monday.year, monday.month, monday.day + 1, 17, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + 1, 17, 30),
            courseName: 'ML Fundamentals',
          ),
          ScheduleTask(
            id: 't4',
            title: 'Algorithm Optimization Lab',
            type: TaskType.lab,
            startTime: DateTime(monday.year, monday.month, monday.day + 1, 18, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + 1, 19, 30),
            courseName: 'Algorithms',
            isCompleted: true,
          ),
        ],
      ),
      DaySchedule(
        date: monday.add(const Duration(days: 2)),
        tasks: [
          ScheduleTask(
            id: 't5',
            title: 'Review Sorting Algorithms',
            type: TaskType.review,
            startTime: DateTime(monday.year, monday.month, monday.day + 2, 16, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + 2, 17, 0),
            courseName: 'Data Structures',
          ),
        ],
      ),
      DaySchedule(
        date: monday.add(const Duration(days: 3)),
        tasks: [
          ScheduleTask(
            id: 't6',
            title: 'Database Normalization Practice',
            type: TaskType.practice,
            startTime: DateTime(monday.year, monday.month, monday.day + 3, 15, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + 3, 16, 30),
            courseName: 'Database Systems',
          ),
        ],
      ),
      DaySchedule(
        date: monday.add(const Duration(days: 4)),
        tasks: [
          ScheduleTask(
            id: 't7',
            title: 'Web Development Quiz',
            type: TaskType.quiz,
            startTime: DateTime(monday.year, monday.month, monday.day + 4, 14, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + 4, 14, 30),
            courseName: 'Web Technologies',
          ),
          ScheduleTask(
            id: 't8',
            title: 'Neural Networks Lab',
            type: TaskType.lab,
            startTime: DateTime(monday.year, monday.month, monday.day + 4, 16, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + 4, 18, 0),
            courseName: 'Deep Learning',
          ),
        ],
      ),
    ];

    if (shuffle) {
      for (var schedule in schedules) {
        schedule.tasks.shuffle();
      }
    }

    return schedules;
  }

  AiInsight _generateMockInsight() {
    final insights = [
      const AiInsight(
        id: 'insight_1',
        title: 'AI Insight',
        message:
            'Based on your quiz history and grades, you should spend more time on algorithm optimization. Your performance in this area has declined by 8% over the past two weeks. Consider reviewing dynamic programming concepts.',
        generatedAt: null,
      ),
      const AiInsight(
        id: 'insight_2',
        title: 'AI Insight',
        message:
            'Your neural networks understanding shows improvement! Focus on practical applications this week. Consider completing the lab exercises before the upcoming quiz.',
        generatedAt: null,
      ),
      const AiInsight(
        id: 'insight_3',
        title: 'AI Insight',
        message:
            'You learn best in the evening hours. I\'ve optimized your schedule to place challenging topics between 6-8 PM when your retention rate is highest.',
        generatedAt: null,
      ),
    ];

    insights.shuffle();
    return AiInsight(
      id: insights.first.id,
      title: insights.first.title,
      message: insights.first.message,
      generatedAt: DateTime.now(),
    );
  }

  void toggleInsightBookmark() {
    if (state.aiInsight == null) return;
    
    final updatedInsight = state.aiInsight!.copyWith(
      isBookmarked: !state.aiInsight!.isBookmarked,
    );
    
    emit(state.copyWith(
      aiInsight: updatedInsight,
      successMessage: updatedInsight.isBookmarked 
          ? 'Insight bookmarked successfully' 
          : 'Bookmark removed',
    ));

    // Clear success message after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(state.copyWith(clearSuccess: true));
      }
    });
  }

  Future<void> exportSchedulePdf() async {
    emit(state.copyWith(isExporting: true, clearError: true));
    
    try {
      // Simulate PDF generation
      await Future.delayed(const Duration(seconds: 2));
      
      emit(state.copyWith(
        isExporting: false,
        successMessage: 'Schedule exported successfully',
      ));

      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(clearSuccess: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        errorMessage: 'Failed to export schedule. Please try again.',
      ));
    }
  }

  Future<void> syncWithCalendar() async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    
    try {
      // Simulate calendar sync
      await Future.delayed(const Duration(seconds: 2));
      
      emit(state.copyWith(
        isSyncing: false,
        successMessage: 'Schedule synced with calendar successfully',
      ));

      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(clearSuccess: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: 'Failed to sync with calendar. Please try again.',
      ));
    }
  }

  void clearSuccess() {
    emit(state.copyWith(clearSuccess: true));
  }
}
