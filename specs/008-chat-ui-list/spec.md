# Feature Specification: Unified Chat UI — Conversation List

**Feature Branch**: `008-chat-ui-list`  
**Created**: April 6, 2026  
**Status**: Draft  
**Input**: User description: "Read CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md, CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md and Flutter_Chat_API_Docs_BACKEND.md and create a specification for the Phase 3: Unified Chat UI — Conversation List"

## User Scenarios & Testing *(mandatory)*

## Clarifications

### Session 2026-04-06

- Q: When tapping the "+" new chat button, should the UI reveal a modal dialog (matching the frontend website) or navigate to a new dedicated screen? → A: Modal Dialog
- Q: Where should the "Pin", "Mute", and "Delete" swipe actions be located on the conversation tile? → A: Trailing (Right-to-Left format)
- Q: How should the list load additional older conversations if the user scrolls past the initial loaded batch? → A: Infinite Scrolling (Auto-load when near bottom)

### User Story 1 - View Universal Conversation List (Priority: P1)

Users across all roles need a single, unified place to see their active conversations with statuses and unread counts, ensuring a consistent experience.

**Why this priority**: Without the ability to view active conversations, chatting is impossible. This replaces role-fragmented views with a central source of truth.

**Independent Test**: The conversation list loads and displays valid data mapping from the persistent local store, correctly rendering user names, recent messages, and unread counts regardless of the user's role.

**Acceptance Scenarios**:

1. **Given** a user is logged in, **When** they navigate to the Messages tab, **Then** they see a header with connection status ("Live"/"Offline"), latest conversations sorted by recency, and an empty state if no conversations exist.
2. **Given** a conversation list is loaded, **When** a user receives a new message, **Then** the list updates the preview text, timestamp, and unread count dynamically.

---

### User Story 2 - Filter and Search Conversations (Priority: P2)

Users must be able to quickly locate specific conversations using text search or predefined filters.

**Why this priority**: Users with many conversations need a rapid way to find relevant threads (e.g., searching for a specific email or name).

**Independent Test**: Can be tested independently by toggling filter chips ("All", "Unread", "Groups") and entering queries into the search bar, ensuring the displayed list correctly reflects the subset of conversations matching the criteria.

**Acceptance Scenarios**:

1. **Given** a list of conversations, **When** a user types in the search bar, **Then** the list immediately filters conversations matching the query (by name, email, or last message text).
2. **Given** the filter chips are visible, **When** the user selects the "Unread" chip, **Then** only conversations with an unread count > 0 are displayed.

---

### User Story 3 - Conversation Swipe Actions (Priority: P3)

Users should be able to manage individual conversations directly from the list view via intuitive swipe gestures.

**Why this priority**: Enhances list management UX without requiring users to open each conversation thread individually.

**Independent Test**: A swipe on a conversation tile reveals the hidden action menu, and tapping action buttons successfully updates the local view and expected states.

**Acceptance Scenarios**:

1. **Given** a user views a conversation tile, **When** they swipe across the tile horizontally, **Then** quick actions to pin, mute, or delete the conversation are presented.

---

### Edge Cases

- What happens if the user's connection drops while attempting to search? (System should use cached data with offline status shown).
- How does the system handle an entirely empty conversation state? (Displays a distinct call-to-action to "Start a new chat").
- What occurs if a user receives an incoming message for a conversation they just swiped to delete locally? (Depends on the deletion sync, but primarily UI handles local visual removal instantly).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a unified Chat Header containing a "Messages" title, an explicit connection status badge ("Live"/"Offline"), a "+" new chat button (which opens a Modal Dialog for starting new chats), and a search toggle.
- **FR-002**: System MUST render a Search Bar capable of filtering local conversation state by user name, email, or latest message text.
- **FR-003**: System MUST provide Filter Chips constrained to "All", "Unread", and "Groups" categories. All legacy, role-specific filter types (e.g., "Instructors", "Students", "Courses") MUST be removed from UI options.
- **FR-004**: System MUST display a vertically scrollable list of Conversation Tiles that implements Infinite Scrolling (auto-loading when near bottom), each showing an avatar (initials or group icon), an online indicator dot, conversation name, last message preview, timestamp, and unread badge.
- **FR-005**: System MUST allow users to swipe individual Conversation Tiles using a Right-to-Left (Trailing) swipe to expose action buttons for Pin, Mute, and Delete. "Pin" and "Mute" MUST be implemented using purely local state (e.g. `SharedPreferences` or `Hive`) as a mobile-only UX pattern.
- **FR-006**: System MUST supply a structured Empty State displaying when no conversations match the current criteria or when the user has zero existing conversations, including an actionable prompt to start a new chat.
- **FR-007**: System MUST support injecting theme properties (e.g. accent colors and dark mode flags) into the shared components to ensure UI alignment per user role dashboard (Student, Instructor, TA, Admin).
- **FR-008**: System MUST integrate these UI components with the globally shared underlying state aggregators to consume real-time additions and mutations without fragmented view controllers.

### Key Entities

- **Conversation List View**: Displays aggregated user threads, responding purely to injected lists of pre-formatted view models.
- **Conversation Swipe Row Actions**: Exposes quick actions mapped to data-store mutating callbacks.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The unified UI codebase reduces chat list UI duplications from 4 separate implementations across role dashboards down to exactly 1 shared implementation.
- **SC-002**: Filter switching and text searching reflect updated UI states within less than 200ms based on loaded state.
- **SC-003**: The legacy "course" filter and role-specific "colleagues"/"instructors" chips are completely invisible in the new UI.
- **SC-004**: System supports a seamless Dark Mode rendering test without text contrast failures across all user roles.

## Assumptions

- The underlying data aggregators (built in Phase 2) handle all REST and WebSocket aggregations; this phase strictly focuses on building the universal UI presentation components.
- Actions like "Pin" and "Mute" operate purely as local/shared preferences state to enable mobile-friendly swipe mechanics despite no backend support.
- Avatars can naturally fallback to generated initials if true image URL assets are missing from the given user models.
