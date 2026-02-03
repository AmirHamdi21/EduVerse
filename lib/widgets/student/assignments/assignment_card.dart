import 'package:flutter/material.dart';
import '../../../../models/assignments/assignment_model.dart';
import '../../../../common/utils/responsive.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.isDark,
    required this.onTap,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.p16,
        vertical: responsive.p8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: _getBorderColor().withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : _getBorderColor()).withValues(
              alpha: 0.1,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsive.radius16),
          child: Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, responsive),
                SizedBox(height: responsive.p12),
                _buildTitle(responsive),
                if (assignment.description != null) ...[
                  SizedBox(height: responsive.p8),
                  _buildDescription(responsive),
                ],
                SizedBox(height: responsive.p12),
                _buildInfoRow(responsive),
                SizedBox(height: responsive.p12),
                _buildFooter(context, responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (assignment.isOverdue || assignment.status == AssignmentStatus.overdue) {
      return const Color(0xFFEF4444);
    }
    return assignment.status.color;
  }

  Widget _buildHeader(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        // Type badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p4,
            vertical: responsive.p4,
          ),
          decoration: BoxDecoration(
            color: assignment.type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                assignment.type.icon,
                size: responsive.fontSize10,
                color: assignment.type.color,
              ),
              SizedBox(width: responsive.p4),
              Text(
                assignment.type.label,
                style: TextStyle(
                  fontSize: responsive.fontSize10,
                  fontWeight: FontWeight.w600,
                  color: assignment.type.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: responsive.p8),
        // Priority badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p8,
            vertical: responsive.p4,
          ),
          decoration: BoxDecoration(
            color: assignment.priority.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                assignment.priority.icon,
                size: responsive.fontSize10,
                color: assignment.priority.color,
              ),
              SizedBox(width: responsive.p2),
              Text(
                assignment.priority.label,
                style: TextStyle(
                  fontSize: responsive.fontSize10,
                  fontWeight: FontWeight.w600,
                  color: assignment.priority.color,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Status badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p10,
            vertical: responsive.p4,
          ),
          decoration: BoxDecoration(
            color: assignment.status.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                assignment.status.icon,
                size: responsive.fontSize12,
                color: assignment.status.color,
              ),
              SizedBox(width: responsive.p4),
              Text(
                assignment.status.label,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: assignment.status.color,
                ),
              ),
            ],
          ),
        ),
        if (onBookmark != null) ...[
          SizedBox(width: responsive.p8),
          GestureDetector(
            onTap: onBookmark,
            child: Icon(
              assignment.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: assignment.isBookmarked
                  ? const Color(0xFFF59E0B)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: responsive.fontSize20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle(ResponsiveUtil responsive) {
    return Text(
      assignment.title,
      style: TextStyle(
        fontSize: responsive.fontSize16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(ResponsiveUtil responsive) {
    return Text(
      assignment.description!,
      style: TextStyle(
        fontSize: responsive.fontSize13,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoRow(ResponsiveUtil responsive) {
    return Row(
      children: [
        _buildInfoChip(
          Icons.school_rounded,
          assignment.courseCode,
          const Color(0xFF3B82F6),
          responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildInfoChip(
          Icons.grade_rounded,
          '${assignment.maxGrade.toStringAsFixed(0)} pts',
          const Color(0xFF8B5CF6),
          responsive,
        ),
        if (assignment.attachments != null &&
            assignment.attachments!.isNotEmpty) ...[
          SizedBox(width: responsive.p8),
          _buildInfoChip(
            Icons.attach_file_rounded,
            '${assignment.attachments!.length}',
            const Color(0xFF6366F1),
            responsive,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color color,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p8,
        vertical: responsive.p4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(responsive.radius6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.fontSize12, color: color),
          SizedBox(width: responsive.p4),
          Text(
            text,
            style: TextStyle(
              fontSize: responsive.fontSize11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        // Due date
        Icon(
          Icons.calendar_today_rounded,
          size: responsive.fontSize14,
          color: _getDueDateColor(),
        ),
        SizedBox(width: responsive.p6),
        Expanded(
          child: Text(
            _getDueDateText(),
            style: TextStyle(
              fontSize: responsive.fontSize12,
              color: _getDueDateColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Grade if graded
        if (assignment.status == AssignmentStatus.graded &&
            assignment.grade != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _getGradeColors()),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: responsive.fontSize12,
                  color: Colors.white,
                ),
                SizedBox(width: responsive.p4),
                Text(
                  '${assignment.grade!.toStringAsFixed(0)}/${assignment.maxGrade.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        // Progress indicator for submitted
        else if (assignment.status == AssignmentStatus.submitted ||
            assignment.status == AssignmentStatus.late)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: assignment.status.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(
                //   width: responsive.fontSize14,
                //   height: responsive.fontSize14,
                //   child: CircularProgressIndicator(
                //     strokeWidth: 2,
                //     valueColor: AlwaysStoppedAnimation<Color>(
                //       assignment.status.color,
                //     ),
                //   ),
                // ),
                // SizedBox(width: responsive.p6),
                Icon(
                  Icons.alarm_outlined,
                  size: responsive.fontSize12,
                  color: assignment.status.color,
                ),
                SizedBox(width: responsive.p4),
                Text(
                  'Awaiting Grade',
                  style: TextStyle(
                    fontSize: responsive.fontSize11,
                    fontWeight: FontWeight.w600,
                    color: assignment.status.color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getDueDateColor() {
    if (assignment.isOverdue || assignment.status == AssignmentStatus.overdue) {
      return const Color(0xFFEF4444);
    }
    if (assignment.isDueToday) {
      return const Color(0xFFF59E0B);
    }
    if (assignment.isDueTomorrow) {
      return const Color(0xFFF59E0B);
    }
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  String _getDueDateText() {
    if (assignment.isOverdue || assignment.status == AssignmentStatus.overdue) {
      final daysOverdue = -assignment.daysUntilDue;
      if (daysOverdue == 0) {
        final hoursOverdue = -assignment.hoursUntilDue;
        return 'Overdue by ${hoursOverdue}h';
      }
      return 'Overdue by $daysOverdue day${daysOverdue > 1 ? 's' : ''}';
    }
    if (assignment.isDueToday) {
      final hoursLeft = assignment.hoursUntilDue;
      if (hoursLeft <= 0) return 'Due now!';
      return 'Due in ${hoursLeft}h';
    }
    if (assignment.isDueTomorrow) {
      return 'Due tomorrow';
    }
    return 'Due ${_formatDate(assignment.dueDate)}';
  }

  List<Color> _getGradeColors() {
    final percentage = assignment.gradePercentage ?? 0;
    if (percentage >= 80) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    }
    if (percentage >= 60) {
      return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    }
    return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
