import '../../models/quiz/quiz_api_models.dart';

// ── Quiz Management State (shared by Instructor & TA) ────────────────────────

abstract class QuizManagementState {
  const QuizManagementState();
}

class QuizMgmtInitial extends QuizManagementState {
  const QuizMgmtInitial();
}

class QuizMgmtLoading extends QuizManagementState {
  const QuizMgmtLoading();
}

class QuizMgmtLoaded extends QuizManagementState {
  final List<QuizModel> quizzes;
  final String searchQuery;
  final String statusFilter;
  final String courseFilter;

  // Sub-views: attempts list, statistics (loaded on demand per quiz)
  final Map<int, List<QuizAttemptModel>> attemptsMap;
  final Map<int, QuizStatisticsModel> statisticsMap;
  final Map<int, bool> loadingAttempts;
  final Map<int, bool> loadingStatistics;

  const QuizMgmtLoaded({
    required this.quizzes,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.courseFilter = 'all',
    this.attemptsMap = const {},
    this.statisticsMap = const {},
    this.loadingAttempts = const {},
    this.loadingStatistics = const {},
  });

  List<QuizModel> get filteredQuizzes {
    return quizzes.where((q) {
      final matchesSearch =
          searchQuery.isEmpty ||
          q.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          q.courseName.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus =
          statusFilter == 'all' || q.status.toJson() == statusFilter;

      final matchesCourse =
          courseFilter == 'all' || q.courseName == courseFilter;

      return matchesSearch && matchesStatus && matchesCourse;
    }).toList();
  }

  /// Unique course names for filter dropdown
  List<String> get courseNames {
    return quizzes.map((q) => q.courseName).toSet().toList()..sort();
  }

  QuizMgmtLoaded copyWith({
    List<QuizModel>? quizzes,
    String? searchQuery,
    String? statusFilter,
    String? courseFilter,
    Map<int, List<QuizAttemptModel>>? attemptsMap,
    Map<int, QuizStatisticsModel>? statisticsMap,
    Map<int, bool>? loadingAttempts,
    Map<int, bool>? loadingStatistics,
  }) {
    return QuizMgmtLoaded(
      quizzes: quizzes ?? this.quizzes,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      courseFilter: courseFilter ?? this.courseFilter,
      attemptsMap: attemptsMap ?? this.attemptsMap,
      statisticsMap: statisticsMap ?? this.statisticsMap,
      loadingAttempts: loadingAttempts ?? this.loadingAttempts,
      loadingStatistics: loadingStatistics ?? this.loadingStatistics,
    );
  }
}

class QuizMgmtError extends QuizManagementState {
  final String message;
  const QuizMgmtError(this.message);
}

/// Transient state while a CUD operation is in-flight.
class QuizMgmtOperating extends QuizManagementState {
  final String operation; // e.g. 'creating', 'deleting', 'grading'
  const QuizMgmtOperating(this.operation);
}
