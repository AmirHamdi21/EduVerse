import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';
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
    return Row(
      children: [
        if (backOnPressed != null) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: backOnPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
              child: Row(
                textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.back,
                    style: const TextStyle(color: AppTheme.onBoardingprimary),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back, color: AppTheme.onBoardingprimary),
                ],
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
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.next),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
