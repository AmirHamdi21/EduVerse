import 'package:equatable/equatable.dart';
import 'package:edu_verse/models/task_model.dart';

enum TasksViewMode { list, calendar, kanban }

enum TasksSortBy { dueDate, priority, category, status, createdAt }

class TasksFilter {
  final TaskStatus? status;
  final TaskPriority? priority;
  final TaskCategory? category;
  final String? courseCode;
  final bool? isBookmarked;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;

  const TasksFilter({
    this.status,
    this.priority,
    this.category,
    this.courseCode,
    this.isBookmarked,
    this.dueDateFrom,
    this.dueDateTo,
  });

  TasksFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    TaskCategory? category,
    String? courseCode,
    bool? isBookmarked,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearCategory = false,
    bool clearCourseCode = false,
    bool clearIsBookmarked = false,
    bool clearDueDateFrom = false,
    bool clearDueDateTo = false,
  }) {
    return TasksFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      category: clearCategory ? null : (category ?? this.category),
      courseCode: clearCourseCode ? null : (courseCode ?? this.courseCode),
      isBookmarked:
          clearIsBookmarked ? null : (isBookmarked ?? this.isBookmarked),
      dueDateFrom: clearDueDateFrom ? null : (dueDateFrom ?? this.dueDateFrom),
      dueDateTo: clearDueDateTo ? null : (dueDateTo ?? this.dueDateTo),
    );
  }

  bool get hasActiveFilters =>
      status != null ||
      priority != null ||
      category != null ||
      courseCode != null ||
      isBookmarked != null ||
      dueDateFrom != null ||
      dueDateTo != null;

  int get activeFilterCount {
    int count = 0;
    if (status != null) count++;
    if (priority != null) count++;
    if (category != null) count++;
    if (courseCode != null) count++;
    if (isBookmarked != null) count++;
    if (dueDateFrom != null || dueDateTo != null) count++;
    return count;
  }

  TasksFilter clear() => const TasksFilter();
}

abstract class TasksState extends Equatable {
  final List<TaskModel> tasks;
  final TasksFilter filter;
  final TasksSortBy sortBy;
  final bool sortAscending;
  final TasksViewMode viewMode;
  final String searchQuery;

  const TasksState({
    this.tasks = const [],
    this.filter = const TasksFilter(),
    this.sortBy = TasksSortBy.dueDate,
    this.sortAscending = true,
    this.viewMode = TasksViewMode.list,
    this.searchQuery = '',
  });

  List<TaskModel> get filteredTasks {
    var result = tasks.where((task) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !(task.description?.toLowerCase().contains(query) ?? false) &&
            !(task.courseName?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Status filter
      if (filter.status != null && task.status != filter.status) {
        return false;
      }

      // Priority filter
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }

      // Category filter
      if (filter.category != null && task.category != filter.category) {
        return false;
      }

      // Course filter
      if (filter.courseCode != null && task.courseCode != filter.courseCode) {
        return false;
      }

      // Bookmark filter
      if (filter.isBookmarked != null &&
          task.isBookmarked != filter.isBookmarked) {
        return false;
      }

      // Due date range filter
      if (filter.dueDateFrom != null &&
          task.dueDate.isBefore(filter.dueDateFrom!)) {
        return false;
      }
      if (filter.dueDateTo != null && task.dueDate.isAfter(filter.dueDateTo!)) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case TasksSortBy.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case TasksSortBy.priority:
          comparison = b.priority.index.compareTo(a.priority.index);
          break;
        case TasksSortBy.category:
          comparison = a.category.index.compareTo(b.category.index);
          break;
        case TasksSortBy.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case TasksSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  // Quick access filtered lists
  List<TaskModel> get pendingTasks =>
      tasks.where((t) => t.status == TaskStatus.pending).toList();
  List<TaskModel> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskModel> get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();
  List<TaskModel> get overdueTasks => tasks.where((t) => t.isOverdue).toList();
  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return tasks
        .where((t) =>
            t.dueDate.isAfter(today) &&
            t.dueDate.isBefore(tomorrow) &&
            t.status != TaskStatus.completed)
        .toList();
  }

  List<TaskModel> get thisWeekTasks {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    return tasks
        .where((t) =>
            t.dueDate.isBefore(endOfWeek) &&
            t.dueDate.isAfter(now) &&
            t.status != TaskStatus.completed)
        .toList();
  }

  @override
  List<Object?> get props =>
      [tasks, filter, sortBy, sortAscending, viewMode, searchQuery];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading({
    super.tasks,
    super.filter,
    super.sortBy,
    super.sortAscending,
    super.viewMode,
    super.searchQuery,
  });
}

class TasksLoaded extends TasksState {
  const TasksLoaded({
    required super.tasks,
    super.filter,
    super.sortBy,
    super.sortAscending,
    super.viewMode,
    super.searchQuery,
  });

  TasksLoaded copyWith({
    List<TaskModel>? tasks,
    TasksFilter? filter,
    TasksSortBy? sortBy,
    bool? sortAscending,
    TasksViewMode? viewMode,
    String? searchQuery,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TasksError extends TasksState {
  final String message;

  const TasksError({
    required this.message,
    super.tasks,
    super.filter,
    super.sortBy,
    super.sortAscending,
    super.viewMode,
    super.searchQuery,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
