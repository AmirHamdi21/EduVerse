# Submission Grading — Instructor Feature Documentation

## 1. Feature Summary
The **Submission Grading** capability belongs to the **Instructor** role and is grouped under **Assignments & Grading**. This document captures implementation intent, navigation, architecture touchpoints, and operational expectations for maintainable evolution.

## 2. Access and Navigation
| Item | Details |
|---|---|
| Role Access | Instructor |
| Primary Route | `/instructor/assignments/:assignmentId/submissions` |
| Primary Screen | `lib/screens/instructor/assignments/submission_grading_screen.dart` |
| Feature Category | Assignments & Grading |

### Entry Points
1. Route configuration in `lib/config/app_router.dart`.
2. Role navigation surfaces (drawer, dashboard quick actions, contextual links).
3. Inter-feature drill-down from related screens.

## 3. User Goals
- Complete key **submission grading** tasks with minimal friction.
- Understand current state clearly (loading, success, empty, error).
- Preserve workflow continuity with adjacent role features.

## 4. Functional Scope
- Provides dedicated UI and actions for **Submission Grading**.
- Coordinates state updates through established BLoC/Cubit patterns.
- Exchanges data through service-layer abstractions and role-aware routes.
- Integrates cleanly with localization/theme and responsive UI requirements.

## 5. Primary User Flow
1. User opens `/instructor/assignments/:assignmentId/submissions`.
2. Screen initializes and requests data dependencies.
3. User executes core actions (view, filter, create, edit, submit, or configure).
4. State layer reflects result and reconciles UI.
5. User exits with persisted state where applicable.

## 6. UI Composition
- **Primary Screen:** `lib/screens/instructor/assignments/submission_grading_screen.dart`
- **Expected Sections:** context header, action controls, main content region, state-feedback UI.
- **UX Baselines:** responsive behavior, accessibility-aware interactions, localization compatibility.

## 7. State Management and Data Layer
| Layer | Implementation |
|---|---|
| State Management | instructor_assignments_cubit, grading_center_cubit, ta_assignment_submissions_cubit |
| Service/API Layer | assignment_service.dart, grades_service.dart |
| Key Data Shapes | assignment config, submission payloads, grading artifacts |

### Data Lifecycle
- Trigger data load from lifecycle and/or user intent.
- Move through deterministic state transitions.
- Persist or reconcile local state without breaking route expectations.

## 8. Business Rules and Validation
- Keep rubric scoring and total score computation deterministic.
- Guard grade updates with explicit save/confirmation flow.
- Retain auditability of grading decisions and feedback.

## 9. Error, Empty, and Loading States
- **Loading:** non-blocking where possible; block destructive duplicates.
- **Empty:** explain why content is empty and provide next action.
- **Error:** return contextual feedback with retry/recovery path.

## 10. Security and Privacy Considerations
- Enforce role boundaries via routing and auth role resolution.
- Avoid cross-role data leakage in shared components.
- Handle personal/academic data with least-privilege display principles.

## 11. Dependencies and Integrations
- `lib/config/app_router.dart`
- `lib/services/auth_role_resolver.dart`
- Role screens under `lib/screens/instructor/**` (or shared surfaces where referenced)
- Supporting modules under `lib/bloc/**` and `lib/services/api/**`

## 12. Implementation Status and Gaps
- **Current Status:** Implemented
- **Current Notes:** Integrated in current branch with role-level routing and UI support.
- **Recommended Hardening:** tighten end-to-end API parity, add instrumentation, and keep route/screen contracts explicitly documented.

## 13. Source References
- `lib/config/app_router.dart`
- `lib/screens/instructor/assignments/submission_grading_screen.dart`
- `features documentation/instructor/INSTRUCTOR_FEATURES_DOCUMENTATION.md`
- `README.md`
