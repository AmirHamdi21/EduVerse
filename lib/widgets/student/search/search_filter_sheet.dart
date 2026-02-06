import 'package:flutter/material.dart';
import '../../../bloc/search/search_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SearchFilterSheet extends StatefulWidget {
  final SearchFilter filter;
  final bool isDark;
  final ValueChanged<SearchFilter> onApply;

  const SearchFilterSheet({
    super.key,
    required this.filter,
    required this.isDark,
    required this.onApply,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.searchFilters,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_filter.hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filter = SearchFilter(category: _filter.category);
                      });
                    },
                    child: Text(
                      l10n.reset,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status filter
          _buildSection(
            title: l10n.status,
            isDark: isDark,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(l10n.pending, 'pending', _filter.status, isDark),
                _buildChip(l10n.inProgress, 'inProgress', _filter.status, isDark),
                _buildChip(l10n.completed, 'completed', _filter.status, isDark),
                _buildChip(l10n.overdue, 'overdue', _filter.status, isDark),
              ],
            ),
          ),

          // Sort by
          _buildSection(
            title: l10n.sortBy,
            isDark: isDark,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSortChip(l10n.searchSortByName, 'name', isDark),
                _buildSortChip(l10n.searchSortByDate, 'date', isDark),
                _buildSortChip(l10n.searchSortByType, 'type', isDark),
              ],
            ),
          ),

          // Sort direction
          if (_filter.sortBy != null)
            _buildSection(
              title: l10n.searchSortDirection,
              isDark: isDark,
              child: Row(
                children: [
                  _buildDirectionChip(
                    l10n.searchAscending,
                    true,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildDirectionChip(
                    l10n.searchDescending,
                    false,
                    isDark,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF155DFC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.applyFilters,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value, String? selected, bool isDark) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _filter = _filter.copyWith(clearStatus: true);
          } else {
            _filter = _filter.copyWith(status: value);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF155DFC).withValues(alpha: 0.1)
              : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF155DFC)
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF155DFC)
                : isDark
                    ? Colors.white70
                    : const Color(0xFF475569),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, bool isDark) {
    final isSelected = value == _filter.sortBy;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _filter = _filter.copyWith(clearSortBy: true);
          } else {
            _filter = _filter.copyWith(sortBy: value);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
              : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : isDark
                    ? Colors.white70
                    : const Color(0xFF475569),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionChip(String label, bool ascending, bool isDark) {
    final isSelected = _filter.ascending == ascending;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = _filter.copyWith(ascending: ascending);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 14,
              color: isSelected
                  ? const Color(0xFF10B981)
                  : isDark
                      ? Colors.white54
                      : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : isDark
                        ? Colors.white70
                        : const Color(0xFF475569),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
