import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class ExamGeneratorSkeletons extends StatefulWidget {
  const ExamGeneratorSkeletons({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  State<ExamGeneratorSkeletons> createState() => _ExamGeneratorSkeletonsState();
}

class _ExamGeneratorSkeletonsState extends State<ExamGeneratorSkeletons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? InstructorColors.darkSurface
        : const Color(0xFFE8EEF8);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleItemCount = _visibleItemCount(constraints);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeroSkeleton(progress: progress, isDark: isDark),
                _PoolSkeleton(
                  progress: progress,
                  base: base,
                  highlight: highlight,
                  isDark: isDark,
                ),
                _FilterSkeleton(
                  progress: progress,
                  base: base,
                  highlight: highlight,
                  isDark: isDark,
                ),
                ...List.generate(
                  visibleItemCount,
                  (_) => _CardSkeleton(
                    progress: progress,
                    base: base,
                    highlight: highlight,
                    isDark: isDark,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _visibleItemCount(BoxConstraints constraints) {
    if (!constraints.hasBoundedHeight) return widget.itemCount;
    const topChromeHeight = 502.0;
    const rowHeight = 128.0;
    final available = constraints.maxHeight - topChromeHeight;
    if (available <= 0) return 0;
    final maxRows = available ~/ rowHeight;
    if (maxRows <= 0) return 0;
    return widget.itemCount < maxRows ? widget.itemCount : maxRows;
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            InstructorColors.primary.withValues(alpha: isDark ? 0.42 : 0.82),
            InstructorColors.teal.withValues(alpha: isDark ? 0.32 : 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonLine(
                color: Colors.white.withValues(alpha: 0.16),
                highlight: Colors.white.withValues(alpha: 0.32),
                progress: progress,
                width: 42,
                height: 42,
                radius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: _SkeletonLine(
                        color: Colors.white.withValues(alpha: 0.16),
                        highlight: Colors.white.withValues(alpha: 0.34),
                        progress: progress,
                        height: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.88,
                      child: _SkeletonLine(
                        color: Colors.white.withValues(alpha: 0.14),
                        highlight: Colors.white.withValues(alpha: 0.28),
                        progress: progress,
                        height: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 16) / 3;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    3,
                    (_) => SizedBox(
                      width: width,
                      height: 42,
                      child: _SkeletonLine(
                        color: Colors.white.withValues(alpha: 0.15),
                        highlight: Colors.white.withValues(alpha: 0.3),
                        progress: progress,
                        height: 42,
                        radius: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PoolSkeleton extends StatelessWidget {
  const _PoolSkeleton({
    required this.progress,
    required this.base,
    required this.highlight,
    required this.isDark,
  });

  final double progress;
  final Color base;
  final Color highlight;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SkeletonLine(
                color: base,
                highlight: highlight,
                progress: progress,
                width: 40,
                height: 40,
                radius: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _SkeletonLine(
                      color: base,
                      highlight: highlight,
                      progress: progress,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.82,
                      child: _SkeletonLine(
                        color: base,
                        highlight: highlight,
                        progress: progress,
                        height: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 8),
                  child: _SkeletonLine(
                    color: base,
                    highlight: highlight,
                    progress: progress,
                    height: 44,
                    radius: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSkeleton extends StatelessWidget {
  const _FilterSkeleton({
    required this.progress,
    required this.base,
    required this.highlight,
    required this.isDark,
  });

  final double progress;
  final Color base;
  final Color highlight;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 134,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          _SkeletonLine(
            color: base,
            highlight: highlight,
            progress: progress,
            height: 42,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SkeletonLine(
                  color: base,
                  highlight: highlight,
                  progress: progress,
                  height: 44,
                  radius: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SkeletonLine(
                  color: base,
                  highlight: highlight,
                  progress: progress,
                  height: 44,
                  radius: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({
    required this.progress,
    required this.base,
    required this.highlight,
    required this.isDark,
  });

  final double progress;
  final Color base;
  final Color highlight;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            children: [
              const SizedBox(width: 19),
              _SkeletonLine(
                color: base,
                highlight: highlight,
                progress: progress,
                width: 44,
                height: 44,
                radius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonLine(
                      color: base,
                      highlight: highlight,
                      progress: progress,
                      height: 14,
                    ),
                    const SizedBox(height: 12),
                    FractionallySizedBox(
                      widthFactor: 0.72,
                      child: _SkeletonLine(
                        color: base,
                        highlight: highlight,
                        progress: progress,
                        height: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FractionallySizedBox(
                      widthFactor: 0.55,
                      child: _SkeletonLine(
                        color: base,
                        highlight: highlight,
                        progress: progress,
                        height: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: _SkeletonLine(
              color: InstructorColors.primary.withValues(alpha: 0.22),
              highlight: InstructorColors.primaryLight.withValues(alpha: 0.5),
              progress: progress,
              width: 5,
              height: 114,
              radius: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.color,
    required this.highlight,
    required this.height,
    required this.progress,
    this.width,
    this.radius = 12,
  });

  final Color color;
  final Color highlight;
  final double height;
  final double progress;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.4 + progress * 2.8, 0),
          end: Alignment(-0.2 + progress * 2.8, 0),
          colors: [color, highlight, color],
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
