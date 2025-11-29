import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';

class PageDot extends StatelessWidget {
  bool isActive;
  PageDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.onBoardingprimary
            : AppTheme.onBoardingindicator,
        borderRadius: BorderRadius.circular(100),
        boxShadow: isActive
            ? const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
    );
  }
}
