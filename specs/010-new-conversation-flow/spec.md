# Feature Specification: New Conversation Flow

**Feature Branch**: `010-new-conversation-flow`  
**Created**: 2026-04-07  
**Status**: Draft  
**Input**: User description: "Phase 5: New Conversation Flow - Create shared new chat dialog with email-based user search, direct and group conversation creation"

## Clarifications

### Session 2026-04-07

- Q: When a user searches for themselves in the user search field, what should happen? → A: Users can find and select themselves in search results (allows self-messaging)
- Q: What are the minimum and maximum number of participants allowed in a group conversation? → A: Minimum 3 participants (2 other users + creator), maximum unlimited
- Q: Is the initial message field required when creating a new conversation, or can users create an empty conversation? → A: Initial message is optional; users can create conversations without sending a message
- Q: How should user search results be ordered when multiple users match the search query? → A: Order by relevance (exact matches first, then partial matches), then alphabetically by name
- Q: When a user search or conversation creation fails due to network errors, what retry mechanism should be provided? → A: Show error message with a "Retry" button; keep dialog open with user's data preserved

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start Direct Conversation with Single User (Priority: P1)

A user wants to initiate a new conversation with another user by searching for them via email or name and sending an initial message.

**Why this priority**: This is the most fundamental use case for messaging - one person reaching out to another. Without this, users cannot start any conversations.

**Independent Test**: Can be fully tested by searching for a user, selecting them, typing a message, and verifying the conversation opens with the message sent. Delivers immediate value as a complete chat initiation flow.

**Acceptance Scenarios**:

1. **Given** I am on the chat screen, **When** I click the "New Conversation" button, **Then** a dialog opens with a search field and message input
2. **Given** the new conversation dialog is open, **When** I type an email or name in the search field, **Then** matching users appear in a results list below the search field
3. **Given** search results are displayed, **When** I select a user from the list, **Then** that user is marked as the conversation participant
4. **Given** I have selected a participant and typed a message, **When** I click "Start Conversation", **Then** the dialog closes, a new direct conversation is created, and I am navigated to that conversation with my message sent
5. **Given** I search for a user I already have a conversation with, **When** I start a new conversation with them, **Then** the system routes me to the existing conversation thread and sends my message there instead of creating a duplicate

---

### User Story 2 - Create Group Conversation with Multiple Users (Priority: P2)

A user wants to create a group conversation with multiple participants, give it a name, and send an initial message to all members.

**Why this priority**: Group conversations enable collaboration and multi-party discussions, which is important but less critical than basic one-to-one messaging.

**Independent Test**: Can be tested independently by toggling to group mode, selecting multiple users, entering a group name, and verifying the group conversation is created with all participants.

**Acceptance Scenarios**:

1. **Given** the new conversation dialog is open, **When** I toggle from "Direct" to "Group" mode, **Then** the UI shows a group name input field and allows multiple user selection
2. **Given** I am in group mode, **When** I search for and select multiple users, **Then** all selected users appear as chips or tags showing they are included
3. **Given** I have selected multiple participants, **When** I try to create the group without entering a name, **Then** validation prevents creation and prompts me to enter a group name
4. **Given** I have entered a group name and selected participants, **When** I click "Start Conversation", **Then** a new group conversation is created with the specified name, all participants are added, and my initial message is sent

---

### User Story 3 - Search and Browse Available Users (Priority: P3)

A user wants to search for users by email or name to find the right person to message, seeing helpful information like their full name and email address.

**Why this priority**: While important for usability, the search functionality primarily supports the conversation initiation flows above. It provides discoverability but isn't a standalone feature.

**Independent Test**: Can be tested by entering various search queries and verifying appropriate users appear, even without completing the conversation creation.

**Acceptance Scenarios**:

1. **Given** the new conversation dialog is open, **When** I type a partial email address, **Then** users whose email contains that text appear in the results
2. **Given** the new conversation dialog is open, **When** I type a partial name, **Then** users whose first or last name contains that text appear in the results
3. **Given** I have typed a search query, **When** no users match, **Then** an empty state message indicates no results found
4. **Given** search results are displayed, **When** I view each result, **Then** I can see the user's full name and email address to confirm identity

---

### Edge Cases

