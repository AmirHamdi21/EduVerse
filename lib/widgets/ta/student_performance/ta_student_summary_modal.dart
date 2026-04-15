import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';
import 'ta_student_card.dart';

class TAStudentSummaryModal extends StatelessWidget {
  final bool isDark;
  final TAStudentPerformance student;
  final VoidCallback? onSendFeedback;
  final VoidCallback? onNotifyInstructor;
  final VoidCallback? onDownloadReport;
  final VoidCallback? onClose;

  const TAStudentSummaryModal({
    super.key,
    required this.isDark,
    required this.student,
    this.onSendFeedback,
    this.onNotifyInstructor,
    this.onDownloadReport,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 20),
                  _buildStudentInfo(),
                  const SizedBox(height: 16),
                  if (student.aiNotes != null) _buildAINotes(l10n),
                  const SizedBox(height: 16),
                  _buildLabPerformanceTrend(l10n),
                  const SizedBox(height: 16),
                  _buildAttendanceHistory(l10n),
                  const SizedBox(height: 20),
                  _buildActionButtons(l10n),
                  const SizedBox(height: 12),
                  _buildDownloadButton(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.taPerformanceSummaryTitle,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.taPerformanceSummarySubtitle,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.close_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TAColors.primary,
                  TAColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.studentId,
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  student.email,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAINotes(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TAColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
            TAColors.warning.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: TAColors.warning),
              const SizedBox(width: 8),
              Text(
                l10n.taPerformanceAINotes,
                style: TextStyle(
                  color: TAColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            student.aiNotes!,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabPerformanceTrend(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 18,
                color: TAColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taPerformanceLabTrend,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...student.labScores.asMap().entries.map((entry) {
            final index = entry.key;
            final score = entry.value;
            return _buildLabScoreItem(label: 'Lab ${index + 1}', score: score);
          }),
        ],
      ),
    );
  }

  Widget _buildLabScoreItem({required String label, required double score}) {
    final color = score >= 85
        ? TAColors.success
        : score >= 70
        ? TAColors.warning
        : TAColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: TAColors.borderColor(isDark),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              '${score.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: TAColors.teal,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taPerformanceAttendanceHistory,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: student.attendanceHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final present = entry.value;
              return _buildAttendanceIcon(
                label: 'Lab ${index + 1}',
                present: present,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceIcon({required String label, required bool present}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: present
                ? TAColors.success.withValues(alpha: isDark ? 0.2 : 0.1)
                : TAColors.error.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: present
                  ? TAColors.success.withValues(alpha: 0.3)
                  : TAColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            present ? Icons.check_rounded : Icons.close_rounded,
            color: present ? TAColors.success : TAColors.error,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSendFeedback,
            icon: Icon(
              Icons.mail_outline_rounded,
              size: 18,
              color: TAColors.primary,
            ),
            label: Text(l10n.taPerformanceSendFeedback),
            style: OutlinedButton.styleFrom(
              foregroundColor: TAColors.textPrimaryColor(isDark),
              side: BorderSide(color: TAColors.borderColor(isDark)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onNotifyInstructor,
            icon: Icon(
              Icons.notifications_outlined,
              size: 18,
              color: TAColors.warning,
            ),
            label: Text(l10n.taPerformanceNotifyInstructor),
            style: OutlinedButton.styleFrom(
              foregroundColor: TAColors.textPrimaryColor(isDark),
              side: BorderSide(color: TAColors.borderColor(isDark)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onDownloadReport,
        icon: const Icon(Icons.download_rounded, size: 18),
        label: Text(l10n.taPerformanceDownloadReport),
        style: ElevatedButton.styleFrom(
          backgroundColor: TAColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
