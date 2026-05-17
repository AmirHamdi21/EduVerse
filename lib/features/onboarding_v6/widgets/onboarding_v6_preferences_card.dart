import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_slide.dart';
import 'package:edu_verse/features/onboarding_v6/onboarding_v6_tokens.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_glass.dart';
import 'package:edu_verse/features/onboarding_v6/widgets/onboarding_v6_segmented_control.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class OnboardingV6PreferencesCard extends StatelessWidget {
  const OnboardingV6PreferencesCard({
    super.key,
    required this.slide,
    required this.tokens,
    required this.l10n,
    required this.locale,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
  });

  final OnboardingV6Slide slide;
  final OnboardingV6Tokens tokens;
  final AppLocalizations l10n;
  final Locale locale;
  final AppThemeMode themeMode;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<AppThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = themeMode == AppThemeMode.dark
        ? AppThemeMode.dark
        : AppThemeMode.light;

    return OnboardingV6Glass(
      borderRadius: BorderRadius.circular(24),
      backgroundColor: tokens.glassBackground,
      borderColor: tokens.glassBorder,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PreferenceGroupHeader(
            icon: CupertinoIcons.globe,
            label: l10n.language.toUpperCase(),
            tokens: tokens,
          ),
          const SizedBox(height: 8),
          OnboardingV6SegmentedControl<String>(
            options: <OnboardingV6SegmentOption<String>>[
              OnboardingV6SegmentOption<String>(
                value: 'en',
                label: l10n.english,
                key: const Key('onboarding-v6-lang-en'),
              ),
              OnboardingV6SegmentOption<String>(
                value: 'ar',
                label: l10n.arabic,
                key: const Key('onboarding-v6-lang-ar'),
              ),
            ],
            value: locale.languageCode == 'ar' ? 'ar' : 'en',
            tint: slide.tint,
            tokens: tokens,
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 16),
          _PreferenceGroupHeader(
            icon: CupertinoIcons.slider_horizontal_3,
            label: l10n.appearance.toUpperCase(),
            tokens: tokens,
          ),
          const SizedBox(height: 8),
          OnboardingV6SegmentedControl<AppThemeMode>(
            options: <OnboardingV6SegmentOption<AppThemeMode>>[
              OnboardingV6SegmentOption<AppThemeMode>(
                value: AppThemeMode.light,
                label: l10n.light,
                icon: CupertinoIcons.sun_max,
                key: const Key('onboarding-v6-theme-light'),
              ),
              OnboardingV6SegmentOption<AppThemeMode>(
                value: AppThemeMode.dark,
                label: l10n.dark,
                icon: CupertinoIcons.moon,
                key: const Key('onboarding-v6-theme-dark'),
              ),
            ],
            value: selectedThemeMode,
            tint: slide.tint,
            tokens: tokens,
            onChanged: onThemeModeChanged,
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Icon(CupertinoIcons.checkmark, color: slide.tint, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.onboardingV6PreferencesInstant,
                  style: TextStyle(
                    color: tokens.textMuted,
                    fontSize: 12,
                    letterSpacing: -0.06,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferenceGroupHeader extends StatelessWidget {
  const _PreferenceGroupHeader({
    required this.icon,
    required this.label,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final OnboardingV6Tokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 15, color: tokens.textMuted),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.32,
            ),
          ),
        ),
      ],
    );
  }
}
