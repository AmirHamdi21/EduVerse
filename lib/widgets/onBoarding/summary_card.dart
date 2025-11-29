import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.onBoardingbackgroundLight,
            AppTheme.onBoardingbackgroundCyan,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.onBoardingborderBlue),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.onBoardingtextMedium,
            height: 1.62,
          ),
          children: [
            TextSpan(
              text: 'EduVerse AI',
              style: TextStyle(
                color: AppTheme.onBoardingprimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text:
                  ' connects all roles through one intelligent system — ensuring ',
            ),
            TextSpan(
              text: 'personalized experiences',
              style: TextStyle(
                color: AppTheme.onBoardingcyanLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' for everyone.'),
          ],
        ),
      ),
    );
  }
}
