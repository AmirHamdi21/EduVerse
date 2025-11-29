import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.onBoardingprimaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x683B82F6),
                      blurRadius: 25,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'EduVerse',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onBoardingtextDark,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 16, color: AppTheme.onBoardingprimary),
            ),
          ),
        ],
      ),
    );
  }
}
