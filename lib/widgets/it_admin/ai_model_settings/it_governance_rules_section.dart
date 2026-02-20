import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_ai_model_settings_barrel.dart';

class ITGovernanceRulesSection extends StatelessWidget {
  final bool isDark;
  final GovernanceRules rules;
  final ValueChanged<GovernanceRules> onRulesChanged;

  const ITGovernanceRulesSection({
    super.key,
    required this.isDark,
    required this.rules,
    required this.onRulesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: isDark ? null : ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.orange.withValues(alpha: 0.2),
                      ITColors.warning.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  color: ITColors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Governance Rules',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Define AI access policies and restrictions',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Role Restrictions
          _buildSubsectionHeader('Role Restrictions', Icons.people_rounded),
          const SizedBox(height: 12),
          _buildCheckboxTile(
            'Enable AI for Students',
            'Allow students to access AI features',
            rules.enableAIForStudents,
            (value) => onRulesChanged(rules.copyWith(enableAIForStudents: value)),
            Icons.school_rounded,
          ),
          _buildCheckboxTile(
            'Enable AI for Instructors',
            'Allow instructors to access AI features',
            rules.enableAIForInstructors,
            (value) => onRulesChanged(rules.copyWith(enableAIForInstructors: value)),
            Icons.cast_for_education_rounded,
          ),
          _buildCheckboxTile(
            'Enable AI for TA',
            'Allow teaching assistants to access AI features',
            rules.enableAIForTA,
            (value) => onRulesChanged(rules.copyWith(enableAIForTA: value)),
            Icons.assistant_rounded,
          ),
          
          const SizedBox(height: 20),
          
          // AI Capabilities
          _buildSubsectionHeader('AI Capabilities', Icons.auto_awesome_rounded),
          const SizedBox(height: 12),
          _buildCheckboxTile(
            'Analyze Student Submissions',
            'Use AI to analyze and provide feedback on submissions',
            rules.analyzeStudentSubmissions,
            (value) => onRulesChanged(rules.copyWith(analyzeStudentSubmissions: value)),
            Icons.analytics_rounded,
          ),
          const SizedBox(height: 16),
          _buildSliderTile(
            'Maximum Response Length',
            '${rules.maxResponseLength} chars',
            rules.maxResponseLength.toDouble(),
            512,
            8192,
            (value) => onRulesChanged(rules.copyWith(maxResponseLength: value.round())),
          ),
          
          const SizedBox(height: 20),
          
          // Compliance & Privacy
          _buildSubsectionHeader('Compliance & Privacy', Icons.shield_rounded),
          const SizedBox(height: 12),
          _buildCheckboxTile(
            'Store AI Logs',
            'Keep records of all AI interactions',
            rules.storeAILogs,
            (value) => onRulesChanged(rules.copyWith(storeAILogs: value)),
            Icons.history_rounded,
          ),
          _buildCheckboxTile(
            'Enable Inappropriate Content Filters',
            'Block inappropriate content in AI responses',
            rules.enableContentFilters,
            (value) => onRulesChanged(rules.copyWith(enableContentFilters: value)),
            Icons.filter_alt_rounded,
          ),
          _buildCheckboxTile(
            'Block Sensitive Topics',
            'Prevent AI from discussing sensitive topics',
            rules.blockSensitiveTopics,
            (value) => onRulesChanged(rules.copyWith(blockSensitiveTopics: value)),
            Icons.block_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: ITColors.textSecondaryColor(isDark),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ITColors.textSecondaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value
                        ? ITColors.primary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: value
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Icon(
                  icon,
                  size: 20,
                  color: value
                      ? ITColors.primary
                      : ITColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String valueText,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ITColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: ITColors.primary,
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
              thumbColor: ITColors.primary,
              overlayColor: ITColors.primary.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 256).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
