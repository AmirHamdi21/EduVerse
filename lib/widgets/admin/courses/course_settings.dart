import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class CourseScheduleDraft {
  final int? id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String scheduleType;

  const CourseScheduleDraft({
    this.id,
    this.dayOfWeek = 'MONDAY',
    this.startTime = '09:00',
    this.endTime = '10:30',
    this.scheduleType = 'LECTURE',
  });

  CourseScheduleDraft copyWith({
    int? id,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? scheduleType,
  }) {
    return CourseScheduleDraft(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      scheduleType: scheduleType ?? this.scheduleType,
    );
  }
}

class _ScheduleOption {
  final String value;
  final String label;

  const _ScheduleOption({required this.value, required this.label});
}

/// Course settings widget
class CourseSettings extends StatelessWidget {
  final bool isDark;
  final bool hasLabs;
  final int labCount;
  final int maxStudents;
  final bool isActive;
  final TextEditingController locationController;
  final List<CourseScheduleDraft> schedules;
  final ValueChanged<bool> onHasLabsChanged;
  final ValueChanged<int> onLabCountChanged;
  final ValueChanged<int> onMaxStudentsChanged;
  final ValueChanged<bool> onIsActiveChanged;
  final ValueChanged<List<CourseScheduleDraft>> onSchedulesChanged;
  final VoidCallback? onDeleteCourse;

