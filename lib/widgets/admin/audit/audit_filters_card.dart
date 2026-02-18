import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AuditFiltersCard extends StatelessWidget {
  final bool isDark;
  final String? selectedSeverity;
  final String? selectedAction;
  final DateTimeRange? dateRange;
  final String searchQuery;
  final ValueChanged<String?> onSeverityChanged;
  final ValueChanged<String?> onActionChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  const AuditFiltersCard({
    super.key,
    required this.isDark,
    this.selectedSeverity,
    this.selectedAction,
    this.dateRange,
    required this.searchQuery,
    required this.onSeverityChanged,
    required this.onActionChanged,
    required this.onDateRangeChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.cyanGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.filters,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: Icon(Icons.clear_rounded, size: 16, color: AdminColors.error),
                  label: Text(
                    l10n.clearAll,
                    style: TextStyle(color: AdminColors.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Search
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchLogs,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AdminColors.getTextColor(isDark).withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyle(color: AdminColors.getTextColor(isDark)),
          ),
          const SizedBox(height: 16),
          // Severity filter
          Text(
            l10n.severity,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(context, null, l10n.all, selectedSeverity, onSeverityChanged),
              _buildFilterChip(context, 'info', l10n.info, selectedSeverity, onSeverityChanged,
                  color: AdminColors.primary),
              _buildFilterChip(context, 'warning', l10n.warning, selectedSeverity, onSeverityChanged,
                  color: AdminColors.warning),
              _buildFilterChip(context, 'critical', l10n.critical, selectedSeverity, onSeverityChanged,
                  color: AdminColors.error),
            ],
          ),
          const SizedBox(height: 16),
          // Action type filter
          Text(
            l10n.actionType,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(context, null, l10n.all, selectedAction, onActionChanged),
              _buildFilterChip(context, 'login', l10n.login, selectedAction, onActionChanged),
              _buildFilterChip(context, 'logout', l10n.logout, selectedAction, onActionChanged),
              _buildFilterChip(context, 'create', l10n.create, selectedAction, onActionChanged),
              _buildFilterChip(context, 'update', l10n.update, selectedAction, onActionChanged),
              _buildFilterChip(context, 'delete', l10n.delete, selectedAction, onActionChanged),
            ],
          ),
          const SizedBox(height: 16),
          // Date range
          Text(
            l10n.dateRange,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _selectDateRange(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: dateRange != null
                    ? Border.all(color: AdminColors.primary.withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 18,
                    color: dateRange != null
                        ? AdminColors.primary
                        : AdminColors.getTextColor(isDark).withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    dateRange != null
                        ? '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}'
                        : l10n.selectDateRange,
                    style: TextStyle(
                      fontSize: 13,
                      color: dateRange != null
                          ? AdminColors.primary
                          : AdminColors.getTextColor(isDark).withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (dateRange != null)
                    GestureDetector(
                      onTap: () => onDateRangeChanged(null),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AdminColors.getTextColor(isDark).withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      selectedSeverity != null ||
      selectedAction != null ||
      dateRange != null ||
      searchQuery.isNotEmpty;

  Widget _buildFilterChip(
    BuildContext context,
    String? value,
    String label,
    String? selected,
    ValueChanged<String?> onChanged, {
    Color? color,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AdminColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(10),
          border: !isSelected && color != null
              ? Border.all(color: color.withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null && !isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AdminColors.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );
    if (result != null) {
      onDateRangeChanged(result);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
