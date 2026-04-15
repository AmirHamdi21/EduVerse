import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  final Duration duration;
  final Curve curve;

  const AnimatedProgressBar({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 6,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
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
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                height: widget.minHeight,
                color: widget.backgroundColor,
              ),
              Container(
                height: widget.minHeight,
                width: _animation.value > 0
                    ? _animation.value *
                          (MediaQuery.of(context).size.width - 32)
                    : 0,
                decoration: BoxDecoration(
                  color: widget.valueColor,
                  boxShadow: [
                    BoxShadow(
                      color: widget.valueColor.withOpacity(0.6),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact version for inline progress displays
class CompactAnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  final Duration duration;
  final Curve curve;

  const CompactAnimatedProgressBar({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 6,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  @override
  State<CompactAnimatedProgressBar> createState() =>
      _CompactAnimatedProgressBarState();
}

class _CompactAnimatedProgressBarState extends State<CompactAnimatedProgressBar>
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
  void didUpdateWidget(CompactAnimatedProgressBar oldWidget) {
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
          child: LinearProgressIndicator(
            value: _animation.value,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
            minHeight: widget.minHeight,
          ),
        );
      },
    );
  }
}
