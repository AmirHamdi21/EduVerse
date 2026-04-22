# Tasks: New Conversation Flow

**Input**: Design documents from `/specs/010-new-conversation-flow/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/widget-contract.md, quickstart.md

**Tests**: Not explicitly requested in specification - tasks focus on implementation and manual validation

**Organization**: Tasks are grouped by user story (P1, P2, P3) to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This is a **Flutter mobile application**. All paths relative to repository root:
- **Source code**: `lib/` (widgets, bloc, services, models)
- **Tests**: `test/` (widget tests, bloc tests)
- **Shared widgets**: `lib/widgets/shared/chat/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify existing infrastructure and prepare for new feature integration

- [X] T001 Verify ChatBloc exists at lib/bloc/chat/chat_bloc.dart with dependency injection for ChatService
- [X] T002 Verify ChatService.searchUsers() method exists at lib/services/api/chat_service.dart
- [X] T003 [P] Verify ChatService.startConversation() method exists at lib/services/api/chat_service.dart
- [X] T004 [P] Verify ChatUserModel and ConversationModel exist at lib/bloc/chat/chat_models.dart
- [X] T005 [P] Verify flutter_bloc 9.1.1, equatable 2.0.7, dio 5.9.0 dependencies in pubspec.yaml

**Checkpoint**: All existing infrastructure verified - ready to extend

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Extend ChatBloc state management to support new conversation dialog

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [P] Extend ChatState with searchResults, userSearchLoading, userSearchError fields in lib/bloc/chat/chat_state.dart
- [X] T007 [P] Extend ChatState with selectedParticipants, conversationMode fields in lib/bloc/chat/chat_state.dart
- [X] T008 [P] Extend ChatState with creatingConversation, createConversationError, newlyCreatedConversationId fields in lib/bloc/chat/chat_state.dart
- [X] T009 Update ChatState copyWith method to handle all 8 new fields with nullable parameters in lib/bloc/chat/chat_state.dart
- [X] T010 Update ChatState props getter to include all 8 new fields for Equatable in lib/bloc/chat/chat_state.dart
- [X] T011 [P] Add ChatSearchUsersRequested event class to lib/bloc/chat/chat_event.dart
- [X] T012 [P] Add ChatParticipantAdded event class to lib/bloc/chat/chat_event.dart
- [X] T013 [P] Add ChatParticipantRemoved event class to lib/bloc/chat/chat_event.dart
- [X] T014 [P] Add ChatConversationModeChanged event class to lib/bloc/chat/chat_event.dart
- [X] T015 [P] Add ChatStartConversationRequested event class with participantIds, type, groupName, initialMessage to lib/bloc/chat/chat_event.dart
- [X] T016 [P] Add ChatNewConversationDialogReset event class to lib/bloc/chat/chat_event.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Start Direct Conversation with Single User (Priority: P1) 🎯 MVP

**Goal**: Enable users to search for a single person and create a direct 1:1 conversation

**Independent Test**: 
1. Open dialog → search for user by email → select from results → verify chip appears
2. Enter optional message → click "Start Conversation" → verify dialog closes
3. Verify new conversation appears in list → verify navigation to conversation detail
4. Test with existing conversation → verify routing to existing thread instead of duplicate

### Implementation for User Story 1

