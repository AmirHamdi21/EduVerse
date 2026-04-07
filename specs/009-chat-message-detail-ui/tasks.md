# Tasks: Unified Chat UI — Message Detail View

**Input**: Design documents from `/specs/009-chat-message-detail-ui/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅  
**Branch**: `009-chat-message-detail-ui`

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## User Stories Summary (from spec.md)

| Story | Title | Priority | Independent Test |
|-------|-------|----------|------------------|
| US1 | View and Send Messages | P1 | Select conversation, view messages, send message |
| US2 | Reply to Specific Messages | P2 | Long-press message, select Reply, send response |
| US3 | Delete Messages | P2 | Long-press message, select delete option |
| US4 | See Typing Indicators | P3 | One user types, other sees indicator |
| US5 | View Connection and Online Status | P3 | Verify Live/Offline badge reflects status |
| US6 | Use Emoji in Messages | P3 | Tap emoji button, select emoji, verify insertion |
| US7 | View Message Sender in Group Chats | P3 | View group conversation, verify sender info |

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ensure branch is ready and existing infrastructure is verified

- [ ] T001 Switch to feature branch `009-chat-message-detail-ui` and run `flutter pub get`
- [ ] T002 Verify existing chat BLoC tests pass by running `flutter test test/bloc/chat/`
- [ ] T003 Create test directory structure at `test/widgets/shared/chat/` if not exists

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: BLoC state modifications required by ALL user stories

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### State Modifications

- [ ] T004 Add `replyToMessage` field of type `ChatMessageModel?` to `ChatState` class in `lib/bloc/chat/chat_state.dart`. Add to constructor, copyWith method (with `clearReplyToMessage` flag), and props list
- [ ] T005 Add `SetReplyContext` event class to `lib/bloc/chat/chat_event.dart` with `final ChatMessageModel? message` field and props override
- [ ] T006 Add `SetReplyContext` handler in `lib/bloc/chat/chat_bloc.dart` that emits state with `replyToMessage` set (or cleared if message is null)

### Verification

- [ ] T007 Run `flutter analyze lib/bloc/chat/` to verify no errors in BLoC modifications
- [ ] T008 Run `flutter test test/bloc/chat/` to verify existing tests still pass after modifications

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View and Send Messages (Priority: P1) 🎯 MVP

**Goal**: Users can view full message history and send new messages with optimistic updates

**Independent Test**: Select a conversation, verify messages load, type and send a message, verify it appears immediately with pending status then sent status

### Widget Tests for User Story 1

- [ ] T009 [P] [US1] Create widget test file at `test/widgets/shared/chat/shared_typing_indicator_test.dart` with tests for: rendering with 0/1/2/3+ typing users, animation presence, text formatting
- [ ] T010 [P] [US1] Create widget test file at `test/widgets/shared/chat/shared_chat_detail_view_test.dart` with tests for: basic rendering, message list display, input bar presence, send button triggers SendMessage event

### Implementation for User Story 1

- [ ] T011 [P] [US1] Create `SharedTypingIndicator` widget in `lib/widgets/shared/chat/shared_typing_indicator.dart` with animated three-dot bounce animation (1.2s cycle), accepts `typingUserNames`, `accentColor`, `isDark` per contracts/widget-interfaces.md
- [ ] T012 [US1] Create `_ConversationHeader` private widget inside `lib/widgets/shared/chat/shared_chat_detail_view.dart` showing participant avatar, name, connection status badge (Live/Offline), typing indicator (using SharedTypingIndicator), and placeholder call buttons
- [ ] T013 [US1] Create `_MessageList` private widget inside `lib/widgets/shared/chat/shared_chat_detail_view.dart` with `ListView.builder`, reversed order, auto-scroll to bottom on new messages, scroll-to-top pagination trigger calling `LoadMoreMessages` event with limit 30. Handle empty message list with friendly prompt to start conversation.
- [ ] T014 [US1] Create `_InputBar` private widget inside `lib/widgets/shared/chat/shared_chat_detail_view.dart` with TextEditingController, attachment button (placeholder), voice message toggle (placeholder), emoji toggle button, send button that dispatches `SendMessage` event with optimistic update
- [ ] T015 [US1] Create `SharedChatDetailView` widget in `lib/widgets/shared/chat/shared_chat_detail_view.dart` composing _ConversationHeader, _MessageList, and _InputBar, using BlocConsumer to read `activeConversationMessages`, `connectionStatus`, `typingUsers`, `onlineUsers` from ChatState
- [ ] T016 [US1] Implement optimistic message sending in SharedChatDetailView: generate negative temp ID, add message with status='pending', update to 'sent' on WebSocket confirmation, handle 3-retry exponential backoff (1s, 2s, 4s) on failure
- [ ] T016a [US1] Implement REST fallback in _InputBar: when `state.connectionStatus != ConnectionStatus.connected`, send message via `ChatService.sendMessage()` REST endpoint instead of WebSocket
- [ ] T016b [P] [US1] Add unit test for retry/deduplication logic in `test/bloc/chat/chat_bloc_retry_test.dart`: test 3-retry exponential backoff, test optimistic message replaced by server-confirmed message
- [ ] T017 [US1] Add typing event dispatch: call `bloc.add(TypingChanged(isTyping: true))` on text input focus/change, debounce 1.5s before `TypingChanged(isTyping: false)`

**Checkpoint**: User Story 1 complete - can view conversations and send messages with real-time updates

---

## Phase 4: User Story 7 - View Message Sender in Group Chats (Priority: P3)

**Goal**: Show sender name and avatar for group messages, hide for direct messages

**Independent Test**: View a group conversation, verify each message shows sender name/avatar. View direct conversation, verify no sender names shown.

**⚠️ Out-of-Priority-Order Note**: US7 is P3 priority but implemented before P2 stories (US2, US3) because SharedMessageBubble is a dependency for all message display. US1's _MessageList requires SharedMessageBubble to render messages.

### Widget Tests for User Story 7

- [ ] T018 [P] [US7] Create widget test file at `test/widgets/shared/chat/shared_message_bubble_test.dart` with tests for: isMe=true (right aligned, accent bg), isMe=false (left aligned, neutral bg), isGroup=true shows sender info, isGroup=false hides sender info, showSenderInfo=false for consecutive messages

### Implementation for User Story 7

- [ ] T019 [US7] Create `SharedMessageBubble` widget in `lib/widgets/shared/chat/shared_message_bubble.dart` per contracts/widget-interfaces.md. Handle: isMe alignment, isGroup sender display, showSenderInfo for consecutive messages, text content, timestamp, status icon (clock for pending, checkmark for sent, red X for failed)
- [ ] T020 [US7] Implement visual states in SharedMessageBubble: `isDeleted: true` shows "This message was deleted" in italic, `status: 'pending'` shows dimmed with clock icon, `status: 'failed'` shows red tint with retry button

**Checkpoint**: User Story 7 complete - group messages show sender info, direct messages don't

---

## Phase 5: User Story 2 - Reply to Specific Messages (Priority: P2)

**Goal**: Users can reply to specific messages with visual context

**Independent Test**: Long-press a message, tap Reply, verify reply preview bar appears, send message, verify it shows reply context

### Implementation for User Story 2

- [ ] T021 [US2] Add `replyToMessage` prop handling in SharedMessageBubble: if message has `replyToId`, show quoted reply context box above bubble content with sender name and truncated text
- [ ] T022 [US2] Implement `onTapReplyContext` callback in SharedMessageBubble that scrolls to the original message when reply context is tapped
- [ ] T023 [US2] Create `_ReplyPreviewBar` private widget in `lib/widgets/shared/chat/shared_chat_detail_view.dart` showing quoted message snippet with dismiss (X) button, visible when `state.replyToMessage != null`
- [ ] T024 [US2] Add reply context to _InputBar: when state.replyToMessage is set, show _ReplyPreviewBar above input. On send, include `replyToId: state.replyToMessage?.id` in SendMessage event. After send, dispatch `SetReplyContext(message: null)` to clear
- [ ] T025 [US2] Handle "Original message was deleted" case in reply context display: if replyToMessage.isDeleted, show placeholder text instead of content

**Checkpoint**: User Story 2 complete - can reply to messages with visible context

---

## Phase 6: User Story 3 - Delete Messages (Priority: P2)

**Goal**: Users can delete messages for self or everyone (within 24h)

**Independent Test**: Long-press own message within 24h, verify "Delete for everyone" option exists. Long-press message older than 24h, verify option is hidden/disabled.

### Implementation for User Story 3

- [ ] T026 [US3] Implement long-press menu in SharedMessageBubble using `showModalBottomSheet` or `showMenu` with actions: Reply (always), Delete for me (always), Delete for everyone (conditional)
- [ ] T027 [US3] Implement `canDeleteForEveryone` calculation: `message.senderId == currentUserId && DateTime.now().difference(message.sentAt) < Duration(hours: 24) && message.status != 'pending' && !message.isDeleted`
- [ ] T028 [US3] Wire up onReply callback to dispatch `SetReplyContext(message: message)` from SharedChatDetailView
- [ ] T029 [US3] Wire up onDeleteForMe callback: update local ChatState to add message ID to `hiddenMessageIds` set (local-only hide, no backend call). Note: This uses existing `HideMessageLocally` event or filter in BloC state—no new event type needed.
- [ ] T030 [US3] Wire up onDeleteForEveryone callback to dispatch `DeleteMessage` event which calls backend and updates via WebSocket
- [ ] T031 [US3] Add retry button for failed messages in SharedMessageBubble: show red retry icon, onTap dispatches `RetryFailedMessage` event (handler already exists in ChatBloc, only wire up callback)

**Checkpoint**: User Story 3 complete - can delete messages with appropriate restrictions

---

## Phase 7: User Story 4 - See Typing Indicators (Priority: P3)

**Goal**: See animated indicator when others are typing

**Independent Test**: Have another user type in conversation, verify indicator appears within 500ms and disappears when they stop/send

**Note**: SharedTypingIndicator widget was created in US1. This phase ensures integration is complete.

### Implementation for User Story 4

- [ ] T032 [US4] Integrate SharedTypingIndicator in _ConversationHeader: read `state.typingUsers[conversation.conversationId]`, map user IDs to names using `conversation.participantUsers`, pass to SharedTypingIndicator
- [ ] T033 [US4] Ensure typing indicator hides when typingUsers list is empty or contains only current user
- [ ] T034 [US4] Verify typing indicator animation: three dots with staggered bounce, 1.2s cycle duration, dots use accentColor with varying opacity

**Checkpoint**: User Story 4 complete - typing indicators work correctly

---

## Phase 8: User Story 5 - View Connection and Online Status (Priority: P3)

**Goal**: See real-time connection status and participant online status

**Independent Test**: Disconnect network, verify "Offline" badge appears. Reconnect, verify "Live" badge appears.

### Implementation for User Story 5

- [ ] T035 [US5] Implement connection status badge in _ConversationHeader: green "Live" badge when `state.connectionStatus == ConnectionStatus.connected`, red "Offline" badge when disconnected, yellow "Connecting..." when reconnecting
- [ ] T036 [US5] Implement online indicator for direct conversations: show green dot next to avatar in _ConversationHeader when `state.onlineUsers.contains(conversation.directDisplayUser?.userId)`
- [ ] T037 [US5] Add visual feedback during reconnection attempts: show subtle loading indicator or pulsing badge

**Checkpoint**: User Story 5 complete - connection and online status displayed correctly

---

## Phase 9: User Story 6 - Use Emoji in Messages (Priority: P3)

**Goal**: Quick emoji picker for adding emoji to messages

**Independent Test**: Tap emoji button, verify row appears with 8 emojis, tap emoji, verify it inserts into text input

### Widget Tests for User Story 6

- [ ] T038 [P] [US6] Create widget test file at `test/widgets/shared/chat/shared_emoji_row_test.dart` with tests for: renders 8 emojis, tap calls onEmojiSelected with correct emoji, theming applies correctly

### Implementation for User Story 6

- [ ] T039 [US6] Create `SharedEmojiRow` widget in `lib/widgets/shared/chat/shared_emoji_row.dart` with horizontal scrollable row of 8 emojis: 😀 😂 ❤️ 👍 👎 😢 😮 🔥. Accept `onEmojiSelected`, `accentColor`, `isDark` per contracts/widget-interfaces.md
- [ ] T040 [US6] Integrate SharedEmojiRow in SharedChatDetailView: toggle visibility on emoji button tap using local state, animate in/out with `AnimatedCrossFade` or `AnimatedContainer`
- [ ] T041 [US6] Wire onEmojiSelected to insert emoji at cursor position in TextEditingController, dismiss emoji row after selection

**Checkpoint**: User Story 6 complete - emoji picker works correctly

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, cleanup, and documentation

### Verification

- [ ] T042 Run `flutter analyze lib/widgets/shared/chat/` to verify no lint errors
- [ ] T043 Run `flutter test test/widgets/shared/chat/` to verify all widget tests pass
- [ ] T044 Run `flutter test test/bloc/chat/` to verify BLoC tests still pass
- [ ] T045 Run manual verification per quickstart.md: send message (optimistic update), reply, delete, typing indicator, pagination, connection status

### Cleanup - Unused Files Audit

- [ ] T046 Search for unused mock/static chat data files using `grep -r "mockMessages\|staticMessages\|dummyChat\|fakemessage" lib/` and remove any found
- [ ] T047 Search for old TA courses feature files that may conflict using `grep -r "ta_courses\|taCourses\|TACoursesScreen" lib/` and remove unused ones not related to backend integration
- [ ] T048 Remove any unused imports from newly created widget files by running `dart fix --apply lib/widgets/shared/chat/`
- [ ] T049 Verify no residual mock data in chat widgets using `grep -r "TODO\|FIXME\|mock\|stub\|fake" lib/widgets/shared/chat/`

### Documentation

- [ ] T050 Update `lib/widgets/shared/chat/` barrel file (if exists) to export new widgets: SharedChatDetailView, SharedMessageBubble, SharedEmojiRow, SharedTypingIndicator
- [ ] T051 Add inline documentation comments to all public widget constructors describing required vs optional params

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)
         │
         ▼
Phase 2 (Foundational) ─────────────────────────────────────────────────────────────►
         │
         ▼
Phase 3 (US1) ──────────────────────────────────────────────────────────────────────►
[View/Send - creates _MessageList, _InputBar, SharedTypingIndicator]
         │
         ▼
Phase 4 (US7) ──────────────────────────────────────────────────────────────────────►
[Group Sender - creates SharedMessageBubble required by _MessageList]
         │
         ├───────────────┬───────────────┬───────────────┬──────────────────────────►
         ▼               ▼               ▼               ▼
    Phase 5 (US2)   Phase 6 (US3)   Phase 7 (US4)   Phase 8-9 (US5-6)
    [Reply]         [Delete]        [Typing]        [Status/Emoji]
         │               │               │               │
         └───────────────┴───────────────┴───────────────┘
                                 │
                                 ▼
                         Phase 10 (Polish)
```

