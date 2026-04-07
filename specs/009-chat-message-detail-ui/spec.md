# Feature Specification: Unified Chat UI — Message Detail View

**Feature Branch**: `009-chat-message-detail-ui`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: Phase 4 of chat backend integration — create shared message detail widgets for viewing and interacting with individual conversation messages, matching the website frontend's MessagingChat component.

## Clarifications

### Session 2026-04-06

- Q: What is the time window for "Delete for everyone"? → A: 24 hours after sending
- Q: What is the retry behavior when a message fails to send? → A: 3 retries with exponential backoff (1s, 2s, 4s)
- Q: What is the page size for message history pagination? → A: 30 messages per page

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View and Send Messages (Priority: P1)

As any user (student, instructor, TA, admin, or IT admin), I want to view the full message history of a selected conversation and send new messages so that I can communicate in real-time with other users.

**Why this priority**: Core messaging functionality is the fundamental purpose of the chat feature. Without this, no communication can occur.

**Independent Test**: Can be fully tested by selecting a conversation, viewing its messages, and sending a new message. Delivers the primary value of real-time communication.

**Acceptance Scenarios**:

1. **Given** a user has selected a conversation from the list, **When** the message detail view opens, **Then** the user sees the complete message history with newest messages at the bottom
2. **Given** a user is viewing a conversation, **When** they type a message and tap send, **Then** the message appears immediately in the chat and is delivered to other participants
3. **Given** a user sends a message, **When** the message is successfully delivered, **Then** a delivery status indicator shows the message was sent
4. **Given** a user is viewing a conversation, **When** another participant sends a message, **Then** the new message appears automatically without requiring a refresh

---

### User Story 2 - Reply to Specific Messages (Priority: P2)

As a user, I want to reply to a specific message in the conversation so that I can maintain context in discussions and reference previous messages clearly.

**Why this priority**: Reply functionality provides essential context in conversations, especially in active chats where multiple topics may be discussed. Without it, conversations become confusing.

**Independent Test**: Can be tested by long-pressing a message, selecting "Reply", and sending a response. The reply should visually link to the original message.

**Acceptance Scenarios**:

1. **Given** a user is viewing a conversation, **When** they long-press a message and select "Reply", **Then** a reply preview bar appears above the input showing the referenced message
2. **Given** a user has initiated a reply, **When** they send the message, **Then** the sent message displays a visual reference to the original message it was replying to
3. **Given** a user sees a reply in the message list, **When** they tap the reply context, **Then** the view scrolls to show the original referenced message

---

### User Story 3 - Delete Messages (Priority: P2)

As a user, I want to delete messages either for myself only or for everyone in the conversation so that I can remove unwanted or mistakenly sent content.

**Why this priority**: Message deletion is critical for user privacy and error correction. Users need control over their sent content.

**Independent Test**: Can be tested by long-pressing a message and selecting delete options. Verify local-only deletion hides the message for the user, and "delete for everyone" removes it for all participants.

**Acceptance Scenarios**:

1. **Given** a user is viewing their own message, **When** they long-press and select "Delete for me", **Then** the message is hidden from their view only
2. **Given** a user is viewing their own sent message within 24 hours, **When** they long-press and select "Delete for everyone", **Then** the message is removed for all participants and shows "This message was deleted"
3. **Given** a user is viewing another person's message, **When** they long-press, **Then** they only see "Delete for me" option (not "Delete for everyone")
4. **Given** a user is viewing their own message older than 24 hours, **When** they long-press, **Then** "Delete for everyone" option is disabled or hidden

---

### User Story 4 - See Typing Indicators (Priority: P3)

As a user, I want to see when another participant is typing so that I know a response is coming and can wait before sending additional messages.

**Why this priority**: Typing indicators improve conversation flow and user experience, but are not essential for basic messaging functionality.

**Independent Test**: Can be tested with two users where one starts typing and the other observes the typing indicator appearing and disappearing.

**Acceptance Scenarios**:

