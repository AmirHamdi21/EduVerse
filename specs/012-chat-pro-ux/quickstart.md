
# Quickstart Guide: Phase 7 Pro Chat UX

This phase enhances the chat UX with three key deliverables: explicit online statuses (`lastSeen`), a full-screen new conversation picker with search, and an interactive user profile panel for easy cross-referencing and replies.

## Setup Requirements

1. **Backend Running**: The NestJS WebSocket namespace (`/messaging`) must be active for `get_online_users` and `user_status` testing.
2. **REST API endpoints**: Ensure `GET /api/messages/users/search` is functioning for the generic search tests.

## Key Changes

1. **State Modifications**: `ChatBloc` requires new events and fields managing the `userLastSeen` and `participantCache` map.
2. **UI Replacements**: Remove the `SharedNewChatDialog` entirely and wire the `+` header button to open `NewConversationScreen`.
3. **Navigation**: Update the generic Router logic to support opening `UserProfileScreen(userId)`.

## Recommended Workflow

1. Start by extending `ChatState` and `ChatBloc` with the real-time presence fields (`onlineUsers` fetching + `userLastSeen`).
2. Upgrade the `chat_socket_service.dart` to emit `get_online_users` and listen for `online_users_list` arrays.
3. Once presence is working, tackle the "Reply to Unknown" participant hydration in the `ChatMessageModel`.
4. Delete the old `SharedNewChatDialog` and construct the full-screen `NewConversationScreen`.
5. Finish with the `UserProfileScreen` accessible by tapping avatars.
