import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import 'course_management_colors.dart';
import '../../shared/course_structure_viewer.dart';

/// Overview tab with course description, quick actions, and recent activity
class OverviewTab extends StatelessWidget {
  final InstructorCourseModel course;
  final bool isDark;
  final AppLocalizations l10n;
  final dynamic courseId;

  const OverviewTab({
    super.key,
    required this.course,
    required this.isDark,
    required this.l10n,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDescriptionCard(),
        const SizedBox(height: 16),
        // T009: Course Structure Viewer
        if (courseId != null)
          CourseStructureViewer(
            courseId: courseId,
            isDark: isDark,
          ),
        if (courseId != null) const SizedBox(height: 16),
        _buildQuickActionsRow(context),
        const SizedBox(height: 20),
        _buildSectionTitle(l10n.recentActivity),
        const SizedBox(height: 10),
        _buildActivityTimeline(),
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
        border: Border.all(
          color: CMColors.borderColor(isDark),
          width: 1,
        ),
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
                child: const Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 16),
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

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.assignment_add,
            label: l10n.createAssignment,
            gradient: CMColors.warmGradient,
            isDark: isDark,
            onTap: () => _showSnack(context, l10n.assignmentCreated),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.upload_file_rounded,
            label: l10n.uploadMaterial,
            gradient: CMColors.successGradient,
            isDark: isDark,
            onTap: () => _showSnack(context, l10n.materialUploaded),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.campaign_rounded,
            label: l10n.postAnnouncement,
            gradient: CMColors.accentGradient,
            isDark: isDark,
            onTap: () {},
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

  Widget _buildActivityTimeline() {
    final activities = [
      _ActivityData(
        Icons.assignment_turned_in_rounded,
        CMColors.success,
        '28 students submitted Process Scheduling',
        '2 hours ago',
      ),
      _ActivityData(
        Icons.announcement_rounded,
        CMColors.primary,
        'New announcement posted',
        '2 days ago',
      ),
      _ActivityData(
        Icons.upload_file_rounded,
        CMColors.orange,
        'Lab Session Recording uploaded',
        '3 days ago',
      ),
    ];

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
        children: List.generate(activities.length, (i) {
          final a = activities[i];
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            a.color.withValues(alpha: 0.15),
                            a.color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: a.color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(a.icon, color: a.color, size: 18),
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            a.time,
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
              if (i < activities.length - 1)
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

  Widget _buildAnnouncementsSection() {
    if (course.announcements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Announcements'),
        const SizedBox(height: 10),
        ...course.announcements.map((a) => Container(
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
            )),
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
            border: Border.all(
              color: CMColors.borderColor(isDark),
              width: 1,
            ),
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

class _ActivityData {
  final IconData icon;
  final Color color;
  final String title;
  final String time;

  _ActivityData(this.icon, this.color, this.title, this.time);
}
