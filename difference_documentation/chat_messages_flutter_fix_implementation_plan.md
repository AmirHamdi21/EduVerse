# Flutter Chat / Messages Fix & Parity Implementation Plan

Date: 2026-04-26

Project in scope:
- Flutter app only: `C:\Users\Friends\Desktop\Graduation\EduVerse`

Reference inputs used:
- Audit report: `C:\Users\Friends\Desktop\Graduation\EduVerse\difference_documentation\chat_messages_audit_report.md`
- Backend contract reference: `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`
- Website behavior reference: `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend`

Strict scope rules:
- Do not edit backend code.
- Do not edit website frontend code.
- Implement fixes only inside the Flutter project.
- When backend and website disagree, Flutter should:
  - Prefer the real backend contract for API payloads and persistence.
  - Prefer the website for user-visible chat flow and UX behavior.
  - Add Flutter-side fallbacks or graceful degradation when backend limitations cannot be solved without backend edits.

---

## 1. Goal

Make the Flutter chat/messages feature:
- reliably realtime
- behaviorally aligned with the website chat flow
- compatible with the existing backend messaging module
- available consistently for student, instructor, TA, and admin through the shared chat implementation

This plan is intentionally detailed so another Codex can execute it phase by phase without needing to rediscover the architecture.

---

## 2. Final Target State

After implementation, the Flutter app should support the following:

- Chat works for student, instructor, TA, and admin through the existing shared chat module.
- Messages sent from device A appear live on device B without leaving/re-entering the thread.
- Socket connection is established after login, refreshed correctly after token refresh, and cleaned up on logout.
- Active conversation is rejoined automatically after reconnect.
- Conversation list updates live for previews, unread counts, and last message timestamps.
- Conversation detail behaves like the website:
  - live incoming messages
  - optimistic sending
  - replies
  - delete for me
  - delete for everyone
  - typing indicator
  - new conversation flow
  - profile drill-down
- Flutter supports backend features that are currently available but not fully surfaced:
  - persistent delete for me
  - message edit support
  - global message search
  - unread total count
  - online users snapshot through HTTP endpoint
- Placeholder-only features stay explicitly marked as unsupported when backend does not provide end-to-end support:
  - voice messages
  - file attachment sending without a valid file-upload-to-`fileId` flow
  - voice/video calling

---

## 3. Non-Negotiable Constraints

### 3.1 Flutter-only constraint

Some findings in the audit originate in backend or website code. Since those codebases are out of scope:
- Do not try to fix backend event schemas.
- Do not try to fix backend pagination ordering.
- Do not try to fix website bugs.
- Instead, add Flutter-side adaptation layers where possible.

### 3.2 Shared implementation constraint

Do not revive role-specific empty screen files as separate implementations.

Keep using:
- `lib/screens/shared/shared_chat_screen.dart`
- `lib/widgets/shared/chat/*`
- `lib/bloc/chat/*`
- `lib/services/api/chat_service.dart`
- `lib/services/chat/chat_socket_service.dart`

The role-specific routes should continue to point at the shared chat experience, with only role-level configuration differences if needed.

### 3.3 Safety constraint

Do not change unrelated modules.

Avoid side effects in:
- discussions
- notifications
- auth outside what is needed to coordinate chat socket lifecycle

---

## 4. Main Problems To Solve In Flutter

### 4.1 Realtime delivery is unreliable

Root issue from audit:
- `ChatBloc` is created at app startup in `lib/main.dart`
- socket connection attempt happens too early in `ChatBloc`
- login happens later, but the chat socket is not explicitly reconnected with the authenticated token

User-visible result:
- new messages do not appear on the other device until the user refreshes or re-enters the chat

### 4.2 Flutter still relies on nonexistent websocket online-user snapshot behavior

Current problem:
- Flutter emits `get_online_users`
- Flutter expects `online_users_list`
- backend does not provide that websocket request/response flow

Required direction:
- load online users through the existing HTTP endpoint
- keep listening to backend `user_status` websocket pushes for incremental updates

### 4.3 Delete behavior is not aligned with backend and website

