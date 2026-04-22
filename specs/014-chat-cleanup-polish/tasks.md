# Tasks: Chat Cleanup, Caching & Polish (Phase 9)

**Input**: Design documents from `/specs/014-chat-cleanup-polish/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md
**Reference Docs**: `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md`, `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md`, `Flutter_Chat_API_Docs_BACKEND.md`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: No new packages needed. Verify existing `shared_preferences` dependency is present in `pubspec.yaml` and confirm all prerequisite files exist.

- [X] T001 Verify that `shared_preferences` is listed in `pubspec.yaml` dependencies. If missing, add it. Run `flutter pub get` to ensure all dependencies are resolved. File: `pubspec.yaml`
- [X] T002 Read the current `lib/services/storage_service.dart` and confirm it imports `flutter_secure_storage` and has methods `clearAll()`, `getAccessToken()`, `saveTokens()`. This is the file we will extend in Phase 2. File: `lib/services/storage_service.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the cache persistence layer and the BLoC event that all user stories depend on. These MUST be complete before any user story work begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 [P] Add chat cache methods to `StorageService`. Open `lib/services/storage_service.dart` and add, after line 1 (`import 'package:flutter_secure_storage/flutter_secure_storage.dart';`), a new import: `import 'package:shared_preferences/shared_preferences.dart';`. Then add 3 new constant keys after line 12 (`static const String _fontSizeKey = 'font_size';`):
  ```dart
  static const String _cachedConversationsKey = 'chat_cached_conversations';
  static const String _cachedMessagesPrefix = 'chat_cached_messages_';
  ```
  Then append the following 5 new methods after the `getFontSize()` method (after line 82):
  1. `Future<bool> cacheConversations(String jsonString)` — wraps `SharedPreferences.getInstance()` then `prefs.setString(_cachedConversationsKey, jsonString)` and returns `true` on success, `false` on failure (must not throw).
  2. `Future<String?> getCachedConversations()` — reads from SharedPreferences using `_cachedConversationsKey`. Returns null on any exception.
  3. `Future<bool> cacheMessages(int conversationId, String jsonString)` — writes to key `'$_cachedMessagesPrefix$conversationId'` and returns `true` on success, `false` on failure (must not throw).
  4. `Future<String?> getCachedMessages(int conversationId)` — reads from key `'$_cachedMessagesPrefix$conversationId'`. Returns null on any exception.
  5. `Future<void> clearChatCache()` — gets SharedPreferences instance, then removes keys: `_cachedConversationsKey`, and iterates all keys matching prefix `_cachedMessagesPrefix` to remove them. Also removes `'chat_pinned_conversation_ids'`, `'chat_muted_conversation_ids'`, `'chat_hidden_conversation_ids'`. Silently catches exceptions.
  Do NOT modify any existing methods. File: `lib/services/storage_service.dart`

- [X] T004 [P] Add `ClearChatCache` event class to `lib/bloc/chat/chat_event.dart`. Append the following class at the end of the file (after the last event class):
  ```dart
  class ClearChatCache extends ChatEvent {
    const ClearChatCache();
  }
  ```
  Do NOT modify any existing event classes. File: `lib/bloc/chat/chat_event.dart`

- [X] T005 Register the `ClearChatCache` event handler in `ChatBloc`. Open `lib/bloc/chat/chat_bloc.dart` and:
  1. In the constructor (around line 78–113), add after `on<HideMessageLocally>(_onHideMessageLocally);` (line 99): `on<ClearChatCache>(_onClearChatCache);`
  2. Update the search debounce from `Duration(milliseconds: 280)` → `Duration(milliseconds: 300)` at line 104 to match spec FR-006.
  3. Append a new handler method after the last handler in the file:
     ```dart
     Future<void> _onClearChatCache(
       ClearChatCache event,
       Emitter<ChatState> emit,
     ) async {
       await _storageService.clearChatCache();
       emit(const ChatState());
     }
     ```
  File: `lib/bloc/chat/chat_bloc.dart`

**Checkpoint**: Foundation ready — cache layer exists, ClearChatCache event is wired. User story implementation can now begin.

---

## Phase 3: User Story 1 — Offline-First Cached Conversations (Priority: P1) 🎯 MVP

