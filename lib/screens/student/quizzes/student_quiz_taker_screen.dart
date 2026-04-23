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
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (ctx, state) {
            if (state is StudentQuizActive) {
              if (state.timeLimitMinutes != null && _countdownTimer == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _startTimer(state.timeLimitMinutes!, state.startedAt);
                });
              }
              return _buildQuizUI(isDark, bg, state, responsive);
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
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
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
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Q ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
              style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
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
              child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20),
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
          Icon(Icons.timer_outlined, color: isLow ? const Color(0xFFEF4444) : Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isLow ? const Color(0xFFEF4444) : Colors.white,
              fontSize: 14, fontWeight: FontWeight.w700,
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
          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
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
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12, offset: const Offset(0, 4),
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
                color: Color(0xFF2B7FFF), fontSize: 10, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            q.questionText,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 16, fontWeight: FontWeight.w600, height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Answer area
          _buildAnswerArea(isDark, q, answer),
        ],
      ),
    );
  }

  Widget _buildAnswerArea(bool isDark, QuizQuestionModel q, AttemptAnswerModel? answer) {
    switch (q.questionType) {
      case QuestionTypeEnum.multipleChoice:
      case QuestionTypeEnum.trueFalse:
        return _buildOptionsArea(isDark, q, answer);
      case QuestionTypeEnum.shortAnswer:
      case QuestionTypeEnum.essay:
        return _buildTextArea(isDark, q, answer);
      case QuestionTypeEnum.matching:
        return _buildOptionsArea(isDark, q, answer);
    }
  }

  Widget _buildOptionsArea(bool isDark, QuizQuestionModel q, AttemptAnswerModel? answer) {
    final options = q.options;
    return Column(
      children: options.asMap().entries.map((entry) {
        final idx = entry.key;
        final opt = entry.value;
        final optText = opt['text'] ?? opt['label'] ?? 'Option ${idx + 1}';
        final optId = (opt['id'] ?? idx).toString();
        final isSelected = answer?.selectedOption == optId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<StudentQuizCubit>().submitAnswer(
                  q.id, selectedOption: optId,
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B7FFF).withValues(alpha: 0.1)
                      : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2B7FFF)
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF2B7FFF)
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                String.fromCharCode(65 + idx),
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontSize: 12, fontWeight: FontWeight.w600,
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
                              : (isDark ? Colors.white : const Color(0xFF1E293B)),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildTextArea(bool isDark, QuizQuestionModel q, AttemptAnswerModel? answer) {
    _answerController.text = answer?.answerText ?? '';
    return TextField(
      controller: _answerController,
      onChanged: (v) => context.read<StudentQuizCubit>().submitAnswer(q.id, text: v),
      maxLines: q.questionType == QuestionTypeEnum.essay ? 8 : 3,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
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
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (state.canGoPrevious)
            Expanded(
              child: _actionBtn(isDark, 'Previous', Icons.arrow_back_rounded, () {
                HapticFeedback.lightImpact();
                context.read<StudentQuizCubit>().previousQuestion();
              }, false),
            ),
          if (state.canGoPrevious) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: state.isLastQuestion
                ? _actionBtn(isDark, 'Submit (${state.answeredCount}/${state.totalQuestions})',
                    Icons.check_circle_rounded, () => _showSubmitDialog(isDark, state), true)
                : _actionBtn(isDark, 'Next', Icons.arrow_forward_rounded, () {
                    HapticFeedback.lightImpact();
                    context.read<StudentQuizCubit>().nextQuestion();
                  }, true),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(bool isDark, String label, IconData icon, VoidCallback onTap, bool primary) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: primary ? const LinearGradient(colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)]) : null,
            color: primary ? null : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primary ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: primary ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    fontSize: 14, fontWeight: FontWeight.w600,
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
            topLeft: Radius.circular(24), topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: List.generate(state.totalQuestions, (i) {
                final isAnswered = state.answers.containsKey(state.questions[i].id);
                final isCurrent = i == state.currentQuestionIndex;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<StudentQuizCubit>().goToQuestion(i);
                  },
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: isCurrent ? const LinearGradient(colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)]) : null,
                      color: isCurrent ? null : (isAnswered ? const Color(0xFF10B981).withValues(alpha: 0.15) : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9))),
                      borderRadius: BorderRadius.circular(12),
                      border: isAnswered && !isCurrent ? Border.all(color: const Color(0xFF10B981), width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : (isAnswered ? const Color(0xFF10B981) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                          fontWeight: FontWeight.w700, fontSize: 14,
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
        title: Text('Submit Quiz?', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B))),
        content: Text(
          'Answered: ${state.answeredCount}/${state.totalQuestions}\nUnanswered: ${state.totalQuestions - state.answeredCount}',
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StudentQuizCubit>().submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B7FFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: Text('Exit Quiz?', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B))),
        content: Text(
          'Your progress will be saved. You can resume later.',
          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay', style: TextStyle(color: Color(0xFF2B7FFF))),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
