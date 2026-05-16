import 'package:edu_verse/features/onboarding_v6/onboarding_v6_slide.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_tokens.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_glass.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OnboardingV6StoryCard extends StatelessWidget {
  const OnboardingV6StoryCard({
    super.key,
    required this.slide,
    required this.tokens,
    required this.l10n,
  });

  final OnboardingV6Slide slide;
  final OnboardingV6Tokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return OnboardingV6Glass(
      borderRadius: BorderRadius.circular(24),
      backgroundColor: tokens.glassBackground,
      borderColor: tokens.glassBorder,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _IconTile(slide: slide),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  slide.body!(l10n),
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      slide.tag!(l10n),
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.55,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.slide});

  final OnboardingV6Slide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[slide.tint, slide.tint.withValues(alpha: 0.66)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: slide.tint.withValues(alpha: 0.66),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.40),
            offset: const Offset(0, 1),
            blurRadius: 0,
            spreadRadius: -0.5,
          ),
        ],
      ),
      child: Icon(slide.icon, color: Colors.white, size: 20),
    );
  }
}
