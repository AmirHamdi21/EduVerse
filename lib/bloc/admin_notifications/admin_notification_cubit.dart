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

      // Announcements remain local-only (no backend endpoint for admin announcements)
      final announcements = _generateMockAnnouncements();

      emit(
        state.copyWith(
          status: AdminNotificationLoadingStatus.loaded,
          notifications: notifications,
          announcements: announcements,
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

  /// Announcements remain local-only (no backend endpoint exists)
  List<AdminAnnouncementModel> _generateMockAnnouncements() {
    final now = DateTime.now();
    return [
      AdminAnnouncementModel(
        id: 'a1',
        title: 'Welcome to Spring Semester 2025',
        content:
            'Dear Students and Faculty,\n\nWe are excited to welcome you to the Spring Semester 2025. Classes begin on January 15th. Please ensure all course registrations are completed by January 10th.\n\nBest regards,\nAdministration',
        target: AnnouncementTarget.all,
        priority: AdminNotificationPriority.high,
        createdAt: now.subtract(const Duration(days: 1)),
        isPinned: true,
        createdBy: 'Admin',
        viewCount: 1250,
      ),
      AdminAnnouncementModel(
        id: 'a2',
        title: 'System Maintenance Notice',
        content:
            'The EduVerse platform will undergo scheduled maintenance on Saturday, January 20th from 2:00 AM to 4:00 AM EST. During this time, the system will be unavailable.',
        target: AnnouncementTarget.all,
        priority: AdminNotificationPriority.urgent,
        createdAt: now.subtract(const Duration(days: 2)),
        createdBy: 'IT Admin',
        viewCount: 890,
      ),
      AdminAnnouncementModel(
        id: 'a3',
        title: 'New Grading Policy Update',
        content:
            'Please review the updated grading policy effective Spring 2025. All instructors must adhere to the new guidelines.',
        target: AnnouncementTarget.instructors,
        priority: AdminNotificationPriority.high,
        createdAt: now.subtract(const Duration(days: 3)),
        createdBy: 'Academic Affairs',
        viewCount: 156,
      ),
      AdminAnnouncementModel(
        id: 'a4',
        title: 'TA Training Workshop',
        content:
            'Mandatory training workshop for all Teaching Assistants on January 12th at 10:00 AM in Room 301.',
        target: AnnouncementTarget.teachingAssistants,
        priority: AdminNotificationPriority.normal,
        createdAt: now.subtract(const Duration(days: 5)),
        createdBy: 'HR Department',
        viewCount: 45,
      ),
      AdminAnnouncementModel(
        id: 'a5',
        title: 'Student Resources Update',
        content:
            'New study resources and AI tutoring features are now available in the student portal.',
        target: AnnouncementTarget.students,
        priority: AdminNotificationPriority.normal,
        createdAt: now.subtract(const Duration(days: 7)),
        createdBy: 'Student Services',
        viewCount: 2340,
      ),
    ];
  }
}
