# Quickstart: New Conversation Flow Implementation

**Feature**: Phase 5 - New Conversation Flow  
**Estimated Time**: 8-12 hours  
**Prerequisites**: Phases 1-4 completed (ChatBloc, ChatService, conversation list UI, message detail UI)

## Overview

This guide provides a step-by-step implementation path for adding the new conversation creation dialog to the EduVerse Flutter app. The feature enables users to search for people, select participants, and create direct or group conversations.

---

## Step 1: Extend ChatBloc State (30 mins)

**File**: `lib/bloc/chat/chat_state.dart`

Add new fields to `ChatState`:

```dart
class ChatState extends Equatable {
  // ... existing fields ...
  
  final List<ChatUserModel> searchResults;
  final bool userSearchLoading;
  final String? userSearchError;
  final List<ChatUserModel> selectedParticipants;
  final String conversationMode;
  final bool creatingConversation;
  final String? createConversationError;
  final int? newlyCreatedConversationId;
  
  const ChatState({
    // ... existing parameters ...
    this.searchResults = const [],
    this.userSearchLoading = false,
    this.userSearchError,
    this.selectedParticipants = const [],
    this.conversationMode = 'direct',
    this.creatingConversation = false,
    this.createConversationError,
    this.newlyCreatedConversationId,
  });
  
  @override
  ChatState copyWith({
    // ... existing parameters ...
    List<ChatUserModel>? searchResults,
    bool? userSearchLoading,
    String? Function()? userSearchError,
    List<ChatUserModel>? selectedParticipants,
    String? conversationMode,
    bool? creatingConversation,
    String? Function()? createConversationError,
    int? Function()? newlyCreatedConversationId,
  }) {
    return ChatState(
      // ... existing copies ...
      searchResults: searchResults ?? this.searchResults,
      userSearchLoading: userSearchLoading ?? this.userSearchLoading,
      userSearchError: userSearchError != null ? userSearchError() : this.userSearchError,
      selectedParticipants: selectedParticipants ?? this.selectedParticipants,
      conversationMode: conversationMode ?? this.conversationMode,
      creatingConversation: creatingConversation ?? this.creatingConversation,
      createConversationError: createConversationError != null ? createConversationError() : this.createConversationError,
      newlyCreatedConversationId: newlyCreatedConversationId != null ? newlyCreatedConversationId() : this.newlyCreatedConversationId,
    );
  }
  
  @override
  List<Object?> get props => [
    // ... existing props ...
    searchResults,
    userSearchLoading,
    userSearchError,
    selectedParticipants,
    conversationMode,
    creatingConversation,
    createConversationError,
    newlyCreatedConversationId,
  ];
}
```

---

## Step 2: Add New ChatBloc Events (30 mins)

**File**: `lib/bloc/chat/chat_event.dart`

```dart
class ChatSearchUsersRequested extends ChatEvent {
  final String query;
  const ChatSearchUsersRequested(this.query);
  @override
  List<Object> get props => [query];
}

class ChatParticipantAdded extends ChatEvent {
  final ChatUserModel user;
  const ChatParticipantAdded(this.user);
  @override
  List<Object> get props => [user];
}

class ChatParticipantRemoved extends ChatEvent {
  final int userId;
  const ChatParticipantRemoved(this.userId);
  @override
  List<Object> get props => [userId];
}

class ChatConversationModeChanged extends ChatEvent {
  final String mode;
  const ChatConversationModeChanged(this.mode);
  @override
  List<Object> get props => [mode];
}

class ChatStartConversationRequested extends ChatEvent {
  final List<int> participantIds;
  final String type;
  final String? groupName;
  final String? initialMessage;
  
  const ChatStartConversationRequested({
    required this.participantIds,
    required this.type,
    this.groupName,
    this.initialMessage,
  });
  
  @override
  List<Object?> get props => [participantIds, type, groupName, initialMessage];
}

class ChatNewConversationDialogReset extends ChatEvent {
  const ChatNewConversationDialogReset();
  @override
  List<Object> get props => [];
}
```

---

## Step 3: Implement Event Handlers in ChatBloc (2-3 hours)

**File**: `lib/bloc/chat/chat_bloc.dart`

Add event handlers with debouncing:

