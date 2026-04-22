# Data Models: Unified Chat UI — Conversation List

The UI components in Phase 3 do not introduce any new backend REST or WebSocket domain models. They exclusively consume the unified models constructed during Phase 2:
- `ConversationModel`
- `ChatMessageModel`
- `ChatUserModel`

## UI View Models / Component Props

Though not persisted models, the new unified components will expect standard UI prop signatures to ensure they can be themed and dynamically rendered per user role:

### `SharedChatHeader`
- `connectionStatus`: `ConnectionStatus` (Live | Offline)
- `accentColor`: `Color` (Inherited from Role Theme)
- `onNewChatTapped`: `VoidCallback` (Triggers `showModalBottomSheet`)
- `onSearchToggled`: `VoidCallback`

### `SharedChatSearchBar`
- `searchQuery`: `String`
- `onQueryChanged`: `ValueChanged<String>`

### `SharedChatFilterChips`
- `currentFilter`: `ChatListFilter` (All | Unread | Groups)
- `onFilterSelected`: `ValueChanged<ChatListFilter>`

### `SharedConversationTile`
- `conversation`: `ConversationModel` (The data source)
- `onTapped`: `VoidCallback`
- `onPinTapped`: `VoidCallback` (Swipe Action)
- `onMuteTapped`: `VoidCallback` (Swipe Action)
- `onDeleteTapped`: `VoidCallback` (Swipe Action)
- `isDark`: `bool`

### UI State Enums (for local component toggling)

```dart
enum ChatListFilter {
  all,
  unread,
  groups
}
```