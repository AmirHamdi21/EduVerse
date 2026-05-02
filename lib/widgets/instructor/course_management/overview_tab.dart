import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/schedule_model.dart';
import '../../../models/instructor/instructor_course_model.dart';
import 'course_management_colors.dart';

class OverviewTab extends StatelessWidget {
  final InstructorCourseModel course;
  final bool isDark;
  final AppLocalizations l10n;
  final dynamic courseId;
  final List<DeadlineCardModel> deadlines;
  final int studentsCount;
  final double? averageGrade;
  final EngagementMetricsModel? engagementMetrics;
  final List<ScheduleModel> schedules;
  final VoidCallback? onCreateAssignment;
  final VoidCallback? onUploadMaterial;
  final VoidCallback? onPostAnnouncement;

  const OverviewTab({
    super.key,
    required this.course,
    required this.isDark,
    required this.l10n,
    this.courseId,
    this.deadlines = const <DeadlineCardModel>[],
    this.studentsCount = 0,
    this.averageGrade,
    this.engagementMetrics,
    this.schedules = const <ScheduleModel>[],
    this.onCreateAssignment,
    this.onUploadMaterial,
    this.onPostAnnouncement,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _buildOverviewCard(),
        const SizedBox(height: 16),
        _buildPerformanceCard(),
        const SizedBox(height: 16),
        _buildQuickActionsCard(context),
        const SizedBox(height: 16),
        _buildScheduleCard(),
        const SizedBox(height: 16),
        _buildActivityCard(),
        if (course.announcements.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAnnouncementsCard(),
        ],
      ],
    );
  }

  Widget _buildOverviewCard() {
    final infoItems = <_OverviewItem>[
      _OverviewItem(
        icon: Icons.sell_outlined,
        label: course.code,
        tint: CMColors.primary,
      ),
      _OverviewItem(
        icon: Icons.credit_card_outlined,
        label: course.semester.trim().isNotEmpty ? course.semester : '--',
        tint: CMColors.accent,
      ),
      _OverviewItem(
        icon: course.isActive ? Icons.verified_outlined : Icons.archive_outlined,
        label: course.isActive ? l10n.activeLabel : l10n.archived,
        tint: course.isActive ? CMColors.success : CMColors.warning,
      ),
      _OverviewItem(
        icon: Icons.people_alt_outlined,
        label: '$studentsCount ${l10n.students}',
        tint: CMColors.primaryMedium,
      ),
      _OverviewItem(
        icon: Icons.assignment_outlined,
        label: '${course.assignments.length} ${l10n.assignments}',
        tint: CMColors.orange,
      ),
      _OverviewItem(
        icon: Icons.video_library_outlined,
        label: '${course.materials.length} ${l10n.courseMaterials}',
        tint: CMColors.teal,
      ),
    ];

    return _SectionCard(
      isDark: isDark,
      title: l10n.studentCourseDetailOverviewHeading,
      subtitle: course.description.trim().isNotEmpty
          ? course.description.trim()
          : l10n.instructorCourseDetailHeroSubtitle,
      child: _ResponsiveWrapGrid(
        children: infoItems
            .map((item) => _OverviewPill(item: item, isDark: isDark))
            .toList(growable: false),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    final metrics =
        engagementMetrics ??
        EngagementMetricsModel(
          totalMaterialViews: 0,
          totalMaterialDownloads: 0,
          assignmentSubmissionRate: 0,
          totalSubmissions: 0,
          totalEnrolledStudents: studentsCount,
        );

    final metricItems = <_OverviewItem>[
      _OverviewItem(
        icon: Icons.insights_outlined,
        label: averageGrade == null
            ? '--'
            : '${averageGrade!.toStringAsFixed(1)}%',
        caption: l10n.averageGrade,
        tint: CMColors.success,
      ),
      _OverviewItem(
        icon: Icons.visibility_outlined,
        label: metrics.totalMaterialViews.toString(),
        caption: l10n.views,
        tint: CMColors.primary,
      ),
      _OverviewItem(
        icon: Icons.download_outlined,
        label: metrics.totalMaterialDownloads.toString(),
        caption: l10n.download,
        tint: CMColors.teal,
      ),
      _OverviewItem(
        icon: Icons.assignment_turned_in_outlined,
        label: '${metrics.assignmentSubmissionRate.toStringAsFixed(1)}%',
        caption: l10n.assignmentSubmissionRate,
        tint: CMColors.orange,
      ),
      _OverviewItem(
        icon: Icons.checklist_rounded,
        label: metrics.totalSubmissions.toString(),
        caption: l10n.submissions,
        tint: CMColors.warning,
      ),
      _OverviewItem(
        icon: Icons.groups_outlined,
        label: metrics.totalEnrolledStudents.toString(),
        caption: l10n.students,
        tint: CMColors.accent,
      ),
    ];

    return _SectionCard(
      isDark: isDark,
      title: l10n.courseProgress,
      child: _ResponsiveWrapGrid(
        minTileWidth: 170,
        children: metricItems
            .map((item) => _ProgressPill(item: item, isDark: isDark))
            .toList(growable: false),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    final actions = <_QuickActionItem>[
      _QuickActionItem(
        icon: Icons.assignment_outlined,
        label: l10n.createAssignment,
        gradient: CMColors.warmGradient,
        onTap:
            onCreateAssignment ??
            () => _showSnack(context, l10n.createAssignment),
      ),
      _QuickActionItem(
        icon: Icons.upload_file_outlined,
        label: l10n.uploadMaterial,
        gradient: CMColors.successGradient,
        onTap:
            onUploadMaterial ?? () => _showSnack(context, l10n.uploadMaterial),
      ),
      _QuickActionItem(
        icon: Icons.campaign_outlined,
        label: l10n.postAnnouncement,
        gradient: CMColors.accentGradient,
        onTap:
            onPostAnnouncement ??
            () => _showSnack(context, l10n.postAnnouncement),
      ),
    ];

    return _SectionCard(
      isDark: isDark,
      title: l10n.searchQuickActions,
      child: _ResponsiveWrapGrid(
        minTileWidth: 180,
        children: actions
            .map(
              (action) => _QuickActionCard(
                action: action,
                isDark: isDark,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _SectionCard(
      isDark: isDark,
      title: l10n.schedule,
      child: schedules.isEmpty
          ? _EmptyMessage(
              message: l10n.instructorCourseDetailNoSchedule,
              isDark: isDark,
            )
          : Column(
              children: List.generate(schedules.length, (index) {
                final schedule = schedules[index];
                final location = [
                  schedule.room,
                  schedule.building,
                ].where((value) => value != null && value.isNotEmpty).join(' • ');

                return Column(
                  children: [
                    _ScheduleTile(
                      schedule: schedule,
                      location: location,
                      isDark: isDark,
                    ),
                    if (index < schedules.length - 1)
                      Divider(
                        height: 1,
                        color: CMColors.borderColor(isDark),
                      ),
                  ],
                );
              }),
            ),
    );
  }

  Widget _buildActivityCard() {
    return _SectionCard(
      isDark: isDark,
      title: l10n.recentActivity,
      child: deadlines.isEmpty
          ? _EmptyMessage(
              message: l10n.instructorCourseDetailNoActivity,
              isDark: isDark,
            )
          : Column(
              children: List.generate(deadlines.length, (index) {
                final deadline = deadlines[index];
                return Column(
                  children: [
                    _DeadlineTile(
                      deadline: deadline,
                      isDark: isDark,
                    ),
                    if (index < deadlines.length - 1)
                      Divider(
                        height: 1,
                        color: CMColors.borderColor(isDark),
                      ),
                  ],
                );
              }),
            ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return _SectionCard(
      isDark: isDark,
      title: l10n.announcements,
      child: Column(
        children: course.announcements
            .map(
              (announcement) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AnnouncementTile(
                  announcement: announcement,
                  isDark: isDark,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CMColors.primary,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CMColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: CMColors.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: CMColors.textSub(isDark),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ResponsiveWrapGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;

  const _ResponsiveWrapGrid({
    required this.children,
    this.minTileWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = constraints.maxWidth;
        final rawColumns = ((width + spacing) / (minTileWidth + spacing))
            .floor();
        final columns = rawColumns.clamp(1, 3);
        final tileWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: tileWidth, child: child))
              .toList(growable: false),
        );
      },
    );
  }
}

class _OverviewItem {
  final IconData icon;
  final String label;
  final String? caption;
  final Color tint;

  const _OverviewItem({
    required this.icon,
    required this.label,
    this.caption,
    required this.tint,
  });
}

class _OverviewPill extends StatelessWidget {
  final _OverviewItem item;
  final bool isDark;

  const _OverviewPill({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CMColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.tint, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CMColors.text(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final _OverviewItem item;
  final bool isDark;

  const _ProgressPill({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CMColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.tint, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.caption ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CMColors.textSub(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (item.caption != null)
            Icon(
              Icons.chevron_right_rounded,
              color: CMColors.textSub(isDark).withValues(alpha: 0.7),
              size: 18,
            ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionItem action;
  final bool isDark;

  const _QuickActionCard({
    required this.action,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: action.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: action.gradient.colors.first.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(action.icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final ScheduleModel schedule;
  final String location;
  final bool isDark;

  const _ScheduleTile({
    required this.schedule,
    required this.location,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CMColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: CMColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatEnum(schedule.dayOfWeek.value)} • ${schedule.startTime} - ${schedule.endTime}',
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatEnum(schedule.scheduleType.value)}${location.isNotEmpty ? ' • $location' : ''}',
                  style: TextStyle(
                    color: CMColors.textSub(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final DeadlineCardModel deadline;
  final bool isDark;

  const _DeadlineTile({
    required this.deadline,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (deadline.status) {
      DeadlineStatus.overdue => CMColors.error,
      DeadlineStatus.dueToday => CMColors.orange,
      DeadlineStatus.upcoming => CMColors.success,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              deadline.type == DeadlineType.assignment
                  ? Icons.assignment_rounded
                  : Icons.science_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.title,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadline.dueDate == null
                      ? '--'
                      : '${deadline.dueDate!.day}/${deadline.dueDate!.month}/${deadline.dueDate!.year}',
                  style: TextStyle(
                    color: CMColors.textSub(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: CMColors.textMutedColor(isDark),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  final bool isDark;

  const _AnnouncementTile({
    required this.announcement,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CMColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CMColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              announcement.isPinned
                  ? Icons.push_pin_rounded
                  : Icons.campaign_outlined,
              color: CMColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CMColors.textSub(isDark),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;
  final bool isDark;

  const _EmptyMessage({
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CMColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: CMColors.textSub(isDark),
          fontSize: 13,
        ),
      ),
    );
  }
}

String _formatEnum(String value) {
  final normalized = value.replaceAll('_', ' ').toLowerCase();
  if (normalized.isEmpty) {
    return '--';
  }

  final first = normalized[0].toUpperCase();
  return '$first${normalized.substring(1)}';
}
