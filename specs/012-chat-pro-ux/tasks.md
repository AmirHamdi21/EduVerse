
# Implementation Tasks: Pro Chat UX Enhancements

**Feature Board**: `012-chat-pro-ux`
**Spec Reference**: [spec.md](./spec.md)
**Plan Reference**: [plan.md](./plan.md)

## Phase 1: Setup

- [ ] T001 Initialize Phase 7 by verifying dependencies defined in `pubspec.yaml` (e.g., `socket_io_client`, `go_router`) and syncing the workspace tree.

## Phase 2: Foundational

- [ ] T002 Update `lib/bloc/chat/chat_state.dart` to add `userLastSeen` (Map), `frequentlyContacted` (List), `contactSearchResults` (List), and `participantCache` (Map) per data-model constraints.
- [ ] T003 Update `lib/bloc/chat/chat_event.dart` and `lib/bloc/chat/chat_bloc.dart` with events to fetch online users (`get_online_users`), parse frequent contacts, and execute participant caching.
- [ ] T004 Update `lib/services/chat/chat_socket_service.dart` to emit `get_online_users` upon connection and listen for `online_users_list` array to push to the BLoC.
- [ ] T005 Update `lib/models/chat/chat_models.dart` to include the `HydratedMessage` extension; Create `lib/models/chat/user_profile_context.dart`.

## Phase 3: Pro "New Conversation" Flow [US1]

**Goal**: Frictionless, full-screen contact selection experience to start new direct or group conversations quickly.
**Test**: Can search for a user, select them, and automatically open chat detail view without premature blank message sent.

- [ ] T006 [US1] Delete `lib/widgets/shared/chat/shared_new_chat_dialog.dart` as it is permanently replaced by the full-screen flow.
- [ ] T007 [P] [US1] Create `lib/widgets/shared/chat/frequently_contacted_section.dart` properly displaying the up to 5 most recently contacted users.
- [ ] T008 [P] [US1] Create `lib/widgets/shared/chat/contact_list_item.dart` to render individual generic contacts with avatars and online status indicators.
- [ ] T009 [US1] Create `lib/screens/shared/chat/new_conversation_screen.dart` implementing the full-screen UI with a sticky search bar, real-time filtering, group toggle logic, an initially hidden "All Contacts" state, and `go_router` navigation hooks.
- [ ] T010 [US1] Update `lib/widgets/shared/chat/shared_chat_header.dart` to navigate via `go_router` to the new conversation screen when the `+` button is tapped, dropping old dialog modal logic.

## Phase 4: Real-Time Explicit Online Status [US2]

**Goal**: Definitively show if contacts are online or when they were last seen updating reliably.
**Test**: Verify the online user list re-syncs on app foreground, and contact status updates in real-time.

- [ ] T011 [US2] Update `lib/bloc/chat/chat_bloc.dart` to integrate actively with `WidgetsBindingObserver.didChangeAppLifecycleState` to fire an explicit presence refresh event when the app returns from the background.
- [ ] T012 [P] [US2] Update `lib/widgets/shared/chat/shared_conversation_tile.dart` to compute and render green dot indicators based on the enriched `ChatState.onlineUsers`.
- [ ] T013 [P] [US2] Update `lib/widgets/shared/chat/shared_chat_detail_view.dart` header to display "Online" or securely calculate and format "Last seen [Time]" via `ChatState.userLastSeen`. Ensure fallback reads as "Offline" unlinked to time if missing.

## Phase 5: User Profile Page [US3]

**Goal**: View detailed info about chat participants including email, role, common groups, and presence.
**Test**: Tap an avatar in a chat view and verify the profile slide-in appears correctly populated.

- [ ] T014 [US3] Create `lib/widgets/shared/chat/profile_header.dart` featuring a prominently large avatar, full name, and online/last seen semantic badge.
- [ ] T015 [P] [US3] Create `lib/widgets/shared/chat/profile_info_section.dart` listing email, active role badge, and a conditionally rendering list of common group conversations.
- [ ] T016 [US3] Create `lib/screens/shared/chat/user_profile_screen.dart` assembling the completed profile UI relying fully on `UserProfileContext` injected from BLoC state.
- [ ] T017 [US3] Update `lib/widgets/shared/chat/shared_conversation_tile.dart` adding gesture taps to navigate via `go_router` to the new profile screen.
- [ ] T018 [US3] Update `lib/widgets/shared/chat/shared_chat_detail_view.dart` fixing header avatar/name clicks to similarly navigate via `go_router` to the target user`'`s profile screen.

## Phase 6: Accurate "Reply To" Context [US4]

**Goal**: Replace "Reply to Unknown" with properly hydrated real names and interactive deep-linked snippets.
**Test**: Start a reply, verify accurate sender name in the preview, send, preserve name in history, and tap to scroll to original message.

- [ ] T019 [US4] Update the reply preview bar inside `lib/widgets/shared/chat/shared_chat_detail_view.dart` to resolve `message.hydratedReplyToName(participantCache)` ensuring "Unknown User" acts as a safe deterministic fallback.
- [ ] T020 [US4] Update `lib/widgets/shared/chat/shared_message_bubble.dart` to calculate and render the correct original sender name in the natively embedded reply snippet.
- [ ] T021 [US4] Implement `ScrollController` or `AutoScrollTag` anchor bindings in `lib/widgets/shared/chat/shared_chat_detail_view.dart` and `shared_message_bubble.dart` to automatically scroll the history viewport when a reply excerpt acts as an active link tap.

## Final Phase: Polish & Cross-Cutting Concerns

- [ ] T022 Clean up TA Courses Mock Data: Strictly auditing against `courses_backend_integration_plan.md` and the frontend equivalents, completely check for and delete unused static/dummy files related to the TA Courses feature originating from past phases prior to backend integration (e.g., `lib/screens/ta/courses/` obsolete mocks or local `setState` leftovers) to maintain clean repository hygiene.
- [ ] T023 Write specific Unit Tests for `ChatBloc` state transitions, `participantCache` logic, and `ChatSocketService` events to ensure BLoC testability mandates are met.
- [ ] T024 Run comprehensive end-to-end tests for chat enhancements: 1) Verify the new conversation full-screen picker, 2) Validate explicit real-time online/offline statuses during lifecycle shifts, 3) Test User Profile slide-in UI flows, 4) Verify accurate reply name hydration alongside functional deep-scrolling.

## Dependencies

- **US1** and **US2** depend directly on resolving **Phase 2: Foundational** state architectures first.
- **US3** depends on **US2** (last seen functionality) to accurately complete User Profile render conditions.
- **US4** depends on model additions configured in **Foundational**.
- **Final Phase:** TA courses cleanup may be executed completely asynchronously, but full QA regression requires completing all other preceding USs.

## Implementation Strategy

We recommend starting immediately integrating the core `userLastSeen` and search states into the core layers (Foundational). A secondary engineer or parallel thread can begin scaffolding the `User Profile Page` (US3) UI components mockingly until the dependencies finish. Proceed with US1 directly replacing the dialog thereafter.

