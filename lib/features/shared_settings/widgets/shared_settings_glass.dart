import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showSettingsGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool isDark,
  required Color accent,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.48 : 0.24),
    builder: (context) {
      final media = MediaQuery.of(context);
      final sheetWidth = media.size.width > 640 ? 640.0 : media.size.width;
      final maxSheetHeight = media.size.height * 0.92;
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Align(
          alignment: AlignmentDirectional.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SizedBox(
              width: sheetWidth,
              child: SettingsGlassSurface(
                isDark: isDark,
                accent: accent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                padding: EdgeInsetsDirectional.fromSTEB(
                  20,
                  12,
                  20,
                  media.padding.bottom + 20,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: builder(context),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<T?> showSettingsGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool isDark,
  required Color accent,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.55 : 0.26),
    builder: (context) {
      return Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SettingsGlassSurface(
            isDark: isDark,
            accent: accent,
            padding: const EdgeInsetsDirectional.all(22),
            child: builder(context),
          ),
        ),
      );
    },
  );
}

class SettingsGlassSurface extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;

  const SettingsGlassSurface({
    super.key,
    required this.isDark,
    required this.accent,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 22,
  });

  @override
  Widget build(BuildContext context) {
    final base = isDark ? Colors.white : Colors.white;
    final fillAlpha = isDark ? 0.10 : 0.72;
    final borderAlpha = isDark ? 0.18 : 0.76;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                base.withValues(alpha: fillAlpha),
                base.withValues(alpha: isDark ? 0.055 : 0.46),
                accent.withValues(alpha: isDark ? 0.08 : 0.13),
              ],
            ),
            border: Border.all(
              color: base.withValues(alpha: borderAlpha),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.20 : 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SettingsSheetHandle extends StatelessWidget {
  final bool isDark;

  const SettingsSheetHandle({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
