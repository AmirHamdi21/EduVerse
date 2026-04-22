
# Data Models: Pro Chat UX Enhancements

## Core State Additions (`ChatState`)

The `ChatState` will be extended to track the newly implemented features natively inside `ChatBloc`:

```dart
// lib/bloc/chat/chat_state.dart

class ChatState extends Equatable {
  // Existing fields...
  final Set<int> onlineUsers;
  
  // NEW: Track last seen timestamps for offline users
  final Map<int, DateTime> userLastSeen;
  
  // NEW: Track Frequently Contacted Users (derived from conversations)
  final List<ChatUserModel> frequentlyContacted;
  
  // NEW: Search results for New Conversation Flow
  final List<ChatUserModel> contactSearchResults;
  
  // NEW: Participant Cache for quick replies
  final Map<int, ChatUserModel> participantCache;

  // Constructor, copyWith, equatable props...
}
```

## User Profile Context Model

While `ChatUserModel` handles raw data from the API, the UI requires derived presentation models.

```dart
// lib/models/chat/user_profile_context.dart

class UserProfileContext {
  final int userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? role; 
  
  final bool isOnline; // Derived from ChatState.onlineUsers
  final DateTime? lastSeen; // Derived from ChatState.userLastSeen
  
  final List<ConversationModel> commonGroups; // Derived from ChatState.conversations

  const UserProfileContext({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.role,
    required this.isOnline,
    this.lastSeen,
    required this.commonGroups,
  });
}
```

## Hydrated Message Reply State

The original `ChatMessageModel` contains an integer `replyToId`. To solve "Reply to Unknown", we introduce a hydrated extension accessible inside the View:

```dart
extension HydratedMessage on ChatMessageModel {
  /// Resolves the name of the sender who wrote the replied-to message.
  /// Needs access to the participantCache from ChatState.
  String hydratedReplyToName(Map<int, ChatUserModel> participantCache) {
    if (replyToId == null) return null;
    
    // Logic to find message sender by ID in participantCache
    // If not found -> "Unknown User"
  }
}
```
