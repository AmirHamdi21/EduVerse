import 'package:equatable/equatable.dart';
import '../materials/announcement_model.dart';

/// Model for instructor announcements
class AnnouncementItem extends Equatable {
  final String id;
  final String title;
  final String content;
  final AnnouncementStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final String audience;
  final int totalAudience;
  final int readCount;
  final List<String> attachments;
  final String? courseName;
  final String? courseId;
  final bool isPinned;
  final String? priority;
  final String? announcementType;
  final String? authorName;
  final String? targetAudience;
  final int viewCount;

  AnnouncementItem({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.publishedAt,
    this.audience = 'All Students',
    this.totalAudience = 0,
    this.readCount = 0,
    this.attachments = const [],
    this.courseName,
    this.courseId,
    this.isPinned = false,
    this.priority,
    this.announcementType,
    this.authorName,
    this.targetAudience,
    this.viewCount = 0,
  });

  factory AnnouncementItem.fromApi(AnnouncementModel api) {
    return AnnouncementItem(
      id: api.id,
      title: api.title,
      content: api.content,
      status: api.isPublished == 1
          ? AnnouncementStatus.published
          : AnnouncementStatus.draft,
      createdAt: api.createdAt,
      publishedAt: api.publishedAt,
      audience: api.course?.displayLabel ?? 'Campus-wide',
      totalAudience: 0,
      readCount: api.viewCount,
      courseName: api.course?.name,
      courseId: api.courseId,
      isPinned: api.isPinned == 1,
      priority: api.priority,
      announcementType: api.announcementType,
      authorName: api.author?.displayName,
      targetAudience: api.targetAudience,
      viewCount: api.viewCount,
    );
  }

  double get readRate =>
      totalAudience > 0 ? (readCount / totalAudience) * 100 : 0;

  AnnouncementItem copyWith({
    String? id,
    String? title,
    String? content,
    AnnouncementStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    String? audience,
    int? totalAudience,
    int? readCount,
    List<String>? attachments,
    String? courseName,
    String? courseId,
    bool? isPinned,
    String? priority,
    String? announcementType,
    String? authorName,
    String? targetAudience,
    int? viewCount,
  }) {
    return AnnouncementItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      publishedAt: publishedAt ?? this.publishedAt,
      audience: audience ?? this.audience,
      totalAudience: totalAudience ?? this.totalAudience,
      readCount: readCount ?? this.readCount,
      attachments: attachments ?? this.attachments,
      courseName: courseName ?? this.courseName,
      courseId: courseId ?? this.courseId,
      isPinned: isPinned ?? this.isPinned,
      priority: priority ?? this.priority,
      announcementType: announcementType ?? this.announcementType,
      authorName: authorName ?? this.authorName,
      targetAudience: targetAudience ?? this.targetAudience,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    status,
    createdAt,
    scheduledAt,
    publishedAt,
    audience,
    totalAudience,
    readCount,
    attachments,
    courseName,
    courseId,
    isPinned,
    priority,
    announcementType,
    authorName,
    targetAudience,
    viewCount,
  ];
}

enum AnnouncementStatus { draft, scheduled, published }

extension AnnouncementStatusExtension on AnnouncementStatus {
  String get displayName {
    switch (this) {
      case AnnouncementStatus.draft:
        return 'Draft';
      case AnnouncementStatus.scheduled:
        return 'Scheduled';
      case AnnouncementStatus.published:
        return 'Published';
    }
  }

  String get icon {
    switch (this) {
      case AnnouncementStatus.draft:
        return '📝';
      case AnnouncementStatus.scheduled:
        return '⏰';
      case AnnouncementStatus.published:
        return '✅';
    }
  }
}

/// Analytics data for an announcement
class AnnouncementAnalytics {
  final String announcementId;
  final String announcementTitle;
  final int totalViews;
  final double readRate;
  final List<ViewDataPoint> viewsOverTime;
  final String aiInsight;
  final DateTime? peakViewTime;

  AnnouncementAnalytics({
    required this.announcementId,
    required this.announcementTitle,
    required this.totalViews,
    required this.readRate,
    required this.viewsOverTime,
    required this.aiInsight,
    this.peakViewTime,
  });
}

class ViewDataPoint {
  final DateTime date;
  final int views;

  ViewDataPoint({required this.date, required this.views});
}
