import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_state.dart';

/// A shared dialog widget for creating new direct or group conversations.
///
/// Uses ChatBloc for all state management with debounced search (400ms).
/// Supports both direct (1:1) and group conversations with validation.
class SharedNewChatDialog extends StatefulWidget {
  const SharedNewChatDialog({super.key});

  @override
  State<SharedNewChatDialog> createState() => _SharedNewChatDialogState();
}

class _SharedNewChatDialogState extends State<SharedNewChatDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.newlyCreatedConversationId !=
          current.newlyCreatedConversationId,
      listener: (context, state) {
        if (state.newlyCreatedConversationId != null) {
          Navigator.of(context).pop(state.newlyCreatedConversationId);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildModeToggle(context),
                      const SizedBox(height: 16),
                      _buildGroupNameField(context),
                      _buildSearchField(context),
                      const SizedBox(height: 8),
                      _buildSelectedParticipants(context),
                      _buildSearchResults(context),
                      const SizedBox(height: 16),
                      _buildMessageField(context),
                      _buildErrorMessage(context),
                    ],
                  ),
                ),
              ),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'New Conversation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<ChatBloc>().add(
                const ChatNewConversationDialogReset(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.conversationMode != current.conversationMode,
      builder: (context, state) {
        return SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'direct',
              label: Text('Direct'),
              icon: Icon(Icons.person),
            ),
            ButtonSegment(
              value: 'group',
              label: Text('Group'),
              icon: Icon(Icons.group),
            ),
          ],
          selected: {state.conversationMode},
          onSelectionChanged: (selection) {
            context.read<ChatBloc>().add(
              ChatConversationModeChanged(selection.first),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupNameField(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.conversationMode != current.conversationMode,
      builder: (context, state) {
        if (state.conversationMode != 'group') {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
              hintText: 'Enter a name for the group',
              prefixIcon: const Icon(Icons.group),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.userSearchLoading != current.userSearchLoading,
      builder: (context, state) {
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Users',
            hintText: 'Enter email or name',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: state.userSearchLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ChatBloc>().add(
                        const ChatSearchUsersRequested(''),
                      );
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            context.read<ChatBloc>().add(ChatSearchUsersRequested(value));
          },
        );
      },
    );
  }

  Widget _buildSelectedParticipants(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.selectedParticipants != current.selectedParticipants,
      builder: (context, state) {
        if (state.selectedParticipants.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.selectedParticipants.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text(user.displayName),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  context.read<ChatBloc>().add(
                    ChatParticipantRemoved(user.userId),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.newConversationSearchResults !=
              current.newConversationSearchResults ||
          previous.userSearchLoading != current.userSearchLoading ||
          previous.userSearchError != current.userSearchError ||
          previous.selectedParticipants != current.selectedParticipants,
      builder: (context, state) {
        // Show error with retry button
        if (state.userSearchError != null) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  state.userSearchError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    if (state.lastSearchQuery != null) {
                      context.read<ChatBloc>().add(
                        ChatSearchUsersRequested(state.lastSearchQuery!),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Don't show results while loading
        if (state.userSearchLoading) {
          return const SizedBox.shrink();
        }

        // Empty state when search returns no results
        if (state.newConversationSearchResults.isEmpty &&
            _searchController.text.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  color: Theme.of(context).disabledColor,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'No users found',
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ),
              ],
            ),
          );
        }

        // Don't show list if no search performed
        if (state.newConversationSearchResults.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filter out already selected participants
        final selectedIds = state.selectedParticipants
            .map((u) => u.userId)
            .toSet();
        final availableResults = state.newConversationSearchResults
            .where((user) => !selectedIds.contains(user.userId))
            .toList();

        if (availableResults.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableResults.length,
            itemBuilder: (context, index) {
              final user = availableResults[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user.displayName),
                subtitle: user.email != null ? Text(user.email!) : null,
                onTap: () {
                  context.read<ChatBloc>().add(ChatParticipantAdded(user));
                  _searchController.clear();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageField(BuildContext context) {
    return TextField(
      controller: _messageController,
      maxLines: 3,
      minLines: 1,
      decoration: InputDecoration(
        labelText: 'Message (optional)',
        hintText: 'Write your first message...',
        prefixIcon: const Icon(Icons.message),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.createConversationError != current.createConversationError,
      builder: (context, state) {
        if (state.createConversationError == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.createConversationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.creatingConversation != current.creatingConversation ||
          previous.selectedParticipants != current.selectedParticipants ||
          previous.conversationMode != current.conversationMode,
      builder: (context, state) {
        final canCreate =
            state.selectedParticipants.isNotEmpty &&
            !state.creatingConversation;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: state.creatingConversation
                    ? null
                    : () {
                        context.read<ChatBloc>().add(
                          const ChatNewConversationDialogReset(),
                        );
                        Navigator.of(context).pop();
                      },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: canCreate ? () => _startConversation(context) : null,
                icon: state.creatingConversation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  state.creatingConversation
                      ? 'Creating...'
                      : 'Start Conversation',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startConversation(BuildContext context) {
    final state = context.read<ChatBloc>().state;
    final participantIds = state.selectedParticipants
        .map((u) => u.userId)
        .toList();

    context.read<ChatBloc>().add(
      ChatStartConversationRequested(
        participantIds: participantIds,
        selectedParticipants: state.selectedParticipants,
        type: state.conversationMode,
        groupName: state.conversationMode == 'group'
            ? _groupNameController.text.trim()
            : null,
        initialMessage: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      ),
    );
  }
}
