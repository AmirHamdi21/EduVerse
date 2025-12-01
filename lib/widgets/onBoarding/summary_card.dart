import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final cardGradient = isDark
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.onBoardingCardBlueDark.withOpacity(0.4),
                  AppTheme.onBoardingCardCyanDark.withOpacity(0.4),
                ],
              )
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.onBoardingbackgroundLight,
                  AppTheme.onBoardingbackgroundCyan,
                ],
              );
        final borderColor = isDark ? AppTheme.onBoardingcyan : AppTheme.onBoardingborderBlue;
        final textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.onBoardingtextMedium;

        return Container(
          padding: EdgeInsets.all(responsive.p20),
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(responsive.radius12),
            border: Border.all(color: borderColor),
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
            text: TextSpan(
              style: TextStyle(
                fontSize: responsive.fontSize14,
                color: textColor,
                height: 1.62,
              ),
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.eduverseAi,
                  style: TextStyle(
                    color: AppTheme.onBoardingprimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: AppLocalizations.of(
                    context,
                  )!.connectAllRolesThroughOneIntelligentSystem,
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.personalizedExperiences,
                  style: TextStyle(
                    color: AppTheme.onBoardingcyanLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: AppLocalizations.of(context)!.forEveryone),
              ],
            ),
          ),
        );
      },
    );
  }
}
