import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:edu_verse/features/walkthrough/role_walkthrough_cubit.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalkthroughHost extends StatelessWidget {
  const WalkthroughHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleWalkthroughCubit, RoleWalkthroughState>(
      buildWhen: (previous, current) => previous.isActive != current.isActive,
      builder: (context, state) {
        if (!state.isActive) {
          return child;
        }

        return Stack(
          children: [
            child,
            const Positioned.fill(child: RoleWalkthroughOverlay()),
          ],
        );
      },
    );
  }
}

class InstructorWalkthroughHost extends WalkthroughHost {
  const InstructorWalkthroughHost({super.key, required super.child});
}

class RoleWalkthroughOverlay extends StatefulWidget {
  const RoleWalkthroughOverlay({super.key});

  @override
  State<RoleWalkthroughOverlay> createState() => _RoleWalkthroughOverlayState();
}

class _RoleWalkthroughOverlayState extends State<RoleWalkthroughOverlay> {
  static const Duration _targetWait = Duration(milliseconds: 900);

  String? _signature;
  DateTime _stepShownAt = DateTime.now();
  Timer? _fallbackTimer;

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleWalkthroughCubit, RoleWalkthroughState>(
      builder: (context, state) {
        final step = state.step;
        if (!state.isActive || step == null) {
          _fallbackTimer?.cancel();
          _signature = null;
          return const SizedBox.shrink();
        }

        final signature =
            '${state.segmentIndex}:${state.stepIndex}:${step.targetId}';
        if (_signature != signature) {
          _signature = signature;
          _stepShownAt = DateTime.now();
          _scheduleFallbackRefresh();
        }

        final cubit = context.read<RoleWalkthroughCubit>();
        final rawRect = cubit.targetRect(step.targetId);
        final waitElapsed = DateTime.now().difference(_stepShownAt);
        final shouldWaitForTarget =
            rawRect == null && step.allowFallback && waitElapsed < _targetWait;

        if (shouldWaitForTarget) {
          return const IgnorePointer(child: SizedBox.expand());
        }

        final media = MediaQuery.of(context);
        final targetRect = rawRect == null
            ? null
            : _inflateAndClamp(rawRect, media.size, 10);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final l10n = AppLocalizations.of(context);
        final reduceMotion = media.disableAnimations;

        return Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            opacity: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _OutsideSpotlightBlur(targetRect: targetRect),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _WalkthroughScrimPainter(
                            targetRect: targetRect,
                            shape: step.shape,
                            isDark: isDark,
                            role: state.role,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: _WalkthroughCardLayer(
                    targetRect: targetRect,
                    step: step,
                    state: state,
                    isDark: isDark,
                    l10n: l10n,
                    reduceMotion: reduceMotion,
                    role: state.role,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Rect _inflateAndClamp(Rect rect, Size size, double padding) {
    final inflated = rect.inflate(padding);
    return Rect.fromLTRB(
      inflated.left.clamp(12.0, size.width - 12.0),
      inflated.top.clamp(12.0, size.height - 12.0),
      inflated.right.clamp(12.0, size.width - 12.0),
      inflated.bottom.clamp(12.0, size.height - 12.0),
    );
  }

  void _scheduleFallbackRefresh() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(_targetWait, () {
      if (!mounted) return;
      setState(() {});
    });
  }
}

class _OutsideSpotlightBlur extends StatelessWidget {
  const _OutsideSpotlightBlur({required this.targetRect});

  final Rect? targetRect;

  @override
  Widget build(BuildContext context) {
    if (targetRect == null) {
      return const _BlurRegion();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final rect = targetRect!.intersect(Offset.zero & size);
        if (rect.isEmpty) {
          return const Positioned.fill(child: _BlurRegion());
        }

        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: size.width,
              height: rect.top.clamp(0.0, size.height),
              child: const _BlurRegion(),
            ),
            Positioned(
              left: 0,
              top: rect.bottom.clamp(0.0, size.height),
              width: size.width,
              height: (size.height - rect.bottom).clamp(0.0, size.height),
              child: const _BlurRegion(),
            ),
            Positioned(
              left: 0,
              top: rect.top.clamp(0.0, size.height),
              width: rect.left.clamp(0.0, size.width),
              height: rect.height.clamp(0.0, size.height),
              child: const _BlurRegion(),
            ),
            Positioned(
              left: rect.right.clamp(0.0, size.width),
              top: rect.top.clamp(0.0, size.height),
              width: (size.width - rect.right).clamp(0.0, size.width),
              height: rect.height.clamp(0.0, size.height),
              child: const _BlurRegion(),
            ),
          ],
        );
      },
    );
  }
}

