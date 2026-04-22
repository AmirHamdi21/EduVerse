import 'package:flutter/material.dart';
import '../../../bloc/grades/grades_state.dart';
import '../../../common/utils/responsive.dart';
import '../../../generated_l10n/app_localizations.dart';

class GradesFilterSheet extends StatefulWidget {
  final bool isDark;
  final GradesFilter currentFilter;
  final GradesSortBy currentSort;
  final bool sortAscending;
  final Function(GradesFilter) onFilterChanged;
  final Function(GradesSortBy) onSortChanged;
  final VoidCallback onReset;

  const GradesFilterSheet({
    super.key,
    required this.isDark,
    required this.currentFilter,
    required this.currentSort,
    required this.sortAscending,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  @override
  State<GradesFilterSheet> createState() => _GradesFilterSheetState();
}

class _GradesFilterSheetState extends State<GradesFilterSheet> {
  late GradesFilter _selectedFilter;
  late GradesSortBy _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedSort = widget.currentSort;
  }

  @override
  void didUpdateWidget(covariant GradesFilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if parent state changes
    if (oldWidget.currentFilter != widget.currentFilter) {
      _selectedFilter = widget.currentFilter;
    }
    if (oldWidget.currentSort != widget.currentSort) {
      _selectedSort = widget.currentSort;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: responsive.p12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(responsive.p20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filterAndSort,
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontSize: responsive.fontSize20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.reset,
                    style: TextStyle(
                      color: const Color(0xFF6366F1),
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter section
          _buildSection(
            responsive,
            l10n,
            title: l10n.filterByGrade,
            icon: Icons.filter_list_rounded,
            child: Wrap(
              spacing: responsive.p8,
              runSpacing: responsive.p8,
              children: GradesFilter.values.map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = filter);
                    widget.onFilterChanged(filter);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (widget.isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05)),
                      ),
                    ),
                    child: Text(
                      filter.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (widget.isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        fontSize: responsive.fontSize13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: responsive.p16),

          // Sort section
          _buildSection(
            responsive,
            l10n,
            title: l10n.sortBy,
            icon: Icons.sort_rounded,
            child: Wrap(
              spacing: responsive.p8,
              runSpacing: responsive.p8,
              children: GradesSortBy.values.map((sort) {
                final isSelected = _selectedSort == sort;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedSort = sort);
                    widget.onSortChanged(sort);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (widget.isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sort.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (widget.isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B)),
                            fontSize: responsive.fontSize13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: responsive.p6),
                          Icon(
                            widget.sortAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: responsive.p24),

          // Apply button
          Padding(
            padding: EdgeInsets.all(responsive.p20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: responsive.p16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.apply,
                  style: TextStyle(
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ResponsiveUtil responsive,
    AppLocalizations l10n, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.p8),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(responsive.radius10),
                ),
                child: Icon(
                  icon,
                  color: widget.isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
              SizedBox(width: responsive.p12),
              Text(
                title,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          child,
        ],
      ),
    );
  }
}
