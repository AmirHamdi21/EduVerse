import 'package:edu_verse/features/splash_v8/splash_v8_timing.dart';
import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:flutter/material.dart';

class SplashV8Grid extends StatelessWidget {
  const SplashV8Grid({
    super.key,
    required this.animation,
    required this.tokens,
    required this.reduceMotion,
  });

  final Animation<double> animation;
  final SplashV8Tokens tokens;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: tokens.gridOpacity,
              child: CustomPaint(
                painter: _SplashV8GridPainter(
                  progress: reduceMotion ? 1 : animation.value,
                  tokens: tokens,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashV8GridPainter extends CustomPainter {
  const _SplashV8GridPainter({required this.progress, required this.tokens});

  static const List<double> _linePositions = <double>[0.20, 0.45, 0.70, 0.92];

  final double progress;
  final SplashV8Tokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tokens.gridStroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    for (var index = 0; index < _linePositions.length; index += 1) {
      final lineProgress = _lineProgress(index);
      if (lineProgress <= 0) {
        continue;
      }

      final y = size.height * _linePositions[index];
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * lineProgress, y),
        paint,
      );
    }
  }

  double _lineProgress(int index) {
    final startMs = 400 + (index * 150);
    final timelineMs = progress * SplashV8Timing.timelineMs;
    final raw = ((timelineMs - startMs) / 1200).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(raw);
  }

  @override
  bool shouldRepaint(covariant _SplashV8GridPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.tokens != tokens;
  }
}
