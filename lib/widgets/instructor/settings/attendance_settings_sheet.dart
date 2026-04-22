import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class AttendanceSettingsSheet extends StatefulWidget {
  final bool isDark;

  const AttendanceSettingsSheet({super.key, required this.isDark});

  @override
  State<AttendanceSettingsSheet> createState() =>
      _AttendanceSettingsSheetState();
}

class _AttendanceSettingsSheetState extends State<AttendanceSettingsSheet> {
  bool _autoAttendance = false;
  bool _lateMarking = true;
  int _lateThreshold = 15;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoAttendance = prefs.getBool('attendance_auto') ?? false;
      _lateMarking = prefs.getBool('attendance_late_marking') ?? true;
      _lateThreshold = prefs.getInt('attendance_late_threshold') ?? 15;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('attendance_auto', _autoAttendance);
    await prefs.setBool('attendance_late_marking', _lateMarking);
    await prefs.setInt('attendance_late_threshold', _lateThreshold);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.attendanceSettings,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: InstructorColors.textTertiaryColor(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSwitchTile(
                  isDark,
                  l10n.autoAttendance,
                  l10n.autoAttendanceDesc,
                  _autoAttendance,
                  (value) => setState(() => _autoAttendance = value),
                ),
                _buildSwitchTile(
                  isDark,
                  l10n.enableLateMarking,
                  l10n.enableLateMarkingDesc,
                  _lateMarking,
                  (value) => setState(() => _lateMarking = value),
                ),
                AnimatedOpacity(
                  opacity: _lateMarking ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: AbsorbPointer(
                    absorbing: !_lateMarking,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          l10n.lateThreshold,
                          style: TextStyle(
                            color: InstructorColors.textSecondaryColor(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [5, 10, 15, 20, 30].map((mins) {
                            return _buildThresholdChip(
                              isDark,
                              '$mins min',
                              _lateThreshold == mins,
                              () => setState(() => _lateThreshold = mins),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _saveSettings();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsSaved),
                            backgroundColor: InstructorColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: InstructorColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.saveChanges,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
    );
  }

  Widget _buildSwitchTile(
    bool isDark,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: InstructorColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: InstructorColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdChip(
    bool isDark,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? InstructorColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? InstructorColors.primary
                : InstructorColors.borderColor(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : InstructorColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
