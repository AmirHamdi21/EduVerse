import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class GenerateQuizButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPressed;

  const GenerateQuizButton({
    super.key,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.p16,
          vertical: responsive.p16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.radius16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2B7FFF), Color(0xFF1447E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 0.5],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B7FFF).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: responsive.iconMedium,
            ),
            SizedBox(width: responsive.p8),
            Text(
              AppLocalizations.of(context).generateQuiz,
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
