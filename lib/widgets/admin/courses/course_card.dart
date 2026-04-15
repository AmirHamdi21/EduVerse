import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/course_model.dart';
import '../../../models/core/enums/course_enums.dart';
import '../shared/admin_colors.dart';

/// Course card widget bound to live [CourseModel] data.
class CourseCard extends StatelessWidget {
  final bool isDark;
  final CourseModel course;
  final String? instructorName;
  final String? instructorInitials;
  final String? taName;
  final String? taInitials;
  final int studentCount;
  final int labCount;
  final double averageGrade;
  final String? aiInsight;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onViewLabs;
  final VoidCallback onViewDetails;
  final VoidCallback? onDelete;

  const CourseCard({
    super.key,
    required this.isDark,
    required this.course,
    this.instructorName,
    this.instructorInitials,
    this.taName,
    this.taInitials,
    this.studentCount = 0,
    this.labCount = 0,
    this.averageGrade = 0,
    this.aiInsight,
    required this.onEdit,
    required this.onAssign,
    required this.onViewLabs,
    required this.onViewDetails,
    this.onDelete,
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
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
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
              children: <Widget>[
                _buildHeader(l10n),
                const SizedBox(height: 16),
                _buildStaffSection(l10n),
                const SizedBox(height: 16),
                _buildStatsSection(l10n),
                if (aiInsight != null &&
                    aiInsight!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _buildAIInsight(aiInsight!),
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
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildBadge(label: course.code, color: AdminColors.primary),
            const SizedBox(width: 8),
            _buildStatusBadge(l10n),
            if (course.courseStatus == CourseStatus.inactive) ...<Widget>[
              const SizedBox(width: 8),
              _buildBadge(
                label: '${l10n.draft}/${l10n.inactive}',
                color: AdminColors.warning,
              ),
            ],
            const Spacer(),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AdminColors.error,
                  size: 20,
                ),
                tooltip: l10n.delete,
              ),
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
          course.departmentName ?? l10n.department,
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

  Widget _buildStatusBadge(AppLocalizations l10n) {
    late Color statusColor;
    late IconData statusIcon;
    late String statusText;

    switch (course.courseStatus) {
      case CourseStatus.active:
        statusColor = AdminColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusText = l10n.active;
        break;
      case CourseStatus.inactive:
        statusColor = AdminColors.warning;
        statusIcon = Icons.pause_circle_rounded;
        statusText = l10n.inactive;
        break;
      case CourseStatus.archived:
        statusColor = AdminColors.getTextSecondaryColor(isDark);
        statusIcon = Icons.archive_rounded;
        statusText = l10n.archived;
        break;
      case CourseStatus.unknown:
        statusColor = AdminColors.getTextSecondaryColor(isDark);
        statusIcon = Icons.help_outline_rounded;
        statusText = l10n.noData;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
    final resolvedInstructor =
        instructorName != null && instructorName!.trim().isNotEmpty
        ? instructorName!
        : l10n.notAssigned;

    final resolvedTa = taName != null && taName!.trim().isNotEmpty
        ? taName!
        : l10n.notAssigned;

    return Column(
      children: <Widget>[
        _buildStaffRow(
          label: l10n.instructor,
          name: resolvedInstructor,
          initials: _safeInitials(instructorInitials, resolvedInstructor),
          color: AdminColors.secondary,
          isAssigned: resolvedInstructor != l10n.notAssigned,
        ),
        const SizedBox(height: 10),
        _buildStaffRow(
          label: l10n.teachingAssistant,
          name: resolvedTa,
          initials: _safeInitials(taInitials, resolvedTa),
          color: AdminColors.accent,
          isAssigned: resolvedTa != l10n.notAssigned,
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
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: isAssigned
                ? LinearGradient(
                    colors: <Color>[color, color.withValues(alpha: 0.7)],
                  )
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
          children: <Widget>[
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
        children: <Widget>[
          Expanded(
            child: _buildStatItem(
              icon: Icons.people_rounded,
              label: l10n.students,
              value: studentCount.toString(),
              color: AdminColors.primary,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.science_rounded,
              label: l10n.labs,
              value: labCount.toString(),
              color: AdminColors.accent,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.grade_rounded,
              label: l10n.avg,
              value: '${averageGrade.toStringAsFixed(0)}%',
              color: _getGradeColor(averageGrade),
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
      children: <Widget>[
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

  Widget _buildAIInsight(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: AdminColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
      children: <Widget>[
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
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightDivider,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 16, color: AdminColors.primary),
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
    if (grade >= 80) {
      return AdminColors.success;
    }
    if (grade >= 60) {
      return AdminColors.warning;
    }
    return AdminColors.error;
  }

  String _safeInitials(String? explicitInitials, String name) {
    if (explicitInitials != null && explicitInitials.trim().isNotEmpty) {
      return explicitInitials.trim();
    }

    final tokens = name.split(' ').where((value) => value.trim().isNotEmpty);
    final initials = tokens.take(2).map((value) => value[0]).join();
    if (initials.isNotEmpty) {
      return initials.toUpperCase();
    }
    return '?';
  }
}
