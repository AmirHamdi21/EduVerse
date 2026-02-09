import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class GradingSettingsSheet extends StatefulWidget {
  final bool isDark;

  const GradingSettingsSheet({super.key, required this.isDark});

  @override
  State<GradingSettingsSheet> createState() => _GradingSettingsSheetState();
}

class _GradingSettingsSheetState extends State<GradingSettingsSheet> {
  bool _autoSave = true;
  bool _showRubric = true;
  bool _anonymousGrading = false;
  String _defaultScale = 'percentage';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSave = prefs.getBool('grading_auto_save') ?? true;
      _showRubric = prefs.getBool('grading_show_rubric') ?? true;
      _anonymousGrading = prefs.getBool('grading_anonymous') ?? false;
      _defaultScale = prefs.getString('grading_default_scale') ?? 'percentage';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('grading_auto_save', _autoSave);
    await prefs.setBool('grading_show_rubric', _showRubric);
    await prefs.setBool('grading_anonymous', _anonymousGrading);
    await prefs.setString('grading_default_scale', _defaultScale);
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
                      l10n.gradingPreferences,
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
                  l10n.autoSaveGrades,
                  l10n.autoSaveGradesDesc,
                  _autoSave,
                  (value) => setState(() => _autoSave = value),
                ),
                _buildSwitchTile(
                  isDark,
                  l10n.showRubricByDefault,
                  l10n.showRubricByDefaultDesc,
                  _showRubric,
                  (value) => setState(() => _showRubric = value),
                ),
                _buildSwitchTile(
                  isDark,
                  l10n.anonymousGrading,
                  l10n.anonymousGradingDesc,
                  _anonymousGrading,
                  (value) => setState(() => _anonymousGrading = value),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.defaultGradeScale,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildScaleChip(isDark, 'Percentage', _defaultScale == 'percentage',
                        () => setState(() => _defaultScale = 'percentage')),
                    _buildScaleChip(isDark, 'Letter Grade', _defaultScale == 'letter',
                        () => setState(() => _defaultScale = 'letter')),
                    _buildScaleChip(isDark, 'Points', _defaultScale == 'points',
                        () => setState(() => _defaultScale = 'points')),
                  ],
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

  Widget _buildScaleChip(
      bool isDark, String label, bool isSelected, VoidCallback onTap) {
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
