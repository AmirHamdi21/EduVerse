import 'package:flutter/material.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../models/labs/lab_model.dart';

class LabDetailsSheet extends StatelessWidget {
  final LabModel lab;
  final bool isDark;
  final Function(LabStatus) onStatusChange;
  final Function(String)? onSubmitReport;
  final VoidCallback? onJoinVirtual;

  const LabDetailsSheet({
    super.key,
    required this.lab,
    required this.isDark,
    required this.onStatusChange,
    this.onSubmitReport,
    this.onJoinVirtual,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                  _buildHeader(context, responsive),
                  SizedBox(height: responsive.p16),
                  _buildStatusBadges(responsive),
                  SizedBox(height: responsive.p20),
                  _buildInfoSection(responsive, l10n),
                  if (lab.objectives != null && lab.objectives!.isNotEmpty) ...[
                    SizedBox(height: responsive.p20),
                    _buildObjectives(responsive, l10n),
                  ],
                  if (lab.materials != null && lab.materials!.isNotEmpty) ...[
                    SizedBox(height: responsive.p20),
                    _buildMaterials(responsive, l10n),
                  ],
                  if (lab.status == LabStatus.completed && lab.grade != null) ...[
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

  Widget _buildHeader(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lab icon
        Container(
          width: responsive.p56,
          height: responsive.p56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                lab.type.color,
                lab.type.color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(responsive.radius16),
            boxShadow: [
              BoxShadow(
                color: lab.type.color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            lab.type.icon,
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
                lab.title,
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
                  Text(
                    '${lab.courseName} (${lab.courseCode})',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                    lab.instructorName,
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
    return Row(
      children: [
        _buildBadge(
          lab.status.icon,
          lab.status.label,
          lab.status.color,
          responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildBadge(
          lab.type.icon,
          lab.type.label,
          lab.type.color,
          responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildBadge(
          Icons.access_time_rounded,
          lab.formattedDuration,
          const Color(0xFF6366F1),
          responsive,
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color, ResponsiveUtil responsive) {
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

  Widget _buildInfoSection(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(responsive.radius16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Scheduled',
            _formatFullDate(lab.scheduledDate),
            const Color(0xFF3B82F6),
            responsive,
          ),
          Divider(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            height: responsive.p24,
          ),
          if (lab.location != null)
            _buildInfoRow(
              Icons.location_on_rounded,
              'Location',
              lab.location!,
              const Color(0xFF10B981),
              responsive,
            )
          else if (lab.virtualLink != null)
            _buildInfoRow(
              Icons.videocam_rounded,
              'Virtual Meeting',
              'Online session available',
              const Color(0xFFEC4899),
              responsive,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
    ResponsiveUtil responsive,
  ) {
    return Row(
      children: [
        Container(
          width: responsive.p40,
          height: responsive.p40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius10),
          ),
          child: Icon(icon, color: color, size: responsive.fontSize18),
        ),
        SizedBox(width: responsive.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: responsive.p2),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObjectives(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag_rounded,
              color: const Color(0xFFF59E0B),
              size: responsive.fontSize18,
            ),
            SizedBox(width: responsive.p8),
            Text(
              'Learning Objectives',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        ...lab.objectives!.asMap().entries.map((entry) {
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

  Widget _buildMaterials(ResponsiveUtil responsive, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2_rounded,
              color: const Color(0xFF8B5CF6),
              size: responsive.fontSize18,
            ),
            SizedBox(width: responsive.p8),
            Text(
              'Required Materials',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        Wrap(
          spacing: responsive.p8,
          runSpacing: responsive.p8,
          children: lab.materials!.map((material) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.p12,
                vertical: responsive.p8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(responsive.radius8),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: responsive.fontSize14,
                    color: const Color(0xFF8B5CF6),
                  ),
                  SizedBox(width: responsive.p6),
                  Text(
                    material,
                    style: TextStyle(
                      fontSize: responsive.fontSize13,
                      color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGradeSection(ResponsiveUtil responsive, AppLocalizations l10n) {
    final percentage = lab.gradePercentage ?? 0;
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
            gradeColor.withValues(alpha: 0.1),
            gradeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
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
                  'Lab Grade',
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: responsive.p4),
                Text(
                  '${lab.grade!.toStringAsFixed(1)} / ${lab.maxGrade!.toStringAsFixed(1)}',
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
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ResponsiveUtil responsive,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        if (lab.virtualLink != null && lab.status == LabStatus.inProgress)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onJoinVirtual,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: responsive.p14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
              ),
              icon: const Icon(Icons.videocam_rounded),
              label: const Text('Join Session'),
            ),
          ),
        if (lab.status == LabStatus.completed && lab.reportUrl == null) ...[
          if (lab.virtualLink != null && lab.status == LabStatus.inProgress)
            SizedBox(width: responsive.p12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showSubmitReportDialog(context, responsive),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: responsive.p14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Submit Report'),
            ),
          ),
        ],
        if (lab.status == LabStatus.upcoming) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: EdgeInsets.symmetric(vertical: responsive.p14),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius12),
                ),
              ),
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Set Reminder'),
            ),
          ),
        ],
      ],
    );
  }

  void _showSubmitReportDialog(BuildContext context, ResponsiveUtil responsive) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius16),
        ),
        title: Text(
          'Submit Lab Report',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Report submission will be available soon. You will be able to upload your lab report files.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
}
