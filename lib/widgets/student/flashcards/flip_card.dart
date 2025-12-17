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
              height: 400,
              decoration: BoxDecoration(
                gradient: !isFront
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                      )
                    : null,
                color: !isFront ? null : surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.card.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arimo',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Click to reveal answer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Arimo',
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    widget.card.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Arimo',
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Click to flip back',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }
}
