import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/schedule_model.dart';
import '../../../models/instructor/instructor_course_model.dart';
import 'course_management_colors.dart';
import '../../shared/course_structure_viewer.dart';

/// Overview tab with course description, quick actions, and recent activity
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
      padding: const EdgeInsets.all(16),
      children: [
        _buildDescriptionCard(),
        const SizedBox(height: 16),
        _buildLiveMetricsCard(),
        const SizedBox(height: 16),
        // T009: Course Structure Viewer
        if (courseId != null)
          CourseStructureViewer(courseId: courseId, isDark: isDark),
        if (courseId != null) const SizedBox(height: 16),
        _buildSectionTitle('Section Schedule'),
        const SizedBox(height: 10),
        _buildScheduleCard(),
        const SizedBox(height: 20),
        _buildQuickActionsRow(context),
        const SizedBox(height: 20),
        _buildSectionTitle(l10n.recentActivity),
        const SizedBox(height: 10),
        _buildActivityTimeline(deadlines),
        const SizedBox(height: 20),
        _buildAnnouncementsSection(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [CMColors.darkCard, CMColors.darkSurface]
              : [Colors.white, const Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: CMColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'About This Course',
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            course.description,
            style: TextStyle(
              color: CMColors.textSub(isDark),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMetricsCard() {
    final metrics =
        engagementMetrics ??
        EngagementMetricsModel(
          totalMaterialViews: 0,
          totalMaterialDownloads: 0,
          assignmentSubmissionRate: 0,
          totalSubmissions: 0,
          totalEnrolledStudents: studentsCount,
        );
    final resolvedStudentsCount = studentsCount > 0
        ? studentsCount
        : metrics.totalEnrolledStudents;

    final gradeText = averageGrade == null
        ? '--'
        : '${averageGrade!.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.people_rounded,
                  title: 'Students',
                  value: resolvedStudentsCount.toString(),
                  color: CMColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.percent_rounded,
                  title: 'Avg Grade',
                  value: gradeText,
                  color: CMColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.visibility_rounded,
                  title: 'Material Views',
                  value: metrics.totalMaterialViews.toString(),
                  color: CMColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.assignment_turned_in_rounded,
                  title: l10n.assignmentSubmissionRate,
                  value:
                      '${metrics.assignmentSubmissionRate.toStringAsFixed(1)}%',
                  color: CMColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.download_rounded,
                  title: 'Downloads',
                  value: metrics.totalMaterialDownloads.toString(),
                  color: CMColors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.checklist_rounded,
                  title: 'Submissions',
                  value: metrics.totalSubmissions.toString(),
                  color: CMColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: CMColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CMColors.textSub(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    if (schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        ),
        child: Text(
          'No schedule available for this section yet',
          style: TextStyle(color: CMColors.textSub(isDark), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
      ),
      child: Column(
        children: List.generate(schedules.length, (index) {
          final schedule = schedules[index];
          final location = [
            schedule.room,
            schedule.building,
          ].where((value) => value != null && value.isNotEmpty).join(' • ');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CMColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: CMColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatEnum(schedule.dayOfWeek.value)} • ${schedule.startTime} - ${schedule.endTime}',
                            style: TextStyle(
                              color: CMColors.text(isDark),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatEnum(schedule.scheduleType.value)}${location.isNotEmpty ? ' • $location' : ''}',
                            style: TextStyle(
                              color: CMColors.textSub(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index < schedules.length - 1)
                Divider(
                  height: 1,
                  indent: 52,
                  endIndent: 14,
                  color: CMColors.borderColor(isDark),
                ),
            ],
          );
        }),
      ),
    );
  }

  String _formatEnum(String value) {
    final normalized = value.replaceAll('_', ' ').toLowerCase();
    if (normalized.isEmpty) {
      return 'Unknown';
    }

    final first = normalized[0].toUpperCase();
    return '$first${normalized.substring(1)}';
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.assignment_add,
            label: l10n.createAssignment,
            gradient: CMColors.warmGradient,
            isDark: isDark,
            onTap:
                onCreateAssignment ??
                () => _showSnack(context, 'Create Assignment'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.upload_file_rounded,
            label: l10n.uploadMaterial,
            gradient: CMColors.successGradient,
            isDark: isDark,
            onTap:
                onUploadMaterial ??
                () => _showSnack(context, 'Upload Material'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.campaign_rounded,
            label: l10n.postAnnouncement,
            gradient: CMColors.accentGradient,
            isDark: isDark,
            onTap:
                onPostAnnouncement ??
                () => _showSnack(context, 'Post Announcement'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: CMColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: CMColors.text(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTimeline(List<DeadlineCardModel> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CMColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        ),
        child: Text(
          'No upcoming activity yet',
          style: TextStyle(color: CMColors.textSub(isDark), fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final deadline = items[i];
          final color = _statusColor(deadline.status);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatDeadline(deadline),
                            style: TextStyle(
                              color: CMColors.textMutedColor(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: CMColors.textMutedColor(isDark),
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 16,
                  color: CMColors.borderColor(isDark),
                ),
            ],
          );
        }),
      ),
    );
  }

  String _formatDeadline(DeadlineCardModel deadline) {
    if (deadline.dueDate == null) {
      return 'No due date';
    }

    final due = deadline.dueDate!;
    return '${due.day}/${due.month}/${due.year}';
  }

  Color _statusColor(DeadlineStatus status) {
    switch (status) {
      case DeadlineStatus.overdue:
        return CMColors.error;
      case DeadlineStatus.dueToday:
        return CMColors.orange;
      case DeadlineStatus.upcoming:
        return CMColors.success;
    }
  }

  Widget _buildAnnouncementsSection() {
    if (course.announcements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Announcements'),
        const SizedBox(height: 10),
        ...course.announcements.map(
          (a) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [CMColors.darkCard, CMColors.darkSurface]
                    : [
                        CMColors.warningLight.withValues(alpha: 0.5),
                        Colors.white,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CMColors.warning.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CMColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    a.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.campaign_rounded,
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
                        a.title,
                        style: TextStyle(
                          color: CMColors.text(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        a.content,
                        style: TextStyle(
                          color: CMColors.textSub(isDark),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: CMColors.primary,
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: CMColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CMColors.borderColor(isDark), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
