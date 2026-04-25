import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/notifications/api_notification_model.dart';
import '../../models/notifications/notification_model.dart';
import '../../services/api/notification_api_service.dart';
import '../../services/notifications/notification_socket_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required NotificationApiService notificationApiService,
    required NotificationSocketService notificationSocketService,
  }) : _notificationApiService = notificationApiService,
       _notificationSocketService = notificationSocketService,
       super(const NotificationState()) {
    _notificationSubscription = _notificationSocketService.notifications.listen(
      _handleIncomingNotification,
    );
    _unreadCountSubscription = _notificationSocketService.unreadCounts.listen(
      _handleUnreadCountUpdate,
    );
    _connectionSubscription = _notificationSocketService.connectionChanges.listen(
      (connected) {
        emit(state.copyWith(isRealtimeConnected: connected));
      },
    );
  }

  final NotificationApiService _notificationApiService;
  final NotificationSocketService _notificationSocketService;

  final StreamController<NotificationModel> _incomingNotificationController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get incomingNotifications =>
      _incomingNotificationController.stream;

  StreamSubscription<NotificationModel>? _notificationSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  Future<void> initializeRealtime() async {
    await _notificationSocketService.connect();
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationLoadingStatus.loading));

    try {
      final result = await _notificationApiService.getAll(limit: 100, page: 1);
      if (!result.isSuccess || result.data == null) {
        emit(
          state.copyWith(
            status: NotificationLoadingStatus.error,
            errorMessage: result.error?.message ?? 'Failed to load notifications',
          ),
        );
        return;
      }

      final notifications = result.data!
          .map(ApiNotificationModel.fromJson)
          .map((api) => api.toNotificationModel())
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      var unreadCount = notifications.where((n) => !n.isRead).length;
      final countResult = await _notificationApiService.getUnreadCount();
      if (countResult.isSuccess && countResult.data != null) {
        unreadCount = countResult.data!;
      }

      emit(
        state.copyWith(
          status: NotificationLoadingStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
          errorMessage: null,
        ),
      );
      await initializeRealtime();
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationLoadingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state.notifications;
    final index = current.indexWhere((n) => n.id == id);
    if (index == -1 || current[index].isRead || !current[index].allowsReadMutation) {
      return;
    }

    final updated = current
        .map((n) => n.id == id ? n.copyWith(isRead: true, readAt: DateTime.now()) : n)
        .toList();
    emit(
      state.copyWith(
        notifications: updated,
        unreadCount: _calculateUnreadCount(updated, fallback: state.unreadCount - 1),
      ),
    );

    final result = await _notificationApiService.markAsRead(id);
    if (!result.isSuccess) {
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    final previous = state.notifications;
    final updated = previous
        .map((n) => n.allowsReadMutation ? n.copyWith(isRead: true, readAt: DateTime.now()) : n)
        .toList();
    emit(state.copyWith(notifications: updated, unreadCount: 0));

    final result = await _notificationApiService.markAllAsRead();
    if (!result.isSuccess) {
      emit(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    final previous = state.notifications;
    final targetIndex = previous.indexWhere((notification) => notification.id == id);
    if (targetIndex == -1) {
      return;
    }

    final target = previous[targetIndex];
    if (!target.allowsDeleteMutation) {
      return;
    }

    final updated = previous.where((n) => n.id != id).toList();
    emit(
      state.copyWith(
        notifications: updated,
        unreadCount: _calculateUnreadCount(updated),
      ),
    );

    final result = await _notificationApiService.deleteNotification(id);
    if (!result.isSuccess) {
      emit(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  Future<void> clearAllNotifications() async {
    final previous = state.notifications;
    emit(state.copyWith(notifications: const [], unreadCount: 0));
    final result = await _notificationApiService.clearAll();
    if (!result.isSuccess) {
      emit(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  Future<void> clearReadNotifications() async {
    final previous = state.notifications;
    final updated = previous.where((n) => !n.isRead).toList();
    emit(
      state.copyWith(
        notifications: updated,
        unreadCount: _calculateUnreadCount(updated),
      ),
    );

    final result = await _notificationApiService.clearRead();
    if (!result.isSuccess) {
      emit(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  void setCategory(NotificationCategory category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void toggleSearchMode() {
    final willSearch = !state.isSearching;
    emit(
      state.copyWith(
        isSearching: willSearch,
        searchQuery: willSearch ? state.searchQuery : '',
      ),
    );
  }

  void _handleIncomingNotification(NotificationModel notification) {
    final withoutDuplicate = state.notifications.where((n) => n.id != notification.id).toList();
    final updated = [notification, ...withoutDuplicate]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(
      state.copyWith(
        notifications: updated,
        unreadCount: state.unreadCount + (notification.isRead ? 0 : 1),
      ),
    );
    _incomingNotificationController.add(notification);
  }

  void _handleUnreadCountUpdate(int count) {
    emit(state.copyWith(unreadCount: count));
  }

  int _calculateUnreadCount(List<NotificationModel> notifications, {int? fallback}) {
    final count = notifications.where((n) => !n.isRead).length;
    if (count == 0 && fallback != null && fallback > 0) {
      return fallback;
    }
    return count;
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    await _unreadCountSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _incomingNotificationController.close();
    await _notificationSocketService.disconnect();
    return super.close();
  }
}
