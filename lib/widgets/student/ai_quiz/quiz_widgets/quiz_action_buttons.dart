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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLastQuestion)
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  label: AppLocalizations.of(context).skip,
                  onTap: onSkip,
                  isEnabled: true,
                  isPrimary: false,
                  icon: Icons.skip_next,
                  responsive: responsive,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                flex: 2,
                child: _buildButton(
                  label: AppLocalizations.of(context).submitQuiz,
                  onTap: onSubmit,
                  isEnabled: true,
                  isPrimary: true,
                  icon: Icons.check_circle,
                  color: const Color(0xFF10B981),
                  responsive: responsive,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  label: AppLocalizations.of(context).back,
                  onTap: canGoPrevious ? onPrevious : null,
                  isEnabled: canGoPrevious,
                  isPrimary: false,
                  icon: Icons.arrow_back_ios_new,
                  responsive: responsive,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: _buildButton(
                  label: AppLocalizations.of(context).skip,
                  onTap: onSkip,
                  isEnabled: true,
                  isPrimary: false,
                  icon: Icons.skip_next,
                  responsive: responsive,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                flex: 2,
                child: _buildButton(
                  label: AppLocalizations.of(context).next,
                  onTap: canGoNext ? onNext : null,
                  isEnabled: canGoNext,
                  isPrimary: true,
                  icon: Icons.arrow_forward_ios,
                  responsive: responsive,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onTap,
    required bool isEnabled,
    required bool isPrimary,
    required IconData icon,
    required ResponsiveUtil responsive,
    Color? color,
  }) {
    final buttonColor = color ?? const Color(0xFF2B7FFF);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: responsive.p16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary && isEnabled
              ? LinearGradient(
                  colors: [buttonColor, buttonColor.withOpacity(0.8)],
                )
              : null,
          color: isPrimary && isEnabled
              ? null
              : (isPrimary
                    ? (isDark
                          ? const Color(0xFF3A4456)
                          : const Color(0xFFE5E7EB))
                    : (isDark ? const Color(0xFF2D2D44) : Colors.white)),
          border: isPrimary
              ? null
              : Border.all(
                  color: isEnabled
                      ? (isDark
                            ? const Color(0xFF3A4456)
                            : const Color(0xFFE5E7EB))
                      : (isDark
                            ? const Color(0xFF2D2D44)
                            : const Color(0xFFF3F4F6)),
                  width: 2,
                ),
          boxShadow: isPrimary && isEnabled
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon == Icons.arrow_back_ios_new) ...[
              Icon(
                icon,
                color: isPrimary && isEnabled
                    ? Colors.white
                    : (isEnabled
                          ? (isDark ? Colors.white : const Color(0xFF6B7280))
                          : const Color(0xFF9CA3AF)),
                size: 14,
              ),
              // const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary && isEnabled
                    ? Colors.white
                    : (isEnabled
                          ? (isDark ? Colors.white : const Color(0xFF6B7280))
                          : const Color(0xFF9CA3AF)),
                fontFamily: 'Arimo',
              ),
            ),
            if (icon != Icons.arrow_back_ios_new) ...[
              // const SizedBox(width: 8),
              Icon(
                icon,
                color: isPrimary && isEnabled
                    ? Colors.white
                    : (isEnabled
                          ? (isDark ? Colors.white : const Color(0xFF6B7280))
                          : const Color(0xFF9CA3AF)),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
