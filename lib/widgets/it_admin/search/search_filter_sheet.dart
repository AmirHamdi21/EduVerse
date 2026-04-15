import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSearchFilterSheet extends StatefulWidget {
  final bool isDark;
  final String selectedStatus;
  final String selectedPriority;
  final DateTimeRange? dateRange;
  final Function(String status, String priority, DateTimeRange? dateRange)
  onApply;

  const ITSearchFilterSheet({
    super.key,
    required this.isDark,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.dateRange,
    required this.onApply,
  });

  @override
  State<ITSearchFilterSheet> createState() => _ITSearchFilterSheetState();
}

class _ITSearchFilterSheetState extends State<ITSearchFilterSheet> {
  late String _status;
  late String _priority;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _priority = widget.selectedPriority;
    _dateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ITColors.cardColor(widget.isDark),
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
                color: ITColors.borderColor(widget.isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter Results',
            style: TextStyle(
              color: ITColors.textPrimaryColor(widget.isDark),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Status Filter
          Text(
            'Status',
            style: TextStyle(
              color: ITColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'all',
                  'operational',
                  'degraded',
                  'offline',
                  'maintenance',
                ].map((status) {
                  final isSelected = _status == status;
                  return FilterChip(
                    label: Text(
                      status == 'all'
                          ? 'All'
                          : status[0].toUpperCase() + status.substring(1),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _status = status),
                    selectedColor: ITColors.primary,
                    backgroundColor: ITColors.cardColor(widget.isDark),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : ITColors.textSecondaryColor(widget.isDark),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? ITColors.primary
                          : ITColors.borderColor(widget.isDark),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),

          // Priority Filter
          Text(
            'Priority',
            style: TextStyle(
              color: ITColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['all', 'critical', 'high', 'medium', 'low'].map((
              priority,
            ) {
              final isSelected = _priority == priority;
              final color = _getPriorityColor(priority);
              return FilterChip(
                label: Text(
                  priority == 'all'
                      ? 'All'
                      : priority[0].toUpperCase() + priority.substring(1),
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _priority = priority),
                selectedColor: color,
                backgroundColor: ITColors.cardColor(widget.isDark),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : ITColors.textSecondaryColor(widget.isDark),
                ),
                side: BorderSide(
                  color: isSelected
                      ? color
                      : ITColors.borderColor(widget.isDark),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Date Range
          Text(
            'Date Range',
            style: TextStyle(
              color: ITColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (range != null) {
                setState(() => _dateRange = range);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ITColors.cardColor(widget.isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ITColors.borderColor(widget.isDark)),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range_rounded, color: ITColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRange != null
                          ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                          : 'Select date range',
                      style: TextStyle(
                        color: _dateRange != null
                            ? ITColors.textPrimaryColor(widget.isDark)
                            : ITColors.textTertiaryColor(widget.isDark),
                      ),
                    ),
                  ),
                  if (_dateRange != null)
                    IconButton(
                      onPressed: () => setState(() => _dateRange = null),
                      icon: Icon(
                        Icons.close_rounded,
                        color: ITColors.textSecondaryColor(widget.isDark),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _status = 'all';
                      _priority = 'all';
                      _dateRange = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: ITColors.borderColor(widget.isDark),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(widget.isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_status, _priority, _dateRange);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ITColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return ITColors.error;
      case 'high':
        return ITColors.warning;
      case 'medium':
        return ITColors.info;
      case 'low':
        return ITColors.success;
      default:
        return ITColors.primary;
    }
  }
}
