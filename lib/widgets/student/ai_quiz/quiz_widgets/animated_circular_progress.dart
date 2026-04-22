import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class AnimatedCircularProgress extends StatefulWidget {
  final double score;
  final int correctCount;
  final int totalQuestions;
  final bool isDark;

  const AnimatedCircularProgress({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.isDark,
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _scaleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _progressController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final cardColor = widget.isDark ? const Color(0xFF252D48) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.p32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(responsive.radius24),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFF3A4456)
                : const Color(0xFFD1D5DC),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: responsive.p160,
              height: responsive.p160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: responsive.p160,
                    height: responsive.p160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isDark
                            ? const Color(0xFF3A4456)
                            : const Color(0xFFE5E7EB),
                        width: 8,
                      ),
                    ),
                  ),
                  // Animated progress circle
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(responsive.p160, responsive.p160),
                        painter: CircularProgressPainter(
                          progress: _progressAnimation.value,
                          isDark: widget.isDark,
                        ),
                      );
                    },
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Text(
                            '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: responsive.fontSize48,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B7FFF),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: responsive.p8),
                      Text(
                        'Score',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          color: widget.isDark
                              ? const Color(0xFFB0B3C1)
                              : const Color(0xFF6A7282),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.p32),
            Text(
              '${widget.correctCount} out of ${widget.totalQuestions} correct',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                color: textColor,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  CircularProgressPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw progress arc
    final paint = Paint()
      ..color = const Color(0xFF2B7FFF)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startAngle = -90 * (3.14159 / 180); // Start from top
    final sweepAngle = progress * 2 * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
