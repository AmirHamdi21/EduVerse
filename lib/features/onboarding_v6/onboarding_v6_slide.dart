import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

enum OnboardingV6SlideKind { story, preferences }

typedef OnboardingV6TextResolver = String Function(AppLocalizations l10n);

class OnboardingV6Slide {
  const OnboardingV6Slide.story({
    required this.imageAsset,
    required this.icon,
    required this.tint,
    required this.label,
    required this.title,
    required this.body,
    required this.tag,
  }) : kind = OnboardingV6SlideKind.story;

  const OnboardingV6Slide.preferences({
    required this.imageAsset,
    required this.tint,
    required this.label,
    required this.title,
  }) : kind = OnboardingV6SlideKind.preferences,
       icon = CupertinoIcons.settings,
       body = null,
       tag = null;

  final OnboardingV6SlideKind kind;
  final String imageAsset;
  final IconData icon;
  final Color tint;
  final OnboardingV6TextResolver label;
  final OnboardingV6TextResolver title;
  final OnboardingV6TextResolver? body;
  final OnboardingV6TextResolver? tag;

  bool get isPreferences => kind == OnboardingV6SlideKind.preferences;
}

const List<OnboardingV6Slide> onboardingV6Slides = <OnboardingV6Slide>[
  OnboardingV6Slide.story(
    imageAsset: 'assets/images/onboarding_1.jpg',
    icon: CupertinoIcons.headphones,
    tint: Color(0xFF0A84FF),
    label: _audioLabel,
    title: _audioTitle,
    body: _audioBody,
    tag: _audioTag,
  ),
  OnboardingV6Slide.story(
    imageAsset: 'assets/images/onboarding_2.jpg',
    icon: CupertinoIcons.chat_bubble_2_fill,
    tint: Color(0xFF30D158),
    label: _tutorLabel,
    title: _tutorTitle,
    body: _tutorBody,
    tag: _tutorTag,
  ),
  OnboardingV6Slide.story(
    imageAsset: 'assets/images/onboarding_3.jpg',
    icon: CupertinoIcons.sparkles,
    tint: Color(0xFFBF5AF2),
    label: _insightLabel,
    title: _insightTitle,
    body: _insightBody,
    tag: _insightTag,
  ),
  OnboardingV6Slide.preferences(
    imageAsset: 'assets/images/onboarding_4.jpg',
    tint: Color(0xFFFF9F0A),
    label: _preferencesLabel,
    title: _preferencesTitle,
  ),
];

String _audioLabel(AppLocalizations l10n) => l10n.onboardingV6AudioLabel;
String _audioTitle(AppLocalizations l10n) => l10n.onboardingV6AudioTitle;
String _audioBody(AppLocalizations l10n) => l10n.onboardingV6AudioBody;
String _audioTag(AppLocalizations l10n) => l10n.onboardingV6AudioTag;

String _tutorLabel(AppLocalizations l10n) => l10n.onboardingV6TutorLabel;
String _tutorTitle(AppLocalizations l10n) => l10n.onboardingV6TutorTitle;
String _tutorBody(AppLocalizations l10n) => l10n.onboardingV6TutorBody;
String _tutorTag(AppLocalizations l10n) => l10n.onboardingV6TutorTag;

String _insightLabel(AppLocalizations l10n) => l10n.onboardingV6InsightLabel;
String _insightTitle(AppLocalizations l10n) => l10n.onboardingV6InsightTitle;
String _insightBody(AppLocalizations l10n) => l10n.onboardingV6InsightBody;
String _insightTag(AppLocalizations l10n) => l10n.onboardingV6InsightTag;

String _preferencesLabel(AppLocalizations l10n) =>
    l10n.onboardingV6PreferencesLabel;
String _preferencesTitle(AppLocalizations l10n) =>
    l10n.onboardingV6PreferencesTitle;
