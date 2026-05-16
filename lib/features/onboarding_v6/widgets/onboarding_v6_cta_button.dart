import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingV6CtaButton extends StatefulWidget {
  const OnboardingV6CtaButton({
    super.key,
    required this.label,
    required this.tint,
    required this.isRtl,
    required this.onPressed,
  });

  final String label;
  final Color tint;
  final bool isRtl;
  final VoidCallback onPressed;

  @override
  State<OnboardingV6CtaButton> createState() => _OnboardingV6CtaButtonState();
}

class _OnboardingV6CtaButtonState extends State<OnboardingV6CtaButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        key: const Key('onboarding-v6-cta'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.85 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    widget.tint.withValues(alpha: 0.93),
                    widget.tint,
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: widget.tint.withValues(alpha: 0.66),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.35),
                    offset: const Offset(0, 1),
                    blurRadius: 0,
                    spreadRadius: -0.5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      widget.isRtl ? -1.0 : 1.0,
                      1.0,
                      1.0,
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
