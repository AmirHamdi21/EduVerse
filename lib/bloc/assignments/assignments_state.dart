import 'package:equatable/equatable.dart';
import '../../models/assignments/assignment_model.dart';

enum AssignmentsSortBy { dueDate, name, course, status, priority, type }

enum AssignmentsViewMode { list, grid, timeline }

class AssignmentsFilter extends Equatable {
  final AssignmentStatus? status;
  final AssignmentType? type;
  final AssignmentPriority? priority;
  final String? courseName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const AssignmentsFilter({
    this.status,
    this.type,
    this.priority,
    this.courseName,
    this.dateFrom,
    this.dateTo,
  });

  AssignmentsFilter copyWith({
    AssignmentStatus? status,
    AssignmentType? type,
    AssignmentPriority? priority,
    String? courseName,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearStatus = false,
    bool clearType = false,
    bool clearPriority = false,
    bool clearCourse = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return AssignmentsFilter(
      status: clearStatus ? null : (status ?? this.status),
      type: clearType ? null : (type ?? this.type),
      priority: clearPriority ? null : (priority ?? this.priority),
      courseName: clearCourse ? null : (courseName ?? this.courseName),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  bool get hasActiveFilters =>
      status != null ||
      type != null ||
      priority != null ||
      courseName != null ||
      dateFrom != null ||
      dateTo != null;

  AssignmentsFilter clear() => const AssignmentsFilter();

  @override
  List<Object?> get props => [
    status,
    type,
    priority,
    courseName,
    dateFrom,
    dateTo,
  ];
}

class AssignmentsState extends Equatable {
  final List<AssignmentModel> assignments;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final AssignmentsFilter filter;
  final AssignmentsSortBy sortBy;
  final bool sortAscending;
  final AssignmentsViewMode viewMode;
  final int selectedTabIndex;

  const AssignmentsState({
    this.assignments = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filter = const AssignmentsFilter(),
    this.sortBy = AssignmentsSortBy.dueDate,
    this.sortAscending = true,
    this.viewMode = AssignmentsViewMode.list,
    this.selectedTabIndex = 0,
  });

  AssignmentsState copyWith({
    List<AssignmentModel>? assignments,
    bool? isLoading,
    String? error,
    String? searchQuery,
    AssignmentsFilter? filter,
    AssignmentsSortBy? sortBy,
    bool? sortAscending,
    AssignmentsViewMode? viewMode,
    int? selectedTabIndex,
    bool clearError = false,
  }) {
    return AssignmentsState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      viewMode: viewMode ?? this.viewMode,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  List<AssignmentModel> get filteredAssignments {
    var result = List<AssignmentModel>.from(assignments);

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.courseName.toLowerCase().contains(query) ||
            a.courseCode.toLowerCase().contains(query) ||
            a.instructorName.toLowerCase().contains(query) ||
            (a.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply filters
    if (filter.status != null) {
      result = result.where((a) => a.status == filter.status).toList();
    }
    if (filter.type != null) {
      result = result.where((a) => a.type == filter.type).toList();
    }
    if (filter.priority != null) {
      result = result.where((a) => a.priority == filter.priority).toList();
    }
    if (filter.courseName != null) {
      result = result.where((a) => a.courseName == filter.courseName).toList();
    }
    if (filter.dateFrom != null) {
      result = result
          .where((a) => a.dueDate.isAfter(filter.dateFrom!))
          .toList();
    }
    if (filter.dateTo != null) {
      result = result.where((a) => a.dueDate.isBefore(filter.dateTo!)).toList();
    }

    // Apply tab filter
    switch (selectedTabIndex) {
      case 1: // Pending
        result = result
            .where((a) => a.status == AssignmentStatus.pending)
            .toList();
        break;
      case 2: // Submitted
        result = result
            .where(
              (a) =>
                  a.status == AssignmentStatus.submitted ||
                  a.status == AssignmentStatus.late,
            )
            .toList();
        break;
      case 3: // Graded
        result = result
            .where((a) => a.status == AssignmentStatus.graded)
            .toList();
        break;
      case 4: // Overdue
        result = result
            .where((a) => a.status == AssignmentStatus.overdue || a.isOverdue)
            .toList();
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case AssignmentsSortBy.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case AssignmentsSortBy.name:
          comparison = a.title.compareTo(b.title);
          break;
        case AssignmentsSortBy.course:
          comparison = a.courseName.compareTo(b.courseName);
          break;
        case AssignmentsSortBy.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case AssignmentsSortBy.priority:
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case AssignmentsSortBy.type:
          comparison = a.type.index.compareTo(b.type.index);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  // Stats getters
  int get totalAssignments => assignments.length;
  int get pendingCount => assignments
      .where(
        (a) =>
            a.status == AssignmentStatus.pending ||
            a.status == AssignmentStatus.overdue,
      )
      .length;
  int get submittedCount => assignments
      .where(
        (a) =>
            a.status == AssignmentStatus.submitted ||
            a.status == AssignmentStatus.late,
      )
      .length;
  int get gradedCount =>
      assignments.where((a) => a.status == AssignmentStatus.graded).length;
  int get overdueCount => assignments
      .where((a) => a.status == AssignmentStatus.overdue || a.isOverdue)
      .length;
  int get dueTodayCount => assignments.where((a) => a.isDueToday).length;
  int get dueTomorrowCount => assignments.where((a) => a.isDueTomorrow).length;

  double get averageGrade {
    final graded = assignments.where((a) => a.grade != null).toList();
    if (graded.isEmpty) return 0;
    final sum = graded.fold<double>(
      0,
      (sum, a) => sum + (a.gradePercentage ?? 0),
    );
    return sum / graded.length;
  }

  List<String> get availableCourses =>
      assignments.map((a) => a.courseName).toSet().toList()..sort();

  @override
  List<Object?> get props => [
    assignments,
    isLoading,
    error,
    searchQuery,
    filter,
    sortBy,
    sortAscending,
    viewMode,
    selectedTabIndex,
  ];
}
