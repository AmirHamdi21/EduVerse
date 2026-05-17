import 'package:edu_verse/features/onboarding_v6/onboarding_v6_tokens.dart';
import 'package:flutter/material.dart';

class OnboardingV6SegmentOption<T> {
  const OnboardingV6SegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.key,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Key? key;
}

class OnboardingV6SegmentedControl<T> extends StatefulWidget {
  const OnboardingV6SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.tint,
    required this.tokens,
    required this.onChanged,
  }) : assert(options.length == 2, 'V6 segmented controls use two options.');

  final List<OnboardingV6SegmentOption<T>> options;
  final T value;
  final Color tint;
  final OnboardingV6Tokens tokens;
  final ValueChanged<T> onChanged;

  @override
  State<OnboardingV6SegmentedControl<T>> createState() =>
      _OnboardingV6SegmentedControlState<T>();
}

class _OnboardingV6SegmentedControlState<T>
    extends State<OnboardingV6SegmentedControl<T>> {
  bool _pressed = false;

  int get _selectedIndex =>
      widget.options.indexWhere((option) => option.value == widget.value);

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final selectedIndex = _selectedIndex.clamp(0, widget.options.length - 1);
    final selectedAlignment = selectedIndex == 0
        ? AlignmentDirectional.centerStart.resolve(textDirection)
        : AlignmentDirectional.centerEnd.resolve(textDirection);

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.tokens.segmentTrack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.tokens.segmentBorder, width: 0.5),
        ),
        child: Stack(
          children: <Widget>[
            AnimatedAlign(
              alignment: selectedAlignment,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
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
                        blurRadius: 16,
                        spreadRadius: -6,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.35),
                        offset: const Offset(0, 1),
                        blurRadius: 0,
                        spreadRadius: -0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: widget.options.map((option) {
                final isSelected = option.value == widget.value;
                return Expanded(
                  child: GestureDetector(
                    key: option.key,
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => setState(() => _pressed = true),
                    onTapCancel: () => setState(() => _pressed = false),
                    onTapUp: (_) => setState(() => _pressed = false),
                    onTap: () => widget.onChanged(option.value),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 160),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : widget.tokens.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (option.icon != null) ...<Widget>[
                              Icon(
                                option.icon,
                                size: 15,
                                color: isSelected
                                    ? Colors.white
                                    : widget.tokens.textPrimary,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