**Goal**: Show cached conversations and messages instantly on app launch even without network. Background-refresh silently when connectivity returns.

**Independent Test**: Launch app with connectivity → load conversations → enable airplane mode → kill and relaunch → conversation list renders within 2 seconds using cached data. "Offline" badge visible.

### Implementation for User Story 1

- [X] T006 [US1] Modify `_onLoadConversations` in `lib/bloc/chat/chat_bloc.dart` (lines 210–242) to implement stale-while-revalidate. The modified method must:
  1. Emit `ChatStatus.loading` (existing behavior, keep as-is).
  2. **NEW**: Before the API call, read `_storageService.getCachedConversations()`. If a non-null JSON string is returned AND `state.conversations` is empty, deserialize it using `dart:convert` (`jsonDecode`) and `ConversationModel.fromJson()` for each item. Emit these cached conversations immediately with `ChatStatus.success` so the user sees instant data.
  3. Proceed with the existing API call (`_chatService.listConversations()`).
  4. **On API success** (existing behavior, keep as-is): emit fresh conversations. **NEW**: After emitting, serialize the fresh conversations list to JSON using `jsonEncode(conversations.map((c) => c.toJson()).toList())` and write to cache. **Important (FR-018)**: Use the boolean return from `cacheConversations`; if write fails, emit a non-blocking `errorMessage` in state (e.g., `"Storage full — offline mode unavailable"`) so the UI can show a SnackBar, but do NOT block the fresh data emit:
     ```dart
     final didCache = await _storageService.cacheConversations(jsonString);
     if (!didCache) {
       // FR-018: Emit non-blocking toast — offline mode unavailable
       emit(state.copyWith(
         errorMessage: 'Storage full — offline mode unavailable',
       ));
     }
     ```
  5. **On API failure** (existing catch block): If cached data was already emitted in step 2 (i.e., `state.conversations.isNotEmpty`), do NOT emit `ChatStatus.failure` — keep showing the cached data. Only emit failure with `errorMessage` if no cached data was available.
  6. **Performance note (F1)**: Deserialization of large caches (100+ conversations) must complete within 2 seconds to meet FR-001/SC-001. Apply a fixed guard that caps cached conversations at 200 items before serializing.
  Add `import 'dart:convert';` at the top of the file if not already present.
  File: `lib/bloc/chat/chat_bloc.dart`

- [X] T007 [US1] Modify `_onSelectConversation` in `lib/bloc/chat/chat_bloc.dart` (lines 251–314) to add message caching. The modified method must:
  1. Keep existing behavior (join conversation, emit loading, etc.).
  2. **NEW**: After emitting loading state but before the API call, read `_storageService.getCachedMessages(event.conversationId)`. If non-null, deserialize (using `ChatMessageModel.fromJson()`) and emit these cached messages with `ChatStatus.success` so the user sees instant message content.
  3. Proceed with existing API call (`_chatService.getConversationMessages()`).
  4. **On API success**: Keep existing emit behavior. **NEW**: After emitting fresh messages, take the latest 50 messages (`messages.take(50).toList()` — messages are already sorted newest-first), serialize to JSON, and call `_storageService.cacheMessages(event.conversationId, jsonString)`. Use the boolean return and emit the same non-blocking FR-018 warning path as T006 when write fails:
     ```dart
     final didCache = await _storageService.cacheMessages(event.conversationId, jsonString);
     if (!didCache) {
       emit(state.copyWith(
         errorMessage: 'Storage full — offline mode unavailable',
       ));
     }
     ```
  5. **On API failure**: If cached messages were already emitted, keep them visible instead of emitting failure.
  File: `lib/bloc/chat/chat_bloc.dart`

- [X] T008 [US1] Integrate cache clearing on logout. Open `lib/bloc/auth/auth_bloc.dart` and modify the `_onLogoutRequested` method (lines 324–340). In the `finally` block (line 336), **after** `await _storageService.clearAll();` (line 337), add:
  ```dart
  await _storageService.clearChatCache();
  ```
  This ensures both `FlutterSecureStorage` (tokens, user data) AND `SharedPreferences` (chat cache, pinned/muted/hidden preferences) are wiped on logout, preventing data leakage on shared devices (FR-017).
  File: `lib/bloc/auth/auth_bloc.dart`

