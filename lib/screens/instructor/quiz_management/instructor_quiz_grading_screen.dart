import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';

class InstructorQuizGradingScreen extends StatefulWidget {
  final QuizModel quiz;
  final QuizAttemptModel attempt;
  const InstructorQuizGradingScreen({
    super.key,
    required this.quiz,
    required this.attempt,
  });
  @override
  State<InstructorQuizGradingScreen> createState() => _GradeState();
}

class _GradeState extends State<InstructorQuizGradingScreen> {
  final Map<int, TextEditingController> _gradeControllers = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each answer
    for (final ans in widget.attempt.answers) {
      _gradeControllers[ans.questionId] = TextEditingController(
        text: ans.pointsEarned?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _gradeControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, ts) {
        final dk = ts.isDark;
        return Scaffold(
          backgroundColor: InstructorColors.background(dk),
          body: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: dk
                      ? InstructorColors.darkHeaderGradient
                      : InstructorColors.headerGradient,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _header(dk),
                    Expanded(child: _body(dk)),
                    _bottom(dk),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(bool dk) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => safeBack(context, '/instructor/dashboard'),
            icon: Icon(iosBackIcon(context), color: Colors.white, size: 18),
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
                '${widget.attempt.userName} — Attempt #${widget.attempt.attemptNumber}',
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
  );

  Widget _body(bool dk) {
    final questions = widget.attempt.questions ?? widget.quiz.questions ?? [];
    final answers = widget.attempt.answers;
    if (questions.isEmpty) {
      return Center(
        child: Text(
          'No questions to grade',
          style: TextStyle(color: InstructorColors.textSecondaryColor(dk)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (_, i) {
        final q = questions[i];
        final ans = answers.where((a) => a.questionId == q.id).firstOrNull;
        return _questionGradeCard(dk, q, ans, i);
      },
    );
  }

  Widget _questionGradeCard(
    bool dk,
    QuizQuestionModel q,
    AttemptAnswerModel? ans,
    int idx,
  ) {
    final needsManual =
        q.questionType == QuestionTypeEnum.essay ||
        q.questionType == QuestionTypeEnum.shortAnswer;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
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
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${idx + 1}',
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: InstructorColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.questionType.toJson().replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 10,
                    color: InstructorColors.accent,
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
                  color: InstructorColors.textSecondaryColor(dk),
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
              color: InstructorColors.textPrimaryColor(dk),
            ),
          ),
          const SizedBox(height: 12),
          // Student answer
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
                    color: InstructorColors.textTertiaryColor(dk),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ans?.answerText ?? ans?.selectedOption ?? 'No answer',
                  style: TextStyle(
                    fontSize: 14,
                    color: InstructorColors.textPrimaryColor(dk),
                  ),
                ),
              ],
            ),
          ),
          // Auto-graded result or manual grade input
          if (ans?.isCorrect != null && !needsManual) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  ans!.isCorrect!
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 18,
                  color: ans.isCorrect!
                      ? InstructorColors.success
                      : InstructorColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  ans.isCorrect! ? 'Correct' : 'Incorrect',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ans.isCorrect!
                        ? InstructorColors.success
                        : InstructorColors.error,
                  ),
                ),
                if (ans.pointsEarned != null) ...[
                  const Spacer(),
                  Text(
                    '${ans.pointsEarned} / ${q.points} pts',
                    style: TextStyle(
                      fontSize: 13,
                      color: InstructorColors.textSecondaryColor(dk),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (needsManual) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Points Earned:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: InstructorColors.textSecondaryColor(dk),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _gradeControllers[q.id],
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(dk),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: InstructorColors.textTertiaryColor(dk),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: InstructorColors.borderColor(dk),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: InstructorColors.primary,
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
                    color: InstructorColors.textTertiaryColor(dk),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottom(bool dk) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: InstructorColors.cardColor(dk),
      border: Border(
        top: BorderSide(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
      ),
    ),
    child: ElevatedButton(
      onPressed: _submitting ? null : _submitGrades,
      style: ElevatedButton.styleFrom(
        backgroundColor: InstructorColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _submitting
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
  );

  Future<void> _submitGrades() async {
    setState(() => _submitting = true);
    final grades = <Map<String, dynamic>>[];
    for (final entry in _gradeControllers.entries) {
      final pts = double.tryParse(entry.value.text);
      if (pts != null)
        grades.add({'questionId': entry.key, 'pointsEarned': pts});
    }
    final ok = await context.read<QuizManagementCubit>().gradeAttempt(
      widget.attempt.id,
      grades,
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Grades submitted!'),
            backgroundColor: InstructorColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        safeBack(context, '/instructor/dashboard');
      }
    }
  }
}
