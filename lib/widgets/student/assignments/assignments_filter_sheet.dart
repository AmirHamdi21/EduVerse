import 'package:flutter/material.dart';
import '../../../../bloc/assignments/assignments_state.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../models/assignments/assignment_model.dart';

class AssignmentsFilterBottomSheet extends StatefulWidget {
  final AssignmentsFilter currentFilter;
  final List<String> availableCourses;
  final bool isDark;
  final Function(AssignmentsFilter) onApply;
  final VoidCallback onClear;

  const AssignmentsFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.availableCourses,
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
  late AssignmentsFilter _filter;

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
              color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
                    color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
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
                  _buildChipGroup<AssignmentStatus>(
                    values: AssignmentStatus.values,
                    selected: _filter.status,
                    labelBuilder: (s) => s.label,
                    colorBuilder: (s) => s.color,
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
                  SizedBox(height: responsive.p16),

                  // Type filter
                  _buildSectionTitle('Assignment Type', responsive),
                  SizedBox(height: responsive.p8),
                  _buildChipGroup<AssignmentType>(
                    values: AssignmentType.values,
                    selected: _filter.type,
                    labelBuilder: (t) => t.label,
                    colorBuilder: (t) => t.color,
                    onSelected: (t) {
                      setState(() {
                        _filter = _filter.copyWith(
                          type: t,
                          clearType: t == null,
                        );
                      });
                    },
                    responsive: responsive,
                  ),
                  SizedBox(height: responsive.p16),

                  // Priority filter
                  _buildSectionTitle('Priority', responsive),
                  SizedBox(height: responsive.p8),
                  _buildChipGroup<AssignmentPriority>(
                    values: AssignmentPriority.values,
                    selected: _filter.priority,
                    labelBuilder: (p) => p.label,
                    colorBuilder: (p) => p.color,
                    onSelected: (p) {
                      setState(() {
                        _filter = _filter.copyWith(
                          priority: p,
                          clearPriority: p == null,
                        );
                      });
                    },
                    responsive: responsive,
                  ),
                  SizedBox(height: responsive.p16),

                  // Course filter
                  if (widget.availableCourses.isNotEmpty) ...[
                    _buildSectionTitle('Course', responsive),
                    SizedBox(height: responsive.p8),
                    _buildCourseDropdown(responsive),
                    SizedBox(height: responsive.p16),
                  ],
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

  Widget _buildCourseDropdown(ResponsiveUtil responsive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.p12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _filter.courseName,
          hint: Text(
            'All Courses',
            style: TextStyle(
              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          isExpanded: true,
          dropdownColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Courses',
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            ...widget.availableCourses.map((course) => DropdownMenuItem(
              value: course,
              child: Text(
                course,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(
                courseName: value,
                clearCourse: value == null,
              );
            });
          },
        ),
      ),
    );
  }
}
