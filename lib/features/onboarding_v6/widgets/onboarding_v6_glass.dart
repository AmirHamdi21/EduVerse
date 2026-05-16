import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingV6Glass extends StatelessWidget {
  const OnboardingV6Glass({
    super.key,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    this.padding,
    this.blurSigma = 30,
  });

  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 0.5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.30),
                offset: const Offset(0, 1),
                blurRadius: 0,
                spreadRadius: -0.5,
              ),
            ],
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}
