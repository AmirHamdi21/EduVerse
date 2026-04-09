# Feature Specification: Chat Cleanup, Caching & Polish

**Feature Branch**: `014-chat-cleanup-polish`
**Created**: 2026-04-09
**Status**: Draft
**Input**: User description: "Phase 9: Chat Cleanup, Caching & Polish"

## Overview

This phase finalises the EduVerse Flutter chat (Phases 1–8) by removing all leftover mock data, adding offline-first caching for conversations and messages, polishing connection-status feedback, tightening error-handling and empty states, optimising UI performance, removing Flutter-only divergences not present on the website, and performing a final feature-parity audit against the website frontend and backend API.

After this phase, no hardcoded or simulated data must exist anywhere in the chat or discussion codebase, and the app must behave identically to the website's `MessagingChat` component for all five roles.

---

## Clarifications

### Session 2026-04-09

- Q: What should the cache invalidation strategy be? → A: Stale-while-revalidate — always show cached data regardless of age, replace with fresh data silently when network returns.
- Q: Should cached chat data be cleared when the user logs out? → A: Yes, clear all cached chat data on logout (secure default, prevents data leakage on shared devices).
- Q: What should happen when cache write fails due to full device storage? → A: Show a non-blocking warning toast ("Storage full — offline mode unavailable") and continue without caching.
- Q: How should new incoming messages behave when the user is scrolled up viewing history? → A: Buffer new messages and show a "↓ New messages" floating indicator; tapping it scrolls to bottom and reveals them.
- Q: Should the chat swipe-action settings screen and model be retained or removed? → A: Keep both — accept as a Flutter-only mobile UX enhancement that does not conflict with website parity.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Offline-First Cached Conversations (Priority: P1)

A user opens the app in an area with no connectivity. They expect to see their previous conversations and recent messages immediately, rather than a blank screen or a spinner that never resolves.

**Why this priority**: Caching is the single biggest reliability gap between the current Flutter app and the website. Without it, any network hiccup renders the chat section completely unusable. Every other polish item is secondary.

**Independent Test**: Launch the app once with connectivity, let conversations load, enable airplane mode, kill and relaunch the app — the conversation list renders within 2 seconds using cached data and a visible "Offline" indicator is shown.

**Acceptance Scenarios**:

1. **Given** a user has previously loaded their chat conversations, **When** they open the app without internet access, **Then** their conversation list appears within 2 seconds showing cached data and a persistent "Offline" status indicator.
2. **Given** the app is offline showing cached data, **When** connectivity is restored, **Then** the app silently fetches fresh conversations in the background and updates the list without a full-screen loader, and the status indicator changes to "Live".
3. **Given** a user has opened a conversation before, **When** they open it offline, **Then** the last 50 messages of that conversation are visible from cache.
4. **Given** there is no cached data at all (first run, or cache cleared), **When** the app is offline, **Then** a friendly empty state is shown explaining that a connection is needed to load chats for the first time.

---

### User Story 2 — Real-Time Connection Status Feedback (Priority: P1)

A user wants to know at a glance whether their messages are being sent live or queued, and whether the app is reconnecting after a connection drop.

**Why this priority**: The website already shows a green "Live" / red "Offline" badge. Without it, users send messages with no feedback and assume the app is broken. This matches the parity requirement directly.

**Independent Test**: Disconnect device from network while app is open → verify a red "Offline" badge appears within 3 seconds. Reconnect → verify it turns green "Live" and auto-reconnects without requiring user action.

**Acceptance Scenarios**:

1. **Given** the app has an active WebSocket connection, **When** the chat screen is visible, **Then** a green "Live" badge is always visible in the chat header.
2. **Given** the WebSocket disconnects (network loss, server restart), **When** the chat screen is visible, **Then** a red "Offline" badge replaces the "Live" badge within 3 seconds.
3. **Given** the app is showing "Offline", **When** connectivity is restored, **Then** the app automatically reconnects without user intervention, the badge returns to "Live", and any messages composed offline are dispatched.
4. **Given** reconnection is in progress, **When** the user looks at the header, **Then** a subtle reconnecting animation or label is shown (not a blocking dialog).