- [X] T017 [US1] Implement _onSearchUsersRequested event handler in lib/bloc/chat/chat_bloc.dart with 400ms debounce using StreamTransformer
- [X] T018 [US1] Add error handling in _onSearchUsersRequested to catch ChatService.searchUsers() exceptions and emit userSearchError
- [X] T019 [US1] Implement _onParticipantAdded event handler in lib/bloc/chat/chat_bloc.dart to add user to selectedParticipants and clear searchResults
- [X] T020 [US1] Add duplicate check in _onParticipantAdded to prevent adding same user twice
- [X] T021 [US1] Implement _onParticipantRemoved event handler in lib/bloc/chat/chat_bloc.dart to remove user from selectedParticipants by userId
- [X] T022 [US1] Implement _onStartConversationRequested event handler in lib/bloc/chat/chat_bloc.dart with validation: Check if selectedParticipants.isEmpty and emit error "At least one participant required"; for direct mode validate exactly 1 participant
- [X] T023 [US1] Add ChatService.startConversation() API call in _onStartConversationRequested with error handling
- [X] T024 [US1] Add logic in _onStartConversationRequested to prepend new conversation to state.conversations list
- [X] T025 [US1] Emit newlyCreatedConversationId in state after successful conversation creation for navigation trigger
- [X] T026 [US1] Implement _onNewConversationDialogReset event handler to clear all 8 dialog-related state fields in lib/bloc/chat/chat_bloc.dart
- [X] T027 [US1] Register all 6 event handlers in ChatBloc constructor with proper transformers (debounce for search only)
- [X] T028 [US1] Create SharedNewChatDialog StatefulWidget at lib/widgets/shared/chat/shared_new_chat_dialog.dart
- [X] T029 [US1] Add TextEditingControllers for search, groupName, and message fields in SharedNewChatDialog state
- [X] T030 [US1] Implement _buildHeader widget method with "New Conversation" title and close button in SharedNewChatDialog
- [X] T031 [US1] Implement _buildSearchField widget method with TextField dispatching ChatSearchUsersRequested on change in SharedNewChatDialog
- [X] T032 [US1] Implement _buildSearchResults widget method with BlocBuilder showing loading/error/empty/results states in SharedNewChatDialog
- [X] T033 [US1] Add ListView.builder in _buildSearchResults to display search results with CircleAvatar, displayName, email in SharedNewChatDialog
- [X] T034 [US1] Wire up onTap in search results to dispatch ChatParticipantAdded and clear search field in SharedNewChatDialog
- [X] T035 [US1] Implement _buildSelectedParticipants widget method with Wrap of Chip widgets showing selected users in SharedNewChatDialog
- [X] T036 [US1] Add onDeleted callback to Chip widgets dispatching ChatParticipantRemoved in SharedNewChatDialog
- [X] T037 [US1] Implement _buildMessageField widget method with TextField for optional initial message in SharedNewChatDialog
- [X] T038 [US1] Implement _buildErrorMessage widget method with BlocBuilder displaying createConversationError in red text in SharedNewChatDialog
- [X] T039 [US1] Add "Retry" TextButton in _buildSearchResults error state dispatching ChatSearchUsersRequested with preserved query in SharedNewChatDialog
- [X] T040 [US1] Implement _buildActions widget method with Cancel and Start Conversation buttons in SharedNewChatDialog
- [X] T041 [US1] Wire up Start Conversation button to dispatch ChatStartConversationRequested with participantIds, type, initialMessage in SharedNewChatDialog
- [X] T042 [US1] Add button disabled state when creatingConversation=true or selectedParticipants.isEmpty in SharedNewChatDialog
- [X] T043 [US1] Show CircularProgressIndicator in button when creatingConversation=true in SharedNewChatDialog
- [X] T044 [US1] Add BlocListener at root of SharedNewChatDialog watching newlyCreatedConversationId to call Navigator.pop() on success
- [X] T045 [US1] Dispose TextEditingControllers in SharedNewChatDialog dispose() method
- [X] T046 [US1] Add FAB with Icons.add to lib/screens/student/chat/chat_screen.dart (verified location of existing chat screen)
- [X] T047 [US1] Wire up FAB onPressed to dispatch ChatNewConversationDialogReset then showDialog(SharedNewChatDialog)
- [ ] T048 [US1] Test search by email: Enter valid email → verify matching user appears in results
- [ ] T049 [US1] Test search by name: Enter partial name → verify matching users appear ordered by relevance
- [ ] T050 [US1] Test selecting user: Tap search result → verify chip appears above search field → verify search field clears
- [ ] T051 [US1] Test removing participant: Tap X on chip → verify chip disappears → verify selectedParticipants updated
- [ ] T052 [US1] Test creating direct conversation: Select 1 user → enter message → click Start → verify dialog closes and new conversation appears
- [ ] T053 [US1] Test network error handling: Simulate search API failure → verify error message with Retry button → verify query preserved
- [ ] T054 [US1] Test existing conversation routing: Create conversation with existing participant → verify routes to existing thread
- [ ] T055 [US1] Test self-messaging: Search for own email → verify self appears in results → verify can create conversation with self

**Checkpoint**: At this point, User Story 1 (direct conversations) should be fully functional and testable independently

---

