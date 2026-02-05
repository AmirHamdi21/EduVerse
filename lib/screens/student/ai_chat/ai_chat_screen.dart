import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/ai_chat/ai_chat_cubit.dart';
import 'package:edu_verse/bloc/ai_chat/ai_chat_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/student/ai_chat/ai_chat_app_bar.dart';
import 'package:edu_verse/widgets/student/ai_chat/ai_chat_header.dart';
import 'package:edu_verse/widgets/student/ai_chat/chat_message_list.dart';
import 'package:edu_verse/widgets/student/ai_chat/chat_input_bar.dart';
import 'package:edu_verse/widgets/student/ai_chat/quick_actions_bar.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiChatCubit(),
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSend() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      context.read<AiChatCubit>().sendMessage(content);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030712) : const Color(0xFFF9FAFB),
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          // Scroll to bottom when new messages arrive
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background decorations
              _buildBackgroundDecorations(isDark),
              
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    AiChatAppBar(
                      onClearChat: () => _showClearChatDialog(context, l10n, isDark),
                    ),
                    AiChatHeader(
                      chatMode: state.chatMode,
                      selectedCourse: state.selectedCourse,
                      availableCourses: state.availableCourses,
                      onModeChanged: (mode) {
                        context.read<AiChatCubit>().setChatMode(mode);
                      },
                      onCourseSelected: (course) {
                        context.read<AiChatCubit>().selectCourse(course);
                      },
                    ),
                    Expanded(
                      child: ChatMessageList(
                        messages: state.messages,
                        scrollController: _scrollController,
                        isTyping: state.isAiTyping,
                      ),
                    ),
                    QuickActionsBar(
                      quickActions: state.quickActions,
                      onActionTap: (prompt) {
                        context.read<AiChatCubit>().sendMessage(prompt);
                        _scrollToBottom();
                      },
                    ),
                    ChatInputBar(
                      controller: _messageController,
                      focusNode: _focusNode,
                      isRecording: state.isRecording,
                      isSending: state.isAiTyping,
                      onSend: _handleSend,
                      onAttachment: () => _showAttachmentOptions(context, isDark),
                      onVoiceToggle: () => context.read<AiChatCubit>().toggleRecording(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: -50,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
              ),
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isDark ? 0.95 : 0.9),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
              ),
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isDark ? 0.95 : 0.9),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearChatDialog(BuildContext context, AppLocalizations l10n, bool isDark) {
    final cubit = context.read<AiChatCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF101828) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.clearChat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.clearChatConfirm,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              cubit.clearChat();
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.attachFile,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  Icons.image_rounded,
                  l10n.image,
                  const Color(0xFF10B981),
                  isDark,
                ),
                _buildAttachmentOption(
                  context,
                  Icons.picture_as_pdf_rounded,
                  l10n.document,
                  const Color(0xFFEF4444),
                  isDark,
                ),
                _buildAttachmentOption(
                  context,
                  Icons.camera_alt_rounded,
                  l10n.camera,
                  const Color(0xFF8B5CF6),
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label attachment coming soon'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
