import 'package:flutter/material.dart';

class AnimatedCircularBar extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  final Duration duration;
  final Curve curve;

  const AnimatedCircularBar({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 6,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  @override
  State<AnimatedCircularBar> createState() => _AnimatedCircularBarState();
}

class _AnimatedCircularBarState extends State<AnimatedCircularBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedCircularBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _animationController, curve: widget.curve),
          );
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CircularProgressIndicator(
          value: _animation.value,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
          strokeWidth: widget.minHeight,
        );
      },
    );
  }
}

/// Compact version for inline progress displays
class CompactAnimatedCircularBar extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  final Duration duration;
  final Curve curve;

  const CompactAnimatedCircularBar({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 6,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  @override
  State<CompactAnimatedCircularBar> createState() =>
      _CompactAnimatedCircularBarState();
}

class _CompactAnimatedCircularBarState extends State<CompactAnimatedCircularBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(CompactAnimatedCircularBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _animationController, curve: widget.curve),
          );
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CircularProgressIndicator(
            value: _animation.value,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
            strokeWidth: widget.minHeight,
          ),
        );
      },
    );
  }
}
