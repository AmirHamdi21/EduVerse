import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import 'course_management_colors.dart';

class GradingTab extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const GradingTab({super.key, required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CMColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CMColors.borderColor(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: CMColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.grading_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Grading coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CMColors.text(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This tab will be enabled in the next phase.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CMColors.textSub(isDark), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