1. **Given** a user is viewing a conversation, **When** another participant begins typing, **Then** a "User X is typing..." indicator appears below the conversation header
2. **Given** a typing indicator is displayed, **When** the other participant stops typing or sends the message, **Then** the indicator disappears
3. **Given** a group conversation, **When** multiple users are typing, **Then** the indicator shows all typing users' names

---

### User Story 5 - View Connection and Online Status (Priority: P3)

As a user, I want to see the real-time connection status and whether other participants are online so that I can understand if messages will be delivered immediately.

**Why this priority**: Status indicators improve user awareness but don't block core functionality. Messages can still be sent when offline via fallback mechanisms.

**Independent Test**: Can be tested by verifying the "Live"/"Offline" badge reflects actual connection status, and that participant online/offline status is accurately displayed.

**Acceptance Scenarios**:

1. **Given** the user has an active connection, **When** viewing any conversation, **Then** a "Live" status badge is displayed in the header
2. **Given** the connection is lost, **When** viewing any conversation, **Then** an "Offline" status badge is displayed
3. **Given** a direct conversation, **When** the other participant is online, **Then** a green online indicator appears next to their avatar
4. **Given** a direct conversation, **When** the other participant goes offline, **Then** the green indicator disappears

---

### User Story 6 - Use Emoji in Messages (Priority: P3)

As a user, I want to add emoji to my messages using a quick picker so that I can express emotions and reactions easily.

**Why this priority**: Emoji enhance communication expressiveness but are optional for basic messaging functionality.

**Independent Test**: Can be tested by tapping the emoji button and verifying the emoji picker appears, and that selecting an emoji inserts it into the message input.

**Acceptance Scenarios**:

1. **Given** a user is composing a message, **When** they tap the emoji button, **Then** an inline emoji row appears with commonly used emojis
2. **Given** the emoji picker is visible, **When** the user taps an emoji, **Then** it is inserted at the cursor position in the text input
3. **Given** the emoji picker is visible, **When** the user taps outside or starts typing, **Then** the picker dismisses

---

### User Story 7 - View Message Sender in Group Chats (Priority: P3)

As a user in a group conversation, I want to see who sent each message so that I can follow the discussion and know who is speaking.

**Why this priority**: Sender identification is essential for group chat usability but not needed for direct conversations.

**Independent Test**: Can be tested by viewing a group conversation and verifying each message shows the sender's name and avatar.

**Acceptance Scenarios**:

1. **Given** a group conversation, **When** viewing messages, **Then** each message bubble shows the sender's name and avatar
2. **Given** a direct conversation, **When** viewing messages, **Then** sender names are not shown (only avatars for visual alignment)
3. **Given** consecutive messages from the same sender, **When** viewing, **Then** the sender name only appears on the first message of the sequence

---

### Edge Cases

