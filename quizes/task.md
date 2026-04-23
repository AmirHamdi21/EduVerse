# Quiz Feature Migration — Task Tracker

## Phase 1 — Data Models
- [x] Create `lib/models/quiz/quiz_api_models.dart` with all models + enums

## Phase 2 — API Service
- [x] Create `lib/services/api/quiz_api_service.dart` with all 18 endpoints

## Phase 3 — State Management
- [x] Create `lib/bloc/quiz/student_quiz_state.dart`
- [x] Create `lib/bloc/quiz/student_quiz_cubit.dart`
- [x] Create `lib/bloc/quiz/quiz_management_state.dart`
- [x] Create `lib/bloc/quiz/quiz_management_cubit.dart`

## Phase 4 — Student UI
- [x] Create `lib/screens/student/quizzes/student_quizzes_screen.dart`
- [x] Create `lib/widgets/student/quizzes/student_quiz_card.dart`
- [x] Create `lib/screens/student/quizzes/student_quiz_taker_screen.dart`
- [x] Create `lib/screens/student/quizzes/student_quiz_result_screen.dart`
- [x] Create `lib/widgets/student/quizzes/student_attempt_history.dart`

## Phase 5 — Instructor UI
- [x] Create `lib/screens/instructor/quiz_management/instructor_quiz_management_screen.dart`
- [x] Create `lib/screens/instructor/quiz_management/instructor_quiz_create_screen.dart`
- [x] Create `lib/screens/instructor/quiz_management/instructor_quiz_edit_screen.dart`
- [x] Create `lib/screens/instructor/quiz_management/instructor_quiz_attempts_screen.dart`
- [x] Create `lib/screens/instructor/quiz_management/instructor_quiz_grading_screen.dart`
- [x] Create `lib/screens/instructor/quiz_management/instructor_quiz_statistics_screen.dart`

## Phase 6 — TA UI
- [x] Create `lib/screens/ta/quiz_management/ta_quiz_management_screen.dart`
- [x] Create `lib/screens/ta/quiz_management/ta_quiz_create_screen.dart`
- [x] Create `lib/screens/ta/quiz_management/ta_quiz_edit_screen.dart`
- [x] Create `lib/screens/ta/quiz_management/ta_quiz_attempts_screen.dart`
- [x] Create `lib/screens/ta/quiz_management/ta_quiz_grading_screen.dart`
- [x] Create `lib/screens/ta/quiz_management/ta_quiz_statistics_screen.dart`

## Phase 7 — Navigation & Routing
- [x] Modify `instructor_drawer.dart` — add Quiz Management
- [x] Modify `ta_drawer.dart` — add Quiz Management
- [x] Modify `student_drawer.dart` — add Quizzes
- [x] Modify `app_router.dart` — add all quiz routes (16 routes total)

## Phase 8 — Localization
- [/] Add quiz keys to `app_en.arb`
- [ ] Add quiz keys to `app_ar.arb`

## Verification
- [ ] `flutter analyze` passes
- [ ] `flutter build apk --debug` passes
