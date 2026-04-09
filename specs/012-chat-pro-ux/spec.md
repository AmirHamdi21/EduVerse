
# Feature Specification: Pro Chat UX Enhancements

**Feature Branch**: `012-chat-pro-ux`  
**Created**: April 9, 2026  
**Status**: Draft  
**Input**: User description: "I want to add to the Phase 7: Pro Chat UX Enhancements to fix an issue that when the user in a chat with someone and make an reply on a message the someone sent it shows reply to unknown and doesnt show the real name of the someone the user chat with so add this fix in this phase..."

## Clarifications

### Session 2026-04-09
- Q: How should the initial All Contacts list handle the paginated search API limit (20) for large user bases? → A: Hide "All Contacts" initially, require search
- Q: How to retrieve common groups with a user? → A: Client-side filtering of already loaded conversations.
- Q: The WebSocket `online_users_list` only provides currently online users. How should we handle the "Last Seen" timestamp for contacts who are offline when the app boots? → A: Fallback to "Offline" until observed
- Q: As per the spec, the "Reply to Unknown" fix hydrates names directly from local cache (Assumptions). What should the UI fallback to if the cache fails to resolve a previous sender's identity entirely? → A: Fallback to "Unknown User"
- Q: For the "Reply to" context inside a sent message bubble (User Story 4), what is the expected interactive behavior when a user taps the replied message's preview snippet? → A: Scroll to Original Message

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pro "New Conversation" Flow (Priority: P1)

Users need a frictionless, full-screen contact selection experience to start new direct or group conversations quickly, similar to professional messaging apps like WhatsApp or Telegram.

**Why this priority**: Creating new conversations is a primary action in any messaging app; the flow must be seamless to ensure high user engagement.

**Independent Test**: Can be fully tested by opening the new conversation screen, searching for a user, selecting them, and verifying that the chat detail view opens for composing the first message without sending an empty message prematurely.

**Acceptance Scenarios**:

1. **Given** the user is on the chat list, **When** they tap the "New Chat" button, **Then** a full-screen contact picker slides up with a search bar and a frequently contacted users section.
2. **Given** the user is on the new conversation screen, **When** they type in the sticky search bar, **Then** the list filters in real-time with debounced API calls showing online status indicators for matches.
3. **Given** the user is selecting participants, **When** they toggle "New Group", **Then** they can multi-select users and enter a required group name.
4. **Given** the user has selected a contact, **When** they confirm the selection, **Then** they are navigated directly to the chat detail screen to compose their first message.

---

### User Story 2 - Real-Time Explicit Online Status (Priority: P1)

Users need to know definitively if their contacts are currently online or when they were last seen, updating reliably even when moving the app between the foreground and background.

**Why this priority**: Core to real-time messaging expectations. It reduces communication friction by setting accurate expectations on response times.

**Independent Test**: Can be tested by backgrounding and foregrounding the app to verify the online user list re-syncs, and observing a contact`'`s status change in real time via WebSocket events.

**Acceptance Scenarios**:

1. **Given** the app has just connected or resumed from the background, **When** the WebSocket connection is established, **Then** the app requests and loads the full list of currently online users.
2. **Given** the user is viewing a contact in the chat list or chat header, **When** that contact goes offline, **Then** the UI updates in real-time to show "Last seen [Time]".
3. **Given** a contact who was offline when the app launched, **When** the user views their profile, **Then** the UI displays "Offline" without a timestamp until a new status event is observed.
4. **Given** the user is viewing the conversation list, **When** a contact comes online, **Then** a green dot indicator instantly appears next to their avatar.

---

### User Story 3 - User Profile Page (Priority: P2)

Users need to view detailed information about the people they are chatting with, including their email, role, common groups, and online/last seen status.

**Why this priority**: Enhances trust and communication context, though secondary to the act of messaging itself.

**Independent Test**: Can be fully tested by tapping an avatar in any chat view and verifying the profile slide-in appears with correct user details fetched from the existing cache or API.

**Acceptance Scenarios**:

1. **Given** the user is looking at the conversation list, **When** they tap a user`'`s avatar circle, **Then** the user profile page slides in from the right side of the screen.
2. **Given** the user is looking at a user profile, **Then** they see the user`'`s large avatar, full name, email, role badge, online status, and a list of common group chats.
3. **Given** the user is looking at a user profile, **When** they tap the "Send Message" button, **Then** they are navigated directly to the conversation with that user.

---

### User Story 4 - Accurate "Reply To" Context (Priority: P2)

Users need to see the real name of the person they are replying to in a group or direct chat, instead of a generic "Unknown" placeholder.

