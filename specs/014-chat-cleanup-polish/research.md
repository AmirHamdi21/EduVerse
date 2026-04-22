# Research: Chat Cleanup, Caching & Polish

**Branch**: `014-chat-cleanup-polish` | **Date**: 2026-04-09

---

## 1. Caching Strategy

### Decision: SharedPreferences with JSON serialization (stale-while-revalidate)

**Rationale:** `SharedPreferences` is already used in the project (`shared_conversation_list.dart` lines 4, 73, 95) for conversation list order persistence. Using the same storage mechanism avoids adding new dependencies. The caching layer stores serialized JSON for conversations and message pages.

**Alternatives considered:**
- **Hive**: More performant for large datasets, but adds a new dependency and setup complexity for a simple cache of ≤50 items per key
- **sqflite**: Relational DB is overkill for a read-through cache of serialized JSON lists
- **Isar**: New dependency, Flutter-specific binary DB; unnecessary for this scope

**Cache keys:**
- `chat_cached_conversations` → JSON-encoded `List<ConversationModel>`
- `chat_cached_messages_{conversationId}` → JSON-encoded `List<ChatMessageModel>` (last 50)

**Lifecycle rules (from clarification):**
- Stale-while-revalidate: always show cached data, replace silently on fresh fetch
- Clear all chat cache on logout (`FR-017`)
- Skip cache writes on storage failure, show toast (`FR-018`)

---

## 2. Cache Clearing on Logout

### Decision: Add `clearChatCache()` to `StorageService`, call from `AuthBloc._onLogoutRequested`

**Rationale:** `AuthBloc._onLogoutRequested` (line 324–339) already calls `_storageService.clearAll()`, which deletes tokens and user data from `FlutterSecureStorage`. However, `SharedPreferences` keys are NOT cleared by `FlutterSecureStorage.clearAll()`. A new `clearChatCache()` method on `StorageService` must explicitly remove all `chat_cached_*` keys from `SharedPreferences`.

**Alternative:** Call `SharedPreferences.clear()` — rejected because it would wipe non-chat preferences (dark mode, font size).

---

## 3. Mock Data Audit

### Decision: No chat-specific mock data remains; audit confirms clean state

**Research finding:** Grepping for `generateSample|simulateReply|mockConversations|_generateSample|_simulateReply|_mockMessages` found matches only in `profile_cubit.dart`, `notification_cubit.dart`, and `ai_notes_cubit.dart` — all outside chat scope. No mock data exists in any chat BLoC, service, widget, or model file.

**`ConversationType.course`:** Grepping for `ConversationType.course|ChatFilter.courses|ChatFilter.instructors|ChatFilter.students` returned zero results. These were already removed in earlier phases.

**Swipe settings:** Per clarification Q5, `chat_swipe_settings_screen.dart` and `chat_swipe_action_model.dart` are retained as accepted Flutter-only mobile UX enhancements.

---

## 4. Connection Status UI

### Decision: Use existing `ConnectionStatus` enum from `ChatState` + existing `ChatSocketService` connection stream

**Current state:** `ChatSocketService` already emits `ChatConnectionStatus.connected/disconnected/reconnecting` via `connectionStatus` stream. `ChatBloc` maps this to `ConnectionStatus.live/offline/connecting` in state. Both `SharedChatHeader` and `SharedChatDetailView` render the connection badge variants.

**Required changes:**
- No new implementation required; verification-only coverage is handled in tasks for FR-003/SC-003 and parity checks.

---

## 5. Empty States Audit

### Decision: Existing empty state widget needs enhancement for network errors and first-run offline

**Current state:** `shared_chat_empty_state.dart` exists but originally only handled the "no conversations" case. Missing states identified for implementation:
- Network error with "Try again" action (FR-005, FR-013)
- First-run offline: "A connection is needed to load chats for the first time" (User Story 1, Scenario 4)
- No search results: "No results for '…'" (User Story 3, Scenario 2)
- Discussion empty states: `shared_discussion_empty_state.dart` exists but needs audit

---

## 6. Token Refresh Integration

### Decision: Already implemented — no new work needed

**Research finding:** `AuthInterceptor` (line 37–106) already handles 401 errors by refreshing the token and retrying the request. `ChatSocketService._handleConnectError` (line 471–478) already detects token/auth errors and calls `_refreshTokenAndReconnect()` (line 481–526). Both flows use `StorageService` to persist refreshed tokens.

**FR-012 is already satisfied.** Verification is needed during testing but no code changes required.

---

## 7. Debounce Implementation

### Decision: Search debounce already implemented at BLoC level; typing indicator also implemented

**Research finding:**
- `ChatSearchUsersRequested` uses `debounce(const Duration(milliseconds: 280))` transformer (line 102–105)
- `_onTypingChanged` uses a 1500ms timer for auto-stop (lines 733–747)
- Conversation search (`SearchConversations`) is a local filter, no debounce needed

**FR-006 status:** Search debounce must be exactly 300ms to match the spec and task coverage.
**FR-007 status:** Already satisfied (1500ms timer).

---

## 8. Pagination

### Decision: Message pagination already implemented; conversation lazy-loading requires explicit FR-009 threshold validation

**Research finding:**
- `LoadMoreMessages` event and `_onLoadMoreMessages` handler exist (lines 332–371)
- `SharedConversationList` uses `ListView.builder` which is inherently lazy
- No explicit server-side pagination exists for the conversation list endpoint (`GET /api/messages/conversations` returns all conversations)
- `ListView.builder` alone is not the FR-009 acceptance gate; explicit threshold behavior is verified via dedicated task coverage (T016b)

---

## 9. New Messages Floating Indicator

### Decision: Add scroll-position tracking to `SharedChatDetailView` with a "↓ New messages" FAB

**Rationale (from clarification Q4):** When the user is scrolled up viewing history, incoming messages must be buffered without auto-scrolling. A floating indicator shows the count of new messages. Tapping it scrolls to bottom.

**Implementation approach:** Track `ScrollController.position` in `SharedChatDetailView`. When user is scrolled up >200px from bottom and new messages arrive, show a floating chip instead of auto-scrolling.

---

## 10. Parity Audit - WebSocket Events

### Decision: All backend events are handled

| Backend Event | Handled in ChatBloc? | Status |
|---|---|---|
| `new_message` | ✅ line 761 | Complete |
| `message_sent` | ✅ via `newMessageStream` (socket service line 379) | Complete |
| `new_message_notification` | ✅ line 155 | Complete |
| `user_typing` | ✅ line 794 | Complete |
| `message_deleted` | ✅ line 817 | Complete |
| `delete_confirmed` | ✅ line 818 | Complete |
| `message_edited` | ✅ line 835 | Complete |
| `user_status` | ✅ line 865 | Complete |
| `message_read` | ✅ line 203 | Complete |
| `online_users_list` | ✅ line 893 | Complete |
