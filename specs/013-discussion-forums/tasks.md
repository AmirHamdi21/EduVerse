# Implementation Tasks: Discussion Forums — Backend Integration & Unified UI/UX

**Feature Branch**: `013-discussion-forums`
**Generated**: April 9, 2026

## Phase 1: Setup

- [X] T001 Initialize Freezed generator builds and confirm `build_runner` runs correctly for code gen in `lib/models/discussion`
- [X] T002 Ensure `/api/discussions` route is properly accessible in existing `DioClient` (configure token interceptors if needed based on API docs constraint)

## Phase 2: Foundational (Data Models & Services)

- [X] T003 Create `DiscussionThread` Freezed data model in `lib/models/discussion/discussion_models.dart` matching website API shape (`id`, `courseId`, `createdBy`, `title`, `description`, `isPinned`, `isLocked`, `viewCount`, `replyCount`, `createdAt`)
- [X] T004 Create `DiscussionReply` Freezed data model in `lib/models/discussion/discussion_models.dart` matching website API shape (`id`, `threadId`, `userId`, `messageText`, `parentMessageId`, `isAnswer`, `isEndorsed`, `endorsedBy`, `createdAt`)
- [X] T005 Implement `DiscussionService` in `lib/services/api/discussion_service.dart` wrapping HTTP `GET`/`POST`/`PUT`/`DELETE`/`PATCH` endpoints to `/api/discussions` according to API Contracts
- [X] T006 Define `DiscussionState` Freezed model in `lib/bloc/discussions/discussion_state.dart` with paginated sequences, current course ID, and role-based `canModerate` flag
- [X] T007 Define `DiscussionEvent` class and subclasses in `lib/bloc/discussions/discussion_event.dart` for LoadThreads, SelectThread, CreateThread, PostReply, Pagination, and Moderation events
- [X] T008 Implement `DiscussionBloc` in `lib/bloc/discussions/discussion_bloc.dart` tying `DiscussionEvent` to `DiscussionService` with deduplication logic for ID-based pagination offset shifts
- [X] T009 Register `DiscussionBloc` dependency injection above Role Dashboards in `lib/main.dart` or appropriate parent provider

## Phase 3: User Story 1 - View and Participate in Discussions (P1)

- [X] T010 [US1] Create `SharedDiscussionThreadTile` in `lib/widgets/shared/discussions/shared_discussion_thread_tile.dart` displaying thread title, view/reply count, pinned/locked badges, and time
- [X] T011 [US1] Create `SharedDiscussionThreadList` in `lib/widgets/shared/discussions/shared_discussion_thread_list.dart` utilizing `DiscussionBloc` state, ensuring pinned threads rank first
- [X] T012 [P] [US1] Create `SharedDiscussionEmptyState` in `lib/widgets/shared/discussions/shared_discussion_empty_state.dart`
- [X] T013 [P] [US1] Create `SharedDiscussionHeader` in `lib/widgets/shared/discussions/shared_discussion_header.dart` including the "+ New Thread" button controlled by role logic
- [X] T014 [US1] Create `SharedDiscussionReplyBubble` in `lib/widgets/shared/discussions/shared_discussion_reply_bubble.dart` handling child reply indentations, role badges, and default text
- [X] T015 [US1] Create `SharedDiscussionReplyInput` in `lib/widgets/shared/discussions/shared_discussion_reply_input.dart` with locked state logic avoiding interaction
- [X] T016 [US1] Create `SharedDiscussionThreadDetail` in `lib/widgets/shared/discussions/shared_discussion_thread_detail.dart` encapsulating header, reply list paginated UI, and replay input
- [X] T017 [US1] Create the main `DiscussionScreen` orchestrator in `lib/screens/shared/discussion_screen.dart` binding BLoC states `threads` & `selectedThread` (explicitly firing a view count increment event to the BLoC on open) with proper `courseId` props and `accentColor`
- [X] T018 [US1] Add `DiscussionScreen` route in standard `go_router` setup matching `/course/:courseId/discussions` to load parameters into BLoC

## Phase 4: User Story 2 - Thread Creation and Management (P2)

- [X] T019 [US2] Implement `SharedDiscussionCreateThread` dialog logic in `lib/widgets/shared/discussions/shared_discussion_create_thread.dart` for posting new topics
- [X] T020 [US2] Wire "Edit Thread" and "Edit Reply" UX workflows opening modals to emit HTTP PUT events to `DiscussionBloc`
- [X] T021 [US2] Expand `DiscussionBloc` state updates handling HTTP 404 thread deletions defensively without crashing UI

## Phase 5: User Story 3 - Forum Moderation and Curation (P2)

- [X] T022 [US3] Add Pin and Lock toggle buttons logic to `SharedDiscussionThreadTile` and `SharedDiscussionThreadDetail` rendering based conditionally on `canModerate` BLoC property
- [X] T023 [US3] Add "Mark as Answer" and "Endorse Reply" long-press interactions to `SharedDiscussionReplyBubble` triggering state emit, conditionally restricted by `canModerate` 
- [X] T024 [US3] Connect Backend REST Actions (`/api/discussions/:id/lock`, `/pin`, etc) to respective `DiscussionBloc` events triggering immediate UI badge shifts
- [X] T024b [US3] Add "Delete Thread" and "Delete Reply" UI button interactions available only to moderators, firing the deletion event to the `DiscussionBloc`

## Phase 6: UI Unification & Dashboard Integrations (Polish)

- [X] T025 Connect Student Dashboard to navigate dynamically to `DiscussionScreen` passing active `courseId` and blue `#3B82F6` accent
- [X] T026 Connect Instructor / TA "Course Chats / Communication" sub-tabs dynamically to target `DiscussionScreen` with active course context and indigo `#4F46E5` accent
- [X] T027 Connect global Admin / IT Admin Dashboards to navigate to `DiscussionScreen` with empty param `courseId` (so they can pick from UI selector) 
- [X] T028 Run Code Audit checking for usage of hardcoded discussion items/mocks or old role-specific files previously managing "discussion-like" activities, deleting them entirely.
- [X] T029 DELETE all old redundant, unused files strictly related to the TA "courses" feature (specifically `lib/screens/ta/courses/` and `lib/widgets/ta/courses/` and related local models) from old iterations prior to backend integration.

## Implementation Strategy & Dependencies

- **Dependency Graph**: Models (Phase 2) -> BLoC/Service (Phase 2) -> Shared List/Detail UIs (Phase 3) -> Dashboards Navigation Routes (Phase 6).
- **Parallel Opportunities**: UIs component isolation (`SharedDiscussionReplyBubble`, `SharedDiscussionThreadTile`) marked `[P]` can be coded in parallel alongside the basic `DiscussionService` logic.
- **Edge Cases Checked**: Deduping of overlapping offset pages is strictly localized in `DiscussionBloc` state mapper. "Thread is locked" toast implemented in `SharedDiscussionReplyInput` block.

---
**Summary Report**
- Total Tasks: 29
- MVP Scope: Tasks T001 to T018 fulfills the complete scope required for User Story 1 (Browsing and participating in standard threads).
- Unification Note: Final cleanup task actively fulfills prompt instruction to audit TA and previous static placeholder code.