import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/assignments/assignment_submission_model.dart';
import '../../../../models/core/drive_file_model.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;
import '../shared/drive_file_preview_screen.dart';
import 'my_submission_view.dart';

class AssignmentDetailBody extends StatelessWidget {
  final AssignmentModel assignment;
  final AssignmentSubmissionModel? mySubmission;
  final bool isDark;
  final bool isSubmitting;
  final double submitProgress;
  final VoidCallback onSubmitPressed;
  final VoidCallback onResubmitPressed;

  const AssignmentDetailBody({
    super.key,
    required this.assignment,
    required this.mySubmission,
    required this.isDark,
    required this.isSubmitting,
    required this.submitProgress,
    required this.onSubmitPressed,
    required this.onResubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: responsive.p16),
          _buildMetaBadges(context),
          SizedBox(height: responsive.p16),
          _buildDueDateCard(context),
          if ((assignment.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: responsive.p16),
            _buildSectionTitle(
              context,
              'Description',
              Icons.description_rounded,
            ),
            SizedBox(height: responsive.p8),
            Text(
              assignment.description!,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: responsive.p16),
          _buildSectionTitle(context, 'Instructions', Icons.menu_book_rounded),
          SizedBox(height: responsive.p8),
          _buildMarkdownInstructions(context),
          SizedBox(height: responsive.p16),
          _buildSectionTitle(
            context,
            'Instruction Files',
            Icons.attach_file_rounded,
          ),
          SizedBox(height: responsive.p8),
          _buildInstructionFiles(context),
          if (mySubmission != null) ...[
            SizedBox(height: responsive.p16),
            MySubmissionView(
              submission: mySubmission!,
              maxScore: assignment.maxGrade,
              isDark: isDark,
              onResubmit:
                  mySubmission!.submissionStatus == api.SubmissionStatus.graded
                  ? onResubmitPressed
                  : null,
            ),
          ],
          SizedBox(height: responsive.p20),
          _buildPrimaryAction(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final responsive = context.responsive;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: responsive.p56,
          height: responsive.p56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(responsive.radius16),
          ),
          child: Icon(
            Icons.assignment_rounded,
            color: Colors.white,
            size: responsive.fontSize28,
          ),
        ),
        SizedBox(width: responsive.p12),
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
              Text(
                '${assignment.courseName} (${assignment.courseCode})',
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaBadges(BuildContext context) {
    final responsive = context.responsive;

    return Wrap(
      spacing: responsive.p8,
      runSpacing: responsive.p8,
      children: [
        _badge(
          context,
          icon: Icons.grade_rounded,
          text: '${assignment.maxGrade.toStringAsFixed(0)} points',
          color: const Color(0xFF8B5CF6),
        ),
        _badge(
          context,
          icon: Icons.upload_file_rounded,
          text: _submissionTypeLabel(assignment.submissionType),
          color: const Color(0xFF3B82F6),
        ),
        _badge(
          context,
          icon: Icons.task_alt_rounded,
          text: _submissionStatusLabel(assignment.submissionFilterStatus),
          color: _submissionStatusColor(assignment.submissionFilterStatus),
        ),
      ],
    );
  }

  Widget _buildDueDateCard(BuildContext context) {
    final responsive = context.responsive;
    final overdue = assignment.submissionFilterStatus == 'overdue';
    final color = overdue ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(responsive.radius14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            overdue
                ? Icons.warning_amber_rounded
                : Icons.calendar_today_rounded,
            color: color,
          ),
          SizedBox(width: responsive.p8),
          Expanded(
            child: Text(
              overdue
                  ? 'Overdue • ${_formatDate(assignment.dueDate)}'
                  : 'Due ${_formatDate(assignment.dueDate)}',
              style: TextStyle(
                fontSize: responsive.fontSize13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownInstructions(BuildContext context) {
    final responsive = context.responsive;
    final content = (assignment.instructionsText ?? '').trim().isNotEmpty
        ? assignment.instructionsText!
        : 'No instructions provided yet.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.35)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(
            fontSize: responsive.fontSize14,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            height: 1.4,
          ),
          strong: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          listBullet: TextStyle(
            fontSize: responsive.fontSize14,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionFiles(BuildContext context) {
    final responsive = context.responsive;
    final files = assignment.instructionFiles;

    if (files == null || files.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.p12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withValues(alpha: 0.25)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(responsive.radius12),
        ),
        child: Text(
          'No instruction files attached.',
          style: TextStyle(
            fontSize: responsive.fontSize13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      );
    }

    return Column(
      children: files
          .map((file) => _DriveActionCard(file: file, isDark: isDark))
          .toList(),
    );
  }

  Widget _buildPrimaryAction(BuildContext context) {
    final responsive = context.responsive;
    final isClosed = assignment.apiStatus == api.AssignmentStatus.closed;
    final canSubmit = !isClosed && (mySubmission == null);

    if (!canSubmit) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: responsive.p48,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onSubmitPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
        ),
        icon: isSubmitting
            ? SizedBox(
                width: responsive.p16,
                height: responsive.p16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                  value: submitProgress > 0 ? submitProgress : null,
                ),
              )
            : const Icon(Icons.upload_rounded),
        label: Text(
          isSubmitting ? 'Submitting...' : 'Submit Assignment',
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final responsive = context.responsive;
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: responsive.fontSize18),
        SizedBox(width: responsive.p6),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _badge(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final responsive = context.responsive;
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
          Icon(icon, size: responsive.fontSize13, color: color),
          SizedBox(width: responsive.p4),
          Text(
            text,
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

  String _submissionTypeLabel(api.SubmissionType type) {
    switch (type) {
      case api.SubmissionType.file:
        return 'File submission';
      case api.SubmissionType.text:
        return 'Text submission';
      case api.SubmissionType.link:
        return 'Link submission';
      case api.SubmissionType.multiple:
        return 'Any submission';
      case api.SubmissionType.unknown:
        return 'Mixed submission';
    }
  }

  String _submissionStatusLabel(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Pending';
    }
  }

  Color _submissionStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return const Color(0xFF3B82F6);
      case 'overdue':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatDate(DateTime value) {
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${hour == 0 ? 12 : hour}:${value.minute.toString().padLeft(2, '0')} $suffix';
  }
}

class _DriveActionCard extends StatelessWidget {
  final DriveFileModel file;
  final bool isDark;

  const _DriveActionCard({required this.file, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.35)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Color(0xFF3B82F6)),
              SizedBox(width: responsive.p8),
              Expanded(
                child: Text(
                  file.fileName,
                  style: TextStyle(
                    fontSize: responsive.fontSize13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p10),
          Wrap(
            spacing: responsive.p8,
            runSpacing: responsive.p8,
            children: [
              TextButton.icon(
                onPressed: () => _openExternal(file.webViewLink),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open in Drive'),
              ),
              TextButton.icon(
                onPressed: file.downloadUrl.isEmpty
                    ? null
                    : () => _openExternal(file.downloadUrl),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () => openDriveFilePreviewScreen(
                  context,
                  file: file,
                  isDark: isDark,
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Preview'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openExternal(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
