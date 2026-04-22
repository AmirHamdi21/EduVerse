import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../bloc/smart_study/smart_study_state.dart';

class ScheduleTaskCard extends StatelessWidget {
  final ScheduleTask task;
  final bool isDark;
  final VoidCallback onToggleComplete;

  const ScheduleTaskCard({
    super.key,
    required this.task,
    required this.isDark,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDark
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFF10B981).withValues(alpha: 0.05))
            : (isDark ? const Color(0xFF101828) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB)),
          width: task.isCompleted ? 1.5 : 1,
        ),
        boxShadow: task.isCompleted
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTaskDetails(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                _buildCheckbox(),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and badge row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                color: task.isCompleted
                                    ? (isDark
                                          ? const Color(0xFF99A1AF)
                                          : const Color(0xFF4A5565))
                                    : (isDark
                                          ? const Color(0xFFF3F4F6)
                                          : const Color(0xFF101828)),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildTypeBadge(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Time and course row
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: task.isCompleted
                                ? const Color(0xFF10B981)
                                : (isDark
                                      ? const Color(0xFF99A1AF)
                                      : const Color(0xFF4A5565)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatTimeRange(),
                            style: TextStyle(
                              color: task.isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isDark
                                        ? const Color(0xFF99A1AF)
                                        : const Color(0xFF4A5565)),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task.courseName,
                              style: TextStyle(
                                color: _getTypeColor(),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggleComplete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: task.isCompleted
              ? const Color(0xFF10B981)
              : (isDark
                    ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                    : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted
                ? const Color(0xFF10B981)
                : (isDark ? const Color(0xFF364153) : const Color(0xFFD1D5DB)),
            width: 2,
          ),
          boxShadow: task.isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: task.isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  Widget _buildTypeBadge() {
    final color = _getTypeColor();
    final icon = _getTypeIcon();
    final label = _getTypeLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (task.type) {
      case TaskType.lecture:
        return const Color(0xFF2B7FFF);
      case TaskType.quiz:
        return const Color(0xFF8B5CF6);
      case TaskType.flashcards:
        return const Color(0xFF10B981);
      case TaskType.lab:
        return const Color(0xFFEF4444);
      case TaskType.review:
        return const Color(0xFFF59E0B);
      case TaskType.practice:
        return const Color(0xFFEC4899);
    }
  }

  IconData _getTypeIcon() {
    switch (task.type) {
      case TaskType.lecture:
        return Icons.menu_book_rounded;
      case TaskType.quiz:
        return Icons.quiz_outlined;
      case TaskType.flashcards:
        return Icons.style_outlined;
      case TaskType.lab:
        return Icons.science_outlined;
      case TaskType.review:
        return Icons.rate_review_outlined;
      case TaskType.practice:
        return Icons.fitness_center_rounded;
    }
  }

  String _getTypeLabel() {
    switch (task.type) {
      case TaskType.lecture:
        return 'Lecture';
      case TaskType.quiz:
        return 'Quiz';
      case TaskType.flashcards:
        return 'Flashcards';
      case TaskType.lab:
        return 'Lab';
      case TaskType.review:
        return 'Review';
      case TaskType.practice:
        return 'Practice';
    }
  }

  String _formatTimeRange() {
    final startFormat = DateFormat('h:mm a');
    final endFormat = DateFormat('h:mm a');
    return '${startFormat.format(task.startTime)} - ${endFormat.format(task.endTime)}';
  }

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF364153)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildTypeBadge(),
                const Spacer(),
                if (task.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              icon: Icons.school_outlined,
              label: 'Course',
              value: task.courseName,
            ),
            const SizedBox(height: 14),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: DateFormat('EEEE, MMM d').format(task.startTime),
            ),
            const SizedBox(height: 14),
            _buildDetailRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: _formatTimeRange(),
            ),
            const SizedBox(height: 14),
            _buildDetailRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _getDuration(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: task.isCompleted
                        ? 'Mark Incomplete'
                        : 'Mark Complete',
                    icon: task.isCompleted
                        ? Icons.refresh_rounded
                        : Icons.check_rounded,
                    isPrimary: !task.isCompleted,
                    onTap: () {
                      onToggleComplete();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: 'Start Now',
                    icon: Icons.play_arrow_rounded,
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to appropriate screen
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark
                        ? const Color(0xFF364153)
                        : const Color(0xFFE5E7EB),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFF101828)),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF101828)),
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

  String _getDuration() {
    final duration = task.endTime.difference(task.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
