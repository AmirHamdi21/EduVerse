import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/assignments/assignment_submission_model.dart';
import '../../models/labs/lab_submission_model.dart';
import '../../models/core/drive_file_model.dart';
import '../../widgets/ta/shared/ta_colors.dart';
import 'file_preview_screen.dart';

/// Reusable submission detail viewer bottom sheet.
/// Shows submission details (text, link, file) with preview and grade options.
class SubmissionDetailViewer extends StatelessWidget {
  final String studentName;
  final String title;
  final DateTime submittedAt;
  final bool isLate;
  final String? submissionText;
  final String? submissionLink;
  final DriveFileModel? driveFile;
  final VoidCallback? onPreviewFile;
  final VoidCallback? onDownloadFile;
  final VoidCallback? onGrade;
  final bool isAssignment;

  const SubmissionDetailViewer({
    super.key,
    required this.studentName,
    required this.title,
    required this.submittedAt,
    required this.isLate,
    this.submissionText,
    this.submissionLink,
    this.driveFile,
    this.onPreviewFile,
    this.onDownloadFile,
    this.onGrade,
    this.isAssignment = true,
  });

  /// Show assignment submission detail viewer
  static Future<void> showAssignment({
    required BuildContext context,
    required AssignmentSubmissionModel submission,
    required String studentName,
    required String assignmentTitle,
    required double maxGrade,
    required Function(double grade, String? feedback) onGrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubmissionDetailViewer(
        studentName: studentName,
        title: assignmentTitle,
        submittedAt: submission.submittedAt,
        isLate: submission.isLate,
        submissionText: submission.submissionText,
        submissionLink: submission.submissionLink,
        driveFile: submission.driveFile,
        onGrade: () => _showGradeDialog(
          context,
          maxGrade: maxGrade,
          initialScore: submission.score,
          initialFeedback: submission.feedback,
          onGrade: onGrade,
        ),
        isAssignment: true,
      ),
    );
  }

  /// Show lab submission detail viewer
  static Future<void> showLab({
    required BuildContext context,
    required LabSubmissionModel submission,
    required String studentName,
    required String labTitle,
    required double maxScore,
    required Function(double grade, String? feedback) onGrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubmissionDetailViewer(
        studentName: studentName,
        title: labTitle,
        submittedAt: submission.submittedAt,
        isLate: submission.isLate,
        submissionText: submission.submissionText,
        driveFile: submission.driveFile,
        onGrade: () => _showGradeDialog(
          context,
          maxGrade: maxScore,
          initialScore: submission.score,
          initialFeedback: submission.feedback,
          onGrade: onGrade,
        ),
        isAssignment: false,
      ),
    );
  }

  static void _showGradeDialog(
    BuildContext context, {
    required double maxGrade,
    double? initialScore,
    String? initialFeedback,
    required Function(double grade, String? feedback) onGrade,
  }) {
    Navigator.of(context).pop(); // Close submission viewer

    // Import and show grade dialog - will be handled by caller
    // This is a placeholder - actual implementation depends on grading widget
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TAColors.borderColor(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TAColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: TAColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TAColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LATE',
                          style: TextStyle(
                            color: TAColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submitted: ${_formatDate(submittedAt)}',
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                // Submission text
                if (submissionText != null && submissionText!.isNotEmpty) ...[
                  _buildSection(
                    isDark,
                    'Submission Text',
                    Icons.notes_outlined,
                    Text(
                      submissionText!,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Submission link
                if (submissionLink != null && submissionLink!.isNotEmpty) ...[
                  _buildSection(
                    isDark,
                    'Submission Link',
                    Icons.link_outlined,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            submissionLink!,
                            style: TextStyle(
                              color: TAColors.primary,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          onPressed: () => _copyToClipboard(submissionLink!),
                          tooltip: 'Copy link',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Submitted file
                if (driveFile != null) ...[
                  _buildSection(
                    isDark,
                    'Submitted File',
                    Icons.attach_file_outlined,
                    _buildFileCard(context, isDark, driveFile!),
                  ),
                  const SizedBox(height: 16),
                ],

                // Empty state
                if (submissionText == null &&
                    submissionLink == null &&
                    driveFile == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: TAColors.textTertiaryColor(isDark),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No submission content',
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Grade button
          if (onGrade != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onGrade,
                  icon: const Icon(Icons.grading_rounded),
                  label: const Text('Grade Submission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TAColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    bool isDark,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: TAColors.textSecondaryColor(isDark)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TAColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: TAColors.borderColor(isDark),
              width: 1,
            ),
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildFileCard(BuildContext context, bool isDark, DriveFileModel file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(file.fileName),
                color: TAColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                file.fileName,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previewFile(context, file),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TAColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _downloadFile(context, file),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Download'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TAColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_outlined;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} $hour:${date.minute.toString().padLeft(2, '0')} $suffix';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _previewFile(BuildContext context, DriveFileModel file) {
    if (file.iframeUrl.isEmpty) {
      return;
    }
    
    // Close submission viewer first
    Navigator.of(context, rootNavigator: true).pop();
    
    // Open file preview screen
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => FilePreviewScreen(
          fileName: file.fileName,
          previewUrl: file.iframeUrl,
          downloadUrl: file.downloadUrl,
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context, DriveFileModel file) async {
    if (file.downloadUrl.isEmpty) {
      return;
    }
    
    final url = Uri.parse(file.downloadUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
