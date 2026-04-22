import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/gamification/gamification_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class AchievementsSection extends StatelessWidget {
  final List<AchievementBadge> badges;

  const AchievementsSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.achievementsAndBadges,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            GestureDetector(
              onTap: () => _showAllBadges(context, l10n, isDark),
              child: Row(
                children: [
                  Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B7FFF),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF2B7FFF),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101828) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: badges.take(6).map((badge) {
              return _BadgeItem(badge: badge);
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAllBadges(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.allBadges,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.badgesDescription,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 6,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  return _BadgeItem(badge: badges[index], showDetails: true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final AchievementBadge badge;
  final bool showDetails;

  const _BadgeItem({required this.badge, this.showDetails = false});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    final isUnlocked = badge.isUnlocked;
    final width = showDetails
        ? double.infinity
        : (MediaQuery.of(context).size.width - 32 - 32 - 24) / 4;

    return GestureDetector(
      onTap: () => _showBadgeDetails(context, isDark),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: showDetails ? 56 : 52,
              height: showDetails ? 56 : 52,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getBadgeColor(badge.category).withValues(alpha: 0.15)
                    : (isDark
                          ? const Color(0xFF1E2939)
                          : const Color(0xFFF3F4F6)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? _getBadgeColor(badge.category).withValues(alpha: 0.3)
                      : (isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB)),
                  width: 2,
                ),
              ),
              child: Icon(
                _getBadgeIcon(badge.iconName),
                size: showDetails ? 26 : 24,
                color: isUnlocked
                    ? _getBadgeColor(badge.category)
                    : (isDark ? Colors.white30 : const Color(0xFFD1D5DB)),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isUnlocked
                      ? (isDark ? Colors.white : const Color(0xFF1F2937))
                      : (isDark ? Colors.white38 : const Color(0xFF9CA3AF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF101828) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? _getBadgeColor(badge.category).withValues(alpha: 0.15)
                    : (isDark
                          ? const Color(0xFF1E2939)
                          : const Color(0xFFF3F4F6)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getBadgeIcon(badge.iconName),
                size: 40,
                color: badge.isUnlocked
                    ? _getBadgeColor(badge.category)
                    : (isDark ? Colors.white30 : const Color(0xFFD1D5DB)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : (isDark
                          ? const Color(0xFF1E2939)
                          : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge.isUnlocked
                    ? l10n.unlocked
                    : '${badge.requiredXp} XP ${l10n.required}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: badge.isUnlocked
                      ? const Color(0xFF10B981)
                      : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: const TextStyle(
                color: Color(0xFF2B7FFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.consistency:
        return const Color(0xFFF59E0B);
      case BadgeCategory.quiz:
        return const Color(0xFF2B7FFF);
      case BadgeCategory.learning:
        return const Color(0xFF10B981);
      case BadgeCategory.performance:
        return const Color(0xFF8B5CF6);
      case BadgeCategory.social:
        return const Color(0xFFEC4899);
      case BadgeCategory.ai:
        return const Color(0xFF06B6D4);
    }
  }

  IconData _getBadgeIcon(String iconName) {
    switch (iconName) {
      case 'consistency':
        return Icons.local_fire_department_rounded;
      case 'quiz':
        return Icons.menu_book_rounded;
      case 'fast':
        return Icons.bolt_rounded;
      case 'top':
        return Icons.workspace_premium_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'ai':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }
}
