# Quickstart

- Replace any legacy `ChatCubit` imports with `ChatBloc`.
- For screens that rely on legacy chat UI models, you will temporarily see errors. Wrap those screens in conditional UI hiding logic or comment out the raw lists until Phase 3 and Phase 4 UI components are constructed.
- Use `AppRouter`'s top-level provider for `ChatBloc` in `main.dart` instead of `ChatCubit`.
- Start tests with `flutter test` for simple model parsing validation before launching WebSocket logic.
