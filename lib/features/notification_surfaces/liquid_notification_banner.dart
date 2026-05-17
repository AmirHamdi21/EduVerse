import 'dart:ui';

import 'package:flutter/material.dart';

import '../../generated_l10n/app_localizations.dart';
import '../../models/notifications/notification_model.dart';

class LiquidNotificationBanner extends StatelessWidget {
  const LiquidNotificationBanner({
    super.key,
    required this.notification,
    required this.showPreview,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationModel notification;
  final bool showPreview;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final accent = _accentFor(notification.type);
    final icon = _iconFor(notification.type);
    final title = notification.title.trim().isEmpty
        ? 'EduVerse'
        : notification.title.trim();
    final body = showPreview ? notification.message.trim() : '';

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 9, 12, 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 460),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final easedScale = Curves.easeOutBack.transform(value);
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -22 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * easedScale),
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -80) {
                    onDismiss();
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: isDark
                              ? [
                                  const Color(
                                    0xFF172033,
                                  ).withValues(alpha: 0.88),
                                  const Color(
                                    0xFF050915,
                                  ).withValues(alpha: 0.78),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.86),
                                  const Color(
                                    0xFFEFF6FF,
                                  ).withValues(alpha: 0.62),
                                ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.92),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(
                              alpha: isDark ? 0.36 : 0.24,
                            ),
                            blurRadius: 38,
                            spreadRadius: -14,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.40 : 0.15,
                            ),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          PositionedDirectional(
                            top: -54,
                            end: -36,
                            child: _GlowOrb(color: accent, size: 148),
                          ),
                          PositionedDirectional(
                            bottom: -56,
                            start: 34,
                            child: _GlowOrb(color: accent, size: 112),
                          ),
                          PositionedDirectional(
                            top: 16,
                            bottom: 16,
                            start: 0,
                            child: Container(
                              width: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    accent.withValues(alpha: 0.98),
                                    accent.withValues(alpha: 0.42),
                                    accent.withValues(alpha: 0.08),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              17,
                              14,
                              12,
                              14,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BannerIcon(
                                  accent: accent,
                                  icon: icon,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: _BannerCopy(
                                    accent: accent,
                                    isDark: isDark,
                                    title: title,
                                    body: body,
                                    now: l10n.notificationNow,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _BannerCloseButton(
                                  isDark: isDark,
                                  onPressed: onDismiss,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accentFor(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
      case NotificationType.quiz:
      case NotificationType.lab:
        return const Color(0xFF0A84FF);
      case NotificationType.grade:
        return const Color(0xFF30D158);
      case NotificationType.message:
      case NotificationType.discussion:
      case NotificationType.community:
        return const Color(0xFFBF5AF2);
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
        return const Color(0xFFFF9F0A);
      case NotificationType.system:
      case NotificationType.announcement:
      case NotificationType.material:
      case NotificationType.enrollment:
      case NotificationType.unknown:
        return const Color(0xFF64D2FF);
    }
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
        return Icons.assignment_rounded;
      case NotificationType.quiz:
        return Icons.quiz_rounded;
      case NotificationType.lab:
        return Icons.science_rounded;
      case NotificationType.grade:
        return Icons.auto_graph_rounded;
      case NotificationType.message:
      case NotificationType.discussion:
      case NotificationType.community:
        return Icons.forum_rounded;
      case NotificationType.deadline:
      case NotificationType.schedule:
      case NotificationType.officeHours:
        return Icons.schedule_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.material:
        return Icons.menu_book_rounded;
      case NotificationType.enrollment:
        return Icons.group_add_rounded;
      case NotificationType.system:
      case NotificationType.unknown:
        return Icons.notifications_active_rounded;
    }
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.accent, required this.isDark});

  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.045),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.55), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'EduVerse',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.82)
                    : Colors.black.withValues(alpha: 0.62),
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _BannerCopy extends StatelessWidget {
  const _BannerCopy({
    required this.accent,
    required this.isDark,
    required this.title,
    required this.body,
    required this.now,
  });

  final Color accent;
  final bool isDark;
  final String title;
  final String body;
  final String now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : const Color(0xFF172033).withValues(alpha: 0.62);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: _BrandPill(accent: accent, isDark: isDark),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                now,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mutedColor,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: titleColor,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            fontWeight: FontWeight.w900,
            height: 1.04,
          ),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: mutedColor,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
              fontWeight: FontWeight.w600,
              height: 1.26,
            ),
          ),
        ],
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      accent.withValues(alpha: 0.72),
                      accent.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scaleX: Directionality.of(context) == TextDirection.rtl ? -1 : 1,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: accent.withValues(alpha: isDark ? 0.92 : 0.82),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BannerCloseButton extends StatelessWidget {
  const _BannerCloseButton({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.64),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color: isDark
                ? Colors.white.withValues(alpha: 0.76)
                : Colors.black.withValues(alpha: 0.58),
          ),
        ),
      ),
    );
  }
}

class _BannerIcon extends StatelessWidget {
  const _BannerIcon({
    required this.accent,
    required this.icon,
    required this.isDark,
  });

  final Color accent;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                accent.withValues(alpha: isDark ? 1 : 0.94),
                Color.lerp(
                  accent,
                  Colors.black,
                  isDark ? 0.26 : 0.08,
                )!.withValues(alpha: 0.70),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.38),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
        PositionedDirectional(
          end: -2,
          bottom: -2,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF30D158),
              border: Border.all(
                color: isDark ? const Color(0xFF070B14) : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
