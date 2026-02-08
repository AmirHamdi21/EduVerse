import 'package:flutter/material.dart';
import 'grading_theme_colors.dart';

/// Skeleton loading card for submissions
class GradingSkeleton extends StatefulWidget {
  final bool isDark;

  const GradingSkeleton({
    super.key,
    required this.isDark,
  });

  @override
  State<GradingSkeleton> createState() => _GradingSkeletonState();
}

class _GradingSkeletonState extends State<GradingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: GradingColors.cardColor(widget.isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: GradingColors.borderColor(widget.isDark),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.1 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Skeleton header bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getShimmerColor(0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        _buildShimmerCircle(48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShimmerBox(height: 14, width: 140),
                              const SizedBox(height: 6),
                              _buildShimmerBox(height: 12, width: 100),
                            ],
                          ),
                        ),
                        _buildShimmerBox(height: 24, width: 70, radius: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Info bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? GradingColors.darkSurface.withValues(alpha: 0.3)
                            : GradingColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildShimmerBox(height: 12, width: 80),
                          const Spacer(),
                          _buildShimmerBox(height: 12, width: 60),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildShimmerBox(height: 44, radius: 12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildShimmerBox(height: 44, radius: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getShimmerColor(int index) {
    final progress = (_shimmerController.value + index * 0.1) % 1.0;
    final baseColor = widget.isDark
        ? GradingColors.darkSurface
        : GradingColors.surface;
    final highlightColor = widget.isDark
        ? GradingColors.darkBorder
        : GradingColors.divider;
    
    return Color.lerp(baseColor, highlightColor, (progress * 2 - 1).abs())!;
  }

  Widget _buildShimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getShimmerColor(0),
                _getShimmerColor(1),
                _getShimmerColor(2),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2 * _shimmerController.value, 0),
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCircle(double size) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getShimmerColor(0),
                _getShimmerColor(1),
                _getShimmerColor(2),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2 * _shimmerController.value, 0),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Stats skeleton for loading state
class StatsSkeletonDashboard extends StatefulWidget {
  final bool isDark;

  const StatsSkeletonDashboard({
    super.key,
    required this.isDark,
  });

  @override
  State<StatsSkeletonDashboard> createState() => _StatsSkeletonDashboardState();
}

class _StatsSkeletonDashboardState extends State<StatsSkeletonDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getShimmerColor(int index) {
    final progress = (_shimmerController.value + index * 0.1) % 1.0;
    final baseColor = widget.isDark
        ? GradingColors.darkSurface
        : GradingColors.surface;
    final highlightColor = widget.isDark
        ? GradingColors.darkBorder
        : GradingColors.divider;
    
    return Color.lerp(baseColor, highlightColor, (progress * 2 - 1).abs())!;
  }

  Widget _buildShimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getShimmerColor(0),
                _getShimmerColor(1),
                _getShimmerColor(2),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2 * _shimmerController.value, 0),
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GradingColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GradingColors.borderColor(widget.isDark),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(width: 40, height: 40, radius: 12),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(width: 140, height: 14),
                  const SizedBox(height: 6),
                  _buildShimmerBox(width: 100, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildShimmerBox(height: 80, radius: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShimmerBox(height: 80, radius: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShimmerBox(height: 80, radius: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
