import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';

class TAQuizGradingScreen extends StatefulWidget {
  final QuizModel quiz;
  final QuizAttemptModel attempt;
  const TAQuizGradingScreen({
    super.key,
    required this.quiz,
    required this.attempt,
  });
  @override
  State<TAQuizGradingScreen> createState() => _GS();
}

class _GS extends State<TAQuizGradingScreen> {
  final Map<int, TextEditingController> _gc = {};
  bool _sub = false;

  @override
  void initState() {
    super.initState();
    for (final a in widget.attempt.answers) {
      _gc[a.questionId] = TextEditingController(
        text: a.pointsEarned?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _gc.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, ts) {
        final dk = ts.isDark;
        return Scaffold(
          backgroundColor: TAColors.background(dk),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: dk
                      ? TAColors.darkHeaderGradient
                      : TAColors.headerGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () =>
                                  safeBack(context, '/ta/dashboard'),
                              icon: Icon(
                                iosBackIcon(context),
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Grade Attempt',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${widget.attempt.userName} — #${widget.attempt.attemptNumber}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _body(dk)),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      decoration: BoxDecoration(
                        color: TAColors.cardColor(dk),
                        border: Border(
                          top: BorderSide(
                            color: TAColors.borderColor(
                              dk,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _sub ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TAColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: _sub
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Grades',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body(bool dk) {
    final qs = widget.attempt.questions ?? widget.quiz.questions ?? [];
    if (qs.isEmpty) {
      return Center(
        child: Text(
          'No questions',
          style: TextStyle(color: TAColors.textSecondaryColor(dk)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: qs.length,
      itemBuilder: (_, i) {
        final q = qs[i];
        final ans = widget.attempt.answers
            .where((a) => a.questionId == q.id)
            .firstOrNull;
        final manual =
            q.questionType == QuestionTypeEnum.essay ||
            q.questionType == QuestionTypeEnum.shortAnswer;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TAColors.cardColor(dk),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TAColors.borderColor(dk).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: TAColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: TAColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: TAColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      q.questionType.toJson().replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 10,
                        color: TAColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${q.points} pts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TAColors.textSecondaryColor(dk),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                q.questionText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TAColors.textPrimaryColor(dk),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dk
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Answer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TAColors.textTertiaryColor(dk),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ans?.answerText ?? ans?.selectedOption ?? 'No answer',
                      style: TextStyle(
                        fontSize: 14,
                        color: TAColors.textPrimaryColor(dk),
                      ),
                    ),
                  ],
                ),
              ),
              if (ans?.isCorrect != null && !manual) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      ans!.isCorrect!
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 18,
                      color: ans.isCorrect! ? TAColors.success : TAColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ans.isCorrect! ? 'Correct' : 'Incorrect',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ans.isCorrect!
                            ? TAColors.success
                            : TAColors.error,
                      ),
                    ),
                  ],
                ),
              ],
              if (manual) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Points:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TAColors.textSecondaryColor(dk),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _gc[q.id],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(dk),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: TAColors.textTertiaryColor(dk),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TAColors.borderColor(dk),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: TAColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ ${q.points}',
                      style: TextStyle(
                        fontSize: 13,
                        color: TAColors.textTertiaryColor(dk),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    setState(() => _sub = true);
    final grades = <Map<String, dynamic>>[];
    for (final e in _gc.entries) {
      final p = double.tryParse(e.value.text);
      if (p != null) grades.add({'questionId': e.key, 'pointsEarned': p});
    }
    final ok = await context.read<QuizManagementCubit>().gradeAttempt(
      widget.attempt.id,
      grades,
    );
    if (mounted) {
      setState(() => _sub = false);
      if (ok) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Grades submitted!'),
            backgroundColor: TAColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        safeBack(context, '/ta/dashboard');
      }
    }
  }
}