Current Flutter issues:
- delete for me is local-only
- delete for everyone removes the message entirely instead of showing deleted placeholder

### 4.4 Read-state handling is too optimistic relative to backend reality

Current Flutter issue:
- it expects per-message read receipt websocket semantics that backend does not actually provide cleanly

Required direction:
- support the current backend safely
- show correct unread clearing behavior
- degrade read receipt UI gracefully rather than pretending precision that the backend does not guarantee

### 4.5 New conversation flow is richer than website but not fully aligned with backend requirements

Current Flutter issue:
- UI says first message is optional
- backend start-conversation DTO currently requires `text`

Required direction:
- make Flutter create-flow compatible with the actual backend contract while preserving good UX

### 4.6 Some backend-supported features exist in Flutter plumbing but not in UI

Examples:
- edit message
- global search
- unread total count

---

## 5. Implementation Strategy Summary

The work should be executed in this order:

1. Stabilize realtime lifecycle first.
2. Fix message persistence semantics next.
3. Align new conversation and thread UX with website flow.
4. Surface backend-supported but missing features.
5. Polish, test, and harden.

Reason:
- If realtime lifecycle remains broken, every later feature will appear flaky.
- If delete/read semantics remain wrong, parity testing becomes misleading.

---

## 6. Phase Plan

## Phase 0: Preparation, Baseline, and Guardrails

### Objective

Create a safe implementation baseline before modifying chat behavior.

### Files to inspect and keep open during execution