---

### User Story 3 — Meaningful Empty States & Error Messages (Priority: P2)

A user opens a chat section that has no conversations, or searches for something with no results, or encounters a network error. Instead of a blank white screen, they see a helpful prompt explaining the situation and what to do next.

**Why this priority**: Empty states directly affect first-run experience and error recovery. Without them, users assume the app is broken rather than understanding the actual state.

**Independent Test**: Sign in as a brand-new user account with no messages → all five role dashboards show a "No conversations yet" call-to-action instead of blank screens.

**Acceptance Scenarios**:

1. **Given** a user has no conversations, **When** they open the chat screen, **Then** a clear empty state message with a "Start a new conversation" action is shown.
2. **Given** a user searches for a contact with a query that returns no results, **When** the search completes, **Then** a "No results for '…'" label is shown instead of a blank list.
3. **Given** a network request fails (non-auth error), **When** the chat screen would normally show data, **Then** a user-friendly error message with a "Try again" action is shown.
4. **Given** a conversation has no messages yet, **When** the user opens it, **Then** a "Say hello!" or "No messages yet" placeholder is shown in the message area.

---

### User Story 4 — Smooth and Performant Chat Interactions (Priority: P2)

A user with many conversations or a long message thread experiences smooth scrolling and fast search with no noticeable lag or jank.

**Why this priority**: Performance is a quality-of-life requirement that affects all users across all roles. It is lower priority than caching and connection status because it requires the earlier work to be completed first.

**Independent Test**: Load a conversation with 100+ messages → scrolling is smooth with no dropped frames. Type quickly in the search box → results update after a short pause (≤ 300 ms debounce), not on every keystroke.

**Acceptance Scenarios**:

1. **Given** a user has a conversation list with more than 50 items, **When** they scroll through it, **Then** items load incrementally without loading the entire list upfront.
2. **Given** the user types in the conversation search box, **When** they pause typing, **Then** results update after a short delay (the system debounces input to avoid excessive calls).
3. **Given** a user is typing a message, **When** they are actively composing, **Then** the "typing" indicator sent to other participants auto-stops after the user pauses for 1.5 seconds, matching web behaviour.
4. **Given** a conversation has many messages, **When** the user scrolls up, **Then** older messages load in pages without wiping the current view.

---

### User Story 5 — No Mock or Hardcoded Chat Data in Any Role (Priority: P1)

A tester auditing any of the five role dashboards (Student, Instructor, TA, Admin, IT Admin) finds no sample conversations, placeholder users, generated replies, or simulated data anywhere in the chat or discussion sections.

**Why this priority**: Mock data is the most visible sign of an incomplete integration. Shipping with it would undermine trust in the entire feature.

**Independent Test**: Run a full text search across the codebase for `generateSample`, `simulateReply`, `mockConversations`, and similar identifiers — zero results in production code paths.

**Acceptance Scenarios**:

1. **Given** the app is built in production mode, **When** any role opens the chat or discussion section, **Then** only data returned by the live backend API is displayed.
2. **Given** a role switches between chat tabs, **When** the conversation list is refreshed, **Then** no hardcoded names, avatars, or message texts are visible.
3. **Given** the app was previously using `ChatCubit` with mock generators, **When** the current build is inspected, **Then** those mock generator functions no longer exist.

---

### User Story 6 — Feature Parity Audit Passes Across All Roles (Priority: P3)

A QA engineer comparing the Flutter app side-by-side with the website `MessagingChat` component finds that every feature available on the website is present in the app, and no Flutter-only features that were removed from scope still exist.

**Why this priority**: This is the final gate before the chat module is considered production-complete. It depends on all other stories being done first.

**Independent Test**: Work through the Role Comparison Matrix from the website documentation for each of the 5 roles. Every row that is marked ✅ on the website is also present in Flutter. No filter chips for "Courses", "Instructors", or "Students" exist in the conversation list.

**Acceptance Scenarios**:

