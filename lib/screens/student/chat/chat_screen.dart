import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/chat/chat_cubit.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/chat/chat_conversation_list.dart';
import '../../../widgets/student/chat/chat_detail_view.dart';
import '../../../widgets/student/chat/chat_header.dart';
import '../../../widgets/student/chat/chat_empty_state.dart';
import '../../../widgets/student/chat/chat_search_bar.dart';
import '../../../widgets/student/chat/chat_filter_chips.dart';
import '../../../widgets/student/chat/new_chat_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Load conversations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadConversations();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ChatCubit>().searchConversations(query);
  }

  void _onFilterChanged(ChatFilter filter) {
    context.read<ChatCubit>().applyFilter(filter);
  }

  void _onNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewChatDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC),
          body: BlocConsumer<ChatCubit, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                context.read<ChatCubit>().clearError();
              }
            },
            builder: (context, state) {
              if (state is ChatLoading) {
                return _buildLoadingState(isDark);
              }

              if (state is ChatError) {
                return _buildErrorState(isDark, state.message, l10n);
              }

              if (state is ChatLoaded) {
                return _buildChatContent(context, state, isDark, l10n);
              }

              return _buildLoadingState(isDark);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading conversations...',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String message, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.error,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatCubit>().loadConversations();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(
    BuildContext context,
    ChatLoaded state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Check if a conversation is selected (for navigation on mobile)
    if (state.selectedConversation != null) {
      return ChatDetailView(
        conversation: state.selectedConversation!,
        messages: state.currentMessages,
        isLoading: state.isLoadingMessages,
        isSending: state.isSendingMessage,
        replyingTo: state.replyingTo,
        isDark: isDark,
        onBack: () {
          context.read<ChatCubit>().clearSelectedConversation();
        },
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Background decorations
          _buildBackgroundDecorations(isDark),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                ChatHeader(
                  isDark: isDark,
                  onNewChat: _onNewChat,
                  isSearching: _isSearching,
                  onToggleSearch: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        context.read<ChatCubit>().searchConversations('');
                      }
                    });
                  },
                ),
                
                // Search bar
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: ChatSearchBar(
                    controller: _searchController,
                    isDark: isDark,
                    onChanged: _onSearch,
                  ),
                  crossFadeState: _isSearching
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                
                // Filter chips
                ChatFilterChips(
                  currentFilter: state.currentFilter,
                  isDark: isDark,
                  onFilterChanged: _onFilterChanged,
                ),
                
                // Conversation list
                Expanded(
                  child: state.filteredConversations.isEmpty
                      ? ChatEmptyState(
                          isDark: isDark,
                          isFiltered: state.currentFilter != ChatFilter.all ||
                              state.searchQuery.isNotEmpty,
                          onClearFilters: () {
                            _searchController.clear();
                            context.read<ChatCubit>().searchConversations('');
                            context.read<ChatCubit>().applyFilter(ChatFilter.all);
                          },
                          onNewChat: _onNewChat,
                        )
                      : ChatConversationList(
                          conversations: state.filteredConversations,
                          isDark: isDark,
                          onConversationTap: (conversation) {
                            context.read<ChatCubit>().selectConversation(conversation);
                          },
                          onConversationLongPress: (conversation) {
                            _showConversationOptions(context, conversation, isDark);
                          },
                          onDelete: (id) {
                            context.read<ChatCubit>().deleteConversation(id);
                          },
                          onArchive: (id) {
                            context.read<ChatCubit>().archiveConversation(id);
                          },
                          onPin: (id) {
                            context.read<ChatCubit>().togglePinConversation(id);
                          },
                          onMute: (id) {
                            context.read<ChatCubit>().toggleMuteConversation(id);
                          },
                          onMarkRead: (id) {
                            context.read<ChatCubit>().markConversationAsRead(id);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    if (isDark) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 300,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(
    BuildContext context,
    Conversation conversation,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Conversation info
                Row(
                  children: [
                    _buildAvatar(conversation, 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (conversation.primaryParticipant != null)
                            Text(
                              conversation.primaryParticipant!.roleDisplayName,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Options
                _buildOptionTile(
                  icon: conversation.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  label: conversation.isPinned ? l10n.cancel : 'Pin Chat',
                  isDark: isDark,
                  onTap: () {
                    context.read<ChatCubit>().togglePinConversation(conversation.id);
                    Navigator.pop(ctx);
                  },
                ),
                _buildOptionTile(
                  icon: conversation.isMuted
                      ? Icons.notifications
                      : Icons.notifications_off_outlined,
                  label: conversation.isMuted ? 'Unmute' : 'Mute',
                  isDark: isDark,
                  onTap: () {
                    context.read<ChatCubit>().toggleMuteConversation(conversation.id);
                    Navigator.pop(ctx);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.delete,
                  isDark: isDark,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteConfirmation(context, conversation, isDark, l10n);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Conversation conversation, double size) {
    final participant = conversation.primaryParticipant;
    final isGroup = conversation.type == ConversationType.group;
    final isCourse = conversation.type == ConversationType.course;
    
    if (isCourse) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      );
    }
    
    if (isGroup) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Icon(
          Icons.group_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      );
    }
    
    if (participant != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              participant.avatarColor,
              participant.avatarColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 3),
        ),
        child: Center(
          child: Text(
            participant.initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF94A3B8),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFEF4444)
        : (isDark ? Colors.white : const Color(0xFF1E293B));
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Conversation conversation,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Conversation?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'This will permanently delete the conversation with ${conversation.title}. This action cannot be undone.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().deleteConversation(conversation.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