- `lib/main.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/bloc/chat/chat_event.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/bloc/chat/chat_models.dart`
- `lib/services/api/chat_service.dart`
- `lib/services/chat/chat_socket_service.dart`
- `lib/services/storage_service.dart`
- `lib/bloc/auth/auth_bloc.dart`
- `lib/screens/shared/shared_chat_screen.dart`
- `lib/widgets/shared/chat/shared_conversation_list.dart`
- `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- `lib/widgets/shared/chat/shared_message_bubble.dart`
- `lib/screens/shared/chat/new_conversation_screen.dart`
- `lib/screens/shared/chat/user_profile_screen.dart`
- `lib/config/app_router.dart`

### Deliverables

- A short internal checklist in code comments or implementation notes for the executing Codex:
  - current socket lifecycle entry points
  - auth success points
  - logout cleanup points
  - message list ordering assumptions

### Tasks

1. Confirm all chat routes still resolve to `SharedChatScreen`.
2. Confirm role-specific chat screen files are unused placeholders and will remain untouched.
3. Map all current `ChatBloc` event triggers from UI.
4. Map all current auth success/logout locations where chat lifecycle can hook in.
5. Add a temporary implementation checklist comment block in the working branch if helpful, but remove or reduce it before final merge unless it still adds value.

### Acceptance criteria

- The executing Codex understands the current entry points and avoids accidental duplicate implementations.

---

## Phase 1: Realtime Lifecycle Repair

### Objective

Make the Flutter chat socket authenticate correctly, reconnect correctly, and rejoin the active thread so live delivery works reliably.

### Primary outcome

Fix the bug where messages do not appear on the other side until manual refresh/re-entry.

### Files likely to change

- `lib/main.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/bloc/chat/chat_event.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/services/chat/chat_socket_service.dart`
- possibly `lib/bloc/auth/auth_bloc.dart` only if a minimal hook/event bridge is needed

### Detailed tasks

#### 1. Add explicit chat socket lifecycle events

Introduce dedicated events to avoid hiding connection control inside the bloc constructor.

Recommended new events:
- `ChatSessionStarted`
- `ChatSessionEnded`
- `ChatReconnectRequested`
- `ChatConnectionEstablished`

Purpose:
- start socket after auth success
- stop socket after logout
- trigger controlled reconnects
- centralize room rejoin logic

#### 2. Remove “connect once at constructor time” as the primary strategy

Current behavior:
- `_connectSocket()` runs immediately in `ChatBloc` constructor

Replace with:
- constructor only subscribes to socket streams
- actual authenticated connection starts when the user session is known to be valid

#### 3. Start chat session after authentication becomes valid

Implementation options:
- Preferred: from `main.dart`, listen to `AuthBloc` state changes and dispatch `ChatSessionStarted` / `ChatSessionEnded`
- Alternative: create a lightweight app-level coordinator

Preferred because:
- it keeps chat independent from auth internals
- avoids tightly coupling `AuthBloc` to `ChatBloc`

Behavior:
- on `AuthAuthenticated`, load current access token and connect socket
- on `AuthUnauthenticated`, disconnect socket, clear volatile chat state, optionally preserve non-sensitive cache as already intended

#### 4. Reconnect after token refresh

Current socket service already refreshes tokens on socket auth failure.

Need to ensure:
- successful refresh reconnects socket with the new token
- reconnect path updates bloc connection state correctly
- active conversation is rejoined after reconnect

#### 5. Rejoin active conversation automatically after reconnect

Add logic:
- when connection state changes to live and `state.activeConversationId != null`, call `joinConversation(activeConversationId)`
- optionally re-emit `markRead(activeConversationId)` after rejoin

This must work for:
- app resume
- network drop/recovery
- token refresh reconnect

#### 6. Prevent duplicate room join / leave issues

Current logic joins on `SelectConversation`.

Refine it so:
- joining the same conversation twice is harmless
- leaving happens only when the active conversation actually changes or session ends
- reconnection rejoin does not corrupt state

#### 7. Add lightweight diagnostic logging during implementation

Temporary debug logging is useful for this phase:
- socket connect
- socket disconnect
- auth token available
- room join
- room rejoin after reconnect
- incoming `new_message`

Remove noisy logs before final merge, or keep only a small guarded debug logger if the project pattern allows it.

### Acceptance criteria

- If two devices are logged in with different roles, message delivery appears in the active thread without leaving/re-entering the screen.
- Realtime still works after app resume.
- Realtime still works after network interruption and reconnect.
- Realtime still works after token refresh.

### Manual verification checklist

1. Device A student, Device B instructor.
2. Open same direct conversation on both.
3. Send from A to B:
   - B sees message live in open thread.
4. Send from B to A:
   - A sees message live in open thread.
5. Put one app in background, bring it back:
   - live send still works.
6. Simulate offline/online:
   - reconnect occurs
   - active room resumes receiving messages.

---

## Phase 2: Online Presence Alignment

### Objective

Replace Flutter’s incorrect websocket snapshot assumption with a correct Flutter-only strategy based on current backend capabilities.

### Files likely to change

- `lib/services/api/chat_service.dart`
- `lib/services/chat/chat_socket_service.dart`
- `lib/bloc/chat/chat_event.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/widgets/shared/chat/shared_conversation_tile.dart`
- `lib/widgets/shared/chat/shared_chat_detail_view.dart`

### Detailed tasks

#### 1. Add HTTP API method for online users

In `ChatService`, add a method for:
- `GET /messages/online-users`

Return:
- a normalized `Set<int>` or `List<int>`

#### 2. Stop depending on nonexistent websocket request/response pair

Deprecate or remove from the active logic:
- `requestOnlineUsers()`
- `get_online_users` emit as a required flow
- `online_users_list` as a required server event

Keep compatibility if desired:
- socket listener for `online_users_list` can remain as harmless fallback
- but Flutter must no longer depend on it

#### 3. Load online snapshot at meaningful times

Trigger online user HTTP fetch:
- after `LoadConversations`
- after successful socket reconnect
- on app resume
- optionally when entering the chat screen if the current snapshot is stale

#### 4. Continue using websocket `user_status` for incremental updates

Keep:
- add/remove online users from `user_status`
- update `userLastSeen`

#### 5. Reconcile group and direct presence display

Desired behavior:
- direct chat shows online/offline/last seen for the peer
- group conversations do not show misleading group-wide “online” badge
- conversation tiles only show presence when a single direct peer can be resolved

### Acceptance criteria

- Presence indicators populate even if users were already online before the current device connected.
- No broken dependence remains on an event the backend never sends.

---

## Phase 3: Conversation and Message Loading Hardening

### Objective

Make Flutter robust against backend pagination and history limitations while preserving a user experience close to the website.

### Important note

Backend ordering is not ideal for chat. Since backend code is out of scope, Flutter must adapt as much as possible.

### Files likely to change

- `lib/services/api/chat_service.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/widgets/shared/chat/shared_chat_detail_view.dart`

### Detailed tasks

#### 1. Make initial conversation opening resilient to backend history order

Current risk:
- backend page 1 may return oldest messages instead of newest

Flutter-side mitigation options:
- If backend meta is available, detect total pages and fetch the latest page first
- If meta is not exposed cleanly by current `ChatService`, extend `ChatService` to parse and return pagination metadata

Preferred implementation:
- add a paginated response model in Flutter
- when opening a conversation, request enough metadata to determine the last page
- load the newest page first
- then prepend older pages on upward scroll

#### 2. Separate raw transport ordering from UI ordering

Keep one explicit rule:
- store message list in one canonical order in bloc
- let UI render based on that order consistently

Recommended:
- keep bloc state sorted ascending by actual time if that simplifies pagination
- or keep descending only if all pagination and merge utilities are updated consistently

The executing Codex must choose one and normalize all merge logic around it.

#### 3. Fix merge logic for optimistic vs incoming websocket messages

Ensure merge keys consider:
- conversation ID
- text
- sender
- timestamp tolerance
- temporary negative IDs

Goal:
- no duplicate self-messages
- no replacement of the wrong optimistic message

#### 4. Ensure live message arrival updates:
- active conversation message list
- conversation preview
- conversation ordering in list
- unread count when thread is inactive

### Acceptance criteria

- Opening a long conversation lands near the most recent messages.
- New incoming messages do not create duplicates.
- Sending a message does not create duplicate self-bubbles after socket echo.

---

## Phase 4: Delete Semantics Fix

### Objective

Align Flutter delete behavior with backend persistence and website behavior.

### Files likely to change

- `lib/bloc/chat/chat_event.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/services/api/chat_service.dart`
- `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- `lib/widgets/shared/chat/shared_message_bubble.dart`

