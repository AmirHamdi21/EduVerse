# Feature Specification: Discussion Forums — Backend Integration & Unified UI/UX

**Feature Branch**: `013-discussion-forums`  
**Created**: April 9, 2026  
**Status**: Draft  
**Input**: User description: "Read CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md, CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md and Flutter_Chat_API_Docs_BACKEND.md and create a specification for thePhase 8: Discussion Forums — Backend Integration & Unified UI/UX"

## Clarifications

### Session 2026-04-09
- Q: What level of offline support is required for discussion threads and replies? → A: Option A - No offline caching, network required
- Q: What is the preferred UX when a user tries to reply to a thread at the exact moment a moderator locks it? → A: Option B - Show a specific "This thread has been locked" alert and refresh the thread state
- Q: How should the client app handle offset shifting causing duplicate items during pagination when new replies are added concurrently? → A: Option A - Client-side deduplication by ID when merging new pages
- Q: Are there any website-only fields in the Discussion responses that require strict mapping? → A: Yes, all fields in the API Docs (like `isEndorsed`, `isAnswer`, `endorsedBy`) must be mapped exactly to achieve full data layer separation parity.
- Q: What is the precise scope of deletions for the old TA "courses" feature? → A: Everything inside `lib/screens/ta/courses/`, `lib/widgets/ta/courses/`, and its isolated mockup models.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View and Participate in Discussions (Priority: P1)

Students and Staff need to view course-specific discussion threads, read replies, and actively participate by asking questions or providing answers.

**Why this priority**: Core functionality of the forums; without the ability to read and post, the feature provides no value.

**Independent Test**: Can be fully tested by having an enrolled student navigate to a course forum, read an existing thread, and successfully post a reply.

**Acceptance Scenarios**:

1. **Given** an enrolled student views the course forum, **When** the thread list loads, **Then** they see paginated threads with pinned threads at the top.
2. **Given** an authorized user opens a thread, **When** they submit a new reply, **Then** the reply appears in the thread and the thread's reply count increments.
3. **Given** an unenrolled student attempts to view a course forum, **When** they request access, **Then** they are denied and shown an appropriate unauthorized message.

---

### User Story 2 - Thread Creation and Management (Priority: P2)

Students and Staff need to start new discussion topics to ask questions or share resources, and modify them if they make a mistake.

**Why this priority**: Essential for generating new content and questions in the course forums.

**Independent Test**: Can be fully tested by creating a new thread, verifying its appearance in the list, and editing its title/description.

**Acceptance Scenarios**:

1. **Given** a user is in the course forum, **When** they create a new thread with a title and description, **Then** the thread is published and they are navigated to the new thread's detail view.
2. **Given** a user is the author of a thread, **When** they edit the title or description, **Then** the changes are saved and reflected immediately.

---

### User Story 3 - Forum Moderation and Curation (Priority: P2)

Instructors, TAs, and Admins need to moderate discussions to keep the forum organized, highlight correct answers, and prevent further replies on resolved or off-topic threads.

**Why this priority**: Crucial for maintaining the quality and safety of the learning environment.

**Independent Test**: Can be fully tested by an Instructor logging in, pinning a thread, locking it, and marking a student's reply as the correct answer.

**Acceptance Scenarios**:

1. **Given** a moderator views a thread, **When** they toggle the "Pin" status, **Then** the thread is pinned to the top of the discussion list.
2. **Given** a moderator views a thread, **When** they toggle the "Lock" status, **Then** the system prevents any new replies from being posted to that thread.
3. **Given** a moderator reads replies, **When** they mark a reply as the "Answer" or "Endorse" it, **Then** the reply receives a visual badge and (for answers) is sorted to the top.
4. **Given** a student views the same thread, **When** they look for moderation actions, **Then** the UI hides all moderation buttons (Pin, Lock, Delete, Endorse, Mark Answer).

### Edge Cases

- **Concurrent Lock vs Reply**: If a user submits a reply to a thread that a moderator has just locked, the system MUST show a specific "This thread has been locked" alert, preserve the user's drafted text, and refresh the thread state to prevent further confusion.
- **Concurrent Deletion vs Edit**: If a thread author tries to edit a thread that a moderator has just deleted, the UI MUST handle the 404 gracefully, alert the user the thread no longer exists, and navigate them back to the forum list.
- **Concurrent Pagination Shifts**: If new objects are added while paginating offset-based lists, the frontend client MUST perform deduplication based on item IDs when merging the new page into the existing list.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to view paginated discussion threads for their courses (students MUST be enrolled in the course).
- **FR-002**: System MUST sort pinned threads to the top of the discussion list.
- **FR-003**: System MUST increment a thread's view count when a user opens the thread detail view.
- **FR-004**: System MUST allow authorized users (enrolled students, instructors, TAs, admins) to create new discussion threads.
- **FR-005**: System MUST allow authorized users to post replies to discussion threads.
- **FR-006**: System MUST prevent any new replies from being posted to threads that are marked as locked.
- **FR-007**: System MUST allow thread authors and moderators to edit the title and description of a thread.
- **FR-008**: System MUST allow moderators (Instructors, TAs, Admins, IT Admins) to delete discussion threads.
- **FR-009**: System MUST allow moderators to toggle a thread's pinned status.
- **FR-010**: System MUST allow moderators to toggle a thread's locked status.
- **FR-011**: System MUST allow moderators to mark a specific reply as the accepted answer, which MUST sort it to the top of the replies list.
- **FR-012**: System MUST allow moderators to endorse user replies, displaying an endorsement badge.
- **FR-013**: System MUST provide a unified UI interface used across all 5 user roles, dynamically hiding or showing moderation actions based on the current user's role and permissions.

### Key Entities

- **Discussion Thread**: Represents a forum topic. Contains a course reference, author, title, description, boolean flags for pinned/locked status, view/reply metrics, and timestamps.
- **Discussion Reply**: Represents a response within a thread. Contains a thread reference, author, message text, and boolean flags for accepted answer and staff endorsement.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of discussion UI components utilize a shared, unified widget tree across all 5 user roles, eliminating duplicate role-specific screens.
- **SC-002**: Zero security breaches regarding unauthorized moderation actions (Students cannot access Pin, Lock, Delete, Endorse, or Mark Answer APIs or UI).
- **SC-003**: Paginated loading successfully retrieves subsequent pages of threads or replies in under 1 second on average.
- **SC-004**: The UI visually distinguishes pinned threads, locked threads, endorsed replies, and accepted answers immediately upon viewing.

## Assumptions

- Users have stable internet connectivity to fetch paginated replies and perform actions (No offline caching supported).
- The standard course enrollment logic dictates Student access accurately.
- "Moderators" globally refers to Instructors, Teaching Assistants, Admins, and IT Admins. Instructors/TAs moderate their assigned courses; Admins/IT Admins have global moderation rights.
- Real-time WebSocket updates are out of scope for the discussion forums (unlike real-time messaging), as the Backend API specifically defines these as standard REST actions.
