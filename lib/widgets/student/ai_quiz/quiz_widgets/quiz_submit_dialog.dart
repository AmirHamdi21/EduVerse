import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'dart:math' as math;

class QuizSubmitDialog extends StatefulWidget {
  final int answeredCount;
  final int skippedCount;
  final int totalQuestions;
  final bool isDark;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const QuizSubmitDialog({
    super.key,
    required this.answeredCount,
    required this.skippedCount,
    required this.totalQuestions,
    required this.isDark,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<QuizSubmitDialog> createState() => _QuizSubmitDialogState();
}

class _QuizSubmitDialogState extends State<QuizSubmitDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final unansweredCount = widget.totalQuestions - widget.answeredCount - widget.skippedCount;
    final completionPercentage = (widget.answeredCount / widget.totalQuestions * 100).toInt();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E2D) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with animated progress circle
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: responsive.p32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.15),
                        const Color(0xFF3B82F6).withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Animated circular progress
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background circle
                                CustomPaint(
                                  size: const Size(120, 120),
                                  painter: _CircleProgressPainter(
                                    progress: _progressAnimation.value * (widget.answeredCount / widget.totalQuestions),
                                    backgroundColor: widget.isDark
                                        ? const Color(0xFF3A4456)
                                        : const Color(0xFFE5E7EB),
                                    progressColor: _getProgressColor(completionPercentage),
                                    strokeWidth: 10,
                                  ),
                                ),
                                // Center content
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(completionPercentage * _progressAnimation.value).toInt()}%',
                                      style: TextStyle(
                                        fontSize: responsive.fontSize28,
                                        fontWeight: FontWeight.bold,
                                        color: _getProgressColor(completionPercentage),
                                        fontFamily: 'Arimo',
                                      ),
                                    ),
                                    Text(
                                      'Complete',
                                      style: TextStyle(
                                        fontSize: responsive.fontSize12,
                                        color: widget.isDark
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF6B7280),
                                        fontFamily: 'Arimo',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: responsive.p20),
                      Text(
                        AppLocalizations.of(context).submitQuiz,
                        style: TextStyle(
                          fontSize: responsive.fontSize24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
                          fontFamily: 'Arimo',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ready to see your results?',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          color: widget.isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats section
                Padding(
                  padding: EdgeInsets.all(responsive.p24),
                  child: Column(
                    children: [
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle_rounded,
                              label: 'Answered',
                              count: widget.answeredCount,
                              color: const Color(0xFF10B981),
                              responsive: responsive,
                            ),
                          ),
                          SizedBox(width: responsive.p10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.skip_next_rounded,
                              label: 'Skipped',
                              count: widget.skippedCount,
                              color: const Color(0xFFF59E0B),
                              responsive: responsive,
                            ),
                          ),
                          SizedBox(width: responsive.p10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.help_outline_rounded,
                              label: 'Empty',
                              count: unansweredCount,
                              color: const Color(0xFFEF4444),
                              responsive: responsive,
                            ),
                          ),
                        ],
                      ),

                      // Warning if not all answered
                      if (widget.answeredCount < widget.totalQuestions) ...[
                        SizedBox(height: responsive.p16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.info_rounded,
                                  color: Color(0xFFFF9500),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${widget.totalQuestions - widget.answeredCount} question${(widget.totalQuestions - widget.answeredCount) > 1 ? 's' : ''} not answered yet',
                                  style: TextStyle(
                                    fontSize: responsive.fontSize12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFD97706),
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: responsive.p24),

                      // Action buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? const Color(0xFF252D48)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: widget.isDark
                                        ? const Color(0xFF3A4456)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).cancel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF6B7280),
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.p12),
                          // Submit button
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: widget.onSubmit,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context).submit,
                                      style: TextStyle(
                                        fontSize: responsive.fontSize14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Arimo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required ResponsiveUtil responsive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: responsive.fontSize20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Arimo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B7280),
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