1. **Given** the website has a "Live"/"Offline" connection badge, **When** the Flutter app is open, **Then** the same badge behaviour is present for all five roles.
2. **Given** the website does not have a `ConversationType.course` concept, **When** the Flutter app conversation list is inspected, **Then** no "Course" filter chip or course-type conversation exists.
3. **Given** all WebSocket events listed in the backend API docs are handled on the website, **When** the Flutter app receives those same events, **Then** each one produces the correct UI update (new message, typing indicator, deletion, status changes).
4. **Given** the website supports token auto-refresh on expiry, **When** the Flutter app's auth token expires during a session, **Then** the user is not shown a raw error — the token is refreshed silently and the action retried.

---

### Edge Cases

- When the device storage is full and the cache cannot be written, the app shows a non-blocking warning toast ("Storage full — offline mode unavailable") and continues the session using live API data only. Cache writes are skipped until storage is freed.
- When cached data is stale by more than 24 hours and the network is unavailable, the app displays the stale cached data as-is (stale-while-revalidate strategy). No expiry-based clearing occurs; data is refreshed only when connectivity returns.
- When a WebSocket message arrives for a conversation that has been deleted by another participant, the app ignores the event silently and does not create ghost conversations. If the conversation is no longer in the user's list, the incoming event is discarded.
- When the user pastes a large block of text at once, it is treated as a single typing event. The 1.5-second auto-stop timer still applies from the moment of the paste.
- When the search query is cleared (text deleted or "X" tapped), the conversation list reverts to the full unfiltered list immediately with no delay.
- When new messages arrive while the user is scrolled up through history, the messages are buffered at the bottom without moving the scroll position, and a floating "↓ New messages" indicator appears. Tapping the indicator scrolls to the bottom and reveals all buffered messages.
- When token refresh itself fails (e.g., the refresh token has also expired), the user is redirected to the login screen with a "Session expired — please sign in again" message. No raw error is displayed.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST display the cached conversation list within 2 seconds of launch even when the device has no network access.
- **FR-002**: The app MUST cache the most recent 50 messages per conversation and serve them when the network is unavailable.
- **FR-003**: The app MUST display a green "Live" status indicator when the real-time connection is active and a red "Offline" indicator when it is not.
- **FR-004**: The app MUST automatically attempt to reconnect the real-time connection when it is lost, without requiring user action, up to a defined retry limit.
- **FR-005**: The app MUST show a meaningful empty state (with a call-to-action where applicable) for: no conversations, no messages in a conversation, and no search results.
- **FR-006**: The app MUST debounce conversation search input so that the search is triggered only after the user pauses typing, with a maximum delay of 300 milliseconds.
- **FR-007**: The app MUST debounce the outgoing "typing" indicator so it automatically stops being sent 1.5 seconds after the user stops typing.
- **FR-008**: The app MUST load conversation messages in pages, fetching additional pages only when the user scrolls towards the top of the message list.
- **FR-009**: The app MUST use client-side incremental rendering for the conversation list when total conversations exceed 50, loading additional batches as the user scrolls (not rendering the entire list at once).
- **FR-010**: The app MUST contain zero hardcoded, mock, or simulated conversation, message, or user data in any production code path for all five roles.
- **FR-011**: The app MUST remove the `ConversationType.course` model variant and all associated UI elements (filter chips, routing) that are not present in the website's chat system.
- **FR-012**: The app MUST silently refresh the user's authentication token when it expires during an active session and retry the failed request, without displaying a raw error to the user.
- **FR-013**: The app MUST handle temporary network/API request failures by displaying a user-friendly error message and a retry action, rather than crashing or showing a blank screen.
- **FR-014**: The app MUST handle all WebSocket events defined in the backend API specification (`new_message`, `user_typing`, `message_deleted`, `delete_confirmed`, `message_edited`, `user_status`, `online_users_list`, `message_read`, `connection_status`) with the same behaviour as the website frontend.
- **FR-015**: The chat and discussion features MUST function identically (same features, same data, same event handling) across all five roles: Student, Instructor, Teaching Assistant, Admin, and IT Admin.
- **FR-016**: The app MUST use a stale-while-revalidate caching strategy: cached conversation and message data is always displayed regardless of age, and is silently replaced with fresh data when network connectivity is restored. No TTL-based cache expiry is applied.
- **FR-017**: The app MUST clear all locally cached chat data (conversations, messages) when the user logs out, to prevent data leakage on shared devices.
- **FR-018**: If a cache write fails (e.g., device storage full), the app MUST show a non-blocking toast message informing the user that offline mode is unavailable, and MUST continue operating normally using live API data.
- **FR-019**: When the user is scrolled up viewing message history and new messages arrive, the app MUST NOT auto-scroll to the bottom. Instead, it MUST buffer the new messages at the bottom of the list and show a floating "↓ New messages" indicator that, when tapped, scrolls to the latest message.