```dart
// In ChatBloc constructor
on<ChatSearchUsersRequested>(
  _onSearchUsersRequested,
  transformer: (events, mapper) => events
      .debounceTime(const Duration(milliseconds: 400))
      .switchMap(mapper),
);
on<ChatParticipantAdded>(_onParticipantAdded);
on<ChatParticipantRemoved>(_onParticipantRemoved);
on<ChatConversationModeChanged>(_onConversationModeChanged);
on<ChatStartConversationRequested>(_onStartConversationRequested);
on<ChatNewConversationDialogReset>(_onNewConversationDialogReset);

// Event handler implementations
Future<void> _onSearchUsersRequested(
  ChatSearchUsersRequested event,
  Emitter<ChatState> emit,
) async {
  emit(state.copyWith(
    userSearchLoading: true,
    userSearchError: () => null,
  ));
  
  try {
    final users = await _chatService.searchUsers(event.query);
    emit(state.copyWith(
      searchResults: users,
      userSearchLoading: false,
    ));
  } catch (e) {
    emit(state.copyWith(
      userSearchLoading: false,
      userSearchError: () => e.toString(),
    ));
  }
}

void _onParticipantAdded(
  ChatParticipantAdded event,
  Emitter<ChatState> emit,
) {
  final participants = [...state.selectedParticipants];
  if (!participants.any((u) => u.userId == event.user.userId)) {
    participants.add(event.user);
  }
  emit(state.copyWith(
    selectedParticipants: participants,
    searchResults: [], // Clear search results
  ));
}

void _onParticipantRemoved(
  ChatParticipantRemoved event,
  Emitter<ChatState> emit,
) {
  final participants = state.selectedParticipants
      .where((u) => u.userId != event.userId)
      .toList();
  emit(state.copyWith(selectedParticipants: participants));
}

void _onConversationModeChanged(
  ChatConversationModeChanged event,
  Emitter<ChatState> emit,
) {
  emit(state.copyWith(conversationMode: event.mode));
}

Future<void> _onStartConversationRequested(
  ChatStartConversationRequested event,
  Emitter<ChatState> emit,
) async {
  // Validation
  if (event.type == 'group' && event.participantIds.length < 2) {
    emit(state.copyWith(
      createConversationError: () => 'Groups require at least 3 participants (including you)',
    ));
    return;
  }
  
  if (event.type == 'group' && (event.groupName == null || event.groupName!.isEmpty)) {
    emit(state.copyWith(
      createConversationError: () => 'Group name is required',
    ));
    return;
  }
  
  emit(state.copyWith(
    creatingConversation: true,
    createConversationError: () => null,
  ));
  
  try {
    final conversation = await _chatService.startConversation(
      participantIds: event.participantIds,
      type: event.type,
      groupName: event.groupName,
      text: event.initialMessage,
    );
    
    // Add to conversation list
    final updatedConversations = [conversation, ...state.conversations];
    
    emit(state.copyWith(
      creatingConversation: false,
      newlyCreatedConversationId: () => conversation.conversationId,
      conversations: updatedConversations,
    ));
  } catch (e) {
    emit(state.copyWith(
      creatingConversation: false,
      createConversationError: () => e.toString(),
    ));
  }
}

void _onNewConversationDialogReset(
  ChatNewConversationDialogReset event,
  Emitter<ChatState> emit,
) {
  emit(state.copyWith(
    searchResults: [],
    userSearchLoading: false,
    userSearchError: () => null,
    selectedParticipants: [],
    conversationMode: 'direct',
    creatingConversation: false,
    createConversationError: () => null,
    newlyCreatedConversationId: () => null,
  ));
}
```

---

## Step 4: Create SharedNewChatDialog Widget (3-4 hours)

