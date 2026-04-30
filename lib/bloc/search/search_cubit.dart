import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../assignments/assignment_bloc.dart';
import '../tasks/tasks_cubit.dart';
import '../tasks/tasks_state.dart';
import '../labs/labs_cubit.dart';
import '../grades/grades_cubit.dart';
import '../notifications/notification_cubit.dart';
import '../../models/task_model.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounce;
  List<String> _recentSearches = [];

  // Feature items for quick access search
  static final List<_FeatureItem> _features = [
    _FeatureItem(
      'Dashboard',
      '/dashboard',
      Icons.dashboard_rounded,
      'Home dashboard overview',
    ),
    _FeatureItem(
      'Courses',
      '/courses',
      Icons.school_rounded,
      'Browse enrolled courses',
    ),
    _FeatureItem(
      'AI Quiz',
      '/ai-quiz-generator',
      Icons.quiz_rounded,
      'Generate AI quizzes',
    ),
    _FeatureItem(
      'Flashcards',
      '/flashcards',
      Icons.style_rounded,
      'Study with flashcards',
    ),
    _FeatureItem(
      'Tasks',
      '/tasks',
      Icons.task_alt_rounded,
      'Manage your tasks',
    ),
    _FeatureItem('Labs', '/labs', Icons.science_rounded, 'Lab sessions'),
    _FeatureItem(
      'Assignments',
      '/assignments',
      Icons.assignment_rounded,
      'View assignments',
    ),
    _FeatureItem(
      'Grades',
      '/grades',
      Icons.grade_rounded,
      'Academic performance',
    ),
    _FeatureItem(
      'Grade Analysis',
      '/grade-analysis',
      Icons.analytics_rounded,
      'Performance insights',
    ),
    _FeatureItem(
      'Calendar',
      '/calendar',
      Icons.calendar_month_rounded,
      'Schedule and events',
    ),
    _FeatureItem('Messages', '/messages', Icons.chat_rounded, 'Chat messages'),
    _FeatureItem(
      'Notifications',
      '/notifications',
      Icons.notifications_rounded,
      'Your notifications',
    ),
    _FeatureItem(
      'AI Chat',
      '/ai-chat',
      Icons.smart_toy_rounded,
      'AI assistant',
    ),
    _FeatureItem(
      'Voice to Text',
      '/voice-to-text',
      Icons.mic_rounded,
      'Voice recording',
    ),
    _FeatureItem(
      'Summarizer',
      '/summarizer',
      Icons.summarize_rounded,
      'Text summarizer',
    ),
    _FeatureItem(
      'Attendance',
      '/attendance',
      Icons.fact_check_rounded,
      'Attendance records',
    ),
    _FeatureItem(
      'Leaderboard',
      '/gamification',
      Icons.leaderboard_rounded,
      'Gamification & rewards',
    ),
    _FeatureItem('Profile', '/profile', Icons.person_rounded, 'Your profile'),
    _FeatureItem(
      'Settings',
      '/settings',
      Icons.settings_rounded,
      'App settings',
    ),
  ];

  SearchCubit() : super(const SearchInitial());

  void search(String query, BuildContext context) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(
        SearchInitial(recentSearches: _recentSearches, filter: state.filter),
      );
      return;
    }

    emit(
      SearchLoading(
        query: query,
        filter: state.filter,
        recentSearches: _recentSearches,
        results: state.results,
      ),
    );

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query, context);
    });
  }

  void _performSearch(String query, BuildContext context) {
    try {
      final normalizedQuery = query.toLowerCase().trim();
      final results = <SearchResultItem>[];

      // Search features/screens
      results.addAll(_searchFeatures(normalizedQuery));

      // Search tasks
      results.addAll(_searchTasks(context, normalizedQuery));

      // Search assignments
      results.addAll(_searchAssignments(context, normalizedQuery));

      // Search labs
      results.addAll(_searchLabs(context, normalizedQuery));

      // Search grades/courses
      results.addAll(_searchGrades(context, normalizedQuery));

      // Search notifications
      results.addAll(_searchNotifications(context, normalizedQuery));

      // Apply additional filters
      final filtered = _applyFilters(results);

      if (filtered.isEmpty) {
        emit(
          SearchEmpty(
            query: query,
            filter: state.filter,
            recentSearches: _recentSearches,
          ),
        );
      } else {
        emit(
          SearchLoaded(
            query: query,
            results: filtered,
            totalCount: filtered.length,
            filter: state.filter,
            recentSearches: _recentSearches,
          ),
        );
      }
    } catch (e) {
      emit(
        SearchError(
          message: e.toString(),
          query: query,
          filter: state.filter,
          recentSearches: _recentSearches,
        ),
      );
    }
  }

  List<SearchResultItem> _searchFeatures(String query) {
    return _features
        .where(
          (f) =>
              f.name.toLowerCase().contains(query) ||
              f.description.toLowerCase().contains(query),
        )
        .map(
          (f) => SearchResultItem(
            id: 'feature_${f.route}',
            title: f.name,
            subtitle: f.description,
            type: SearchResultType.feature,
            icon: f.icon,
            iconColor: const Color(0xFF155DFC),
            route: f.route,
          ),
        )
        .toList();
  }

  List<SearchResultItem> _searchTasks(BuildContext context, String query) {
    try {
      final tasksCubit = context.read<TasksCubit>();
      final tasksState = tasksCubit.state;
      if (tasksState is! TasksLoaded) return [];

      return tasksState.tasks
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                (t.description?.toLowerCase().contains(query) ?? false) ||
                (t.courseName?.toLowerCase().contains(query) ?? false) ||
                t.category.name.toLowerCase().contains(query) ||
                t.status.name.toLowerCase().contains(query),
          )
          .map(
            (t) => SearchResultItem(
              id: 'task_${t.id}',
              title: t.title,
              subtitle: t.courseName ?? t.category.name,
              description: t.description,
              type: SearchResultType.task,
              icon: _getTaskIcon(t.category),
              iconColor: _getTaskPriorityColor(t.priority),
              route: '/tasks',
              date: t.dueDate,
              status: t.status.name,
              progress: t.status == TaskStatus.completed ? 1.0 : null,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<SearchResultItem> _searchAssignments(
    BuildContext context,
    String query,
  ) {
    try {
      final bloc = context.read<AssignmentBloc>();
      final aState = bloc.state;
      if (aState.isLoading || aState.assignments.isEmpty) return [];

      return aState.assignments
          .where(
            (a) =>
                a.title.toLowerCase().contains(query) ||
                a.courseName.toLowerCase().contains(query) ||
                (a.description?.toLowerCase().contains(query) ?? false) ||
                a.instructorName.toLowerCase().contains(query),
          )
          .map(
            (a) => SearchResultItem(
              id: 'assignment_${a.id}',
              title: a.title,
              subtitle: a.courseName,
              description: a.description,
              type: SearchResultType.assignment,
              icon: Icons.assignment_rounded,
              iconColor: const Color(0xFFF59E0B),
              route: '/assignments',
              date: a.dueDate,
              status: a.submissionFilterStatus,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<SearchResultItem> _searchLabs(BuildContext context, String query) {
    try {
      final cubit = context.read<LabsCubit>();
      final lState = cubit.state;
      if (lState.isLoading || lState.labs.isEmpty) return [];

      return lState.labs
          .where(
            (l) =>
                l.title.toLowerCase().contains(query) ||
                (l.course?.name.toLowerCase().contains(query) ?? false) ||
                (l.description?.toLowerCase().contains(query) ?? false),
          )
          .map(
            (l) => SearchResultItem(
              id: 'lab_${l.id}',
              title: l.title,
              subtitle: l.course?.name ?? 'Course ${l.courseId}',
              description: l.description,
              type: SearchResultType.lab,
              icon: Icons.science_rounded,
              iconColor: const Color(0xFF06B6D4),
              route: '/labs',
              date: l.dueDate,
              status: l.status.name,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<SearchResultItem> _searchGrades(BuildContext context, String query) {
    try {
      final cubit = context.read<GradesCubit>();
      final gState = cubit.state;
      if (gState.isLoading || gState.courses.isEmpty) return [];

      return gState.courses
          .where(
            (c) =>
                c.courseName.toLowerCase().contains(query) ||
                c.courseCode.toLowerCase().contains(query) ||
                c.instructor.toLowerCase().contains(query),
          )
          .map(
            (c) => SearchResultItem(
              id: 'grade_${c.id}',
              title: c.courseName,
              subtitle: '${c.courseCode} • ${c.instructor}',
              type: SearchResultType.grade,
              icon: Icons.grade_rounded,
              iconColor: const Color(0xFF10B981),
              route: '/grades',
              progress: c.currentPercentage / 100,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<SearchResultItem> _searchNotifications(
    BuildContext context,
    String query,
  ) {
    try {
      final cubit = context.read<NotificationCubit>();
      final nState = cubit.state;
      if (nState.notifications.isEmpty) return [];

      return nState.notifications
          .where(
            (n) =>
                n.title.toLowerCase().contains(query) ||
                n.message.toLowerCase().contains(query) ||
                (n.courseName?.toLowerCase().contains(query) ?? false),
          )
          .take(5)
          .map(
            (n) => SearchResultItem(
              id: 'notif_${n.id}',
              title: n.title,
              subtitle: n.message,
              type: SearchResultType.message,
              icon: Icons.notifications_rounded,
              iconColor: const Color(0xFF8B5CF6),
              route: '/notifications',
              date: n.createdAt,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<SearchResultItem> _applyFilters(List<SearchResultItem> results) {
    var filtered = List<SearchResultItem>.from(results);
    final f = state.filter;

    if (f.status != null) {
      filtered = filtered.where((r) => r.status == f.status).toList();
    }

    if (f.dateFrom != null) {
      filtered = filtered
          .where((r) => r.date == null || r.date!.isAfter(f.dateFrom!))
          .toList();
    }
    if (f.dateTo != null) {
      filtered = filtered
          .where(
            (r) =>
                r.date == null ||
                r.date!.isBefore(f.dateTo!.add(const Duration(days: 1))),
          )
          .toList();
    }

    if (f.sortBy != null) {
      switch (f.sortBy) {
        case 'date':
          filtered.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return f.ascending
                ? a.date!.compareTo(b.date!)
                : b.date!.compareTo(a.date!);
          });
          break;
        case 'name':
          filtered.sort(
            (a, b) => f.ascending
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title),
          );
          break;
        case 'type':
          filtered.sort((a, b) => a.type.index.compareTo(b.type.index));
          break;
      }
    }

    return filtered;
  }

  void setFilter(SearchFilter filter, BuildContext context) {
    if (state.query.isNotEmpty) {
      emit(
        SearchLoading(
          query: state.query,
          filter: filter,
          recentSearches: _recentSearches,
          results: state.results,
        ),
      );
      _performSearch(state.query, context);
    } else {
      emit(SearchInitial(recentSearches: _recentSearches, filter: filter));
    }
  }

  void setCategory(SearchCategory category, BuildContext context) {
    final newFilter = state.filter.copyWith(category: category);
    setFilter(newFilter, context);
  }

  void addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    emit(SearchInitial(recentSearches: _recentSearches, filter: state.filter));
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    emit(SearchInitial(recentSearches: _recentSearches, filter: state.filter));
  }

  void clearSearch() {
    emit(
      SearchInitial(
        recentSearches: _recentSearches,
        filter: const SearchFilter(),
      ),
    );
  }

  void clearFilters(BuildContext context) {
    setFilter(SearchFilter(category: state.filter.category), context);
  }

  IconData _getTaskIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.assignment:
        return Icons.assignment_rounded;
      case TaskCategory.exam:
        return Icons.quiz_rounded;
      case TaskCategory.project:
        return Icons.work_rounded;
      case TaskCategory.lab:
        return Icons.science_rounded;
      case TaskCategory.reading:
        return Icons.menu_book_rounded;
      case TaskCategory.other:
        return Icons.task_alt_rounded;
    }
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.urgent:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

class _FeatureItem {
  final String name;
  final String route;
  final IconData icon;
  final String description;

  const _FeatureItem(this.name, this.route, this.icon, this.description);
}
