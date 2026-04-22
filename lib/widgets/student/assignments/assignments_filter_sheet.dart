import 'package:flutter/material.dart';

import '../../../../bloc/assignments/assignment_state.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../generated_l10n/app_localizations.dart';

class AssignmentsFilterBottomSheet extends StatefulWidget {
  final AssignmentFilterStatus currentFilter;
  final bool isDark;
  final ValueChanged<AssignmentFilterStatus> onApply;
  final VoidCallback onClear;

  const AssignmentsFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.isDark,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<AssignmentsFilterBottomSheet> createState() =>
      _AssignmentsFilterBottomSheetState();
}

class _AssignmentsFilterBottomSheetState
    extends State<AssignmentsFilterBottomSheet> {
  late AssignmentFilterStatus _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: responsive.p12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: Row(
              children: [
                Text(
                  l10n.filter,
                  style: TextStyle(
                    fontSize: responsive.fontSize18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = AssignmentFilterStatus.all;
                    });
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.clearFilters,
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: responsive.fontSize14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Status', responsive),
                  SizedBox(height: responsive.p8),
                  _buildChipGroup<AssignmentFilterStatus>(
                    values: AssignmentFilterStatus.values,
                    selected: _filter,
                    labelBuilder: _statusLabel,
                    colorBuilder: _statusColor,
                    onSelected: (status) {
                      setState(() {
                        _filter = status ?? AssignmentFilterStatus.all;
                      });
                    },
                    responsive: responsive,
                  ),
                  SizedBox(height: responsive.p16),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: SizedBox(
              width: double.infinity,
              height: responsive.p48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
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

  Widget _buildSectionTitle(String title, ResponsiveUtil responsive) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.fontSize14,
        fontWeight: FontWeight.w600,
        color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildChipGroup<T>({
    required List<T> values,
    required T? selected,
    required String Function(T) labelBuilder,
    required Color Function(T) colorBuilder,
    required Function(T?) onSelected,
    required ResponsiveUtil responsive,
  }) {
    return Wrap(
      spacing: responsive.p8,
      runSpacing: responsive.p8,
      children: values.map((value) {
        final isSelected = selected == value;
        final color = colorBuilder(value);

        return FilterChip(
          label: Text(labelBuilder(value)),
          selected: isSelected,
          onSelected: (_) => onSelected(isSelected ? null : value),
          backgroundColor: widget.isDark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
          selectedColor: color.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? color
                : (widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            fontSize: responsive.fontSize13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p8,
            vertical: responsive.p4,
          ),
        );
      }).toList(),
    );
  }

  String _statusLabel(AssignmentFilterStatus status) {
    switch (status) {
      case AssignmentFilterStatus.all:
        return 'All';
      case AssignmentFilterStatus.submitted:
        return 'Submitted';
      case AssignmentFilterStatus.pending:
        return 'Pending';
      case AssignmentFilterStatus.overdue:
        return 'Overdue';
    }
  }

  Color _statusColor(AssignmentFilterStatus status) {
    switch (status) {
      case AssignmentFilterStatus.all:
        return const Color(0xFF6366F1);
      case AssignmentFilterStatus.submitted:
        return const Color(0xFF3B82F6);
      case AssignmentFilterStatus.pending:
        return const Color(0xFFF59E0B);
      case AssignmentFilterStatus.overdue:
        return const Color(0xFFEF4444);
    }
  }
}
