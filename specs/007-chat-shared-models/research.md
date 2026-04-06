# Research & Decisions

## 1. Handling WebSocket Typing Indicators (Debouncing)
- **Decision**: Debounce typing `false` signals locally using a Timer (1.5s) if the backend doesn't automatically send `isTyping: false`.
- **Rationale**: Prevents rapid BLoC state mutations and keeps Flutter parity with the web's 1.5s rule.
- **Alternatives**: Let the UI stream rapidly update state (causes expensive widget rebuilds).

## 2. Pagination for Chat Messages (`LoadMoreMessages`)
- **Decision**: Introduce a explicit `LoadMoreMessages` BLoC event tracking a pagination cursor/offset per conversation via `ChatService.getConversationMessages(id, {page: x})`.
- **Rationale**: Replaces loading everything into memory at once, avoiding Out-Of-Memory exceptions on long running chats.
- **Alternatives**: Defer pagination to Phase 8, but doing it in Phase 2 saves massive BLoC refactoring later.

## 3. Discarding Role-Specific Models
- **Decision**: Eradicate all instances of `InstructorChatModels` and legacy `ChatCubit` structures instantly.
- **Rationale**: As mandated by the plan, enforcing single representation eliminates parsing bugs and UI mismatches forever.
- **Alternatives**: Maintain legacy converters (discouraged by Constitution Principle VII regarding static mock/simulated formats).
