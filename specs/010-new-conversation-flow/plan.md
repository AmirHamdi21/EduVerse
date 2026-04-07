# Implementation Plan: New Conversation Flow

**Branch**: `010-new-conversation-flow` | **Date**: 2026-04-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/010-new-conversation-flow/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Add a shared dialog widget that enables users to search for people by email/name and start direct or group conversations. The dialog uses ChatBloc with debounced search (400ms via StreamTransformer), Material Chip multi-select UI, and event-driven navigation via BlocListener. The implementation extends existing ChatBloc state management rather than creating a separate Cubit, ensuring single source of truth and maintaining strict 1:1 feature parity with the React web frontend.

## Technical Context

**Language/Version**: Dart 3.9.2+, Flutter 3.24+  
**Primary Dependencies**: flutter_bloc 9.1.1, equatable 2.0.7, dio 5.9.0, socket_io_client 3.0.2  
**Storage**: Backend API (PostgreSQL) via ChatService, no local persistence for this feature  
**Testing**: flutter_test (widget tests), bloc_test (BLoC unit tests), integration_test  
**Target Platform**: Flutter multi-platform (iOS, Android, Web)
**Project Type**: Mobile application (Flutter)  
**Performance Goals**: Search debouncing 400ms, API response <500ms, smooth 60fps UI rendering  
**Constraints**: Must match website behavior 1:1, no offline mode required for this feature, maximum 20 search results  
**Scale/Scope**: Single shared dialog widget, 6 new ChatBloc events, 8 new ChatState fields, ~300-400 lines of widget code

**Existing Infrastructure**:
- `lib/bloc/chat/chat_bloc.dart` - Main ChatBloc managing all chat state
- `lib/services/api/chat_service.dart` - ChatService with searchUsers() and startConversation() methods
- `lib/services/websocket/chat_socket_service.dart` - Real-time message delivery
- `lib/bloc/chat/chat_models.dart` - ChatUserModel, ConversationModel already defined
- `lib/widgets/shared/chat/` - 11 existing shared chat widgets (conversation_list, message_bubble, etc.)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [✓] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls?
  - YES: All API calls routed through ChatBloc events (ChatSearchUsersRequested, ChatStartConversationRequested). Widget only dispatches events and listens to state via BlocBuilder/BlocListener.
  
- [✓] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly?
  - YES: ChatUserModel and ConversationModel already match backend API (see data-model.md lines 37-84, 86-150). No new models needed, only state extensions.
  
- [✓] Is **III. Type Safety & Error Handling** fully accounted for — including optimistic updates and WebSocket reconnect fallback?
  - YES: All state fields strongly typed with nullable error states (userSearchError, createConversationError). Validation rules enforce type constraints. No optimistic updates for this feature (creation is blocking). WebSocket reconnect handled by existing infrastructure.
  
- [✓] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1?
  - YES: Dialog UI directly matches website's MessagingChat new conversation modal (see research.md decision #5). Group minimums (3 participants), optional initial message, search behavior, and error states all match website behavior per CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md.
  
- [✓] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable?
  - YES: ChatBloc receives ChatService via dependency injection (constructor parameter). Widget tests can provide mock ChatBloc. Event handlers are pure functions operating on state. See widget-contract.md testing section.
  
- [✓] Does the plan enforce **VI. Real-Time Communication Integrity** — WebSocket lifecycle, auto-reconnect, event idempotency?
  - YES: New conversations immediately added to local state after API response. WebSocket will deliver subsequent messages via existing ChatMessageReceived event handler. No WebSocket-specific changes needed for this feature.
  
- [✓] Is **VII. Static Data Elimination** accounted for — mock removal audit included in verification?
  - YES: No mock data introduced. All data comes from ChatService.searchUsers() and ChatService.startConversation() API calls. Validation rules prevent empty states.
  
- [✓] Was **VIII. Aggressive Clarification** performed — minimum 5 clarification questions on field parity, roles, edge cases, deletions, and event coverage?
  - YES: 5 clarification questions asked and resolved via /speckit.clarify (see spec.md lines 8-16): self-messaging allowed, group limits (min 3, max unlimited), initial message optional, search ordering (relevance-based), error retry mechanism with data preservation.

## Project Structure

### Documentation (this feature)

