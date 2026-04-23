# Quiz Feature Migration — Task Tracker

## Phase 1 — Data Models
- [ ] Create `lib/models/quiz/quiz_api_models.dart` with all models + enums

## Phase 2 — API Service
- [ ] Create `lib/services/api/quiz_api_service.dart` with all 18 endpoints

## Phase 3 — State Management
- [ ] Create `lib/bloc/quiz/student_quiz_state.dart`
- [ ] Create `lib/bloc/quiz/student_quiz_cubit.dart`
- [ ] Create `lib/bloc/quiz/quiz_management_state.dart`
- [ ] Create `lib/bloc/quiz/quiz_management_cubit.dart`

## Phase 4 — Student UI
- [ ] Create `lib/screens/student/quizzes/student_quizzes_screen.dart`
- [ ] Create `lib/widgets/student/quizzes/student_quiz_card.dart`
- [ ] Create `lib/screens/student/quizzes/student_quiz_taker_screen.dart`
- [ ] Create `lib/screens/student/quizzes/student_quiz_result_screen.dart`
- [ ] Create `lib/widgets/student/quizzes/student_attempt_history.dart`

## Phase 5 — Instructor UI
- [ ] Create `lib/screens/instructor/quiz_management/instructor_quiz_management_screen.dart`
- [ ] Create `lib/screens/instructor/quiz_management/instructor_quiz_create_screen.dart`
- [ ] Create `lib/screens/instructor/quiz_management/instructor_quiz_edit_screen.dart`
- [ ] Create `lib/screens/instructor/quiz_management/instructor_quiz_attempts_screen.dart`
- [ ] Create `lib/screens/instructor/quiz_management/instructor_quiz_grading_screen.dart`
- [ ] Create `lib/screens/instructor/quiz_management/instructor_quiz_statistics_screen.dart`

## Phase 6 — TA UI (Full CRUD — Identical to Instructor)
- [ ] Create `lib/screens/ta/quiz_management/ta_quiz_management_screen.dart`
- [ ] Create `lib/screens/ta/quiz_management/ta_quiz_create_screen.dart`
- [ ] Create `lib/screens/ta/quiz_management/ta_quiz_edit_screen.dart`
- [ ] Create `lib/screens/ta/quiz_management/ta_quiz_attempts_screen.dart`
- [ ] Create `lib/screens/ta/quiz_management/ta_quiz_grading_screen.dart`
- [ ] Create `lib/screens/ta/quiz_management/ta_quiz_statistics_screen.dart`

## Phase 7 — Navigation & Routing
- [ ] Modify `instructor_drawer.dart` — remove AI Quiz, add Quiz Management
- [ ] Modify `ta_drawer.dart` — add Quiz Management
- [ ] Modify `student_drawer.dart` — add Quizzes
- [ ] Modify `app_router.dart` — add all quiz routes + BLoC providers

## Phase 8 — Localization
- [ ] Add quiz keys to `app_en.arb`
- [ ] Add quiz keys to `app_ar.arb`

## Verification
- [ ] `flutter analyze` passes
- [ ] `flutter build apk --debug` passes
