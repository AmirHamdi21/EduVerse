import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

enum TADiscussionFilter { all, unanswered, highActivity, aiFlagged }

class TACourseDiscussionsTab extends StatefulWidget {
  final bool isDark;
  final List<TADiscussionItem> discussions;
  final Function(TADiscussionItem)? onReplyAsTA;
  final Function(TADiscussionFilter)? onFilterChanged;

  const TACourseDiscussionsTab({
    super.key,
    required this.isDark,
    required this.discussions,
    this.onReplyAsTA,
    this.onFilterChanged,
  });

  @override
  State<TACourseDiscussionsTab> createState() => _TACourseDiscussionsTabState();
}

class _TACourseDiscussionsTabState extends State<TACourseDiscussionsTab> {
  TADiscussionFilter _selectedFilter = TADiscussionFilter.all;

  List<TADiscussionItem> get filteredDiscussions {
    switch (_selectedFilter) {
      case TADiscussionFilter.all:
        return widget.discussions;
      case TADiscussionFilter.unanswered:
        return widget.discussions.where((d) => !d.isAnswered).toList();
      case TADiscussionFilter.highActivity:
        return widget.discussions.where((d) => d.repliesCount >= 5).toList();
      case TADiscussionFilter.aiFlagged:
        return widget.discussions.where((d) => d.isAIFlagged).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterChips(l10n),
        const SizedBox(height: 16),
        if (filteredDiscussions.isEmpty)
          _buildEmptyState(l10n)
        else
          ...filteredDiscussions.map((d) => _buildDiscussionCard(d, l10n)),
      ],
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.taCourseFilterAll,
            filter: TADiscussionFilter.all,
            icon: Icons.all_inclusive_rounded,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.taCourseFilterUnanswered,
            filter: TADiscussionFilter.unanswered,
            icon: Icons.help_outline_rounded,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.taCourseFilterHighActivity,
            filter: TADiscussionFilter.highActivity,
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.taCourseFilterAIFlagged,
            filter: TADiscussionFilter.aiFlagged,
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required TADiscussionFilter filter,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
          widget.onFilterChanged?.call(filter);
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? TAColors.primary
                : TAColors.cardColor(widget.isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(widget.isDark),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: TAColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : TAColors.textSecondaryColor(widget.isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_rounded,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.taCourseNoDiscussions,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taCourseNoDiscussionsDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(widget.isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionCard(TADiscussionItem discussion, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: discussion.isAIFlagged
              ? TAColors.warning.withValues(alpha: 0.5)
              : TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: widget.isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    discussion.studentName.isNotEmpty
                        ? discussion.studentName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: TAColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
                        color: TAColors.textPrimaryColor(widget.isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      discussion.timeAgo,
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(widget.isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDiscussionBadges(discussion, l10n),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            discussion.question,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.reply_rounded,
                value: '${discussion.repliesCount}',
                label: l10n.taCourseDiscussionReplies,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.thumb_up_outlined,
                value: '${discussion.likesCount}',
                label: l10n.taCourseDiscussionLikes,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => widget.onReplyAsTA?.call(discussion),
                icon: const Icon(Icons.reply_rounded, size: 16),
                label: Text(l10n.taCourseReplyAsTA),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TAColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionBadges(TADiscussionItem discussion, AppLocalizations l10n) {
    return Row(
      children: [
        if (discussion.isAIFlagged)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TAColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: TAColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    color: TAColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (!discussion.isAnswered)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TAColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l10n.taCourseUnanswered,
              style: TextStyle(
                color: TAColors.error,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: TAColors.textTertiaryColor(widget.isDark),
        ),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            color: TAColors.textSecondaryColor(widget.isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class TADiscussionItem {
  final String id;
  final String studentName;
  final String question;
  final String timeAgo;
  final int repliesCount;
  final int likesCount;
  final bool isAnswered;
  final bool isAIFlagged;

  TADiscussionItem({
    required this.id,
    required this.studentName,
    required this.question,
    required this.timeAgo,
    required this.repliesCount,
    required this.likesCount,
    required this.isAnswered,
    required this.isAIFlagged,
  });
}
