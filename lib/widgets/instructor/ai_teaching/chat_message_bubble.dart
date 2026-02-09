import 'package:flutter/material.dart';
import '../../../models/instructor/ai_teaching_model.dart';
import 'ai_teaching_colors.dart';

/// Chat message bubble widget
class ChatMessageBubble extends StatelessWidget {
  final AIChatMessage message;
  final bool isDark;
  final VoidCallback? onRegenerate;
  final VoidCallback? onMakeEasier;
  final VoidCallback? onMakeHarder;
  final VoidCallback? onCopy;
  final VoidCallback? onExport;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isDark,
    this.onRegenerate,
    this.onMakeEasier,
    this.onMakeHarder,
    this.onCopy,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          if (!message.isUser) const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                if (!message.isUser) _buildActionButtons(context),
                _buildTimestamp(),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AITeachingColors.aiGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.psychology_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: message.isUser
            ? AITeachingColors.primary
            : AITeachingColors.messageBubbleColor(isDark),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(message.isUser ? 16 : 4),
          bottomRight: Radius.circular(message.isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: message.isUser
              ? Colors.white
              : AITeachingColors.textPrimaryColor(isDark),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildActionChip(
            icon: Icons.refresh_rounded,
            label: 'Regenerate',
            onTap: onRegenerate,
          ),
          _buildActionChip(
            icon: Icons.remove_circle_outline_rounded,
            label: 'Easier',
            onTap: onMakeEasier,
          ),
          _buildActionChip(
            icon: Icons.add_circle_outline_rounded,
            label: 'Harder',
            onTap: onMakeHarder,
          ),
          _buildActionChip(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: onCopy,
          ),
          _buildActionChip(
            icon: Icons.download_rounded,
            label: 'Export',
            onTap: onExport,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AITeachingColors.darkSurface
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AITeachingColors.borderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AITeachingColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AITeachingColors.textSecondaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    final hour = message.timestamp.hour;
    final minute = message.timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$displayHour:$minute $period',
        style: TextStyle(
          color: AITeachingColors.textTertiaryColor(isDark),
          fontSize: 11,
        ),
      ),
    );
  }
}
