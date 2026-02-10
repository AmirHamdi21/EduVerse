import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TADiscussionMonitorSection extends StatelessWidget {
  final bool isDark;
  final List<TADiscussionModel> discussions;
  final Function(TADiscussionModel discussion)? onDiscussionTap;
  final Function(TADiscussionModel discussion)? onReplyNow;
  final VoidCallback? onViewAll;

  const TADiscussionMonitorSection({
    super.key,
    required this.isDark,
    required this.discussions,
    this.onDiscussionTap,
    this.onReplyNow,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  l10n.taDiscussionMonitor,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TAColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.taUnanswered,
                    style: const TextStyle(
                      color: TAColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (discussions.isEmpty)
          _buildEmptyState(l10n)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: discussions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final discussion = discussions[index];
              return _buildDiscussionCard(discussion, l10n);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.taNoUnansweredQuestions,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionCard(TADiscussionModel discussion, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDiscussionTap?.call(discussion),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: TAColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      discussion.studentName.isNotEmpty
                          ? discussion.studentName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: TAColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discussion.studentName,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          discussion.courseCode,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    discussion.timeAgo,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                discussion.question,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.visibility_rounded,
                    label: '${discussion.viewCount} ${l10n.taViews}',
                  ),
                  const SizedBox(width: 10),
                  _buildInfoChip(
                    icon: Icons.thumb_up_rounded,
                    label: '${discussion.upvoteCount}',
                  ),
                  const Spacer(),
                  _buildReplyButton(discussion, l10n),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: TAColors.textTertiaryColor(isDark),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildReplyButton(TADiscussionModel discussion, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onReplyNow?.call(discussion),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: TAColors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: TAColors.teal.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.reply_rounded,
                color: TAColors.teal,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.taReplyNow,
                style: const TextStyle(
                  color: TAColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TADiscussionModel {
  final String id;
  final String studentName;
  final String courseCode;
  final String question;
  final String timeAgo;
  final int viewCount;
  final int upvoteCount;

  TADiscussionModel({
    required this.id,
    required this.studentName,
    required this.courseCode,
    required this.question,
    required this.timeAgo,
    this.viewCount = 0,
    this.upvoteCount = 0,
  });
}
