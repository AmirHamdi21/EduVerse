import 'package:equatable/equatable.dart';

import '../../models/core/course_model.dart';
import '../../models/core/enums/lab_enums.dart' as api;
import '../../models/labs/lab_model.dart';

enum LabsSortBy { dueDate, title, course, status }

enum LabsViewMode { list, grid, calendar }

enum LabsDisplayStatus { upcoming, inProgress, completed, missed }

extension LabsDisplayStatusPresentation on LabsDisplayStatus {
  String get label {
    switch (this) {
      case LabsDisplayStatus.upcoming:
        return 'Upcoming';
      case LabsDisplayStatus.inProgress:
        return 'In Progress';
      case LabsDisplayStatus.completed:
        return 'Completed';
      case LabsDisplayStatus.missed:
        return 'Missed';
    }
  }
}

class LabsFilter extends Equatable {
  final LabsDisplayStatus? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LabsFilter({this.status, this.dateFrom, this.dateTo});

  LabsFilter copyWith({
    LabsDisplayStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearStatus = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return LabsFilter(
      status: clearStatus ? null : (status ?? this.status),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }

  bool get hasActiveFilters =>
      status != null || dateFrom != null || dateTo != null;

  LabsFilter clear() => const LabsFilter();

  @override
  List<Object?> get props => [status, dateFrom, dateTo];
}

class LabsState extends Equatable {
  final List<LabModel> labs;
  final List<CourseModel> enrolledCourses;
  final int? selectedCourseId;
  final CourseModel? selectedCourse;
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
    this.enrolledCourses = const [],
    this.selectedCourseId,
    this.selectedCourse,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filter = const LabsFilter(),
    this.sortBy = LabsSortBy.dueDate,
    this.sortAscending = true,
    this.viewMode = LabsViewMode.list,
    this.selectedTabIndex = 0,
  });

  LabsState copyWith({
    List<LabModel>? labs,
    List<CourseModel>? enrolledCourses,
    int? selectedCourseId,
    CourseModel? selectedCourse,
    bool? isLoading,
    String? error,
    String? searchQuery,
    LabsFilter? filter,
    LabsSortBy? sortBy,
    bool? sortAscending,
    LabsViewMode? viewMode,
    int? selectedTabIndex,
    bool clearError = false,
    bool clearSelectedCourseId = false,
    bool clearSelectedCourse = false,
  }) {
    return LabsState(
      labs: labs ?? this.labs,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      selectedCourseId: clearSelectedCourseId
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
      selectedCourse: clearSelectedCourse
          ? null
          : (selectedCourse ?? this.selectedCourse),
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
    var result = List<LabModel>.from(_courseScopedLabs);

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((lab) {
        return lab.title.toLowerCase().contains(query) ||
            (lab.course?.name.toLowerCase().contains(query) ?? false) ||
            (lab.course?.code.toLowerCase().contains(query) ?? false) ||
            (lab.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply filters
    if (filter.status != null) {
      result = result
          .where((lab) => _displayStatusForLab(lab) == filter.status)
          .toList();
    }
    if (filter.dateFrom != null) {
      result = result
          .where(
            (lab) =>
                lab.dueDate != null && lab.dueDate!.isAfter(filter.dateFrom!),
          )
          .toList();
    }
    if (filter.dateTo != null) {
      result = result
          .where(
            (lab) =>
                lab.dueDate != null && lab.dueDate!.isBefore(filter.dateTo!),
          )
          .toList();
    }

    // Apply tab filter
    switch (selectedTabIndex) {
      case 1: // Upcoming
        result = result
            .where(
              (lab) => _displayStatusForLab(lab) == LabsDisplayStatus.upcoming,
            )
            .toList();
        break;
      case 2: // In Progress
        result = result
            .where(
              (lab) =>
                  _displayStatusForLab(lab) == LabsDisplayStatus.inProgress,
            )
            .toList();
        break;
      case 3: // Completed
        result = result
            .where(
              (lab) => _displayStatusForLab(lab) == LabsDisplayStatus.completed,
            )
            .toList();
        break;
      case 4: // Missed
        result = result
            .where(
              (lab) => _displayStatusForLab(lab) == LabsDisplayStatus.missed,
            )
            .toList();
        break;
    }

    // Apply sorting
    result.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case LabsSortBy.dueDate:
          comparison = (a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0));
          break;
        case LabsSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
        case LabsSortBy.course:
          comparison = (a.course?.name ?? '').compareTo(b.course?.name ?? '');
          break;
        case LabsSortBy.status:
          comparison = _displayStatusForLab(
            a,
          ).index.compareTo(_displayStatusForLab(b).index);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  // Stats getters
  int get totalLabs => _courseScopedLabs.length;
  int get upcomingCount => _courseScopedLabs
      .where((l) => _displayStatusForLab(l) == LabsDisplayStatus.upcoming)
      .length;
  int get inProgressCount => _courseScopedLabs
      .where((l) => _displayStatusForLab(l) == LabsDisplayStatus.inProgress)
      .length;
  int get completedCount => _courseScopedLabs
      .where((l) => _displayStatusForLab(l) == LabsDisplayStatus.completed)
      .length;
  int get missedCount => _courseScopedLabs
      .where((l) => _displayStatusForLab(l) == LabsDisplayStatus.missed)
      .length;
  int get todayCount {
    final now = DateTime.now();
    return _courseScopedLabs.where((lab) {
      final dueDate = lab.dueDate;
      return dueDate != null &&
          dueDate.year == now.year &&
          dueDate.month == now.month &&
          dueDate.day == now.day;
    }).length;
  }

  List<LabModel> get _courseScopedLabs {
    if (selectedCourseId == null) {
      return labs;
    }
    return labs.where((lab) => lab.courseId == selectedCourseId).toList();
  }

  LabsDisplayStatus _displayStatusForLab(LabModel lab) {
    switch (lab.status) {
      case api.LabStatus.closed:
        return LabsDisplayStatus.completed;
      case api.LabStatus.archived:
        return LabsDisplayStatus.missed;
      case api.LabStatus.published:
        if (!lab.isPastDue) {
          return LabsDisplayStatus.upcoming;
        }
        final daysUntilDue = lab.daysUntilDue;
        if (daysUntilDue != null && daysUntilDue <= -2) {
          return LabsDisplayStatus.missed;
        }
        return LabsDisplayStatus.inProgress;
      case api.LabStatus.draft:
      case api.LabStatus.unknown:
        return LabsDisplayStatus.upcoming;
    }
  }

  List<String> get availableCourses =>
      enrolledCourses.map((course) => course.name).toSet().toList()..sort();

  @override
  List<Object?> get props => [
    labs,
    enrolledCourses,
    selectedCourseId,
    selectedCourse,
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
