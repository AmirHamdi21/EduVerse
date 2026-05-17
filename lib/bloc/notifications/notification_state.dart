import 'package:equatable/equatable.dart';

import '../../models/notifications/notification_model.dart';

enum NotificationLoadingStatus { initial, loading, loaded, error }

const Object _unset = Object();

class NotificationState extends Equatable {
  final NotificationLoadingStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int? sessionUserId;
  final String? errorMessage;
  final NotificationCategory selectedCategory;
  final String searchQuery;
  final bool isSearching;
  final bool isRealtimeConnected;

  const NotificationState({
    this.status = NotificationLoadingStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.sessionUserId,
    this.errorMessage,
    this.selectedCategory = NotificationCategory.all,
    this.searchQuery = '',
    this.isSearching = false,
    this.isRealtimeConnected = false,
  });

  NotificationState copyWith({
    NotificationLoadingStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    Object? sessionUserId = _unset,
    Object? errorMessage = _unset,
    NotificationCategory? selectedCategory,
    String? searchQuery,
    bool? isSearching,
    bool? isRealtimeConnected,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      sessionUserId: sessionUserId == _unset
          ? this.sessionUserId
          : sessionUserId as int?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isRealtimeConnected: isRealtimeConnected ?? this.isRealtimeConnected,
    );
  }

  List<NotificationModel> get filteredNotifications {
    var filtered = notifications;

    if (selectedCategory != NotificationCategory.all) {
      filtered = filtered.where((n) => n.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.message.toLowerCase().contains(query) ||
            (n.courseName?.toLowerCase().contains(query) ?? false) ||
            (n.instructorName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return filteredNotifications
        .where((n) => !n.createdAt.isBefore(startOfDay))
        .toList();
  }

  List<NotificationModel> get thisWeekNotifications {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(const Duration(days: 7));
    return filteredNotifications
        .where(
          (n) =>
              n.createdAt.isBefore(startOfDay) &&
              !n.createdAt.isBefore(startOfWeek),
        )
        .toList();
  }

  List<NotificationModel> get earlierNotifications {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(const Duration(days: 7));
    return filteredNotifications
        .where((n) => n.createdAt.isBefore(startOfWeek))
        .toList();
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    unreadCount,
    sessionUserId,
    errorMessage,
    selectedCategory,
    searchQuery,
    isSearching,
    isRealtimeConnected,
  ];
}
