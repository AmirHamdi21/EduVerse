import 'package:flutter/material.dart';

/// Animated typing indicator showing who is currently typing.
/// Displays three bouncing dots with user names.
class SharedTypingIndicator extends StatefulWidget {
  /// List of user names currently typing (excludes current user)
  final List<String> typingUserNames;

  /// Accent color for dots
  final Color accentColor;

  /// Dark mode flag
  final bool isDark;

  const SharedTypingIndicator({
    super.key,
    required this.typingUserNames,
    this.accentColor = const Color(0xFF4F46E5),
    this.isDark = false,
  });

  @override
  State<SharedTypingIndicator> createState() => _SharedTypingIndicatorState();
}

class _SharedTypingIndicatorState extends State<SharedTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUserNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedDots(),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _buildTypingText(),
              style: TextStyle(
                fontSize: 12,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.15;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final bounce = (0.5 - (0.5 - value).abs()) * 2;

            return Transform.translate(
              offset: Offset(0, -4 * bounce),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.7 + 0.3 * bounce),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _buildTypingText() {
    final count = widget.typingUserNames.length;
    if (count == 0) return '';
    if (count == 1) return '${widget.typingUserNames[0]} is typing...';
    if (count == 2) {
      return '${widget.typingUserNames[0]} and ${widget.typingUserNames[1]} are typing...';
    }
    // 3 or more
    final others = count - 2;
    return '${widget.typingUserNames[0]}, ${widget.typingUserNames[1]}, and $others ${others == 1 ? 'other' : 'others'} are typing...';
  }
}
