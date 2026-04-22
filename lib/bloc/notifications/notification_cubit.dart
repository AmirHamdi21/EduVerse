import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notifications/api_notification_model.dart';
import '../../models/notifications/notification_model.dart';
import '../../services/api/notification_api_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationApiService? _notificationApiService;

  NotificationCubit({NotificationApiService? notificationApiService})
    : _notificationApiService = notificationApiService,
      super(const NotificationState());

  /// Load notifications from the backend API.
  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationLoadingStatus.loading));

    try {
      if (_notificationApiService == null) {
        // Fallback to empty state when no service injected
        emit(
          state.copyWith(
            status: NotificationLoadingStatus.loaded,
            notifications: [],
            aiInsights: _generateSampleAIInsights(),
            systemAlerts: _generateSampleSystemAlerts(),
            unreadCount: 0,
          ),
        );
        return;
      }

      // Fetch notifications from API
      final result = await _notificationApiService.getAll(limit: 100);

      List<NotificationModel> notifications = [];
      if (result.isSuccess && result.data != null) {
        notifications = result.data!
            .map((json) => ApiNotificationModel.fromJson(json))
            .map((api) => api.toNotificationModel())
            .toList();
      }

      // Fetch unread count from API
      int unreadCount = notifications.where((n) => !n.isRead).length;
      final countResult = await _notificationApiService.getUnreadCount();
      if (countResult.isSuccess && countResult.data != null) {
        unreadCount = countResult.data!;
      }

      // AI Insights and System Alerts remain local-only (no backend endpoints)
      final aiInsights = _generateSampleAIInsights();
      final systemAlerts = _generateSampleSystemAlerts();

      emit(
        state.copyWith(
          status: NotificationLoadingStatus.loaded,
          notifications: notifications,
          aiInsights: aiInsights,
          systemAlerts: systemAlerts,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationLoadingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Mark a notification as read (optimistic UI + API call)
  void markAsRead(String id) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(
      state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ),
    );

    // Fire-and-forget API call
    _notificationApiService?.markAsRead(id);
  }

  /// Mark a notification as unread
  void markAsUnread(String id) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: false);
      }
      return n;
    }).toList();

    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(
      state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ),
    );
  }

  /// Mark all notifications as read (optimistic UI + API call)
  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications, unreadCount: 0));

    // Fire-and-forget API call
    _notificationApiService?.markAllAsRead();
  }

  /// Toggle bookmark status (local-only)
  void toggleBookmark(String id) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isBookmarked: !n.isBookmarked);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }

  /// Delete a notification (optimistic UI + API call)
  void deleteNotification(String id) {
    final updatedNotifications = state.notifications
        .where((n) => n.id != id)
        .toList();
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(
      state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ),
    );

    // Fire-and-forget API call
    _notificationApiService?.deleteNotification(id);
  }

  /// Clear all notifications (local-only since backend has no clear-all endpoint)
  void clearAllNotifications() {
    emit(state.copyWith(notifications: [], unreadCount: 0));
  }

  /// Clear read notifications (optimistic UI + API call)
  void clearReadNotifications() {
    final updatedNotifications = state.notifications
        .where((n) => !n.isRead)
        .toList();
    emit(state.copyWith(notifications: updatedNotifications));

    // Fire-and-forget API call
    _notificationApiService?.clearRead();
  }

  /// Set filter category
  void setCategory(NotificationCategory category) {
    emit(state.copyWith(selectedCategory: category));
  }

  /// Set search query
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Toggle search mode
  void toggleSearchMode() {
    emit(
      state.copyWith(
        isSearching: !state.isSearching,
        searchQuery: state.isSearching ? '' : state.searchQuery,
      ),
    );
  }

  /// Dismiss AI insight
  void dismissAIInsight(String id) {
    final updatedInsights = state.aiInsights.map((i) {
      if (i.id == id) {
        return i.copyWith(isDismissed: true);
      }
      return i;
    }).toList();

    emit(state.copyWith(aiInsights: updatedInsights));
  }

  /// Dismiss system alert
  void dismissSystemAlert(String id) {
    final updatedAlerts = state.systemAlerts.map((a) {
      if (a.id == id) {
        return a.copyWith(isDismissed: true);
      }
      return a;
    }).toList();

    emit(state.copyWith(systemAlerts: updatedAlerts));
  }

  // ── Local-only features (no backend endpoints) ──────────────────

  /// Generate sample AI insights (no backend endpoint exists for these)
  List<AIInsightModel> _generateSampleAIInsights() {
    final now = DateTime.now();
    return [
      AIInsightModel(
        id: 'ai1',
        title: 'Performance Alert',
        message:
            'Your quiz performance dropped this week — review Chapter 2 again for better understanding.',
        insightType: AIInsightType.performanceAlert,
        actionText: 'Take Action',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AIInsightModel(
        id: 'ai2',
        title: 'AI Recommendation',
        message:
            'AI recommends revising "Data Structures" before the next lab session for optimal performance.',
        insightType: AIInsightType.recommendation,
        actionText: 'View Recommendations',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  /// Generate sample system alerts (no backend endpoint exists for these)
  List<SystemAlertModel> _generateSampleSystemAlerts() {
    final now = DateTime.now();
    return [
      SystemAlertModel(
        id: 'sys1',
        title: 'New Version Available',
        message:
            'EduVerse v2.1 is live with new features and improvements. Update now!',
        alertType: SystemAlertType.update,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      SystemAlertModel(
        id: 'sys2',
        title: 'Scheduled Maintenance',
        message:
            'System will be temporarily unavailable Sunday at 2 AM for scheduled maintenance.',
        alertType: SystemAlertType.maintenance,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
