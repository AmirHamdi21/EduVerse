import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRecording;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onVoiceToggle;
  final VoidCallback onAttachment;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isRecording,
    required this.isSending,
    required this.onSend,
    required this.onVoiceToggle,
    required this.onAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 
            ? 12 
            : MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAttachmentButton(isDark),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(l10n, isDark)),
            const SizedBox(width: 12),
            _buildVoiceButton(isDark),
            const SizedBox(width: 8),
            _buildSendButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(bool isDark) {
    return GestureDetector(
      onTap: onAttachment,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          Icons.attach_file_rounded,
          size: 22,
          color: isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildTextField(AppLocalizations l10n, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: isRecording ? l10n.listeningHint : l10n.typeMessageHint,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildVoiceButton(bool isDark) {
    return GestureDetector(
      onTap: onVoiceToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isRecording
              ? const Color(0xFFEF4444)
              : (isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isRecording
                ? const Color(0xFFEF4444)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
          ),
          boxShadow: isRecording
              ? [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          size: 22,
          color: isRecording
              ? Colors.white
              : (isDark ? const Color(0xFF99A1AF) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _buildSendButton(bool isDark) {
    return GestureDetector(
      onTap: isSending ? null : onSend,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B7FFF).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isSending
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                Icons.send_rounded,
                size: 20,
                color: Colors.white,
              ),
      ),
    );
  }
}
