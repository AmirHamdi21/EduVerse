import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

enum TAThreadStatus { unread, read, resolved }

class TADiscussionThreadCard extends StatelessWidget {
  final bool isDark;
  final TADiscussionThread thread;
  final VoidCallback? onTap;

  const TADiscussionThreadCard({
    super.key,
    required this.isDark,
    required this.thread,
    this.onTap,
  });

  Color _getTagColor(String tag) {
    final tagLower = tag.toLowerCase();
    if (tagLower.contains('urgent')) return TAColors.error;
    if (tagLower.contains('instructor')) return TAColors.primary;
    if (tagLower.contains('lab')) return TAColors.teal;
    if (tagLower.contains('assignment')) return TAColors.warning;
    if (tagLower.contains('general')) return TAColors.info;
    return TAColors.textSecondaryColor(isDark);
  }

  IconData _getStatusIcon(TAThreadStatus status) {
    switch (status) {
      case TAThreadStatus.unread:
        return Icons.radio_button_unchecked;
      case TAThreadStatus.read:
        return Icons.radio_button_checked;
      case TAThreadStatus.resolved:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(TAThreadStatus status) {
    switch (status) {
      case TAThreadStatus.unread:
        return TAColors.warning;
      case TAThreadStatus.read:
        return TAColors.info;
      case TAThreadStatus.resolved:
        return TAColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: thread.status == TAThreadStatus.unread
                  ? TAColors.warning.withValues(alpha: 0.3)
                  : TAColors.borderColor(isDark).withValues(alpha: 0.5),
              width: thread.status == TAThreadStatus.unread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TAColors.primary,
                          TAColors.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        thread.studentName.isNotEmpty
                            ? thread.studentName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and student name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.title,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 14,
                            fontWeight: thread.status == TAThreadStatus.unread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          thread.studentName,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status icon
                  Icon(
                    _getStatusIcon(thread.status),
                    size: 20,
                    color: _getStatusColor(thread.status),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Preview
              Text(
                thread.preview,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: thread.tags.map((tag) {
                  final color = _getTagColor(tag);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Footer
              Row(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 14,
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${thread.replyCount} ${l10n.taDiscussReplies}',
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: TAColors.textTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    thread.timeAgo,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TADiscussionThread {
  final String id;
  final String title;
  final String studentName;
  final String preview;
  final List<String> tags;
  final int replyCount;
  final String timeAgo;
  final TAThreadStatus status;
  final String? courseId;

  TADiscussionThread({
    required this.id,
    required this.title,
    required this.studentName,
    required this.preview,
    required this.tags,
    required this.replyCount,
    required this.timeAgo,
    required this.status,
    this.courseId,
  });
}
