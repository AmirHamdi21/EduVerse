import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/admin/admin_notification_model.dart';
import 'admin_notification_state.dart';

class AdminNotificationCubit extends Cubit<AdminNotificationState> {
  AdminNotificationCubit() : super(const AdminNotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: AdminNotificationLoadingStatus.loading));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final notifications = _generateMockNotifications();
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
  }

  void markAllAsRead() {
    final notifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    emit(state.copyWith(notifications: notifications));
  }

  void clearReadNotifications() {
    final notifications = state.notifications.where((n) => !n.isRead).toList();

    emit(state.copyWith(notifications: notifications));
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

  List<AdminNotificationModel> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      AdminNotificationModel(
        id: '1',
        title: 'New User Registration',
        message: 'Ahmed Mohamed has registered as a new student',
        type: AdminNotificationType.userActivity,
        priority: AdminNotificationPriority.normal,
        category: AdminNotificationCategory.users,
        createdAt: now.subtract(const Duration(minutes: 5)),
        userName: 'Ahmed Mohamed',
        userRole: 'Student',
        requiresAction: true,
      ),
      AdminNotificationModel(
        id: '2',
        title: 'System Maintenance Scheduled',
        message: 'Scheduled maintenance window: Saturday 2:00 AM - 4:00 AM',
        type: AdminNotificationType.maintenance,
        priority: AdminNotificationPriority.high,
        category: AdminNotificationCategory.system,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AdminNotificationModel(
        id: '3',
        title: 'Course Approval Required',
        message:
            'New course "Advanced AI" submitted by Dr. Sarah needs approval',
        type: AdminNotificationType.approval,
        priority: AdminNotificationPriority.high,
        category: AdminNotificationCategory.courses,
        createdAt: now.subtract(const Duration(hours: 2)),
        courseName: 'Advanced AI',
        userName: 'Dr. Sarah',
        requiresAction: true,
      ),
      AdminNotificationModel(
        id: '4',
        title: 'Security Alert',
        message:
            'Multiple failed login attempts detected for user john.doe@edu.com',
        type: AdminNotificationType.security,
        priority: AdminNotificationPriority.urgent,
        category: AdminNotificationCategory.security,
        createdAt: now.subtract(const Duration(hours: 3)),
        requiresAction: true,
      ),
      AdminNotificationModel(
        id: '5',
        title: 'Monthly Report Generated',
        message: 'System usage report for December 2024 is now available',
        type: AdminNotificationType.report,
        priority: AdminNotificationPriority.normal,
        category: AdminNotificationCategory.reports,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      AdminNotificationModel(
        id: '6',
        title: 'New Instructor Joined',
        message: 'Dr. Mark Johnson has been added as an instructor',
        type: AdminNotificationType.userActivity,
        priority: AdminNotificationPriority.normal,
        category: AdminNotificationCategory.users,
        createdAt: now.subtract(const Duration(hours: 8)),
        userName: 'Dr. Mark Johnson',
        userRole: 'Instructor',
        isRead: true,
      ),
      AdminNotificationModel(
        id: '7',
        title: 'Database Backup Completed',
        message: 'Automated backup completed successfully at 3:00 AM',
        type: AdminNotificationType.systemAlert,
        priority: AdminNotificationPriority.low,
        category: AdminNotificationCategory.system,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AdminNotificationModel(
        id: '8',
        title: 'Enrollment Spike Detected',
        message: '150 new enrollments in the last 24 hours - 50% above average',
        type: AdminNotificationType.report,
        priority: AdminNotificationPriority.normal,
        category: AdminNotificationCategory.reports,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      AdminNotificationModel(
        id: '9',
        title: 'User Role Update',
        message: 'Lisa Chen promoted from TA to Instructor',
        type: AdminNotificationType.userActivity,
        priority: AdminNotificationPriority.normal,
        category: AdminNotificationCategory.users,
        createdAt: now.subtract(const Duration(days: 2)),
        userName: 'Lisa Chen',
        isRead: true,
      ),
      AdminNotificationModel(
        id: '10',
        title: 'Storage Warning',
        message: 'Server storage at 85% capacity - consider cleanup',
        type: AdminNotificationType.systemAlert,
        priority: AdminNotificationPriority.high,
        category: AdminNotificationCategory.system,
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        requiresAction: true,
      ),
    ];
  }

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
