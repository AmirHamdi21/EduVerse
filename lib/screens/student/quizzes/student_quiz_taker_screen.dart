import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_cubit.dart';
import 'package:edu_verse/bloc/quiz/student_quiz_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:go_router/go_router.dart';

class StudentQuizTakerScreen extends StatefulWidget {
  const StudentQuizTakerScreen({super.key});

  @override
  State<StudentQuizTakerScreen> createState() => _StudentQuizTakerScreenState();
}

class _StudentQuizTakerScreenState extends State<StudentQuizTakerScreen> {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer(int minutes, DateTime startedAt) {
    if (_countdownTimer != null) return;
    final endTime = startedAt.add(Duration(minutes: minutes));
    _remainingSeconds = endTime.difference(DateTime.now()).inSeconds;
    if (_remainingSeconds <= 0) {
      _autoSubmit();
      return;
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        _countdownTimer?.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    HapticFeedback.heavyImpact();
    context.read<StudentQuizCubit>().submitQuiz();
    context.pushReplacement('/student/quiz-result');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, themeState) {
        final isDark = themeState.isDark;
        final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

        return BlocConsumer<StudentQuizCubit, StudentQuizState>(
          listener: (ctx, state) {
            if (state is StudentQuizResultLoaded) {
              context.pushReplacement('/student/quiz-result');
            }
            if (state is StudentQuizError) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            if (state is StudentQuizActive) {
              if (state.timeLimitMinutes != null && _countdownTimer == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _startTimer(state.timeLimitMinutes!, state.startedAt);
                });
              }
              return state.totalQuestions > 0
                  ? _buildQuizUI(isDark, bg, state, responsive)
                  : Scaffold(
                      backgroundColor: bg,
                      body: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2B7FFF),
                        ),
                      ),
                    );
            }
            if (state is StudentQuizSubmitting) {
              return Scaffold(
                backgroundColor: bg,
                body: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2B7FFF)),
                      SizedBox(height: 16),
                      Text('Submitting quiz...'),
                    ],
                  ),
                ),
              );
            }
            if (state is StudentQuizStarting) {
              return Scaffold(
                backgroundColor: bg,
                body: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2B7FFF)),
                ),
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

  Widget _buildQuizUI(
    bool isDark,
    Color bg,
    StudentQuizActive state,
    ResponsiveUtil responsive,
  ) {
    final q = state.currentQuestion;
    final answer = state.answers[q.id];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(isDark);
      },
      child: Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(isDark, state),
            // ── Progress ────────────────────────────────────────────────
            _buildProgress(isDark, state),
            // ── Question ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsive.p16),
                physics: const BouncingScrollPhysics(),
                child: _buildQuestionCard(isDark, q, answer, state),
              ),
            ),
            // ── Actions ─────────────────────────────────────────────────
            _buildActions(isDark, state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, StudentQuizActive state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2B7FFF), const Color(0xFF155DFC)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showExitDialog(isDark),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Q ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (state.timeLimitMinutes != null) _buildTimerBadge(),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showQuestionNavigator(isDark, state),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBadge() {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final isLow = _remainingSeconds < 120;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLow
            ? const Color(0xFFEF4444).withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: isLow ? const Color(0xFFEF4444) : Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isLow ? const Color(0xFFEF4444) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(bool isDark, StudentQuizActive state) {
    final progress = (state.currentQuestionIndex + 1) / state.totalQuestions;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFE2E8F0),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF2B7FFF)),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    bool isDark,
    QuizQuestionModel q,
    AttemptAnswerModel? answer,
    StudentQuizActive state,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2B7FFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              q.questionType.toJson().replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2B7FFF),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            q.questionText,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Answer area
          _buildAnswerArea(isDark, q, answer),
        ],
      ),
    );
  }

  Widget _buildAnswerArea(
    bool isDark,
    QuizQuestionModel q,
    AttemptAnswerModel? answer,
  ) {
    switch (q.questionType) {
      case QuestionTypeEnum.multipleChoice:
      case QuestionTypeEnum.trueFalse:
        return _buildOptionsArea(isDark, q, answer);
      case QuestionTypeEnum.shortAnswer:
      case QuestionTypeEnum.essay:
        return _buildTextArea(isDark, q, answer);
      case QuestionTypeEnum.matching:
        return _buildMatchingArea(isDark, q, answer);
    }
  }

  /// Matching question UI — mirrors the web's MatchingQuestion.tsx.
  /// Two columns: tap a left item, then tap a right item to pair them.
  Widget _buildMatchingArea(
    bool isDark,
    QuizQuestionModel q,
    AttemptAnswerModel? answer,
  ) {
    // Extract left/right items from matchingPairs
    final leftItems = q.matchingPairs.map((p) => p['left'] ?? '').toList();
    final rightItems = q.matchingPairs.map((p) => p['right'] ?? '').toList();

    // If no matchingPairs, fall back to options
    if (leftItems.isEmpty) {
      return _buildOptionsArea(isDark, q, answer);
    }

    // Current pairs from the answer
    final currentPairs = answer?.matchingAnswers ?? [];

    return _MatchingQuestionWidget(
      isDark: isDark,
      leftItems: leftItems,
      rightItems: rightItems..shuffle(), // Shuffle right side for challenge
      selectedPairs: currentPairs,
      onPairChange: (pairs) {
        context.read<StudentQuizCubit>().submitAnswer(
          q.id,
          matchingAnswers: pairs,
        );
      },
    );
  }

  Widget _buildOptionsArea(
    bool isDark,
    QuizQuestionModel q,
    AttemptAnswerModel? answer,
  ) {
    final options = q.options.isNotEmpty
        ? q.options
        : (q.questionType == QuestionTypeEnum.trueFalse
              ? const <Map<String, dynamic>>[
                  {'text': 'True'},
                  {'text': 'False'},
                ]
              : const <Map<String, dynamic>>[]);

    if (options.isEmpty) {
      return Text(
        'No options available for this question.',
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 13,
        ),
      );
    }

    return Column(
      children: options.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        final optText = opt['text'] ?? opt['label'] ?? 'Option ${idx + 1}';
        final optId = idx.toString();
        final selected = answer?.selectedOption?.trim().toLowerCase();
        final isSelected =
            selected == optId ||
            (q.questionType == QuestionTypeEnum.trueFalse &&
                ((selected == 'true' && optId == '0') ||
                    (selected == 'false' && optId == '1')));

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<StudentQuizCubit>().submitAnswer(
                  q.id,
                  selectedOption: optId,
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B7FFF).withValues(alpha: 0.1)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2B7FFF)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF2B7FFF)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                String.fromCharCode(65 + idx),
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optText.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF2B7FFF)
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B)),
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextArea(
    bool isDark,
    QuizQuestionModel q,
    AttemptAnswerModel? answer,
  ) {
    _answerController.text = answer?.answerText ?? '';
    return TextField(
      controller: _answerController,
      onChanged: (v) =>
          context.read<StudentQuizCubit>().submitAnswer(q.id, text: v),
      maxLines: q.questionType == QuestionTypeEnum.essay ? 8 : 3,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1E293B),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2B7FFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildActions(bool isDark, StudentQuizActive state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (state.canGoPrevious)
            Expanded(
              child: _actionBtn(
                isDark,
                'Previous',
                Icons.arrow_back_rounded,
                () {
                  HapticFeedback.lightImpact();
                  context.read<StudentQuizCubit>().previousQuestion();
                },
                false,
              ),
            ),
          if (state.canGoPrevious) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: state.isLastQuestion
                ? _actionBtn(
                    isDark,
                    'Submit (${state.answeredCount}/${state.totalQuestions})',
                    Icons.check_circle_rounded,
                    () => _showSubmitDialog(isDark, state),
                    true,
                  )
                : _actionBtn(isDark, 'Next', Icons.arrow_forward_rounded, () {
                    HapticFeedback.lightImpact();
                    context.read<StudentQuizCubit>().nextQuestion();
                  }, true),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap,
    bool primary,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  )
                : null,
            color: primary
                ? null
                : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primary
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: primary
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  void _showQuestionNavigator(bool isDark, StudentQuizActive state) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(state.totalQuestions, (i) {
                final isAnswered = state.answers.containsKey(
                  state.questions[i].id,
                );
                final isCurrent = i == state.currentQuestionIndex;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<StudentQuizCubit>().goToQuestion(i);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isCurrent
                          ? const LinearGradient(
                              colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                            )
                          : null,
                      color: isCurrent
                          ? null
                          : (isAnswered
                                ? const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.15)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : const Color(0xFFF1F5F9))),
                      borderRadius: BorderRadius.circular(12),
                      border: isAnswered && !isCurrent
                          ? Border.all(color: const Color(0xFF10B981), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : (isAnswered
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B))),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSubmitDialog(bool isDark, StudentQuizActive state) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Submit Quiz?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Answered: ${state.answeredCount}/${state.totalQuestions}\nUnanswered: ${state.totalQuestions - state.answeredCount}',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StudentQuizCubit>().submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B7FFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Quiz?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Your progress will be saved. You can resume later.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Stay',
              style: TextStyle(color: Color(0xFF2B7FFF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StudentQuizCubit>().saveProgress();
              context.read<StudentQuizCubit>().backToList();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Matching Question Widget ─────────────────────────────────────────────────
// Mirrors the web's MatchingQuestion.tsx — two columns, tap left then right to pair.

const _pairColors = [
  Color(0xFF3B82F6), // Blue
  Color(0xFF10B981), // Green
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Violet
  Color(0xFF06B6D4), // Cyan
];

class _MatchingQuestionWidget extends StatefulWidget {
  final bool isDark;
  final List<String> leftItems;
  final List<String> rightItems;
  final List<Map<String, String>> selectedPairs;
  final ValueChanged<List<Map<String, String>>> onPairChange;

  const _MatchingQuestionWidget({
    required this.isDark,
    required this.leftItems,
    required this.rightItems,
    required this.selectedPairs,
    required this.onPairChange,
  });

  @override
  State<_MatchingQuestionWidget> createState() =>
      _MatchingQuestionWidgetState();
}

class _MatchingQuestionWidgetState extends State<_MatchingQuestionWidget> {
  String? _activeLeft;
  late List<String> _shuffledRight;

  @override
  void initState() {
    super.initState();
    _shuffledRight = List.of(widget.rightItems)..shuffle();
  }

  int? _pairIndexOf(String item) {
    for (var i = 0; i < widget.selectedPairs.length; i++) {
      if (widget.selectedPairs[i]['left'] == item ||
          widget.selectedPairs[i]['right'] == item) {
        return i;
      }
    }
    return null;
  }

  Color? _colorOf(String item) {
    final idx = _pairIndexOf(item);
    return idx != null ? _pairColors[idx % _pairColors.length] : null;
  }

  void _onLeftTap(String item) {
    final existingPair = widget.selectedPairs
        .where((p) => p['left'] == item)
        .firstOrNull;
    if (existingPair != null) {
      widget.onPairChange(
        widget.selectedPairs.where((p) => p['left'] != item).toList(),
      );
      setState(() => _activeLeft = null);
      return;
    }
    setState(() => _activeLeft = _activeLeft == item ? null : item);
  }

  void _onRightTap(String item) {
    if (_activeLeft == null) {
      final existingPair = widget.selectedPairs
          .where((p) => p['right'] == item)
          .firstOrNull;
      if (existingPair != null) {
        widget.onPairChange(
          widget.selectedPairs.where((p) => p['right'] != item).toList(),
        );
      }
      return;
    }

    var updated = List<Map<String, String>>.from(widget.selectedPairs);
    updated.removeWhere((p) => p['right'] == item);
    updated.removeWhere((p) => p['left'] == _activeLeft);
    updated.add({'left': _activeLeft!, 'right': item});
    widget.onPairChange(updated);
    setState(() => _activeLeft = null);
  }

  @override
  Widget build(BuildContext context) {
    final dk = widget.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dk
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dk
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Match from',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dk
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.leftItems.map(
                  (item) => _buildItem(
                    item,
                    true,
                    dk,
                    isActive: _activeLeft == item,
                    pairColor: _colorOf(item),
                    pairIndex: _pairIndexOf(item),
                    onTap: () => _onLeftTap(item),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Match to',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dk
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                ..._shuffledRight.map(
                  (item) => _buildItem(
                    item,
                    false,
                    dk,
                    pairColor: _colorOf(item),
                    pairIndex: _pairIndexOf(item),
                    onTap: () => _onRightTap(item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    String text,
    bool isLeft,
    bool dk, {
    bool isActive = false,
    Color? pairColor,
    int? pairIndex,
    required VoidCallback onTap,
  }) {
    final hasPair = pairColor != null;
    final borderColor =
        pairColor ??
        (isActive
            ? const Color(0xFF3B82F6)
            : (dk
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFCBD5E1)));
    final bgColor = hasPair
        ? pairColor.withValues(alpha: 0.1)
        : isActive
        ? const Color(0xFF3B82F6).withValues(alpha: 0.08)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: hasPair || isActive ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: hasPair
                          ? pairColor
                          : (dk ? Colors.white : const Color(0xFF1E293B)),
                      fontSize: 13,
                      fontWeight: hasPair ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (hasPair && pairIndex != null)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pairColor,
                    ),
                    child: Center(
                      child: Text(
                        '${pairIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
