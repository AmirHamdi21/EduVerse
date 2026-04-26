import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import 'course_management_colors.dart';

/// Scrollable header with course info card + quick stats
class CourseManagementHeader extends StatelessWidget {
  final InstructorCourseModel course;
  final bool isDark;
  final AppLocalizations l10n;
  final TabController tabController;
  final int? studentsCount;
  final int? assignmentsCount;
  final int? materialsCount;
  final ValueChanged<int>? onTabSelected;

  const CourseManagementHeader({
    super.key,
    required this.course,
    required this.isDark,
    required this.l10n,
    required this.tabController,
    this.studentsCount,
    this.assignmentsCount,
    this.materialsCount,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          _buildCourseInfoCard(),
          const SizedBox(height: 12),
          _buildQuickStats(),
          const SizedBox(height: 12),
          _buildTabBar(),
        ],
      ),
    );
  }

  Widget _buildCourseInfoCard() {
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CMColors.primaryMedium.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CMColors.primaryMedium.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Course avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(course.colorValue),
                  Color(course.colorValue).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Color(course.colorValue).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (course.code.length >= 2
                        ? course.code.substring(0, 2)
                        : course.code.padRight(2, 'C'))
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${course.code} • ${course.semester}',
                  style: TextStyle(
                    color: CMColors.textSub(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: course.isActive
                    ? [
                        CMColors.success.withValues(alpha: 0.15),
                        CMColors.success.withValues(alpha: 0.08),
                      ]
                    : [
                        CMColors.textMuted.withValues(alpha: 0.15),
                        CMColors.textMuted.withValues(alpha: 0.08),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: course.isActive
                    ? CMColors.success.withValues(alpha: 0.3)
                    : CMColors.textMuted.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: course.isActive
                        ? CMColors.success
                        : CMColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  course.isActive ? l10n.activeLabel : l10n.archived,
                  style: TextStyle(
                    color: course.isActive
                        ? CMColors.success
                        : CMColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final resolvedStudents = studentsCount ?? course.totalStudents;
    final resolvedAssignments = assignmentsCount ?? course.assignments.length;
    final resolvedMaterials = materialsCount ?? course.materials.length;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.people_rounded,
            value: resolvedStudents.toString(),
            label: l10n.students,
            gradient: CMColors.primaryGradient,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.assignment_rounded,
            value: resolvedAssignments.toString(),
            label: l10n.courseAssignments,
            gradient: CMColors.warmGradient,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.folder_rounded,
            value: resolvedMaterials.toString(),
            label: l10n.courseMaterials,
            gradient: CMColors.successGradient,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CMColors.darkCard : CMColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
      ),
      child: TabBar(
        controller: tabController,
        onTap: onTabSelected,
        labelColor: isDark ? Colors.white : Colors.black,
        unselectedLabelColor: CMColors.textMutedColor(isDark),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        indicator: BoxDecoration(
          gradient: CMColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CMColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(4),
        tabs: [
          _buildTab(Icons.dashboard_rounded, 'Overview', true),
          _buildTab(Icons.folder_rounded, 'Lectures', false),
          _buildTab(Icons.assignment_rounded, 'Assignments', false),
          _buildTab(Icons.grading_rounded, 'Grading', false),
          _buildTab(Icons.people_rounded, 'Students', false),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, bool isFirst) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final LinearGradient gradient;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CMColors.borderColor(isDark), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: CMColors.text(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: CMColors.textSub(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
