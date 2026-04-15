import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'quiz_question_review_card.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizSession quizSession;
  final Duration? timeTaken;

  const QuizResultScreen({
    super.key,
    required this.quizSession,
    this.timeTaken,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _celebrationController;
  late AnimationController _cardSlideController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _celebrationAnimation;

  bool _showReview = false;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _cardSlideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scoreAnimation =
        Tween<double>(begin: 0, end: widget.quizSession.score / 100).animate(
          CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
        );

    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scoreController.forward();
        _celebrationController.forward();
        _cardSlideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _celebrationController.dispose();
    _cardSlideController.dispose();
    super.dispose();
  }

  String _getPerformanceEmoji() {
    final score = widget.quizSession.score;
    if (score >= 90) return '🏆';
    if (score >= 70) return '🌟';
    if (score >= 50) return '👍';
    return '💪';
  }

  String _getPerformanceMessage(AppLocalizations l10n) {
    final score = widget.quizSession.score;
    if (score >= 90) return 'Outstanding Performance!';
    if (score >= 70) return 'Great Job!';
    if (score >= 50) return 'Good Effort!';
    return 'Keep Practicing!';
  }

  Color _getScoreColor() {
    final score = widget.quizSession.score;
    if (score >= 90) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFF3B82F6);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getRankingBadge() {
    final score = widget.quizSession.score;
    if (score >= 90) return 'Top 5%';
    if (score >= 80) return 'Top 20%';
    if (score >= 70) return 'Top 30%';
    if (score >= 60) return 'Top 50%';
    return 'Keep Going!';
  }

  String _formatTimeTaken() {
    if (widget.timeTaken == null) return '';
    final duration = widget.timeTaken!;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes min ${seconds}s';
    }
    return '${seconds}s';
  }

  int _getAvgTimePerQuestion() {
    if (widget.timeTaken == null) return 0;
    final totalQuestions = widget.quizSession.questions.length;
    if (totalQuestions == 0) return 0;
    return (widget.timeTaken!.inSeconds / totalQuestions).round();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Custom App Bar
                  SliverToBoxAdapter(
                    child: _buildHeader(responsive, isDark, l10n),
                  ),
                  // Score Display
                  SliverToBoxAdapter(
                    child: _buildScoreSection(responsive, isDark, l10n),
                  ),
                  // Stats Cards
                  SliverToBoxAdapter(
                    child: _buildStatsGrid(responsive, isDark),
                  ),
                  // Performance Insights
                  SliverToBoxAdapter(
                    child: _buildPerformanceInsights(responsive, isDark),
                  ),
                  // Action Buttons
                  SliverToBoxAdapter(
                    child: _buildActionButtons(responsive, isDark, l10n),
                  ),
                  // Review Section Toggle
                  SliverToBoxAdapter(
                    child: _buildReviewToggle(responsive, isDark),
                  ),
                  // Review Questions
                  if (_showReview)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p20,
                            vertical: responsive.p8,
                          ),
                          child: QuizQuestionReviewCard(
                            question: widget.quizSession.questions[index],
                            questionNumber: index + 1,
                            isDark: isDark,
                          ),
                        ),
                        childCount: widget.quizSession.questions.length,
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: responsive.p32)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    ResponsiveUtil responsive,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.all(responsive.p20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/ai-quiz-generator'),
            child: Container(
              padding: EdgeInsets.all(responsive.p12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(responsive.radius12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF334155),
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            l10n.quizCompleted,
            style: TextStyle(
              fontSize: responsive.fontSize18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildScoreSection(
    ResponsiveUtil responsive,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final scoreColor = _getScoreColor();

    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: responsive.p20),
          padding: EdgeInsets.all(responsive.p24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF162456).withOpacity(0.3),
                      const Color(0xFF053345).withOpacity(0.3),
                    ]
                  : [const Color(0xFFEFF6FF), const Color(0xFFECFEFF)],
            ),
            borderRadius: BorderRadius.circular(responsive.radius24),
            border: Border.all(
              color: isDark ? const Color(0xFF193CB8) : const Color(0xFFBEDBFF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Circular Score
              SizedBox(
                width: responsive.p160,
                height: responsive.p160,
                child: AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ScoreRingPainter(
                        progress: _scoreAnimation.value,
                        scoreColor: isDark
                            ? const Color(0xFF51A2FF)
                            : const Color(0xFF155DFC),
                        isDark: isDark,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(_scoreAnimation.value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: responsive.fontSize40,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? const Color(0xFF51A2FF)
                                    : const Color(0xFF155DFC),
                              ),
                            ),
                            Text(
                              l10n.yourScore,
                              style: TextStyle(
                                fontSize: responsive.fontSize12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: responsive.p16),
              // Quiz Title
              Text(
                widget.quizSession.courseName,
                style: TextStyle(
                  fontSize: responsive.fontSize20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF3F4F6)
                      : const Color(0xFF101828),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.p12),
              // Time taken and Ranking badge row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Time taken
                  if (widget.timeTaken != null) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF99A1AF)
                          : const Color(0xFF4A5565),
                    ),
                    SizedBox(width: responsive.p4),
                    Text(
                      _formatTimeTaken(),
                      style: TextStyle(
                        fontSize: responsive.fontSize14,
                        color: isDark
                            ? const Color(0xFF99A1AF)
                            : const Color(0xFF4A5565),
                      ),
                    ),
                    SizedBox(width: responsive.p12),
                  ],
                  // Ranking Badge with gradient
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p12,
                      vertical: responsive.p4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9810FA), Color(0xFFE60076)],
                      ),
                      borderRadius: BorderRadius.circular(responsive.radius8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: responsive.p4),
                        Text(
                          _getRankingBadge(),
                          style: TextStyle(
                            fontSize: responsive.fontSize12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.p12),
              // Questions summary text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    color: isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF4A5565),
                  ),
                  children: [
                    const TextSpan(text: 'Great job! You answered '),
                    TextSpan(
                      text:
                          '${widget.quizSession.correctCount} out of ${widget.quizSession.questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF51A2FF)
                            : const Color(0xFF155DFC),
                      ),
                    ),
                    const TextSpan(text: ' questions correctly.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(ResponsiveUtil responsive, bool isDark) {
    final correct = widget.quizSession.correctCount;
    final total = widget.quizSession.questions.length;
    final incorrect =
        total - correct - (total - widget.quizSession.answeredCount);
    final avgTimePerQuestion = _getAvgTimePerQuestion();

    return Padding(
      padding: EdgeInsets.all(responsive.p20),
      child: Column(
        children: [
          // Row 1: Correct and Incorrect
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  responsive,
                  isDark,
                  icon: Icons.check_circle_rounded,
                  label: 'Correct Answers',
                  value: '$correct/$total',
                  color: const Color(0xFF10B981),
                  progress: total > 0 ? correct / total : 0,
                ),
              ),
              SizedBox(width: responsive.p12),
              Expanded(
                child: _buildEnhancedStatCard(
                  responsive,
                  isDark,
                  icon: Icons.cancel_rounded,
                  label: 'Incorrect Answers',
                  value: '$incorrect/$total',
                  color: const Color(0xFFEF4444),
                  progress: total > 0 ? incorrect / total : 0,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          // Row 2: Avg Time per Question
          if (widget.timeTaken != null)
            _buildEnhancedStatCard(
              responsive,
              isDark,
              icon: Icons.timer_outlined,
              label: 'Avg Time / Question',
              value: '${avgTimePerQuestion}s',
              color: const Color(0xFF3B82F6),
              progress: avgTimePerQuestion > 0
                  ? (avgTimePerQuestion / 60).clamp(0.0, 1.0)
                  : 0.4,
              isFullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    ResponsiveUtil responsive,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double progress,
    bool isFullWidth = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.all(responsive.p16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101828) : Colors.white,
                borderRadius: BorderRadius.circular(responsive.radius16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E2939)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(responsive.p10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(
                            responsive.radius12,
                          ),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      SizedBox(width: responsive.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF4A5565),
                              ),
                            ),
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: responsive.fontSize24,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(responsive.radius8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceInsights(ResponsiveUtil responsive, bool isDark) {
    final score = widget.quizSession.score;
    final insights = <Map<String, dynamic>>[];

    if (score >= 80) {
      insights.add({
        'icon': Icons.trending_up_rounded,
        'text': 'Excellent mastery of the topic!',
        'color': const Color(0xFF10B981),
      });
    } else if (score >= 50) {
      insights.add({
        'icon': Icons.lightbulb_outline_rounded,
        'text': 'Review incorrect answers for improvement',
        'color': const Color(0xFFF59E0B),
      });
    } else {
      insights.add({
        'icon': Icons.school_rounded,
        'text': 'Consider reviewing the material again',
        'color': const Color(0xFF3B82F6),
      });
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.p20),
      child: Container(
        padding: EdgeInsets.all(responsive.p16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withOpacity(0.5)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(responsive.radius16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          children: insights.map((insight) {
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.p10),
                  decoration: BoxDecoration(
                    color: (insight['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    color: insight['color'] as Color,
                    size: 22,
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Text(
                    insight['text'] as String,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      color: isDark ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    ResponsiveUtil responsive,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.all(responsive.p20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              responsive,
              isDark,
              icon: Icons.arrow_back_rounded,
              label: l10n.backToQuizScreen,
              isPrimary: false,
              onTap: () => context.push('/ai-quiz-generator'),
            ),
          ),
          SizedBox(width: responsive.p12),
          Expanded(
            child: _buildActionButton(
              responsive,
              isDark,
              icon: Icons.replay_rounded,
              label: l10n.retakeQuiz,
              isPrimary: true,
              onTap: () {
                _resetQuizSession(widget.quizSession);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ResponsiveUtil responsive,
    bool isDark, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius16),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: responsive.p16,
            horizontal: responsive.p12,
          ),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(responsive.radius16),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE2E8F0),
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF334155)),
              ),
              SizedBox(width: responsive.p8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: isPrimary
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF334155)),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewToggle(ResponsiveUtil responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.p20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _showReview = !_showReview),
          borderRadius: BorderRadius.circular(responsive.radius16),
          child: Container(
            padding: EdgeInsets.all(responsive.p16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(responsive.radius16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.p10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.radius12),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 22,
                  ),
                ),
                SizedBox(width: responsive.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Questions',
                        style: TextStyle(
                          fontSize: responsive.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _showReview
                            ? 'Tap to hide'
                            : 'Tap to see all questions',
                        style: TextStyle(
                          fontSize: responsive.fontSize12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _showReview ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetQuizSession(QuizSession quizSession) {
    for (var question in quizSession.questions) {
      question.userAnswer = null;
      question.userAnswers = null;
    }
    quizSession.currentQuestionIndex = 0;
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color scoreColor;
  final bool isDark;

  _ScoreRingPainter({
    required this.progress,
    required this.scoreColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background ring
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring with gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [scoreColor.withOpacity(0.5), scoreColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );

    // End dot
    if (progress > 0.01) {
      final endAngle = -math.pi / 2 + progress * 2 * math.pi;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);

      final dotPaint = Paint()
        ..color = scoreColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);

      // Dot glow
      final glowPaint = Paint()
        ..color = scoreColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scoreColor != scoreColor;
  }
}
