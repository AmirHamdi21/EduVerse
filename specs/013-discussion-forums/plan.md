# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Integrate the Discussion Forums backend API (`/api/discussions`) into the EduVerse Flutter mobile app with a unified UI/UX. Replace any existing mock data or role-specific forum screens with a single shared widget tree (`lib/widgets/shared/discussions/`) and BLoC (`DiscussionBloc`), following the exact same strategy used for real-time messaging. The feature provides course-centric Q&A threads with role-based moderation (pin, lock, endorse, mark answer) and strict adherence to the website's feature parity rules.

## Technical Context

**Language/Version**: Dart 3+ / Flutter 3.24+  
**Primary Dependencies**: flutter_bloc, equatable, dio, go_router  
**Storage**: N/A (No offline caching, network required)  
**Testing**: flutter_test, bloc_test (unit and integration tests for BLoC and Services)  
**Target Platform**: iOS, Android, Web (Flutter multi-platform)  
**Project Type**: Mobile App Frontend Integration  
**Performance Goals**: Paginated loading retrieves subsequent pages in < 1 second.  
**Constraints**: Pure REST fallback fallback only (no WebSockets for discussions), client-side deduplication for pagination offset shifts.  
**Scale/Scope**: 5 user roles sharing a single widget tree and BLoC, integrating ~10 REST endpoints.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls?
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly?
- [x] Is **III. Type Safety & Error Handling** fully accounted for — including optimistic updates and WebSocket reconnect fallback?
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1?
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable?
- [x] Does the plan enforce **VI. Real-Time Communication Integrity** — WebSocket lifecycle, auto-reconnect, event idempotency? *(N/A for Discussions as it uses REST, but checked for Chat parity context)*
- [x] Is **VII. Static Data Elimination** accounted for — mock removal audit included in verification?
- [x] Was **VIII. Aggressive Clarification** performed — minimum 5 clarification questions on field parity, roles, edge cases, deletions, and event coverage?

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
