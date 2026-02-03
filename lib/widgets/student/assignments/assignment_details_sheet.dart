import 'package:flutter/material.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../models/assignments/assignment_model.dart';

class AssignmentDetailsSheet extends StatelessWidget {
  final AssignmentModel assignment;
  final bool isDark;
  final VoidCallback? onSubmit;
  final VoidCallback? onDownloadAttachments;

  const AssignmentDetailsSheet({
    super.key,
    required this.assignment,
    required this.isDark,
    this.onSubmit,
    this.onDownloadAttachments,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: responsive.p12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(responsive),
                  SizedBox(height: responsive.p16),
                  _buildStatusBadges(responsive),
                  SizedBox(height: responsive.p20),
                  _buildDueDateSection(responsive, l10n),
                  if (assignment.description != null) ...[
                    SizedBox(height: responsive.p20),
                    _buildDescription(responsive, l10n),
                  ],
                  if (assignment.instructions != null &&
                      assignment.instructions!.isNotEmpty) ...[
                    SizedBox(height: responsive.p20),
                    _buildInstructions(responsive, l10n),
                  ],
                  if (assignment.attachments != null &&
                      assignment.attachments!.isNotEmpty) ...[
                    SizedBox(height: responsive.p20),
                    _buildAttachments(responsive, l10n),
                  ],
                  if (assignment.submission != null) ...[
                    SizedBox(height: responsive.p20),
                    _buildSubmissionSection(responsive, l10n),
                  ],
                  if (assignment.status == AssignmentStatus.graded) ...[
                    SizedBox(height: responsive.p20),
                    _buildGradeSection(responsive, l10n),
                  ],
                  SizedBox(height: responsive.p24),
                  _buildActionButtons(context, responsive, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ResponsiveUtil responsive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type icon
        Container(
          width: responsive.p56,
          height: responsive.p56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                assignment.type.color,
                assignment.type.color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(responsive.radius16),
            boxShadow: [
              BoxShadow(
                color: assignment.type.color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            assignment.type.icon,
            color: Colors.white,
            size: responsive.fontSize28,
          ),
        ),
        SizedBox(width: responsive.p16),
        // Title and course
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.title,
                style: TextStyle(
                  fontSize: responsive.fontSize20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: responsive.p4),
              Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: responsive.fontSize14,
                    color: const Color(0xFF3B82F6),
                  ),
                  SizedBox(width: responsive.p4),
                  Expanded(
                    child: Text(
                      '${assignment.courseName} (${assignment.courseCode})',
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.p4),
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: responsive.fontSize14,
                    color: const Color(0xFF8B5CF6),
                  ),
                  SizedBox(width: responsive.p4),
                  Text(
                    assignment.instructorName,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges(ResponsiveUtil responsive) {
    return Wrap(
      spacing: responsive.p8,
      runSpacing: responsive.p8,
      children: [
        _buildBadge(
          assignment.status.icon,
          assignment.status.label,
          assignment.status.color,
          responsive,
        ),
        _buildBadge(
          assignment.priority.icon,
          assignment.priority.label,
          assignment.priority.color,
          responsive,
        ),
        _buildBadge(
          Icons.grade_rounded,
          '${assignment.maxGrade.toStringAsFixed(0)} points',
          const Color(0xFF6366F1),
          responsive,
        ),
      ],
    );
  }

  Widget _buildBadge(
      IconData icon, String label, Color color, ResponsiveUtil responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p10,
        vertical: responsive.p6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(responsive.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.fontSize14, color: color),
          SizedBox(width: responsive.p4),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateSection(ResponsiveUtil responsive, AppLocalizations l10n) {
    final isOverdue = assignment.isOverdue || assignment.status == AssignmentStatus.overdue;
    final dueDateColor = isOverdue
        ? const Color(0xFFEF4444)
        : assignment.isDueToday
            ? const Color(0xFFF59E0B)
            : const Color(0xFF3B82F6);

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: dueDateColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(color: dueDateColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.p44,
            height: responsive.p44,
            decoration: BoxDecoration(
              color: dueDateColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(responsive.radius12),
            ),
            child: Icon(
              isOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.calendar_today_rounded,
              color: dueDateColor,
              size: responsive.fontSize20,
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'Overdue' : 'Due Date',
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: responsive.p2),
                Text(
                  _formatFullDate(assignment.dueDate),
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.bold,
                    color: dueDateColor,
                  ),
                ),
              ],
            ),
          ),
          if (!isOverdue && assignment.status == AssignmentStatus.pending)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.p12,
                vertical: responsive.p8,
              ),
              decoration: BoxDecoration(
                color: dueDateColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(responsive.radius8),
              ),
              child: Text(
                _getTimeRemaining(),
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.bold,
                  color: dueDateColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_rounded,
              color: const Color(0xFF3B82F6),
              size: responsive.fontSize18,
            ),
            SizedBox(width: responsive.p8),
            Text(
              l10n.description,
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        Text(
          assignment.description!,
          style: TextStyle(
            fontSize: responsive.fontSize14,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.list_alt_rounded,
              color: const Color(0xFFF59E0B),
              size: responsive.fontSize18,
            ),
            SizedBox(width: responsive.p8),
            Text(
              'Instructions',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        ...assignment.instructions!.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.p8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: responsive.p24,
                  height: responsive.p24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontSize: responsive.fontSize12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: responsive.p10),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.4,
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

  Widget _buildAttachments(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: const Color(0xFF8B5CF6),
                  size: responsive.fontSize18,
                ),
                SizedBox(width: responsive.p8),
                Text(
                  'Attachments (${assignment.attachments!.length})',
                  style: TextStyle(
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            if (onDownloadAttachments != null)
              TextButton.icon(
                onPressed: onDownloadAttachments,
                icon: Icon(
                  Icons.download_rounded,
                  size: responsive.fontSize16,
                ),
                label: const Text('Download All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                ),
              ),
          ],
        ),
        SizedBox(height: responsive.p12),
        ...assignment.attachments!.map((attachment) {
          return Container(
            margin: EdgeInsets.only(bottom: responsive.p8),
            padding: EdgeInsets.all(responsive.p12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.5)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(responsive.radius12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: responsive.p40,
                  height: responsive.p40,
                  decoration: BoxDecoration(
                    color: _getFileColor(attachment.fileType).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(responsive.radius10),
                  ),
                  child: Icon(
                    _getFileIcon(attachment.fileType),
                    color: _getFileColor(attachment.fileType),
                    size: responsive.fontSize18,
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        style: TextStyle(
                          fontSize: responsive.fontSize13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (attachment.fileSize != null)
                        Text(
                          attachment.formattedSize,
                          style: TextStyle(
                            fontSize: responsive.fontSize11,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.download_rounded,
                    color: const Color(0xFF3B82F6),
                    size: responsive.fontSize18,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmissionSection(ResponsiveUtil responsive, AppLocalizations l10n) {
    final submission = assignment.submission!;

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_done_rounded,
                color: const Color(0xFF3B82F6),
                size: responsive.fontSize18,
              ),
              SizedBox(width: responsive.p8),
              Text(
                'Your Submission',
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: responsive.fontSize14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              SizedBox(width: responsive.p6),
              Text(
                'Submitted: ${_formatFullDate(submission.submittedAt)}',
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (submission.attachments.isNotEmpty) ...[
            SizedBox(height: responsive.p8),
            Row(
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  size: responsive.fontSize14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                SizedBox(width: responsive.p6),
                Text(
                  '${submission.attachments.length} file(s) submitted',
                  style: TextStyle(
                    fontSize: responsive.fontSize13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
          if (submission.comments != null) ...[
            SizedBox(height: responsive.p8),
            Text(
              'Your comment: "${submission.comments}"',
              style: TextStyle(
                fontSize: responsive.fontSize13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeSection(ResponsiveUtil responsive, AppLocalizations l10n) {
    final percentage = assignment.gradePercentage ?? 0;
    final gradeColor = percentage >= 80
        ? const Color(0xFF10B981)
        : percentage >= 60
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradeColor.withValues(alpha: 0.15),
            gradeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsive.p56,
                height: responsive.p56,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: responsive.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.p16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grade Received',
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: responsive.p4),
                    Text(
                      '${assignment.grade!.toStringAsFixed(1)} / ${assignment.maxGrade.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: responsive.fontSize20,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                percentage >= 80
                    ? Icons.emoji_events_rounded
                    : percentage >= 60
                        ? Icons.thumb_up_rounded
                        : Icons.trending_up_rounded,
                color: gradeColor,
                size: responsive.fontSize32,
              ),
            ],
          ),
          if (assignment.feedback != null) ...[
            SizedBox(height: responsive.p16),
            Divider(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            SizedBox(height: responsive.p12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.comment_rounded,
                  size: responsive.fontSize16,
                  color: gradeColor,
                ),
                SizedBox(width: responsive.p8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructor Feedback',
                        style: TextStyle(
                          fontSize: responsive.fontSize13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: responsive.p4),
                      Text(
                        assignment.feedback!,
                        style: TextStyle(
                          fontSize: responsive.fontSize13,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    // Show submit button only for pending or overdue assignments
    if (assignment.status == AssignmentStatus.pending ||
        assignment.status == AssignmentStatus.overdue) {
      return SizedBox(
        width: double.infinity,
        height: responsive.p48,
        child: ElevatedButton.icon(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: assignment.isOverdue
                ? const Color(0xFFF59E0B)
                : const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius12),
            ),
          ),
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(
            assignment.isOverdue ? 'Submit Late' : 'Submit Assignment',
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
      case 'py':
      case 'js':
      case 'java':
      case 'cpp':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'doc':
      case 'docx':
        return const Color(0xFF3B82F6);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF10B981);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFF59E0B);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Color(0xFF8B5CF6);
      case 'zip':
      case 'rar':
        return const Color(0xFF6B7280);
      case 'py':
      case 'js':
      case 'java':
      case 'cpp':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatFullDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year} at ${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _getTimeRemaining() {
    if (assignment.isDueToday) {
      final hours = assignment.hoursUntilDue;
      if (hours <= 0) return 'Due now!';
      return '${hours}h left';
    }
    if (assignment.isDueTomorrow) return 'Tomorrow';
    return '${assignment.daysUntilDue}d left';
  }
}
