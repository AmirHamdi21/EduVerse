# Implementation Plan: Role-Specific Screen Integration & Unification

**Branch**: `011-chat-role-integration` | **Date**: 2026-04-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/011-chat-role-integration/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Replace four separate role-specific chat implementations with a single unified chat screen that serves all five user roles (Student, Instructor, TA, Admin, IT Admin) while preserving role-specific styling and functionality. This consolidation eliminates ~25+ widget files, reduces maintenance burden, and ensures consistent chat experience across all roles. The unified screen composes existing Phase 3-5 components (conversation list, message detail, new chat dialog) with responsive layout switching at 600px breakpoint.

## Technical Context

**Language/Version**: Dart 3+ / Flutter 3.24+  
**Primary Dependencies**: flutter_bloc, equatable, go_router (already in pubspec.yaml)  
**Storage**: N/A (state managed via ChatBloc + backend API)  
**Testing**: Flutter test framework, widget tests, integration tests  
**Target Platform**: Android, iOS, Web (mobile-first with tablet/desktop responsive design)  
**Project Type**: Mobile application  
**Performance Goals**: <2s chat screen load time, smooth layout transitions at 600px breakpoint  
**Constraints**: Single ChatBloc instance above MaterialApp, 600px responsive breakpoint, preserve role accent colors  
**Scale/Scope**: 5 role dashboards, 1 shared screen replacing 4 separate implementations, ~25+ legacy files to remove

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls?
  - *Yes. SharedChatScreen consumes ChatBloc state only, no direct service calls*
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly?
  - *Yes. Uses existing unified models from Phase 2 (chat_models.dart)*
- [x] Is **III. Type Safety & Error Handling** fully accounted for — including optimistic updates and WebSocket reconnect fallback?
  - *Yes. Error handling inherited from ChatBloc (Phase 2), graceful degradation for missing ChatBloc*
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1?
  - *Yes. Unified screen mirrors website MessagingChat component structure*
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable?
  - *Yes. SharedChatScreen accepts props for testing, ChatBloc injectable*
- [x] Does the plan enforce **VI. Real-Time Communication Integrity** — WebSocket lifecycle, auto-reconnect, event idempotency?
  - *Yes. All WebSocket logic handled by existing ChatBloc/ChatSocketService*
- [x] Is **VII. Static Data Elimination** accounted for — mock removal audit included in verification?
  - *Yes. Legacy screens with mock data will be deleted entirely*
- [x] Was **VIII. Aggressive Clarification** performed — minimum 5 clarification questions on field parity, roles, edge cases, deletions, and event coverage?
  - *Yes. 3 critical clarifications completed (breakpoint, ChatBloc scope, deletion timing)*

## Project Structure

### Documentation (this feature)

```text
specs/011-chat-role-integration/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification (already created)
├── research.md          # Phase 0 output (to be created)
├── data-model.md        # Phase 1 output (to be created)
├── quickstart.md        # Phase 1 output (to be created)
├── contracts/           # Phase 1 output (N/A for this UI integration)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── screens/
│   ├── shared/
│   │   └── chat_screen.dart                    # [NEW] Unified chat screen for all roles
│   ├── student/
│   │   └── chat/
│   │       └── chat_screen.dart                # [DELETE] Legacy student chat
│   ├── instructor/
│   │   └── chat/
│   │       └── instructor_chat_screen.dart     # [DELETE] Legacy instructor chat
│   ├── ta/
│   │   └── messages/
│   │       └── ta_messages_screen.dart         # [DELETE] Legacy TA messages
│   ├── admin/
│   │   └── messages/
│   │       └── admin_messages_screen.dart      # [DELETE] Legacy admin messages
│   └── it_admin/
│       └── it_admin_dashboard.dart             # [MODIFY] Add chat tab entry
├── widgets/
│   ├── shared/
│   │   └── chat/                               # Existing from Phases 3-5
│   │       ├── conversation_list_widget.dart   # [USE] From Phase 3
│   │       ├── message_detail_widget.dart      # [USE] From Phase 4
│   │       └── new_conversation_dialog.dart    # [USE] From Phase 5
│   ├── student/
│   │   └── chat/                               # [DELETE ALL] 10 legacy widgets
│   ├── instructor/
│   │   └── chat/                               # [DELETE ALL] 10 legacy widgets
│   └── admin/
│       └── messages/                           # [DELETE ALL] 5 legacy widgets
├── bloc/
│   └── chat/
│       └── chat_bloc.dart                      # [USE] Existing from Phase 2
├── main.dart                                    # [MODIFY] Ensure ChatBloc wraps MaterialApp with BlocProvider (not as sibling)
└── routes/
    └── app_router.dart                          # [MODIFY] Update chat routes for all 5 roles to point to SharedChatScreen
```

**Structure Decision**: Standard Flutter mobile app structure with shared screen approach. The unified `SharedChatScreen` will be placed in `lib/screens/shared/` to emphasize its cross-role nature. Legacy role-specific screens and widgets will be deleted after smoke tests confirm the unified screen works correctly.

**Terminology Standard**: Use "tablet/desktop" (two words) consistently across all artifacts, not "tabletDesktop" (one word).

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations. All constitution principles are satisfied.*