### Key Entities

- **Cached Conversation**: A locally stored summary of a conversation including its ID, participant info, last message preview, unread count, and timestamp — used to populate the list during offline or initial load. Cache follows stale-while-revalidate: never expires, overwritten silently when fresh data arrives. For predictable performance, persisted conversation cache is capped at 200 entries.
- **Cached Message Page**: A locally stored set of up to 50 messages for a given conversation, used to render the thread when offline.
- **Connection Status**: A runtime value representing whether the real-time connection is currently active ("Live") or inactive ("Offline"), displayed persistently in the chat header.
- **Debounce Timer**: A short-lived delay applied to search input and typing-indicator events to reduce unnecessary network calls.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Cached conversation list renders within 2 seconds of app launch with no network connection, for all five roles.
- **SC-002**: Zero instances of hardcoded, mock, or placeholder conversation/message data exist anywhere reachable through any role's UI in a production build.
- **SC-003**: The real-time connection status badge ("Live"/"Offline") updates within 3 seconds of an actual connection state change, visible to all roles.
- **SC-004**: The app automatically reconnects the real-time channel after a connection loss within one minute, without any user action.
- **SC-005**: All five roles pass a feature-parity checklist where every behaviour marked present on the website is confirmed present in the Flutter app.
- **SC-006**: Search results in the conversation list update no more frequently than once per 300 milliseconds while the user is typing.
- **SC-007**: The "typing" status sent to other participants stops within 1.5 seconds of the user ceasing to type.
- **SC-008**: When a network error occurs, users see a descriptive message and a "Try again" option — no raw error codes or empty screens.
- **SC-009**: Conversations with more than 50 messages support upward pagination, with older messages loading without losing the user's current scroll position.
- **SC-010**: Expired authentication tokens are refreshed silently and the originating request succeeds, with no visible interruption to the user's session.
- **SC-011**: After a user logs out and logs back in (same or different account), zero cached conversations or messages from the previous session are visible.

---

## Assumptions

- All Phases 1–8 have been completed: the shared BLoC, unified UI components, WebSocket service, Discussion Forums, and all five role integrations are in place.
- The backend API and WebSocket server are stable; this phase does not require any backend changes.
- The existing authentication flow already has a mechanism for refreshing tokens that can be leveraged by the HTTP client interceptor — this phase wires the chat operations into it, not build it from scratch.
- Local device storage is available for caching; the specific storage mechanism is an implementation detail left to the planning phase.
- "Production mode" means a release build with no debug-only code paths active.
- The website's `ConversationType` is limited to `direct` and `group`; the `course` type that existed in earlier Flutter iterations is confirmed as out of scope and must be removed.
- Swipe-action settings for chat (`chat_swipe_settings_screen.dart`, `chat_swipe_action_model.dart`) are retained as an accepted Flutter-only mobile UX enhancement. They do not conflict with the unified approach and are not subject to the parity audit.
- The backend's reconnection behaviour (max 5 attempts, 1200 ms delay) is already implemented in `ChatSocketService`; this phase ensures the UI reflects that state accurately.
- Discussion forums are treated as part of the audit scope (ensuring no mock data remains and empty states are in place), but no new discussion features are added in this phase.
