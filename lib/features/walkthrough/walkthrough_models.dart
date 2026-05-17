import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum WalkthroughRole { instructor, ta, student }

enum WalkthroughTargetShape { roundedRect, circle }

class WalkthroughStep {
  const WalkthroughStep({
    required this.targetId,
    required this.icon,
    required this.title,
    required this.body,
    this.shape = WalkthroughTargetShape.roundedRect,
    this.allowFallback = true,
  });

  final String targetId;
  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;
  final WalkthroughTargetShape shape;
  final bool allowFallback;
}

class WalkthroughSegment {
  const WalkthroughSegment({
    required this.id,
    required this.route,
    required this.steps,
    this.needsCourse = false,
  });

  final String id;
  final String route;
  final List<WalkthroughStep> steps;
  final bool needsCourse;
}
