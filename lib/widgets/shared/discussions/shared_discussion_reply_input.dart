import 'package:flutter/material.dart';

class SharedDiscussionReplyInput extends StatefulWidget {
  final bool isLocked;
  final Color accentColor;
  final Future<bool> Function(String text) onSubmit;

  const SharedDiscussionReplyInput({
    super.key,
    required this.isLocked,
    required this.accentColor,
    required this.onSubmit,
  });

  @override
  State<SharedDiscussionReplyInput> createState() =>
      _SharedDiscussionReplyInputState();
}

class _SharedDiscussionReplyInputState
    extends State<SharedDiscussionReplyInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting || widget.isLocked) {
      return;
    }

    setState(() => _isSubmitting = true);
    final shouldClear = await widget.onSubmit(text);
    if (!mounted) {
      return;
    }

    if (shouldClear) {
      _controller.clear();
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE4E7EC),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'This thread has been locked.',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isLocked && !_isSubmitting,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: widget.isLocked
                        ? 'Replies are disabled for this thread'
                        : 'Write a reply...',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : const Color(0xFFE4E7EC),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : const Color(0xFFE4E7EC),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.isLocked || _isSubmitting
                    ? null
                    : _handleSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
