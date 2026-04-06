# Feature Specification: Phase 2: Shared Data Models & Conversation BLoC

**Feature Branch**: `007-chat-shared-models`  
**Created**: April 6, 2026  
**Status**: Draft  
**Input**: User description: "Read CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md, CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md and Flutter_Chat_API_Docs_BACKEND.md and create a specification for the Phase 2: Shared Data Models & Conversation BLoC"

## User Scenarios & Testing *(mandatory)*

## Clarifications

### Session 2026-04-06

- Q: How should `ChatBloc` handle fetching older messages when the user scrolls up? → A: Add a `LoadMoreMessages` event to `ChatBloc` in Phase 2 so the state can append older messages seamlessly.

### User Story 1 - Unified Data Models (Priority: P1)

As a developer, I want a single, consolidated set of chat data models that precisely mirror the backend API and website frontend, removing redundant role-specific models, so that any chat component operates on the exact same data structure regardless of the user's role.

**Why this priority**: Essential architectural prerequisite. Without a single, API-compliant data model, creating shared UI components is impossible.

**Independent Test**: Can be fully tested by serializing and deserializing JSON payloads directly from the backend API into the `ConversationModel` and `ChatMessageModel` objects and ensuring no fields are lost or crash parsing.

**Acceptance Scenarios**:

1. **Given** a backend API response for conversations, **When** it is parsed by `ConversationModel.fromJson`, **Then** it accurately captures all properties (`conversationId`, `type`, `directDisplayUser`, `unreadCount`, etc.) without error.
2. **Given** the app's initial models structure, **When** examining the available `ConversationType` enum, **Then** only `direct` and `group` exist, and legacy types like `course` are absent.

---

### User Story 2 - Event-Driven Chat BLoC (Priority: P1)

As a Developer, I want the chat's state management transitioned from the simpler `ChatCubit` to a robust, event-driven `ChatBloc`, so that complex concurrent interactions (API fetches alongside incoming WebSocket events, optimistic UI updates) can be handled predictably via distinct events.

**Why this priority**: Required for handling complex distributed state reliably across REST HTTP fetches and real-time Socket operations simultaneously.

**Independent Test**: Can be fully tested via Unit Tests asserting that when `SendMessage` or `LoadConversations` events are dispatched, the Bloc emits the appropriate `Loading`, `Success`, or `Failure` states in sequence.

**Acceptance Scenarios**:

1. **Given** the user dispatches a `LoadConversations` event, **When** the `ChatBloc` processes it, **Then** it delegates to `ChatService.listConversations()`, emits a loading state, and safely updates the main conversation list.
2. **Given** the user dispatches a `SendMessage` event, **When** processed, **Then** an optimistic message is immediately appended to the chat state, followed by invoking the WebSocket (`chatSocketClient.sendMessage()`) or REST fallback.

---

### User Story 3 - Real-Time WebSocket State Integration (Priority: P2)

As a user, I want the chat application to instantly update my screen when a new message arrives, someone starts typing, or another person deletes a message, so that my experience feels "live" without me refreshing the screen.

**Why this priority**: Delivers the core "real-time" value proposition of a modern chat app, differentiating it from basic email.

**Independent Test**: Can be tested by manually pushing mocked WebSocket events (e.g., `user_typing`) to the socket service stream and verifying that `ChatBloc` state immediately updates its `typingUsers` map.

**Acceptance Scenarios**:

1. **Given** the user is viewing a conversation, **When** the WebSocket service receives a `user_typing` event for that ID, **Then** the `ChatBloc` adds the user to its `typingUsers` state map and triggers a UI update.
2. **Given** a socket disconnection event, **When** detected, **Then** the `ChatBloc` updates the `connectionStatus` state to `offline`, ensuring the UI can show a notification or indicator.

---

### Edge Cases

- What happens when a user creates a new chat but the conversation already exists on the backend?
- How does the system handle receiving WebSocket events for a conversation that is not currently loaded in the state?
- How are rapid, duplicate WebSocket events (e.g., typing indicators) managed to prevent unnecessary state rebuilds?
- What happens if the socket is offline, and the user attempts to send a message but the REST fallback also fails?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST consolidate all chat entity representations into a single `ConversationModel`, `ChatMessageModel`, and `ChatUserModel` exactly matching the `ChatConversationApi` and `ChatMessageApi` shapes from the backend.
- **FR-002**: System MUST remove obsolete properties and enums: `ConversationType.course`, `OnlineStatus.away`, and `OnlineStatus.busy`.
- **FR-003**: System MUST provide a new `ChatBloc` structure (States, Events, Bloc logic) to replace the existing `ChatCubit` entirely.
- **FR-004**: `ChatBloc` MUST support these CRUD events: `LoadConversations`, `SelectConversation`, `LoadMoreMessages` (for pagination), `SendMessage`, `SearchUsers`, `StartNewConversation`, `DeleteMessage`, and `MarkRead`.
- **FR-005**: `ChatBloc` MUST implement optimistic UI updates for outbound text messages.
- **FR-006**: `ChatState` MUST include explicit fields for ephemeral live data: `connectionStatus`, `typingUsers` map, and an `onlineUsers` representation.
- **FR-007**: `ChatBloc` MUST subscribe to `ChatSocketService` streams to automatically dispatch inward state transitions for all WebSocket events: `new_message`, `delete_confirmed`, `user_status`, `message_read`, `message_edited`, and `message_deleted`.

### Key Entities *(include if feature involves data)*

- **ConversationModel**: The single, unified representation of a conversation (direct or group).
- **ChatMessageModel**: Represents an individual message within a conversation.
- **ChatUserModel**: A minimal profile definition mapping to the `ChatUser` shape (e.g., `userId`, `firstName`, `lastName`, `email`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 4 divergent, role-specific chat data models are completely removed from the project and replaced by 1 shared model architecture.
- **SC-002**: JSON serialization coverage correctly parses 100% of fields from backend API mock responses for `ConversationModel` and `ChatMessageModel`.
- **SC-003**: The codebase seamlessly transitions the backend integration to `ChatBloc` with zero compiler errors in the models and blocs directories.
- **SC-004**: BLoC state transitions successfully handle and reflect incoming WebSocket live events (new message, typing, user status) within automated state tests.

## Assumptions

- The `ChatService` and `ChatSocketService` from Phase 1 are fully operational, tested, and can be integrated into the new `ChatBloc`.
- Mobile memory is sufficient to maintain small state caches (`typingUsers`, `onlineUsers`) without aggressive pruning per session.
- Role-specific UI screens will temporarily experience breaking layout/compilation errors until Phase 3 and Phase 4 replace them with shared UI components.
