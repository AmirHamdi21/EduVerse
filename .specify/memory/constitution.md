<!--
SYNC IMPACT REPORT
- Version Change: 1.0.1 -> 2.0.0
- Modified Principles:
  - "I. BLoC State Management First" -> "I. BLoC State Management First" (expanded for WebSocket stream subscriptions)
  - "II. Strict Data Layer Separation" -> "II. Strict Data Layer Separation" (expanded for ChatService/ChatSocketService and Discussion models)
  - "III. Type Safety & Error Handling" -> "III. Type Safety & Error Handling" (expanded for WebSocket reconnect and optimistic updates)
  - "IV. UI/UX Consistency" -> "IV. Website Feature Parity" (redefined: strict 1:1 with website frontend)
  - "V. Testable Architecture" -> "V. Testable Architecture" (unchanged)
- Added Sections:
  - Principle "VI. Real-Time Communication Integrity" (WebSocket lifecycle rules)
  - Principle "VII. Static Data Elimination" (mandatory mock removal gate)
  - Principle "VIII. Aggressive Clarification" (speckit.clarify guidance)
  - Section "Chat Integration Constraints" (replaces Courses-only scope)
  - Section "Feature Parity Rules" (website-is-truth rules)
  - Section "Static Data & Mock Removal Policy"
- Removed Sections:
  - None (expanded scope, no deletions)
- Templates Requiring Updates:
  - ✅ plan-template.md — Constitution Check updated in-place below
  - ✅ spec-template.md — No structural changes needed (template is generic)
  - ✅ tasks-template.md — No structural changes needed (template is generic)
- Follow-up TODOs:
  - Update plan-template.md Constitution Check items to match new principles (done inline below)
-->
# EduVerse Flutter Backend Integration Constitution

## Core Principles

### I. BLoC State Management First
All UI state MUST be driven exclusively by reactive BLoC or Cubit classes.
Widgets MUST never perform raw data fetching, direct API calls, or WebSocket
event processing. All network and socket interactions MUST flow through a
dedicated service layer, with results surfaced to the UI solely via
`BlocBuilder`, `BlocConsumer`, or `BlocListener` state transitions
(`loading`, `loaded`, `error`, `connectionStatus`). WebSocket event streams
(e.g., `new_message`, `user_typing`, `message_deleted`) MUST be subscribed
to inside the BLoC/Cubit `init` lifecycle and MUST emit new states — never
directly mutate widget state.

### II. Strict Data Layer Separation
Domain models MUST be strictly separated from raw API response handling.
Every feature starts with strongly-typed Dart models that mirror the exact
backend API response shapes **and** the React website frontend type
interfaces to guarantee cross-platform field parity. The Repository pattern
MUST be utilized through services (e.g., `CourseService`,
`EnrollmentService`, `ChatService`, `ChatSocketService`,
`DiscussionService`). REST services MUST extend or compose `CoreApiClient`
with Dio. WebSocket services MUST be singletons managing their own
connection lifecycle and exposing typed `Stream`s consumed by BLoCs.

### III. Type Safety & Error Handling
All API and WebSocket interactions MUST guarantee type safety and gracefully
handle errors. Models MUST use robust `factory` methods for JSON parsing
with safe fallbacks. Network failures, WebSocket disconnections, parsing
errors, and missing relationships MUST fail predictably and bubble up safe
error states to the UI rather than throwing unhandled exceptions. For
real-time features: optimistic UI updates (e.g., appending a sent message
immediately) MUST include deduplication logic to reconcile with
server-confirmed events, and MUST fall back to REST endpoints when the
WebSocket is disconnected.

### IV. Website Feature Parity
The Flutter mobile app MUST achieve strict 1:1 feature parity with the
EduVerse React website frontend for every integrated feature.

**Parity rules:**
- If a feature EXISTS on the website but NOT in the Flutter app, it MUST be
  added to the Flutter app.
- If a feature EXISTS in the Flutter app but NOT on the website, it MUST be
  removed from the Flutter app.
- All data models, field names, enum values, and API response shapes in
  Flutter MUST exactly match those defined in the website frontend's
  TypeScript interfaces (e.g., `ChatConversationApi`, `ChatMessageApi`,
  `ChatUser`).
- UI component composition (which widgets compose a feature screen) MUST
  mirror the website's component hierarchy, adapted for Flutter's widget
  tree but preserving the identical logical structure.
- The website frontend documentation (`CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md`)
  is the single source of truth for what features and fields MUST exist.

### V. Testable Architecture
All services, repositories, and BLoCs MUST be constructed to be completely
testable. Services MUST accept injected dependencies (e.g., `Dio` instance,
`StorageService`) to allow mocking. WebSocket services MUST expose a
test-friendly interface that can be driven without a live server. Logic MUST
be testable independently of the UI and network layers.

### VI. Real-Time Communication Integrity
WebSocket connections MUST follow a strict lifecycle protocol:
- Connect on feature entry with JWT token authentication.
- Auto-reconnect on disconnect (maximum 5 attempts, 1200ms delay between
  attempts, matching the website frontend behavior).
- Expose a typed `connectionStatus` stream (`connected` / `disconnected`)
  consumed by the BLoC to drive UI connection indicators.
- Emit `join_conversation` on conversation select; emit
  `leave_conversation` on conversation deselect.