class _BlurRegion extends StatelessWidget {
  const _BlurRegion();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WalkthroughCardLayer extends StatelessWidget {
  const _WalkthroughCardLayer({
    required this.targetRect,
    required this.step,
    required this.state,
    required this.isDark,
    required this.l10n,
    required this.reduceMotion,
    required this.role,
  });

  final Rect? targetRect;
  final WalkthroughStep step;
  final RoleWalkthroughState state;
  final bool isDark;
  final AppLocalizations l10n;
  final bool reduceMotion;
  final WalkthroughRole? role;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cardWidth = math.min(media.size.width - 28, 378.0);
    const cardHeightEstimate = 292.0;
    final top = _cardTop(media.size, cardHeightEstimate);
    final left = _cardLeft(media.size, cardWidth);

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
            ),
          ),
          AnimatedPositioned(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: left,
            top: top,
            width: cardWidth,
            child: _WalkthroughCard(
              step: step,
              state: state,
              isDark: isDark,
              l10n: l10n,
              role: role,
            ),
          ),
        ],
      ),
    );
  }

  double _cardLeft(Size size, double cardWidth) {
    if (targetRect == null) {
      return (size.width - cardWidth) / 2;
    }
    final ideal = targetRect!.center.dx - cardWidth / 2;
    return ideal.clamp(14.0, size.width - cardWidth - 14.0);
  }

  double _cardTop(Size size, double cardHeightEstimate) {
    const edgePadding = 18.0;
    const gap = 24.0;
    if (targetRect == null) {
      return (size.height - cardHeightEstimate) / 2;
    }

    final rect = targetRect!;
    final availableAbove = rect.top - edgePadding - gap;
    final availableBelow = size.height - rect.bottom - edgePadding - gap;
    final fitsAbove = availableAbove >= cardHeightEstimate;
    final fitsBelow = availableBelow >= cardHeightEstimate;

    if (fitsAbove && (!fitsBelow || availableAbove >= availableBelow)) {
      return rect.top - cardHeightEstimate - gap;
    }

    if (fitsBelow) {
      return rect.bottom + gap;
    }

    if (availableAbove > availableBelow) {
      return math.max(edgePadding, rect.top - cardHeightEstimate - gap);
    }

    if (availableBelow > 120) {
      return math.min(
        rect.bottom + gap,
        size.height - cardHeightEstimate - edgePadding,
      );
    }

    final centered = (size.height - cardHeightEstimate) / 2;
    if (Rect.fromLTWH(
      0,
      centered,
      size.width,
      cardHeightEstimate,
    ).overlaps(rect.inflate(gap / 2))) {
      return rect.top > size.height / 2
          ? edgePadding
          : size.height - cardHeightEstimate - edgePadding;
    }
    return centered.clamp(
      edgePadding,
      size.height - cardHeightEstimate - edgePadding,
    );
  }
}

class _WalkthroughCard extends StatelessWidget {
  const _WalkthroughCard({
    required this.step,
    required this.state,
    required this.isDark,
    required this.l10n,
    required this.role,
  });