### Detailed tasks

#### 1. Make “delete for me” call the backend

Current issue:
- UI uses `HideMessageLocally`

Required fix:
- “Delete for me” should dispatch `DeleteMessage(forEveryone: false, ...)`
- bloc should call REST delete-for-me
- message should disappear for the current user after success

Optional enhancement:
- retain a small local pending-hidden set for optimistic UX until server success returns

#### 2. Preserve local-only hide as a private helper only if needed

If optimistic deletion is implemented:
- keep a temporary hidden state
- remove it once server confirms

But it must no longer be the final behavior.

#### 3. Make “delete for everyone” preserve the message row

Current issue:
- bloc removes deleted messages from the timeline

Required fix:
- convert the message to:
  - `isDeleted = true`
  - `text = deletedText`
  - status updated appropriately
- do not remove the row

#### 4. Handle socket delete events consistently

For `message_deleted` and `delete_confirmed`:
- update the existing message model in place
- if backend payload lacks enough fields, map the targeted message locally into deleted state

#### 5. Update reply behavior for deleted parent messages

If a reply points to a deleted message:
- keep the reply reference visible
- show deleted placeholder text

### Acceptance criteria

- Delete for me persists across reloads.
- Delete for everyone shows “This message was deleted” rather than removing the row.
- Deleted messages still preserve timeline continuity and reply references.

---

## Phase 5: Read State and Unread Behavior

### Objective

Make unread clearing correct and make read-state UI honest relative to the current backend.

### Files likely to change

