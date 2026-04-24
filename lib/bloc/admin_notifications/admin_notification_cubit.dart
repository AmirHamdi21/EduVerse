import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/admin/admin_notification_model.dart';
import '../../models/notifications/api_notification_model.dart';
import '../../services/api/notification_api_service.dart';
import 'admin_notification_state.dart';

class AdminNotificationCubit extends Cubit<AdminNotificationState> {
  final NotificationApiService? _notificationApiService;

  AdminNotificationCubit({NotificationApiService? notificationApiService})
    : _notificationApiService = notificationApiService,
      super(const AdminNotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: AdminNotificationLoadingStatus.loading));

    try {
      List<AdminNotificationModel> notifications = [];

      if (_notificationApiService != null) {
        final result = await _notificationApiService.getAll(limit: 100);
        if (result.isSuccess && result.data != null) {
          notifications = result.data!
              .map((json) => ApiNotificationModel.fromJson(json))
              .map((api) => api.toAdminNotificationModel())
              .toList();
        }
      }

      emit(
        state.copyWith(
          status: AdminNotificationLoadingStatus.loaded,
          notifications: notifications,
          announcements: const <AdminAnnouncementModel>[],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminNotificationLoadingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setCategory(AdminNotificationCategory category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void toggleSearchMode() {
    emit(
      state.copyWith(
        isSearching: !state.isSearching,
        searchQuery: state.isSearching ? '' : state.searchQuery,
      ),
    );
  }

  void setCurrentTab(int tab) {
    emit(state.copyWith(currentTab: tab));
  }

  void markAsRead(String id) {
    final notifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: notifications));

    // Fire-and-forget API call
    _notificationApiService?.markAsRead(id);
  }

  void markAsUnread(String id) {
    final notifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: false);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: notifications));
  }

  void toggleBookmark(String id) {
    final notifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isBookmarked: !n.isBookmarked);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: notifications));
  }

  void archiveNotification(String id) {
    final notifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isArchived: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: notifications));
  }

  void unarchiveNotification(String id) {
    final notifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isArchived: false);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: notifications));
  }

  void deleteNotification(String id) {
    final notifications = state.notifications.where((n) => n.id != id).toList();

    emit(state.copyWith(notifications: notifications));

    // Fire-and-forget API call
    _notificationApiService?.deleteNotification(id);
  }

  void markAllAsRead() {
    final notifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    emit(state.copyWith(notifications: notifications));

    // Fire-and-forget API call
    _notificationApiService?.markAllAsRead();
  }

  void clearReadNotifications() {
    final notifications = state.notifications.where((n) => !n.isRead).toList();

    emit(state.copyWith(notifications: notifications));

    // Fire-and-forget API call
    _notificationApiService?.clearRead();
  }

  void clearAllNotifications() {
    emit(state.copyWith(notifications: []));
  }

  void deleteAnnouncement(String id) {
    final announcements = state.announcements.where((a) => a.id != id).toList();

    emit(state.copyWith(announcements: announcements));
  }

  void toggleAnnouncementPin(String id) {
    final announcements = state.announcements.map((a) {
      if (a.id == id) {
        return a.copyWith(isPinned: !a.isPinned);
      }
      return a;
    }).toList();

    emit(state.copyWith(announcements: announcements));
  }

  void addAnnouncement(AdminAnnouncementModel announcement) {
    final announcements = [announcement, ...state.announcements];
    emit(state.copyWith(announcements: announcements));
  }
}