- What happens when a message fails to send? The system automatically retries 3 times with exponential backoff (1s, 2s, 4s). After all retries fail, an error indicator appears on the message with a manual retry option, and the message remains in a "failed" state.
- What happens when viewing deleted messages? The message bubble displays "This message was deleted" placeholder text with distinct styling.
- What happens when replying to a deleted message? The reply context shows "Original message was deleted" instead of the original content.
- What happens when the message list is empty? An empty state with a friendly prompt to start the conversation is displayed.
- What happens when scrolling through very long message histories? The system loads messages in pages of 30 messages as the user scrolls up, with a loading indicator during fetch.
- What happens when connection is lost mid-message? The message is queued and automatically sent when connection is restored, or sent via REST fallback.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a scrollable list of messages for the selected conversation with newest messages at the bottom
- **FR-002**: System MUST auto-scroll to the most recent message when opening a conversation or when new messages arrive
- **FR-003**: System MUST load message history in pages of 30 messages, fetching older pages when user scrolls to the top
- **FR-004**: System MUST display a conversation header showing participant avatar, name, online status, and typing indicator
- **FR-005**: System MUST provide placeholder buttons (visible but non-functional, showing "Coming soon" toast on tap) for voice and video calls in the conversation header
- **FR-006**: System MUST display each message with its text content, timestamp, and delivery status
- **FR-007**: System MUST show sender avatar and name for messages in group conversations
- **FR-008**: System MUST display "This message was deleted" for messages marked as deleted
- **FR-009**: System MUST support message replies by showing the referenced message context above the reply
- **FR-010**: System MUST provide long-press actions on messages: Reply, Delete for me, and Delete for everyone (own messages only, within 24 hours of sending)
- **FR-011**: System MUST display a reply preview bar when the user is composing a reply to a specific message
- **FR-012**: System MUST provide an input bar with text field, attachment button (visible but disabled, showing "Coming soon" toast on tap), voice message toggle (visible but disabled, showing "Coming soon" toast on tap), emoji button, and send button
- **FR-013**: System MUST display an inline emoji row when the emoji button is tapped
- **FR-014**: System MUST show animated typing indicator when other participants are typing
- **FR-015**: System MUST display connection status badge (Live/Offline) in the header
- **FR-016**: System MUST implement optimistic message sending — display message immediately with "pending" status
- **FR-017**: System MUST update message status to "sent" when server confirms delivery
- **FR-018**: System MUST fall back to REST-based message sending when WebSocket connection is unavailable
- **FR-019**: System MUST automatically retry failed message sends 3 times with exponential backoff (1s, 2s, 4s) before showing error state
- **FR-020**: System MUST deduplicate messages by matching optimistic messages with server-confirmed messages
- **FR-021**: System MUST accept accent color and dark mode parameters for per-role theming

### Key Entities

- **Message Bubble**: Visual representation of a single message containing text content, sender info (for groups), timestamp, status, and optional reply context
- **Conversation Header**: Top section displaying participant details, online status, typing indicator, and call action buttons
- **Input Bar**: Bottom section containing message composition controls including text input, attachment, voice, emoji, and send buttons
- **Reply Preview**: Contextual bar showing the message being replied to when composing a reply
- **Typing Indicator**: Animated visual element showing that other participants are currently typing
- **Emoji Row**: Quick access panel for commonly used emojis

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view a selected conversation's messages and send a new message in under 5 seconds (measured from conversation tile tap to message appearing in list)
- **SC-002**: Messages sent appear in the conversation immediately (optimistic update) with less than 100ms perceived delay
- **SC-003**: Typing indicators appear within 500ms of another user beginning to type (includes network round-trip latency; local rendering must be <50ms after WebSocket event received)
- **SC-004**: Connection status badge accurately reflects live/offline status with less than 2 second lag
- **SC-005**: 95% of messages are successfully delivered on first attempt when connection is stable
- **SC-006**: Reply, delete, and emoji actions are accessible within 2 taps from the message view
- **SC-007**: Message detail view loads and displays message history within 2 seconds for conversations with up to 1000 messages
- **SC-008**: Users can distinguish their own messages from others' messages through visual styling
- **SC-009**: All five user roles (student, instructor, TA, admin, IT admin) can use the message detail view identically with appropriate theming

## Assumptions

- Phase 1 (Core Chat Infrastructure) and Phase 2 (Shared Data Models & BLoC) are completed, providing `ChatService`, `ChatSocketService`, and `ChatBloc`
- Phase 3 (Conversation List) is completed, providing the conversation selection that triggers the message detail view
- The existing WebSocket infrastructure supports all required events: `new_message`, `user_typing`, `message_deleted`, `message_sent`, `user_status`
- REST fallback endpoints are available at `/api/messages/conversations/:id` for message retrieval and sending
- User authentication and JWT tokens are handled by the existing auth system
- The message detail view will be used as a shared component across all five user roles
- Voice/video call and file attachment features are UI placeholders only — actual functionality is out of scope
- Voice message recording functionality is a UI placeholder only — actual implementation is out of scope
