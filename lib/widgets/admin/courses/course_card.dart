import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Course model for the list
class CourseModel {
  final String id;
  final String code;
  final String name;
  final String department;
  final String? instructorName;
  final String? instructorInitials;
  final String? taName;
  final String? taInitials;
  final int studentCount;
  final int labCount;
  final double avgGrade;
  final String status; // 'healthy', 'warning', 'critical'
  final String? aiInsight;
  final bool isActive;
  final bool hasLabs;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    this.instructorName,
    this.instructorInitials,
    this.taName,
    this.taInitials,
    this.studentCount = 0,
    this.labCount = 0,
    this.avgGrade = 0.0,
    this.status = 'healthy',
    this.aiInsight,
    this.isActive = true,
    this.hasLabs = false,
  });
}

/// Course card widget
class CourseCard extends StatelessWidget {
  final bool isDark;
  final CourseModel course;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onViewLabs;
  final VoidCallback onViewDetails;

  const CourseCard({
    super.key,
    required this.isDark,
    required this.course,
    required this.onEdit,
    required this.onAssign,
    required this.onViewLabs,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 16),
                _buildStaffSection(l10n),
                const SizedBox(height: 16),
                _buildStatsSection(l10n),
                if (course.aiInsight != null) ...[
                  const SizedBox(height: 16),
                  _buildAIInsight(l10n),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildBadge(
              label: course.code,
              color: AdminColors.primary,
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          course.name,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          course.department,
          style: TextStyle(
            color: AdminColors.getTextSecondaryColor(isDark),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (course.status) {
      case 'healthy':
        statusColor = AdminColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Healthy';
        break;
      case 'warning':
        statusColor = AdminColors.warning;
        statusIcon = Icons.warning_rounded;
        statusText = 'Warning';
        break;
      case 'critical':
        statusColor = AdminColors.error;
        statusIcon = Icons.error_rounded;
        statusText = 'Critical';
        break;
      default:
        statusColor = AdminColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Healthy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection(AppLocalizations l10n) {
    return Column(
      children: [
        _buildStaffRow(
          label: l10n.instructor,
          name: course.instructorName ?? l10n.notAssigned,
          initials: course.instructorInitials ?? '?',
          color: AdminColors.secondary,
          isAssigned: course.instructorName != null,
        ),
        const SizedBox(height: 10),
        _buildStaffRow(
          label: l10n.teachingAssistant,
          name: course.taName ?? l10n.notAssigned,
          initials: course.taInitials ?? '?',
          color: AdminColors.accent,
          isAssigned: course.taName != null,
        ),
      ],
    );
  }

  Widget _buildStaffRow({
    required String label,
    required String name,
    required String initials,
    required Color color,
    required bool isAssigned,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: isAssigned
                ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
                : null,
            color: isAssigned ? null : AdminColors.getTextTertiaryColor(isDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AdminColors.getTextTertiaryColor(isDark),
                fontSize: 11,
              ),
            ),
            Text(
              name,
              style: TextStyle(
                color: isAssigned
                    ? AdminColors.getTextColor(isDark)
                    : AdminColors.warning,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: isAssigned ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.people_rounded,
              label: l10n.students,
              value: course.studentCount.toString(),
              color: AdminColors.primary,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.science_rounded,
              label: l10n.labs,
              value: course.labCount.toString(),
              color: AdminColors.accent,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.grade_rounded,
              label: l10n.avg,
              value: '${course.avgGrade.toStringAsFixed(0)}%',
              color: _getGradeColor(course.avgGrade),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
    );
  }

  Widget _buildAIInsight(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AdminColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AdminColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              course.aiInsight!,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_rounded,
            label: l10n.edit,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.person_add_rounded,
            label: l10n.assign,
            onTap: onAssign,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.science_rounded,
            label: l10n.labs,
            onTap: onViewLabs,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: AdminColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 80) return AdminColors.success;
    if (grade >= 60) return AdminColors.warning;
    return AdminColors.error;
  }
}
