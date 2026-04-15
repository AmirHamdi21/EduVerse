import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// AI course preview widget
class CourseAiPreview extends StatelessWidget {
  final bool isDark;
  final String courseName;
  final String courseCode;
  final String? department;
  final String? level;
  final String? semester;
  final String? instructor;
  final List<String> tas;
  final int maxStudents;
  final bool hasLabs;
  final int labCount;
  final bool isAnalyzing;

  const CourseAiPreview({
    super.key,
    required this.isDark,
    required this.courseName,
    required this.courseCode,
    this.department,
    this.level,
    this.semester,
    this.instructor,
    this.tas = const [],
    this.maxStudents = 30,
    this.hasLabs = false,
    this.labCount = 1,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
              : [const Color(0xFFEFF6FF), const Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.primary.withValues(alpha: 0.3)
              : AdminColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiCoursePreview,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.aiAnalyzingCourse,
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAnalyzing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AdminColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (courseName.isNotEmpty || courseCode.isNotEmpty) ...[
            _buildPreviewCard(l10n),
            const SizedBox(height: 16),
            _buildAiInsights(l10n),
          ] else
            _buildEmptyState(l10n),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  courseCode.isNotEmpty ? courseCode : 'CODE',
                  style: TextStyle(
                    color: AdminColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AdminColors.success),
                    const SizedBox(width: 4),
                    Text(
                      l10n.preview,
                      style: TextStyle(
                        color: AdminColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            courseName.isNotEmpty ? courseName : l10n.courseName,
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (department != null)
                _buildInfoChip(
                  icon: Icons.school_rounded,
                  label: department!,
                  color: AdminColors.secondary,
                ),
              if (level != null)
                _buildInfoChip(
                  icon: Icons.stairs_rounded,
                  label: level!,
                  color: AdminColors.accent,
                ),
              if (semester != null)
                _buildInfoChip(
                  icon: Icons.calendar_month_rounded,
                  label: semester!,
                  color: AdminColors.warning,
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.group_rounded,
                  label: l10n.capacity,
                  value: '$maxStudents',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.person_rounded,
                  label: l10n.instructor,
                  value: instructor != null ? '1' : '0',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.badge_rounded,
                  label: l10n.tas,
                  value: '${tas.length}',
                ),
              ),
              if (hasLabs)
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.science_rounded,
                    label: l10n.labs,
                    value: '$labCount',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AdminColors.getTextSecondaryColor(isDark)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsights(AppLocalizations l10n) {
    final insights = _generateInsights(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiInsights,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(insight.icon, size: 16, color: insight.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.text,
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<_Insight> _generateInsights(AppLocalizations l10n) {
    final insights = <_Insight>[];

    if (instructor == null) {
      insights.add(
        _Insight(
          icon: Icons.warning_rounded,
          color: AdminColors.warning,
          text: l10n.noInstructorAssigned,
        ),
      );
    } else {
      insights.add(
        _Insight(
          icon: Icons.check_circle_rounded,
          color: AdminColors.success,
          text: l10n.instructorAssigned,
        ),
      );
    }

    if (tas.isEmpty) {
      insights.add(
        _Insight(
          icon: Icons.info_rounded,
          color: AdminColors.accent,
          text: l10n.noTAAssigned,
        ),
      );
    } else if (tas.length < 2 && maxStudents > 50) {
      insights.add(
        _Insight(
          icon: Icons.lightbulb_rounded,
          color: AdminColors.warning,
          text: l10n.recommendMoreTAs,
        ),
      );
    }

    if (maxStudents > 100 && !hasLabs) {
      insights.add(
        _Insight(
          icon: Icons.lightbulb_rounded,
          color: AdminColors.primary,
          text: l10n.largeClassSuggestion,
        ),
      );
    }

    if (hasLabs && labCount * 25 < maxStudents) {
      insights.add(
        _Insight(
          icon: Icons.info_rounded,
          color: AdminColors.warning,
          text: l10n.labCapacityWarning,
        ),
      );
    }

    return insights;
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.preview_rounded,
            size: 48,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.startFillingForm,
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Insight {
  final IconData icon;
  final Color color;
  final String text;

  _Insight({required this.icon, required this.color, required this.text});
}
