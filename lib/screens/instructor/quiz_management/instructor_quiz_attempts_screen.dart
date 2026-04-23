import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InstructorQuizAttemptsScreen extends StatefulWidget {
  final QuizModel quiz;
  const InstructorQuizAttemptsScreen({super.key, required this.quiz});
  @override
  State<InstructorQuizAttemptsScreen> createState() => _AttState();
}

class _AttState extends State<InstructorQuizAttemptsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizManagementCubit>().loadAttempts(widget.quiz.id);
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
                    Expanded(
                      child:
                          BlocBuilder<QuizManagementCubit, QuizManagementState>(
                            builder: (_, s) {
                              if (s is! QuizMgmtLoaded)
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: InstructorColors.primary,
                                  ),
                                );
                              final loading =
                                  s.loadingAttempts[widget.quiz.id] == true;
                              final attempts =
                                  s.attemptsMap[widget.quiz.id] ?? [];
                              if (loading)
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: InstructorColors.primary,
                                  ),
                                );
                              if (attempts.isEmpty) return _empty(dk);
                              return _list(dk, attempts);
                            },
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

  Widget _header(bool dk) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
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
                'Student Attempts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.quiz.title,
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

  Widget _empty(bool dk) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people_outline_rounded,
          size: 56,
          color: InstructorColors.textTertiaryColor(dk),
        ),
        const SizedBox(height: 16),
        Text(
          'No attempts yet',
          style: TextStyle(
            color: InstructorColors.textSecondaryColor(dk),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _list(bool dk, List<QuizAttemptModel> attempts) => RefreshIndicator(
    onRefresh: () =>
        context.read<QuizManagementCubit>().loadAttempts(widget.quiz.id),
    color: InstructorColors.primary,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: attempts.length,
      itemBuilder: (_, i) => _attemptCard(dk, attempts[i]),
    ),
  );

  Widget _attemptCard(bool dk, QuizAttemptModel att) {
    final statusColor = _sColor(att.status);
    final df = DateFormat('MMM d, yyyy • HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: InstructorColors.borderColor(dk).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dk ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: InstructorColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    att.userName.isNotEmpty
                        ? att.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: InstructorColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      att.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: InstructorColors.textPrimaryColor(dk),
                      ),
                    ),
                    Text(
                      'Attempt #${att.attemptNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: InstructorColors.textTertiaryColor(dk),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  att.status.toJson().replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _stat(
                dk,
                Icons.grade_outlined,
                att.score != null
                    ? '${att.score!.toStringAsFixed(1)} pts'
                    : 'N/A',
                InstructorColors.primary,
              ),
              const SizedBox(width: 16),
              _stat(
                dk,
                Icons.percent_rounded,
                '${att.scorePercentage.toStringAsFixed(0)}%',
                att.scorePercentage >= (widget.quiz.passingScore)
                    ? InstructorColors.success
                    : InstructorColors.error,
              ),
              const SizedBox(width: 16),
              if (att.submittedAt != null)
                _stat(
                  dk,
                  Icons.access_time_rounded,
                  df.format(att.submittedAt!),
                  InstructorColors.textTertiaryColor(dk),
                ),
            ],
          ),
          // Grade button for submitted (not yet graded) attempts
          if (att.status == AttemptStatusEnum.submitted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '/instructor/quiz-grading',
                  extra: {'quiz': widget.quiz, 'attempt': att},
                ),
                icon: const Icon(Icons.grading_rounded, size: 16),
                label: const Text('Grade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: InstructorColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(bool dk, IconData ic, String val, Color c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(ic, size: 14, color: c),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          val,
          style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Color _sColor(AttemptStatusEnum s) {
    switch (s) {
      case AttemptStatusEnum.inProgress:
        return InstructorColors.warning;
      case AttemptStatusEnum.submitted:
        return InstructorColors.info;
      case AttemptStatusEnum.graded:
        return InstructorColors.success;
      case AttemptStatusEnum.abandoned:
        return InstructorColors.error;
    }
  }
}
