import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Progress indicator widget for multi-step form
class AddCourseProgressIndicator extends StatelessWidget {
  final bool isDark;
  final int currentStep;
  final ValueChanged<int> onStepTapped;

  const AddCourseProgressIndicator({
    super.key,
    required this.isDark,
    required this.currentStep,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [l10n.details, l10n.staff, l10n.settings];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTapped(index),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: isCompleted || isCurrent
                          ? AdminColors.primaryGradient
                          : null,
                      color: isCompleted || isCurrent
                          ? null
                          : (isDark
                              ? AdminColors.darkSurface
                              : Colors.grey[200]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.white
                                    : AdminColors.getTextSecondaryColor(isDark),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index],
                          style: TextStyle(
                            color: isCurrent
                                ? AdminColors.primary
                                : AdminColors.getTextSecondaryColor(isDark),
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: isCompleted
                              ? AdminColors.primaryGradient
                              : null,
                          color: isCompleted
                              ? null
                              : (isDark
                                  ? AdminColors.darkSurface
                                  : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