- `lib/services/api/chat_service.dart`
- `lib/bloc/chat/chat_models.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- `lib/widgets/shared/chat/shared_message_bubble.dart`
- optionally `lib/widgets/shared/chat/shared_conversation_tile.dart`

### Detailed tasks

#### 1. Distinguish conversation-level unread clearing from message-level receipts

Backend reality:
- conversation-level mark-read exists through websocket
- HTTP mark-read endpoint is single-message based
- websocket `message_read` payload does not reliably match Flutter’s per-message expectation

Flutter plan:
- keep unread clearing at the conversation level
- when a conversation opens, zero its unread count locally
- call websocket `mark_read(conversationId)` when connected
- optionally call HTTP `markRead(lastVisibleMessageId)` as fallback only if helpful for backend state, but do not treat it as full precision

#### 2. Make receipt UI degrade gracefully

Recommended UI policy:
- own optimistic message: `sending`
- own server-confirmed message: `sent`
- optionally show `read` only when a trustworthy event can be mapped
- otherwise do not overstate precision

Possible final decision:
- keep single-check / simple sent state in bubbles
- reserve read checkmarks for cases where the mapping is reliable

#### 3. Fix message-read model mismatch

Current Flutter model expects `messageId`.

Adapt it so:
- conversation-level read events can still be consumed without breaking
- if backend event lacks `messageId`, Flutter updates conversation-level state only

This may require:
- extending `MessageReadEvent`
- making `messageId` nullable
- storing conversation-level read metadata separately if needed

#### 4. Add unread total count support

Add Flutter API method:
- `GET /messages/unread-count`

Then decide usage:
- show in chat header
- or expose to higher-level dashboard badge plumbing later

For this plan, at minimum:
- fetch and store it in chat state
- expose it for UI use even if not immediately surfaced everywhere

### Acceptance criteria

- Opening a thread clears its unread badge reliably.
- Conversation list unread counts update correctly on incoming messages.
- Flutter no longer misinterprets backend read events as precise per-message receipts when they are not.

---

## Phase 6: New Conversation and Profile Flow Alignment

### Objective

Keep Flutter’s richer UX, but align it to the actual backend contract and website flow.

### Files likely to change

- `lib/screens/shared/chat/new_conversation_screen.dart`
- `lib/screens/shared/chat/user_profile_screen.dart`
- `lib/bloc/chat/chat_event.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/services/api/chat_service.dart`

### Detailed tasks

#### 1. Make first message required for conversation creation

Because backend currently requires `text`, Flutter must not present an “optional” initial message in flows that hit `startConversation`.

Update:
- label text
- validation messages
- disabled state logic for create buttons

For direct conversation:
- require one selected participant
- require first message text

For group conversation:
- require at least 2 other participants
- require group name
- require first message text

#### 2. Preserve existing direct-conversation dedupe logic

Flutter already tries to reuse existing direct conversations.

Keep this behavior, but ensure:
- if local state says the direct conversation exists, navigate to it
- if backend returns an existing conversation, do not duplicate any initial message send

Do not replicate the website’s duplicate-send bug.

#### 3. Ensure profile “Send Message” path respects same rules

From `UserProfileScreen`:
- starting a direct conversation should route through the same validated path
- if backend requires first message, provide a small compose step before creation or route into the new-conversation screen prefilled with the selected user

Recommended approach:
- keep “Send Message” on profile as a navigation into the compose/create flow instead of immediately creating an empty direct conversation

#### 4. Improve participant hydration

Ensure newly created conversations reliably populate:
- direct peer display
- participant names
- emails
- roles where available

### Acceptance criteria

- User cannot hit a create-conversation API path with invalid missing text.
- Profile-to-chat flow is smooth and backend-compatible.
- Existing direct conversations are reused without duplicate first messages.

---

## Phase 7: Website Parity Features Missing In Flutter

### Objective

Bring Flutter to parity with the features and flows visibly present in the website chat, while still honoring backend reality.

### Files likely to change

- `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- `lib/widgets/shared/chat/shared_message_bubble.dart`
- `lib/widgets/shared/chat/shared_conversation_list.dart`
- `lib/widgets/shared/chat/shared_chat_header.dart`
- `lib/screens/shared/shared_chat_screen.dart`

### Detailed tasks

#### 1. Align active-thread message UX with website

Ensure Flutter matches website behavior for:
- optimistic send
- auto-scroll when already near bottom
- new-message indicator when user is away from bottom
- reply composer
- conversation preview updates

Flutter already has most of this. This phase is mostly cleanup and consistency validation.

#### 2. Align delete affordances with website

Keep:
- reply action
- delete for me
- delete for everyone

Ensure action menu visibility rules match the intended logic:
- own message
- 24-hour delete-for-everyone window if that remains desired in Flutter UI

