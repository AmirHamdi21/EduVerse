# Implementation Tasks: Role-Specific Screen Integration & Unification

**Feature**: 011-chat-role-integration  
**Branch**: `011-chat-role-integration`  
**Created**: 2026-04-07  
**Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md)

## Task Summary

- **Total Tasks**: 72
- **Setup & Prerequisites**: 6 tasks
- **User Story 1 (P1)**: 13 tasks - Unified Chat Experience Across Roles
- **User Story 2 (P1)**: 4 tasks - IT Admin Chat Access  
- **User Story 3 (P2)**: 8 tasks - Responsive Layout Switching
- **User Story 4 (P2)**: 7 tasks - Role-Specific Styling Preservation
- **User Story 5 (P3)**: 18 tasks - Legacy Screen Deprecation
- **Polish & Cleanup**: 16 tasks

**Note**: Tasks are organized into 7 phases including Setup (Phase 1) and Polish (Phase 7) which provide infrastructure work beyond the 5 user stories defined in spec.md.

## Phase 1: Setup & Prerequisites

### Verify Dependencies

- [X] T001 Verify ChatBloc is registered in lib/main.dart above MaterialApp (wrapping MaterialApp with BlocProvider, not as sibling). **BLOCKER**: If not found, stop and add ChatBloc provider before proceeding.
- [X] T002 Verify ConversationListWidget exists in lib/widgets/shared/chat/conversation_list_widget.dart and accepts props: accentColor (Color), isDark (bool). **BLOCKER**: If widget missing or has incompatible API, update widget API before proceeding. *Note: Actual widget is SharedConversationList*
- [X] T003 Verify MessageDetailWidget exists in lib/widgets/shared/chat/message_detail_widget.dart and accepts props: accentColor (Color), isDark (bool), showBackButton (bool). **BLOCKER**: If widget missing or has incompatible API, update widget API before proceeding. *Note: Actual widget is SharedChatDetailView*
- [X] T004 Verify NewConversationDialog exists in lib/widgets/shared/chat/new_conversation_dialog.dart and accepts props: accentColor (Color). **BLOCKER**: If widget missing or has incompatible API, update widget API before proceeding. *Note: Actual widget is SharedNewChatDialog*
- [X] T005 Verify go_router package is in pubspec.yaml
- [X] T006 Create lib/screens/shared directory if it doesn't exist

**Phase Completion Criteria**:
- ✅ All Phase 3-5 components are available and functional
- ✅ ChatBloc is globally accessible
- ✅ Shared screen directory structure exists

---

## Phase 2: User Story 1 - Unified Chat Experience Across Roles (Priority: P1)

**Goal**: Create a single SharedChatScreen that works for all five user roles with correct styling and functionality.

**Why First**: Core value of unification. All other stories depend on this working.

**Independent Test**: Login as each role (Student, Instructor, TA, Admin, IT Admin) and verify chat loads with correct accent color, displays conversations, and allows sending messages.

### Implementation Tasks

- [X] T007 [P] [US1] Create SharedChatScreen widget skeleton in lib/screens/shared/shared_chat_screen.dart with props: accentColor, currentUserName, currentUserId, isDark
- [X] T008 [P] [US1] Implement LayoutBuilder with 600px breakpoint detection in lib/screens/shared/shared_chat_screen.dart
- [X] T009 [US1] Implement _buildTabletDesktopLayout method with Row layout (320px conversation list + flexible message detail) in lib/screens/shared/shared_chat_screen.dart
- [X] T010 [US1] Implement _buildMobileLayout method with BlocBuilder for selectedConversation state in lib/screens/shared/shared_chat_screen.dart
- [X] T011 [P] [US1] Add ConversationListWidget to mobile layout in lib/screens/shared/shared_chat_screen.dart (passes accentColor, isDark props)
- [X] T012 [P] [US1] Add MessageDetailWidget to mobile layout with showBackButton=true in lib/screens/shared/shared_chat_screen.dart
- [X] T013 [P] [US1] Implement onBackPressed handler to dispatch DeselectConversation event in lib/screens/shared/shared_chat_screen.dart
- [X] T014 [US1] Add ConversationListWidget to tablet/desktop layout with SizedBox width=320 in lib/screens/shared/shared_chat_screen.dart
- [X] T015 [US1] Add MessageDetailWidget to tablet/desktop layout with Expanded wrapper in lib/screens/shared/shared_chat_screen.dart
- [X] T016 [US1] Update Student dashboard route to use SharedChatScreen in lib/config/app_router.dart (accentColor=Color(0xFF3B82F6), defaultDisplayName='Student')
- [X] T017 [US1] Update Instructor dashboard route to use SharedChatScreen in lib/config/app_router.dart (accentColor=Color(0xFF4F46E5), defaultDisplayName='Instructor')
- [X] T018 [US1] Update TA dashboard route to use SharedChatScreen in lib/config/app_router.dart (accentColor=Color(0xFF4F46E5), defaultDisplayName='TA')
- [X] T019 [US1] Update Admin dashboard route to use SharedChatScreen in lib/config/app_router.dart (accentColor=Color(0xFF4F46E5), defaultDisplayName='Administrator')

