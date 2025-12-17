import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizGeneratorHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBackPressed;

  const QuizGeneratorHeader({
    super.key,
    required this.isDark,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = isDark
        ? const Color(0xFFB0B3C1)
        : const Color(0xFF6A7282);

    return Padding(
      padding: EdgeInsets.all(responsive.p16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: responsive.p36,
              height: responsive.p36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF3A4456)
                    : const Color(0xFFF0F0F0),
              ),
              child: Icon(
                Icons.arrow_back,
                color: textColor,
                size: responsive.iconSmall,
              ),
            ),
          ),
          SizedBox(width: responsive.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).aiQuizGenerator,
                  style: TextStyle(
                    fontSize: responsive.fontSize24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: responsive.p4),
                Text(
                  AppLocalizations.of(context).createPersonalizedQuizzes,
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : const Color(0xFF101727),
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          ),
        ],
      ),
    );
  }
}