**Why this priority**: Fixes a confusing UX issue that degrades the perceived quality of the chat feature by ensuring names are appropriately hydrated.

**Independent Test**: Can be tested by starting a reply to a received message, verifying the sender`'`s actual name is displayed in the preview, sending the reply, and seeing the name preserved in the chat history.

**Acceptance Scenarios**:

1. **Given** the user is in a chat, **When** they initiate a reply to an incoming message, **Then** the reply preview bar displays the original sender`'`s real name instead of "Unknown".
2. **Given** a user has sent a reply, **When** the message appears in the chat history, **Then** the message bubble maintains and correctly displays the original sender`'`s real name.
3. **Given** a visible reply message snippet, **When** the user taps the snippet inside the chat history, **Then** the chat view automatically scrolls to focus on the original message if it exists in the active sequence; if not, a Toast displays "Message is too old to display".
4. **Given** an unresolved participant cache miss, **When** attempting a reply, **Then** the preview defaults securely to "Unknown User".

---

### Edge Cases

- What happens when the app returns from the background but the network is disconnected? (Should handle graceful retry of the `get_online_users` event once reconnected).
- How does the system handle searching for users on very slow network connections? (Debouncing active typing, showing loading spinners).
- What happens if a user tries to start a group chat with no additional participants selected or an empty group name? (Validation and UI feedback).
- How is the `lastSeen` time formatted if the user was last seen years ago versus just a few minutes ago? (Use relative datetime formatting).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a full-screen, slide-up "New Conversation" interface featuring a sticky search bar.
- **FR-002**: System MUST display up to the 5 most recently contacted users in a dedicated "Frequently Contacted" section of the new conversation screen.
- **FR-003**: System MUST initially hide the "All Contacts" list; contacts are only fetched and populated when the user explicitly searches via the search bar.
- **FR-004**: System MUST immediately navigate the user to the main chat detail view to compose their first message upon selecting a contact for a new conversation.
- **FR-005**: System MUST allow users to view a full User Profile page triggered from the chat list avatar, chat detail header, and new conversation contact touch interactions; "Common Groups" MUST be derived client-side by filtering existing conversations.
- **FR-006**: System MUST emit an event to request the total list of online users (`get_online_users`) upon initial WebSocket connection and whenever the app resumes from the background state.
- **FR-007**: System MUST track, cache, and display the `lastSeen` timestamp for users when they go offline; if an offline user's timestamp is unknown at launch, the system MUST fallback to displaying "Offline".
- **FR-008**: System MUST hydrate the original sender`'`s name when a user replies to a message, ensuring "Reply to Unknown" is replaced with the correct contact name in both the preview bar and sent message bubble. If cache hydration fails, fallback to rendering "Unknown User".
- **FR-009**: System MUST allow users to interact smoothly with sent reply context fields; tapping a received or sent 'reply' snippet within the message bubble MUST seamlessly scroll the chat viewport to that original message reference, or show a Toast "Message is too old to display" if it is not in the active sequence.
- **FR-010**: System MUST allow toggling between direct and group chat creation from the new conversation screen, enforcing a minimum of two participants and a group name input for groups.

### Key Entities

- **User Profile Context**: Represents the displayable metadata of a contact (Avatar, Full Name, Email, Role, Online Status, Last Seen timestamp).
- **Online Presence State**: Represents a user`'`s real-time availability (Boolean `isOnline`, DateTime `lastSeen`).
- **Participant Cache**: The local state representing known chat participants, utilized to resolve accurate names for the "Reply to" functionality.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully navigate to and select a contact to start a new chat perfectly without any application crashes.
- **SC-002**: Real-time online status for all visible contacts is fetched and rendered accurately within 2 seconds of the app returning to the foreground.
- **SC-003**: 100% of replies sent to known participants correctly resolve and display the original sender`'`s actual name rather than rendering the "Unknown" placeholder.
- **SC-004**: During user searches, queries debounce correctly to issue minimal network calls and return results without causing UI stuttering during rapid typing.

## Assumptions

- The backend REST endpoints (`GET /api/messages/users/search`) and WebSocket events (`get_online_users`, `online_users_list`, `user_status`) are fully implemented and behave according to the existing API documentation.
- The 5 "Frequently Contacted" users can be derived purely client-side from the existing `GET /api/messages/conversations` payload by referencing recent active direct chats.
- Blocking and reporting users is strictly out of scope for Phase 7 (UI placeholders only).
- The `replyTo` context can be fully hydrated client-side purely from existing user caches inside the `ChatBloc` memory state without needing synchronous backend requests per reply.

