import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/instructor/assignment_model.dart';
import 'create_assignment_colors.dart';

class DeadlineSettingsSection extends StatelessWidget {
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final bool allowLateSubmissions;
  final bool plagiarismDetection;
  final bool groupWork;
  final bool autoGrading;
  final DifficultyLevel difficulty;
  final bool isDark;
  final Color? accentColor;
  final Function(DateTime?) onDueDateChanged;
  final Function(TimeOfDay?) onDueTimeChanged;
  final Function(bool) onAllowLateChanged;
  final Function(bool) onPlagiarismChanged;
  final Function(bool) onGroupWorkChanged;
  final Function(bool) onAutoGradingChanged;
  final Function(DifficultyLevel) onDifficultyChanged;

  const DeadlineSettingsSection({
    super.key,
    required this.dueDate,
    required this.dueTime,
    required this.allowLateSubmissions,
    required this.plagiarismDetection,
    required this.groupWork,
    required this.autoGrading,
    required this.difficulty,
    required this.isDark,
    this.accentColor,
    required this.onDueDateChanged,
    required this.onDueTimeChanged,
    required this.onAllowLateChanged,
    required this.onPlagiarismChanged,
    required this.onGroupWorkChanged,
    required this.onAutoGradingChanged,
    required this.onDifficultyChanged,
  });

  Color get _accent => accentColor ?? CreateAssignmentColors.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Due Date & Time
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimePicker(context),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Toggles
        _buildToggleItem(
          label: 'Allow Late Submissions',
          value: allowLateSubmissions,
          onChanged: onAllowLateChanged,
        ),
        _buildToggleItem(
          label: 'Plagiarism Detection',
          value: plagiarismDetection,
          onChanged: onPlagiarismChanged,
        ),
        _buildToggleItem(
          label: 'Group Work',
          value: groupWork,
          onChanged: onGroupWorkChanged,
        ),
        _buildToggleItem(
          label: 'Auto-Grading (MCQ)',
          value: autoGrading,
          onChanged: onAutoGradingChanged,
        ),
        const SizedBox(height: 16),

        // Difficulty Level
        _buildDifficultySelector(),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: TextStyle(
            color: CreateAssignmentColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) {
                return Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: _accent,
                      surface: isDark
                          ? CreateAssignmentColors.darkCard
                          : Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDueDateChanged(date);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: _accent,
                ),
                const SizedBox(width: 10),
                Text(
                  dueDate != null ? dateFormat.format(dueDate!) : 'Select Date',
                  style: TextStyle(
                    color: dueDate != null
                        ? CreateAssignmentColors.textPrimaryColor(isDark)
                        : CreateAssignmentColors.textTertiaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Time',
          style: TextStyle(
            color: CreateAssignmentColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: dueTime ?? const TimeOfDay(hour: 23, minute: 59),
              builder: (ctx, child) {
                return Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: _accent,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (time != null) {
              onDueTimeChanged(time);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: _accent,
                ),
                const SizedBox(width: 10),
                Text(
                  dueTime != null ? dueTime!.format(context) : 'Select Time',
                  style: TextStyle(
                    color: dueTime != null
                        ? CreateAssignmentColors.textPrimaryColor(isDark)
                        : CreateAssignmentColors.textTertiaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(isDark),
              fontSize: 14,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: _accent,
            activeThumbColor: Colors.white,
            inactiveThumbColor: CreateAssignmentColors.textTertiaryColor(isDark),
            inactiveTrackColor: CreateAssignmentColors.borderColor(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 18,
                  color: CreateAssignmentColors.getDifficultyColor(difficulty.value),
                ),
                const SizedBox(width: 8),
                Text(
                  'Difficulty Level',
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CreateAssignmentColors.getDifficultyColor(difficulty.value)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                difficulty.displayName,
                style: TextStyle(
                  color: CreateAssignmentColors.getDifficultyColor(difficulty.value),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: difficulty.value,
              onChanged: (value) {
                onDifficultyChanged(DifficultyLevelExtension.fromValue(value));
              },
              activeColor: CreateAssignmentColors.getDifficultyColor(difficulty.value),
              inactiveColor: CreateAssignmentColors.borderColor(isDark),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDifficultyLabel('Easy', DifficultyLevel.easy),
            _buildDifficultyLabel('Medium', DifficultyLevel.medium),
            _buildDifficultyLabel('Hard', DifficultyLevel.hard),
            _buildDifficultyLabel('Very Hard', DifficultyLevel.veryHard),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyLabel(String label, DifficultyLevel level) {
    final isSelected = difficulty == level;
    return Text(
      label,
      style: TextStyle(
        color: isSelected
            ? CreateAssignmentColors.getDifficultyColor(level.value)
            : CreateAssignmentColors.textTertiaryColor(isDark),
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
