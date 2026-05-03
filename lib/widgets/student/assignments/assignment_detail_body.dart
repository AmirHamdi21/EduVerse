import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/assignments/assignment_submission_model.dart';
import '../../../../models/core/drive_file_model.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;
import '../shared/drive_file_preview_screen.dart';

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
    final l10n = AppLocalizations.of(context);
    final canSubmit = _canSubmit();
    final showResubmit =
        mySubmission?.submissionStatus == api.SubmissionStatus.graded;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        responsive.p16,
        responsive.p8,
        responsive.p16,
        responsive.p24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHero(context, l10n, responsive),
          SizedBox(height: responsive.p16),
          _buildSnapshotGrid(context, l10n, responsive),
          SizedBox(height: responsive.p16),
          _buildOverviewSection(context, l10n, responsive),
          if ((assignment.description ?? '').trim().isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p16),
            _buildContentCard(
              context,
              title: l10n.description,
              icon: Icons.notes_rounded,
              child: Text(
                assignment.description!,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: _StudentAssignmentDetailColors.textSecondary(isDark),
                  height: 1.55,
                ),
              ),
            ),
          ],
          SizedBox(height: responsive.p16),
          _buildContentCard(
            context,
            title: l10n.instructions,
            icon: Icons.menu_book_rounded,
            child: _buildInstructions(context),
          ),
          SizedBox(height: responsive.p16),
          _buildContentCard(
            context,
            title: l10n.attachments,
            icon: Icons.attach_file_rounded,
            child: _buildInstructionFiles(context, l10n),
          ),
          if (mySubmission != null) ...<Widget>[
            SizedBox(height: responsive.p16),
            _buildMySubmissionCard(context, l10n, responsive),
          ],
          if (canSubmit || showResubmit) ...<Widget>[
            SizedBox(height: responsive.p20),
            _buildActionCard(
              context,
              l10n,
              responsive,
              showResubmit: showResubmit,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: <Color>[
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                  Color(0xFF0EA5E9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: <Color>[
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.28 : 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -34,
              right: -4,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -18,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.p18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: responsive.p8,
                    runSpacing: responsive.p8,
                    children: <Widget>[
                      _buildHeroChip(
                        icon: Icons.menu_book_rounded,
                        label: assignment.courseCode,
                      ),
                      _buildHeroChip(
                        icon: Icons.schedule_rounded,
                        label: _statusLabel(l10n),
                      ),
                      _buildHeroChip(
                        icon: Icons.stars_rounded,
                        label: '${_formatScore(assignment.maxGrade)} pts',
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p14),
                  Text(
                    assignment.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isMobile
                          ? responsive.fontSize24
                          : responsive.fontSize28,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  SizedBox(height: responsive.p6),
                  Text(
                    '${assignment.courseName} • ${assignment.instructorName.isEmpty ? "Course team" : assignment.instructorName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: responsive.fontSize14,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: responsive.p16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.p14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: responsive.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                assignment.submissionFilterStatus == 'overdue'
                                    ? 'Deadline passed'
                                    : 'Next deadline',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.76),
                                  fontSize: responsive.fontSize12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: responsive.p4),
                              Text(
                                _formatDate(assignment.dueDate),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p12,
                            vertical: responsive.p8,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusLabel(l10n),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.fontSize12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotGrid(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final cards = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.stars_rounded,
        label: 'Max score',
        value: _formatScore(assignment.maxGrade),
        color: _StudentAssignmentDetailColors.primary,
      ),
      (
        icon: Icons.upload_rounded,
        label: 'Submission',
        value: _submissionTypeLabel(),
        color: _StudentAssignmentDetailColors.accent,
      ),
      (
        icon: Icons.event_available_rounded,
        label: l10n.status,
        value: _statusLabel(l10n),
        color: _statusColor(),
      ),
      (
        icon: Icons.schedule_send_rounded,
        label: 'Late policy',
        value: assignment.lateSubmissionAllowed
            ? '${assignment.latePenaltyPercent.toStringAsFixed(0)}% penalty'
            : 'Not allowed',
        color: assignment.lateSubmissionAllowed
            ? _StudentAssignmentDetailColors.warning
            : _StudentAssignmentDetailColors.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final spacing = responsive.p10;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: EdgeInsets.all(responsive.p14),
                decoration: BoxDecoration(
                  color: _StudentAssignmentDetailColors.card(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _StudentAssignmentDetailColors.border(
                      isDark,
                    ).withValues(alpha: 0.7),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: card.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(card.icon, color: card.color, size: 20),
                    ),
                    SizedBox(height: responsive.p12),
                    Text(
                      card.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: responsive.fontSize16,
                        fontWeight: FontWeight.w800,
                        color: _StudentAssignmentDetailColors.textPrimary(isDark),
                      ),
                    ),
                    SizedBox(height: responsive.p4),
                    Text(
                      card.label,
                      style: TextStyle(
                        fontSize: responsive.fontSize12,
                        fontWeight: FontWeight.w600,
                        color: _StudentAssignmentDetailColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final rows = <({IconData icon, String label, String value})>[
      (
        icon: Icons.school_rounded,
        label: l10n.course,
        value: '${assignment.courseName} (${assignment.courseCode})',
      ),
      (
        icon: Icons.person_outline_rounded,
        label: 'Instructor',
        value: assignment.instructorName.isEmpty
            ? 'Course team'
            : assignment.instructorName,
      ),
      (
        icon: Icons.calendar_today_rounded,
        label: l10n.dueDate,
        value: _formatDate(assignment.dueDate),
      ),
      (
        icon: Icons.timer_outlined,
        label: 'Available from',
        value: assignment.availableFrom == null
            ? 'Immediately'
            : _formatDate(assignment.availableFrom!),
      ),
    ];

    return _buildContentCard(
      context,
      title: 'Assignment snapshot',
      icon: Icons.dashboard_customize_rounded,
      child: Column(
        children: rows.map((row) {
          final isLast = identical(row, rows.last);
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : responsive.p12),
            child: Container(
              padding: EdgeInsets.all(responsive.p12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _StudentAssignmentDetailColors.border(
                    isDark,
                  ).withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _StudentAssignmentDetailColors.primary.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      row.icon,
                      color: _StudentAssignmentDetailColors.primary,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: responsive.p10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          row.label,
                          style: TextStyle(
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w700,
                            color: _StudentAssignmentDetailColors.textSecondary(
                              isDark,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.p4),
                        Text(
                          row.value,
                          style: TextStyle(
                            fontSize: responsive.fontSize14,
                            fontWeight: FontWeight.w700,
                            color: _StudentAssignmentDetailColors.textPrimary(
                              isDark,
                            ),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: _StudentAssignmentDetailColors.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _StudentAssignmentDetailColors.border(
            isDark,
          ).withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _StudentAssignmentDetailColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: _StudentAssignmentDetailColors.primary,
                ),
              ),
              SizedBox(width: responsive.p10),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.w800,
                  color: _StudentAssignmentDetailColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p14),
          child,
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final responsive = context.responsive;
    final content = (assignment.instructionsText ?? '').trim().isNotEmpty
        ? assignment.instructionsText!
        : 'No instructions were attached yet.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _StudentAssignmentDetailColors.border(
            isDark,
          ).withValues(alpha: 0.55),
        ),
      ),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(
            fontSize: responsive.fontSize14,
            color: _StudentAssignmentDetailColors.textSecondary(isDark),
            height: 1.55,
          ),
          strong: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w800,
            color: _StudentAssignmentDetailColors.textPrimary(isDark),
          ),
          listBullet: TextStyle(
            fontSize: responsive.fontSize14,
            color: _StudentAssignmentDetailColors.textSecondary(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionFiles(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final files = assignment.instructionFiles ?? const <DriveFileModel>[];
    if (files.isEmpty) {
      return _buildEmptyInfoCard(context, 'No supporting files were uploaded.');
    }

    return Column(
      children: files.map<Widget>((file) {
        return _buildDriveFileCard(
          context,
          file: file,
          title: file.fileName,
          subtitle: 'Instruction file',
          previewLabel: l10n.preview,
          openInDriveLabel: 'Open in Drive',
          downloadLabel: l10n.download,
        );
      }).toList(growable: false),
    );
  }

  Widget _buildMySubmissionCard(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final submission = mySubmission!;
    final score = submission.score;
    final percentage = score == null || assignment.maxGrade <= 0
        ? null
        : (score / assignment.maxGrade * 100).clamp(0, 100);

    return _buildContentCard(
      context,
      title: 'My submission',
      icon: Icons.cloud_done_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: responsive.p8,
            runSpacing: responsive.p8,
            children: <Widget>[
              _buildInfoPill(
                context,
                icon: Icons.event_rounded,
                text: '${l10n.submitted} ${_formatDate(submission.submittedAt)}',
              ),
              _buildInfoPill(
                context,
                icon: Icons.flag_rounded,
                text: submission.isLate ? l10n.late : _statusLabel(l10n),
                color: submission.isLate
                    ? _StudentAssignmentDetailColors.error
                    : _StudentAssignmentDetailColors.success,
              ),
              _buildInfoPill(
                context,
                icon: Icons.repeat_rounded,
                text: 'Attempt ${submission.attemptNumber}',
              ),
            ],
          ),
          SizedBox(height: responsive.p14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.p14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  _StudentAssignmentDetailColors.success.withValues(alpha: 0.16),
                  _StudentAssignmentDetailColors.info.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _StudentAssignmentDetailColors.success.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _StudentAssignmentDetailColors.success,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    score == null ? '--' : score.toStringAsFixed(score % 1 == 0 ? 0 : 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        score == null
                            ? 'Waiting for grading'
                            : '${_formatScore(score)} / ${_formatScore(assignment.maxGrade)}',
                        style: TextStyle(
                          fontSize: responsive.fontSize20,
                          fontWeight: FontWeight.w800,
                          color: _StudentAssignmentDetailColors.textPrimary(
                            isDark,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.p4),
                      Text(
                        score == null
                            ? 'Your work has been submitted successfully.'
                            : '${percentage!.toStringAsFixed(0)}% overall score',
                        style: TextStyle(
                          fontSize: responsive.fontSize13,
                          color: _StudentAssignmentDetailColors.textSecondary(
                            isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if ((submission.submissionText ?? '').trim().isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p14),
            _buildInlinePanel(
              context,
              title: 'Submission note',
              icon: Icons.edit_note_rounded,
              child: Text(
                submission.submissionText!,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  color: _StudentAssignmentDetailColors.textSecondary(isDark),
                  height: 1.5,
                ),
              ),
            ),
          ],
          if ((submission.submissionLink ?? '').trim().isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p14),
            _buildInlinePanel(
              context,
              title: 'Submission link',
              icon: Icons.link_rounded,
              child: InkWell(
                onTap: () => _openExternal(submission.submissionLink!),
                child: Text(
                  submission.submissionLink!,
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    color: _StudentAssignmentDetailColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
          if (_resolveSubmissionFiles(submission).isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p14),
            ..._resolveSubmissionFiles(submission).map<Widget>((file) {
              return _buildDriveFileCard(
                context,
                file: file,
                title: file.fileName,
                subtitle: 'Uploaded file',
                previewLabel: l10n.preview,
                openInDriveLabel: 'Open in Drive',
                downloadLabel: l10n.download,
              );
            }),
          ],
          if ((submission.feedback ?? '').trim().isNotEmpty) ...<Widget>[
            SizedBox(height: responsive.p14),
            _buildInlinePanel(
              context,
              title: l10n.feedback,
              icon: Icons.forum_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    submission.feedback!,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: _StudentAssignmentDetailColors.textSecondary(
                        isDark,
                      ),
                      height: 1.5,
                    ),
                  ),
                  if (submission.gradedAt != null) ...<Widget>[
                    SizedBox(height: responsive.p8),
                    Text(
                      'Reviewed ${_formatDate(submission.gradedAt!)}',
                      style: TextStyle(
                        fontSize: responsive.fontSize12,
                        fontWeight: FontWeight.w600,
                        color: _StudentAssignmentDetailColors.textSecondary(
                          isDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    AppLocalizations l10n,
    ResponsiveUtil responsive, {
    required bool showResubmit,
  }) {
    final canSubmit = _canSubmit();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: _StudentAssignmentDetailColors.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _StudentAssignmentDetailColors.border(
            isDark,
          ).withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            showResubmit ? 'Improve your submission' : 'Ready when you are',
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w800,
              color: _StudentAssignmentDetailColors.textPrimary(isDark),
            ),
          ),
          SizedBox(height: responsive.p6),
          Text(
            showResubmit
                ? 'You can upload an updated version after reviewing the feedback.'
                : 'Use the submission sheet to upload a file, share a link, or send written work.',
            style: TextStyle(
              fontSize: responsive.fontSize14,
              color: _StudentAssignmentDetailColors.textSecondary(isDark),
              height: 1.5,
            ),
          ),
          SizedBox(height: responsive.p16),
          if (isSubmitting)
            Padding(
              padding: EdgeInsets.only(bottom: responsive.p12),
              child: LinearProgressIndicator(
                value: submitProgress > 0 ? submitProgress.clamp(0, 1) : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
                color: _StudentAssignmentDetailColors.primary,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: responsive.p56,
            child: ElevatedButton.icon(
              onPressed: (!canSubmit && !showResubmit) || isSubmitting
                  ? null
                  : (showResubmit ? onResubmitPressed : onSubmitPressed),
              style: ElevatedButton.styleFrom(
                backgroundColor: _StudentAssignmentDetailColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: isSubmitting
                  ? SizedBox(
                      width: responsive.p18,
                      height: responsive.p18,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      showResubmit
                          ? Icons.replay_rounded
                          : Icons.upload_rounded,
                    ),
              label: Text(
                isSubmitting
                    ? 'Submitting...'
                    : (showResubmit ? 'Resubmit Assignment' : 'Submit Assignment'),
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveFileCard(
    BuildContext context, {
    required DriveFileModel file,
    required String title,
    required String subtitle,
    required String previewLabel,
    required String openInDriveLabel,
    required String downloadLabel,
  }) {
    final responsive = context.responsive;
    final canPreview = file.driveId.isNotEmpty;
    final canOpenInDrive = file.webViewLink.isNotEmpty;
    final canDownload = file.downloadUrl.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.p10),
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _StudentAssignmentDetailColors.border(
            isDark,
          ).withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _StudentAssignmentDetailColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: _StudentAssignmentDetailColors.primary,
                ),
              ),
              SizedBox(width: responsive.p10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        fontWeight: FontWeight.w800,
                        color: _StudentAssignmentDetailColors.textPrimary(
                          isDark,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.p2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: responsive.fontSize12,
                        color: _StudentAssignmentDetailColors.textSecondary(
                          isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 460;

              final previewButton = OutlinedButton.icon(
                onPressed: !canPreview
                    ? null
                    : () => openDriveFilePreviewScreen(
                        context,
                        file: file,
                        isDark: isDark,
                      ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _StudentAssignmentDetailColors.primary,
                  side: BorderSide(
                    color: _StudentAssignmentDetailColors.primary.withValues(
                      alpha: 0.32,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: Text(previewLabel),
              );

              final openInDriveButton = OutlinedButton.icon(
                onPressed: !canOpenInDrive
                    ? null
                    : () => _openExternal(file.webViewLink),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _StudentAssignmentDetailColors.accent,
                  side: BorderSide(
                    color: _StudentAssignmentDetailColors.accent.withValues(
                      alpha: 0.28,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(openInDriveLabel),
              );

              final downloadButton = FilledButton.icon(
                onPressed: !canDownload
                    ? null
                    : () => _openExternal(file.downloadUrl),
                style: FilledButton.styleFrom(
                  backgroundColor: _StudentAssignmentDetailColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.download_rounded),
                label: Text(downloadLabel),
              );

              if (isCompact) {
                return Column(
                  children: <Widget>[
                    SizedBox(width: double.infinity, child: previewButton),
                    SizedBox(height: responsive.p8),
                    SizedBox(width: double.infinity, child: openInDriveButton),
                    SizedBox(height: responsive.p8),
                    SizedBox(width: double.infinity, child: downloadButton),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: previewButton),
                  SizedBox(width: responsive.p8),
                  Expanded(child: openInDriveButton),
                  SizedBox(width: responsive.p8),
                  Expanded(child: downloadButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<DriveFileModel> _resolveSubmissionFiles(
    AssignmentSubmissionModel submission,
  ) {
    if (submission.driveFile != null) {
      return <DriveFileModel>[submission.driveFile!];
    }

    final attachments = assignment.submission?.attachments ?? const <AssignmentAttachment>[];
    if (attachments.isEmpty) {
      return const <DriveFileModel>[];
    }

    return attachments.map(_attachmentToDriveFile).toList(growable: false);
  }

  DriveFileModel _attachmentToDriveFile(AssignmentAttachment attachment) {
    final driveId = _extractDriveId(attachment.url);
    final downloadUrl = attachment.url;
    final webViewLink = driveId.isNotEmpty
        ? 'https://drive.google.com/file/d/$driveId/view'
        : attachment.url;

    return DriveFileModel(
      driveFileId: int.tryParse(attachment.id) ?? 0,
      driveId: driveId,
      fileName: attachment.name,
      webViewLink: webViewLink,
      downloadUrl: downloadUrl,
      iframeUrl: driveId.isNotEmpty
          ? 'https://drive.google.com/file/d/$driveId/preview'
          : '',
    );
  }

  String _extractDriveId(String value) {
    final fileMatch = RegExp(r'/file/d/([^/]+)').firstMatch(value);
    if (fileMatch != null) {
      return fileMatch.group(1) ?? '';
    }

    final uri = Uri.tryParse(value);
    if (uri != null) {
      final id = uri.queryParameters['id'];
      if (id != null && id.isNotEmpty) {
        return id;
      }
    }

    return '';
  }

  Widget _buildInlinePanel(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _StudentAssignmentDetailColors.border(
            isDark,
          ).withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: _StudentAssignmentDetailColors.primary,
              ),
              SizedBox(width: responsive.p8),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w800,
                  color: _StudentAssignmentDetailColors.textPrimary(isDark),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final responsive = context.responsive;
    final resolvedColor = color ?? _StudentAssignmentDetailColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p10,
        vertical: responsive.p6,
      ),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: resolvedColor),
          SizedBox(width: responsive.p6),
          Text(
            text,
            style: TextStyle(
              color: resolvedColor,
              fontSize: responsive.fontSize12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInfoCard(BuildContext context, String text) {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _StudentAssignmentDetailColors.border(
            isDark,
          ).withValues(alpha: 0.55),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: responsive.fontSize13,
          color: _StudentAssignmentDetailColors.textSecondary(isDark),
        ),
      ),
    );
  }

  bool _canSubmit() {
    final isClosed = assignment.apiStatus == api.AssignmentStatus.closed;
    return !isClosed && mySubmission == null;
  }

  String _submissionTypeLabel() {
    switch (assignment.submissionType) {
      case api.SubmissionType.file:
        return 'File upload';
      case api.SubmissionType.text:
        return 'Written answer';
      case api.SubmissionType.link:
        return 'Link share';
      case api.SubmissionType.multiple:
        return 'Mixed options';
      case api.SubmissionType.unknown:
        return 'Flexible';
    }
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return l10n.submitted;
      case 'overdue':
        return l10n.overdue;
      default:
        return l10n.pending;
    }
  }

  Color _statusColor() {
    switch (assignment.submissionFilterStatus) {
      case 'submitted':
        return _StudentAssignmentDetailColors.success;
      case 'overdue':
        return _StudentAssignmentDetailColors.error;
      default:
        return _StudentAssignmentDetailColors.warning;
    }
  }

  String _formatDate(DateTime value) {
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${hour == 0 ? 12 : hour}:${value.minute.toString().padLeft(2, '0')} $suffix';
  }

  String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  Future<void> _openExternal(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class AssignmentDetailLoadingView extends StatelessWidget {
  const AssignmentDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    Widget block({double? height, double? width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: responsive.isMobile ? 240 : 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: EdgeInsets.all(responsive.p18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  block(height: 32, width: 160),
                  SizedBox(height: responsive.p12),
                  block(height: 20, width: double.infinity),
                  SizedBox(height: responsive.p10),
                  block(height: 20, width: responsive.screenWidth * 0.55),
                  const Spacer(),
                  block(height: 78, width: double.infinity),
                ],
              ),
            ),
          ),
          SizedBox(height: responsive.p16),
          Wrap(
            spacing: responsive.p10,
            runSpacing: responsive.p10,
            children: List<Widget>.generate(4, (_) {
              return Container(
                width: (responsive.screenWidth - (responsive.p16 * 2) - responsive.p10) / 2,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: EdgeInsets.all(responsive.p14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    block(height: 40, width: 40),
                    SizedBox(height: responsive.p12),
                    block(height: 18, width: 90),
                    SizedBox(height: responsive.p6),
                    block(height: 12, width: 60),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: responsive.p16),
          ...List<Widget>.generate(3, (_) {
            return Container(
              margin: EdgeInsets.only(bottom: responsive.p16),
              padding: EdgeInsets.all(responsive.p16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  block(height: 20, width: 180),
                  SizedBox(height: responsive.p16),
                  block(height: 16, width: double.infinity),
                  SizedBox(height: responsive.p10),
                  block(height: 16, width: double.infinity),
                  SizedBox(height: responsive.p10),
                  block(height: 16, width: responsive.screenWidth * 0.5),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StudentAssignmentDetailColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static Color card(bool isDark) {
    return isDark ? const Color(0xFF111827) : Colors.white;
  }

  static Color border(bool isDark) {
    return isDark ? const Color(0xFF334155) : const Color(0xFFD9E2F0);
  }

  static Color textPrimary(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF0F172A);
  }

  static Color textSecondary(bool isDark) {
    return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  }
}
