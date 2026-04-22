import 'package:flutter/material.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;

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
                _buildHeader(responsive),
                SizedBox(height: responsive.p12),
                _buildTitle(responsive),
                if (assignment.description != null) ...[
                  SizedBox(height: responsive.p8),
                  _buildDescription(responsive),
                ],
                SizedBox(height: responsive.p12),
                _buildInfoRow(responsive),
                SizedBox(height: responsive.p12),
                _buildFooter(responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return const Color(0xFF3B82F6);
      case 'overdue':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Widget _buildHeader(ResponsiveUtil responsive) {
    final submissionTypeColor = _submissionTypeColor();
    final submissionStatusColor = _submissionStatusColor();
    final apiStatusColor = _apiStatusColor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: responsive.p8,
            runSpacing: responsive.p6,
            children: [
              _buildHeaderChip(
                responsive: responsive,
                icon: _submissionTypeIcon(),
                text: _submissionTypeLabel(),
                color: submissionTypeColor,
                iconSize: responsive.fontSize10,
                textSize: responsive.fontSize10,
              ),
              _buildHeaderChip(
                responsive: responsive,
                icon: Icons.task_alt_rounded,
                text: _apiStatusLabel(),
                color: apiStatusColor,
                iconSize: responsive.fontSize10,
                textSize: responsive.fontSize10,
              ),
              _buildHeaderChip(
                responsive: responsive,
                icon: _submissionStatusIcon(),
                text: _submissionStatusLabel(),
                color: submissionStatusColor,
                iconSize: responsive.fontSize12,
                textSize: responsive.fontSize12,
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

  Widget _buildHeaderChip({
    required ResponsiveUtil responsive,
    required IconData icon,
    required String text,
    required Color color,
    required double iconSize,
    required double textSize,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p8,
        vertical: responsive.p4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(responsive.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(width: responsive.p4),
          Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
        if (assignment.instructionFiles != null &&
            assignment.instructionFiles!.isNotEmpty) ...[
          SizedBox(width: responsive.p8),
          _buildInfoChip(
            Icons.attach_file_rounded,
            '${assignment.instructionFiles!.length}',
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

  Widget _buildFooter(ResponsiveUtil responsive) {
    return Row(
      children: [
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
        if (assignment.hasSubmission && assignment.grade != null)
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
        else if (assignment.hasSubmission)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: _submissionStatusColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.alarm_outlined,
                  size: responsive.fontSize12,
                  color: _submissionStatusColor(),
                ),
                SizedBox(width: responsive.p4),
                Text(
                  'Awaiting Grade',
                  style: TextStyle(
                    fontSize: responsive.fontSize11,
                    fontWeight: FontWeight.w600,
                    color: _submissionStatusColor(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getDueDateColor() {
    if (assignment.submissionFilterStatus == 'overdue') {
      return const Color(0xFFEF4444);
    }
    if (assignment.isDueToday || assignment.isDueTomorrow) {
      return const Color(0xFFF59E0B);
    }
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  String _getDueDateText() {
    if (assignment.submissionFilterStatus == 'overdue') {
      final daysOverdue = -assignment.daysUntilDue;
      if (daysOverdue == 0) {
        final hoursOverdue = -assignment.hoursUntilDue;
        return 'Overdue by ${hoursOverdue}h';
      }
      return 'Overdue by $daysOverdue day${daysOverdue > 1 ? 's' : ''}';
    }
    if (assignment.isDueToday) {
      final hoursLeft = assignment.hoursUntilDue;
      if (hoursLeft <= 0) {
        return 'Due now!';
      }
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
      return <Color>[const Color(0xFF10B981), const Color(0xFF059669)];
    }
    if (percentage >= 60) {
      return <Color>[const Color(0xFFF59E0B), const Color(0xFFD97706)];
    }
    return <Color>[const Color(0xFFEF4444), const Color(0xFFDC2626)];
  }

  String _formatDate(DateTime date) {
    final months = <String>[
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

  String _submissionTypeLabel() {
    switch (assignment.submissionType) {
      case api.SubmissionType.file:
        return 'File';
      case api.SubmissionType.text:
        return 'Text';
      case api.SubmissionType.link:
        return 'Link';
      case api.SubmissionType.multiple:
        return 'Any';
      case api.SubmissionType.unknown:
        return 'Mixed';
    }
  }

  IconData _submissionTypeIcon() {
    switch (assignment.submissionType) {
      case api.SubmissionType.file:
        return Icons.upload_file_rounded;
      case api.SubmissionType.text:
        return Icons.notes_rounded;
      case api.SubmissionType.link:
        return Icons.link_rounded;
      case api.SubmissionType.multiple:
        return Icons.widgets_rounded;
      case api.SubmissionType.unknown:
        return Icons.assignment_rounded;
    }
  }

  Color _submissionTypeColor() {
    switch (assignment.submissionType) {
      case api.SubmissionType.file:
        return const Color(0xFF3B82F6);
      case api.SubmissionType.text:
        return const Color(0xFFF59E0B);
      case api.SubmissionType.link:
        return const Color(0xFF8B5CF6);
      case api.SubmissionType.multiple:
        return const Color(0xFF10B981);
      case api.SubmissionType.unknown:
        return const Color(0xFF6B7280);
    }
  }

  String _apiStatusLabel() {
    switch (assignment.apiStatus) {
      case api.AssignmentStatus.draft:
        return 'Draft';
      case api.AssignmentStatus.published:
        return 'Published';
      case api.AssignmentStatus.closed:
        return 'Closed';
      case api.AssignmentStatus.archived:
        return 'Archived';
      case api.AssignmentStatus.unknown:
        return 'Unknown';
    }
  }

  Color _apiStatusColor() {
    switch (assignment.apiStatus) {
      case api.AssignmentStatus.draft:
        return const Color(0xFF6B7280);
      case api.AssignmentStatus.published:
        return const Color(0xFF10B981);
      case api.AssignmentStatus.closed:
        return const Color(0xFFF59E0B);
      case api.AssignmentStatus.archived:
        return const Color(0xFF6B7280);
      case api.AssignmentStatus.unknown:
        return const Color(0xFF6B7280);
    }
  }

  String _submissionStatusLabel() {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return 'Submitted';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Pending';
    }
  }

  Color _submissionStatusColor() {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return const Color(0xFF3B82F6);
      case 'overdue':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _submissionStatusIcon() {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return Icons.cloud_done_rounded;
      case 'overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }
}
