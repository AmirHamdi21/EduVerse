import 'package:equatable/equatable.dart';

import '../../models/schedule/schedule_models.dart';
import '../schedule/schedule_item_builder.dart';

enum TACalendarViewType { month, week, day }

class TACalendarState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final TACalendarViewType viewType;
  final Set<String> activeFilters;
  final List<DailyScheduleResponse> rawDays;
  final List<UnifiedScheduleItem> unifiedItems;

  TACalendarState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.viewType = TACalendarViewType.month,
    this.activeFilters = const <String>{
      'lab',
      'grading',
      'office_hours',
      'meetings',
    },
    this.rawDays = const <DailyScheduleResponse>[],
    this.unifiedItems = const <UnifiedScheduleItem>[],
  }) : selectedDate = selectedDate ?? DateTime.now(),
       focusedMonth = focusedMonth ?? DateTime.now();

  List<UnifiedScheduleItem> get filteredItems {
    return unifiedItems
        .where((item) {
          final mappedType = _kindToFilter(item.kind);
          return activeFilters.contains(mappedType);
        })
        .toList(growable: false);
  }

  List<UnifiedScheduleItem> eventsForDate(DateTime date) {
    final iso = toISODate(date);
    return filteredItems
        .where((item) => item.date == iso)
        .toList(growable: false);
  }

  List<UnifiedScheduleItem> get upcomingItems {
    return ScheduleItemBuilder.upcoming(filteredItems, limit: 5);
  }

  TACalendarState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    TACalendarViewType? viewType,
    Set<String>? activeFilters,
    List<DailyScheduleResponse>? rawDays,
    List<UnifiedScheduleItem>? unifiedItems,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TACalendarState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      viewType: viewType ?? this.viewType,
      activeFilters: activeFilters ?? this.activeFilters,
      rawDays: rawDays ?? this.rawDays,
      unifiedItems: unifiedItems ?? this.unifiedItems,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    error,
    successMessage,
    selectedDate,
    focusedMonth,
    viewType,
    activeFilters,
    rawDays,
    unifiedItems,
  ];

  static String _kindToFilter(ScheduleItemKind kind) {
    switch (kind) {
      case ScheduleItemKind.classSession:
        return 'lab';
      case ScheduleItemKind.exam:
        return 'grading';
      case ScheduleItemKind.event:
        return 'meetings';
      case ScheduleItemKind.campusEvent:
        return 'meetings';
      case ScheduleItemKind.officeHours:
        return 'office_hours';
      case ScheduleItemKind.unknown:
        return 'meetings';
    }
  }
}
