# Data Model: New Conversation Flow

**Feature**: Phase 5 - New Conversation Flow  
**Date**: 2026-04-07

## Overview

This document defines the data structures and state management contracts for the new conversation creation feature. All models extend existing chat models in `lib/bloc/chat/chat_models.dart`.

---

## Existing Models (Used Unchanged)

### ChatUserModel

**Purpose**: Represents a user that can be searched and added to conversations

**Location**: `lib/bloc/chat/chat_models.dart` (already exists)

**Properties**:
```dart
class ChatUserModel extends Equatable {
  final int userId;           // Backend user ID
  final String? firstName;    // User's first name
  final String? lastName;     // User's last name
  final String? fullName;     // Pre-computed full name from backend
  final String? email;        // User's email address
  
  String get displayName;     // Computed: fullName > firstName+lastName > email > "User {id}"
}
```

**Usage in Feature**:
- Search results from `/api/messages/users/search`
- Selected participants for new conversation
- Self-user display in search results

**Validation Rules**:
- `userId` must be positive integer
- At least one of `fullName`, `firstName`, or `email` should be present for display

---

### ConversationModel

**Purpose**: Represents a chat conversation (direct or group)

**Location**: `lib/bloc/chat/chat_models.dart` (already exists)

**Properties**:
```dart
class ConversationModel extends Equatable {
  final int conversationId;           // Unique conversation ID
  final ConversationType type;         // 'direct' or 'group'
  final String? name;                  // Group name (null for direct)
  final List<int> participants;        // List of participant user IDs
  final List<ChatUserModel> participantUsers;  // Full user objects
  final ChatUserModel? directDisplayUser;      // For direct chats: the other person
  final String? lastMessage;                   // Last message text
  final ChatMessageModel? lastMessageInfo;     // Full last message object
  final int unreadCount;                       // Unread message count
  final DateTime? lastMessageAt;               // Timestamp of last activity
}
```

**Usage in Feature**:
- Result of creating new conversation
- Detecting existing conversation (backend returns `existing: true`)
- Adding to conversation list after creation

---

### ConversationType

**Purpose**: Enum for conversation types

**Location**: `lib/bloc/chat/chat_models.dart` (already exists)

**Values**:
```dart
enum ConversationType {
  direct,   // One-on-one conversation
  group;    // Multi-participant conversation (3+ total)
}
```

**Validation Rules**:
- Group conversations: minimum 3 total participants (creator + 2 others)
- Direct conversations: exactly 2 participants

**Note on terminology**: 
- `ConversationType` enum (defined here) is used in backend API responses and ConversationModel for data persistence
- `conversationMode` string field ('direct' or 'group') is used in ChatState for UI state management during dialog interaction
- Both represent the same concept but at different layers: ConversationType for data/model layer, conversationMode for presentation layer

---

## ChatBloc State Extensions

### New State Fields

Add to existing `ChatState` class:

```dart
class ChatState extends Equatable {
  // ... existing fields ...
  
  // User search state
  final List<ChatUserModel> searchResults;
  final bool userSearchLoading;
  final String? userSearchError;
  final String? lastSearchQuery;
  
  // New conversation dialog state
  final List<ChatUserModel> selectedParticipants;
  final String conversationMode;  // 'direct' or 'group'
  final String? groupNameInput;
  final String? initialMessageInput;
  
  // Conversation creation state
  final bool creatingConversation;
  final String? createConversationError;
  final int? newlyCreatedConversationId;
  
  const ChatState({
    // ... existing parameters ...
    this.searchResults = const [],
    this.userSearchLoading = false,
    this.userSearchError,
    this.lastSearchQuery,
    this.selectedParticipants = const [],
    this.conversationMode = 'direct',
    this.groupNameInput,
    this.initialMessageInput,
    this.creatingConversation = false,
    this.createConversationError,
    this.newlyCreatedConversationId,
  });
}
```

**Field Descriptions**:

- `searchResults`: List of users matching current search query (max 20)
- `userSearchLoading`: True while search API call is in progress
- `userSearchError`: Error message if search fails (null if no error)
- `lastSearchQuery`: Last query string (used for retry on error)
- `selectedParticipants`: Users selected for the new conversation (corresponds to "Conversation Participant" entity in spec.md - this is the implementation representation of that conceptual entity)
- `conversationMode`: Current mode ('direct' or 'group')
- `groupNameInput`: Group name entered by user (required for groups)
- `initialMessageInput`: Optional first message text
- `creatingConversation`: True while conversation creation API call is in progress
- `createConversationError`: Error message if creation fails (null if no error)
- `newlyCreatedConversationId`: ID of conversation just created (triggers navigation)

---

## ChatBloc Events

### New Events

Add to `lib/bloc/chat/chat_event.dart`:

```dart
// User search events
class ChatSearchUsersRequested extends ChatEvent {
  final String query;
  const ChatSearchUsersRequested(this.query);
  @override
  List<Object> get props => [query];
}

class ChatSearchUsersCleared extends ChatEvent {
  const ChatSearchUsersCleared();
  @override
  List<Object> get props => [];
}

// Participant selection events
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

// Conversation mode events
class ChatConversationModeChanged extends ChatEvent {
  final String mode;  // 'direct' or 'group'
  const ChatConversationModeChanged(this.mode);
  @override
  List<Object> get props => [mode];
}

// Conversation creation events
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

// Dialog reset event
class ChatNewConversationDialogReset extends ChatEvent {
  const ChatNewConversationDialogReset();
  @override
  List<Object> get props => [];
}
```

---

## Request/Response Contracts

