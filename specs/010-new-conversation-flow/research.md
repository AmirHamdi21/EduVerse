# Research: New Conversation Flow Technical Decisions

**Feature**: Phase 5 - New Conversation Flow  
**Date**: 2026-04-07  
**Context**: Flutter chat application implementing new conversation creation dialog with user search

## Research Questions & Decisions

### 1. Debouncing Strategy for User Search

**Decision**: Use StreamTransformer debouncing in the ChatBloc

**Rationale**:
- Aligns with BLoC-first architecture principle
- Centralizes business logic away from UI
- Enables easier testing of debounce behavior
- Existing ChatBloc already manages chat state

**Implementation Approach**:
```dart
// In ChatBloc constructor
on<ChatSearchUsersRequested>(
  (event, emit) async {
    emit(state.copyWith(userSearchLoading: true));
    final users = await _chatService.searchUsers(event.query);
    emit(state.copyWith(
      searchResults: users,
      userSearchLoading: false,
    ));
  },
  transformer: (events, mapper) => events
      .debounceTime(const Duration(milliseconds: 400))
      .switchMap(mapper),
);
```

**Alternatives Considered**:
- Widget-level Timer debouncing: Rejected (violates BLoC-first principle)
- External debounce package: Not needed (bloc provides transformer)

**Dependencies**: None (flutter_bloc already installed)

---

### 2. Multi-Select UI Pattern for Group Conversations

**Decision**: Chips (FilterChip or ChoiceChip) with remove capability

**Rationale**:
- Standard Material Design pattern for multi-select
- Visual feedback (shows selected items prominently)
- Easy to remove selections (tap X icon)
- Matches website UI patterns (tag/chip display)

**Implementation Approach**:
```dart
Wrap(
  spacing: 8,
  children: selectedParticipants.map((user) {
    return Chip(
      label: Text(user.fullName),
      onDeleted: () => removeParticipant(user.userId),
      avatar: CircleAvatar(child: Text(user.firstName[0])),
    );
  }).toList(),
)
```

**Alternatives Considered**:
- Checkbox list: Too verbose for multiple selections
- Multi-select dropdown: Doesn't show selected items well
- Custom widget: Over-engineering for standard pattern

**Dependencies**: None (Material widgets included)

---

### 3. Search Results Display in Dialog

**Decision**: ListView.builder inside dialog with separate loading/empty/error states

**Rationale**:
- Efficient rendering for large result sets (lazy loading)
- Standard Flutter pattern for dynamic lists
- Easy to integrate with BlocBuilder for reactive updates
- Separates concerns (list vs. states)

**Implementation Approach**:
```dart
BlocBuilder<ChatBloc, ChatState>(
  builder: (context, state) {
    if (state.userSearchLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (state.userSearchError != null) {
      return ErrorWidget(
        message: state.userSearchError,
        onRetry: () => context.read<ChatBloc>().add(
          ChatSearchUsersRequested(query: searchQuery),
        ),
      );
    }
    
    if (state.searchResults.isEmpty) {
      return EmptyState(message: 'No users found');
    }
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final user = state.searchResults[index];
        return ListTile(
          title: Text(user.fullName),
          subtitle: Text(user.email),
          onTap: () => selectUser(user),
        );
      },
    );
  },
)
```

**Alternatives Considered**:
- SingleChildScrollView with Column: Bad performance for many results
- GridView: Doesn't fit search result pattern
- Custom scrollable: Over-engineering

**Dependencies**: None

---

### 4. Dialog State Management Strategy

**Decision**: Use existing ChatBloc with new events/state fields for dialog

**Rationale**:
- Maintains single source of truth for chat state
- Avoids creating redundant state containers
- Dialog state is temporary and tied to chat operations
- Enables coordination with conversation list refresh

**New ChatBloc Events**:
- `ChatSearchUsersRequested(String query)`
- `ChatUserSelected(ChatUserModel user)`
- `ChatUserDeselected(int userId)`
- `ChatConversationModeChanged(String mode)` // 'direct' or 'group'
- `ChatStartConversationRequested({participants, type, groupName, message})`
- `ChatNewConversationDialogReset()`

**New ChatState Fields**:
```dart
final List<ChatUserModel> searchResults;
final List<ChatUserModel> selectedParticipants;
final String conversationMode; // 'direct' or 'group'
final bool userSearchLoading;
final String? userSearchError;
final bool creatingConversation;
final String? createConversationError;
```

**Alternatives Considered**:
- Separate DialogCubit: Rejected (introduces state synchronization issues)
- StatefulWidget setState: Rejected (violates BLoC-first principle)
- Form with local state: Rejected (no integration with BLoC)

**Dependencies**: None (extends existing ChatBloc)

---

### 5. Navigation and Coordination After Creation

**Decision**: Event-driven navigation with BlocListener

