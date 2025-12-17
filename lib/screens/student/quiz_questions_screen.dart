import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/quiz_models.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_question_card.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_progress_bar.dart';
import '../../../widgets/student/ai_quiz/quiz_widgets/quiz_action_buttons.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final QuizSession quizSession;

  const QuizQuestionsScreen({super.key, required this.quizSession});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  late List<String> selectedAnswers;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.quizSession.questions.length, '');

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.forward();
    });
  }

  void _nextQuestion() {
    if (widget.quizSession.canGoNext) {
      _pageController.reset();
      setState(() {
        widget.quizSession.nextQuestion();
      });
      _pageController.forward();
    }
  }

  void _previousQuestion() {
    if (widget.quizSession.canGoPrevious) {
      _pageController.reset();
      setState(() {
        widget.quizSession.previousQuestion();
      });
      _pageController.forward();
    }
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
      _pageController.reset();
      setState(() {
        widget.quizSession.skipQuestion();
      });
      _pageController.forward();
    }
  }

  void _submitQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.submitQuiz),
        content: Text(
          '${AppLocalizations.of(context)!.youAnswered} ${widget.quizSession.answeredCount} questions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/quiz-result', extra: widget.quizSession);
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _pageController.dispose();
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

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Quiz'),
                content: const Text('Are you sure you want to exit the quiz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    backgroundColor: cardColor,
                    elevation: 0,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: responsive.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.quizSession.courseName,
                                style: TextStyle(
                                  fontSize: responsive.fontSize16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                '${AppLocalizations.of(context).question} ${widget.quizSession.currentQuestionIndex + 1} of ${widget.quizSession.questions.length}',
                                style: TextStyle(
                                  fontSize: responsive.fontSize12,
                                  color: isDark
                                      ? const Color(0xFFB0B3C1)
                                      : const Color(0xFF6A7282),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(responsive.p16),
                      child: QuizProgressBar(
                        currentQuestion:
                            widget.quizSession.currentQuestionIndex + 1,
                        totalQuestions: widget.quizSession.questions.length,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  // Question Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                      child: FadeTransition(
                        opacity: _pageAnimation,
                        child: QuizQuestionCard(
                          question: widget.quizSession.currentQuestion,
                          isDark: isDark,
                          onAnswerSelected: _submitAnswer,
                          onMultipleAnswersSelected: _submitMultipleAnswers,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: responsive.p32)),
                  // Action Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                      child: QuizActionButtons(
                        isDark: isDark,
                        canGoPrevious: widget.quizSession.canGoPrevious,
                        canGoNext: widget.quizSession.canGoNext,
                        isLastQuestion: widget.quizSession.isLastQuestion,
                        onPrevious: _previousQuestion,
                        onNext: _nextQuestion,
                        onSkip: _skipQuestion,
                        onSubmit: _submitQuiz,
                      ),
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
}
