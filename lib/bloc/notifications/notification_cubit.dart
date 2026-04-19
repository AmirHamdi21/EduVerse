import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notifications/notification_model.dart';
import '../../services/api/student_stats_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final StudentStatsService? _studentStatsService;

  NotificationCubit({StudentStatsService? studentStatsService})
    : _studentStatsService = studentStatsService,
      super(const NotificationState());

  /// Load notifications - in a real app, this would call an API
  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationLoadingStatus.loading));

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate sample notifications
      final notifications = _generateSampleNotifications();
      final aiInsights = _generateSampleAIInsights();
      final systemAlerts = _generateSampleSystemAlerts();

      var unreadCount = notifications.where((n) => !n.isRead).length;

      // Keep the dashboard badge in sync with backend unread count when
      // available, while retaining demo notifications as the list source.
      if (_studentStatsService != null) {
        try {
          final unreadModel = await _studentStatsService.getUnreadCount();
          unreadCount = unreadModel.unreadCount;
        } catch (_) {
          // Ignore network failures and keep the locally computed fallback.
        }
      }

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

  /// Mark a notification as read
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

  /// Mark all notifications as read
  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications, unreadCount: 0));
  }

  /// Toggle bookmark status
  void toggleBookmark(String id) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isBookmarked: !n.isBookmarked);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }

  /// Delete a notification
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
  }

  /// Clear all notifications
  void clearAllNotifications() {
    emit(state.copyWith(notifications: [], unreadCount: 0));
  }

  /// Clear read notifications
  void clearReadNotifications() {
    final updatedNotifications = state.notifications
        .where((n) => !n.isRead)
        .toList();
    emit(state.copyWith(notifications: updatedNotifications));
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

  /// Generate sample notifications for demo
  List<NotificationModel> _generateSampleNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Assignment 2 Deadline Tomorrow',
        message:
            'Due Oct 20, 11:59 PM — Operating Systems. Make sure to submit your work on time.',
        type: NotificationType.assignment,
        priority: NotificationPriority.urgent,
        category: NotificationCategory.deadlines,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        courseName: 'Operating Systems',
        instructorName: 'Dr. Amy Sano',
        tags: {'Operating Systems': 'OS', 'Assignment': 'HW'},
        dueDate: now.add(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '2',
        title: 'New lecture notes uploaded',
        message:
            'Introduction to AI - Week 5 materials are now available. Review them before the next class.',
        type: NotificationType.lecture,
        priority: NotificationPriority.normal,
        category: NotificationCategory.courses,
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: false,
        courseName: 'Introduction to AI',
        instructorName: 'Prof. Sarah Johnson',
        tags: {'Introduction to AI': 'AI', 'Lecture': 'LEC'},
      ),
      NotificationModel(
        id: '3',
        title: 'Message from Prof. Alan Turing',
        message:
            'Reminder: Office hours are moved to 3 PM today. Please come prepared with your questions.',
        type: NotificationType.message,
        priority: NotificationPriority.normal,
        category: NotificationCategory.messages,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        instructorName: 'Prof. Alan Turing',
        tags: {'Message': 'MSG'},
      ),
      NotificationModel(
        id: '4',
        title: 'Midterm Exam Schedule Updated',
        message:
            'The exam date has been changed to December 15th. Make sure to update your study schedule.',
        type: NotificationType.exam,
        priority: NotificationPriority.high,
        category: NotificationCategory.deadlines,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: false,
        courseName: 'Machine Learning',
        instructorName: 'Dr. Alan Turing - Instructor',
        tags: {'Course': 'ML', 'Machine Learning': 'EXAM'},
        dueDate: DateTime(now.year, 12, 15),
      ),
      NotificationModel(
        id: '5',
        title: 'New Assignment',
        message:
            'Complete the binary search tree implementation by next week. Check the requirements carefully.',
        type: NotificationType.assignment,
        priority: NotificationPriority.normal,
        category: NotificationCategory.deadlines,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        courseName: 'Data Structures',
        instructorName: 'Dr. Grace Hopper - Instructor',
        tags: {'Course': 'DS', 'Algorithms': 'ALGO'},
        dueDate: now.add(const Duration(days: 7)),
      ),
      NotificationModel(
        id: '6',
        title: 'Lab Report Due Soon',
        message:
            'Physics II Lab 3 report due in 2 days. Submit through the portal before the deadline.',
        type: NotificationType.lab,
        priority: NotificationPriority.high,
        category: NotificationCategory.deadlines,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
        courseName: 'Physics II',
        instructorName: 'Lab Instructor',
        tags: {'Physics II': 'PHY', 'Lab': 'LAB'},
        dueDate: now.add(const Duration(days: 2)),
      ),
      NotificationModel(
        id: '7',
        title: 'Course Discussion Reply',
        message:
            'Someone replied to your question in the Neural Networks forum. Check it out!',
        type: NotificationType.message,
        priority: NotificationPriority.low,
        category: NotificationCategory.messages,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        courseName: 'Neural Networks',
      ),
      NotificationModel(
        id: '8',
        title: 'Quiz Results Available',
        message:
            'Your Data Structures quiz results are now available. View your score and feedback.',
        type: NotificationType.course,
        priority: NotificationPriority.normal,
        category: NotificationCategory.courses,
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
        courseName: 'Data Structures',
        instructorName: 'Dr. Grace Hopper',
      ),
    ];
  }

  /// Generate sample AI insights
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

  /// Generate sample system alerts
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
