# Feature Specification: Role-Specific Screen Integration & Unification

**Feature Branch**: `011-chat-role-integration`  
**Created**: 2026-04-07  
**Status**: Draft  
**Input**: User description: "Phase 6: Role-Specific Screen Integration & Unification - Replace 4 separate role-specific chat implementations with one shared chat screen for all user roles (Student, Instructor, TA, Admin, IT Admin)"

## Clarifications

### Session 2026-04-07

- Q: What screen width breakpoint should trigger the transition between mobile layout (list↔detail navigation) and tablet/desktop layout (side-by-side view)? → A: 600px width (standard mobile/tablet breakpoint)
- Q: Where should the ChatBloc be provided in the widget tree to ensure it's accessible to all five role dashboards? → A: Provide ChatBloc above MaterialApp (single global instance)
- Q: When should the legacy role-specific chat screens and widgets (~25+ files) be deleted from the codebase? → A: After successful smoke tests (validate new screen works first)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Chat Experience Across Roles (Priority: P1)

As any user (Student, Instructor, TA, Admin, or IT Admin), I want to access a single, consistent chat interface from my dashboard so that I can communicate with others without learning different interfaces per role.

**Why this priority**: Core value of the unification effort. Without a working shared chat screen, no other features in this phase can be delivered.

**Independent Test**: Can be fully tested by logging in as any role and verifying the chat interface loads with correct styling, loads conversations, and allows sending messages.

**Acceptance Scenarios** (satisfy FR-001, FR-002):

1. **Given** a logged-in Student, **When** they navigate to the Chat tab, **Then** they see the unified chat screen with blue accent color (Color(0xFF3B82F6)) applied to highlights (selected conversation background, active tab indicator) and message bubbles, displaying their conversations
2. **Given** a logged-in Instructor, **When** they navigate to the Chat tab, **Then** they see the unified chat screen with indigo accent color (Color(0xFF4F46E5)) applied to highlights and message bubbles, displaying their conversations
3. **Given** a logged-in TA, **When** they navigate to the Messages tab, **Then** they see the unified chat screen with indigo accent color (Color(0xFF4F46E5)) applied to highlights and message bubbles, displaying their conversations
4. **Given** a logged-in Admin, **When** they navigate to the Messages tab, **Then** they see the unified chat screen with indigo accent color (Color(0xFF4F46E5)) applied to highlights and message bubbles, displaying their conversations
5. **Given** a logged-in IT Admin, **When** they navigate to the Chat tab (new), **Then** they see the unified chat screen with blue accent color (Color(0xFF3B82F6)) applied to highlights and message bubbles, displaying their conversations

---

### User Story 2 - IT Admin Chat Access (Priority: P1)

As an IT Admin, I want to access the chat feature from my dashboard so that I can communicate with other staff and users, which was previously unavailable to me.

**Why this priority**: IT Admin currently has no chat screen, creating a critical gap in role parity. This enables IT Admin communication capabilities.

**Independent Test**: Can be fully tested by logging in as IT Admin, finding the new Chat tab in the sidebar, opening it, and sending a message.

**Acceptance Scenarios**:

1. **Given** an IT Admin dashboard with no existing chat access, **When** the feature is deployed, **Then** a new "Chat" tab appears in the IT Admin sidebar under Communication
2. **Given** an IT Admin on the Chat tab, **When** they start a new conversation, **Then** they can search for users and send messages using the same interface as other roles
3. **Given** an IT Admin viewing conversations, **When** they receive a new message, **Then** the conversation updates in real-time with unread indicators

---

### User Story 3 - Responsive Layout Switching (Priority: P2)

As any user, I want the chat interface to adapt to my device screen size so that I can use chat effectively on both mobile phones and larger displays (tablets/desktops).

**Why this priority**: Essential UX requirement to maintain usability across different form factors. Without this, the unified screen may be unusable on certain devices.

**Independent Test**: Can be tested by resizing the browser/device and verifying the layout transitions smoothly between mobile (list↔detail navigation) and tablet/desktop (side-by-side) modes.

**Acceptance Scenarios**:

1. **Given** a user on a mobile device (screen width < 600px), **When** they select a conversation, **Then** the view navigates from the conversation list to the message detail view
2. **Given** a user on a mobile device viewing messages, **When** they tap the back button, **Then** they return to the conversation list
3. **Given** a user on a tablet/desktop (screen width ≥ 600px), **When** they view chat, **Then** they see the conversation list and message detail side-by-side
4. **Given** a user resizing their browser window, **When** the width crosses the 600px breakpoint threshold, **Then** the layout smoothly transitions between mobile and tablet/desktop modes

---

### User Story 4 - Role-Specific Styling Preservation (Priority: P2)

As a user, I want the chat interface to match my dashboard's visual theme (accent color, dark mode) so that the experience feels cohesive and integrated within my role's overall design.

**Why this priority**: Visual consistency is important for user trust and professional appearance. Different roles have established brand colors that should be preserved.

**Independent Test**: Can be tested by logging in as different roles and verifying the accent colors match the expected values for each role.

**Acceptance Scenarios**:

1. **Given** a Student using light mode, **When** they view chat, **Then** message bubbles and UI elements use blue (#3B82F6) accent color
2. **Given** an Instructor using dark mode, **When** they view chat, **Then** the interface respects dark mode styling with indigo (#4F46E5) accents
3. **Given** a TA switching themes, **When** they toggle dark mode, **Then** the chat interface updates to reflect the new theme immediately
4. **Given** any user, **When** they view chat, **Then** their display name shows correctly based on their authenticated profile

---

### User Story 5 - Legacy Screen Deprecation (Priority: P3)

As a developer/maintainer, I want the old role-specific chat implementations removed so that the codebase has a single source of truth for the chat feature, reducing maintenance burden and bug surface.

**Why this priority**: Code cleanup improves maintainability but is not user-facing. Must happen after new unified screen is proven stable through smoke tests.

**Independent Test**: Can be tested by verifying no orphaned imports, no broken routes, and successful build after removal of legacy files.

**Acceptance Scenarios** (satisfy FR-010):

1. **Given** the unified chat screen is deployed and smoke tested successfully across all roles (per FR-010 criteria: each role sends ≥1 message, receives ≥1 message, unread count updates), **When** legacy Student ChatScreen is removed, **Then** the app builds successfully with no broken references
2. **Given** legacy Instructor/TA/Admin chat screens removed per FR-010 deletion timing, **When** users access their dashboards, **Then** they are correctly routed to the new shared screen
3. **Given** all legacy chat widgets removed (~25+ files) per FR-010, **When** running the app, **Then** no runtime errors occur and chat functionality remains intact

---

### Edge Cases

**Terminology note**: This spec uses "smoke tests" consistently with tasks.md (not "QA verification").

- **Edge Case 1**: What happens when a user's role changes (e.g., Student becomes TA) while they have an active chat session? System should handle role transitions gracefully by applying the new role's styling on next login. (Coverage: T043a validates or marks out-of-scope)
- **Edge Case 2**: How does the system handle a user logged into multiple roles simultaneously (if allowed)? The chat screen should use the accent color and settings for the currently active dashboard.
- **Edge Case 3**: What happens when the ChatBloc is not provided in the widget tree? The screen should show a graceful error state per FR-011 rather than crashing. (Coverage: T043b validates error message, T058 implements)
- **Edge Case 4**: How does the system handle deep links to chat from different role dashboards? Routes should resolve to the correct shared screen with proper role context.
- **Edge Case 5**: What happens when the unified screen is accessed offline (no backend connection)? Cached conversations should display, and a clear offline indicator should be shown. (Coverage: T043c validates)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a single shared chat screen that can be used by all five user roles (Student, Instructor, TA, Admin, IT Admin)
- **FR-002**: System MUST apply role-specific accent colors as Color objects to the chat interface (blue Color(0xFF3B82F6) for Student/IT Admin, indigo Color(0xFF4F46E5) for Instructor/TA/Admin). "Highlights" are defined as: selected conversation background and active tab indicator.
- **FR-003**: System MUST display the current user's authenticated name in the chat interface
- **FR-004**: System MUST support both mobile layout (list↔detail navigation for screens < 600px width) and tablet/desktop layout (side-by-side for screens ≥ 600px width)
- **FR-005**: System MUST integrate with the existing ChatBloc for state management
- **FR-006**: System MUST compose the conversation list component (from Phase 3), message detail component (from Phase 4), and new chat dialog component (from Phase 5). Before composing, system MUST validate that each component accepts required props: ConversationListWidget(accentColor, isDark), MessageDetailWidget(accentColor, isDark, showBackButton), NewConversationDialog(accentColor).
- **FR-007**: System MUST add a Chat tab to the IT Admin dashboard navigation
- **FR-008**: System MUST update existing role dashboard routes to point to the new shared chat screen
- **FR-009**: System MUST support dark mode/light mode theming based on the dashboard's current theme
- **FR-010**: System MUST remove all legacy role-specific chat screens and widgets only after successful smoke tests validate the unified chat screen works correctly for all five roles. Smoke test pass criteria: Each role must successfully send ≥1 message, receive ≥1 message, and verify unread count updates correctly.
- **FR-011**: System MUST provide ChatBloc as a single global instance by wrapping MaterialApp with BlocProvider<ChatBloc> in main.dart (not as sibling), ensuring accessibility to all role dashboards without duplication
- **FR-012**: System MUST display a graceful error state with retry option if chat screen load time exceeds 2 seconds due to network timeout, rather than indefinitely loading

### Key Entities

- **SharedChatScreen**: The unified chat screen component that accepts role-specific configuration props (accentColor, currentUserName, currentUserId, isDark)
- **RoleConfiguration**: Per-role settings defining accent color, default user display name fallback, and layout preferences
- **DashboardRoute**: Navigation configuration mapping each role's chat tab to the shared screen with appropriate props

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All five user roles can access and use the chat feature within 3 taps/clicks from their dashboard (validated by manual QA testing)
- **SC-002**: The chat interface loads within 2 seconds on typical network conditions (50ms latency) for all roles. If timeout occurs, system displays error state per FR-012.
- **SC-003**: 100% of chat functionality (send, receive, search, new conversation, delete) works identically across all five roles
- **SC-004**: Zero visual discrepancies when switching between mobile and tablet/desktop layouts
- **SC-005**: Codebase reduction of 25+ legacy widget files after cleanup
- **SC-006**: IT Admin users can successfully send and receive messages (new capability)
- **SC-007**: Application build time is not increased (same or faster) after removing redundant code
- **SC-008**: No user-reported regressions in chat functionality for existing roles after migration

## Assumptions

- Phases 1-5 (Core Infrastructure, Shared Models, Conversation List UI, Message Detail UI, New Conversation Flow) are complete and functional
- The ChatBloc, ChatService, and ChatSocketService are fully implemented and tested
- The existing role dashboards use a standard navigation pattern (sidebar tabs) that can be modified to point to the shared screen
- All roles have existing authentication mechanisms that provide user ID and name
- The go_router navigation system is already in place for routing between screens
- IT Admin dashboard exists and follows the same structural pattern as other role dashboards
- Dark mode toggle functionality already exists at the dashboard level
- The existing conversation list, message detail, and new chat dialog widgets from previous phases accept the required props (accentColor, isDark, etc.)
