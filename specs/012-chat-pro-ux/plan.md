
# Implementation Plan: Pro Chat UX Enhancements

**Branch**: `012-chat-pro-ux` | **Date**: April 9, 2026 | **Spec**: [spec.md](../spec.md)
**Input**: Feature specification from `/specs/012-chat-pro-ux/spec.md`

## Summary

Implement Phase 7: Pro Chat UX Enhancements by refactoring the "New Conversation" flow to a full-screen, dynamically-searched contact picker with an initial "Frequently Contacted" list. Introduce a reactive User Profile slide-in pane populated with derived common groups, offline `lastSeen` tracking, and real-time online presence indicators explicitly requested via `get_online_users`. Additionally, resolve the "Reply to Unknown" label by securely hydrating a participant cache to reflect actual sender names in previews and chat history, supporting deep-linked scrolling to original replied messages.

## Technical Context

**Language/Version**: Dart 3+ / Flutter 3.24+
**Primary Dependencies**: flutter_bloc, equatable, socket_io_client, dio, go_router
**Storage**: N/A (In-Memory BLoC `ChatState` with shared preferences minimal caching previously implemented)
**Testing**: flutter test (Unit + Integration)
**Target Platform**: Android / iOS / Web
**Project Type**: mobile-app
**Performance Goals**: Debounced search under 300ms, sub-1-second UI presence updates
**Constraints**: 
- `user_status` and `online_users_list` data MUST exactly reflect network connection states.
- Missing reply context must fall back graciously to "Unknown User" rather than failing API calls.
**Scale/Scope**: 3 new full-screen widgets, 4 modified chat core services/blocs. Global user search and pagination executed remotely via `GET /api/messages/users/search` with `limit=20` and debounced requests.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls?
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly?
- [x] Is **III. Type Safety & Error Handling** fully accounted for — including optimistic updates and WebSocket reconnect fallback?
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1?
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable?
- [x] Does the plan enforce **VI. Real-Time Communication Integrity** — WebSocket lifecycle, auto-reconnect, event idempotency?
- [x] Is **VII. Static Data Elimination** accounted for — mock removal audit included in verification?
- [x] Was **VIII. Aggressive Clarification** performed — minimum 5 clarification questions on field parity, roles, edge cases, deletions, and event coverage?

## Project Structure

### Documentation (this feature)

```text
specs/012-chat-pro-ux/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── bloc/
│   ├── chat/
│   │   ├── chat_bloc.dart
│   │   ├── chat_event.dart
│   │   └── chat_state.dart
├── models/
│   └── chat/
│       ├── chat_models.dart
│       └── user_profile_context.dart
├── screens/
│   └── shared/
│       ├── chat/
│       │   ├── new_conversation_screen.dart
│       │   └── user_profile_screen.dart
├── services/
│   └── chat/
│       └── chat_socket_service.dart
└── widgets/
    └── shared/
        └── chat/
            ├── contact_list_item.dart
            ├── frequently_contacted_section.dart
            ├── profile_header.dart
            ├── profile_info_section.dart
            ├── shared_chat_detail_view.dart
            ├── shared_chat_header.dart
            ├── shared_conversation_tile.dart
            └── shared_message_bubble.dart
```

**Structure Decision**: The Flutter application follows a standard modular path structure. I opted to align these UX enhancements directly inside `lib/widgets/shared/chat` and `lib/bloc/chat` since they strictly affect all five roles consistently. `SharedNewChatDialog` will be completely deleted and replaced with `new_conversation_screen.dart`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