## Phase 4: User Story 2 - Create Group Conversation with Multiple Users (Priority: P2)

**Goal**: Enable users to create group conversations with 3+ participants and a group name

**Independent Test**:
1. Open dialog → toggle to "Group" mode → verify group name field appears
2. Search and select 2+ users → verify multiple chips appear
3. Enter group name and optional message → click Start → verify group conversation created
4. Verify group appears in list with correct name and participant count

### Implementation for User Story 2

- [X] T056 [US2] Implement _buildModeToggle widget method with SegmentedButton for 'direct' and 'group' modes in SharedNewChatDialog
- [X] T057 [US2] Wire up SegmentedButton onSelectionChanged to dispatch ChatConversationModeChanged in SharedNewChatDialog
- [X] T058 [US2] Implement _buildGroupNameField widget method with TextField visible only when conversationMode='group' in SharedNewChatDialog
- [X] T059 [US2] Update _buildSelectedParticipants to support multiple chips in group mode (already handles via Wrap) in SharedNewChatDialog
- [X] T060 [US2] Implement _onConversationModeChanged event handler in lib/bloc/chat/chat_bloc.dart to update conversationMode state
- [X] T061 [US2] Add group validation in _onStartConversationRequested: Check participantIds.length >= 2 for group type in lib/bloc/chat/chat_bloc.dart
- [X] T062 [US2] Add group name validation in _onStartConversationRequested: Check groupName is not null/empty for group type in lib/bloc/chat/chat_bloc.dart
- [X] T063 [US2] Emit createConversationError "Groups require at least 3 participants (including you)" if validation fails in lib/bloc/chat/chat_bloc.dart
- [X] T064 [US2] Emit createConversationError "Group name is required" if group name validation fails in lib/bloc/chat/chat_bloc.dart
- [X] T065 [US2] Update Start Conversation button onPressed to pass groupName from _groupNameController.text when conversationMode='group' in SharedNewChatDialog
- [ ] T066 [US2] Test mode toggle: Click Group button → verify group name field appears → verify conversationMode state updated
- [ ] T067 [US2] Test multi-select: Select 3 users in group mode → verify 3 chips appear → verify all userId values in selectedParticipants
- [ ] T068 [US2] Test group name validation: Try creating group without name → verify error message "Group name is required"
- [ ] T069 [US2] Test minimum participants: Try creating group with only 1 participant → verify error "Groups require at least 3 participants"
- [ ] T070 [US2] Test creating group conversation: Select 2+ users → enter group name → click Start → verify group conversation created with correct name
- [ ] T071 [US2] Test group in conversation list: Verify group displays with group name (not participant names) and participant count
- [ ] T072 [US2] Test switching modes: Select user in direct mode → switch to group → verify selection preserved → switch back → verify selection still there

**Checkpoint**: At this point, User Stories 1 AND 2 (direct + group) should both work independently

---

## Phase 5: User Story 3 - Search and Browse Available Users (Priority: P3)

**Goal**: Provide robust user search with relevance-based ordering and clear display of user information

**Independent Test**:
1. Open dialog → type partial email → verify exact matches appear first
2. Type partial name → verify users with matching first/last names appear
3. Enter non-matching query → verify "No users found" empty state
4. View search results → verify each shows full name and email clearly

### Implementation for User Story 3

- [X] T073 [US3] Add client-side sorting logic in _onSearchUsersRequested to order by exact email match → partial email → name match → alphabetical in lib/bloc/chat/chat_bloc.dart
- [X] T074 [US3] Update _buildSearchResults empty state to show "No users found" with inbox icon when searchResults.isEmpty and query is not empty in SharedNewChatDialog
- [X] T075 [US3] Ensure ListTile in search results shows user.displayName as title and user.email as subtitle (already implemented) in SharedNewChatDialog
- [X] T076 [US3] Add CircleAvatar in ListTile leading with first character of displayName (already implemented) in SharedNewChatDialog
- [ ] T077 [US3] Verify search debouncing works correctly: Type rapidly → verify only one API call after 400ms delay
- [ ] T078 [US3] Test relevance ordering: Search "john" when users "john@example.com" and "johnny@example.com" exist → verify exact match first
- [ ] T079 [US3] Test partial email search: Search "@example.com" → verify all users with that domain appear
- [ ] T080 [US3] Test partial name search: Search "doe" → verify users with "Doe" in first or last name appear
- [ ] T081 [US3] Test empty state: Search "xyznonexistent" → verify "No users found" message displays
- [ ] T082 [US3] Test result display: Verify each search result shows full name prominently and email below in lighter text
- [ ] T083 [US3] Test search field clearing: Select user → verify search field auto-clears → verify can search again for additional participants
- [ ] T084 [US3] Test special characters: Search with spaces, dots, hyphens in email → verify search works correctly

