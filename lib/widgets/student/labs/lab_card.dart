import 'package:flutter/material.dart';
import '../../../../models/labs/lab_model.dart';
import '../../../../common/utils/responsive.dart';

class LabCard extends StatelessWidget {
  final LabModel lab;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final Animation<double>? animation;

  const LabCard({
    super.key,
    required this.lab,
    required this.isDark,
    required this.onTap,
    this.onBookmark,
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
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: lab.status.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : lab.status.color).withValues(alpha: 0.1),
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
        // Lab type badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p10,
            vertical: responsive.p4,
          ),
          decoration: BoxDecoration(
            color: lab.type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                lab.type.icon,
                size: responsive.fontSize12,
                color: lab.type.color,
              ),
              SizedBox(width: responsive.p4),
              Text(
                lab.type.label,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: lab.type.color,
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
            color: lab.status.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                lab.status.icon,
                size: responsive.fontSize12,
                color: lab.status.color,
              ),
              SizedBox(width: responsive.p4),
              Text(
                lab.status.label,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: lab.status.color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: responsive.p8),
        // Bookmark button
        if (onBookmark != null)
          GestureDetector(
            onTap: onBookmark,
            child: Icon(
              lab.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: lab.isBookmarked
                  ? const Color(0xFFF59E0B)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: responsive.fontSize20,
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
          lab.courseCode,
          const Color(0xFF3B82F6),
          responsive,
        ),
        SizedBox(width: responsive.p8),
        _buildInfoChip(
          Icons.access_time_rounded,
          lab.formattedDuration,
          const Color(0xFF8B5CF6),
          responsive,
        ),
        if (lab.location != null) ...[
          SizedBox(width: responsive.p8),
          Expanded(
            child: _buildInfoChip(
              Icons.location_on_rounded,
              lab.location!,
              const Color(0xFF10B981),
              responsive,
              expanded: true,
            ),
          ),
        ] else if (lab.virtualLink != null) ...[
          SizedBox(width: responsive.p8),
          _buildInfoChip(
            Icons.videocam_rounded,
            'Online',
            const Color(0xFFEC4899),
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
          _formatDate(lab.scheduledDate),
          style: TextStyle(
            fontSize: responsive.fontSize12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        // Grade if completed
        if (lab.status == LabStatus.completed && lab.grade != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981),
                  const Color(0xFF059669),
                ],
              ),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.grade_rounded,
                  size: responsive.fontSize12,
                  color: Colors.white,
                ),
                SizedBox(width: responsive.p4),
                Text(
                  '${lab.grade!.toStringAsFixed(0)}/${lab.maxGrade!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        // Days indicator for upcoming
        else if (lab.status == LabStatus.upcoming)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.p10,
              vertical: responsive.p4,
            ),
            decoration: BoxDecoration(
              color: _getDaysColor(lab.daysUntil).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(responsive.radius8),
            ),
            child: Text(
              lab.isToday ? 'Today' : _getDaysText(lab.daysUntil),
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.bold,
                color: _getDaysColor(lab.daysUntil),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getDaysColor(int days) {
    if (days <= 0) return const Color(0xFFEF4444);
    if (days <= 2) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getDaysText(int days) {
    if (days <= 0) return 'Due Now';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }
}
