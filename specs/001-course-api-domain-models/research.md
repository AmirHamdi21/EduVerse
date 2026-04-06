# Research: Phase 1

### Decision 1: Caching Mechanism (Offline Resilience)
**Decision**: Use `shared_preferences` for caching JSON strings of recently fetched lists.
**Rationale**: It is already installed efficiently in our `pubspec.yaml`. Writing lightweight JSON to SharedPreferences ensures safe, instant offline loading for `Courses` lists without needing the overhead of initializing a major SQL database (like Hive/Isar) strictly for this data layer.
**Alternatives considered**: Hive (rejected due to missing setup overhead in current stack), SQLite (too complex for simple array caching).

### Decision 2: API Networking Client
**Decision**: Use `dio` with custom interceptors.
**Rationale**: `dio` provides native interceptor support which cleanly resolves our "Token Expiration 401 Contextual Retry" requirement. We can silently refresh the token inside the interceptor, retry the request transparently, and only fail natively if the refresh also fails.
**Alternatives considered**: base `http` package (rejected because handling refresh tokens/retries globally is complex without middleware).