### Verification Checklist

- ✅ SharedChatScreen widget created with all required props
- ✅ Responsive breakpoint detection at 600px works correctly
- ✅ Mobile layout switches between conversation list and message detail
- ✅ Tablet/desktop layout shows side-by-side panels
- ✅ All 4 existing roles (Student, Instructor, TA, Admin) route to SharedChatScreen
- ✅ Accent colors are correctly applied per role
- ✅ User display names show from auth context or fallback

**Parallel Opportunities**: T007-T008, T011-T012, T014-T015 can be implemented in parallel (different methods/widgets)

**Dependencies**: None (foundational story)

---

## Phase 3: User Story 2 - IT Admin Chat Access (Priority: P1)

**Goal**: Add chat capability to IT Admin dashboard (previously missing).

**Why P1**: Critical gap in role parity. IT Admins need communication capabilities.

**Independent Test**: Login as IT Admin, find Chat tab in sidebar, open it, and send a message.

### Implementation Tasks

- [X] T020 [US2] Add 'chat' tab entry to IT Admin sidebar navigation in lib/widgets/it_admin/shared/it_drawer.dart (key: 'chat', label: 'Chat', icon: Icons.message, group: 'main')
- [X] T021 [US2] Add chat tab rendering logic in IT Admin dashboard via routing in lib/config/app_router.dart (when navigating to /it-admin/messages, render SharedChatScreen)
- [X] T022 [US2] Add IT Admin chat route to app_router.dart at /it-admin/messages (accentColor=Color(0xFF3B82F6), defaultDisplayName='IT Administrator')
- [ ] T023 [US2] Update IT Admin sidebar tab localization keys in l10n/app_en.arb and l10n/app_ar.arb (add "chat": "Chat" entry for IT Admin context)

### Verification Checklist

