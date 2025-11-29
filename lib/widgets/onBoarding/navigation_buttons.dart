import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  void Function()? backOnPressed;
  void Function()? nextOnPressed;
  NavigationButtons({super.key, this.backOnPressed, this.nextOnPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (backOnPressed != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: backOnPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              label: const Text(
                'Back',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4C2B7FFF),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: nextOnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              label: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.45,
                ),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
