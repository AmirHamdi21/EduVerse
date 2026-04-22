import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/instructor/announcement_model.dart';
import 'announcement_colors.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementItem announcement;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAnalytics;
  final VoidCallback? onPublish;
  final VoidCallback? onPin;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    this.onAnalytics,
    this.onPublish,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AnnouncementColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AnnouncementColors.darkBorder.withOpacity(0.3)
              : AnnouncementColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : AnnouncementColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildContent(),
                const SizedBox(height: 16),
                _buildMetadata(),
                if (announcement.status == AnnouncementStatus.published) ...[
                  const SizedBox(height: 16),
                  _buildReadRate(),
                ],
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.title,
                style: TextStyle(
                  color: AnnouncementColors.textPrimaryColor(isDark),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                announcement.content,
                style: TextStyle(
                  color: AnnouncementColors.textSecondaryColor(isDark),
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (announcement.isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.push_pin_rounded,
                  color: AnnouncementColors.primary,
                  size: 18,
                ),
              ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AnnouncementColors.textSecondaryColor(isDark),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AnnouncementColors.darkCard : Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: AnnouncementColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AnnouncementColors.textPrimaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (announcement.status == AnnouncementStatus.draft ||
                    announcement.status == AnnouncementStatus.scheduled)
                  PopupMenuItem(
                    value: 'publish',
                    child: Row(
                      children: [
                        Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: AnnouncementColors.published,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Publish Now',
                          style: TextStyle(
                            color: AnnouncementColors.textPrimaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onPin != null)
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          announcement.isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin_rounded,
                          size: 18,
                          color: AnnouncementColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          announcement.isPinned ? 'Unpin' : 'Pin',
                          style: TextStyle(
                            color: AnnouncementColors.textPrimaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: AnnouncementColors.delete,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: TextStyle(color: AnnouncementColors.delete),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'publish':
                    onPublish?.call();
                    break;
                  case 'pin':
                    onPin?.call();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildStatusChip(),
        if (announcement.priority != null &&
            announcement.priority!.isNotEmpty)
          _buildPriorityChip(),
        if (announcement.announcementType != null &&
            announcement.announcementType!.isNotEmpty)
          _buildAnnouncementTypeChip(),
        if (announcement.courseName != null &&
            announcement.courseName!.isNotEmpty)
          _buildCourseChip(),
        if (announcement.attachments.isNotEmpty)
          _buildAttachmentChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor();
    final statusLightColor = _getStatusLightColor();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? statusColor.withOpacity(0.15) : statusLightColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 6),
          Text(
            announcement.status.displayName,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AnnouncementColors.darkSurface
            : AnnouncementColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AnnouncementColors.darkBorder.withOpacity(0.5)
              : AnnouncementColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file_rounded,
            size: 14,
            color: AnnouncementColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 4),
          Text(
            '${announcement.attachments.length}',
            style: TextStyle(
              color: AnnouncementColors.textSecondaryColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AnnouncementColors.accent.withOpacity(0.15)
            : AnnouncementColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnnouncementColors.accent.withOpacity(0.25)),
      ),
      child: Text(
        announcement.priority!,
        style: const TextStyle(
          color: AnnouncementColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCourseChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AnnouncementColors.primary.withOpacity(0.15)
            : AnnouncementColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnnouncementColors.primary.withOpacity(0.25)),
      ),
      child: Text(
        announcement.courseName!,
        style: const TextStyle(
          color: AnnouncementColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAnnouncementTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AnnouncementColors.teal.withOpacity(0.15)
            : AnnouncementColors.tealLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnnouncementColors.teal.withOpacity(0.3)),
      ),
      child: Text(
        announcement.announcementType!,
        style: const TextStyle(
          color: AnnouncementColors.teal,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final DateTime date;
    if (announcement.status == AnnouncementStatus.scheduled &&
        announcement.scheduledAt != null) {
      date = announcement.scheduledAt!;
    } else {
      date = announcement.publishedAt ?? announcement.createdAt;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: AnnouncementColors.textTertiaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              dateFormat.format(date),
              style: TextStyle(
                color: AnnouncementColors.textTertiaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 14,
              color: AnnouncementColors.textTertiaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              announcement.audience,
              style: TextStyle(
                color: AnnouncementColors.textTertiaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (announcement.authorName != null &&
            announcement.authorName!.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AnnouncementColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                announcement.authorName!,
                style: TextStyle(
                  color: AnnouncementColors.textTertiaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        if (announcement.viewCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 14,
                color: AnnouncementColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                '${announcement.viewCount} views',
                style: TextStyle(
                  color: AnnouncementColors.textTertiaryColor(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReadRate() {
    final percentage = announcement.readRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Read Rate',
              style: TextStyle(
                color: AnnouncementColors.textSecondaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${announcement.readCount}/${announcement.totalAudience} (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                color: AnnouncementColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: isDark
                ? AnnouncementColors.darkSurface
                : AnnouncementColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              AnnouncementColors.primary,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: onEdit,
            isPrimary: false,
          ),
        ),
        if (announcement.status == AnnouncementStatus.published) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              icon: Icons.bar_chart_rounded,
              label: 'Analytics',
              onTap: onAnalytics ?? () {},
              isPrimary: false,
            ),
          ),
        ],
        const SizedBox(width: 10),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary
                ? AnnouncementColors.primary
                : (isDark
                      ? AnnouncementColors.darkSurface
                      : AnnouncementColors.surface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? AnnouncementColors.primary
                  : (isDark
                        ? AnnouncementColors.darkBorder.withOpacity(0.5)
                        : AnnouncementColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary
                    ? Colors.white
                    : AnnouncementColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : AnnouncementColors.textSecondaryColor(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AnnouncementColors.delete.withOpacity(0.1)
                : AnnouncementColors.deleteLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AnnouncementColors.delete.withOpacity(0.3),
            ),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: AnnouncementColors.delete,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (announcement.status) {
      case AnnouncementStatus.published:
        return AnnouncementColors.published;
      case AnnouncementStatus.scheduled:
        return AnnouncementColors.scheduled;
      case AnnouncementStatus.draft:
        return AnnouncementColors.draft;
    }
  }

  Color _getStatusLightColor() {
    switch (announcement.status) {
      case AnnouncementStatus.published:
        return AnnouncementColors.publishedLight;
      case AnnouncementStatus.scheduled:
        return AnnouncementColors.scheduledLight;
      case AnnouncementStatus.draft:
        return AnnouncementColors.draftLight;
    }
  }

  IconData _getStatusIcon() {
    switch (announcement.status) {
      case AnnouncementStatus.published:
        return Icons.check_circle_outline_rounded;
      case AnnouncementStatus.scheduled:
        return Icons.schedule_rounded;
      case AnnouncementStatus.draft:
        return Icons.edit_note_rounded;
    }
  }
}