- Typing indicators MUST auto-stop after 1.5 seconds of inactivity
  (matching website debounce).
- All events MUST be handled idempotently — duplicate events from
  reconnection MUST NOT cause duplicate messages or state corruption.

### VII. Static Data Elimination
ALL static mock data, sample generators, and simulated responses MUST be
fully eliminated before a phase is considered complete.

**Mandatory removal targets per phase:**
- Hardcoded conversation lists (`_conversations`, `_chatMessages` maps).
- Sample data generators (`_generateSampleConversations()`,
  `_generateSampleMessages()`, `_generateAvailableUsers()`).
- Simulated reply logic (`_simulateReply()`, `Future.delayed` fake
  responses).
- Local `setState` data manipulation that bypasses the BLoC.
- Mock user objects, avatar strings, or timestamp fabrication.

**Gate rule:** No phase may be marked complete if ANY mock/static data
remains in the files modified or created during that phase. The
`/speckit.implement` step MUST include a final audit grep for residual
mock artifacts.

### VIII. Aggressive Clarification
During the `/speckit.clarify` step, the specification MUST be interrogated
with a minimum of 5 targeted clarification questions covering:
1. **Field parity** — Are all backend response fields mapped to model
   properties? Are any website-only fields missing?
2. **Role behavior** — Does each role (student, instructor, TA, admin,
   IT admin) see the correct UI elements and permissions?
3. **Edge cases** — What happens on network failure, empty states, token
   expiration mid-conversation, and large message volumes?
4. **Deletion scope** — Which existing Flutter files, widgets, and models
   will be deleted or replaced?
5. **WebSocket event coverage** — Are all backend-emitted events handled
   in the BLoC? Are there events the backend emits that the spec ignores?

This ensures no ambiguity survives into the implementation phase.

## Chat Integration Constraints

All chat backend integration MUST precisely follow the phases and structures
dictated in `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md`. The domain models
constructed in Flutter MUST match the properties and behaviors defined in
the React Web frontend (`Eduverse-Frontend`) and the backend API
documentation (`Flutter_Chat_API_Docs_BACKEND.md`) to ensure exact feature
parity.

For strict alignment, the implementation MUST reference the following local
environment paths to ensure complete parity with the web version and
established backend routes:
- **Backend Path:** `D:\Graduation\backend\last_backend\EduVerse_Backend`
- **Frontend Website Path:** `D:\Graduation\frontend tarek\Eduverse-Frontend`
- **Backend API Docs:** `Flutter_Chat_API_Docs_BACKEND.md` (in project root)
- **Website Feature Docs:** `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md` (in project root)
- **Integration Plan:** `CHAT_FEATURE_DOCUMENTATION_SPECKIT_PLAN.md` (in project root)

## Feature Parity Rules

The following rules govern what is added and removed during integration:

| Condition | Action | Justification |
|-----------|--------|---------------|
| Feature on website, missing in Flutter | MUST add to Flutter | Website is truth |
| Feature in Flutter, missing on website | MUST remove from Flutter | Website is truth |
| Field in website model, missing in Flutter model | MUST add field | Data parity |
| Enum value in Flutter, absent in backend | MUST remove enum value | Backend is truth |
| Widget in Flutter with no website equivalent | MUST delete widget | No orphan UI |
| Mobile-specific UX patterns (e.g., Swipe to Pin/Mute) | Excusable exception | Mobile UX standards supersede strict feature parity if the action operates purely on local state. |
| WebSocket event in backend, not handled in Flutter | MUST handle event | Full coverage |

## Static Data & Mock Removal Policy

Mock data removal is a **non-negotiable gate** for every phase:

1. **Before implementation**: Identify all mock data in files to be
   modified (grep for hardcoded lists, `DateTime.now().subtract()` patterns,
   `Future.delayed` simulations).
2. **During implementation**: Replace each mock call with a real service
   call through the BLoC.
3. **After implementation**: Run a final audit for residual patterns:
   - `_generateSample`, `_simulateReply`, `_mockMessages`
   - `Duration(hours:`, `Duration(minutes:` in conversation/message data
   - `isMe: true/false` hardcoded message maps
   - `setState(() =>` patterns that bypass BLoC
4. **Verification**: The phase MUST NOT be marked complete until the audit
   returns zero mock residuals in modified files.

## QA & Review Process

Because this integration operates across five dynamic roles (Student,
Instructor, TA, Admin, IT Admin), code reviews and QA MUST manually verify
data changes in all five dashboard contexts. Each phase completion requires:

- Functional verification that real backend data renders correctly.
- WebSocket connection verification (connect, send, receive, reconnect).
- Role-based UI verification (correct buttons, permissions, filters per role).
- Mock data elimination audit (zero residual static data).
- Cross-reference with website frontend to confirm visual and data parity.

## Governance

This Constitution supersedes all other generic practices. Any deviations —
including connecting directly to the backend bypassing BLoCs, introducing
static data outside of clearly marked test fixtures, or adding Flutter-only
features not present on the website — require explicit justification and
amendment to this document. All phases MUST pass the Core Principle gates
before proceeding to the next phase.

**Amendment procedure:**
- Any principle change requires an updated version with Sync Impact Report.
- MAJOR version bump for principle removal/redefinition.
- MINOR version bump for new principle or section addition.
- PATCH version bump for clarification or typo fixes.

**Version**: 2.0.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-06
