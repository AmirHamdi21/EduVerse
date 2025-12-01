import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoCard extends StatelessWidget {
  String text;
  InfoCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final cardColor = isDark ? Color(0xFF1A2847) : const Color(0xCCEFF6FF);
        final borderColor = isDark ? AppTheme.onBoardingcyan : AppTheme.onBoardingborderBlue;
        final textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.onBoardingtextMedium;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.p16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(responsive.radius12),
            border: Border.all(color: borderColor, width: 1.01),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: responsive.aspectRatioWidth(40),
                height: responsive.aspectRatioHeight(40),
                decoration: const BoxDecoration(
                  gradient: AppTheme.iconGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: responsive.iconSmall,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: responsive.fontSize14,
                    height: 1.62,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
