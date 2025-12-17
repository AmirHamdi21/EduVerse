import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/quiz_models.dart';

class QuizSettingsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final QuizType selectedQuizType;
  final Function(QuizType) onQuizTypeChanged;
  final DifficultyLevel selectedDifficultyLevel;
  final Function(DifficultyLevel) onDifficultyLevelChanged;
  final int numberOfQuestions;
  final Function(double) onNumberOfQuestionsChanged;
  final bool includeWeakTopics;
  final Function(bool) onIncludeWeakTopicsChanged;

  const QuizSettingsCard({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.selectedQuizType,
    required this.onQuizTypeChanged,
    required this.selectedDifficultyLevel,
    required this.onDifficultyLevelChanged,
    required this.numberOfQuestions,
    required this.onNumberOfQuestionsChanged,
    required this.includeWeakTopics,
    required this.onIncludeWeakTopicsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final borderColor = isDark
        ? const Color(0xFF3A4456)
        : const Color(0xFFD1D5DC);

    return Container(
      padding: EdgeInsets.all(responsive.p24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(responsive.radius24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            AppLocalizations.of(context).quizType,
            _buildQuizTypeButtons(context, responsive, isDark),
            responsive,
          ),
          SizedBox(height: responsive.p24),
          _buildSection(
            context,
            AppLocalizations.of(context).difficultyLevel,
            _buildDifficultyLevelButtons(context, responsive, isDark),
            responsive,
          ),
          SizedBox(height: responsive.p24),
          _buildNumberOfQuestionsSection(context, responsive, borderColor),
          SizedBox(height: responsive.p24),
          _buildIncludeWeakTopicsSection(context, responsive, borderColor),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Widget content,
    ResponsiveUtil responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: responsive.p12),
        content,
      ],
    );
  }

  Widget _buildQuizTypeButtons(
    BuildContext context,
    ResponsiveUtil responsive,
    bool isDark,
  ) {
    return Row(
      children: [
        _buildTypeButton(
          context,
          AppLocalizations.of(context).mcq,
          QuizType.mcq,
          responsive,
          flex: 1,
          isDark: isDark,
        ),
        SizedBox(width: responsive.p12),
        _buildTypeButton(
          context,
          AppLocalizations.of(context).trueFalse,
          QuizType.trueFalse,
          responsive,
          isDark: isDark,
          flex: 1,
        ),
        SizedBox(width: responsive.p12),
        _buildTypeButton(
          context,
          AppLocalizations.of(context).shortAnswer,
          QuizType.shortAnswer,
          responsive,
          isDark: isDark,
          flex: 1,
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    String label,
    QuizType type,
    ResponsiveUtil responsive, {
    int flex = 1,
    bool isDark = false,
  }) {
    final isSelected = selectedQuizType == type;

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => onQuizTypeChanged(type),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p12,
            vertical: responsive.p12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.radius14),
            color: isSelected
                ? const Color(0xFF2B7FFF)
                : isDark
                ? const Color(0xFF1E2939)
                : const Color(0xFFF9FAFB),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2B7FFF)
                  : const Color(0xFFD1D5DC),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.p10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyLevelButtons(
    BuildContext context,
    ResponsiveUtil responsive,
    bool isDark,
  ) {
    return Row(
      children: [
        _buildLevelButton(
          context,
          AppLocalizations.of(context).easy,
          DifficultyLevel.easy,
          responsive,
          isGradient: true,
          isDark: isDark,
        ),
        SizedBox(width: responsive.p12),
        _buildLevelButton(
          context,
          AppLocalizations.of(context).medium,
          DifficultyLevel.medium,
          responsive,
          isDark: isDark,
        ),
        SizedBox(width: responsive.p12),
        _buildLevelButton(
          context,
          AppLocalizations.of(context).hard,
          DifficultyLevel.hard,
          responsive,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    String label,
    DifficultyLevel level,
    ResponsiveUtil responsive, {
    bool isGradient = false,
    bool isDark = false,
  }) {
    final isSelected = selectedDifficultyLevel == level;

    return Expanded(
      child: GestureDetector(
        onTap: () => onDifficultyLevelChanged(level),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.p12,
            vertical: responsive.p12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.radius24),
            color: isSelected
                ? const Color(0xFF2B7FFF)
                : isDark
                ? const Color(0xFF1E2939)
                : const Color(0xFFF9FAFB),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2B7FFF)
                  : const Color(0xFFD1D5DC),
              width: 1,
            ),
            gradient: isSelected && isGradient
                ? const LinearGradient(
                    colors: [Color(0xFF51A2FF), Color(0xFF155DFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberOfQuestionsSection(
    BuildContext context,
    ResponsiveUtil responsive,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).numberOfQuestions,
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              numberOfQuestions.toString(),
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF155DFC),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF155DFC),
            inactiveTrackColor: const Color(0xFF155DFC).withOpacity(0.2),
            trackHeight: responsive.p8,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: responsive.p8,
              elevation: responsive.p4,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: responsive.p12,
            ),
          ),
          child: Slider(
            value: numberOfQuestions.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            onChanged: onNumberOfQuestionsChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildIncludeWeakTopicsSection(
    BuildContext context,
    ResponsiveUtil responsive,
    Color borderColor,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.radius14),
        color: const Color(0xFF155DFC).withOpacity(0.2),
        border: Border.all(color: const Color(0xFFD4E5FF), width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onIncludeWeakTopicsChanged(!includeWeakTopics),
            child: Container(
              width: responsive.p20,
              height: responsive.p20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsive.radius4),
                color: includeWeakTopics
                    ? const Color(0xFF155DFC)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xFF155DFC), width: 1.5),
              ),
              child: includeWeakTopics
                  ? Icon(Icons.check, color: Colors.white, size: responsive.p12)
                  : null,
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).includeWeakTopics,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