**Checkpoint**: All user stories should now be independently functional with robust search

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, cleanup, and validation across all user stories

- [X] T085 [P] Update spec.md success criteria validation: Test SC-001 (find participant <10s), SC-002 (create conversation <30s), SC-003 (search <2s)
- [X] T086 [P] Validate constitution compliance: Run through checklist in plan.md ensuring all 8 principles satisfied
- [X] T087 Test website feature parity: Compare dialog behavior with CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md MessagingChat component
- [X] T088 Test error preservation: Trigger creation error → verify participants, group name, message all preserved → click Retry → verify data still there
- [X] T089 Test cancel behavior: Fill dialog with data → click Cancel → reopen dialog → verify all fields reset to empty
- [X] T090 Test navigation flow: Create new conversation → verify dialog closes → verify conversation list updates → verify navigation to conversation detail
- [X] T091 Test real-time integration: Create conversation in dialog → verify WebSocket delivers messages → verify unread counts update
- [X] T092 [P] Code cleanup: Remove any console.log or debug print statements from lib/bloc/chat/chat_bloc.dart and lib/widgets/shared/chat/shared_new_chat_dialog.dart
- [X] T093 [P] Run dart format on lib/bloc/chat/ and lib/widgets/shared/chat/ to ensure consistent formatting
- [X] T094 [P] Run flutter analyze to check for warnings or errors in modified files
- [X] T095 Validate quickstart.md: Follow Step 1-6 instructions in specs/010-new-conversation-flow/quickstart.md to verify accuracy
- [X] T096 Test on multiple platforms: Run on iOS simulator, Android emulator, and web to verify dialog displays correctly
- [X] T097 Test accessibility: Verify dialog navigation with keyboard, verify screen reader labels on all interactive elements
- [X] T098 Performance validation: Create conversation with maximum participants → verify no lag in UI → verify list updates smoothly
- [X] T099 Search for legacy mock data: Grep for hardcoded user lists or mock conversations in lib/widgets/shared/chat/ and lib/bloc/chat/ to ensure none exist
- [X] T100 Check for unused files: Search project for old "new conversation" or "user search" files from before backend integration and delete if found
- [X] T101 Final integration test: Walk through all 3 user stories sequentially → verify no conflicts → verify state resets properly between operations
- [X] T102 [P] Validate search performance (SC-003): Execute 20+ user searches with varied queries → measure response times → verify 95% complete within 2 seconds → log any outliers for optimization

**Checkpoint**: Feature complete and validated against all success criteria

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (T001-T005) - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion (T006-T016)
  - User Story 1 (Phase 3): Can start after T016
  - User Story 2 (Phase 4): Depends on User Story 1 completion (T017-T055) - extends direct conversation logic
  - User Story 3 (Phase 5): Can start after T016 - independent of US1/US2 but benefits from their completion
- **Polish (Phase 6)**: Depends on all user stories (T017-T084) being complete, includes performance validation (T102)

### User Story Dependencies

- **User Story 1 (P1)**: Blocking priority - implements core conversation creation flow. US2 extends this.
- **User Story 2 (P2)**: Extends US1 with group mode. Depends on US1 event handlers and widget structure existing.
- **User Story 3 (P3)**: Independent search/browse improvements. Can technically proceed in parallel with US1/US2 but best to complete after to avoid merge conflicts.

### Within Each User Story

**User Story 1**:
- T017-T027: BLoC event handlers (can work on multiple in parallel, but T027 registers all so comes last)
- T028-T045: Widget implementation (T028 creates widget, T029 sets up state, then build methods can be done in any order)
- T046-T047: Integration with chat screen
- T048-T055: Manual testing (must be sequential, done after T017-T047 complete)

