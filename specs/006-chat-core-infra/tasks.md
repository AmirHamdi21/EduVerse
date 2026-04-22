# Implementation Tasks: Phase 1: Core Chat Infrastructure

**Feature Branch**: `006-chat-core-infra`
**Spec**: [spec.md](./spec.md)
**Plan**: [plan.md](./plan.md)

## Implementation Strategy
- Implement infrastructure iteratively without altering the existing UI code.
- Construct the shared domain models first to ensure both API and Socket services map identically.
- Focus on creating the robust WebSocket connection engine to handle the core of real-time messaging, then extend it through the functional API requirements.
- Verify API/Socket methods via standard Unit testing.

## Dependencies
- Phase 1 (Setup) must complete before Foundational models.
- Foundational Tasks must complete before User Stories.
- User Stories can largely be executed in parallel due to strict physical separation between ChatService logic and ChatSocketService event loops. Phase 7 operates as the final cleanup.

---

## Phase 1: Setup

**Goal**: Configure project environment and packages limit.
**Tests**: Automatically verified via `pubspec` resolution.

- [X] T001 Update `pubspec.yaml` to include `socket_io_client: ^3.0.2` and run `flutter pub get`.

---

## Phase 2: Foundational

**Goal**: Standardize the domain models bridging the backend interfaces.
**Context**: Replaces disjointed data structures with universal payloads based on `data-model.md`.

- [X] T002 [P] Create universal domain models (`ConversationModel`, `ChatMessageModel`, `ChatUserModel`, and `ConversationType` Enum mapping `direct`/`group`) based on website TypeScript interfaces mapped in `data-model.md`, placing them in `lib/models/chat_models.dart`.
- [X] T003 [P] Scaffold `IChatService` interface inside `lib/services/api/chat_service.dart` relying on `dio`.
- [X] T004 [P] Scaffold `IChatSocketService` interface inside `lib/services/chat/chat_socket_service.dart`.

---

## Phase 3: Real-Time Connectivity (P1)

**Goal**: Establish resilient bi-directional socket persistence (US1).
**Independent Test**: The infrastructure can successfully connect using mock tokens and immediately attempt to auto-reconnect upon simulated drops.

- [X] T005 [US1] Implement `ChatSocketService.connect()` handling token query-param injection, disconnect triggers, and an internal loop for automatic retries up to 5 times (1200ms delay) within `lib/services/chat/chat_socket_service.dart`.
- [X] T006 [US1] Expose the current `connectionStatus` output stream (using explicit `ChatConnectionStatus` enum states: `connected`, `disconnected`, `reconnecting`), accurately reflecting real-time connectedness throughout the application lifecycle inside `lib/services/chat/chat_socket_service.dart`.
- [X] T007 [US1] Write unit tests asserting connection loops, reconnect mechanics with mock adapters in `test/services/chat/chat_socket_service_test.dart`.

---

## Phase 4: Historical Conversation Retrieval (P1)

**Goal**: Establish list and retrieval payloads via REST APIs (US2).
**Independent Test**: Fetch lists of chats or paginated messages flawlessly map into Dart `ConversationModel`s.

- [X] T008 [P] [US2] Implement `ChatService.listConversations()` integrating JWT authentication headers via the `dio` instance within `lib/services/api/chat_service.dart`.
- [X] T009 [P] [US2] Implement `ChatService.getConversationMessages(id, page, limit)` to return a structured list of messages in `lib/services/api/chat_service.dart`.
- [X] T010 [US2] Write payload conversion tests demonstrating JSON parsed successfully to `ChatMessageModel` structures within `test/services/api/chat_service_test.dart`.

---

## Phase 5: Message Transmission & Management (P2)

**Goal**: Ensure bidirectional CRUD capacities on individual messages across both transports (US3).
**Independent Test**: Invoking Send/Delete/Edit queues requests down both REST paths or emits appropriately shaped Websocket payloads representing accurate events.

- [X] T011 [P] [US3] Implement messaging endpoints (`sendMessage`, `editMessage`, `deleteForMe`, `deleteForEveryone`, `markRead`) passing strictly structured dicts in `lib/services/api/chat_service.dart`. Ensure `editMessage` returns `Future<ChatMessageModel>` and deletions return `Future<bool>` for successful tracking.
- [X] T012 [P] [US3] Implement interactive socket emitters (`sendMessage`, `editMessage`, `deleteMessage`, `markRead`, `emitTyping`) mirroring exactly the backend docs dict payloads within `lib/services/chat/chat_socket_service.dart`.
- [X] T013 [P] [US3] Implement inbound broadcast listeners mapping all node-emitted events (`new_message`, `new_message_notification`, `user_typing`, `message_read`, `message_deleted`, `message_edited`, `user_status`, `delete_confirmed`) to public Dart streams within `lib/services/chat/chat_socket_service.dart` per FR-015.
- [X] T014 [US3] Create assertions validating inbound socket messages and dispatched payload schemas match expectations spanning `test/services/api/chat_service_test.dart` and `test/services/chat/chat_socket_service_test.dart`.
- [X] T014b [US3] Implement and expose programmatic methods to emit `join_conversation` and `leave_conversation` socket events per FR-013.

---

## Phase 6: Discovering Users & Initiating Chats (P2)

**Goal**: Allow lookup tools needed to initiate fresh chats (US4).
**Independent Test**: Hitting `searchUsers(query)` yields populated `ChatUser` records.

- [X] T015 [P] [US4] Implement `ChatService.searchUsers(query)` supporting limit pagination across `lib/services/api/chat_service.dart`.
- [X] T016 [P] [US4] Implement `ChatService.startConversation(participantIds, type, text)` sending valid initialization payloads representing direct or group room creation in `lib/services/api/chat_service.dart`.
- [X] T017 [US4] Formulate matching unit testing logic verifying the search payload arrays inside `test/services/api/chat_service_test.dart`.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Goal**: Ensure graceful fallback architectures exist and complete final workspace cleanups.

- [X] T018 Implement HTTP 429 response catch logic and offline fallback utilizing a persistent background queueing strategy (using `shared_preferences` to survive app restarts) for Dio requests inside `lib/services/api/chat_service.dart`.
- [X] T019 Audit the project for unused placeholder files per the `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md`, `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md` and `Flutter_Chat_API_Docs_BACKEND.md` docs (e.g. across `lib/widgets/ta/courses/`, `lib/models/ta/`, and `lib/screens/ta/` if applicable, or TA chat monolithic widgets). Delete these stagnant models and widgets to consolidate the source structure. Audit completed; no safely-unused files were found for deletion without breaking active imports/routes.
