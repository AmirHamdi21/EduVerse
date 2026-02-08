import 'package:flutter/material.dart';
import 'create_assignment_colors.dart';

class LabDetailsSection extends StatelessWidget {
  final TextEditingController objectivesController;
  final TextEditingController equipmentController;
  final TextEditingController safetyController;
  final TextEditingController procedureController;
  final String? selectedLabRoom;
  final int estimatedDuration;
  final bool requiresLabCoat;
  final bool requiresSafetyGlasses;
  final bool requiresGloves;
  final bool requiresLabReport;
  final List<String> labRooms;
  final bool isDark;
  final Function(String?) onLabRoomChanged;
  final Function(int) onDurationChanged;
  final Function(bool) onLabCoatChanged;
  final Function(bool) onSafetyGlassesChanged;
  final Function(bool) onGlovesChanged;
  final Function(bool) onLabReportChanged;

  const LabDetailsSection({
    super.key,
    required this.objectivesController,
    required this.equipmentController,
    required this.safetyController,
    required this.procedureController,
    required this.selectedLabRoom,
    required this.estimatedDuration,
    required this.requiresLabCoat,
    required this.requiresSafetyGlasses,
    required this.requiresGloves,
    required this.requiresLabReport,
    required this.labRooms,
    required this.isDark,
    required this.onLabRoomChanged,
    required this.onDurationChanged,
    required this.onLabCoatChanged,
    required this.onSafetyGlassesChanged,
    required this.onGlovesChanged,
    required this.onLabReportChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lab Room & Duration Row
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Lab Room',
                value: selectedLabRoom,
                hint: 'Select Room',
                icon: Icons.science_outlined,
                items: labRooms.map((room) => DropdownMenuItem(
                  value: room,
                  child: Text(
                    room,
                    style: TextStyle(
                      color: CreateAssignmentColors.textPrimaryColor(isDark),
                      fontSize: 13,
                    ),
                  ),
                )).toList(),
                onChanged: onLabRoomChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDurationSelector(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Lab Objectives
        _buildLabel('Lab Objectives', Icons.flag_outlined),
        const SizedBox(height: 8),
        _buildTextField(
          controller: objectivesController,
          hintText: 'What students should learn or achieve...',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Equipment Required
        _buildLabel('Equipment & Materials', Icons.build_outlined),
        const SizedBox(height: 8),
        _buildTextField(
          controller: equipmentController,
          hintText: 'List all required equipment and materials...',
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Lab Procedure
        _buildLabel('Lab Procedure', Icons.list_alt_outlined),
        const SizedBox(height: 8),
        _buildTextField(
          controller: procedureController,
          hintText: 'Step-by-step instructions for the lab...',
          maxLines: 4,
        ),
        const SizedBox(height: 20),

        // Safety Requirements
        _buildSafetySection(),
        const SizedBox(height: 16),

        // Safety Instructions
        _buildLabel('Safety Instructions', Icons.health_and_safety_outlined),
        const SizedBox(height: 8),
        _buildTextField(
          controller: safetyController,
          hintText: 'Specific safety precautions and guidelines...',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Lab Report Toggle
        _buildLabReportToggle(),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CreateAssignmentColors.lab,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: CreateAssignmentColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: CreateAssignmentColors.textPrimaryColor(isDark),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: CreateAssignmentColors.textTertiaryColor(isDark),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: CreateAssignmentColors.lab,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: CreateAssignmentColors.lab),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark
                ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
                : CreateAssignmentColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CreateAssignmentColors.borderColor(isDark),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  color: CreateAssignmentColors.textTertiaryColor(isDark),
                  fontSize: 13,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: CreateAssignmentColors.textSecondaryColor(isDark),
              ),
              dropdownColor: isDark
                  ? CreateAssignmentColors.darkCard
                  : Colors.white,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer_outlined, size: 14, color: CreateAssignmentColors.lab),
            const SizedBox(width: 6),
            Text(
              'Duration',
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
                : CreateAssignmentColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CreateAssignmentColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: estimatedDuration > 30
                    ? () => onDurationChanged(estimatedDuration - 30)
                    : null,
                icon: Icon(
                  Icons.remove_rounded,
                  size: 20,
                  color: estimatedDuration > 30
                      ? CreateAssignmentColors.lab
                      : CreateAssignmentColors.textTertiaryColor(isDark),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Expanded(
                child: Text(
                  '${estimatedDuration ~/ 60}h ${estimatedDuration % 60}m',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: estimatedDuration < 480
                    ? () => onDurationChanged(estimatedDuration + 30)
                    : null,
                icon: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: estimatedDuration < 480
                      ? CreateAssignmentColors.lab
                      : CreateAssignmentColors.textTertiaryColor(isDark),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetySection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CreateAssignmentColors.lab.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.lab.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: CreateAssignmentColors.lab,
              ),
              const SizedBox(width: 8),
              Text(
                'Safety Equipment Required',
                style: TextStyle(
                  color: CreateAssignmentColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSafetyChip(
                icon: Icons.checkroom_rounded,
                label: 'Lab Coat',
                isSelected: requiresLabCoat,
                onTap: () => onLabCoatChanged(!requiresLabCoat),
              ),
              _buildSafetyChip(
                icon: Icons.visibility_rounded,
                label: 'Safety Glasses',
                isSelected: requiresSafetyGlasses,
                onTap: () => onSafetyGlassesChanged(!requiresSafetyGlasses),
              ),
              _buildSafetyChip(
                icon: Icons.back_hand_rounded,
                label: 'Gloves',
                isSelected: requiresGloves,
                onTap: () => onGlovesChanged(!requiresGloves),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CreateAssignmentColors.lab
              : (isDark ? CreateAssignmentColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? CreateAssignmentColors.lab
                : CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : CreateAssignmentColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : CreateAssignmentColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabReportToggle() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CreateAssignmentColors.lab.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 20,
              color: CreateAssignmentColors.lab,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Require Lab Report',
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Students must submit a formal lab report',
                  style: TextStyle(
                    color: CreateAssignmentColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: requiresLabReport,
            onChanged: onLabReportChanged,
            activeTrackColor: CreateAssignmentColors.lab,
            activeThumbColor: Colors.white,
            inactiveThumbColor: CreateAssignmentColors.textTertiaryColor(isDark),
            inactiveTrackColor: CreateAssignmentColors.borderColor(isDark),
          ),
        ],
      ),
    );
  }
}
