import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/notifications/api_notification_model.dart';
import '../../models/notifications/notification_model.dart';
import '../../services/api/notification_api_service.dart';
import '../../services/notifications/notification_socket_service.dart';
import '../../services/storage_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required NotificationApiService notificationApiService,
    required NotificationSocketService notificationSocketService,
    StorageService? storageService,
  }) : _notificationApiService = notificationApiService,
       _notificationSocketService = notificationSocketService,
       _storageService = storageService ?? StorageService(),
       super(const NotificationState()) {
    _notificationSubscription = _notificationSocketService.notifications.listen(
      _handleIncomingNotification,
    );
    _unreadCountSubscription = _notificationSocketService.unreadCounts.listen(
      _handleUnreadCountUpdate,
    );
    _connectionSubscription = _notificationSocketService.connectionChanges
        .listen((connected) {
          if (isClosed) {
            return;
          }
          emit(state.copyWith(isRealtimeConnected: connected));
        });
  }

  final NotificationApiService _notificationApiService;
  final NotificationSocketService _notificationSocketService;
  final StorageService _storageService;

  final StreamController<NotificationModel> _incomingNotificationController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get incomingNotifications =>
      _incomingNotificationController.stream;

  StreamSubscription<NotificationModel>? _notificationSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  bool _syncInFlight = false;

  Future<void> initializeRealtime() async {
    if (isClosed) {
      return;
    }
    await _notificationSocketService.connect();
    if (isClosed) {
      return;
    }
  }

  Future<void> loadNotifications() async {
    final sessionUserId = await _currentSessionUserId();
    if (isClosed) {
      return;
    }
    if (sessionUserId == null) {
      await clearForSignedOutSession();
      return;
    }

    final isDifferentSession =
        state.sessionUserId != null && state.sessionUserId != sessionUserId;
    if (isDifferentSession) {
      await _notificationSocketService.disconnect();
      if (isClosed) {
        return;
      }
      _emitIfOpen(
        NotificationState(
          status: NotificationLoadingStatus.loading,
          sessionUserId: sessionUserId,
        ),
      );
    } else {
      _emitIfOpen(
        state.copyWith(
          status: NotificationLoadingStatus.loading,
          sessionUserId: sessionUserId,
        ),
      );
    }

    try {
      final result = await _notificationApiService.getAll(limit: 100, page: 1);
      if (isClosed) {
        return;
      }
      if (!await _isStillCurrentSession(sessionUserId)) {
        return;
      }
      if (!result.isSuccess || result.data == null) {
        _emitIfOpen(
          state.copyWith(
            status: NotificationLoadingStatus.error,
            sessionUserId: sessionUserId,
            errorMessage:
                result.error?.message ?? 'Failed to load notifications',
          ),
        );
        return;
      }

      final notifications =
          result.data!
              .map(ApiNotificationModel.fromJson)
              .map((api) => api.toNotificationModel())
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      var unreadCount = notifications.where((n) => !n.isRead).length;
      final countResult = await _notificationApiService.getUnreadCount();
      if (isClosed) {
        return;
      }
      if (!await _isStillCurrentSession(sessionUserId)) {
        return;
      }
      if (countResult.isSuccess && countResult.data != null) {
        unreadCount = countResult.data!;
      }

      _emitIfOpen(
        state.copyWith(
          status: NotificationLoadingStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
          sessionUserId: sessionUserId,
          errorMessage: null,
        ),
      );
      await initializeRealtime();
    } catch (e) {
      if (isClosed) {
        return;
      }
      _emitIfOpen(
        state.copyWith(
          status: NotificationLoadingStatus.error,
          sessionUserId: sessionUserId,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    if (isClosed) {
      return;
    }
    final current = state.notifications;
    final index = current.indexWhere((n) => n.id == id);
    if (index == -1 ||
        current[index].isRead ||
        !current[index].allowsReadMutation) {
      return;
    }

    final updated = current
        .map(
          (n) =>
              n.id == id ? n.copyWith(isRead: true, readAt: DateTime.now()) : n,
        )
        .toList();
    _emitIfOpen(
      state.copyWith(
        notifications: updated,
        unreadCount: _calculateUnreadCount(
          updated,
          fallback: state.unreadCount - 1,
        ),
      ),
    );

    final result = await _notificationApiService.markAsRead(id);
    if (isClosed) {
      return;
    }
    if (!result.isSuccess) {
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    if (isClosed) {
      return;
    }
    final previous = state.notifications;
    final updated = previous
        .map(
          (n) => n.allowsReadMutation
              ? n.copyWith(isRead: true, readAt: DateTime.now())
              : n,
        )
        .toList();
    _emitIfOpen(state.copyWith(notifications: updated, unreadCount: 0));

    final result = await _notificationApiService.markAllAsRead();
    if (isClosed) {
      return;
    }
    if (!result.isSuccess) {
      _emitIfOpen(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    if (isClosed) {
      return;
    }
    final previous = state.notifications;
    final targetIndex = previous.indexWhere(
      (notification) => notification.id == id,
    );
    if (targetIndex == -1) {
      return;
    }

    final target = previous[targetIndex];
    if (!target.allowsDeleteMutation) {
      return;
    }

    final updated = previous.where((n) => n.id != id).toList();
    _emitIfOpen(
      state.copyWith(
        notifications: updated,
        unreadCount: _calculateUnreadCount(updated),
      ),
    );

    final result = await _notificationApiService.deleteNotification(id);
    if (isClosed) {
      return;
    }
    if (!result.isSuccess) {
      _emitIfOpen(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  Future<void> clearAllNotifications() async {
    if (isClosed) {
      return;
    }
    final previous = state.notifications;
    _emitIfOpen(state.copyWith(notifications: const [], unreadCount: 0));
    final result = await _notificationApiService.clearAll();
    if (isClosed) {
      return;
    }
    if (!result.isSuccess) {
      _emitIfOpen(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  Future<void> clearReadNotifications() async {
    if (isClosed) {
      return;
    }
    final previous = state.notifications;
    final updated = previous.where((n) => !n.isRead).toList();
    _emitIfOpen(
      state.copyWith(
        notifications: updated,
        unreadCount: _calculateUnreadCount(updated),
      ),
    );

    final result = await _notificationApiService.clearRead();
    if (isClosed) {
      return;
    }
    if (!result.isSuccess) {
      _emitIfOpen(state.copyWith(notifications: previous));
      await loadNotifications();
    }
  }

  void setCategory(NotificationCategory category) {
    _emitIfOpen(state.copyWith(selectedCategory: category));
  }

  void setSearchQuery(String query) {
    _emitIfOpen(state.copyWith(searchQuery: query));
  }

  void toggleSearchMode() {
    if (isClosed) {
      return;
    }
    final willSearch = !state.isSearching;
    _emitIfOpen(
      state.copyWith(
        isSearching: willSearch,
        searchQuery: willSearch ? state.searchQuery : '',
      ),
    );
  }

  void ingestExternalNotification(
    NotificationModel notification, {
    bool surface = true,
  }) {
    _handleIncomingNotification(notification, surface: surface);
  }

  void _handleIncomingNotification(
    NotificationModel notification, {
    bool surface = true,
  }) {
    if (isClosed) {
      return;
    }
    if (state.sessionUserId != null &&
        notification.userId != null &&
        notification.userId != state.sessionUserId) {
      return;
    }
    final existingIndex = state.notifications.indexWhere(
      (n) => n.id == notification.id,
    );
    final isNewNotification = existingIndex == -1;
    final withoutDuplicate = state.notifications
        .where((n) => n.id != notification.id)
        .toList();
    final updated = [notification, ...withoutDuplicate]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _emitIfOpen(
      state.copyWith(
        notifications: updated,
        unreadCount: isNewNotification
            ? state.unreadCount + (notification.isRead ? 0 : 1)
            : _calculateUnreadCount(updated, fallback: state.unreadCount),
      ),
    );
    if (surface &&
        isNewNotification &&
        !isClosed &&
        !_incomingNotificationController.isClosed) {
      _incomingNotificationController.add(notification);
    }
  }

  void _handleUnreadCountUpdate(int count) {
    _emitIfOpen(state.copyWith(unreadCount: count));
  }

  Future<void> ensureCurrentSessionLoaded() async {
    final sessionUserId = await _currentSessionUserId();
    if (isClosed) {
      return;
    }
    if (sessionUserId == null) {
      await clearForSignedOutSession();
      return;
    }
    if (state.sessionUserId != sessionUserId ||
        state.status == NotificationLoadingStatus.initial) {
      await loadNotifications();
      return;
    }
    await initializeRealtime();
  }

  Future<void> syncLatestNotifications() async {
    if (isClosed || _syncInFlight) {
      return;
    }

    final sessionUserId = await _currentSessionUserId();
    if (isClosed) {
      return;
    }
    if (sessionUserId == null) {
      await clearForSignedOutSession();
      return;
    }
    if (state.sessionUserId != sessionUserId ||
        state.status == NotificationLoadingStatus.initial) {
      await loadNotifications();
      return;
    }

    _syncInFlight = true;
    try {
      final result = await _notificationApiService.getAll(limit: 100, page: 1);
      if (isClosed || !await _isStillCurrentSession(sessionUserId)) {
        return;
      }
      if (!result.isSuccess || result.data == null) {
        await initializeRealtime();
        return;
      }

      final notifications =
          result.data!
              .map(ApiNotificationModel.fromJson)
              .map((api) => api.toNotificationModel())
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      var unreadCount = notifications.where((n) => !n.isRead).length;
      final countResult = await _notificationApiService.getUnreadCount();
      if (isClosed || !await _isStillCurrentSession(sessionUserId)) {
        return;
      }
      if (countResult.isSuccess && countResult.data != null) {
        unreadCount = countResult.data!;
      }

      _emitIfOpen(
        state.copyWith(
          status: NotificationLoadingStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
          sessionUserId: sessionUserId,
          errorMessage: null,
        ),
      );
      await initializeRealtime();
    } catch (_) {
      if (!isClosed) {
        await initializeRealtime();
      }
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> clearForSignedOutSession() async {
    await _notificationSocketService.disconnect();
    if (isClosed) {
      return;
    }
    _emitIfOpen(const NotificationState());
  }

  Future<int?> _currentSessionUserId() async {
    final user = await _storageService.getUserData();
    final userId = user?.userId;
    if (userId == null || userId <= 0) {
      return null;
    }
    return userId;
  }

  Future<bool> _isStillCurrentSession(int expectedUserId) async {
    if (isClosed) {
      return false;
    }
    final currentUserId = await _currentSessionUserId();
    return !isClosed && currentUserId == expectedUserId;
  }

  void _emitIfOpen(NotificationState nextState) {
    if (!isClosed) {
      emit(nextState);
    }
  }

  int _calculateUnreadCount(
    List<NotificationModel> notifications, {
    int? fallback,
  }) {
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
