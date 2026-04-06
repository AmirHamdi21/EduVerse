# Tasks: Phase 2: Shared Data Models & Conversation BLoC

**Feature**: `007-chat-shared-models`
**Input**: Design documents from `specs/007-chat-shared-models/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup

**Purpose**: Project initialization and basic structure.

- [X] T001 Create missing folder structure for new BLoC architecture in `lib/bloc/chat/` and test directories in `test/bloc/`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented.
*(In this phase, User Story 1 acts as the foundational data layer everything else depends on).*

**Checkpoint**: Foundation ready - skipped parallel phase since BLoC depends heavily on models.

---

## Phase 3: User Story 1 - Unified Data Models (Priority: P1) 🎯 MVP

**Goal**: A single, consolidated set of chat data models that precisely mirror the backend API and website frontend, removing redundant role-specific models.

**Independent Test**: Can be fully tested by serializing and deserializing JSON payloads directly.

### Implementation for User Story 1

- [X] T002 [P] [US1] Create `ChatUserModel` in `lib/bloc/chat/chat_models.dart` mirroring backend properties (userId, firstName, lastName, fullName, email).
- [X] T003 [P] [US1] Create `ChatMessageModel` in `lib/bloc/chat/chat_models.dart`. Include fallback for `isDeleted` and `deletedText`.
- [X] T004 [US1] Create `ConversationModel` in `lib/bloc/chat/chat_models.dart`. Use `ChatUserModel` and `ChatMessageModel` inside. Ensure `type` is only `direct` or `group` (drop `course` type).
- [X] T005 [US1] Write unit tests for JSON deserialization of models in `test/bloc/chat_models_test.dart` to verify backend parity.

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Event-Driven Chat BLoC (Priority: P1)

**Goal**: Transition state management to a robust, event-driven `ChatBloc` handling concurrent REST interactions, pagination, and optimistic UI updates.

**Independent Test**: Unit Tests asserting Event to State transitions (`Loading`, `Success`, `Failure`).

### Implementation for User Story 2

- [X] T006 [P] [US2] Create BLoC state classes/enums `ChatState` in `lib/bloc/chat/chat_state.dart` (including `connectionStatus`, `typingUsers`, `onlineUsers`).
- [X] T007 [P] [US2] Create BLoC event classes `ChatEvent` in `lib/bloc/chat/chat_event.dart` (including `LoadMoreMessages` for pagination).
- [X] T008 [US2] Create `ChatBloc` skeleton in `lib/bloc/chat/chat_bloc.dart` with initial state.
- [X] T009 [US2] Implement `LoadConversations`, `SelectConversation` (must explicitly emit `join_conversation` and `leave_conversation` via `ChatSocketService`), and `LoadMoreMessages` handlers in `lib/bloc/chat/chat_bloc.dart` using `ChatService`.
- [X] T010 [US2] Implement `SendMessage` handler with immediate optimistic UI append (deduplication ready) in `lib/bloc/chat/chat_bloc.dart`. Update message status to 'failed' with a retry mechanism if both WebSocket and REST fallback fail.
- [X] T011 [US2] Implement remaining REST handlers: `SearchUsers`, `StartNewConversation` (must seamlessly return the existing conversation ID if the chat already exists), `DeleteMessage`, `MarkRead` in `lib/bloc/chat/chat_bloc.dart`.
- [X] T012 [US2] Write unit tests for ChatBloc REST event handlers in `test/bloc/chat_bloc_test.dart`.

**Checkpoint**: At this point, REST event handling and data-model consumption is verified.

---

## Phase 5: User Story 3 - Real-Time WebSocket State Integration (Priority: P2)

**Goal**: Ensure chat application instantly updates screen when WebSocket streams send live mutations.

**Independent Test**: Verify mocked WebSocket events mutate BLoC state automatically.

### Implementation for User Story 3

- [X] T013 [US3] Subscribe to `ChatSocketService` streams within `ChatBloc` constructor in `lib/bloc/chat/chat_bloc.dart`.
- [X] T014 [US3] Implement `WebSocketEventReceived` internal handler for all inbound events: `new_message`, `delete_confirmed`, `user_status`, `message_read`, `message_edited`, and `message_deleted` in `lib/bloc/chat/chat_bloc.dart`.
- [X] T015 [US3] Implement `TypingChanged` events and the locally debounced typing signal (1.5s timeout) in `lib/bloc/chat/chat_bloc.dart`.
- [X] T016 [US3] Write BLoC tests for WebSocket state mutations in `test/bloc/chat_bloc_test.dart`.

**Checkpoint**: All user stories should now be independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and crucial cleanup.

- [X] T017 Update `AppRouter` / Providers to inject `ChatBloc` instead of `ChatCubit` inside `lib/main.dart` and routing configs.
- [X] T018 Delete legacy state management at `lib/bloc/chat/chat_cubit.dart`.
- [X] T019 Explicitly delete the 4 outdated, role-specific mock models: `lib/widgets/instructor/chat/instructor_chat_models.dart`, and the corresponding models for student, TA, and admin roles.
- [X] T020 Temporarily comment out or refactor legacy chat models invocations in `lib/screens/student/chat/chat_screen.dart` and `lib/screens/instructor/chat/instructor_chat_screen.dart` so compiling succeeds (UI will be replaced in Phases 3/4).
- [X] T021 **CLEANUP GATE**: Rely on dart compiler orphans to systematically identify and delete unused files related to the TA courses feature from the past files before backend integration. Explicitly delete TA course models/screens that are no longer referenced. Check for `chat_models.dart` backups as well.

---

## Dependencies & Execution Order

### Phase Dependencies
- **Foundational (Phase 2)**: US1 acts as the models foundation.
- **Phase 4 (US2)**: Depends explicitly on Phase 3 (US1).
- **Phase 5 (US3)**: Depends explicitly on Phase 4 (US2) existing to hook streams.
- **Phase 6 (Polish)**: Must run last to avoid breaking the app entirely before the BLoC is ready.

### Parallel Opportunities
- Models (T002, T003) can be created in parallel.
- Events (T007) and States (T006) can be created in parallel.