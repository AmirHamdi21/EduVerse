import 'package:flutter/material.dart';
import '../../../models/quiz/quiz_api_models.dart';

/// Shows a list of past quiz attempts with score, date, status badges.
class StudentAttemptHistory extends StatelessWidget {
  final List<QuizAttemptModel> attempts;
  final bool isDark;
  final void Function(int attemptId)? onViewResult;

  const StudentAttemptHistory({
    super.key,
    required this.attempts,
    required this.isDark,
    this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: 48,
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 12),
              Text(
                'No attempts yet',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attempts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final attempt = attempts[index];
        return _buildAttemptTile(attempt);
      },
    );
  }

  Widget _buildAttemptTile(QuizAttemptModel attempt) {
    final statusColor = _statusColor(attempt.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewResult != null ? () => onViewResult!(attempt.id) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Attempt number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#${attempt.attemptNumber}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Attempt ${attempt.attemptNumber}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(attempt.status, statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(attempt.submittedAt ?? attempt.startedAt),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Score
              if (attempt.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.15),
                        statusColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${attempt.scorePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AttemptStatusEnum status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toJson().replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _statusColor(AttemptStatusEnum status) {
    switch (status) {
      case AttemptStatusEnum.inProgress:
        return const Color(0xFFF59E0B);
      case AttemptStatusEnum.submitted:
        return const Color(0xFF3B82F6);
      case AttemptStatusEnum.graded:
        return const Color(0xFF10B981);
      case AttemptStatusEnum.expired:
        return const Color(0xFFEF4444);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
