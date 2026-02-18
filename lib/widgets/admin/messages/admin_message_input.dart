import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminMessageInput extends StatefulWidget {
  final bool isDark;
  final Function(String) onSend;
  final VoidCallback? onAttachFile;
  final VoidCallback? onVoiceMessage;
  final bool isEnabled;

  const AdminMessageInput({
    super.key,
    required this.isDark,
    required this.onSend,
    this.onAttachFile,
    this.onVoiceMessage,
    this.isEnabled = true,
  });

  @override
  State<AdminMessageInput> createState() => _AdminMessageInputState();
}

class _AdminMessageInputState extends State<AdminMessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? AdminColors.darkCard : AdminColors.lightCard,
        border: Border(
          top: BorderSide(
            color: widget.isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.onAttachFile != null)
              IconButton(
                icon: Icon(
                  Icons.attach_file_rounded,
                  color: widget.isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
                ),
                onPressed: widget.isEnabled ? widget.onAttachFile : null,
              ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.isEnabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: widget.isDark ? AdminColors.darkText : AdminColors.lightText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: widget.isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: _hasText
                  ? _buildSendButton()
                  : _buildVoiceButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnabled ? _handleSend : null,
          borderRadius: BorderRadius.circular(24),
          child: const Center(
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnabled ? widget.onVoiceMessage : null,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Icon(
              Icons.mic_rounded,
              color: widget.isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
