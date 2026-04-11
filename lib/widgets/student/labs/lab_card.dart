import 'package:flutter/material.dart';

import '../../../../models/labs/lab_model.dart';
import '../../../../models/core/enums/lab_enums.dart' as api;
import '../../../../common/utils/responsive.dart';

class LabCard extends StatelessWidget {
  final LabModel lab;
  final bool isDark;
  final VoidCallback onTap;

  const LabCard({
    super.key,
    required this.lab,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return _buildCardContent(context, responsive);
  }

  Widget _buildCardContent(BuildContext context, ResponsiveUtil responsive) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.p16,
        vertical: responsive.p8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: _statusColor(lab.status).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : _statusColor(lab.status))
                .withValues(alpha: 0.1),
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
                if (lab.description != null) ...[
                  SizedBox(height: responsive.p8),
                  _buildDescription(responsive),
                ],
                SizedBox(height: responsive.p12),
                _buildInfoRow(context, responsive),
                SizedBox(height: responsive.p12),
                _buildFooter(context, responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p10,
            vertical: responsive.p4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.science_rounded,
                size: responsive.fontSize12,
                color: const Color(0xFF6366F1),
              ),
              SizedBox(width: responsive.p4),
              Text(
                lab.labNumber == null ? 'Lab' : 'Lab ${lab.labNumber}',
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6366F1),
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
            color: _statusColor(lab.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _statusIcon(lab.status),
                size: responsive.fontSize12,
                color: _statusColor(lab.status),
              ),
              SizedBox(width: responsive.p4),
              Text(
                _statusLabel(lab.status),
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(lab.status),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ResponsiveUtil responsive) {
    return Text(
      lab.title,
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
      lab.description!,
      style: TextStyle(
        fontSize: responsive.fontSize13,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoRow(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        _buildInfoChip(
          Icons.school_rounded,
          lab.course?.code ?? 'N/A',
          const Color(0xFF3B82F6),
          responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildInfoChip(
          Icons.grade_rounded,
          '${lab.maxScore.toStringAsFixed(0)} pts',
          const Color(0xFF8B5CF6),
          responsive,
        ),
        if (lab.instructionFiles.isNotEmpty) ...[
          SizedBox(width: responsive.p8),
          _buildInfoChip(
            Icons.attach_file_rounded,
            '${lab.instructionFiles.length}',
            const Color(0xFF10B981),
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
    ResponsiveUtil responsive, {
    bool expanded = false,
  }) {
    final content = Container(
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
          expanded
              ? Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: responsive.fontSize11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(
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

    return expanded ? Flexible(child: content) : content;
  }

  Widget _buildFooter(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        // Date and time
        Icon(
          Icons.calendar_today_rounded,
          size: responsive.fontSize14,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        SizedBox(width: responsive.p6),
        Text(
          lab.formattedDueDate,
          style: TextStyle(
            fontSize: responsive.fontSize12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (lab.status == api.LabStatus.published)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: _dueColor(lab).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: responsive.fontSize12,
                  color: _dueColor(lab),
                ),
                SizedBox(width: responsive.p4),
                Text(
                  _dueText(lab),
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.bold,
                    color: _dueColor(lab),
                  ),
                ),
              ],
            ),
          )
        else if (lab.status == api.LabStatus.archived)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Text(
              'Archived',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
      ],
    );
  }

  String _statusLabel(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return 'Active';
      case api.LabStatus.closed:
        return 'Closed';
      case api.LabStatus.archived:
        return 'Archived';
      case api.LabStatus.draft:
        return 'Draft';
      case api.LabStatus.unknown:
        return 'Unknown';
    }
  }

  IconData _statusIcon(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return Icons.play_circle_rounded;
      case api.LabStatus.closed:
        return Icons.check_circle_rounded;
      case api.LabStatus.archived:
        return Icons.archive_rounded;
      case api.LabStatus.draft:
        return Icons.edit_note_rounded;
      case api.LabStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color _statusColor(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return const Color(0xFF10B981);
      case api.LabStatus.closed:
        return const Color(0xFF64748B);
      case api.LabStatus.archived:
        return const Color(0xFF475569);
      case api.LabStatus.draft:
        return const Color(0xFFF59E0B);
      case api.LabStatus.unknown:
        return const Color(0xFF94A3B8);
    }
  }

  Color _dueColor(LabModel lab) {
    final days = lab.daysUntilDue;
    if (days == null) {
      return const Color(0xFF64748B);
    }
    if (days < 0) {
      return const Color(0xFFEF4444);
    }
    if (days <= 2) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }

  String _dueText(LabModel lab) {
    final days = lab.daysUntilDue;
    if (days == null) {
      return 'No deadline';
    }
    if (days < 0) {
      return 'Late';
    }
    if (days == 0) {
      return 'Due today';
    }
    if (days == 1) {
      return 'Due tomorrow';
    }
    return 'In $days days';
  }
}
