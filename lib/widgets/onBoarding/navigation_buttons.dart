import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationButtons extends StatelessWidget {
  void Function()? backOnPressed;
  void Function()? nextOnPressed;
  NavigationButtons({super.key, this.backOnPressed, this.nextOnPressed});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LanguageCubit>().state.languageCode == 'ar';
    final l = AppLocalizations.of(context)!;
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final backBorderColor = isDark
            ? Colors.white.withOpacity(0.2)
            : Colors.white30;
        final backBackgroundColor = isDark
            ? Colors.white.withOpacity(0.1)
            : const Color.fromARGB(255, 207, 207, 207).withOpacity(0.2);
        final backTextAndIconColor = isDark
            ? AppTheme.onBoardingcyan
            : AppTheme.onBoardingprimary;

        return Row(
          children: [
            if (backOnPressed != null) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: backOnPressed,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: responsive.p16),
                    side: BorderSide(color: backBorderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    backgroundColor: backBackgroundColor,
                  ),
                  child: Row(
                    textDirection: isArabic
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.back,
                        style: TextStyle(
                          color: backTextAndIconColor,
                          fontSize: responsive.fontSize16,
                        ),
                      ),
                      SizedBox(width: responsive.p8),
                      Icon(
                        Icons.arrow_back,
                        color: backTextAndIconColor,
                        size: responsive.iconMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: responsive.p12),
            ],
            Expanded(
              child: Container(
                height: responsive.buttonHeight,
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
                child: ElevatedButton(
                  onPressed: nextOnPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.next,
                        style: TextStyle(fontSize: responsive.fontSize16),
                      ),
                      SizedBox(width: responsive.p8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: responsive.iconMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
