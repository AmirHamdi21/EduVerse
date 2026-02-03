import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_header.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_question_navigator.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/modern_progress_indicator.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/modern_question_card.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/modern_action_buttons.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_submit_dialog.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_exit_dialog.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final QuizSession quizSession;

  const QuizQuestionsScreen({super.key, required this.quizSession});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  void _animateQuestionChange() {
    _animationController.reset();
    _animationController.forward();
  }

  void _nextQuestion() {
    if (widget.quizSession.canGoNext) {
      HapticFeedback.lightImpact();
      setState(() {
        widget.quizSession.nextQuestion();
      });
      _animateQuestionChange();
    }
  }

  void _previousQuestion() {
    if (widget.quizSession.canGoPrevious) {
      HapticFeedback.lightImpact();
      setState(() {
        widget.quizSession.previousQuestion();
      });
      _animateQuestionChange();
    }
  }

  void _goToQuestion(int index) {
    if (index == widget.quizSession.currentQuestionIndex) return;
    HapticFeedback.lightImpact();
    setState(() {
      widget.quizSession.currentQuestionIndex = index;
    });
    _animateQuestionChange();
  }

  void _submitAnswer(String answerId) {
    setState(() {
      widget.quizSession.submitAnswer(answerId);
    });
  }

  void _submitMultipleAnswers(List<String> answers) {
    setState(() {
      widget.quizSession.submitMultipleAnswers(answers);
    });
  }

  void _skipQuestion() {
    if (widget.quizSession.canGoNext) {
      HapticFeedback.lightImpact();
      setState(() {
        widget.quizSession.skipQuestion();
      });
      _animateQuestionChange();
    }
  }

  void _showQuestionNavigator(bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuizQuestionNavigator(
        questions: widget.quizSession.questions,
        currentIndex: widget.quizSession.currentQuestionIndex,
        isDark: isDark,
        onQuestionSelected: _goToQuestion,
      ),
    );
  }

  void _showSubmitDialog(bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizSubmitDialog(
        answeredCount: widget.quizSession.answeredCount,
        skippedCount: widget.quizSession.skippedCount,
        totalQuestions: widget.quizSession.questions.length,
        isDark: isDark,
        onCancel: () => Navigator.pop(context),
        onSubmit: () {
          Navigator.pop(context);
          context.push('/quiz-result', extra: widget.quizSession);
        },
      ),
    );
  }

  void _showExitDialog(bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => QuizExitDialog(
        isDark: isDark,
        onCancel: () => Navigator.pop(context),
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF121218)
            : const Color(0xFFF5F5F7);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _showExitDialog(isDark);
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: Column(
              children: [
                // Header
                QuizHeader(
                  courseName: widget.quizSession.courseName,
                  currentQuestion: widget.quizSession.currentQuestionIndex + 1,
                  totalQuestions: widget.quizSession.questions.length,
                  isDark: isDark,
                  onClose: () => _showExitDialog(isDark),
                  onQuestionNavigator: () => _showQuestionNavigator(isDark),
                ),
                
                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(responsive.p16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Progress indicator
                        ModernProgressIndicator(
                          currentQuestion: widget.quizSession.currentQuestionIndex + 1,
                          totalQuestions: widget.quizSession.questions.length,
                          answeredCount: widget.quizSession.answeredCount,
                          skippedCount: widget.quizSession.skippedCount,
                          isDark: isDark,
                        ),
                        SizedBox(height: responsive.p16),
                        
                        // Question card with animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ModernQuestionCard(
                              key: ValueKey(widget.quizSession.currentQuestion.id),
                              question: widget.quizSession.currentQuestion,
                              questionNumber: widget.quizSession.currentQuestionIndex + 1,
                              isDark: isDark,
                              onAnswerSelected: _submitAnswer,
                              onMultipleAnswersSelected: _submitMultipleAnswers,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.p24),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                ModernActionButtons(
                  isDark: isDark,
                  canGoPrevious: widget.quizSession.canGoPrevious,
                  canGoNext: widget.quizSession.canGoNext,
                  isLastQuestion: widget.quizSession.isLastQuestion,
                  isCurrentAnswered: widget.quizSession.currentQuestion.isAnswered,
                  onPrevious: _previousQuestion,
                  onNext: _nextQuestion,
                  onSkip: _skipQuestion,
                  onSubmit: () => _showSubmitDialog(isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
