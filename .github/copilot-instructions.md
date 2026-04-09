# edu_verse Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-09

## Active Technologies
- Dart Flutter + socket_io_client, dio (006-chat-core-infra)
- Memory (006-chat-core-infra)
- Dart 3+, Flutter + flutter_bloc, equatable, socket_io_client, dio (007-chat-shared-models)
- N/A for this phase (SharedPrefs caching evaluated separately later) (007-chat-shared-models)
- Dart 3+ + Flutter, flutter_bloc, equatable (008-chat-ui-list)
- Dart 3+ / Flutter 3.24+ + flutter_bloc, equatable, socket_io_client (already in pubspec.yaml) (009-chat-message-detail-ui)
- N/A (all state managed via ChatBloc + backend API) (009-chat-message-detail-ui)
- [if applicable, e.g., PostgreSQL, CoreData, files or N/A] (010-new-conversation-flow)
- Dart 3+ / Flutter 3.24+ + flutter_bloc, equatable, go_router (already in pubspec.yaml) (011-chat-role-integration)
- N/A (state managed via ChatBloc + backend API) (011-chat-role-integration)
- Dart 3+ / Flutter 3.24+ + flutter_bloc, equatable, socket_io_client, dio, go_router (012-chat-pro-ux)
- N/A (In-Memory BLoC `ChatState` with shared preferences minimal caching previously implemented) (012-chat-pro-ux)

- [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION] (006-chat-core-infra)

## Project Structure

```text
backend/
frontend/
tests/
```

## Commands

cd src; pytest; ruff check .

## Code Style

[e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]: Follow standard conventions

## Recent Changes
- 012-chat-pro-ux: Added Dart 3+ / Flutter 3.24+ + flutter_bloc, equatable, socket_io_client, dio, go_router
- 011-chat-role-integration: Added Dart 3+ / Flutter 3.24+ + flutter_bloc, equatable, go_router (already in pubspec.yaml)
- 010-new-conversation-flow: Added [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