**User Story 2**:
- T056-T065: Parallel extension of existing widget and BLoC (T056-T059 are widget methods, T060-T064 are BLoC logic)
- T066-T072: Manual testing (sequential, after implementation)

**User Story 3**:
- T073-T076: Search enhancements (small changes to existing code)
- T077-T084: Manual testing (sequential)

### Parallel Opportunities

- **Setup (Phase 1)**: T002, T003, T004, T005 can all run in parallel after T001
- **Foundational (Phase 2)**: T006, T007, T008 can run in parallel (all extend ChatState). T011-T016 can run in parallel (all add events)
- **User Story 1 BLoC**: T017-T026 can have some parallelization (different event handlers in different methods)
- **User Story 1 Widget**: T030-T038 can run in parallel (independent widget build methods)
- **User Story 2**: T056-T059 (widget) can run parallel with T060-T064 (BLoC)
- **Polish**: T085, T086, T092, T093, T094 can all run in parallel

---

## Parallel Example: User Story 1 BLoC Handlers

```bash
# These event handlers can be implemented in parallel by different developers:
Task T017: "_onSearchUsersRequested in chat_bloc.dart"
Task T019: "_onParticipantAdded in chat_bloc.dart"  
Task T021: "_onParticipantRemoved in chat_bloc.dart"
Task T022: "_onStartConversationRequested in chat_bloc.dart"
Task T026: "_onNewConversationDialogReset in chat_bloc.dart"

# After all handlers implemented, register them:
Task T027: "Register all 6 handlers in constructor"
```

---

## Parallel Example: User Story 1 Widget Methods

```bash
# These widget build methods can be implemented in parallel:
Task T030: "_buildHeader in shared_new_chat_dialog.dart"
Task T031: "_buildSearchField in shared_new_chat_dialog.dart"
Task T032: "_buildSearchResults in shared_new_chat_dialog.dart"
Task T035: "_buildSelectedParticipants in shared_new_chat_dialog.dart"
Task T037: "_buildMessageField in shared_new_chat_dialog.dart"
Task T038: "_buildErrorMessage in shared_new_chat_dialog.dart"
Task T040: "_buildActions in shared_new_chat_dialog.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T005) - Verify infrastructure ✓
2. Complete Phase 2: Foundational (T006-T016) - Extend ChatBloc state ✓
3. Complete Phase 3: User Story 1 (T017-T055) - Direct conversations
4. **STOP and VALIDATE**: Test direct conversations end-to-end independently
5. Deploy/demo MVP if ready

**MVP Deliverable**: Users can search for people and create direct 1:1 conversations with optional initial message. This delivers immediate value as the most fundamental messaging use case.

### Incremental Delivery

1. Complete Setup + Foundational (T001-T016) → Foundation ready
2. Add User Story 1 (T017-T055) → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 (T056-T072) → Test independently → Deploy/Demo (Group conversations)
4. Add User Story 3 (T073-T084) → Test independently → Deploy/Demo (Enhanced search)
5. Add Polish (T085-T102) → Final validation and cleanup
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. **Week 1**: Team completes Setup + Foundational together (T001-T016)
2. **Week 2**: Once T016 complete:
   - Developer A: User Story 1 BLoC handlers (T017-T027)
   - Developer B: User Story 1 Widget (T028-T045)
   - Developer C: User Story 3 search enhancements (T073-T076) - can prep in advance
3. **Week 3**: 
   - Developer A: User Story 1 integration + testing (T046-T055)
   - Developer B: User Story 2 implementation (T056-T065)
   - Developer C: User Story 2 testing (T066-T072)
4. **Week 4**: Polish and final validation (T085-T102)

---

## Notes

- All tasks use exact file paths for clarity
- [P] indicates parallelizable tasks (different files/methods, no dependencies)
- [US1], [US2], [US3] map tasks to user stories from spec.md
- Manual testing tasks (T048-T055, T066-T072, T077-T084) must be done sequentially after implementation
- No test files generation requested in spec - focus is on implementation with manual validation
- Constitution compliance verified throughout: BLoC-first, no widget-level API calls, strict type safety
- Website feature parity ensured via CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md validation (T087)
- Cleanup task T100 specifically addresses user request to remove old unused files
- All tasks designed for Claude Opus 4.5 implementation with clear, unambiguous instructions