  const CourseSettings({
    super.key,
    required this.isDark,
    this.hasLabs = false,
    this.labCount = 0,
    this.maxStudents = 30,
    this.isActive = true,
    required this.locationController,
    this.schedules = const <CourseScheduleDraft>[],
    required this.onHasLabsChanged,
    required this.onLabCountChanged,
    required this.onMaxStudentsChanged,
    required this.onIsActiveChanged,
    required this.onSchedulesChanged,
    this.onDeleteCourse,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.courseSettings,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCapacitySetting(l10n),
          const SizedBox(height: 20),
          _buildLabSettings(l10n),
          const SizedBox(height: 20),
          _buildLocationSetting(l10n),
          const SizedBox(height: 20),
          _buildScheduleSettings(l10n),
          const SizedBox(height: 20),
          _buildStatusToggle(l10n),
          if (onDeleteCourse != null) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onDeleteCourse,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AdminColors.error,
                ),
                label: Text(
                  l10n.delete,
                  style: TextStyle(color: AdminColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AdminColors.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapacitySetting(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.maxStudents,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildAdjustButton(
              icon: Icons.remove_rounded,
              onTap: () {
                if (maxStudents > 5) {
                  onMaxStudentsChanged(maxStudents - 5);
                }
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AdminColors.darkSurface.withValues(alpha: 0.5)
                      : const Color(0xFFF3F3F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$maxStudents ${l10n.students}',
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            _buildAdjustButton(
              icon: Icons.add_rounded,
              onTap: () {
                if (maxStudents < 500) {
                  onMaxStudentsChanged(maxStudents + 5);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AdminColors.primary,
            inactiveTrackColor: AdminColors.primary.withValues(alpha: 0.2),
            thumbColor: AdminColors.primary,
            overlayColor: AdminColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: maxStudents.toDouble(),
            min: 5,
            max: 500,
            divisions: 99,
            onChanged: (value) => onMaxStudentsChanged(value.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildLabSettings(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hasLabs,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.labsDescription,
                  style: TextStyle(
                    color: AdminColors.getTextSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Switch(
              value: hasLabs,
              onChanged: onHasLabsChanged,
              activeThumbColor: AdminColors.accent,
            ),
          ],
        ),
        if (hasLabs) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.numberOfLabs,
                  style: TextStyle(
                    color: AdminColors.getTextColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAdjustButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        if (labCount > 0) {
                          onLabCountChanged(labCount - 1);
                        }
                      },
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AdminColors.darkSurface.withValues(alpha: 0.5)
                              : const Color(0xFFF3F3F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$labCount',
                            style: TextStyle(
                              color: AdminColors.getTextColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildAdjustButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        if (labCount < 20) {
                          onLabCountChanged(labCount + 1);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AdminColors.accent,
                    inactiveTrackColor: AdminColors.accent.withValues(
                      alpha: 0.2,
                    ),
                    thumbColor: AdminColors.accent,
                    overlayColor: AdminColors.accent.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: labCount.toDouble(),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    onChanged: (value) => onLabCountChanged(value.toInt()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isActive ? AdminColors.greenGradient : null,
        color: isActive
            ? null
            : (isDark ? AdminColors.darkSurface : Colors.grey[200]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isActive
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_rounded,
                color: isActive
                    ? Colors.white
                    : AdminColors.getTextSecondaryColor(isDark),
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? l10n.courseActive : l10n.courseInactive,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AdminColors.getTextColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isActive ? l10n.studentCanEnroll : l10n.enrollmentPaused,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isActive,
            onChanged: onIsActiveChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSetting(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.location,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: locationController,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: l10n.locationHint,
            hintStyle: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSettings(AppLocalizations l10n) {
    final dayOptions = _dayOptions(l10n);
    final typeOptions = _typeOptions(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n.schedule,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addSchedule,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l10n.add),
            ),
          ],
        ),
        if (schedules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AdminColors.darkSurface.withValues(alpha: 0.45)
                  : AdminColors.lightBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Add at least one schedule entry.',
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
          )
        else
          ...List<Widget>.generate(schedules.length, (index) {
            final schedule = schedules[index];
            final currentDay =
                dayOptions.any((option) => option.value == schedule.dayOfWeek)
                ? schedule.dayOfWeek
                : dayOptions.first.value;
            final currentType =
                typeOptions.any(
                  (option) => option.value == schedule.scheduleType,
                )
                ? schedule.scheduleType
                : typeOptions.first.value;

            return Container(
              margin: EdgeInsets.only(
                bottom: index == schedules.length - 1 ? 0 : 10,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AdminColors.darkSurface.withValues(alpha: 0.45)
                    : AdminColors.lightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: currentDay,
                          isDense: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AdminColors.darkCard.withValues(alpha: 0.65)
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          dropdownColor: isDark
                              ? AdminColors.darkCard
                              : Colors.white,
                          items: dayOptions
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.value,
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      color: AdminColors.getTextColor(isDark),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            _replaceSchedule(
                              index,
                              schedule.copyWith(dayOfWeek: value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: currentType,
                          isDense: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AdminColors.darkCard.withValues(alpha: 0.65)
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          dropdownColor: isDark
                              ? AdminColors.darkCard
                              : Colors.white,
                          items: typeOptions
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.value,
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      color: AdminColors.getTextColor(isDark),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            _replaceSchedule(
                              index,
                              schedule.copyWith(scheduleType: value),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeSchedule(index),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AdminColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildTimeField(
                          label: l10n.startTime,
                          value: schedule.startTime,
                          onChanged: (value) {
                            _replaceSchedule(
                              index,
                              schedule.copyWith(startTime: value.trim()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTimeField(
                          label: l10n.endTime,
                          value: schedule.endTime,
                          onChanged: (value) {
                            _replaceSchedule(
                              index,
                              schedule.copyWith(endTime: value.trim()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: TextStyle(color: AdminColors.getTextColor(isDark), fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: '09:00',
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.65)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );
  }

  List<_ScheduleOption> _dayOptions(AppLocalizations l10n) {
    return <_ScheduleOption>[
      _ScheduleOption(value: 'MONDAY', label: l10n.monday),
      _ScheduleOption(value: 'TUESDAY', label: l10n.tuesday),
      _ScheduleOption(value: 'WEDNESDAY', label: l10n.wednesday),
      _ScheduleOption(value: 'THURSDAY', label: l10n.thursday),
      _ScheduleOption(value: 'FRIDAY', label: l10n.friday),
      _ScheduleOption(value: 'SATURDAY', label: l10n.saturday),
      _ScheduleOption(value: 'SUNDAY', label: l10n.sunday),
    ];
  }

  List<_ScheduleOption> _typeOptions(AppLocalizations l10n) {
    return <_ScheduleOption>[
      _ScheduleOption(value: 'LECTURE', label: l10n.lectureType),
      _ScheduleOption(value: 'LAB', label: l10n.labType),
      const _ScheduleOption(value: 'TUTORIAL', label: 'Tutorial'),
    ];
  }

  void _addSchedule() {
    final next = List<CourseScheduleDraft>.from(schedules)
      ..add(const CourseScheduleDraft());
    onSchedulesChanged(next);
  }

  void _removeSchedule(int index) {
    final next = List<CourseScheduleDraft>.from(schedules)..removeAt(index);
    onSchedulesChanged(next);
  }

  void _replaceSchedule(int index, CourseScheduleDraft updated) {
    final next = List<CourseScheduleDraft>.from(schedules)..[index] = updated;
    onSchedulesChanged(next);
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AdminColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AdminColors.primary, size: 20),
        ),
      ),
    );
  }
}
