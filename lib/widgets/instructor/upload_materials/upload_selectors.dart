import 'package:flutter/material.dart';
import '../../../models/instructor/upload_materials_model.dart';
import 'upload_materials_colors.dart';

/// Course selector dropdown
class CourseSelector extends StatelessWidget {
  final List<CourseOption> courses;
  final String? selectedCourseId;
  final ValueChanged<String?> onCourseChanged;
  final bool isDark;

  const CourseSelector({
    super.key,
    required this.courses,
    required this.selectedCourseId,
    required this.onCourseChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UploadMaterialsColors.borderColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourseId,
          hint: Text(
            'Select Course',
            style: TextStyle(
              color: UploadMaterialsColors.textSecondaryColor(isDark),
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: UploadMaterialsColors.textSecondaryColor(isDark),
          ),
          dropdownColor: isDark ? UploadMaterialsColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: courses.map((course) {
            return DropdownMenuItem<String>(
              value: course.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: UploadMaterialsColors.primary.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: UploadMaterialsColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.name,
                          style: TextStyle(
                            color: UploadMaterialsColors.textPrimaryColor(
                              isDark,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          course.code,
                          style: TextStyle(
                            color: UploadMaterialsColors.textSecondaryColor(
                              isDark,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onCourseChanged,
        ),
      ),
    );
  }
}

/// Week number selector with +/- buttons and direct typing.
/// Better UX than dropdown: fast increment/decrement, works well on mobile.
class WeekNumberSelector extends StatefulWidget {
  final int? weekNumber;
  final ValueChanged<int?> onWeekChanged;
  final bool isDark;
  final bool enabled;

  const WeekNumberSelector({
    super.key,
    required this.weekNumber,
    required this.onWeekChanged,
    required this.isDark,
    this.enabled = true,
  });

  @override
  State<WeekNumberSelector> createState() => _WeekNumberSelectorState();
}

class _WeekNumberSelectorState extends State<WeekNumberSelector> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.weekNumber?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(WeekNumberSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final expected = widget.weekNumber?.toString() ?? '';
    if (_controller.text != expected) {
      _controller.text = expected;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    if (!widget.enabled) return;
    final current = widget.weekNumber ?? 0;
    widget.onWeekChanged(current + 1);
  }

  void _decrement() {
    if (!widget.enabled) return;
    final current = widget.weekNumber ?? 1;
    if (current > 1) {
      widget.onWeekChanged(current - 1);
    }
  }

  void _clear() {
    if (!widget.enabled) return;
    widget.onWeekChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = UploadMaterialsColors.textPrimaryColor(widget.isDark);
    final secondaryColor = UploadMaterialsColors.textSecondaryColor(widget.isDark);

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isDark ? UploadMaterialsColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UploadMaterialsColors.borderColor(widget.isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Week Number',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.weekNumber != null)
                  TextButton(
                    onPressed: widget.enabled ? _clear : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'None',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Decrement button
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: widget.enabled && (widget.weekNumber ?? 1) > 1
                          ? _decrement
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.enabled && (widget.weekNumber ?? 1) > 1
                              ? UploadMaterialsColors.primary.withValues(
                                  alpha: widget.isDark ? 0.15 : 0.08,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color: widget.enabled && (widget.weekNumber ?? 1) > 1
                              ? UploadMaterialsColors.primary
                              : secondaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Number display / editable field
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showNumberDialog(),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: UploadMaterialsColors.borderColor(widget.isDark),
                        ),
                      ),
                      child: widget.weekNumber == null
                          ? Text(
                              'Optional',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                              '${widget.weekNumber}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Increment button
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: widget.enabled ? _increment : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.enabled
                              ? UploadMaterialsColors.primary.withValues(
                                  alpha: widget.isDark ? 0.15 : 0.08,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: widget.enabled
                              ? UploadMaterialsColors.primary
                              : secondaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberDialog() {
    if (!widget.enabled) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return _WeekNumberDialog(
          initialWeek: widget.weekNumber,
          isDark: widget.isDark,
          onConfirm: widget.onWeekChanged,
        );
      },
    );
  }
}

class _WeekNumberDialog extends StatefulWidget {
  final int? initialWeek;
  final bool isDark;
  final ValueChanged<int?> onConfirm;

  const _WeekNumberDialog({
    this.initialWeek,
    required this.isDark,
    required this.onConfirm,
  });

  @override
  State<_WeekNumberDialog> createState() => _WeekNumberDialogState();
}

class _WeekNumberDialogState extends State<_WeekNumberDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialWeek?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.onConfirm(null);
    } else {
      final week = int.tryParse(text);
      if (week != null && week > 0) {
        widget.onConfirm(week);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Week Number'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'e.g. 1, 2, 3...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _confirm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(null);
            Navigator.of(context).pop();
          },
          child: const Text('None'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

/// Material type filter chips
class MaterialTypeFilter extends StatelessWidget {
  final CourseMaterialType? selectedType;
  final ValueChanged<CourseMaterialType?> onTypeChanged;
  final bool isDark;

  const MaterialTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: 'All',
            isSelected: selectedType == null,
            onTap: () => onTypeChanged(null),
          ),
          const SizedBox(width: 8),
          ...CourseMaterialType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: type.title,
                icon: type.icon,
                color: type.color,
                isSelected: selectedType == type,
                onTap: () => onTypeChanged(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? UploadMaterialsColors.primary)
                : (isDark
                      ? UploadMaterialsColors.darkSurface
                      : UploadMaterialsColors.surface),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : UploadMaterialsColors.borderColor(isDark),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : UploadMaterialsColors.textPrimaryColor(isDark),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
