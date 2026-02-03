import 'package:equatable/equatable.dart';
import '../../models/labs/lab_model.dart';

enum LabsSortBy { date, name, course, status, type }

enum LabsViewMode { list, grid, calendar }

class LabsFilter extends Equatable {
  final LabStatus? status;
  final LabType? type;
  final String? courseName;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LabsFilter({
    this.status,
    this.type,
    this.courseName,
    this.dateFrom,
    this.dateTo,
  });

  LabsFilter copyWith({
    LabStatus? status,
    LabType? type,
    String? courseName,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearStatus = false,
    bool clearType = false,
    bool clearCourse = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return LabsFilter(
      status: clearStatus ? null : (status ?? this.status),
      type: clearType ? null : (type ?? this.type),
      courseName: clearCourse ? null : (courseName ?? this.courseName),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  bool get hasActiveFilters =>
      status != null ||
      type != null ||
      courseName != null ||
      dateFrom != null ||
      dateTo != null;

  LabsFilter clear() => const LabsFilter();

  @override
  List<Object?> get props => [status, type, courseName, dateFrom, dateTo];
}

class LabsState extends Equatable {
  final List<LabModel> labs;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final LabsFilter filter;
  final LabsSortBy sortBy;
  final bool sortAscending;
  final LabsViewMode viewMode;
  final int selectedTabIndex;

  const LabsState({
    this.labs = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filter = const LabsFilter(),
    this.sortBy = LabsSortBy.date,
    this.sortAscending = true,
    this.viewMode = LabsViewMode.list,
    this.selectedTabIndex = 0,
  });

  LabsState copyWith({
    List<LabModel>? labs,
    bool? isLoading,
    String? error,
    String? searchQuery,
    LabsFilter? filter,
    LabsSortBy? sortBy,
    bool? sortAscending,
    LabsViewMode? viewMode,
    int? selectedTabIndex,
    bool clearError = false,
  }) {
    return LabsState(
      labs: labs ?? this.labs,
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

  List<LabModel> get filteredLabs {
    var result = List<LabModel>.from(labs);

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((lab) {
        return lab.title.toLowerCase().contains(query) ||
            lab.courseName.toLowerCase().contains(query) ||
            lab.courseCode.toLowerCase().contains(query) ||
            lab.instructorName.toLowerCase().contains(query) ||
            (lab.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply filters
    if (filter.status != null) {
      result = result.where((lab) => lab.status == filter.status).toList();
    }
    if (filter.type != null) {
      result = result.where((lab) => lab.type == filter.type).toList();
    }
    if (filter.courseName != null) {
      result = result
          .where((lab) => lab.courseName == filter.courseName)
          .toList();
    }
    if (filter.dateFrom != null) {
      result = result
          .where((lab) => lab.scheduledDate.isAfter(filter.dateFrom!))
          .toList();
    }
    if (filter.dateTo != null) {
      result = result
          .where((lab) => lab.scheduledDate.isBefore(filter.dateTo!))
          .toList();
    }

    // Apply tab filter
    switch (selectedTabIndex) {
      case 1: // Upcoming
        result = result
            .where((lab) => lab.status == LabStatus.upcoming)
            .toList();
        break;
      case 2: // In Progress
        result = result
            .where((lab) => lab.status == LabStatus.inProgress)
            .toList();
        break;
      case 3: // Completed
        result = result
            .where((lab) => lab.status == LabStatus.completed)
            .toList();
        break;
      case 4: // Missed
        result = result.where((lab) => lab.status == LabStatus.missed).toList();
        break;
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case LabsSortBy.date:
          comparison = a.scheduledDate.compareTo(b.scheduledDate);
          break;
        case LabsSortBy.name:
          comparison = a.title.compareTo(b.title);
          break;
        case LabsSortBy.course:
          comparison = a.courseName.compareTo(b.courseName);
          break;
        case LabsSortBy.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case LabsSortBy.type:
          comparison = a.type.index.compareTo(b.type.index);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  // Stats getters
  int get totalLabs => labs.length;
  int get upcomingCount =>
      labs.where((l) => l.status == LabStatus.upcoming).length;
  int get inProgressCount =>
      labs.where((l) => l.status == LabStatus.inProgress).length;
  int get completedCount =>
      labs.where((l) => l.status == LabStatus.completed).length;
  int get missedCount => labs.where((l) => l.status == LabStatus.missed).length;
  int get todayCount => labs.where((l) => l.isToday).length;

  List<String> get availableCourses =>
      labs.map((l) => l.courseName).toSet().toList()..sort();

  @override
  List<Object?> get props => [
    labs,
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
