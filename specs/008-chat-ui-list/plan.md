# Implementation Plan: Unified Chat UI — Conversation List

**Branch**: `008-chat-ui-list` | **Date**: April 6, 2026 | **Spec**: [specs/008-chat-ui-list/spec.md](spec.md)
**Input**: Feature specification from `/specs/008-chat-ui-list/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Replace all role-fragmented conversation list views in the Flutter app with a single, universal shared conversation list component suite. This suite will include a header with connection status, text search, "All/Unread/Groups" filter chips, conversation tiles with swipe actions (Pin, Mute, Delete), an empty state, and infinite scrolling. These components will exclusively consume the `ChatBloc` state implemented in Phase 2 to ensure strict BLoC state management and 1:1 feature parity with the React website.

## Technical Context

**Language/Version**: Dart 3+
**Primary Dependencies**: Flutter, flutter_bloc, equatable  
**Storage**: N/A for this phase
**Testing**: flutter_test  
**Target Platform**: iOS / Android / Web
**Project Type**: Mobile App
**Performance Goals**: Filter switching and text searching state updates in <200ms
**Constraints**: Must support seamless Dark Mode rendering per user role.
**Scale/Scope**: Replace 4 separate role-specific chat UI implementations with exactly 1 shared implementation.

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
specs/008-chat-ui-list/
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
├── widgets/
│   └── shared/
│       └── chat/
│           ├── shared_chat_header.dart         # [NEW] Header with connection status, search toggle, new chat modal button
│           ├── shared_chat_search_bar.dart     # [NEW] Search input for filtering by name/email/msg
│           ├── shared_chat_filter_chips.dart   # [NEW] Filter chips (All/Unread/Groups)
│           ├── shared_conversation_tile.dart   # [NEW] Single tile with swipe actions (Pin/Mute/Delete Trailing)
│           ├── shared_conversation_list.dart   # [NEW] ListView.builder consuming ChatBloc with Infinite Scroll
│           └── shared_chat_empty_state.dart    # [NEW] Empty state with CTA
├── screens/
│   ├── student/chat/
│   │   └── chat_screen.dart                    # [MODIFY] Replace existing body with shared_conversation_list
│   ├── instructor/chat/
│   │   └── instructor_chat_screen.dart         # [MODIFY] Replace existing body with shared_conversation_list
│   ├── ta/chat/
│   │   └── ta_messages_screen.dart             # [MODIFY] Replace existing body with shared_conversation_list
│   ├── admin/messages/
│   │   └── admin_messages_screen.dart          # [MODIFY] Replace existing body with shared_conversation_list
│   └── it_admin/chat/
│       └── it_admin_chat_screen.dart           # [NEW/MODIFY] Add/update to use shared_conversation_list
└── widgets/
    ├── student/chat/                           # [DELETE] Legacy conversation list widgets
    ├── instructor/chat/                        # [DELETE] Legacy conversation list widgets
    └── admin/messages/                         # [DELETE] Legacy conversation list widgets
```

**Structure Decision**: The plan introduces a new `shared/chat` widget directory to house all universal Conversation List UI components. All role-specific chat screens (`student`, `instructor`, `ta`, `admin`, `it_admin`) will be modified to drop their localized UI implementations and import these shared widgets, delegating their state entirely to the `ChatBloc`. Legacy role-specific chat widgets will be aggressively deleted to adhere to the Constitution's UI/Static data elimination rules.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations. Strict adherence to BLoC and Shared UI.*
