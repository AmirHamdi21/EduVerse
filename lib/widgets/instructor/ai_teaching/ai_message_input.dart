import 'package:flutter/material.dart';
import 'ai_teaching_colors.dart';

/// Message input widget for AI chat
class AIMessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;
  final bool isDark;
  final bool isLoading;
  final String hintText;

  const AIMessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachment,
    this.onVoice,
    required this.isDark,
    this.isLoading = false,
    this.hintText = 'Ask AI anything...',
  });

  @override
  State<AIMessageInput> createState() => _AIMessageInputState();
}

class _AIMessageInputState extends State<AIMessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AITeachingColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: AITeachingColors.borderColor(widget.isDark),
          ),
        ),
        boxShadow: widget.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          _buildIconButton(
            icon: Icons.attach_file_rounded,
            onTap: widget.onAttachment,
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AITeachingColors.darkSurface
                    : AITeachingColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AITeachingColors.borderColor(widget.isDark),
                ),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: 5,
                minLines: 1,
                enabled: !widget.isLoading,
                style: TextStyle(
                  color: AITeachingColors.textPrimaryColor(widget.isDark),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AITeachingColors.textTertiaryColor(widget.isDark),
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (_hasText && !widget.isLoading) {
                    widget.onSend();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice / Send button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _hasText || widget.isLoading
                ? _buildSendButton()
                : _buildIconButton(
                    icon: Icons.mic_rounded,
                    onTap: widget.onVoice,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.isDark
                ? AITeachingColors.darkSurface
                : AITeachingColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AITeachingColors.borderColor(widget.isDark),
            ),
          ),
          child: Icon(
            icon,
            color: AITeachingColors.textSecondaryColor(widget.isDark),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onSend,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          key: const ValueKey('send'),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: widget.isLoading ? null : AITeachingColors.aiGradient,
            color: widget.isLoading
                ? AITeachingColors.textTertiaryColor(widget.isDark)
                : null,
            borderRadius: BorderRadius.circular(22),
            boxShadow: widget.isLoading
                ? null
                : [
                    BoxShadow(
                      color: AITeachingColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
        ),
      ),
    );
  }
}