### User Search Request

**Endpoint**: `GET /api/messages/users/search`

**Query Parameters**:
```dart
{
  'query': String,      // Email or name search term
  'limit': int,         // Maximum results (default: 20)
}
```

**Response Body**:
```dart
[
  {
    "userId": 123,
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "email": "john.doe@example.com"
  },
  // ... more users
]
```

**Mapped to**: `List<ChatUserModel>`

---

### Start Conversation Request

**Endpoint**: `POST /api/messages/conversations`

**Request Body**:
```dart
{
  "participantIds": [int],   // List of user IDs to include
  "type": String,             // "direct" or "group"
  "groupName": String?,       // Required for groups
  "text": String?,            // Optional first message
  "fileId": int?,             // Optional (not used in Phase 5)
}
```

**Success Response** (New Conversation):
```dart
{
  "conversationId": 456,
  "type": "direct",
  "participants": [123, 789],
  "participantUsers": [ /* ChatUserModel objects */ ],
  "directDisplayUser": { /* ChatUserModel */ },
  "unreadCount": 0,
  "lastMessageAt": "2026-04-07T14:30:00Z",
  // ... other ConversationModel fields
}
```

**Success Response** (Existing Conversation):
```dart
{
  "existing": true,
  "conversationId": 456,
  // ... full ConversationModel as above
}
```

**Mapped to**: `ConversationModel`

---

## Validation Rules

### Client-Side Validation

**Before Search**:
- Query must be at least 1 character
- Debounce 400ms after last keystroke

**Before Conversation Creation**:
```dart
// Direct mode
if (mode == 'direct') {
  assert(selectedParticipants.length == 1, 'Direct conversations require exactly 1 participant');
}

// Group mode
if (mode == 'group') {
  assert(selectedParticipants.length >= 2, 'Groups require at least 2 other participants (3 total)');
  assert(groupName != null && groupName.isNotEmpty, 'Group name is required');
}

// Common
assert(selectedParticipants.isNotEmpty, 'At least one participant must be selected');
```

**Search Result Ordering**:
1. Exact email matches first
2. Partial email matches second
3. Name matches third
4. Within each group: alphabetical by full name

---

## State Transitions

### User Search Flow

```
Initial State
  ↓ ChatSearchUsersRequested("john")
Loading State (userSearchLoading: true)
  ↓ Search API call completes
Results State (searchResults: [user1, user2], userSearchLoading: false)
  ↓ User selects result
Updated State (selectedParticipants: [user1])
```

### Conversation Creation Flow

```
Dialog Open State (selectedParticipants: [user1])
  ↓ ChatStartConversationRequested()
Creating State (creatingConversation: true)
  ↓ API call completes successfully
Success State (
  creatingConversation: false,
  newlyCreatedConversationId: 456,
  createConversationError: null
)
  ↓ BlocListener triggers navigation
Navigated State (newlyCreatedConversationId: null - cleared after navigation)
```

### Error Recovery Flow

```
Error State (createConversationError: "Network error")
  ↓ User taps "Retry"
Creating State (creatingConversation: true, createConversationError: null)
  ↓ API call completes
Success or Error State (same as above)
```

---

## Entity Relationships

```
ChatUserModel (1) ←→ (*) ConversationModel.participantUsers
ConversationModel (1) ←→ (1) ConversationType
ConversationModel (1) ← (0..1) ChatUserModel.directDisplayUser

ChatState contains:
  - searchResults: List<ChatUserModel>
  - selectedParticipants: List<ChatUserModel>
  - conversations: List<ConversationModel> (existing field)
```

---

## Immutability and Copying

All models use `Equatable` and `copyWith` patterns:

```dart
// Example: Adding a participant
emit(state.copyWith(
  selectedParticipants: [...state.selectedParticipants, newUser],
));

// Example: Removing a participant
emit(state.copyWith(
  selectedParticipants: state.selectedParticipants
      .where((u) => u.userId != removedUserId)
      .toList(),
));
```

---

## Error Handling

**Network Errors**:
- Caught in try-catch blocks in event handlers
- Emitted as error string in state
- Preserved form data (participants, groupName, message)
- User can retry with "Retry" button

**Validation Errors**:
- Checked before API calls
- Emitted as `createConversationError` string
- Examples: "Groups require at least 3 participants", "Group name is required"

**Backend Errors**:
- HTTP error responses parsed from Dio exceptions
- User-friendly messages displayed
- Original error logged for debugging

---

## Testing Considerations

**Testable Scenarios**:
- Search debouncing (ensure 400ms delay)
- Participant selection/deselection
- Mode toggle (direct ↔ group)
- Validation rules (group size, group name)
- API error handling with retry
- Existing conversation detection
- Navigation after creation

**Mock Data** (Test Only):
```dart
final mockSearchResults = [
  ChatUserModel(userId: 1, fullName: 'Alice', email: 'alice@example.com'),
  ChatUserModel(userId: 2, fullName: 'Bob', email: 'bob@example.com'),
];

final mockCreatedConversation = ConversationModel(
  conversationId: 123,
  type: ConversationType.direct,
  participants: [1, 2],
  participantUsers: mockSearchResults,
  unreadCount: 0,
);
```

---

## Next Steps (Phase 2 - Tasks)

Tasks will decompose implementation into:
1. Extend ChatState with new fields
2. Add new ChatEvent classes
3. Implement event handlers in ChatBloc
4. Create SharedNewChatDialog widget
5. Integrate dialog with existing chat screen
6. Write unit tests for BLoC logic
7. Write widget tests for dialog
