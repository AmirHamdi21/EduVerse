import 'package:flutter/material.dart';

/// Horizontal scrollable row of emoji buttons for quick insertion.
/// Matching website's emoji picker with 8 common emojis.
class SharedEmojiRow extends StatelessWidget {
  /// Callback when an emoji is tapped
  final void Function(String emoji) onEmojiSelected;

  /// Accent color for selection highlight
  final Color accentColor;

  /// Dark mode flag
  final bool isDark;

  /// Standard emoji set matching website implementation
  static const List<String> emojis = [
    '😀',
    '😂',
    '❤️',
    '👍',
    '👎',
    '😢',
    '😮',
    '🔥',
  ];

  const SharedEmojiRow({
    super.key,
    required this.onEmojiSelected,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return _buildEmojiButton(emojis[index]);
        },
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return GestureDetector(
      onTap: () => onEmojiSelected(emoji),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
}
