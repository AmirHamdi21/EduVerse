import 'package:flutter/material.dart';
import '../../../models/quiz/quiz_api_models.dart';

/// A premium quiz card for the student quiz list.
class StudentQuizCard extends StatelessWidget {
  final QuizModel quiz;
  final int remainingAttempts;
  final QuizAttemptModel? inProgressAttempt;
  final bool isDark;
  final VoidCallback onStart;
  final VoidCallback? onResume;
  final VoidCallback? onViewHistory;

  const StudentQuizCard({
    super.key,
    required this.quiz,
    required this.remainingAttempts,
    this.inProgressAttempt,
    required this.isDark,
    required this.onStart,
    this.onResume,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final hasInProgress = inProgressAttempt != null;
    final canStart = remainingAttempts > 0 || hasInProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header gradient ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.courseName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                _buildStatChip(
                  Icons.help_outline_rounded,
                  '${quiz.questionCount} Q',
                ),
                const SizedBox(width: 12),
                if (quiz.timeLimitMinutes != null) ...[
                  _buildStatChip(
                    Icons.timer_outlined,
                    '${quiz.timeLimitMinutes} min',
                  ),
                  const SizedBox(width: 12),
                ],
                _buildStatChip(
                  Icons.refresh_rounded,
                  '$remainingAttempts left',
                ),
              ],
            ),
          ),

          // ── Description ───────────────────────────────────────────────
          if (quiz.description != null && quiz.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                quiz.description!,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── Actions ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildPrimaryButton(canStart, hasInProgress),
                ),
                if (onViewHistory != null) ...[
                  const SizedBox(width: 10),
                  _buildSecondaryButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        quiz.status.toJson().toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(bool canStart, bool hasInProgress) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canStart
            ? (hasInProgress ? onResume : onStart)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: canStart
                ? const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  )
                : null,
            color: canStart
                ? null
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasInProgress
                    ? Icons.play_arrow_rounded
                    : Icons.rocket_launch_rounded,
                color: canStart
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8)),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                hasInProgress
                    ? 'Resume'
                    : (canStart ? 'Start Quiz' : 'No Attempts Left'),
                style: TextStyle(
                  color: canStart
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewHistory,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.history_rounded,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            size: 18,
          ),
        ),
      ),
    );
  }

  List<Color> get _gradientColors {
    switch (quiz.quizType) {
      case QuizTypeEnum.practice:
        return const [Color(0xFF10B981), Color(0xFF059669)];
      case QuizTypeEnum.survey:
        return const [Color(0xFFF59E0B), Color(0xFFD97706)];
      case QuizTypeEnum.graded:
        return const [Color(0xFF2B7FFF), Color(0xFF155DFC)];
    }
  }
}
