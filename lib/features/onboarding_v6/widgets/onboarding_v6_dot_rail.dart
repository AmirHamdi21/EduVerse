import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class OnboardingV6DotRail extends StatelessWidget {
  const OnboardingV6DotRail({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.onDotPressed,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onDotPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(count, (index) {
        return Padding(
          padding: EdgeInsetsDirectional.only(end: index == count - 1 ? 0 : 6),
          child: _SpringDot(
            key: Key('onboarding-v6-dot-$index'),
            isSelected: index == currentIndex,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            semanticLabel: 'Slide ${index + 1} of $count',
            onTap: () => onDotPressed(index),
          ),
        );
      }),
    );
  }
}

class _SpringDot extends StatefulWidget {
  const _SpringDot({
    super.key,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.semanticLabel,
    required this.onTap,
  });

  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  State<_SpringDot> createState() => _SpringDotState();
}

class _SpringDotState extends State<_SpringDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _targetWidth => widget.isSelected ? 22 : 6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: _targetWidth,
    );
  }

  @override
  void didUpdateWidget(covariant _SpringDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _controller.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 400, damping: 30),
          _controller.value,
          _targetWidth,
          0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: _controller.value.clamp(6, 22),
              height: 6,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.activeColor
                    : widget.inactiveColor,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          },
        ),
      ),
    );
  }
}
