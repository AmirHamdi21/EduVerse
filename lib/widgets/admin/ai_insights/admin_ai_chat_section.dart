import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/admin_colors.dart';

class AIMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final bool isTyping;

  const AIMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.isTyping = false,
  });
}

class AdminAIChatSection extends StatelessWidget {
  final bool isDark;
  final List<AIMessage> messages;
  final ScrollController scrollController;
  final Function(String)? onSuggestionTap;

  const AdminAIChatSection({
    super.key,
    required this.isDark,
    required this.messages,
    required this.scrollController,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _buildWelcomeState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(messages[index]);
      },
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AdminColors.purpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AdminColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Admin AI Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AdminColors.darkText : AdminColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'I can help you with analytics, reports,\nsystem management, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AdminColors.darkTextSecondary
                    : AdminColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    if (message.isTyping) {
      return _buildTypingIndicator();
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: EdgeInsets.only(
          left: message.isUser ? 48 : 16,
          right: message.isUser ? 16 : 48,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isUser ? AdminColors.primaryGradient : null,
                color: message.isUser
                    ? null
                    : (isDark ? AdminColors.darkCard : AdminColors.lightCard),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                border: message.isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? AdminColors.darkCardBorder
                            : AdminColors.lightCardBorder,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (message.isUser ? AdminColors.primary : Colors.black)
                        .withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: AdminColors.purpleGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Assistant',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  if (!message.isUser) const SizedBox(height: 8),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isUser
                          ? Colors.white
                          : (isDark
                                ? AdminColors.darkText
                                : AdminColors.lightText),
                    ),
                  ),
                ],
              ),
            ),
            if (message.suggestions != null &&
                message.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestions!.map((suggestion) {
                  return _buildSuggestionChip(suggestion);
                }).toList(),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AdminColors.darkTextTertiary
                      : AdminColors.lightTextTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return Material(
      color: AdminColors.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSuggestionTap != null
            ? () => onSuggestionTap!(suggestion)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            suggestion,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AdminColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? AdminColors.darkCardBorder
                : AdminColors.lightCardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AdminColors.secondary.withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
