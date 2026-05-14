import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_cubit.dart';
import 'package:edu_verse/bloc/quiz/quiz_management_state.dart';
import 'package:edu_verse/models/quiz/quiz_api_models.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TAQuizAttemptsScreen extends StatefulWidget {
  final QuizModel quiz;
  const TAQuizAttemptsScreen({super.key, required this.quiz});
  @override
  State<TAQuizAttemptsScreen> createState() => _S();
}

class _S extends State<TAQuizAttemptsScreen> {
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                    ),
                    Expanded(
                      child:
                          BlocBuilder<QuizManagementCubit, QuizManagementState>(
                            builder: (_, s) {
                              if (s is! QuizMgmtLoaded) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: TAColors.primary,
                                  ),
                                );
                              }
                              final loading =
                                  s.loadingAttempts[widget.quiz.id] == true;
                              final atts = s.attemptsMap[widget.quiz.id] ?? [];
                              if (loading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: TAColors.primary,
                                  ),
                                );
                              }
                              if (atts.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline_rounded,
                                        size: 56,
                                        color: TAColors.textTertiaryColor(dk),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No attempts yet',
                                        style: TextStyle(
                                          color: TAColors.textSecondaryColor(
                                            dk,
                                          ),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return RefreshIndicator(
                                onRefresh: () => context
                                    .read<QuizManagementCubit>()
                                    .loadAttempts(widget.quiz.id),
                                color: TAColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: atts.length,
                                  itemBuilder: (_, i) => _card(dk, atts[i]),
                                ),
                              );
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

  Widget _card(bool dk, QuizAttemptModel att) {
    final sc = _sC(att.status);
    final df = DateFormat('MMM d, yyyy • HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(dk),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(dk).withValues(alpha: 0.5),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    att.userName.isNotEmpty
                        ? att.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: TAColors.primary,
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
                        color: TAColors.textPrimaryColor(dk),
                      ),
                    ),
                    Text(
                      'Attempt #${att.attemptNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: TAColors.textTertiaryColor(dk),
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
                  color: sc.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  att.status.toJson().replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: sc,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _st(
                dk,
                Icons.grade_outlined,
                att.score != null
                    ? '${att.score!.toStringAsFixed(1)} pts'
                    : 'N/A',
                TAColors.primary,
              ),
              const SizedBox(width: 16),
              _st(
                dk,
                Icons.percent_rounded,
                '${att.scorePercentage.toStringAsFixed(0)}%',
                att.scorePercentage >= widget.quiz.passingScore
                    ? TAColors.success
                    : TAColors.error,
              ),
              const SizedBox(width: 16),
              if (att.submittedAt != null)
                _st(
                  dk,
                  Icons.access_time_rounded,
                  df.format(att.submittedAt!),
                  TAColors.textTertiaryColor(dk),
                ),
            ],
          ),
          if (att.status == AttemptStatusEnum.submitted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '/ta/quiz-grading',
                  extra: {'quiz': widget.quiz, 'attempt': att},
                ),
                icon: const Icon(Icons.grading_rounded, size: 16),
                label: const Text('Grade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TAColors.accent,
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

  Widget _st(bool dk, IconData ic, String val, Color c) => Row(
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

  Color _sC(AttemptStatusEnum s) {
    switch (s) {
      case AttemptStatusEnum.inProgress:
        return TAColors.warning;
      case AttemptStatusEnum.submitted:
        return TAColors.info;
      case AttemptStatusEnum.graded:
        return TAColors.success;
      case AttemptStatusEnum.abandoned:
        return TAColors.error;
    }
  }
}
