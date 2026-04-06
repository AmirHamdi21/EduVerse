# Implementation Plan: Phase 1: Core Chat Infrastructure

**Branch**: `006-chat-core-infra` | **Date**: April 6, 2026 | **Spec**: specs/006-chat-core-infra/spec.md
**Input**: Feature specification from `/specs/006-chat-core-infra/spec.md`

## Summary

Build the foundational core chat infrastructure for the Flutter app. This entails adding WebSocket and REST API service layers fully aligned with the backend API and frontend website. This phase involves no UI changes.

## Technical Context

**Language/Version**: Dart Flutter
**Primary Dependencies**: socket_io_client, dio
**Storage**: Memory
**Testing**: flutter test
**Target Platform**: Android iOS Web
**Project Type**: mobile-app
**Performance Goals**: Auto-reconnect within 1.2s, connect within 2s
**Constraints**: Handle HTTP 429 backoff, background reconnect, sync across devices
**Scale/Scope**: Phase 1 sets up infrastructure for all users and roles

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
specs/006-chat-core-infra/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # To be created by /speckit.tasks
```

### Source Code (repository root)

```text
edu_verse/
├── pubspec.yaml
├── lib/
│   └── services/
│       ├── api/
│       │   └── chat_service.dart
│       └── chat/
│           └── chat_socket_service.dart
└── test/
    └── services/
        ├── api/
        │   └── chat_service_test.dart
        └── chat/
            └── chat_socket_service_test.dart
```