**Rationale**:
- Separates navigation logic from UI building
- Responds to state changes (conversation created)
- Allows sequential operations (close dialog → refresh → navigate)
- Aligns with BLoC navigation patterns

**Implementation Approach**:
```dart
BlocListener<ChatBloc, ChatState>(
  listenWhen: (prev, curr) => 
    prev.creatingConversation && !curr.creatingConversation,
  listener: (context, state) {
    if (state.createConversationError != null) {
      // Show error, keep dialog open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.createConversationError!)),
      );
    } else if (state.newlyCreatedConversationId != null) {
      // Success flow
      Navigator.of(context).pop(); // Close dialog
      context.read<ChatBloc>().add(
        ChatConversationSelected(state.newlyCreatedConversationId!),
      );
      // ChatBloc automatically refreshes list and navigates
    }
  },
  child: NewConversationDialog(),
)
```

**Sequence**:
1. User taps "Start Conversation"
2. ChatBloc emits `creatingConversation: true`
3. ChatService.startConversation() called
4. On success: ChatBloc emits new state with `newlyCreatedConversationId`
5. BlocListener detects state change
6. Navigator.pop() closes dialog
7. ChatBloc receives ChatConversationSelected event
8. ChatBloc refreshes conversation list and navigates to conversation detail

**Alternatives Considered**:
- Callback-based navigation: Rejected (tight coupling)
- Manual Navigator calls in widget: Rejected (no state tracking)
- Global navigation service: Over-engineering

**Dependencies**: None

---

## Search Result Ordering Implementation

**Decision**: Backend-driven ordering with client-side sort

**Rationale**:
- Backend can perform efficient database queries
- Client applies specified ordering rules (relevance → alphabetical)
- Matches constitution requirement for server-side search

**Implementation**:
```dart
// In ChatService.searchUsers()
final response = await _request(
  method: 'GET',
  path: '/messages/users/search',
  queryParameters: {'query': query, 'limit': limit},
);

// Backend should return ordered results, but client ensures sorting
final users = _extractList(response.data)
    .map(ChatUserModel.fromJson)
    .toList();

// Apply secondary sort if needed
users.sort((a, b) {
  // Exact email match comes first
  final aExact = a.email.toLowerCase() == query.toLowerCase();
  final bExact = b.email.toLowerCase() == query.toLowerCase();
  if (aExact && !bExact) return -1;
  if (!aExact && bExact) return 1;
  
  // Then by name
  return a.fullName.compareTo(b.fullName);
});

return users;
```

---

## Group Participant Validation

**Decision**: Client-side validation before API call

**Rationale**:
- Immediate user feedback (no network round-trip)
- Reduces unnecessary API calls
- Matches UI requirements for minimum 3 participants

**Implementation**:
```dart
Future<void> _startConversation() async {
  // Validation
  if (conversationMode == 'group') {
    if (selectedParticipants.length < 2) {
      emit(state.copyWith(
        createConversationError: 'Groups require at least 3 participants',
      ));
      return;
    }
    
    if (groupName.isEmpty) {
      emit(state.copyWith(
        createConversationError: 'Group name is required',
      ));
      return;
    }
  }
  
  if (selectedParticipants.isEmpty) {
    emit(state.copyWith(
      createConversationError: 'Select at least one participant',
    ));
    return;
  }
  
  // Proceed with API call...
}
```

---

## Error Handling with Retry

**Decision**: Error state with explicit retry button

**Rationale**:
- User has control over retry timing
- Preserves all form data (constitution requirement)
- Avoids automatic retry loops on persistent errors

**Implementation**:
- Error message displayed in dialog
- "Retry" button triggers same event again
- All form fields remain populated
- Clear error state before retry attempt

---

## Dependencies Summary

**No new dependencies required**. All patterns use existing packages:
- flutter_bloc (already in pubspec.yaml)
- Material Design widgets (Flutter SDK)
- dio (already in pubspec.yaml for ChatService)

---

## Alignment with Constitution

✅ **I. BLoC State Management First**: All state in ChatBloc, no widget-level API calls  
✅ **II. Strict Data Layer Separation**: ChatService handles API, ChatBloc manages state  
✅ **III. Type Safety & Error Handling**: Explicit error states with retry  
✅ **IV. Website Feature Parity**: Multi-select chips match website UI  
✅ **V. Testable Architecture**: All logic in testable BLoC/Service layers  
✅ **VI. Real-Time Communication Integrity**: N/A for this phase  
✅ **VII. Static Data Elimination**: No mock data, all real API calls  
✅ **VIII. Aggressive Clarification**: All decisions documented with rationale

---

## Next Steps

Phase 1 will define:
- ChatUserModel structure (if not already exists)
- New ChatBloc events and state fields
- Dialog widget contract (props, callbacks)
- Integration with existing shared widgets
