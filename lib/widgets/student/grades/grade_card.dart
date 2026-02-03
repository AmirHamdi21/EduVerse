import 'package:flutter/material.dart';
import '../../../common/utils/responsive.dart';
import '../../../models/grades/grade_model.dart';

class GradeCard extends StatelessWidget {
  final CourseGrade course;
  final bool isDark;
  final VoidCallback onTap;
  final Animation<double>? animation;

  const GradeCard({
    super.key,
    required this.course,
    required this.isDark,
    required this.onTap,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final cardContent = _buildCardContent(context, responsive);

    if (animation != null) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation!, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: animation!,
          child: cardContent,
        ),
      );
    }
    return cardContent;
  }

  Widget _buildCardContent(BuildContext context, ResponsiveUtil responsive) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.p16,
        vertical: responsive.p8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius20),
        border: Border.all(
          color: course.courseColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : course.courseColor).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsive.radius20),
          child: Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(responsive),
                SizedBox(height: responsive.p12),
                _buildGradeRow(responsive),
                SizedBox(height: responsive.p12),
                _buildProgressBar(responsive),
                SizedBox(height: responsive.p12),
                _buildFooter(responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveUtil responsive) {
    return Row(
      children: [
        // Course icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                course.courseColor,
                course.courseColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(responsive.radius14),
            boxShadow: [
              BoxShadow(
                color: course.courseColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              course.courseCode.substring(0, 2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.p12),
        // Course info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.courseName,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: responsive.p4),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p8,
                      vertical: responsive.p2,
                    ),
                    decoration: BoxDecoration(
                      color: course.courseColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(responsive.radius6),
                    ),
                    child: Text(
                      course.courseCode,
                      style: TextStyle(
                        color: course.courseColor,
                        fontSize: responsive.fontSize12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.p8),
                  Icon(
                    Icons.school_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: responsive.p4),
                  Text(
                    '${course.creditHours} Credits',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: responsive.fontSize12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Grade badge
        _buildGradeBadge(responsive),
      ],
    );
  }

  Widget _buildGradeBadge(ResponsiveUtil responsive) {
    final grade = course.currentGrade;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p12,
        vertical: responsive.p8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            grade.color,
            grade.color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.radius12),
        boxShadow: [
          BoxShadow(
            color: grade.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        grade.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: responsive.fontSize18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildGradeRow(ResponsiveUtil responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            responsive,
            icon: Icons.trending_up_rounded,
            label: 'Current',
            value: '${course.currentPercentage.toStringAsFixed(1)}%',
            color: const Color(0xFF3B82F6),
          ),
          _buildStatDivider(responsive),
          _buildStatItem(
            responsive,
            icon: Icons.auto_graph_rounded,
            label: 'GPA',
            value: course.currentGrade.gpa.toStringAsFixed(2),
            color: const Color(0xFF10B981),
          ),
          _buildStatDivider(responsive),
          _buildStatItem(
            responsive,
            icon: Icons.assignment_turned_in_rounded,
            label: 'Graded',
            value: '${course.gradedCount}/${course.assessments.length}',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ResponsiveUtil responsive, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.p8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        SizedBox(height: responsive.p6),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: responsive.fontSize11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ResponsiveUtil responsive) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildProgressBar(ResponsiveUtil responsive) {
    final progress = course.currentPercentage / 100;
    final grade = course.currentGrade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${course.currentPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: grade.color,
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 8,
              width: double.infinity,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [grade.color, grade.color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: grade.color.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(ResponsiveUtil responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_rounded,
              size: 16,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            SizedBox(width: responsive.p4),
            Text(
              course.instructor,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: responsive.fontSize12,
              ),
            ),
          ],
        ),
        if (course.pendingCount > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p8,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(responsive.radius6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pending_rounded,
                  size: 14,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: responsive.p4),
                Text(
                  '${course.pendingCount} pending',
                  style: TextStyle(
                    color: const Color(0xFFF59E0B),
                    fontSize: responsive.fontSize11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p8,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(responsive.radius6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                SizedBox(width: responsive.p4),
                Text(
                  'Complete',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: responsive.fontSize11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
