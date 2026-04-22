import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';

class TADeadlineDetectionCard extends StatelessWidget {
  final List<UpcomingDeadline> deadlines;
  final bool isDark;
  final String? selectedCourse;
  final List<String> courseOptions;
  final ValueChanged<String?>? onCourseChanged;
  final Function(UpcomingDeadline)? onDeadlineTap;

  const TADeadlineDetectionCard({
    super.key,
    required this.deadlines,
    required this.isDark,
    this.selectedCourse,
    this.courseOptions = const [],
    this.onCourseChanged,
    this.onDeadlineTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TAColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: TAColors.warning,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Deadline Detection',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (courseOptions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCourse,
                      hint: Text(
                        'All Courses',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                      isDense: true,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: TAColors.cardColor(isDark),
                      items: courseOptions.map((course) {
                        return DropdownMenuItem(
                          value: course,
                          child: Text(course),
                        );
                      }).toList(),
                      onChanged: onCourseChanged,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (deadlines.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No upcoming deadlines',
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ...deadlines.asMap().entries.map((entry) {
              final index = entry.key;
              final deadline = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < deadlines.length - 1 ? 10 : 0,
                ),
                child: _buildDeadlineItem(deadline),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(UpcomingDeadline deadline) {
    final isUrgent = deadline.daysRemaining <= 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDeadlineTap?.call(deadline),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isUrgent ? TAColors.error : TAColors.warning).withValues(
              alpha: 0.08,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (isUrgent ? TAColors.error : TAColors.warning).withValues(
                alpha: 0.2,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isUrgent ? TAColors.error : TAColors.warning)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  deadline.icon,
                  size: 16,
                  color: isUrgent ? TAColors.error : TAColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deadline.course,
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(isDark),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isUrgent ? TAColors.error : TAColors.warning)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${deadline.daysRemaining}d',
                  style: TextStyle(
                    color: isUrgent ? TAColors.error : TAColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: TAColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingDeadline {
  final String title;
  final String course;
  final int daysRemaining;
  final IconData icon;

  UpcomingDeadline({
    required this.title,
    required this.course,
    required this.daysRemaining,
    this.icon = Icons.assignment,
  });
}