Note:
- backend does not enforce the 24-hour window; this is purely a client rule if kept.
- another Codex should decide whether to keep the UI restriction or remove it for backend consistency.
- recommended: keep it only if product wants WhatsApp-style UX; otherwise remove it to match actual backend capability.

#### 3. Align presence and typing display with website where appropriate

Differences:
- website typing label is generic
- Flutter can show better participant names

Recommendation:
- keep Flutter’s better participant-resolved typing indicator
- do not downgrade it just to mimic the website’s weaker label

#### 4. Decide whether local-only pin/mute/hide stays

These are not website/backend parity features.

Recommended decision:
- keep pin and mute only if product wants mobile-only convenience and document them as local preferences
- reconsider local hide/delete-conversation because it can confuse parity expectations

Preferred:
- keep pin and mute
- rename local delete behavior to “Hide conversation” if retained
- do not call it “Delete chat” unless it is truly persistent and cross-session by product intent

### Acceptance criteria

- Flutter UX feels like the website chat from the user’s perspective.
- Any remaining non-parity local-only behavior is clearly intentional and correctly named.

---

## Phase 8: Backend-Supported Features Missing In Flutter UI

### Objective

Expose backend features already available but not fully implemented in the Flutter UI.

### Files likely to change

- `lib/services/api/chat_service.dart`
- `lib/services/chat/chat_socket_service.dart`
- `lib/bloc/chat/chat_event.dart`
- `lib/bloc/chat/chat_state.dart`
- `lib/bloc/chat/chat_bloc.dart`
- `lib/widgets/shared/chat/shared_message_bubble.dart`
- `lib/widgets/shared/chat/shared_chat_header.dart`
- possibly new search widgets/screens under `lib/widgets/shared/chat/` or `lib/screens/shared/chat/`

### Detailed tasks

#### 1. Implement edit message in Flutter

Backend support exists, so Flutter should fully expose it.

Implementation pieces:
- add `EditMessageRequested` event
- add bloc handler calling:
  - websocket `edit_message` when connected
  - REST `PATCH /messages/:id` fallback when needed
- add UI action on own non-deleted messages
- add inline edit UX:
  - bottom sheet
  - dialog
  - or in-place edit mode

Required rules:
- only sender can edit
- cannot edit deleted messages

#### 2. Implement global message search

Backend endpoint exists.

Flutter should add:
- API method for `/messages/search`
- search response model
- dedicated search entry point from chat header or route
- result tap opens the conversation and scrolls to the message if present

Recommended UX:
- separate search screen rather than overloading conversation-list search

#### 3. Surface unread total count

At minimum:
- fetch unread total count in chat state
- expose it in chat header or dashboard badge integration point

If integrating fully is too broad for one implementation pass:
- store it in bloc state and show it in chat header only

#### 4. Add HTTP online users support to the public chat service contract

This belongs here as a fully surfaced backend feature if not already completed in Phase 2.

### Acceptance criteria

- User can edit own message from Flutter.
- User can search messages globally from Flutter.
- Unread total count is available in Flutter state and at least one visible UI location.

---

## Phase 9: Attachment, Voice, and Unsupported Features Cleanup

### Objective

Resolve placeholder confusion and avoid promising unsupported functionality.

### Files likely to change

