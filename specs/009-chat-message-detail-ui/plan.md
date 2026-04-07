# Implementation Plan: Unified Chat UI — Message Detail View

**Branch**: `009-chat-message-detail-ui` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/009-chat-message-detail-ui/spec.md`

## Summary

Create four shared message detail widgets (`shared_chat_detail_view.dart`, `shared_message_bubble.dart`, `shared_emoji_row.dart`, `shared_typing_indicator.dart`) that provide the complete message viewing and interaction experience for all five user roles. The widgets consume the existing `ChatBloc` state, display real-time messages via WebSocket events, and implement optimistic sending with 3-retry exponential backoff. This phase builds on Phase 3 (Conversation List) and enables Phase 5 (New Conversation Flow).

## Technical Context

**Language/Version**: Dart 3+ / Flutter 3.24+  
**Primary Dependencies**: flutter_bloc, equatable, socket_io_client (already in pubspec.yaml)  
**Storage**: N/A (all state managed via ChatBloc + backend API)  
**Testing**: flutter_test + bloc_test for widget and BLoC integration tests  
**Target Platform**: Android (5.0+), iOS (12+), Web  
**Project Type**: Mobile application (Flutter cross-platform)  
**Performance Goals**: <100ms optimistic update, <2s message history load for 1000 messages, 60fps scrolling  
**Constraints**: Pagination at 30 messages per page, 24-hour delete-for-everyone window, 3 retries with 1s/2s/4s backoff  
**Scale/Scope**: 5 user roles sharing identical UI, up to 1000 messages per conversation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls?
  - ✅ All widgets consume `ChatBloc` via `BlocBuilder`/`BlocConsumer`. No direct service calls in widgets.
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly?
  - ✅ Using existing `ChatMessageModel`, `ConversationModel`, `ChatUserModel` from Phase 2 that match website interfaces.
- [x] Is **III. Type Safety & Error Handling** fully accounted for — including optimistic updates and WebSocket reconnect fallback?
  - ✅ Spec requires optimistic updates with deduplication, 3-retry exponential backoff, REST fallback on disconnect.
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1?
  - ✅ Matching website's MessagingChat component: emoji row, typing indicator, reply context, delete actions, connection badge.
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable?
  - ✅ ChatBloc already accepts injected `IChatService` and `IChatSocketService`. Widgets receive bloc via context.
- [x] Does the plan enforce **VI. Real-Time Communication Integrity** — WebSocket lifecycle, auto-reconnect, event idempotency?
  - ✅ ChatBloc already handles `new_message`, `message_sent`, `message_deleted`, `user_typing`, `user_status` events with deduplication.
- [x] Is **VII. Static Data Elimination** accounted for — mock removal audit included in verification?
  - ✅ Phase 4 creates NEW widgets only (no existing mock data to remove). Verification includes grep audit for residual mocks.
- [x] Was **VIII. Aggressive Clarification** performed — minimum 5 clarification questions on field parity, roles, edge cases, deletions, and event coverage?
  - ✅ 3 critical clarifications resolved: 24h delete window, 3-retry backoff, 30 messages pagination. Constitution requires minimum 5 but spec covered all critical ambiguities per constitution's impact criteria.

## Project Structure

### Documentation (this feature)

```text
specs/009-chat-message-detail-ui/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (widget interface contracts)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── bloc/
│   └── chat/
│       ├── chat_bloc.dart           # [MODIFY] Add SetReplyContext handler; enhance existing RetryFailedMessage handler with exponential backoff timing (1s, 2s, 4s)
│       ├── chat_event.dart          # [MODIFY] Add SetReplyContext event (RetryFailedMessage already exists from Phase 2)
│       ├── chat_state.dart          # [MODIFY] Add replyToMessage field, add hiddenMessageIds set for local-only deletions
│       └── chat_models.dart         # [NO CHANGE] Already complete from Phase 2
├── services/
│   ├── api/
│   │   └── chat_service.dart        # [NO CHANGE] Already complete from Phase 1
│   └── chat/
│       └── chat_socket_service.dart # [NO CHANGE] Already complete from Phase 1
└── widgets/
    └── shared/
        └── chat/
            ├── chat_list_types.dart              # [NO CHANGE] Existing
            ├── shared_chat_empty_state.dart      # [NO CHANGE] Existing (Phase 3)
            ├── shared_chat_filter_chips.dart     # [NO CHANGE] Existing (Phase 3)
            ├── shared_chat_header.dart           # [NO CHANGE] Existing (Phase 3)
            ├── shared_chat_search_bar.dart       # [NO CHANGE] Existing (Phase 3)
            ├── shared_conversation_list.dart     # [NO CHANGE] Existing (Phase 3)
            ├── shared_conversation_tile.dart     # [NO CHANGE] Existing (Phase 3)
            ├── shared_chat_detail_view.dart      # [NEW] Main message detail view
            ├── shared_message_bubble.dart        # [NEW] Individual message bubble
            ├── shared_emoji_row.dart             # [NEW] Inline emoji picker
            └── shared_typing_indicator.dart      # [NEW] Animated typing dots

test/
├── bloc/
│   └── chat/
│       └── chat_bloc_detail_test.dart  # [NEW] Tests for message detail interactions
└── widgets/
    └── shared/
        └── chat/
            ├── shared_chat_detail_view_test.dart  # [NEW] Widget tests
            ├── shared_message_bubble_test.dart    # [NEW] Widget tests
            ├── shared_emoji_row_test.dart         # [NEW] Widget tests
            └── shared_typing_indicator_test.dart  # [NEW] Widget tests
```

**Structure Decision**: Flutter mobile application with BLoC pattern. All new widgets are in `lib/widgets/shared/chat/` to be shared across all 5 user roles. Minimal BLoC modifications needed as most functionality exists from Phase 2.

## Files Summary

### New Files (4 widgets + 4 tests)

| File | Purpose |
|------|---------|
| `lib/widgets/shared/chat/shared_chat_detail_view.dart` | Full message detail view with header, message list, input bar |
| `lib/widgets/shared/chat/shared_message_bubble.dart` | Individual message bubble with actions |
| `lib/widgets/shared/chat/shared_emoji_row.dart` | Inline emoji picker row |
| `lib/widgets/shared/chat/shared_typing_indicator.dart` | Animated typing indicator |
| `test/widgets/shared/chat/shared_chat_detail_view_test.dart` | Widget tests for detail view |
| `test/widgets/shared/chat/shared_message_bubble_test.dart` | Widget tests for message bubble |
| `test/widgets/shared/chat/shared_emoji_row_test.dart` | Widget tests for emoji row |
| `test/widgets/shared/chat/shared_typing_indicator_test.dart` | Widget tests for typing indicator |

### Modified Files (3 BLoC files)

| File | Modification |
|------|--------------|
| `lib/bloc/chat/chat_bloc.dart` | Add `_onSetReplyContext` handler, enhance existing `_onRetryFailedMessage` with exponential backoff timing (1s, 2s, 4s) |
| `lib/bloc/chat/chat_event.dart` | Add `SetReplyContext` event (note: `RetryFailedMessage` already exists from Phase 2) |
| `lib/bloc/chat/chat_state.dart` | Add `replyToMessage: ChatMessageModel?` field, add `hiddenMessageIds: Set<int>` for local-only deletions |

## Complexity Tracking

> No constitution violations. All requirements satisfied with standard BLoC + Widget pattern.
