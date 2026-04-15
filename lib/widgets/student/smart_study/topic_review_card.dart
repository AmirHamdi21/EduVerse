import 'package:flutter/material.dart';
import '../../../bloc/smart_study/smart_study_state.dart';

class TopicReviewCard extends StatelessWidget {
  final StudyTopic topic;
  final bool isDark;

  const TopicReviewCard({super.key, required this.topic, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          _buildImageSection(),
          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and progress
                _buildTitleSection(context),
                const SizedBox(height: 12),
                // Progress bar
                _buildProgressBar(),
                const SizedBox(height: 12),
                // Status message
                _buildStatusMessage(),
                const SizedBox(height: 8),
                // Recommendation
                _buildRecommendation(),
                const SizedBox(height: 16),
                // Action button
                _buildActionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getTopicGradient(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Pattern overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TopicPatternPainter(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Topic icon
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getTopicIcon(), color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
          // Difficulty badge
          Positioned(
            top: 12,
            right: 12,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getDifficultyIcon(), color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _getDifficultyText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF3F4F6)
                      : const Color(0xFF101828),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2939).withValues(alpha: 0.7)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  topic.courseName,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF4A5565),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildUrgencyBadge(),
      ],
    );
  }

  Widget _buildUrgencyBadge() {
    final color = _getUrgencyColor();

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                _getUrgencyText(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(topic.progressPercent * 100).toInt()}%',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: constraints.maxWidth * topic.progressPercent,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getProgressGradient(),
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    final color = _getStatusColor();

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            topic.statusMessage,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb_outline_rounded,
          size: 16,
          color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            topic.recommendation,
            style: TextStyle(
              color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Starting: ${topic.title}'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getActionIcon(), color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  topic.actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getTopicGradient() {
    switch (topic.status) {
      case TopicStatus.belowAverage:
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case TopicStatus.slightlyBehind:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case TopicStatus.goodProgress:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case TopicStatus.onTrack:
        return [const Color(0xFF2B7FFF), const Color(0xFF155DFC)];
    }
  }

  List<Color> _getProgressGradient() {
    if (topic.progressPercent < 0.4) {
      return [const Color(0xFFEF4444), const Color(0xFFF87171)];
    } else if (topic.progressPercent < 0.7) {
      return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
    } else {
      return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
  }

  Color _getStatusColor() {
    switch (topic.status) {
      case TopicStatus.belowAverage:
        return const Color(0xFFEF4444);
      case TopicStatus.slightlyBehind:
        return const Color(0xFFF59E0B);
      case TopicStatus.goodProgress:
        return const Color(0xFF10B981);
      case TopicStatus.onTrack:
        return const Color(0xFF2B7FFF);
    }
  }

  Color _getUrgencyColor() {
    switch (topic.urgency) {
      case TopicUrgency.high:
        return const Color(0xFFEF4444);
      case TopicUrgency.medium:
        return const Color(0xFFF59E0B);
      case TopicUrgency.low:
        return const Color(0xFF10B981);
      case TopicUrgency.all:
        return const Color(0xFF99A1AF);
    }
  }

  String _getUrgencyText() {
    switch (topic.urgency) {
      case TopicUrgency.high:
        return 'High';
      case TopicUrgency.medium:
        return 'Medium';
      case TopicUrgency.low:
        return 'Low';
      case TopicUrgency.all:
        return '';
    }
  }

  IconData _getTopicIcon() {
    if (topic.title.toLowerCase().contains('neural') ||
        topic.title.toLowerCase().contains('deep learning')) {
      return Icons.psychology_outlined;
    } else if (topic.title.toLowerCase().contains('data') ||
        topic.title.toLowerCase().contains('algorithm')) {
      return Icons.data_array_rounded;
    } else if (topic.title.toLowerCase().contains('machine learning')) {
      return Icons.auto_graph_rounded;
    } else if (topic.title.toLowerCase().contains('database')) {
      return Icons.storage_rounded;
    } else if (topic.title.toLowerCase().contains('web')) {
      return Icons.web_rounded;
    }
    return Icons.school_outlined;
  }

  IconData _getDifficultyIcon() {
    switch (topic.difficulty) {
      case TopicDifficulty.easy:
        return Icons.sentiment_satisfied_alt_rounded;
      case TopicDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case TopicDifficulty.hard:
        return Icons.psychology_alt_rounded;
      case TopicDifficulty.all:
        return Icons.tune_rounded;
    }
  }

  String _getDifficultyText() {
    switch (topic.difficulty) {
      case TopicDifficulty.easy:
        return 'Easy';
      case TopicDifficulty.medium:
        return 'Medium';
      case TopicDifficulty.hard:
        return 'Hard';
      case TopicDifficulty.all:
        return 'All';
    }
  }

  IconData _getActionIcon() {
    if (topic.actionLabel.toLowerCase().contains('review')) {
      return Icons.menu_book_rounded;
    } else if (topic.actionLabel.toLowerCase().contains('quiz')) {
      return Icons.quiz_outlined;
    } else if (topic.actionLabel.toLowerCase().contains('practice')) {
      return Icons.fitness_center_rounded;
    }
    return Icons.play_arrow_rounded;
  }
}

class _TopicPatternPainter extends CustomPainter {
  final Color color;

  _TopicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