- Users can search for and select themselves in the search results, enabling self-messaging conversations
- Group conversations require a minimum of 3 total participants (creator plus 2 others); groups with only 1 other participant should automatically create a direct conversation instead
- Network errors during user search display an error message with a "Retry" button while preserving the user's search query
- Network errors during conversation creation display an error message with a "Retry" button while keeping the dialog open and preserving all user input (selected participants, group name, typed message)
- What happens if the user tries to create a group with only one participant? (Should either prevent this or automatically create a direct conversation)
- How does the system handle creating a conversation when the backend returns an error? (Should show error message and keep dialog open for retry)
- What happens if the user clears the search field after selecting participants? (Selected participants should remain)
- How does the system handle searching with special characters or very long email addresses? (Should sanitize input and handle gracefully)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a "New Conversation" button or action that opens a dialog for creating conversations
- **FR-002**: System MUST allow users to search for other users by entering email address or name in a search field
- **FR-003**: System MUST debounce search input at 400ms after user stops typing to avoid excessive API calls
- **FR-004**: System MUST display search results showing each user's full name and email address
- **FR-004a**: System MUST include the current user in search results, allowing self-messaging
- **FR-004b**: System MUST order search results by relevance: exact email matches first, then partial email matches, then name matches, with alphabetical sorting by full name as secondary ordering within each group (see data-model.md lines 246-259 for implementation details)
- **FR-005**: System MUST allow users to select a single user for direct conversations
- **FR-006**: System MUST allow users to toggle between "Direct" and "Group" conversation modes
- **FR-007**: System MUST allow users to select multiple users when in group mode
- **FR-007a**: System MUST require a minimum of 3 total participants (creator plus 2 other users) for group conversations
- **FR-007b**: System MUST allow unlimited maximum participants in group conversations
- **FR-008**: System MUST require a group name when creating group conversations
- **FR-009**: System MUST provide a text input field for the first message in the conversation
- **FR-009a**: System MUST allow conversation creation without an initial message (message field is optional)
- **FR-010**: System MUST validate that at least one participant is selected before allowing conversation creation
- **FR-011**: System MUST call the backend API to search users when search input changes
- **FR-012**: System MUST call the backend API to create a new conversation with selected participants
- **FR-013**: System MUST handle the case where a direct conversation already exists by routing to that existing conversation (backend returns existing conversation with 'existing: true' flag - see data-model.md lines 287-293)
- **FR-014**: System MUST send the initial message when the conversation is created (if a message was provided)
- **FR-015**: System MUST refresh the conversation list after creating a new conversation
- **FR-016**: System MUST navigate the user to the newly created or existing conversation after successful creation
- **FR-017**: System MUST close the new conversation dialog after successful conversation creation
- **FR-018**: System MUST display error messages when user search fails
- **FR-018a**: System MUST provide a "Retry" button when user search fails due to network errors
- **FR-018b**: System MUST preserve user's search query and selected participants when displaying error messages
- **FR-019**: System MUST display error messages when conversation creation fails
- **FR-019a**: System MUST provide a "Retry" button when conversation creation fails due to network errors
- **FR-019b**: System MUST keep the dialog open and preserve all user input (participants, group name, message) when displaying error messages
- **FR-020**: System MUST clear the dialog form when the user cancels or closes it
- **FR-021**: System MUST limit search results to a reasonable number (e.g., 20 users) to avoid UI overload

### Key Entities

- **User Search Result**: Represents a user that can be added to a conversation, containing user ID, first name, last name, email address
- **Conversation Participant**: Represents a user selected to be included in the new conversation, containing user ID and display information. Group conversations require minimum 3 total participants (creator plus 2 others) with no maximum limit.
- **New Conversation Request**: Represents the data needed to create a conversation, containing participant IDs, conversation type (direct/group), optional group name, and optional initial message text
- **Conversation**: Represents the created conversation thread, containing conversation ID, type, participants, and metadata

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find and select a conversation participant within 10 seconds from opening the dialog, using the search functionality, with most relevant matches appearing first
- **SC-002**: Users can create a new direct conversation and send their first message in under 30 seconds
- **SC-003**: 95% of user searches return results within 2 seconds
- **SC-004**: The system correctly routes 100% of duplicate conversation attempts to existing threads instead of creating duplicates
- **SC-005**: Users successfully create group conversations with the intended participants 100% of the time when all inputs are valid
- **SC-006**: Search results update as users type without requiring a separate search button press
- **SC-007**: The interface clearly distinguishes between direct and group conversation modes

## Assumptions

- Users have the necessary permissions to search for and message other users in the system
- All authenticated users (students, instructors, TAs, admins, IT admins) have equal permissions to search for and message other users - no role-based messaging restrictions apply for this feature
- The backend API endpoints (`/api/messages/users/search` and `/api/messages/conversations`) are functional and return data in the documented format
- Backend API returns existing conversations with an 'existing: true' flag when a direct conversation already exists between two participants, enabling client-side routing to existing threads
- Users are authenticated and have a valid access token before accessing the new conversation flow
- The chat service and BLoC infrastructure from previous phases (Phase 1-4) are already implemented and functional
- Network connectivity is generally stable, though the UI should handle temporary failures gracefully
- The conversation list UI from Phase 3 is already implemented and can be refreshed programmatically
- The message detail UI from Phase 4 is already implemented and can navigate to specific conversations
- Search is performed server-side; the client does not need to cache or filter a full user directory
- A default search limit of 20 users is reasonable for most use cases
- The shared widget will be located at `lib/widgets/shared/chat/shared_new_chat_dialog.dart` following the established project structure
