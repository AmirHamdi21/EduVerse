import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminSearchFilters extends StatelessWidget {
  final bool isDark;
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final List<String> categories;

  const AdminSearchFilters({
    super.key,
    required this.isDark,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category),
              label: Text(category),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AdminColors.darkText : AdminColors.lightText),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: isDark
                  ? AdminColors.darkCard
                  : AdminColors.lightCard,
              selectedColor: AdminColors.primary,
              side: BorderSide(
                color: isSelected
                    ? AdminColors.primary
                    : (isDark
                          ? AdminColors.darkCardBorder
                          : AdminColors.lightCardBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              avatar: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class AdminSearchFilterSheet extends StatefulWidget {
  final bool isDark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onReset;

  const AdminSearchFilterSheet({
    super.key,
    required this.isDark,
    required this.currentFilters,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<AdminSearchFilterSheet> createState() => _AdminSearchFilterSheetState();
}

class _AdminSearchFilterSheetState extends State<AdminSearchFilterSheet> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark
                        ? AdminColors.darkText
                        : AdminColors.lightText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(color: AdminColors.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilterSection('Date Range', [
              _buildDateOption('Today'),
              _buildDateOption('This Week'),
              _buildDateOption('This Month'),
              _buildDateOption('All Time'),
            ]),
            const SizedBox(height: 20),
            _buildFilterSection('Status', [
              _buildStatusOption('Active', AdminColors.success),
              _buildStatusOption('Inactive', AdminColors.error),
              _buildStatusOption('Pending', AdminColors.warning),
            ]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: widget.isDark
                            ? AdminColors.darkCardBorder
                            : AdminColors.lightCardBorder,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: widget.isDark
                            ? AdminColors.darkText
                            : AdminColors.lightText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_filters);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isDark
                ? AdminColors.darkTextSecondary
                : AdminColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: options),
      ],
    );
  }

  Widget _buildDateOption(String label) {
    final isSelected = _filters['dateRange'] == label;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filters['dateRange'] = selected ? label : null;
        });
      },
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (widget.isDark ? AdminColors.darkText : AdminColors.lightText),
      ),
      selectedColor: AdminColors.primary,
      backgroundColor: widget.isDark
          ? AdminColors.darkCard
          : AdminColors.lightCard,
    );
  }

  Widget _buildStatusOption(String label, Color color) {
    final isSelected = _filters['status'] == label;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filters['status'] = selected ? label : null;
        });
      },
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (widget.isDark ? AdminColors.darkText : AdminColors.lightText),
      ),
      selectedColor: color,
      backgroundColor: widget.isDark
          ? AdminColors.darkCard
          : AdminColors.lightCard,
      avatar: isSelected ? null : Icon(Icons.circle, size: 12, color: color),
    );
  }
}