- [X] T008a [US1] Validate stale-cache edge case behavior for FR-016. Simulate cached data older than 24 hours with no network and confirm the app still shows cached data (no TTL-based expiry), then silently refreshes when connectivity returns.

**Note**: T009 has been merged into T006 step 4. The FR-018 cache-write-failure handling now uses deterministic boolean return values from storage writes and emits a non-blocking `errorMessage` in BLoC. No separate task is needed.

**Checkpoint**: User Story 1 complete. Cached conversations load offline, fresh data replaces silently, cache clears on logout, and cache write failures produce a non-blocking toast.

---

## Phase 4: User Story 2 — Real-Time Connection Status Feedback (Priority: P1)

**Goal**: Show Live/Offline/Connecting badge in real-time. This is ALREADY IMPLEMENTED in the existing code — this phase is verification only.

**Independent Test**: Disconnect device from network while app is open → verify red "Offline" badge appears within 3 seconds. Reconnect → verify it turns green "Live".

### Verification for User Story 2

- [X] T010 [US2] Verify connection status badge in `lib/widgets/shared/chat/shared_chat_header.dart`. Confirm that lines 75–99 render a colored badge with the `ConnectionStatus` enum (green "Live", amber "Connecting", red "Offline"). Confirm the `_resolveStatus` method (lines 133–142) maps correctly. **No code changes needed** — this task is verification-only. If any mapping is wrong, fix it. File: `lib/widgets/shared/chat/shared_chat_header.dart`

- [X] T011 [US2] Verify connection status badge in conversation detail header `lib/widgets/shared/chat/shared_chat_detail_view.dart`. Confirm the `_ConversationHeader._buildConnectionBadge()` method (lines 529–563) renders the correct badge (green/amber/red) matching the `ConnectionStatus` enum. **No code changes needed** — verification-only. File: `lib/widgets/shared/chat/shared_chat_detail_view.dart`

**Checkpoint**: User Story 2 verified. Connection status badges work correctly.

---

## Phase 5: User Story 3 — Meaningful Empty States & Error Messages (Priority: P2)

**Goal**: Replace blank screens with helpful prompts for no-conversations, no-search-results, network-error, and offline-first-launch scenarios.

**Independent Test**: Sign in as a brand-new user with no messages → chat shows "No conversations yet" with a "Start a new chat" button. Disconnect API server with no cache → shows "Something went wrong" with "Try again".

### Implementation for User Story 3

- [X] T012 [US3] Rewrite `SharedChatEmptyState` to support multiple states. Open `lib/widgets/shared/chat/shared_chat_empty_state.dart` and replace the entire widget with an enhanced version that accepts the following NEW optional parameters (in addition to existing ones):
  - `bool isError` (default: `false`) — when true, shows: icon `Icons.error_outline_rounded`, title "Something went wrong", subtitle based on error message or "We couldn't load your conversations. Please try again.", action button "Try again" calling `onRetry`.
  - `bool isOffline` (default: `false`) — when true, shows: icon `Icons.wifi_off_rounded`, title "You're offline", subtitle "A connection is needed to load chats for the first time.", no action button.
  - `String? searchQuery` (default: `null`) — when non-null and non-empty, shows: icon `Icons.search_off_rounded`, title "No results for '$searchQuery'", subtitle "Try a different search term.", action button "Clear search" calling `onClearFilters`.
  - `VoidCallback? onRetry` (default: `null`) — callback for retry button on error state.
  Build priority order: `isError` > `isOffline` > `searchQuery != null` > `isFiltered` > default (no conversations).
  Keep existing parameters (`isDark`, `isFiltered`, `accentColor`, `onStartNewChat`, `onClearFilters`) working identically for the `isFiltered` and default cases.
  Wrap the content in a `TweenAnimationBuilder<double>` for a subtle fade-in (opacity 0→1, duration 400ms).
  File: `lib/widgets/shared/chat/shared_chat_empty_state.dart`

