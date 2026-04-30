import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
import '../profile/role_profile_theme.dart';

class ChatGroupProfileScreen extends StatefulWidget {
  const ChatGroupProfileScreen({super.key, required this.conversationId});

  final int conversationId;

  @override
  State<ChatGroupProfileScreen> createState() => _ChatGroupProfileScreenState();
}

class _ChatGroupProfileScreenState extends State<ChatGroupProfileScreen> {
  int? _pendingMemberUserId;

  _ChatGroupTheme get _theme =>
      _ChatGroupTheme.fromAuthState(context.read<AuthBloc>().state);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _theme.background(isDark),
      body: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.activeConversationId != current.activeConversationId ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final pendingUserId = _pendingMemberUserId;
          if (pendingUserId == null) {
            return;
          }

          final activeConversation = state.activeConversation;
          final openedConversation =
              activeConversation != null &&
              activeConversation.type == ConversationType.direct &&
              (activeConversation.directDisplayUser?.userId == pendingUserId ||
                  activeConversation.participants.contains(pendingUserId));

          if (openedConversation) {
            context.read<ChatBloc>().add(
              MarkRead(activeConversation.conversationId),
            );
            setState(() => _pendingMemberUserId = null);
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
            return;
          }

          final error = (state.errorMessage ?? '').trim();
          if (error.isNotEmpty) {
            setState(() => _pendingMemberUserId = null);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        },
        builder: (context, state) {
          final conversation = state.conversations
              .where((item) => item.conversationId == widget.conversationId)
              .firstOrNull;

          if (conversation == null) {
            return _buildMissingState(context, isDark);
          }

          final authState = context.read<AuthBloc>().state;
          final currentUserId = authState is AuthAuthenticated
              ? authState.user.userId
              : 0;
          final members = _resolveMembers(state, conversation);
          final onlineCount = members
              .where((member) => state.onlineUsers.contains(member.userId))
              .length;

          return Stack(
            children: [
              _buildBackgroundDecorations(isDark),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                  children: [
                    _buildTopBar(context, isDark),
                    const SizedBox(height: 10),
                    _buildHeroCard(
                      conversation: conversation,
                      memberCount: members.length,
                      onlineCount: onlineCount,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildStatsRow(
                      isDark: isDark,
                      memberCount: members.length,
                      onlineCount: onlineCount,
                      unreadCount: conversation.unreadCount,
                    ),
                    const SizedBox(height: 14),
                    _buildSectionCard(
                      isDark: isDark,
                      title: 'Members',
                      subtitle:
                          'Open a direct chat with any member and keep the conversation flowing.',
                      icon: Icons.groups_rounded,
                      child: Column(
                        children: members
                            .map(
                              (member) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildMemberTile(
                                  context: context,
                                  member: member,
                                  isDark: isDark,
                                  isCurrentUser: member.userId == currentUserId,
                                  isOnline: state.onlineUsers.contains(
                                    member.userId,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSectionCard(
                      isDark: isDark,
                      title: 'Quick Action',
                      subtitle:
                          'Jump straight back into the group thread from this info view.',
                      icon: Icons.flash_on_rounded,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openConversation(
                            context,
                            conversation.conversationId,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _theme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.forum_outlined),
                          label: const Text(
                            'Open Group Chat',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
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

  Widget _buildMissingState(BuildContext context, bool isDark) {
    return Stack(
      children: [
        _buildBackgroundDecorations(isDark),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              children: [
                _buildTopBar(context, isDark),
                Expanded(
                  child: Center(
                    child: _buildEmptyState(
                      isDark: isDark,
                      icon: Icons.group_off_outlined,
                      title: 'Group data not found',
                      subtitle:
                          'We could not resolve this group from the current chat cache.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -50,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _theme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 220,
          left: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _theme.accent.withValues(alpha: isDark ? 0.16 : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pop(),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _theme.card(isDark).withValues(alpha: isDark ? 0.92 : 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _theme.border(isDark)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _theme.textPrimary(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  color: _theme.textPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required ConversationModel conversation,
    required int memberCount,
    required int onlineCount,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? _theme.darkHeaderGradient : _theme.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _theme.primary.withValues(alpha: isDark ? 0.22 : 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Profile',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversation.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHeroChip(
                          icon: Icons.people_alt_rounded,
                          label: '$memberCount members',
                        ),
                        _buildHeroChip(
                          icon: Icons.circle_rounded,
                          label: '$onlineCount online',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeroMetaCard(
                  title: 'Conversation',
                  value: 'Group chat',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeroMetaCard(
                  title: 'Unread',
                  value: '${conversation.unreadCount}',
                  color: _theme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetaCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required bool isDark,
    required int memberCount,
    required int onlineCount,
    required int unreadCount,
  }) {
    return _buildSurfaceCard(
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              isDark: isDark,
              icon: Icons.groups_rounded,
              value: '$memberCount',
              label: 'Members',
              color: _theme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatItem(
              isDark: isDark,
              icon: Icons.wifi_tethering_rounded,
              value: '$onlineCount',
              label: 'Online',
              color: _theme.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatItem(
              isDark: isDark,
              icon: Icons.mark_chat_unread_rounded,
              value: '$unreadCount',
              label: 'Unread',
              color: _theme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: _theme.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: _theme.textPrimary(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: _theme.textSecondary(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return _buildSurfaceCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _theme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _theme.textPrimary(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _theme.textSecondary(isDark),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildMemberTile({
    required BuildContext context,
    required ChatUserModel member,
    required bool isDark,
    required bool isCurrentUser,
    required bool isOnline,
  }) {
    final isPending = _pendingMemberUserId == member.userId;
    final memberRole = (member.role ?? '').trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isCurrentUser || isPending
            ? null
            : () => _openMemberConversation(context, member),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _theme.surface(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCurrentUser
                  ? _theme.accent.withValues(alpha: 0.20)
                  : _theme.border(isDark),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_theme.primary, _theme.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _initialsFor(member.displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _theme.textPrimary(isDark),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          _buildMiniBadge(label: 'You', color: _theme.accent)
                        else if (isOnline)
                          _buildMiniBadge(
                            label: 'Online',
                            color: _theme.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memberRole.isEmpty ? 'Member' : memberRole,
                      style: TextStyle(
                        color: _theme.textSecondary(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((member.email ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        member.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _theme.textTertiary(isDark),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isPending)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _theme.primary,
                  ),
                )
              else
                Icon(
                  isCurrentUser
                      ? Icons.check_circle_outline_rounded
                      : Icons.chat_bubble_outline_rounded,
                  color: isCurrentUser ? _theme.accent : _theme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _theme.surface(isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: _theme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _theme.textPrimary(isDark),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _theme.textSecondary(isDark),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfaceCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _theme.border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  List<ChatUserModel> _resolveMembers(
    ChatState state,
    ConversationModel conversation,
  ) {
    final resolved = <int, ChatUserModel>{};

    for (final member in conversation.participantUsers) {
      if (member.userId > 0) {
        resolved[member.userId] = member;
      }
    }

    for (final userId in conversation.participants) {
      if (userId <= 0 || resolved.containsKey(userId)) {
        continue;
      }
      resolved[userId] =
          state.participantCache[userId] ?? ChatUserModel(userId: userId);
    }

    final members = resolved.values.toList(growable: false);
    members.sort(
      (left, right) => left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      ),
    );
    return members;
  }

  void _openConversation(BuildContext context, int conversationId) {
    context.read<ChatBloc>().add(SelectConversation(conversationId));
    context.read<ChatBloc>().add(MarkRead(conversationId));
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
  }

  void _openMemberConversation(BuildContext context, ChatUserModel member) {
    setState(() => _pendingMemberUserId = member.userId);
    context.read<ChatBloc>().add(const ClearChatError());
    context.read<ChatBloc>().add(
      StartNewConversation(participantIds: [member.userId], type: 'direct'),
    );
  }

  String _initialsFor(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'G';
    }
    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return '$first$second'.toUpperCase();
  }
}

class _ChatGroupTheme {
  const _ChatGroupTheme({
    required this.primary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.background,
    required this.card,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.headerGradient,
    required this.darkHeaderGradient,
  });

  final Color primary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color Function(bool isDark) background;
  final Color Function(bool isDark) card;
  final Color Function(bool isDark) surface;
  final Color Function(bool isDark) border;
  final Color Function(bool isDark) textPrimary;
  final Color Function(bool isDark) textSecondary;
  final Color Function(bool isDark) textTertiary;
  final LinearGradient headerGradient;
  final LinearGradient darkHeaderGradient;

  factory _ChatGroupTheme.fromAuthState(AuthState authState) {
    if (authState is AuthAuthenticated) {
      return _ChatGroupTheme.fromRoleName(authState.user.primaryRoleName);
    }
    return _ChatGroupTheme.fromRoleName(null);
  }

  factory _ChatGroupTheme.fromRoleName(String? roleName) {
    final normalized = (roleName ?? '').trim().toLowerCase().replaceAll(
      '_',
      ' ',
    );

    if (normalized.contains('assistant') || normalized == 'ta') {
      return _ChatGroupTheme.fromRoleProfileTheme(RoleProfileTheme.ta());
    }
    if (normalized.contains('instructor')) {
      return _ChatGroupTheme.fromRoleProfileTheme(
        RoleProfileTheme.instructor(),
      );
    }
    if (normalized.contains('admin')) {
      return _ChatGroupTheme.fromRoleProfileTheme(RoleProfileTheme.admin());
    }
    return _ChatGroupTheme.fromRoleProfileTheme(RoleProfileTheme.student());
  }

  factory _ChatGroupTheme.fromRoleProfileTheme(RoleProfileTheme roleTheme) {
    return _ChatGroupTheme(
      primary: roleTheme.primary,
      accent: roleTheme.accent,
      success: roleTheme.success,
      warning: roleTheme.warning,
      background: roleTheme.background,
      card: roleTheme.card,
      surface: roleTheme.surface,
      border: roleTheme.border,
      textPrimary: roleTheme.textPrimary,
      textSecondary: roleTheme.textSecondary,
      textTertiary: roleTheme.textTertiary,
      headerGradient: roleTheme.headerGradient,
      darkHeaderGradient: roleTheme.darkHeaderGradient,
    );
  }
}