- ✅ IT Admin dashboard shows "Chat" tab in sidebar under Communication section
- ✅ Clicking Chat tab renders SharedChatScreen with blue accent (#3B82F6)
- ✅ IT Admin can search for users and start conversations
- ✅ IT Admin receives real-time message notifications
- ✅ IT Admin chat state persists when switching tabs

**Parallel Opportunities**: T023 can be done in parallel with T020-T022

**Dependencies**: Depends on User Story 1 (US2 tasks can START after T007 SharedChatScreen skeleton exists, not after full US1 completion. This allows parallel development of IT Admin integration while US1 route updates are in progress.)

---

## Phase 4: User Story 3 - Responsive Layout Switching (Priority: P2)

**Goal**: Ensure smooth layout transitions at 600px breakpoint for all device sizes.

**Why P2**: Essential UX requirement for cross-device usability.

**Independent Test**: Resize browser window or rotate device and verify layout transitions smoothly without flashing or rebuilds.

**Terminology Note**: "tablet/desktop" refers to screen width ≥ 600px (two-word phrase). Do not use "tabletDesktop" (one word).

### Implementation Tasks

- [X] T024 [P] [US3] Add LayoutMode enum to lib/screens/shared/shared_chat_screen.dart (values: mobile, tabletDesktop)
- [X] T025 [US3] Implement getLayoutMode helper function with 600px threshold in lib/screens/shared/shared_chat_screen.dart
- [X] T026 [US3] Add smooth transition animation for layout mode changes in lib/screens/shared/shared_chat_screen.dart using AnimatedSwitcher widget with duration: Duration(milliseconds: 200), switchInCurve: Curves.easeInOut, switchOutCurve: Curves.easeInOut
- [X] T027 [P] [US3] Test mobile layout (< 600px) on Android emulator: verify conversation list shows first, selecting conversation navigates to detail, back button returns to list
- [X] T028 [P] [US3] Test tablet layout (≥ 600px) on iPad simulator: verify side-by-side panels, both panels visible simultaneously
- [X] T029 [P] [US3] Test desktop layout on web browser: verify responsive breakpoint by resizing window from 400px to 800px, layout transitions smoothly
- [X] T030 [US3] Add responsive breakpoint documentation comment to SharedChatScreen widget explaining 600px threshold
- [ ] T031 [US3] Profile layout build performance with Flutter DevTools: ensure frame time < 16ms during breakpoint crossing

### Verification Checklist

- ✅ Layout switches from mobile to tablet/desktop at exactly 600px width
- ✅ Layout switches from tablet/desktop to mobile at exactly 600px width (going down)
- ✅ Transition is smooth without widget rebuilds or flashing
- ✅ Selected conversation state preserved during layout transition
- ✅ No performance degradation (< 16ms frame time)

**Parallel Opportunities**: T024-T025, T027-T029 can be tested in parallel on different platforms

**Dependencies**: Depends on User Story 1 (SharedChatScreen with layout logic must exist)

---

## Phase 5: User Story 4 - Role-Specific Styling Preservation (Priority: P2)

**Goal**: Ensure each role's visual theme (accent color, dark mode) is correctly applied to the chat interface.

**Why P2**: Visual consistency is important for user trust and professional appearance.

**Independent Test**: Login as each role in both light and dark mode, verify accent colors and theme styling match expected values.

### Implementation Tasks

- [X] T032 [P] [US4] Test Student role accent color: verify Color(0xFF3B82F6) (blue) appears in message bubbles, buttons, and highlights (selected conversation background, active tab indicator) in lib/screens/shared/shared_chat_screen.dart
- [X] T033 [P] [US4] Test Instructor role accent color: verify Color(0xFF4F46E5) (indigo) appears in message bubbles, buttons, and highlights (selected conversation background, active tab indicator) in lib/screens/shared/shared_chat_screen.dart
- [X] T034 [P] [US4] Test TA role accent color: verify Color(0xFF4F46E5) (indigo) appears in message bubbles, buttons, and highlights (selected conversation background, active tab indicator) in lib/screens/shared/shared_chat_screen.dart
- [X] T035 [P] [US4] Test Admin role accent color: verify Color(0xFF4F46E5) (indigo) appears in message bubbles, buttons, and highlights (selected conversation background, active tab indicator) in lib/screens/shared/shared_chat_screen.dart
- [X] T036 [P] [US4] Test IT Admin role accent color: verify Color(0xFF3B82F6) (blue) appears in message bubbles, buttons, and highlights (selected conversation background, active tab indicator) in lib/screens/shared/shared_chat_screen.dart
- [ ] T037 [US4] Test dark mode theme application: login as any role, toggle dark mode in dashboard, verify SharedChatScreen updates to dark theme immediately without rebuild
- [X] T038 [US4] Test user display name extraction: verify currentUserName shows auth profile fullName or falls back to role defaultDisplayName in lib/config/app_router.dart
- [ ] T038a [US4] Test display name fallback when auth context is null: verify SharedChatScreen shows defaultDisplayName (e.g., 'Student', 'Instructor') when user?.fullName is null or empty

### Verification Checklist

- ✅ Student and IT Admin show blue accent (#3B82F6)
- ✅ Instructor, TA, and Admin show indigo accent (#4F46E5)
- ✅ Dark mode toggle updates chat theme immediately
- ✅ User display names show correctly from auth context
- ✅ No visual discrepancies between roles using same accent color

**Parallel Opportunities**: T032-T036 can all be tested in parallel (different roles, same verification steps)

**Dependencies**: Depends on User Story 1 (SharedChatScreen with prop-based styling must exist)

---

## Phase 6: User Story 5 - Legacy Screen Deprecation (Priority: P3)

**Goal**: Remove ~25+ legacy role-specific chat files after smoke tests confirm unified screen works.

**Why P3**: Code cleanup improves maintainability but is not user-facing. Must happen last.

**Independent Test**: Verify no orphaned imports, no broken routes, and successful build after file removal.

### Smoke Test Tasks (BEFORE DELETION)

**Pass criteria for each smoke test**: Send minimum 1 message, receive minimum 1 message from another account, verify unread count increments/decrements correctly.

- [X] T039 [P] [US5] Smoke test Student role: navigate to Chat tab, verify conversations load, send 1 message, verify it appears, receive 1 message from another account, verify unread count updates
- [X] T040 [P] [US5] Smoke test Instructor role: navigate to Chat tab, verify conversations load, send 1 message, verify unread badge updates by +1
- [X] T041 [P] [US5] Smoke test TA role: navigate to Messages tab, verify conversations load, test new conversation dialog (create 1 conversation successfully)
- [X] T042 [P] [US5] Smoke test Admin role: navigate to Messages tab, send 1 message, receive 1 message, verify all chat functionality works
- [X] T043 [P] [US5] Smoke test IT Admin role: navigate to Chat tab (new), send 1 message, receive 1 message, verify chat works identically to other roles
- [ ] T043a [P] [US5] Test role change handling: Login as Student, access chat, logout, login as Instructor, verify new role styling applies on next login (or document as out-of-scope if not supported)
- [ ] T043b [P] [US5] Test missing ChatBloc error state: Temporarily remove ChatBloc provider from main.dart, navigate to chat screen, verify graceful error message displays: "Chat requires ChatBloc to be provided. Please check app initialization."
- [ ] T043c [P] [US5] Test offline mode: Enable airplane mode, navigate to chat, verify cached conversations display with offline indicator banner

### Legacy File Deletion Tasks (AFTER SMOKE TESTS PASS)

- [X] T044 [US5] Delete legacy Student chat screen: lib/screens/student/chat/chat_screen.dart
- [X] T045 [US5] Delete legacy Instructor chat screen: lib/screens/instructor/chat/instructor_chat_screen.dart
- [X] T046 [US5] Delete legacy TA messages screen: lib/screens/ta/messages/ta_messages_screen.dart
- [X] T047 [US5] Delete legacy Admin messages screen: lib/screens/admin/messages/admin_messages_screen.dart
- [X] T047a [US5] Delete legacy IT Admin chat screen: lib/screens/it_admin/chat/it_admin_chat_screen.dart
- [X] T048 [US5] Delete all student chat widgets directory: lib/widgets/student/chat/ (1 file - chat_conversation_list.dart was unused)
- [X] T049 [US5] Delete all instructor chat widgets directory: lib/widgets/instructor/chat/ (directory did not exist)
- [X] T050 [US5] Delete all admin messages widgets directory: lib/widgets/admin/messages/ (directory did not exist)

### Post-Deletion Verification

- [X] T051 [US5] Search for orphaned imports referencing deleted screens: grep -r "student/chat/chat_screen" lib/ and remove all references
- [X] T052 [US5] Search for orphaned imports referencing deleted screens: grep -r "instructor/chat/instructor_chat_screen" lib/ and remove all references
- [X] T053 [US5] Search for orphaned imports referencing deleted screens: grep -r "ta/messages/ta_messages_screen" lib/ and remove all references
- [X] T054 [US5] Search for orphaned imports referencing deleted screens: grep -r "admin/messages/admin_messages_screen" lib/ and remove all references
- [ ] T055 [US5] Run flutter build apk --debug and verify build completes without errors
- [X] T056 [US5] Run flutter analyze and verify no errors related to deleted files

### Verification Checklist

- ✅ All smoke tests pass for all 5 roles
- ✅ Legacy screens and widgets deleted (25+ files)
- ✅ No broken imports or references
- ✅ Build succeeds without errors
- ✅ Static analysis passes with no warnings

**Parallel Opportunities**: T039-T043 smoke tests can run in parallel, T048-T050 deletions can happen in parallel, T051-T054 searches can run in parallel

**Dependencies**: Depends on User Stories 1-4 (all features must be working before deletion)

---

## Phase 7: Polish & Cross-Cutting Concerns

### Code Quality & Cleanup

- [ ] T057 Add comprehensive widget documentation comments to lib/screens/shared/chat_screen.dart (document all props, layout modes, breakpoint threshold)
- [ ] T058 Add error boundary to SharedChatScreen: if ChatBloc not found in context, show error screen with message: "Chat Unavailable - ChatBloc is not provided in the widget tree. Please ensure BlocProvider<ChatBloc> wraps MaterialApp in main.dart." Display in Center widget with Icon(Icons.error_outline, size: 64, color: Colors.red) and Text widget with error message.
- [ ] T059 Run flutter format on all modified files: lib/screens/shared/chat_screen.dart, lib/routes/app_router.dart, lib/screens/it_admin/it_admin_dashboard.dart
- [ ] T060 Check for unused imports in modified files with flutter analyze

### Unused TA Courses Feature Cleanup (User Requested)

**Constitution Principle VII Mock Removal Audit Checklist**:
- [ ] Grep for `_generateSample` patterns (e.g., `_generateSampleCourses()`)
- [ ] Grep for `Future.delayed` simulated responses
- [ ] Grep for `setState(() =>` patterns that bypass BLoC
- [ ] Grep for hardcoded course lists with `DateTime.now().subtract()`
- [ ] Verify no files reference mock course data structures

- [ ] T061 Search for unused TA courses widgets from pre-backend integration: Run `grep -r "ta.*course" lib/widgets/` and identify files NOT referenced in courses_backend_integration_plan.md. Cross-reference with constitution checklist above.
- [ ] T062 Search for unused TA courses screens from pre-backend integration: Run `find lib/screens/ta/ -name "*course*"` (Windows: `Get-ChildItem -Path lib\screens\ta\ -Recurse -Filter *course*`) and identify files NOT referenced in courses_backend_integration_plan.md
- [ ] T063 Delete identified unused TA courses files that match mock removal patterns AND are not referenced in Flutter_Courses_API_Docs.md
- [ ] T064 Verify no broken references after TA courses cleanup: Run `flutter analyze` and `flutter build apk --debug`
- [ ] T065 Update git commit message to document TA courses legacy file removal with list of deleted files and confirmation all files matched mock removal audit checklist

### Performance Validation

- [ ] T065a Measure baseline build time before SharedChatScreen implementation: Run `flutter build apk --debug` and record build duration as baseline
- [ ] T066 Profile SharedChatScreen render time with Flutter DevTools: verify initial load < 2 seconds on typical network (50ms latency). If load exceeds 2 seconds, verify timeout error state displays gracefully.
- [ ] T067 Profile layout transition performance: verify frame time < 16ms (60 FPS) when crossing 600px breakpoint
- [ ] T068 Memory profiling: verify no memory leaks when switching between roles or toggling layouts

### Final Integration Test

- [ ] T069 Full integration test: Login as Student, send message to Instructor, verify Instructor receives it in real-time
- [ ] T070 Full integration test: Login as IT Admin, start new conversation with Admin, verify chat functionality works end-to-end
- [ ] T071 Final QA: All 5 roles tested on Android, iOS, and Web platforms
- [ ] T072 Create or update feature documentation in specs/011-chat-role-integration/README.md with deployment notes, rollback procedure, and testing checklist

### Verification Checklist

- ✅ All code is well-documented
- ✅ Error handling for missing ChatBloc implemented
- ✅ Code formatting consistent across all files
- ✅ No unused imports or dead code
- ✅ TA courses legacy files identified and removed
- ✅ Performance targets met (<2s load, <16ms frame time)
- ✅ No memory leaks detected
- ✅ Full integration tests pass for all role combinations

**Parallel Opportunities**: T057-T060 (documentation & formatting), T061-T063 (TA cleanup), T066-T068 (profiling) can all run in parallel

---

## Dependencies Graph

```text
[Phase 1: Setup] 
    ↓
[US1: Unified Chat (P1)] ← Foundational, blocks everything
    ↓                      
    ├─→ [US2: IT Admin Chat (P1)] ← Depends on US1
    ├─→ [US3: Responsive Layout (P2)] ← Depends on US1
    ├─→ [US4: Role Styling (P2)] ← Depends on US1
    └─→ [US5: Legacy Deprecation (P3)] ← Depends on US1-US4 completion
         ↓
    [Phase 7: Polish & Cleanup] ← Runs after all user stories complete
```

**Critical Path**: Setup → US1 → US2 → US5 → Polish (longest dependency chain)

**Parallel Execution Strategy**:
- US3 and US4 can run in parallel (both depend only on US1)
- US2 can start as soon as US1 SharedChatScreen is created
- Within US5, smoke tests can run fully in parallel
- Within Polish phase, most tasks can run in parallel

---

## Implementation Strategy

### MVP Scope (Minimum Viable Product)

For rapid validation, implement **only User Story 1 (P1)** first:
- Tasks T001-T019: Creates SharedChatScreen, wires to 4 existing roles
- Delivers core value: Single unified chat screen works for Student, Instructor, TA, Admin
- Independently testable: Can deploy and validate before adding IT Admin or cleanup

### Incremental Delivery Order

1. **Sprint 1**: US1 (Unified Chat) → Deploy to staging, validate with users
2. **Sprint 2**: US2 (IT Admin) + US3 (Responsive) → Feature-complete for all roles
3. **Sprint 3**: US4 (Styling) + US5 (Cleanup) → Production-ready
4. **Sprint 4**: Polish & TA cleanup → Codebase fully optimized

### Rollback Strategy

If issues discovered after deployment:
1. SharedChatScreen routes can be reverted to legacy screens individually per role
2. Legacy files NOT deleted until US5 smoke tests pass
3. Git commit separation: US1-US4 in one commit, US5 deletion in separate commit for easy revert

---

## Testing Matrix

| Role | Accent Color | Route | Dark Mode | Mobile | Tablet | Desktop |
|------|-------------|-------|-----------|--------|--------|---------|
| Student | #3B82F6 | /studentdashboard/chat | ✅ | ✅ | ✅ | ✅ |
| Instructor | #4F46E5 | /instructordashboard/chat | ✅ | ✅ | ✅ | ✅ |
| TA | #4F46E5 | /tadashboard/messages | ✅ | ✅ | ✅ | ✅ |
| Admin | #4F46E5 | /admindashboard/messages | ✅ | ✅ | ✅ | ✅ |
| IT Admin | #3B82F6 | /itadmindashboard/chat | ✅ | ✅ | ✅ | ✅ |

**Total Test Combinations**: 5 roles × 2 themes × 3 platforms = 30 test scenarios

---

## Success Metrics

- ✅ Single SharedChatScreen file replaces 4 separate implementations
- ✅ All 5 roles can access chat within 3 taps from dashboard
- ✅ Chat interface loads in < 2 seconds for all roles
- ✅ Layout transitions smoothly at 600px breakpoint (< 16ms frame time)
- ✅ ~25+ legacy files successfully deleted with zero broken imports
- ✅ Build time unchanged or faster after cleanup
- ✅ No user-reported regressions in chat functionality post-migration
- ✅ IT Admin chat capability added (new feature)
- ✅ All TA courses legacy files identified and removed

---

## Notes for Implementation

1. **ChatBloc Verification**: Before starting, confirm ChatBloc is provided in `main.dart` above `MaterialApp`. If not, add it in T001.

2. **Phase 3-5 Component API**: Verify that `ConversationListWidget`, `MessageDetailWidget`, and `NewConversationDialog` accept the props defined in quickstart.md (accentColor, isDark, etc.). If not, update them first.

3. **600px Breakpoint**: This is a hardcoded value. Use `LayoutBuilder` with `constraints.maxWidth >= 600` for detection. Do NOT make it configurable or dynamic.

4. **Responsive Transition**: Use `AnimatedSwitcher` or `AnimatedCrossFade` to smooth the transition between mobile and tablet/desktop layouts.

5. **Error Handling**: If `ChatBloc` is not found, show a helpful error screen (e.g., "Chat requires ChatBloc to be provided. Please check app initialization.") instead of crashing.

6. **Dark Mode Detection**: Use `Theme.of(context).brightness == Brightness.dark` to detect dark mode. Pass the `isDark` boolean to all child widgets.

7. **User Name Fallback**: Always provide a fallback display name per role if `user?.fullName` is null or empty.

8. **Legacy Deletion Timing**: DO NOT delete any legacy files until ALL smoke tests (T039-T043) pass. This is a safety gate.

9. **TA Courses Cleanup**: The user specifically requested checking for unused TA courses files from before backend integration. Search patterns to use:
   - `grep -r "ta.*course" lib/widgets/`
   - `find lib/screens/ta/ -name "*course*"`
   - Look for files that don't integrate with CourseService or backend APIs

10. **Git Commit Strategy**: 
    - Commit 1: T001-T019 (US1 - Unified Screen)
    - Commit 2: T020-T023 (US2 - IT Admin)
    - Commit 3: T024-T031 (US3 - Responsive)
    - Commit 4: T032-T038 (US4 - Styling)
    - Commit 5: T039-T056 (US5 - Legacy Deletion) ← Separate for easy revert
    - Commit 6: T057-T072 (Polish & Cleanup)

---

**Next Command**: `/speckit.implement` (to execute the tasks with LLM assistance)
