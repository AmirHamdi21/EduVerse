# Widget Contracts: Unified Chat UI — Conversation List

These are internal UI contracts (Flutter Widget APIs) replacing the former role-based screens.

## Shared components replacing legacy widgets

1. `SharedChatHeader` → Replaces `AdminChatHeader`, `InstructorChatHeader`, etc.
2. `SharedChatSearchBar` → Replaces inline `TextField`s used previously.
3. `SharedChatFilterChips` → Replaces specific "role" toggle tabs.
4. `SharedConversationTile` → Replaces `ConversationItem`, `AdminMessageTile`, etc., adding `onPin`, `onMute`, `onDelete` swipe actions.
5. `SharedConversationList` → Consumes `BlocBuilder<ChatBloc, ChatState>` globally.

These widgets are explicitly built to depend on `lib/bloc/chat/chat_bloc.dart` natively.