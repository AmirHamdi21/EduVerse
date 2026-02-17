import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';
import 'department_table.dart';

class DepartmentCard extends StatelessWidget {
  final bool isDark;
  final Department department;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onAssignHead;
  final VoidCallback onAssignTAs;

  const DepartmentCard({
    super.key,
    required this.isDark,
    required this.department,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onViewDetails,
    required this.onEdit,
    required this.onAssignHead,
    required this.onAssignTAs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: department.hasWarning
              ? AdminColors.warning.withValues(alpha: 0.5)
              : AdminColors.getCardBorderColor(isDark),
          width: department.hasWarning ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Department Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: department.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      department.icon,
                      color: department.iconColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Department Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                department.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.getTextColor(isDark),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (department.hasWarning) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AdminColors.warning,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${department.instructorCount} ${l10n?.instructors ?? 'Instructors'} • ${department.studentCount} ${l10n?.students ?? 'students'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AdminColors.getTextTertiaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Programs Tags
                  Wrap(
                    spacing: 4,
                    children: department.programs.take(3).map((program) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getProgramColor(
                            program,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          program,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getProgramColor(program),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 12),
                  // Expand Icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AdminColors.getTextTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          if (isExpanded) ...[
            Divider(height: 1, color: AdminColors.getDividerColor(isDark)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatItem(
                              icon: Icons.school_outlined,
                              label: l10n?.courses ?? 'Courses',
                              value: department.courseCount.toString(),
                              color: AdminColors.primary,
                            ),
                            const SizedBox(width: 24),
                            _buildStatItem(
                              icon: Icons.person_outline_rounded,
                              label: l10n?.instructors ?? 'Instructors',
                              value: department.instructorCount.toString(),
                              color: AdminColors.secondary,
                            ),
                            const SizedBox(width: 24),
                            _buildStatItem(
                              icon: Icons.people_outline_rounded,
                              label: l10n?.teachingAssistants ?? 'TAs',
                              value: department.taCount.toString(),
                              color: AdminColors.chartCyan,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Head Info
                  if (department.headName != null) ...[
                    _buildInfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: l10n?.departmentHead ?? 'Head',
                      value: department.headName!,
                    ),
                  ] else ...[
                    _buildWarningRow(
                      icon: Icons.person_off_outlined,
                      message: l10n?.noHeadAssigned ?? 'No Head Assigned',
                      actionLabel: l10n?.assignHead ?? 'Assign Head',
                      onAction: onAssignHead,
                    ),
                  ],
                  // Warnings
                  if (department.hasWarning &&
                      department.warningMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildWarningRow(
                      icon: Icons.warning_amber_rounded,
                      message: department.warningMessage!,
                      actionLabel: l10n?.assignTAs ?? 'Assign TAs',
                      onAction: onAssignTAs,
                      isWarning: true,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.visibility_outlined,
                          label: l10n?.viewDetails ?? 'View Details',
                          onTap: onViewDetails,
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.edit_outlined,
                          label: l10n?.edit ?? 'Edit',
                          onTap: onEdit,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminColors.getTextTertiaryColor(isDark)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningRow({
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isWarning ? AdminColors.warning : AdminColors.chartPurple)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isWarning ? AdminColors.warning : AdminColors.chartPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
          ),
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isWarning
                    ? AdminColors.warning
                    : AdminColors.chartPurple,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? AdminColors.primary
              : AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : AdminColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : AdminColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgramColor(String program) {
    switch (program.toLowerCase()) {
      case 'bsc':
        return AdminColors.primary;
      case 'msc':
        return AdminColors.secondary;
      case 'phd':
        return AdminColors.chartPink;
      case 'diploma':
        return AdminColors.chartCyan;
      case 'bba':
        return AdminColors.chartGreen;
      case 'mba':
        return AdminColors.chartOrange;
      default:
        return AdminColors.chartPurple;
    }
  }
}
