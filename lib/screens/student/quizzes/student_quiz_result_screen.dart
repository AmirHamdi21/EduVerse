import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_cubit.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class StudentQuizResultScreen extends StatelessWidget {
  const StudentQuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, themeState) {
        final isDark = themeState.isDark;
        final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

        return BlocBuilder<StudentQuizCubit, StudentQuizState>(
          builder: (ctx, state) {
            if (state is StudentQuizResultLoaded) {
              return _buildResultUI(context, isDark, bg, state.result);
            }
            if (state is StudentQuizLoading) {
              return Scaffold(
                backgroundColor: bg,
                body: const Center(child: CircularProgressIndicator(color: Color(0xFF2B7FFF))),
              );
            }
            return Scaffold(
              backgroundColor: bg,
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultUI(BuildContext context, bool isDark, Color bg, AttemptResultModel result) {
    final passed = result.passed;
    final gradeColor = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Gradient header
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: passed
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── Header ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<StudentQuizCubit>().backToList();
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            passed ? '🎉 PASSED' : '❌ FAILED',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Score circle ──────────────────────────────────────
                  const SizedBox(height: 30),
                  _ScoreCircle(percentage: result.percentage, passed: passed),
                  const SizedBox(height: 16),
                  Text(
                    result.quizTitle.isNotEmpty ? result.quizTitle : 'Quiz Result',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${result.score.toStringAsFixed(1)} / ${result.maxScore.toStringAsFixed(1)} points',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // ── Stats card ────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                          blurRadius: 20, offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _statBox(isDark, '${result.correctCount}', 'Correct', const Color(0xFF10B981)),
                            const SizedBox(width: 12),
                            _statBox(isDark, '${result.wrongCount}', 'Wrong', const Color(0xFFEF4444)),
                            const SizedBox(width: 12),
                            _statBox(isDark, '${result.skippedCount}', 'Skipped', const Color(0xFFF59E0B)),
                          ],
                        ),
                        if (result.timeTakenMinutes != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_outlined, size: 18,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Text(
                                  'Time taken: ${result.timeTakenMinutes} min',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontSize: 13, fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Actions ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBtn(
                            'Back to Quizzes',
                            Icons.list_rounded,
                            isDark,
                            false,
                            () {
                              context.read<StudentQuizCubit>().backToList();
                              context.pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(bool isDark, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(String label, IconData icon, bool isDark, bool primary, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: primary ? const LinearGradient(colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)]) : null,
            color: primary ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: primary ? null : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(
                color: primary ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                fontSize: 14, fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated circular score indicator.
class _ScoreCircle extends StatelessWidget {
  final double percentage;
  final bool passed;

  const _ScoreCircle({required this.percentage, required this.passed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140, height: 140,
      child: CustomPaint(
        painter: _ScoreCirclePainter(percentage: percentage, passed: passed),
        child: Center(
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double percentage;
  final bool passed;

  _ScoreCirclePainter({required this.percentage, required this.passed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10);

    // Progress
    final sweep = (percentage / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, sweep,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
