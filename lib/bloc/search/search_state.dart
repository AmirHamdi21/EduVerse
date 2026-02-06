import 'package:flutter/material.dart';

enum SearchCategory {
  all,
  courses,
  tasks,
  assignments,
  labs,
  grades,
  flashcards,
  notes,
  messages,
}

enum SearchResultType {
  course,
  task,
  assignment,
  lab,
  grade,
  flashcard,
  note,
  message,
  feature,
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String? description;
  final SearchResultType type;
  final IconData icon;
  final Color iconColor;
  final String? route;
  final Object? extra;
  final DateTime? date;
  final String? status;
  final double? progress;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.iconColor,
    this.description,
    this.route,
    this.extra,
    this.date,
    this.status,
    this.progress,
  });
}

class SearchFilter {
  final SearchCategory category;
  final String? status;
  final String? priority;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? sortBy;
  final bool ascending;

  const SearchFilter({
    this.category = SearchCategory.all,
    this.status,
    this.priority,
    this.dateFrom,
    this.dateTo,
    this.sortBy,
    this.ascending = true,
  });

  SearchFilter copyWith({
    SearchCategory? category,
    String? status,
    String? priority,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    bool? ascending,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearSortBy = false,
  }) {
    return SearchFilter(
      category: category ?? this.category,
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      ascending: ascending ?? this.ascending,
    );
  }

  bool get hasActiveFilters =>
      status != null ||
      priority != null ||
      dateFrom != null ||
      dateTo != null ||
      sortBy != null;

  int get activeFilterCount {
    int count = 0;
    if (status != null) count++;
    if (priority != null) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (sortBy != null) count++;
    return count;
  }
}

abstract class SearchState {
  final String query;
  final SearchFilter filter;
  final List<String> recentSearches;
  final List<SearchResultItem> results;

  const SearchState({
    this.query = '',
    this.filter = const SearchFilter(),
    this.recentSearches = const [],
    this.results = const [],
  });

  List<SearchResultItem> get filteredResults {
    if (filter.category == SearchCategory.all) return results;

    final typeMapping = <SearchCategory, Set<SearchResultType>>{
      SearchCategory.courses: {SearchResultType.course},
      SearchCategory.tasks: {SearchResultType.task},
      SearchCategory.assignments: {SearchResultType.assignment},
      SearchCategory.labs: {SearchResultType.lab},
      SearchCategory.grades: {SearchResultType.grade},
      SearchCategory.flashcards: {SearchResultType.flashcard},
      SearchCategory.notes: {SearchResultType.note},
      SearchCategory.messages: {SearchResultType.message},
    };

    final allowedTypes = typeMapping[filter.category] ?? {};
    if (allowedTypes.isEmpty) return results;

    return results.where((r) => allowedTypes.contains(r.type)).toList();
  }

  Map<SearchResultType, List<SearchResultItem>> get groupedResults {
    final map = <SearchResultType, List<SearchResultItem>>{};
    for (final item in filteredResults) {
      map.putIfAbsent(item.type, () => []).add(item);
    }
    return map;
  }
}

class SearchInitial extends SearchState {
  const SearchInitial({
    super.recentSearches,
    super.filter,
  });
}

class SearchLoading extends SearchState {
  const SearchLoading({
    required super.query,
    super.filter,
    super.recentSearches,
    super.results,
  });
}

class SearchLoaded extends SearchState {
  final int totalCount;

  const SearchLoaded({
    required super.query,
    required super.results,
    required this.totalCount,
    super.filter,
    super.recentSearches,
  });

  SearchLoaded copyWith({
    String? query,
    List<SearchResultItem>? results,
    int? totalCount,
    SearchFilter? filter,
    List<String>? recentSearches,
  }) {
    return SearchLoaded(
      query: query ?? this.query,
      results: results ?? this.results,
      totalCount: totalCount ?? this.totalCount,
      filter: filter ?? this.filter,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class SearchEmpty extends SearchState {
  const SearchEmpty({
    required super.query,
    super.filter,
    super.recentSearches,
  });
}

class SearchError extends SearchState {
  final String message;

  const SearchError({
    required this.message,
    required super.query,
    super.filter,
    super.recentSearches,
  });
}
