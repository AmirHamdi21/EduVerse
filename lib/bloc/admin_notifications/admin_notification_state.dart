import 'package:equatable/equatable.dart';
import '../../models/admin/admin_notification_model.dart';

enum AdminNotificationLoadingStatus {
  initial,
  loading,
  loaded,
  error,
}

class AdminNotificationState extends Equatable {
  final AdminNotificationLoadingStatus status;
  final List<AdminNotificationModel> notifications;
  final List<AdminAnnouncementModel> announcements;
  final AdminNotificationCategory selectedCategory;
  final String searchQuery;
  final bool isSearching;
  final String? errorMessage;
  final int currentTab;

  const AdminNotificationState({
    this.status = AdminNotificationLoadingStatus.initial,
    this.notifications = const [],
    this.announcements = const [],
    this.selectedCategory = AdminNotificationCategory.all,
    this.searchQuery = '',
    this.isSearching = false,
    this.errorMessage,
    this.currentTab = 0,
  });

  int get unreadCount =>
      notifications.where((n) => !n.isRead && !n.isArchived).length;

  int get pendingActionsCount =>
      notifications.where((n) => n.requiresAction && !n.isRead).length;

  int get announcementsCount => announcements.length;

  List<AdminNotificationModel> get filteredNotifications {
    var filtered = notifications.where((n) => !n.isArchived).toList();

    if (selectedCategory != AdminNotificationCategory.all) {
      filtered =
          filtered.where((n) => n.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.message.toLowerCase().contains(query) ||
            (n.userName?.toLowerCase().contains(query) ?? false) ||
            (n.courseName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  List<AdminNotificationModel> get archivedNotifications {
    var filtered = notifications.where((n) => n.isArchived).toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.message.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  List<AdminNotificationModel> get bookmarkedNotifications {
    return notifications
        .where((n) => n.isBookmarked)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<AdminAnnouncementModel> get filteredAnnouncements {
    var filtered = announcements.toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.content.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by pinned first, then by date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  AdminNotificationState copyWith({
    AdminNotificationLoadingStatus? status,
    List<AdminNotificationModel>? notifications,
    List<AdminAnnouncementModel>? announcements,
    AdminNotificationCategory? selectedCategory,
    String? searchQuery,
    bool? isSearching,
    String? errorMessage,
    int? currentTab,
  }) {
    return AdminNotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      announcements: announcements ?? this.announcements,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        announcements,
        selectedCategory,
        searchQuery,
        isSearching,
        errorMessage,
        currentTab,
      ];
}
