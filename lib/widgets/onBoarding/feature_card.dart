import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/common/classes/role_feature.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureCard extends StatelessWidget {
  String title;
  Color badgeColor;
  Color borderColor;
  List<Color> gradientColors;
  List<Color> decorGradient;
  List<RoleFeature> features;
  String tagline;
  Color taglineColor;
  FeatureCard({
    super.key,
    required this.title,
    required this.badgeColor,
    required this.borderColor,
    required this.gradientColors,
    required this.decorGradient,
    required this.features,
    required this.tagline,
    required this.taglineColor,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LanguageCubit>().state.languageCode == 'ar';
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final titleColor = isDark ? AppTheme.darkTextPrimary : AppTheme.onBoardingtextDark;
        final featureTextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.onBoardingtextMedium;
        final iconBackgroundColor = isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5);
        final iconBorderColor = isDark ? Colors.white.withOpacity(0.2) : Colors.white;
        final dividerColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.onBoardingdivider;

        return _buildCard(
          context,
          isArabic,
          titleColor,
          featureTextColor,
          iconBackgroundColor,
          iconBorderColor,
          dividerColor,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isArabic,
    Color titleColor,
    Color featureTextColor,
    Color iconBackgroundColor,
    Color iconBorderColor,
    Color dividerColor,
  ) {
    final responsive = context.responsive;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          isArabic
              ? Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: responsive.aspectRatioWidth(80),
                    height: responsive.aspectRatioHeight(80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: decorGradient),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(responsive.radius16),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                  ),
                )
              : Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: responsive.aspectRatioWidth(80),
                    height: responsive.aspectRatioHeight(80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: decorGradient),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(responsive.radius16),
                        bottomLeft: Radius.circular(100),
                      ),
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.all(responsive.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: responsive.aspectRatioWidth(64),
                      height: responsive.aspectRatioHeight(64),
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(responsive.radius12),
                        border: Border.all(color: iconBorderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: responsive.iconLarge,
                        color: AppTheme.onBoardingprimary,
                      ),
                    ),
                    SizedBox(width: responsive.p16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: responsive.fontSize18,
                            color: titleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: responsive.p4),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: responsive.fontSize14,
                              color: badgeColor,
                            ),
                            SizedBox(width: responsive.p4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.poweredByIntelligence2,
                              style: TextStyle(fontSize: responsive.fontSize12, color: badgeColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: responsive.p16),
                ...features.map(
                  (f) => Padding(
                    padding: EdgeInsets.only(bottom: responsive.p8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.emoji, style: TextStyle(fontSize: responsive.fontSize16)),
                        SizedBox(width: responsive.p8),
                        Expanded(
                          child: Text(
                            f.text,
                            style: TextStyle(
                              fontSize: responsive.fontSize14,
                              color: featureTextColor,
                              height: 1.43,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: dividerColor, height: responsive.p24),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: responsive.fontSize12,
                      color: taglineColor,
                    ),
                    SizedBox(width: responsive.p8),
                    Expanded(
                      child: Text(
                        tagline,
                        style: TextStyle(
                          fontSize: responsive.fontSize12,
                          color: taglineColor,
                          fontStyle: FontStyle.italic,
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
