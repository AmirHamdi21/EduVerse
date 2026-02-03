import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class ModernActionButtons extends StatelessWidget {
  final bool isDark;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastQuestion;
  final bool isCurrentAnswered;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onSubmit;

  const ModernActionButtons({
    super.key,
    required this.isDark,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLastQuestion,
    required this.isCurrentAnswered,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: isLastQuestion
            ? _buildLastQuestionLayout(context, responsive)
            : _buildNormalLayout(context, responsive),
      ),
    );
  }

  Widget _buildNormalLayout(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        // Previous button
        _buildCircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: canGoPrevious ? () {
            HapticFeedback.lightImpact();
            onPrevious();
          } : null,
          isEnabled: canGoPrevious,
          responsive: responsive,
        ),
        SizedBox(width: responsive.p12),
        
        // Skip button
        Expanded(
          child: _buildSecondaryButton(
            context: context,
            label: AppLocalizations.of(context).skip,
            icon: Icons.skip_next_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              onSkip();
            },
            responsive: responsive,
          ),
        ),
        SizedBox(width: responsive.p12),
        
        // Next button
        Expanded(
          flex: 2,
          child: _buildPrimaryButton(
            context: context,
            label: AppLocalizations.of(context).next,
            icon: Icons.arrow_forward_rounded,
            onTap: canGoNext ? () {
              HapticFeedback.mediumImpact();
              onNext();
            } : null,
            isEnabled: canGoNext,
            color: const Color(0xFF6366F1),
            responsive: responsive,
          ),
        ),
      ],
    );
  }

  Widget _buildLastQuestionLayout(BuildContext context, ResponsiveUtil responsive) {
    return Row(
      children: [
        // Previous button
        _buildCircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: canGoPrevious ? () {
            HapticFeedback.lightImpact();
            onPrevious();
          } : null,
          isEnabled: canGoPrevious,
          responsive: responsive,
        ),
        SizedBox(width: responsive.p12),
        
        // Skip button (smaller)
        _buildSecondaryButton(
          context: context,
          label: AppLocalizations.of(context).skip,
          icon: Icons.skip_next_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            onSkip();
          },
          responsive: responsive,
          isCompact: true,
        ),
        SizedBox(width: responsive.p12),
        
        // Submit button (larger)
        Expanded(
          flex: 3,
          child: _buildPrimaryButton(
            context: context,
            label: AppLocalizations.of(context).submitQuiz,
            icon: Icons.check_circle_rounded,
            onTap: () {
              HapticFeedback.heavyImpact();
              onSubmit();
            },
            isEnabled: true,
            color: const Color(0xFF10B981),
            responsive: responsive,
            isPulsing: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required ResponsiveUtil responsive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isDark
                  ? const Color(0xFF252D48)
                  : const Color(0xFFF3F4F6))
              : (isDark
                  ? const Color(0xFF1E1E2D)
                  : const Color(0xFFFAFAFB)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? (isDark
                    ? const Color(0xFF3A4456)
                    : const Color(0xFFE5E7EB))
                : (isDark
                    ? const Color(0xFF252D48)
                    : const Color(0xFFF3F4F6)),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? (isDark ? Colors.white : const Color(0xFF6B7280))
              : (isDark
                  ? const Color(0xFF3A4456)
                  : const Color(0xFFD1D5DB)),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required ResponsiveUtil responsive,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? responsive.p12 : responsive.p16,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF252D48)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF59E0B).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: const Color(0xFFF59E0B),
              size: 20,
            ),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF59E0B),
                  fontFamily: 'Arimo',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required Color color,
    required ResponsiveUtil responsive,
    bool isPulsing = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled
              ? null
              : (isDark
                  ? const Color(0xFF252D48)
                  : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: FontWeight.bold,
                color: isEnabled
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF)),
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              color: isEnabled
                  ? Colors.white
                  : (isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF)),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
