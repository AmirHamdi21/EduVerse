# Research: Core Chat Infrastructure

**Goal:** Establish WebSocket integration for real-time messaging and REST api setup.

## Technical Decisions

**Decision 1**: WebSocket Package
- **Decision**: socket_io_client version 3.0.2
- **Rationale**: Backend is using socket.io for its WebSocket namespace /messaging. socket_io_client fully supports standard socket.io connections from Flutter, maintaining robust features like auto-reconnect.
- **Alternatives considered**: Standard raw web_socket_channel (would require manually implementing socket.io handshakes).

**Decision 2**: HTTP Client
- **Decision**: dio package integration
- **Rationale**: Existing REST infrastructure in the app already uses dio. Leveraging it ensures authorization interceptors and error handling (e.g. 429 retries) apply universally.
- **Alternatives considered**: Raw http package (would duplicate networking boilerplate).

**Decision 3**: Authentication Handling
- **Decision**: Pass JWT in the WebSocket URL query parameter ?token=<access_token>
- **Rationale**: The backend Flutter_Chat_API_Docs_BACKEND.md explicitly specifies this exact approach for the /messaging namespace.
- **Alternatives considered**: Sending authentication payload inside the initial connect event.

**Decision 4**: Offline Queueing and Retries
- **Decision**: Background retry queue managed by the overarching REST client / local storage
- **Rationale**: User clarification mandates background queueing for both REST APIs suffering from HTTP 429 and offline messages.
