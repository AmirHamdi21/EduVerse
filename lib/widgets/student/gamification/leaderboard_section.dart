import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/gamification/gamification_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class LeaderboardSection extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final LeaderboardFilter filter;
  final String searchQuery;
  final bool isComparing;
  final List<LeaderboardEntry> compareUsers;
  final Function(LeaderboardFilter) onFilterChanged;
  final Function(String) onSearch;
  final VoidCallback onToggleCompare;
  final Function(LeaderboardEntry) onUserSelected;

  const LeaderboardSection({
    super.key,
    required this.entries,
    required this.filter,
    required this.searchQuery,
    required this.isComparing,
    required this.compareUsers,
    required this.onFilterChanged,
    required this.onSearch,
    required this.onToggleCompare,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTabs(l10n, isDark),
        const SizedBox(height: 16),
        _buildSearchBar(context, l10n, isDark),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101828) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: entries.isEmpty
                ? [_buildEmptyState(l10n, isDark)]
                : entries.map((entry) {
                    final isLast = entries.last == entry;
                    return _LeaderboardItem(
                      entry: entry,
                      isLast: isLast,
                      isComparing: isComparing,
                      isSelected: compareUsers.any((u) => u.id == entry.id),
                      onTap: isComparing ? () => onUserSelected(entry) : null,
                    );
                  }).toList(),
          ),
        ),
        if (isComparing && compareUsers.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildCompareButton(context, l10n, isDark),
        ],
      ],
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            l10n.global,
            LeaderboardFilter.global,
            Icons.public_rounded,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            l10n.perCourse,
            LeaderboardFilter.perCourse,
            Icons.school_rounded,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            l10n.friends,
            LeaderboardFilter.friends,
            Icons.people_rounded,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    LeaderboardFilter chipFilter,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = filter == chipFilter;

    return GestureDetector(
      onTap: () => onFilterChanged(chipFilter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2B7FFF)
              : (isDark ? const Color(0xFF1E2939) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2B7FFF)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearch,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: l10n.findClassmate,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onToggleCompare,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isComparing
                  ? const Color(0xFF2B7FFF)
                  : (isDark ? const Color(0xFF1E2939) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isComparing
                    ? const Color(0xFF2B7FFF)
                    : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 20,
                  color: isComparing
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.compareProgress,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isComparing
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: isDark ? Colors.white30 : const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noResults,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareButton(BuildContext context, AppLocalizations l10n, bool isDark) {
    return GestureDetector(
      onTap: () => _showCompareSheet(context, l10n, isDark),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.compare_arrows_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${l10n.compare} ${compareUsers.length} ${l10n.users}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompareSheet(BuildContext context, AppLocalizations l10n, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.progressComparison,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: compareUsers.map((user) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CompareUserCard(entry: user),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isLast;
  final bool isComparing;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LeaderboardItem({
    required this.entry,
    required this.isLast,
    required this.isComparing,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: entry.isCurrentUser
              ? (isDark
                  ? const Color(0xFF2B7FFF).withValues(alpha: 0.15)
                  : const Color(0xFFF0F7FF))
              : (isSelected
                  ? (isDark
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                      : const Color(0xFFF5F3FF))
                  : Colors.transparent),
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
            left: entry.isCurrentUser
                ? const BorderSide(color: Color(0xFF2B7FFF), width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            _buildRank(isDark),
            const SizedBox(width: 14),
            _buildAvatar(isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (entry.isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B7FFF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'You',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2B7FFF),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.levelTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.xp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2B7FFF),
                  ),
                ),
                Text(
                  'XP',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            if (isComparing) ...[
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRank(bool isDark) {
    final isTop3 = entry.rank <= 3;
    Color rankColor;
    IconData? rankIcon;

    if (entry.rank == 1) {
      rankColor = const Color(0xFFF59E0B);
      rankIcon = Icons.emoji_events_rounded;
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFF94A3B8);
      rankIcon = Icons.emoji_events_rounded;
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events_rounded;
    } else {
      rankColor = isDark ? Colors.white54 : const Color(0xFF6B7280);
    }

    return SizedBox(
      width: 32,
      child: isTop3
          ? Icon(rankIcon, size: 24, color: rankColor)
          : Text(
              entry.rank.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: entry.isCurrentUser
              ? const Color(0xFF2B7FFF)
              : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: entry.avatarUrl.isNotEmpty
            ? Image.network(
                entry.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(isDark),
              )
            : _buildDefaultAvatar(isDark),
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
      child: Icon(
        Icons.person_rounded,
        size: 22,
        color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
      ),
    );
  }
}

class _CompareUserCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _CompareUserCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
            ),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E2939) : Colors.white,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 26,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
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
                  entry.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.levelTitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.xp} XP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