- [X] T013 [US3] Update `SharedConversationList` to pass new empty state parameters. Open `lib/widgets/shared/chat/shared_conversation_list.dart` and modify the `SharedChatEmptyState` widget usage in the `build()` method (lines 356–368). Pass the new parameters:
  ```dart
  SharedChatEmptyState(
    isDark: widget.isDark,
    isFiltered: isFiltered,
    isError: state.status == ChatStatus.failure,
    isOffline: state.connectionStatus == ConnectionStatus.offline && state.conversations.isEmpty,
    searchQuery: state.conversationSearchQuery.trim().isNotEmpty ? state.conversationSearchQuery : null,
    accentColor: widget.accentColor,
    onStartNewChat: _openNewConversationScreen,
    onClearFilters: _clearFilters,
    onRetry: () => context.read<ChatBloc>().add(const LoadConversations()),
  )
  ```
  Do NOT change other parts of the widget. File: `lib/widgets/shared/chat/shared_conversation_list.dart`

- [X] T013b [US3] Verify or implement empty message state inside `SharedChatDetailView`. Open `lib/widgets/shared/chat/shared_chat_detail_view.dart` and confirm that when `state.activeConversationMessages.isEmpty` AND `state.status == ChatStatus.success` (i.e., messages loaded but none exist), the message list area shows a friendly placeholder such as "No messages yet — say hello! 👋" instead of a blank white area. If this empty state does not exist, add it as a `Center` widget inside the `_MessageList` builder when the messages list is empty. Also confirm that when `state.status == ChatStatus.failure` during message loading, an error state with a "Try again" button is shown (FR-013 coverage for message detail view, not just conversation list). File: `lib/widgets/shared/chat/shared_chat_detail_view.dart`

- [X] T013c [US3] Verify search-clear edge case behavior. When the search query is cleared (delete text or tap clear), confirm the full conversation list is restored immediately with no delayed stale filter state.

**Checkpoint**: User Story 3 complete. All five empty/error states display correctly, including in-conversation empty and error states.

---

## Phase 6: User Story 4 — Smooth and Performant Chat Interactions (Priority: P2)

**Goal**: Ensure smooth scrolling, debounced search, typing indicator auto-stop, and new messages floating indicator.

**Independent Test**: Open a conversation → scroll up 5+ screens → have another user send 3 messages → "↓ 3 new messages" chip appears → tap it → scrolls to bottom.

### Implementation for User Story 4

- [X] T014 [US4] Add scroll position tracking and new messages indicator to `SharedChatDetailView`. **Dependency**: T015 (the `_NewMessagesIndicator` widget class) MUST be implemented first or alongside this task, as T014 references the widget. Open `lib/widgets/shared/chat/shared_chat_detail_view.dart` and make the following changes to `_SharedChatDetailViewState`:
  1. Add two new state variables after `bool _showEmojiPicker = false;` (line 75):
     ```dart
     int _newMessageCount = 0;
     bool _isNearBottom = true;
     ```
  2. Modify `_onScroll()` (line 94) to also track bottom proximity. Add at the beginning of the method (before the existing load-more logic):
     ```dart
     final isNear = _scrollController.hasClients && _scrollController.position.pixels <= 200;
     if (isNear != _isNearBottom) {
       setState(() {
         _isNearBottom = isNear;
         if (_isNearBottom) _newMessageCount = 0;
       });
     }
     ```
  3. Modify the `BlocConsumer.listener` (lines 222–235): Replace the unconditional auto-scroll with conditional logic:
     ```dart
     listener: (context, state) {
       if (state.activeConversationMessages.isNotEmpty && _scrollController.hasClients) {
         if (_isNearBottom) {
           // Auto-scroll when near bottom (existing behavior)
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (_scrollController.hasClients) {
               _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
             }
           });
         } else {
           // Buffer count when scrolled up (FR-019)
           setState(() { _newMessageCount++; });
         }
       }
     },
     ```
  4. In the `builder` body (around line 265), wrap the `_MessageList` widget in a `Stack` and add a `Positioned` overlay for the new messages indicator:
     ```dart
     Expanded(
       child: Stack(
         children: [
           _MessageList(/* existing params */),
           if (_newMessageCount > 0)
             Positioned(
               bottom: 16,
               left: 0,
               right: 0,
               child: Center(
                 child: _NewMessagesIndicator(
                   count: _newMessageCount,
                   onTap: _scrollToBottom,
                   accentColor: widget.accentColor,
                   isDark: widget.isDark,
                 ),
               ),
             ),
         ],
       ),
     ),
     ```
  5. Add a `_scrollToBottom()` method to the state class:
     ```dart
     void _scrollToBottom() {
       if (_scrollController.hasClients) {
         _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
       }
       setState(() {
         _newMessageCount = 0;
         _isNearBottom = true;
       });
     }
     ```
  File: `lib/widgets/shared/chat/shared_chat_detail_view.dart`