  final WalkthroughStep step;
  final RoleWalkthroughState state;
  final bool isDark;
  final AppLocalizations l10n;
  final WalkthroughRole? role;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RoleWalkthroughCubit>();
    final colors = _WalkthroughRoleColors.forRole(role);
    final progress = state.totalSteps == 0
        ? 0.0
        : state.globalStepNumber / state.totalSteps;
    final textColor = isDark ? Colors.white : colors.textPrimary;
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : colors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF10203D).withValues(alpha: 0.96),
                  Color.alphaBlend(
                    colors.primary.withValues(alpha: 0.16),
                    const Color(0xFF172A4D),
                  ).withValues(alpha: 0.94),
                ]
              : [
                  Colors.white.withValues(alpha: 0.98),
                  Color.alphaBlend(
                    colors.primary.withValues(alpha: 0.08),
                    const Color(0xFFF8FBFF),
                  ).withValues(alpha: 0.96),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.92),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(step.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.walkthroughProgress(
                          state.globalStepNumber,
                          state.totalSteps,
                        ),
                        style: TextStyle(
                          color: colors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : colors.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => cubit.skip(context),
                  style: TextButton.styleFrom(
                    foregroundColor: mutedColor,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.walkthroughSkip),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              step.title(l10n),
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                height: 1.12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.body(l10n),
              style: TextStyle(
                color: mutedColor,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (!state.isFirstStep)
                  OutlinedButton.icon(
                    onPressed: () => cubit.previous(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(l10n.walkthroughBack),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : colors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (!state.isFirstStep) const Spacer(),
                FilledButton.icon(
                  onPressed: () => cubit.next(context),
                  icon: Icon(
                    state.isLastStep
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    state.isLastStep
                        ? l10n.walkthroughFinish
                        : l10n.walkthroughNext,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughScrimPainter extends CustomPainter {
  const _WalkthroughScrimPainter({
    required this.targetRect,
    required this.shape,
    required this.isDark,
    required this.role,
  });

  final Rect? targetRect;
  final WalkthroughTargetShape shape;
  final bool isDark;
  final WalkthroughRole? role;

  @override
  void paint(Canvas canvas, Size size) {
    final basePath = Path()..addRect(Offset.zero & size);
    if (targetRect != null) {
      if (shape == WalkthroughTargetShape.circle) {
        basePath.addOval(targetRect!);
      } else {
        basePath.addRRect(
          RRect.fromRectAndRadius(targetRect!, const Radius.circular(22)),
        );
      }
      basePath.fillType = PathFillType.evenOdd;
    }

    final scrimPaint = Paint()
      ..color = (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(
        alpha: isDark ? 0.66 : 0.54,
      );
    canvas.drawPath(basePath, scrimPaint);

    if (targetRect == null) return;
    final colors = _WalkthroughRoleColors.forRole(role);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = LinearGradient(
        colors: [colors.primary, colors.accent],
      ).createShader(targetRect!);

    if (shape == WalkthroughTargetShape.circle) {
      canvas.drawOval(targetRect!, glowPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetRect!, const Radius.circular(22)),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WalkthroughScrimPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.shape != shape ||
        oldDelegate.isDark != isDark ||
        oldDelegate.role != role;
  }
}

class _WalkthroughRoleColors {
  const _WalkthroughRoleColors({
    required this.primary,
    required this.accent,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color primary;
  final Color accent;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  static const _WalkthroughRoleColors instructor = _WalkthroughRoleColors(
    primary: InstructorColors.primary,
    accent: InstructorColors.cyan,
    border: InstructorColors.border,
    textPrimary: InstructorColors.textPrimary,
    textSecondary: InstructorColors.textSecondary,
  );

  static const _WalkthroughRoleColors ta = _WalkthroughRoleColors(
    primary: TAColors.primary,
    accent: TAColors.cyan,
    border: TAColors.border,
    textPrimary: TAColors.textPrimary,
    textSecondary: TAColors.textSecondary,
  );

  static _WalkthroughRoleColors forRole(WalkthroughRole? role) {
    return role == WalkthroughRole.ta ? ta : instructor;
  }
}
