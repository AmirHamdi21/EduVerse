# Phase 9: Chat Cleanup, Caching & Polish — Implementation Plan

**Feature**: 014-chat-cleanup-polish | **Date**: 2026-04-09

> **Goal**: Make the chat module offline-first with stale-while-revalidate caching, eliminate all remaining mock data, polish UX (new messages indicator, connection badge), and ensure strict feature parity with the React website.

---

## User Review Required

> [!IMPORTANT]
> The connection status badge (Live/Offline/Connecting) is **already implemented** in both `shared_chat_header.dart` (line 75–99) and `shared_chat_detail_view.dart` (line 529–563). No implementation changes are needed for the badge itself; verification maps to FR-003/SC-003. FR-014/FR-015 are validated separately via event and role-parity tasks.

> [!IMPORTANT]
> The auth interceptor (`auth_interceptor.dart`) and socket reconnect (`chat_socket_service.dart`) already handle token refresh. FR-012 is already satisfied — only verification needed.

> [!WARNING]
> The `AuthBloc._onLogoutRequested` calls `_storageService.clearAll()` which only clears `FlutterSecureStorage` keys (tokens + user data). It does **NOT** clear `SharedPreferences` keys used for chat caching and local preferences (pinned/muted/hidden conversations). A new `clearChatCache()` method must be added and called on logout.

---

## Proposed Changes

### Component 1: StorageService — Chat Cache Layer

Summary: Extend `StorageService` with dedicated methods for reading, writing, and clearing cached chat data from `SharedPreferences`. This creates the persistence layer that the BLoC will use for stale-while-revalidate.

#### [MODIFY] storage_service.dart

**What changes:**
1. Add import for `shared_preferences/shared_preferences.dart`
2. Add 3 cache key constants:
   - `_cachedConversationsKey = 'chat_cached_conversations'`
   - `_cachedMessagesPrefix = 'chat_cached_messages_'`
   - `_chatPrefKeys` (list of all chat-related SharedPreferences keys for bulk clear)
3. Add methods:
   - `Future<bool> cacheConversations(String jsonString)` — writes serialized conversation list and returns write success
   - `Future<String?> getCachedConversations()` — reads cached conversation JSON
   - `Future<bool> cacheMessages(int conversationId, String jsonString)` — writes serialized messages for a thread and returns write success
   - `Future<String?> getCachedMessages(int conversationId)` — reads cached messages for a thread
   - `Future<void> clearChatCache()` — removes all `chat_cached_*` keys AND the local preference keys (`chat_pinned_*`, `chat_muted_*`, `chat_hidden_*`) from SharedPreferences
4. In ChatBloc cache orchestration, apply a fixed conversation-cache write guard before calling storage writes: persist at most 200 conversations per write to maintain predictable deserialization performance.
5. Cache write methods MUST never throw. They return `false` on failure so `ChatBloc` can emit the FR-018 non-blocking warning toast deterministically.

---

### Component 2: ChatBloc — Stale-While-Revalidate Orchestration

#### [MODIFY] chat_bloc.dart

**What changes in `_onLoadConversations`:**
1. Before the API call, read `_storageService.getCachedConversations()`
2. If cached data exists and `state.conversations` is empty, deserialize and emit it immediately with `ChatStatus.success`
3. After successful API fetch, write the fresh data to cache
4. If cache write fails, emit a non-blocking error but keep the fresh API data
5. On API failure, if cached data was already emitted, keep it visible

**What changes in `_onSelectConversation`:**
1. Before the API call, read `_storageService.getCachedMessages(conversationId)`
2. If cached messages exist, emit them immediately
3. After successful API fetch, write to cache (cap at 50 messages per thread)

**New event handler — `_onClearChatCache`:**
1. Calls `await _storageService.clearChatCache()`
2. Resets BLoC state to initial

**Debounce adjustment:**
- Change `Duration(milliseconds: 280)` → `Duration(milliseconds: 300)`

#### [MODIFY] chat_event.dart
Add `ClearChatCache` event class.

---

### Component 3: AuthBloc — Logout Cache Clearing

#### [MODIFY] auth_bloc.dart
In the `finally` block of `_onLogoutRequested`, add `_storageService.clearChatCache()` call.

---

### Component 4: SharedChatDetailView — New Messages Floating Indicator

#### [MODIFY] shared_chat_detail_view.dart
1. Track scroll position and `_isNearBottom` state
2. Replace unconditional auto-scroll with conditional logic
3. Add floating "↓ New messages" chip overlay
4. Add `_NewMessagesIndicator` private widget
5. Add in-conversation empty message state ("No messages yet — say hello! 👋") when `messages.isEmpty` and `status == success`
6. Add in-conversation error state with "Try again" button when `status == failure` during message loading (FR-013 coverage)

---

### Component 5: SharedChatEmptyState — Error & Offline Variants

#### [MODIFY] shared_chat_empty_state.dart
Add parameters: `isError`, `isOffline`, `searchQuery`, `onRetry`. Branch build on priority: error > offline > search > filtered > default.

#### [MODIFY] shared_conversation_list.dart
Pass new error/offline/search parameters to `SharedChatEmptyState`.

---

## Files Modified Summary

| # | File | Change Type | Effort |
|---|---|---|---|
| 1 | `lib/services/storage_service.dart` | Add cache methods | Medium |
| 2 | `lib/bloc/chat/chat_bloc.dart` | Stale-while-revalidate + ClearChatCache | Large |
| 3 | `lib/bloc/chat/chat_event.dart` | Add ClearChatCache event | Small |
| 4 | `lib/bloc/auth/auth_bloc.dart` | Call clearChatCache on logout | Small |
| 5 | `lib/widgets/shared/chat/shared_chat_detail_view.dart` | New messages indicator | Medium |
| 6 | `lib/widgets/shared/chat/shared_chat_empty_state.dart` | Error/offline/search variants | Medium |
| 7 | `lib/widgets/shared/chat/shared_conversation_list.dart` | Pass error/offline params | Small |

**Total**: 7 core files modified, 0 new files, 0 required deletions. Optional scoped dead-file cleanup may occur if confirmed during audit.