**File**: `lib/widgets/shared/chat/shared_new_chat_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../bloc/chat/chat_models.dart';

class SharedNewChatDialog extends StatefulWidget {
  const SharedNewChatDialog({super.key});

  @override
  State<SharedNewChatDialog> createState() => _SharedNewChatDialogState();
}

class _SharedNewChatDialogState extends State<SharedNewChatDialog> {
  final _searchController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _messageController = TextEditingController();

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
      listenWhen: (prev, curr) =>
          prev.newlyCreatedConversationId != curr.newlyCreatedConversationId,
      listener: (context, state) {
        if (state.newlyCreatedConversationId != null) {
          Navigator.of(context).pop(); // Close dialog
          // Navigation to conversation handled by parent screen
        }
      },
      child: Dialog(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              SizedBox(height: 16),
              _buildModeToggle(context),
              SizedBox(height: 16),
              _buildSelectedParticipants(context),
              _buildGroupNameField(context),
              _buildSearchField(context),
              _buildSearchResults(context),
              SizedBox(height: 16),
              _buildMessageField(context),
              SizedBox(height: 16),
              _buildErrorMessage(context),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('New Conversation', style: Theme.of(context).textTheme.headlineSmall),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            context.read<ChatBloc>().add(ChatNewConversationDialogReset());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'direct', label: Text('Direct')),
            ButtonSegment(value: 'group', label: Text('Group')),
          ],
          selected: {state.conversationMode},
          onSelectionChanged: (Set<String> selected) {
            context.read<ChatBloc>().add(
              ChatConversationModeChanged(selected.first),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedParticipants(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.selectedParticipants.isEmpty) {
          return SizedBox.shrink();
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.selectedParticipants.map((user) {
            return Chip(
              label: Text(user.displayName),
              onDeleted: () => context.read<ChatBloc>().add(
                ChatParticipantRemoved(user.userId),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGroupNameField(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.conversationMode != 'group') {
          return SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(top: 16),
          child: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Group name *',
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search users...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          context.read<ChatBloc>().add(ChatSearchUsersRequested(value));
        }
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.userSearchLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.userSearchError != null) {
          return ListTile(
            leading: Icon(Icons.error, color: Colors.red),
            title: Text(state.userSearchError!),
            trailing: TextButton(
              onPressed: () => context.read<ChatBloc>().add(
                ChatSearchUsersRequested(_searchController.text),
              ),
              child: Text('Retry'),
            ),
          );
        }

        if (state.searchResults.isEmpty && _searchController.text.isNotEmpty) {
          return ListTile(
            leading: Icon(Icons.inbox),
            title: Text('No users found'),
          );
        }

        if (state.searchResults.isEmpty) {
          return SizedBox.shrink();
        }

        return Container(
          height: 200,
          child: ListView.builder(
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final user = state.searchResults[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.displayName[0]),
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
      decoration: InputDecoration(
        labelText: 'Message (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.createConversationError == null) {
          return SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            state.createConversationError!,
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                context.read<ChatBloc>().add(ChatNewConversationDialogReset());
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: state.creatingConversation ||
                      state.selectedParticipants.isEmpty
                  ? null
                  : () {
                      context.read<ChatBloc>().add(
                            ChatStartConversationRequested(
                              participantIds: state.selectedParticipants
                                  .map((u) => u.userId)
                                  .toList(),
                              type: state.conversationMode,
                              groupName: _groupNameController.text.isEmpty
                                  ? null
                                  : _groupNameController.text,
                              initialMessage: _messageController.text.isEmpty
                                  ? null
                                  : _messageController.text,
                            ),
                          );
                    },
              child: state.creatingConversation
                  ? CircularProgressIndicator()
                  : Text('Start Conversation'),
            ),
          ],
        );
      },
    );
  }
}
```

---

## Step 5: Integrate Dialog into Chat Screen (30 mins)

Add a FloatingActionButton or header button to trigger the dialog:

```dart
// In your chat screen widget
FloatingActionButton(
  onPressed: () {
    context.read<ChatBloc>().add(ChatNewConversationDialogReset());
    showDialog(
      context: context,
      builder: (context) => SharedNewChatDialog(),
    );
  },
  child: Icon(Icons.add),
)
```

---

## Step 6: Test Implementation (2-3 hours)

### Manual Testing Checklist

- [ ] Search for users by email
- [ ] Search for users by name
- [ ] Search returns self in results
- [ ] Select single user for direct chat
- [ ] Select multiple users for group
- [ ] Toggle between direct/group modes
- [ ] Validate group name requirement
- [ ] Validate minimum 3 participants for group
- [ ] Create direct conversation
- [ ] Create group conversation
- [ ] Handle network errors with retry
- [ ] Verify data preserved on error
- [ ] Verify existing conversation routing
- [ ] Verify conversation list refresh
- [ ] Verify navigation to new conversation

### Unit Tests

Write tests for:
- Event handler logic
- State transitions
- Validation rules
- Error handling

### Widget Tests

Write tests for:
- Dialog rendering
- User interactions
- Error states
- Loading states

---

## Common Pitfalls to Avoid

1. **Forgetting to reset state**: Always call `ChatNewConversationDialogReset` when opening dialog
2. **Not clearing search field**: Clear after selecting a participant
3. **Missing nullable safety**: Use `() => value` for nullable copyWith parameters
4. **Debounce not working**: Ensure `transformer` is on the event handler
5. **Navigation timing**: Use BlocListener for navigation, not BlocBuilder

---

## Performance Optimization Tips

- Use `ListView.builder` for search results (done in example)
- Limit search results to 20 (already in ChatService)
- Clear search results after selection to reduce memory
- Dispose TextEditingControllers in widget disposal

---

## Next Steps After Implementation

1. Run `/speckit.tasks` to generate detailed task breakdown
2. Implement tasks in order (state → events → bloc → widget → integration)
3. Write tests alongside implementation
4. Test on real backend with multiple users
5. Verify website feature parity (check CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md)

---

## Estimated Timeline

- Step 1 (State): 30 minutes
- Step 2 (Events): 30 minutes
- Step 3 (BLoC): 2-3 hours
- Step 4 (Widget): 3-4 hours
- Step 5 (Integration): 30 minutes
- Step 6 (Testing): 2-3 hours

**Total**: 8-12 hours for complete implementation with tests
