import 'package:flutter/material.dart';
import '../../../models/instructor/assignment_model.dart';
import 'create_assignment_colors.dart';

class AssignmentTypeSelector extends StatelessWidget {
  final AssignmentType selectedType;
  final Function(AssignmentType) onTypeChanged;
  final bool isDark;

  const AssignmentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AssignmentType.values.map((type) {
          final isSelected = selectedType == type;
          return _buildTypeChip(type, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildTypeChip(AssignmentType type, bool isSelected) {
    final color = CreateAssignmentColors.getTypeColor(type.name);
    
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTypeIcon(type),
              size: 16,
              color: isSelected
                  ? Colors.white
                  : CreateAssignmentColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              type.displayName,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : CreateAssignmentColors.textSecondaryColor(isDark),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(AssignmentType type) {
    switch (type) {
      case AssignmentType.assignment:
        return Icons.assignment_rounded;
      case AssignmentType.lab:
        return Icons.science_rounded;
      case AssignmentType.project:
        return Icons.folder_special_rounded;
    }
  }
}
