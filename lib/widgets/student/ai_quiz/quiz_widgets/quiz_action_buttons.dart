import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class QuizActionButtons extends StatelessWidget {
  final bool isDark;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastQuestion;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onSubmit;

  const QuizActionButtons({
    super.key,
    required this.isDark,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLastQuestion,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final borderColor = isDark
        ? const Color(0xFF3A4456)
        : const Color(0xFFD1D5DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLastQuestion)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      border: Border.all(color: borderColor, width: 1),
                      color: isDark ? const Color(0xFF252D48) : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).skip,
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: GestureDetector(
                  onTap: onSubmit,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B7FFF), Color(0xFF1447E6)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).submitQuiz,
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: canGoPrevious ? onPrevious : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      border: Border.all(
                        color: canGoPrevious
                            ? borderColor
                            : borderColor.withOpacity(0.5),
                        width: 1,
                      ),
                      color: isDark ? const Color(0xFF252D48) : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).back,
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: canGoPrevious
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark
                                    ? const Color(0xFF8A8E96)
                                    : const Color(0xFFB0B3C1)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      border: Border.all(color: borderColor, width: 1),
                      color: isDark ? const Color(0xFF252D48) : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).skip,
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: GestureDetector(
                  onTap: canGoNext ? onNext : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p16,
                      vertical: responsive.p12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      gradient: canGoNext
                          ? const LinearGradient(
                              colors: [Color(0xFF2B7FFF), Color(0xFF1447E6)],
                            )
                          : LinearGradient(
                              colors: [
                                const Color(0xFF8A8E96).withOpacity(0.5),
                                const Color(0xFF8A8E96).withOpacity(0.5),
                              ],
                            ),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).next,
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
