import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/shared/chat/contact_list_item.dart';
import '../../../widgets/shared/chat/frequently_contacted_section.dart';

class NewConversationScreen extends StatefulWidget {
  final ChatUserModel? preselectedUser;

  const NewConversationScreen({super.key, this.preselectedUser});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatNewConversationDialogReset());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final preselectedUser = widget.preselectedUser;
      if (preselectedUser != null && mounted) {
        context.read<ChatBloc>().add(
          ChatDirectParticipantSelected(preselectedUser),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectDirectConversationRecipient(ChatUserModel user) {
    context.read<ChatBloc>().add(ChatDirectParticipantSelected(user));
  }

  void _toggleGroupParticipant(ChatState state, ChatUserModel user) {
    final isSelected = state.selectedParticipants.any(
      (participant) => participant.userId == user.userId,
    );

    if (isSelected) {
      context.read<ChatBloc>().add(ChatParticipantRemoved(user.userId));
      return;
    }

    context.read<ChatBloc>().add(ChatParticipantAdded(user));
  }

  void _createGroupConversation(ChatState state) {
    final participantIds = state.selectedParticipants
        .map((user) => user.userId)
        .toList(growable: false);

    context.read<ChatBloc>().add(
      ChatStartConversationRequested(
        participantIds: participantIds,
        selectedParticipants: state.selectedParticipants,
        type: 'group',
        groupName: _groupNameController.text.trim(),
        initialMessage: _messageController.text.trim(),
      ),
    );
  }

  void _startDirectConversation(ChatState state) {
    final selectedUser = state.selectedParticipants.isNotEmpty
        ? state.selectedParticipants.first
        : null;
    if (selectedUser == null) {
      return;
    }

    context.read<ChatBloc>().add(
      ChatStartConversationRequested(
        participantIds: <int>[selectedUser.userId],
        selectedParticipants: <ChatUserModel>[selectedUser],
        type: 'direct',
        initialMessage: _messageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accentColor = _resolveAccentColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.newlyCreatedConversationId !=
              current.newlyCreatedConversationId ||
          previous.createConversationError != current.createConversationError,
      listener: (context, state) {
        if ((state.createConversationError ?? '').trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.createConversationError!)),
          );
        }

        final createdId = state.newlyCreatedConversationId;
        if (createdId != null && createdId > 0) {
          context.read<ChatBloc>().add(const ChatNewConversationDialogReset());
          if (context.mounted) {
            context.pop(createdId);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final mode = state.conversationMode;
              final isGroup = mode == 'group';
              final query = _searchController.text.trim();
              final showSearchResults = query.isNotEmpty;

              final availableResults = state.contactSearchResults
                  .where((user) {
                    if (!isGroup) {
                      return true;
                    }
                    return !state.selectedParticipants.any(
                      (selected) => selected.userId == user.userId,
                    );
                  })
                  .toList(growable: false);

              final selectedDirectUser =
                  !isGroup && state.selectedParticipants.isNotEmpty
                  ? state.selectedParticipants.first
                  : null;
              final canCreateDirect =
                  !isGroup &&
                  selectedDirectUser != null &&
                  _messageController.text.trim().isNotEmpty &&
                  !state.creatingConversation;
              final canCreateGroup =
                  isGroup &&
                  state.selectedParticipants.length >= 2 &&
                  _groupNameController.text.trim().isNotEmpty &&
                  _messageController.text.trim().isNotEmpty &&
                  !state.creatingConversation;

              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF020617)
                      : const Color(0xFFF8FAFC),
                ),
                child: Column(
                  children: [
                    _NewConversationHeader(
                      accentColor: accentColor,
                      title: l10n.newConversation,
                      subtitle: l10n.chatNewConversationSubtitle,
                      onClose: () => context.pop(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeCard(
                              icon: Icons.person_outline_rounded,
                              label: l10n.chatModeDirect,
                              subtitle: l10n.chatModeDirectSubtitle,
                              accentColor: accentColor,
                              isSelected: !isGroup,
                              isDark: isDark,
                              onTap: () {
                                context.read<ChatBloc>().add(
                                  const ChatConversationModeChanged('direct'),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModeCard(
                              icon: Icons.groups_rounded,
                              label: l10n.chatModeGroup,
                              subtitle: l10n.chatModeGroupSubtitle,
                              accentColor: accentColor,
                              isSelected: isGroup,
                              isDark: isDark,
                              onTap: () {
                                context.read<ChatBloc>().add(
                                  const ChatConversationModeChanged('group'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ModernSearchField(
                      controller: _searchController,
                      accentColor: accentColor,
                      isDark: isDark,
                      hintText: l10n.searchByNameOrEmail,
                      loading: state.userSearchLoading,
                      onChanged: (value) {
                        context.read<ChatBloc>().add(
                          ChatSearchUsersRequested(value),
                        );
                        setState(() {});
                      },
                      onClear: () {
                        _searchController.clear();
                        context.read<ChatBloc>().add(
                          const ChatSearchUsersRequested(''),
                        );
                        setState(() {});
                      },
                    ),
                    if (isGroup)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _SectionCard(
                          accentColor: accentColor,
                          isDark: isDark,
                          child: TextField(
                            controller: _groupNameController,
                            decoration: InputDecoration(
                              hintText: l10n.chatGroupNameHint,
                              prefixIcon: const Icon(Icons.group_work_rounded),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    if (isGroup && state.selectedParticipants.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _SectionCard(
                          accentColor: accentColor,
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.chatSelectedParticipantsTitle,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: state.selectedParticipants
                                    .map((user) {
                                      return Chip(
                                        label: Text(user.displayName),
                                        avatar: CircleAvatar(
                                          backgroundColor: accentColor
                                              .withValues(alpha: 0.14),
                                          child: Text(
                                            user.displayName[0].toUpperCase(),
                                            style: TextStyle(
                                              color: accentColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        deleteIcon: const Icon(
                                          Icons.close_rounded,
                                        ),
                                        onDeleted: () {
                                          context.read<ChatBloc>().add(
                                            ChatParticipantRemoved(user.userId),
                                          );
                                        },
                                      );
                                    })
                                    .toList(growable: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!isGroup && selectedDirectUser != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _SectionCard(
                          accentColor: accentColor,
                          isDark: isDark,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      accentColor,
                                      Color.lerp(
                                        accentColor,
                                        const Color(0xFF06B6D4),
                                        0.28,
                                      )!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    selectedDirectUser.displayName[0]
                                        .toUpperCase(),
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
                                    Text(
                                      selectedDirectUser.displayName,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (selectedDirectUser.email ?? '')
                                              .trim()
                                              .isNotEmpty
                                          ? selectedDirectUser.email!
                                          : l10n.chatSelectedRecipientSubtitle,
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  context.read<ChatBloc>().add(
                                    const ChatNewConversationDialogReset(),
                                  );
                                  if (widget.preselectedUser != null) {
                                    _searchController.clear();
                                  }
                                  setState(() {});
                                },
                                icon: const Icon(Icons.swap_horiz_rounded),
                                label: Text(l10n.chatChangeRecipient),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: showSearchResults
                          ? _buildSearchResults(
                              state: state,
                              results: availableResults,
                              isGroup: isGroup,
                              accentColor: accentColor,
                            )
                          : _buildInitialState(state, isGroup, accentColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _ComposerCard(
                        accentColor: accentColor,
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.chatFirstMessageTitle,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _messageController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: l10n.chatFirstMessageHint,
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: !isGroup
                                    ? (canCreateDirect
                                          ? () =>
                                                _startDirectConversation(state)
                                          : null)
                                    : (canCreateGroup
                                          ? () =>
                                                _createGroupConversation(state)
                                          : null),
                                icon: state.creatingConversation
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded),
                                label: Text(
                                  state.creatingConversation
                                      ? (!isGroup
                                            ? l10n.chatStartingConversation
                                            : l10n.chatCreatingGroupConversation)
                                      : (!isGroup
                                            ? l10n.chatStartConversationButton
                                            : l10n.chatCreateGroupConversationButton),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _resolveAccentColor(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final role = authState is AuthAuthenticated
        ? authState.user.primaryRoleName.toLowerCase()
        : 'student';

    if (role.contains('ta')) {
      return const Color(0xFF8B5CF6);
    }
    if (role.contains('instructor')) {
      return const Color(0xFF155CFB);
    }
    if (role.contains('admin')) {
      return const Color(0xFF4F46E5);
    }
    return const Color(0xFF3B82F6);
  }

  Widget _buildInitialState(ChatState state, bool isGroup, Color accentColor) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        FrequentlyContactedSection(
          users: state.frequentlyContacted,
          onlineUsers: state.onlineUsers,
          accentColor: accentColor,
          onUserTap: (user) {
            if (isGroup) {
              _toggleGroupParticipant(state, user);
            } else {
              _selectDirectConversationRecipient(user);
            }
          },
          onAvatarTap: (user) {
            context.push('/messages/profile/${user.userId}');
          },
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionCard(
            accentColor: accentColor,
            isDark: Theme.of(context).brightness == Brightness.dark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chatSearchPromptTitle,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chatSearchPromptSubtitle,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults({
    required ChatState state,
    required List<ChatUserModel> results,
    required bool isGroup,
    required Color accentColor,
  }) {
    final l10n = AppLocalizations.of(context);
    if (state.userSearchLoading && results.isEmpty) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.chatNoContactsFound,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        final isSelected = state.selectedParticipants.any(
          (participant) => participant.userId == user.userId,
        );

        return ContactListItem(
          user: user,
          isOnline: state.onlineUsers.contains(user.userId),
          isSelected: isSelected,
          accentColor: accentColor,
          onAvatarTap: () {
            context.push('/messages/profile/${user.userId}');
          },
          onTap: () {
            if (isGroup) {
              _toggleGroupParticipant(state, user);
            } else {
              _selectDirectConversationRecipient(user);
            }
          },
        );
      },
    );
  }
}

class _NewConversationHeader extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _NewConversationHeader({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              accentColor,
              Color.lerp(accentColor, Colors.white, 0.16)!,
              Color.lerp(accentColor, const Color(0xFF06B6D4), 0.24)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: 0.20),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor
              : (isDark ? const Color(0xFF111827) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.14)
                    : accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : accentColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.88)
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final bool isDark;
  final String hintText;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _ModernSearchField({
    required this.controller,
    required this.accentColor,
    required this.isDark,
    required this.hintText,
    required this.loading,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final mutedText = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: mutedText),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.search_rounded, color: accentColor),
            ),
            suffixIcon: loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close_rounded, color: mutedText),
                          onPressed: onClear,
                        )),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF111827) : Colors.white,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final Widget child;

  const _SectionCard({
    required this.accentColor,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ComposerCard extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final Widget child;

  const _ComposerCard({
    required this.accentColor,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