### User Story Dependencies

| Story | Depends On | Can Parallelize With |
|-------|------------|---------------------|
| US1 (View/Send) | Phase 2 (Foundation) | None (implements core widgets) |
| US7 (Group Sender) | US1 (US7 creates SharedMessageBubble used by US1's _MessageList) | None |
| US2 (Reply) | US1, US7 (SharedMessageBubble required) | US3, US4, US5, US6 |
| US3 (Delete) | US1, US7 (SharedMessageBubble required) | US2, US4, US5, US6 |
| US4 (Typing) | US1 (SharedTypingIndicator integration) | US2, US3, US5, US6 |
| US5 (Status) | US1 (_ConversationHeader integration) | US2, US3, US4, US6 |
| US6 (Emoji) | US1 (SharedEmojiRow + _InputBar integration) | US2, US3, US4, US5 |

### Within Each User Story

1. Tests written first (if included)
2. Core widget implementation
3. Integration with existing components
4. Verification

### Parallel Opportunities

**Phase 2** (can run in parallel):
- T004, T005 (state.dart and event.dart are different files)

**Phase 3 Tests** (can run in parallel):
- T009, T010 (different test files)

**Phase 3 Implementation**:
- T011 can run while T012-T014 are in progress (SharedTypingIndicator is independent)

**After US1 Complete** (can run in parallel):
- US2 (T021-T025)
- US3 (T026-T031)
- US4 (T032-T034)
- US5 (T035-T037)
- US6 (T038-T041)

---

## Parallel Example: Foundation Phase

```bash
# These can be launched in parallel (different files):
Task T004: "Add replyToMessage field to ChatState in lib/bloc/chat/chat_state.dart"
Task T005: "Add SetReplyContext event in lib/bloc/chat/chat_event.dart"

# Then T006 depends on both:
Task T006: "Add SetReplyContext handler in lib/bloc/chat/chat_bloc.dart"
```

## Parallel Example: After US1 Complete

```bash
# Once US1 and US7 are complete, these can all run in parallel:
Task T021-T025: US2 Reply implementation
Task T026-T031: US3 Delete implementation
Task T032-T034: US4 Typing indicator integration
Task T035-T037: US5 Status badge implementation
Task T038-T041: US6 Emoji picker implementation
```

---

## Implementation Strategy

### MVP First (User Story 1 + US7 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundation (BLoC modifications)
3. Complete Phase 3: User Story 1 (View/Send)
4. Complete Phase 4: User Story 7 (Group Sender - needed for message bubbles)
5. **STOP and VALIDATE**: Test viewing conversations and sending messages
6. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundation → BLoC ready
2. US1 + US7 → Can view/send messages in any conversation (MVP!)
3. Add US2 (Reply) → Enhanced messaging with context
4. Add US3 (Delete) → Message management
5. Add US4-US6 → Polish features (typing, status, emoji)
6. Polish phase → Cleanup and verification

---

## Task Summary

| Phase | Tasks | Parallelizable | Est. Effort |
|-------|-------|----------------|-------------|
| 1. Setup | T001-T003 | 1 | 10 min |
| 2. Foundation | T004-T008 | 2 | 20 min |
| 3. US1 View/Send | T009-T017, T016a, T016b | 4 | 100 min |
| 4. US7 Group Sender | T018-T020 | 1 | 45 min |
| 5. US2 Reply | T021-T025 | 0 | 45 min |
| 6. US3 Delete | T026-T031 | 0 | 45 min |
| 7. US4 Typing | T032-T034 | 0 | 20 min |
| 8. US5 Status | T035-T037 | 0 | 20 min |
| 9. US6 Emoji | T038-T041 | 1 | 30 min |
| 10. Polish | T042-T051 | 4 | 30 min |
| **Total** | **53 tasks** | **14 parallel** | **~6.5 hours** |

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All file paths are relative to repository root `D:\Graduation\EduVerse\edu_verse\`
- Verify the 24-hour delete window uses `sentAt` timestamp, not client time
- Retry delays are exactly: 1s, 2s, 4s (exponential backoff per research.md)
- Pagination page size is exactly 30 messages per research.md
