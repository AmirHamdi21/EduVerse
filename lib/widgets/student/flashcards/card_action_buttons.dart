import 'package:flutter/material.dart';

class CardActionButtons extends StatelessWidget {
  final VoidCallback onMarkAsKnown;
  final VoidCallback onReviewLater;
  final VoidCallback onShuffleDeck;
  final bool isDark;

  const CardActionButtons({
    super.key,
    required this.onMarkAsKnown,
    required this.onReviewLater,
    required this.onShuffleDeck,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final buttonBgColor = Color(0xFFFFFFFF).withValues(alpha: 0.1);
    final buttonTextColor = const Color(0xFF2B7FFF);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          label: 'Mark as Known',
          icon: Icons.check_circle_outline,
          onPressed: onMarkAsKnown,
          bgColor: buttonBgColor,
          textColor: buttonTextColor,
        ),
        _buildActionButton(
          label: 'Review Later',
          icon: Icons.refresh_outlined,
          onPressed: onReviewLater,
          bgColor: buttonBgColor,
          textColor: buttonTextColor,
        ),
        _buildActionButton(
          label: 'Shuffle Deck',
          icon: Icons.shuffle,
          onPressed: onShuffleDeck,
          bgColor: buttonBgColor,
          textColor: buttonTextColor,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color bgColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
