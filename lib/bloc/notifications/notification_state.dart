import 'package:equatable/equatable.dart';
import '../../models/notifications/notification_model.dart';

enum NotificationLoadingStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationLoadingStatus status;
  final List<NotificationModel> notifications;
  final List<AIInsightModel> aiInsights;
  final List<SystemAlertModel> systemAlerts;
  final int unreadCount;
  final String? errorMessage;
  final NotificationCategory selectedCategory;
  final String searchQuery;
  final bool isSearching;

  const NotificationState({
    this.status = NotificationLoadingStatus.initial,
    this.notifications = const [],
    this.aiInsights = const [],
    this.systemAlerts = const [],
    this.unreadCount = 0,
    this.errorMessage,
    this.selectedCategory = NotificationCategory.all,
    this.searchQuery = '',
    this.isSearching = false,
  });

  NotificationState copyWith({
    NotificationLoadingStatus? status,
    List<NotificationModel>? notifications,
    List<AIInsightModel>? aiInsights,
    List<SystemAlertModel>? systemAlerts,
    int? unreadCount,
    String? errorMessage,
    NotificationCategory? selectedCategory,
    String? searchQuery,
    bool? isSearching,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      aiInsights: aiInsights ?? this.aiInsights,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  /// Get filtered notifications based on selected category and search
  List<NotificationModel> get filteredNotifications {
    var filtered = notifications;

    // Filter by category
    if (selectedCategory != NotificationCategory.all) {
      filtered = filtered.where((n) => n.category == selectedCategory).toList();
    }

    // Filter by search query
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

  /// Get today's notifications
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return filteredNotifications
        .where((n) => n.createdAt.isAfter(startOfDay))
        .toList();
  }

  /// Get this week's notifications (excluding today)
  List<NotificationModel> get thisWeekNotifications {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(const Duration(days: 7));
    return filteredNotifications
        .where((n) =>
            n.createdAt.isBefore(startOfDay) && n.createdAt.isAfter(startOfWeek))
        .toList();
  }

  /// Get earlier notifications (older than a week)
  List<NotificationModel> get earlierNotifications {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(const Duration(days: 7));
    return filteredNotifications
        .where((n) => n.createdAt.isBefore(startOfWeek))
        .toList();
  }

  /// Get bookmarked notifications
  List<NotificationModel> get bookmarkedNotifications {
    return notifications.where((n) => n.isBookmarked).toList();
  }

  /// Get active AI insights (not dismissed)
  List<AIInsightModel> get activeAIInsights {
    return aiInsights.where((i) => !i.isDismissed).toList();
  }

  /// Get active system alerts (not dismissed)
  List<SystemAlertModel> get activeSystemAlerts {
    return systemAlerts.where((a) => !a.isDismissed).toList();
  }

  /// Check if there are any active notifications, insights, or alerts
  bool get hasActiveItems {
    return filteredNotifications.isNotEmpty ||
        activeAIInsights.isNotEmpty ||
        activeSystemAlerts.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        aiInsights,
        systemAlerts,
        unreadCount,
        errorMessage,
        selectedCategory,
        searchQuery,
        isSearching,
      ];
}
