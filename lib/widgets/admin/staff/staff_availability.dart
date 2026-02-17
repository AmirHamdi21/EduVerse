import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Staff availability widget showing instructors and TAs
class StaffAvailability extends StatelessWidget {
  final bool isDark;
  final List<StaffMember> instructors;
  final List<StaffMember> teachingAssistants;
  final Function(StaffMember) onStaffTapped;

  const StaffAvailability({
    super.key,
    required this.isDark,
    required this.instructors,
    required this.teachingAssistants,
    required this.onStaffTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.cyanGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.staffAvailability,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.workloadAndInsights,
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: l10n.instructors,
            icon: Icons.school_rounded,
            color: AdminColors.secondary,
            staff: instructors,
            l10n: l10n,
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: l10n.teachingAssistants,
            icon: Icons.badge_rounded,
            color: AdminColors.accent,
            staff: teachingAssistants,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<StaffMember> staff,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (staff.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                l10n.noStaffAvailable,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...staff.map((member) => _buildStaffCard(member, color, l10n)),
      ],
    );
  }

  Widget _buildStaffCard(StaffMember member, Color accentColor, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onStaffTapped(member),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: member.isOverloaded
                  ? AdminColors.warning.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: accentColor.withValues(alpha: 0.2),
                    child: Text(
                      member.initials,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getStatusColor(member.status),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AdminColors.darkCard : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      member.department,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWorkloadBadge(member, l10n),
                  const SizedBox(height: 4),
                  _buildStatusBadge(member, l10n),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkloadBadge(StaffMember member, AppLocalizations l10n) {
    final Color badgeColor;
    if (member.workloadPercent >= 100) {
      badgeColor = AdminColors.error;
    } else if (member.workloadPercent >= 75) {
      badgeColor = AdminColors.warning;
    } else {
      badgeColor = AdminColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${member.workloadPercent}%',
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StaffMember member, AppLocalizations l10n) {
    final statusText = _getStatusText(member.status, l10n);
    final statusColor = _getStatusColor(member.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.available:
        return AdminColors.success;
      case StaffStatus.atCapacity:
        return AdminColors.warning;
      case StaffStatus.overloaded:
        return AdminColors.error;
      case StaffStatus.onLeave:
        return Colors.grey;
    }
  }

  String _getStatusText(StaffStatus status, AppLocalizations l10n) {
    switch (status) {
      case StaffStatus.available:
        return l10n.available;
      case StaffStatus.atCapacity:
        return l10n.atCapacity;
      case StaffStatus.overloaded:
        return l10n.overloaded;
      case StaffStatus.onLeave:
        return l10n.onLeave;
    }
  }
}

enum StaffStatus { available, atCapacity, overloaded, onLeave }

class StaffMember {
  final String id;
  final String name;
  final String initials;
  final String department;
  final int workloadPercent;
  final StaffStatus status;
  final int assignedCourses;
  final bool isInstructor;

  StaffMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.department,
    required this.workloadPercent,
    required this.status,
    required this.assignedCourses,
    this.isInstructor = true,
  });

  bool get isOverloaded => status == StaffStatus.overloaded;
}