- `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- `lib/screens/shared/shared_chat_screen.dart`
- maybe supporting localization files if user-facing text changes

### Detailed tasks

#### 1. File attachments

Backend only accepts `fileId`; Flutter currently has no confirmed end-to-end upload-to-file-service flow in chat.

Plan:
- Do not fake attachment sending.
- Replace current placeholder behavior with one of these:
  - temporarily hide attachment action
  - disable it with explicit “Not available yet”
  - or keep it behind a feature flag

Recommended:
- hide or disable until a real upload integration exists elsewhere in the Flutter app that can return a valid `fileId`

#### 2. Voice message

Current state:
- placeholder only

Plan:
- hide or disable the button explicitly
- do not leave ambiguous “Coming soon” actions inside the core chat flow unless product wants that

#### 3. Voice/video call buttons

Current state:
- placeholder only in Flutter and website

Plan:
- either keep as disabled non-interactive icons
- or hide them

Recommended:
- retain only if design wants parity with website visuals
- make them non-primary and clearly unsupported

### Acceptance criteria

- Chat no longer suggests a working feature when the action cannot complete end-to-end.

---

## Phase 10: Role Validation and Route Validation

### Objective

Ensure shared chat works identically across student, instructor, TA, and admin routes.

### Files likely to inspect or lightly edit

- `lib/config/app_router.dart`
- `lib/screens/shared/shared_chat_screen.dart`
- any role shell screens only if navigation or app-bar behavior requires minor adjustments

### Detailed tasks

1. Validate all role routes open the shared screen correctly.
2. Validate accent color and title rules per role remain intact.
3. Validate chat works when entered from each role shell:
   - student
   - instructor
   - TA
   - admin
4. Ensure there is no stale reference to empty role-specific chat screen files.

### Acceptance criteria

- All four target roles use the same working chat experience through their current routes.

---

## Phase 11: Test Coverage and Verification

### Objective

Add enough automated and manual verification to keep chat regressions from recurring.

### Test layers

#### 1. Unit tests

Recommended targets:
- `ChatMessageModel.fromJson`
- socket payload normalization
- delete-for-everyone mapping
- read-event mapping with nullable/partial payloads
- conversation sorting
- optimistic/incoming merge logic
- new-conversation validation logic

Likely files:
- `test/bloc/chat/...`
- `test/services/chat/...`
- `test/models/chat/...`

#### 2. Bloc tests

Recommended scenarios:
- session start connects socket
- session end disconnects socket
- reconnect while active conversation re-joins room
- incoming message updates active thread
- incoming message updates inactive conversation unread count
- delete for me removes after REST success
- delete for everyone transforms message into deleted placeholder
- edit message updates correctly

#### 3. Widget tests

Recommended targets:
- conversation list badge rendering
- reply preview bar
- deleted message bubble
- disabled or hidden unsupported actions
- new conversation validation errors

#### 4. Manual multi-device test matrix

Required matrix:
- Student <-> Instructor
- Student <-> TA
- Student <-> Admin
- Instructor <-> TA
- Instructor <-> Admin
- TA <-> Admin

Required manual scenarios:
- direct send while both in active thread
- send when receiver is on conversation list
- open conversation clears unread
- delete for me
- delete for everyone
- reply send
- edit message
- reconnect after app background
- reconnect after connectivity interruption

---

## 7. Detailed File-Level Change Map

## Core state and lifecycle

### `lib/main.dart`

Planned work:
- add app-level coordination between auth state and chat session lifecycle
- dispatch start/end chat session events

### `lib/bloc/chat/chat_event.dart`

Planned additions:
- session lifecycle events
- edit message event
- global search events
- online users refresh event if not already sufficient

### `lib/bloc/chat/chat_state.dart`

Planned additions/refinements:
- unread total count
- global search results state
- message edit in-progress state if needed
- clearer connection/session flags if needed
- possibly conversation-level read metadata

### `lib/bloc/chat/chat_bloc.dart`

Planned work:
- move socket connection control out of constructor-only flow
- rejoin active conversation after reconnect
- fetch online users via HTTP
- correct delete semantics
- add edit message flow
- add message search flow
- refine read-state handling
- harden optimistic merge behavior

## Transport and API

### `lib/services/api/chat_service.dart`

Planned additions:
- `getOnlineUsers()`
- `getUnreadCount()`
- `searchMessages()`
- paginated conversation message response handling if needed
- optional richer conversation/message DTO normalization

### `lib/services/chat/chat_socket_service.dart`

Planned work:
- stop treating `online_users_list` as required
- support reconnect + rejoin-friendly lifecycle
- improve payload normalization for partial read/edit/delete events

## Shared chat UI

### `lib/screens/shared/shared_chat_screen.dart`

Planned work:
- minimal changes only
- preserve shared role-agnostic screen
- possibly ensure session checks or resume behavior trigger correctly

### `lib/widgets/shared/chat/shared_conversation_list.dart`

Planned work:
- integrate unread total or refresh triggers if needed
- reconsider hide/delete naming if local hide remains
- preserve search/filter behavior

### `lib/widgets/shared/chat/shared_chat_detail_view.dart`

Planned work:
- update delete-for-me wiring
- update delete-for-everyone behavior
- add edit action entry
- refine unsupported attachment/voice/call affordances

### `lib/widgets/shared/chat/shared_message_bubble.dart`

Planned work:
- add edit action for eligible own messages
- support deleted-state rendering without row removal
- keep reply rendering stable for deleted parent messages

## New conversation and profile flow

### `lib/screens/shared/chat/new_conversation_screen.dart`

Planned work:
- require initial message text
- align validation text
- preserve direct/group flows

### `lib/screens/shared/chat/user_profile_screen.dart`

Planned work:
- route profile “Send Message” through backend-compatible creation flow
- avoid trying to create empty direct conversations

---

## 8. Suggested Phase-by-Phase Execution Order For Another Codex

This is the recommended concrete implementation order:

1. Phase 1
2. Phase 2
3. Phase 4
4. Phase 5
5. Phase 6
6. Phase 3
7. Phase 8
8. Phase 9
9. Phase 10
10. Phase 11

Reason for this order:
- Phase 1 fixes the user’s main bug immediately.
- Phase 2 removes a false realtime dependency.
- Phase 4 and 5 fix correctness before adding new UX features.
- Phase 6 aligns creation flow with backend so chat becomes stable.
- Phase 3 can then safely improve history loading logic.
- Phase 8 adds new capabilities after the base is trustworthy.

---

## 9. Risks and Flutter-Only Mitigations

### Risk 1: Backend read events remain inconsistent

Mitigation:
- make Flutter tolerant of missing `messageId`
- prefer conversation-level unread correctness over fake precise read receipts

### Risk 2: Backend pagination order remains suboptimal

Mitigation:
- add Flutter-side paginated response handling
- load latest page first where possible

### Risk 3: Backend websocket payloads are sparse

Mitigation:
- centralize normalization in Flutter models/services
- avoid spreading payload assumptions across widgets

### Risk 4: Auth-chat lifecycle coupling introduces regressions

Mitigation:
- keep lifecycle coordination at app level
- test login, logout, refresh token, and resume thoroughly

### Risk 5: Existing cached data causes stale behavior

Mitigation:
- review cache invalidation for:
  - logout
  - delete for me
  - delete for everyone
  - edit message

---

## 10. Definition of Done

The work is done only when all of the following are true:

- Realtime messaging works reliably across two devices without manual refresh/re-entry.
- Student, instructor, TA, and admin all use the same functioning shared chat flow.
- Delete for me is persistent and backend-backed.
- Delete for everyone shows a deleted placeholder instead of removing the row.
- New conversation flow is backend-compatible and does not allow invalid empty first-message creation.
- Online presence uses backend-supported HTTP snapshot plus websocket incremental updates.
- Edit message is implemented in Flutter.
- Global message search is implemented in Flutter.
- Unread total count is implemented in Flutter state and surfaced in at least one UI location.
- Unsupported attachment/voice/call actions are no longer misleading.
- Automated tests cover the critical chat state transitions.
- Manual multi-device verification passes for all target roles.

---

## 11. Recommended Output Artifacts During Implementation

When another Codex executes this plan, it should produce:

- code changes in Flutter only
- a short implementation summary
- a verification checklist with:
  - tested role pairs
  - tested reconnect scenarios
  - tested delete/edit/reply/search flows
- a small residual-risk section listing backend limitations that Flutter had to work around

---

## 12. Final Guidance For The Implementing Codex

Prioritize correctness over feature count in early phases.

Specifically:
- do not start with edit/search before fixing socket lifecycle
- do not leave local-only delete semantics in place
- do not preserve the “first message optional” flow if it continues to conflict with backend reality
- do not introduce a second role-specific chat implementation

The most important first milestone is:
- after login, socket connects correctly
- active conversation rejoins on reconnect
- live messages appear immediately in the open thread on both devices

