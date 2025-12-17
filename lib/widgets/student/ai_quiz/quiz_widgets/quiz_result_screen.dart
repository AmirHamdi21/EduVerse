import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/widgets/common/animated_circular_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import 'quiz_question_review_card.dart';
import 'animated_circular_progress.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizSession quizSession;

  const QuizResultScreen({super.key, required this.quizSession});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFFAFAFA);
        final cardColor = isDark ? const Color(0xFF252D48) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF101828);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.p24),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.white : const Color(0xFF101727),
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      },
                    ),
                    SizedBox(height: responsive.p32),
                    // Celebration icon
                    Container(
                      width: responsive.p80,
                      height: responsive.p80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: responsive.p48,
                      ),
                    ),
                    SizedBox(height: responsive.p24),
                    // Title
                    Text(
                      AppLocalizations.of(context).quizCompleted,
                      style: TextStyle(
                        fontSize: responsive.fontSize28,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: responsive.p12),
                    // Subtitle
                    Text(
                      AppLocalizations.of(context).yourScore,
                      style: TextStyle(
                        fontSize: responsive.fontSize16,
                        color: isDark
                            ? const Color(0xFFB0B3C1)
                            : const Color(0xFF6A7282),
                      ),
                    ),
                    SizedBox(height: responsive.p32),
                    // Animated Score Card with Circular Progress
                    AnimatedCircularProgress(
                      score: widget.quizSession.score,
                      correctCount: widget.quizSession.correctCount,
                      totalQuestions: widget.quizSession.questions.length,
                      isDark: isDark,
                    ),
                    SizedBox(height: responsive.p32),
                    // Performance breakdown
                    _buildPerformanceBreakdown(
                      context,
                      responsive,
                      isDark,
                      cardColor,
                      textColor,
                    ),
                    SizedBox(height: responsive.p32),
                    // Quiz Review Section
                    _buildReviewSection(
                      context,
                      responsive,
                      isDark,
                      cardColor,
                      textColor,
                    ),
                    SizedBox(height: responsive.p32),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context.push('/ai-quiz-generator');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.p16,
                                vertical: responsive.p8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius12,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF3A4456)
                                      : const Color(0xFFD1D5DC),
                                  width: 1,
                                ),
                                color: cardColor,
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context).backToQuizScreen,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: responsive.p12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _resetQuizSession(widget.quizSession);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.p16,
                                vertical: responsive.p16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius12,
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2B7FFF),
                                    Color(0xFF1447E6),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context).retakeQuiz,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.p32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceBreakdown(
    BuildContext context,
    ResponsiveUtil responsive,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(responsive.radius16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A4456) : const Color(0xFFD1D5DC),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Breakdown',
            style: TextStyle(
              fontSize: responsive.fontSize16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: responsive.p16),
          _buildPerformanceMetric(
            responsive,
            isDark,
            textColor,
            'Correct Answers',
            '${widget.quizSession.correctCount}',
            const Color(0xFF51C77A),
          ),
          SizedBox(height: responsive.p12),
          _buildPerformanceMetric(
            responsive,
            isDark,
            textColor,
            'Incorrect Answers',
            '${widget.quizSession.questions.length - widget.quizSession.correctCount}',
            const Color(0xFFFF6B6B),
          ),
          SizedBox(height: responsive.p12),
          _buildPerformanceMetric(
            responsive,
            isDark,
            textColor,
            'Skipped',
            '${widget.quizSession.questions.length - widget.quizSession.answeredCount}',
            const Color(0xFFFFA500),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(
    ResponsiveUtil responsive,
    bool isDark,
    Color textColor,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: responsive.p12,
          height: responsive.p12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: responsive.p12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize14,
              color: isDark ? const Color(0xFFB0B3C1) : const Color(0xFF6A7282),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(
    BuildContext context,
    ResponsiveUtil responsive,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Summary',
          style: TextStyle(
            fontSize: responsive.fontSize18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: responsive.p20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.quizSession.questions.length,
          itemBuilder: (context, index) => QuizQuestionReviewCard(
            question: widget.quizSession.questions[index],
            questionNumber: index + 1,
            isDark: isDark,
          ),
        ),
      ],
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
