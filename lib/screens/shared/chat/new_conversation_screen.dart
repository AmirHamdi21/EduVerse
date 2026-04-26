import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
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
        appBar: AppBar(
          title: const Text('New Conversation'),
          actions: [
            IconButton(
              tooltip: 'Close',
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
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

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'direct',
                          icon: Icon(Icons.person_outline),
                          label: Text('Direct'),
                        ),
                        ButtonSegment(
                          value: 'group',
                          icon: Icon(Icons.group_outlined),
                          label: Text('Group'),
                        ),
                      ],
                      selected: <String>{mode},
                      onSelectionChanged: (selection) {
                        context.read<ChatBloc>().add(
                          ChatConversationModeChanged(selection.first),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: state.userSearchLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : (_searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<ChatBloc>().add(
                                          const ChatSearchUsersRequested(''),
                                        );
                                        setState(() {});
                                      },
                                    )),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        context.read<ChatBloc>().add(
                          ChatSearchUsersRequested(value),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                  if (isGroup)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          hintText: 'Group name',
                          prefixIcon: const Icon(Icons.group),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  if (isGroup && state.selectedParticipants.isNotEmpty)
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final user = state.selectedParticipants[index];
                          return Chip(
                            label: Text(user.displayName),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              context.read<ChatBloc>().add(
                                ChatParticipantRemoved(user.userId),
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: state.selectedParticipants.length,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (!isGroup && selectedDirectUser != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          title: Text(selectedDirectUser.displayName),
                          subtitle: Text(
                            (selectedDirectUser.email ?? '').trim().isNotEmpty
                                ? selectedDirectUser.email!
                                : 'Selected recipient',
                          ),
                          trailing: IconButton(
                            tooltip: 'Change recipient',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              context.read<ChatBloc>().add(
                                const ChatNewConversationDialogReset(),
                              );
                              if (widget.preselectedUser != null) {
                                _searchController.clear();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: showSearchResults
                        ? _buildSearchResults(
                            state: state,
                            results: availableResults,
                            isGroup: isGroup,
                          )
                        : _buildInitialState(state, isGroup),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'First message',
                        prefixIcon: const Icon(Icons.message_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (!isGroup)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: canCreateDirect
                              ? () => _startDirectConversation(state)
                              : null,
                          icon: state.creatingConversation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_outlined),
                          label: Text(
                            state.creatingConversation
                                ? 'Starting...'
                                : 'Start Conversation',
                          ),
                        ),
                      ),
                    ),
                  if (isGroup)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: canCreateGroup
                              ? () => _createGroupConversation(state)
                              : null,
                          icon: state.creatingConversation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_outlined),
                          label: Text(
                            state.creatingConversation
                                ? 'Creating...'
                                : 'Create Group Conversation',
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(ChatState state, bool isGroup) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        FrequentlyContactedSection(
          users: state.frequentlyContacted,
          onlineUsers: state.onlineUsers,
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
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Contacts is hidden until you search. Start typing to find people.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults({
    required ChatState state,
    required List<ChatUserModel> results,
    required bool isGroup,
  }) {
    if (state.userSearchLoading && results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No contacts found for this search.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
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
