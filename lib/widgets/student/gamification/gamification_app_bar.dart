import 'package:flutter/material.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/gamification/gamification_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamificationAppBar extends StatelessWidget {
  final TimeFilter timeFilter;
  final Function(TimeFilter) onFilterChanged;

  const GamificationAppBar({
    super.key,
    required this.timeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildBackButton(context, isDark),
          const SizedBox(width: 12),
          _buildTimeFilters(context, l10n, isDark),
          const Spacer(),
          _buildSettingsButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => safeBack(context, '/dashboard'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          iosBackIcon(context),
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTimeFilters(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip(context, l10n.weekly, TimeFilter.weekly, isDark),
          _buildFilterChip(context, l10n.monthly, TimeFilter.monthly, isDark),
          _buildFilterChip(context, l10n.allTime, TimeFilter.allTime, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    TimeFilter filter,
    bool isDark,
  ) {
    final isSelected = timeFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B7FFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showSettingsSheet(context, isDark),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: isDark ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              l10n.settings,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              context,
              isDark,
              Icons.notifications_outlined,
              l10n.notifications,
              () {},
            ),
            _buildSettingItem(
              context,
              isDark,
              Icons.lock_outline_rounded,
              l10n.privacy,
              () {},
            ),
            _buildSettingItem(
              context,
              isDark,
              Icons.help_outline_rounded,
              l10n.help,
              () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2939)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
