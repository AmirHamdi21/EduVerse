import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';

class FlipCard extends StatefulWidget {
  final Flashcard card;
  final bool isDark;
  final VoidCallback onFlip;

  const FlipCard({
    super.key,
    required this.card,
    required this.isDark,
    required this.onFlip,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isFlipped = !_isFlipped;
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);

    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Calculate angle (0 to 180 degrees)
          final angle = _controller.value * 180;

          // Determine which side to show based on angle
          final isFront = angle < 90;

          // For front: rotate from 0 to 90
          // For back: rotate from 90 to 0 (reverse)
          final rotationAngle = isFront ? angle : 180 - angle;

          // Create perspective transform
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(rotationAngle * 3.14159265359 / 180);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Container(
              height: 420,
              decoration: BoxDecoration(
                gradient: !isFront
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B7FFF), Color(0xFF1E5FCC)],
                      )
                    : null,
                color: !isFront ? null : surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isFront
                        ? Colors.black.withOpacity(widget.isDark ? 0.3 : 0.08)
                        : const Color(0xFF2B7FFF).withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              // Show front or back based on angle, no mirroring
              child: isFront
                  ? _buildQuestionSide(textColor, secondaryTextColor)
                  : _buildAnswerSide(secondaryTextColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionSide(Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Question badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF1E5FCC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.help_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Question',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Question text
          Text(
            widget.card.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arimo',
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Hint with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2B7FFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: const Color(0xFF2B7FFF),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to reveal answer',
                  style: TextStyle(
                    color: const Color(0xFF2B7FFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSide(Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Answer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Answer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Answer text with scrollable area
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  widget.card.answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Arimo',
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Hint to flip back
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to flip back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
