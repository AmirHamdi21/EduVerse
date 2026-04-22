# Phase 0 Research: Student Courses Phase 1

## Decision 1: Backend source code is the contract authority
- Decision: Use NestJS controller/service/DTO files in `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend` as the final source of truth for endpoint shape, required fields, and validation behavior.
- Rationale: Documentation files are useful context but can lag backend changes; Phase 1 requires contract-accurate UI and parsing behavior.
- Alternatives considered: Rely only on frontend docs; rejected because it can preserve stale filters/fields and violate strict data-layer parity.

## Decision 2: Semester filter is included in Phase 1 and wired to backend query
- Decision: Add a semester filter control in the shell and wire it to `GET /api/enrollments/my-courses?semester=<id>`.
- Rationale: Clarification outcomes explicitly require semester filtering in Phase 1, and backend supports optional semester query.
- Alternatives considered: Delay semester filter to Phase 2; rejected due to explicit clarified requirement.

## Decision 3: Status filter options are backend-shape-driven
- Decision: Only expose status filter values supported by backend my-courses behavior (with no unsupported static options).
- Rationale: Prevents UX states that cannot be fulfilled by API responses and enforces backend-first behavior.
- Alternatives considered: Keep full static redesign options regardless of API; rejected because it creates misleading filter behavior.

## Decision 4: Auth/session failures get dedicated UI state
- Decision: Map `401` and `403` responses for student course loading to a dedicated auth/session-required state in BLoC and UI.
- Rationale: Clarification requires dedicated recovery messaging, not generic error toasts/messages.
- Alternatives considered: Reuse existing generic `CoursesError`; rejected due to weak recovery guidance and unclear user action.

## Decision 5: Join Course behavior remains unchanged in Phase 1
- Decision: Keep Join Course action logic and endpoint interaction unchanged; only visual redesign is applied in Phase 1.
- Rationale: Clarification confirmed behavior freeze while still requiring endpoint audit coverage.
- Alternatives considered: Start flow/logic updates in Phase 1; rejected to avoid scope drift.

## Decision 6: Design tokens are centralized for shell components
- Decision: Create `student_courses_theme.dart` to host typography, colors, gradients, spacing, and control styling constants used by all redesigned shell widgets.
- Rationale: Keeps redesign styling coherent and reduces repeated ad-hoc values across files.
- Alternatives considered: Inline values per widget; rejected due to maintainability and consistency risks.

## Decision 7: Compatibility parsing is minimized and temporary
- Decision: Preserve only minimal compatibility branches needed to avoid immediate runtime breakage, and remove temporary fallbacks after backend-aligned integration is confirmed.
- Rationale: Supports safe migration without keeping long-term static or divergent parsing logic.
- Alternatives considered: Keep broad backward compatibility permanently; rejected due to constitution static-data/fallback elimination requirements.

## Decision 8: Targeted verification uses service + bloc + widget tests
- Decision: Validate Phase 1 with focused tests for enrollment service query handling, BLoC state transitions (including auth/session), and shell widget rendering/state behavior.
- Rationale: This gives high confidence on integration correctness with limited scope and avoids overbroad test churn.
- Alternatives considered: Manual verification only; rejected because contract and state logic regressions are likely without automated coverage.

## Decision 9: Cached data policy remains cache-first while loading
- Decision: Keep existing cache-first pattern in `CoursesBloc` for student courses and show cached data while network refresh executes.
- Rationale: Supports sub-2s shell render target and avoids regressions in perceived performance.
- Alternatives considered: Remove cache layer for simplicity; rejected due to performance and user-experience impact.

## Decision 10: Endpoint audit includes related Join Course paths
- Decision: Audit `my-courses` (primary), `available`, and `register` contracts even though only `my-courses` behavior is changed in Phase 1.
- Rationale: Prevents redesign divergence near Join Course UI and prepares safe future expansion.
- Alternatives considered: Audit only `my-courses`; rejected because Join Course is visible in the same shell and requires contract awareness.
