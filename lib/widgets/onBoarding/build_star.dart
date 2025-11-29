import 'package:edu_verse/common/classes/start_data.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';

class BuildStar extends StatelessWidget {
  StarData data;
  BuildStar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: data.left,
      top: data.top,
      child: Opacity(
        opacity: data.opacity,
        child: Container(
          width: data.size,
          height: data.size,
          decoration: BoxDecoration(
            color: AppTheme.onBoardingstarColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