- [X] T015 [US4] **(Implement before or alongside T014)** Add the `_NewMessagesIndicator` private widget at the end of `lib/widgets/shared/chat/shared_chat_detail_view.dart` (after the `_InputBar` widget class). This widget is a pill-shaped chip:
  ```dart
  class _NewMessagesIndicator extends StatelessWidget {
    final int count;
    final VoidCallback onTap;
    final Color accentColor;
    final bool isDark;

    const _NewMessagesIndicator({
      required this.count,
      required this.onTap,
      required this.accentColor,
      required this.isDark,
    });

    @override
    Widget build(BuildContext context) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$count new message${count == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
  File: `lib/widgets/shared/chat/shared_chat_detail_view.dart`

- [X] T016 [US4] Verify search debounce is 300ms. Open `lib/bloc/chat/chat_bloc.dart` and confirm that the `ChatSearchUsersRequested` handler (line 102–105) uses `debounce(const Duration(milliseconds: 300))`. This was updated in T005. Confirm the typing indicator auto-stop timer in `_onTypingChanged` (lines 733–747) uses `Duration(milliseconds: 1500)`. **Verification-only** — no changes expected. File: `lib/bloc/chat/chat_bloc.dart`

- [X] T016a [US4] Validate upward message pagination behavior for FR-008. Open `lib/bloc/chat/chat_bloc.dart` and `lib/widgets/shared/chat/shared_chat_detail_view.dart` and verify that older message pages are requested only when scrolling toward the top of the message list, and that loading older pages does not reset scroll position. If behavior is missing or unstable, patch and document the exact trigger threshold and state transition used.

- [X] T016b [US4] Validate and enforce FR-009 conversation incremental-render behavior in `lib/widgets/shared/chat/shared_conversation_list.dart`: when total conversations exceed 50, render only the first 50 initially, then append additional batches of 25 as the user nears list end. Document trigger threshold and provide a reproducible 100+ conversation test.

- [X] T016c [US4] Validate typing edge case for large paste operations. Paste a large text block into the message input and verify typing indicator behavior still auto-stops after 1.5 seconds of inactivity (same as normal typing).

**Checkpoint**: User Story 4 complete. New messages indicator works, debounce values match spec.

---

## Phase 7: User Story 5 — No Mock or Hardcoded Chat Data (Priority: P1)

**Goal**: Confirm zero mock data exists in any chat-related file. This is a verification-only phase based on research.md findings.

**Independent Test**: Run grep across all chat directories — zero hits for mock patterns.

### Verification for User Story 5

- [X] T017 [US5] Run mock data audit across all chat files. Execute the following TWO commands from the project root and confirm ZERO results for both:
  ```bash
  # Primary mock data patterns
  grep -rn "_generateSample\|_simulateReply\|mockConversation\|_mockMessages\|fake.*message\|sample.*conversation" lib/bloc/chat/ lib/widgets/shared/chat/ lib/screens/shared/shared_chat_screen.dart lib/services/chat/
  
  # Constitution VII additional patterns (data fabrication & BLoC bypass)
  grep -rn "Duration(hours:\|Duration(minutes:" lib/bloc/chat/ lib/widgets/shared/chat/ lib/services/chat/
  grep -rn "setState(() =>" lib/widgets/shared/chat/
  ```
  The `Duration(hours:` / `Duration(minutes:` patterns catch timestamp fabrication in mock data. The `setState(() =>` pattern catches direct widget state mutation that bypasses the BLoC (Constitution Principle VII). Note: `setState` used for purely local UI state like scroll position or animation flags is acceptable — only flag instances that mutate app/data state.
  If any mock data is found in these directories, remove it immediately. File: Multiple chat directories

- [X] T018 [US5] Run `ConversationType.course` audit. Execute:
  ```bash
  grep -rn "ConversationType.course\|ChatFilter.courses\|ChatFilter.instructors\|ChatFilter.students" lib/
  ```
  Confirm ZERO results. These were removed in earlier phases. If any are found, remove them. File: Entire `lib/` directory

**Checkpoint**: User Story 5 verified. No mock data in chat codebase.

---

## Phase 8: User Story 6 — Feature Parity Audit (Priority: P3)

**Goal**: Confirm the Flutter app matches the website's `MessagingChat` component behavior across all 5 roles.

**Independent Test**: Work through the Role Comparison Matrix for Student, Instructor, TA, Admin, IT Admin — every feature present on website is present in Flutter.

### Verification for User Story 6

- [X] T019 [US6] Verify all WebSocket events are handled AND reconnect parameters match spec. Open `lib/bloc/chat/chat_bloc.dart` and confirm the following events from `Flutter_Chat_API_Docs_BACKEND.md` §2.1 are handled in `_onWebSocketEventReceived`:
  - `new_message` (expected: line ~761)
  - `user_typing` (expected: line ~794)
  - `message_deleted` (expected: line ~817)
  - `delete_confirmed` (expected: line ~818)
  - `message_edited` (expected: line ~835)
  - `user_status` (expected: line ~865)
  - `online_users_list` (expected: line ~893)
  - `message_read` (expected: line ~203)
  - `connection_status` (expected: line ~754)
  Cross-reference with `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md` §10 WebSocket Events Reference. **Verification-only** — log any missing handlers.
  **FR-004 / SC-004 reconnect verification**: Also open `lib/services/chat/chat_socket_service.dart` and confirm:
  - Max reconnect attempts = 5 (matching backend spec and website behavior)
  - Reconnect delay = 1200ms between attempts
  - Total worst-case reconnect time ≤ 60 seconds (5 × 1200ms = 6s, well within SC-004's 1-minute threshold)
  - The `connectionStatus` stream emits `reconnecting` during attempts and `disconnected` after final failure
  If any parameter does not match, fix it. File: `lib/bloc/chat/chat_bloc.dart`, `lib/services/chat/chat_socket_service.dart`

- [X] T019b [US6] Verify deleted-conversation event edge case. Confirm that incoming real-time events for conversations no longer present in the user's list are safely discarded (no ghost conversation creation and no crash).

- [X] T020 [US6] Verify token refresh (REST + WebSocket) is working. Confirm:
  1. `lib/services/auth_interceptor.dart` handles 401 by refreshing token (lines 37–106) — **already implemented**.
  2. `lib/services/chat/chat_socket_service.dart` handles auth errors via `_refreshTokenAndReconnect()` (lines 481–526) — **already implemented**.
  **Verification-only**. File: `lib/services/auth_interceptor.dart`, `lib/services/chat/chat_socket_service.dart`

- [X] T020b [US6] Verify refresh-token failure edge case. When refresh fails (expired/invalid refresh token), confirm the app redirects to login and shows a user-friendly "Session expired — please sign in again" message.

- [X] T021 [US6] Verify swipe settings are retained. Confirm that `lib/screens/shared/chat/chat_swipe_settings_screen.dart` and the swipe action model exist and are NOT deleted. Per spec clarification Q5, these are accepted Flutter-only mobile UX enhancements. **Verification-only**. File: `lib/screens/shared/chat/`

- [X] T021a [US6] Verify discussion role parity for FR-015 across all five roles (Student, Instructor, TA, Admin, IT Admin). Confirm shared discussion entry points, moderation visibility, and role-appropriate access behavior are consistent with the website and backend docs.

- [X] T021b [US6] Run discussion no-mock audit in discussion scope only. Execute grep scans across `lib/bloc/discussions/`, `lib/services/api/discussion_service.dart`, `lib/screens/shared/discussion_screen.dart`, and `lib/widgets/shared/discussions/` to confirm zero hardcoded/sample/simulated data.

- [X] T021c [US6] Verify discussion empty/error states across all five roles. Confirm no blank screens for empty threads, empty replies, or request failures, and that retry guidance is user-friendly.

**Checkpoint**: User Story 6 verified. Feature parity confirmed.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup, dead-file audit, and static analysis in chat/discussion scope only.

- [X] T022 Run `flutter analyze` and fix all errors/warnings in modified files. Execute `flutter analyze` from the project root. Fix any issues in the 7 files modified during this phase:
  - `lib/services/storage_service.dart`
  - `lib/bloc/chat/chat_bloc.dart`
  - `lib/bloc/chat/chat_event.dart`
  - `lib/bloc/auth/auth_bloc.dart`
  - `lib/widgets/shared/chat/shared_chat_detail_view.dart`
  - `lib/widgets/shared/chat/shared_chat_empty_state.dart`
  - `lib/widgets/shared/chat/shared_conversation_list.dart`
  File: Project root

- [X] T023 Audit for unused/dead files in chat/discussion scope. Check for dead or duplicated paths in:
  - `lib/bloc/chat/`
  - `lib/bloc/discussions/`
  - `lib/services/chat/`
  - `lib/services/api/discussion_service.dart`
  - `lib/screens/shared/shared_chat_screen.dart`
  - `lib/screens/shared/discussion_screen.dart`
  - `lib/widgets/shared/chat/`
  - `lib/widgets/shared/discussions/`
  For each candidate, run `grep -rn "filename_without_ext" lib/` to confirm whether it is still imported. Mark only truly dead files for deletion.

- [X] T024 Audit for duplicate legacy discussion model/service paths that conflict with the unified discussion stack. Verify there is no parallel legacy discussion path active in production code outside `lib/models/discussion/`, `lib/bloc/discussions/`, and `lib/services/api/discussion_service.dart`. If duplicates exist, mark them for scoped cleanup.

- [X] T025 Final comprehensive mock data scan in chat/discussion scope (Constitution Principle VII gate for this phase). Run:
  ```bash
  # Primary mock data patterns (scoped)
  grep -rn "_generateSample\|_simulateReply\|mockConversation\|_mockMessages\|sampleData\|dummy.*message\|hardcoded.*chat" lib/bloc/chat/ lib/bloc/discussions/ lib/widgets/shared/chat/ lib/widgets/shared/discussions/ lib/screens/shared/shared_chat_screen.dart lib/screens/shared/discussion_screen.dart lib/services/chat/ lib/services/api/discussion_service.dart
  
  # Constitution VII additional patterns (timestamp fabrication)
  grep -rn "Duration(hours:\|Duration(minutes:" lib/bloc/chat/ lib/widgets/shared/chat/ lib/services/chat/
  
  # Constitution VII BLoC bypass pattern (in chat widgets only)
  grep -rn "setState(() =>" lib/widgets/shared/chat/
  ```
  Document all remaining mock data locations. For files in chat/discussion scope: remove them. For `setState` hits in chat widgets: verify each is purely local UI state (scroll flags, animation) and NOT app/data state mutation. If a global project-wide hygiene scan is needed, run it as an optional follow-up outside this phase scope. File: Scoped chat/discussion directories

- [X] T026 Delete confirmed dead files. Based on the audit results from T023 and T024, delete any files that are:
  1. Not imported by any other file in the project
  2. Contain only hardcoded/mock data
  3. In chat/discussion scope and confirmed obsolete by this phase's audits
  Before deleting, run `flutter analyze` to confirm no compilation errors result. If deletion causes errors, revert and flag for manual review instead. File: Various (based on audit results)

- [X] T027 Run quickstart.md validation. Follow the verification checklist in `specs/014-chat-cleanup-polish/quickstart.md`:
  - [ ] `flutter analyze` passes with no errors
  - [ ] App launches and chat loads with real API data
  - [ ] Cached conversations persist across app restart
  - [ ] Cache clears on logout (verify SharedPreferences keys)
  - [ ] Stale cached data older than 24h still appears offline and refreshes on reconnect
  - [ ] Connection status badge reflects actual WebSocket state
  - [ ] New messages indicator appears when scrolled up
  - [ ] Clearing search query restores full list immediately
  - [ ] Real-time events for deleted/non-member conversations are ignored safely
  - [ ] Refresh-token failure redirects to login with a friendly session-expired message
  - [ ] No `_generateSample` / `_simulateReply` / mock data in chat files
  - [ ] Discussion parity checks pass for all 5 roles (entry points, moderation visibility, empty/error states, and no mock data)
  - [ ] **(FR-015 / SC-005)** Login as each of the 5 roles (Student, Instructor, TA, Admin, IT Admin) and verify chat features work identically: conversation list loads, messages send/receive, connection badge visible, empty states correct
  File: `specs/014-chat-cleanup-polish/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 Caching (Phase 3)**: Depends on Phase 2 (needs cache methods + ClearChatCache event)
- **US2 Connection Status (Phase 4)**: Depends on Phase 2 — can run in parallel with Phase 3
- **US3 Empty States (Phase 5)**: Depends on Phase 2 — can run in parallel with Phase 3
- **US4 Performance (Phase 6)**: Depends on Phase 2 — can run in parallel with Phase 3
- **US5 Mock Data (Phase 7)**: No code dependencies — can run in parallel with any phase
- **US6 Parity Audit (Phase 8)**: Depends on Phases 3–7 being complete — final verification
- **Polish (Phase 9)**: Depends on ALL user stories being complete

### User Story Dependencies

- **US1 (P1 — Caching)**: Depends on Phase 2 only. No dependencies on other stories.
- **US2 (P1 — Connection Status)**: Independent. Already implemented — verification only.
- **US3 (P2 — Empty States)**: Independent. Different files from US1.
- **US4 (P2 — Performance)**: Partially overlaps US1 file (chat_bloc.dart debounce). Execute after US1 for the bloc file, but T014/T015 (detail view) can run in parallel.
- **US5 (P1 — Mock Data)**: Independent verification — no file edits.
- **US6 (P3 — Parity)**: Depends on all other stories. Final gate.

### Within Each User Story

- Foundation tasks before implementation tasks
- BLoC changes before widget changes
- Cache methods before cache consumers
- Verify after each checkpoint

### Parallel Opportunities

- T003 and T004 can run in parallel (different files)
- T010 and T011 can run in parallel (different files, verification only)
- T012 and T014 can run in parallel (different files: empty state vs detail view)
- T017 and T018 can run in parallel (both are grep commands)
- T019, T020, and T021 can run in parallel (all verification, different files)
- T023 and T024 can run in parallel (auditing different directories)

---

## Parallel Example: After Phase 2 Completion

```bash
# These can start simultaneously after Phase 2:
T006, T007, T008 — US1 Caching (chat_bloc.dart, auth_bloc.dart)
T010, T011           — US2 Connection Status (verification, no edits)
T012, T013            — US3 Empty States (empty_state.dart, conversation_list.dart)
T017, T018            — US5 Mock Data Audit (grep only, no edits)

# After US1 is done:
T014, T015            — US4 New Messages Indicator (detail_view.dart)
T016                  — US4 Debounce verification

# After all stories:
T019, T020, T021      — US6 Parity Audit
T022–T027             — Polish & Cleanup
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T005)
3. Complete Phase 3: User Story 1 — Caching (T006–T008)
4. **STOP and VALIDATE**: Test offline caching, logout wipe, cache write failure
5. This alone provides the biggest UX improvement

### Incremental Delivery

1. Phase 1 + 2 → Foundation ready
2. Add US1 (Caching) → Test independently → Biggest value delivery
3. Add US2 (Connection Status) → Verify badges → Quick win
4. Add US3 (Empty States) → Test all variants → Better first-run experience
5. Add US4 (Performance) → Test new messages indicator → Smooth UX
6. Add US5 + US6 → Full audit → Production-ready gate
7. Phase 9 Polish → Clean dead files → Ship it

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- The 7 modified files are: `storage_service.dart`, `chat_bloc.dart`, `chat_event.dart`, `auth_bloc.dart`, `shared_chat_detail_view.dart`, `shared_chat_empty_state.dart`, `shared_conversation_list.dart`
- No new files are created; no existing files are deleted (except optional scoped deletions during T026)
- Cache writes return deterministic success/failure values so FR-018 warning behavior can be enforced without exception-based control flow
- T023–T024 audits are restricted to chat/discussion scope to keep this phase aligned with its stated feature boundaries
