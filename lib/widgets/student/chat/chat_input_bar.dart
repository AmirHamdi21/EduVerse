import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttachment;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isSending,
    required this.onSend,
    required this.onAttachment,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeOut,
    );
    
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: widget.isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          Container(
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: widget.onAttachment,
              icon: Icon(
                Icons.add_rounded,
                color: widget.isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              splashRadius: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 15,
                        fontFamily: 'Arimo',
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.typeMessageHint,
                        hintStyle: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontFamily: 'Arimo',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (_hasText && !widget.isSending) {
                          widget.onSend();
                        }
                      },
                    ),
                  ),
                  
                  // Emoji button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement emoji picker
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: widget.isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      size: 22,
                    ),
                    splashRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Send button
          AnimatedBuilder(
            animation: _sendButtonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _sendButtonAnimation.value),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: _hasText
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _hasText
                    ? null
                    : (widget.isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _hasText
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasText && !widget.isSending ? widget.onSend : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: widget.isSending
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _hasText ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: _hasText
                                ? Colors.white
                                : (widget.isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8)),
                            size: 24,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
