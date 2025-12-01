import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.onBoardingtextDark;
        final skipColor = isDark ? AppTheme.onBoardingcyan : AppTheme.onBoardingprimary;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.p24, vertical: responsive.p20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: responsive.aspectRatioWidth(40),
                    height: responsive.aspectRatioHeight(40),
                    decoration: BoxDecoration(
                      gradient: AppTheme.onBoardingprimaryGradient,
                      borderRadius: BorderRadius.circular(responsive.radius12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x683B82F6),
                          blurRadius: 25,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.school, color: Colors.white, size: responsive.iconMedium),
                  ),
                  SizedBox(width: responsive.p12),
                  Text(
                    'EduVerse',
                    style: TextStyle(
                      fontSize: responsive.fontSize20,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  AppLocalizations.of(context)!.skip,
                  style: TextStyle(fontSize: responsive.fontSize16, color: skipColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
