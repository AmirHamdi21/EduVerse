import 'package:flutter/material.dart';
import '../../../../bloc/labs/labs_state.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../generated_l10n/app_localizations.dart';

class LabsFilterBottomSheet extends StatefulWidget {
  final LabsFilter currentFilter;
  final bool isDark;
  final Function(LabsFilter) onApply;
  final VoidCallback onClear;

  const LabsFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.isDark,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<LabsFilterBottomSheet> createState() => _LabsFilterBottomSheetState();
}

class _LabsFilterBottomSheetState extends State<LabsFilterBottomSheet> {
  late LabsFilter _filter;

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
          // Handle
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
          // Header
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
          // Filter options
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: responsive.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status filter
                  _buildSectionTitle('Status', responsive),
                  SizedBox(height: responsive.p8),
                  _buildChipGroup<LabsDisplayStatus>(
                    values: LabsDisplayStatus.values,
                    selected: _filter.status,
                    labelBuilder: (s) => s.label,
                    colorBuilder: _statusColor,
                    onSelected: (s) {
                      setState(() {
                        _filter = _filter.copyWith(
                          status: s,
                          clearStatus: s == null,
                        );
                      });
                    },
                    responsive: responsive,
                  ),
                ],
              ),
            ),
          ),
          // Apply button
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

  Color _statusColor(LabsDisplayStatus status) {
    switch (status) {
      case LabsDisplayStatus.upcoming:
        return const Color(0xFF3B82F6);
      case LabsDisplayStatus.inProgress:
        return const Color(0xFFF59E0B);
      case LabsDisplayStatus.completed:
        return const Color(0xFF10B981);
      case LabsDisplayStatus.missed:
        return const Color(0xFFEF4444);
    }
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
}
