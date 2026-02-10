import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TATrendingTopics extends StatelessWidget {
  final bool isDark;
  final List<TATrendingTopic> topics;
  final Function(TATrendingTopic)? onTopicTap;

  const TATrendingTopics({
    super.key,
    required this.isDark,
    required this.topics,
    this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: TAColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.taDiscussTrendingTopics,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...topics.map((topic) => _buildTopicRow(topic)),
        ],
      ),
    );
  }

  Widget _buildTopicRow(TATrendingTopic topic) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTopicTap?.call(topic),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  topic.name,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topic.count.toString(),
                  style: TextStyle(
                    color: TAColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TATrendingTopic {
  final String id;
  final String name;
  final int count;

  TATrendingTopic({
    required this.id,
    required this.name,
    required this.count,
  });
}
