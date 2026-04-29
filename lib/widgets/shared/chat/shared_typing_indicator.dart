import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

/// Animated typing indicator showing who is currently typing.
class SharedTypingIndicator extends StatefulWidget {
  final List<String> typingUserNames;
  final Color accentColor;
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
  late final AnimationController _controller;

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildAnimatedDots(),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _buildTypingText(context),
            style: TextStyle(
              fontSize: 12,
              color: widget.isDark ? Colors.grey[300] : Colors.white,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (index) {
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
                  color: widget.accentColor.withValues(
                    alpha: 0.72 + 0.28 * bounce,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _buildTypingText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = widget.typingUserNames.length;
    if (count == 0) {
      return '';
    }
    if (count == 1) {
      return l10n.chatTypingSingle(widget.typingUserNames[0]);
    }
    if (count == 2) {
      return l10n.chatTypingDouble(
        widget.typingUserNames[0],
        widget.typingUserNames[1],
      );
    }
    final others = count - 2;
    return l10n.chatTypingMultiple(
      widget.typingUserNames[0],
      widget.typingUserNames[1],
      others,
    );
  }
}