```text
specs/010-new-conversation-flow/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification with 21 requirements + 5 clarifications
├── research.md          # Phase 0 output - 5 technical decisions documented
├── data-model.md        # Phase 1 output - State/event extensions defined
├── quickstart.md        # Phase 1 output - Developer implementation guide
├── contracts/           # Phase 1 output
│   └── widget-contract.md  # SharedNewChatDialog contract
├── checklists/
│   └── requirements.md  # Spec validation checklist (all passed)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT YET CREATED)
```

### Source Code (repository root)

```text
lib/
├── bloc/
│   └── chat/
│       ├── chat_bloc.dart        # [MODIFIED] Add 6 new event handlers with debouncing
│       ├── chat_state.dart       # [MODIFIED] Extend with 8 new fields for dialog state
│       ├── chat_event.dart       # [MODIFIED] Add 6 new event classes
│       └── chat_models.dart      # [NO CHANGES] Existing models sufficient
│
├── services/
│   └── api/
│       └── chat_service.dart     # [NO CHANGES] searchUsers() and startConversation() already exist
│
├── widgets/
│   └── shared/
│       └── chat/
│           ├── shared_new_chat_dialog.dart  # [NEW] Main dialog widget (~400 lines)
│           ├── conversation_list.dart       # [NO CHANGES]
│           └── [10 other existing widgets]  # [NO CHANGES]
│
└── screens/
    └── chat/
        └── chat_screen.dart      # [MODIFIED] Add FAB/button to show dialog

test/
├── bloc/
│   └── chat/
│       └── chat_bloc_test.dart   # [MODIFIED] Add tests for 6 new event handlers
│
└── widgets/
    └── shared/
        └── chat/
            └── shared_new_chat_dialog_test.dart  # [NEW] Widget tests for dialog
```

**Structure Decision**: 

This is a **Flutter mobile application** with existing BLoC-based architecture. The feature extends the current chat feature with minimal new files:

1. **Single new widget**: `lib/widgets/shared/chat/shared_new_chat_dialog.dart` - The reusable dialog component
2. **Extend existing BLoC**: Modifications to `chat_bloc.dart`, `chat_state.dart`, `chat_event.dart` to add dialog-specific state and events
3. **Minor integration**: Update chat screen to trigger the dialog (add FAB or header button)

This follows the project's established pattern of shared chat widgets (conversation_list, message_bubble, etc.) and aligns with constitution principle I (BLoC State Management First) by extending the existing ChatBloc rather than creating isolated widget state.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations**: All 8 constitution principles are satisfied. No complexity justification required.

---

## Implementation Phases

### Phase 0: Research ✅ COMPLETE
- **Deliverable**: `research.md` with 5 technical decisions
- **Status**: Completed - all architecture decisions documented

### Phase 1: Design ✅ COMPLETE
- **Deliverables**: 
  - `data-model.md` - State/event definitions
  - `contracts/widget-contract.md` - Dialog widget contract
  - `quickstart.md` - Developer implementation guide
- **Status**: Completed - all design artifacts created

### Phase 2: Task Breakdown ⏳ NEXT
- **Deliverable**: `tasks.md` via `/speckit.tasks` command
- **Status**: Ready to generate - run `/speckit.tasks` to create actionable task list

### Phase 3: Implementation ⏳ PENDING
- **Deliverable**: Working code via `/speckit.implement` command
- **Status**: Pending - awaits task breakdown completion

### Phase 4: Verification ⏳ PENDING
- **Deliverable**: Test results and demo
- **Status**: Pending - awaits implementation completion

---

## Next Steps

1. **Run `/speckit.tasks`** to generate the task breakdown in `tasks.md`
2. Execute tasks via `/speckit.implement` or manually implement following `quickstart.md`
3. Verify against success criteria in `spec.md` (lines 206-213)
4. Test against website behavior documented in `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md`

---

## References

- **Feature Spec**: `specs/010-new-conversation-flow/spec.md`
- **Backend API**: `Flutter_Chat_API_Docs_BACKEND.md` (lines 184-231 for relevant endpoints)
- **Website Parity**: `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md` (MessagingChat component)
- **Constitution**: `.specify/memory/constitution.md` (version 2.0.0)
- **Phase Overview**: `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md` (lines 225-258)
