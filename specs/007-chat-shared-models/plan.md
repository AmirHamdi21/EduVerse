# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

This phase replaces 4 disparate, mock-driven role-specific chat models with a single, consolidated data model mirroring the EduVerse JSON Backend API exactly. It transitions state management from a simple `ChatCubit` to an event-driven `ChatBloc` designed to handle concurrent REST fetching, pagination, optimistic UI updates, and real-time WebSocket streams synchronously.

## Technical Context

**Language/Version**: Dart 3+, Flutter  
**Primary Dependencies**: flutter_bloc, equatable, socket_io_client, dio  
**Storage**: N/A for this phase (SharedPrefs caching evaluated separately later)  
**Testing**: flutter_test (Unit Tests for Parsing + Bloc logic)  
**Target Platform**: Android, iOS, Web  
**Project Type**: Mobile Application BLoC logic  
**Performance Goals**: Sub-50ms BLoC map processing on socket event ingress  
**Constraints**: Optimistic message logic must resolve duplicate IDs when socket confirms  
**Scale/Scope**: Models & Blocs layer replacement only, breaking currently disconnected UIs.

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
specs/007-chat-shared-models/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── events-and-state.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
# Single project Structure
src/
└── lib/
    ├── bloc/
    │   └── chat/
    │       ├── chat_bloc.dart
    │       ├── chat_event.dart
    │       ├── chat_state.dart
    │       └── chat_models.dart
    ├── models/
    │   └── chat/                 # [DELETE IF EXISTS]
    ├── widgets/
    │   └── instructor/
    │       └── chat/
    │           └── instructor_chat_models.dart # [DELETE]
    └── main.dart                 # Register ChatBloc Provider

tests/
└── test/
    └── bloc/
        └── chat_bloc_test.dart
```

**Structure Decision**: The Flutter lib structure will consolidate all chat models and blocs inside `lib/bloc/chat/`. Redundant `instructor_chat_models.dart` or legacy models under `lib/models/` will be ruthlessly deleted. Legacy `chat_cubit.dart` is to be entirely wiped out.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
