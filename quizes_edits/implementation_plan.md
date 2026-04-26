# Fix 4 Critical Quiz Bugs

## Background
Four bugs identified in the quiz module: missing course selector, AI questions not showing options/correct answer, 400 error on save, and student quiz showing nothing.

## Root Cause Analysis

### Bug 1: Missing Course Selector in Create Quiz
The `_courseId` field exists but has no dropdown UI. The web passes `courseOptions` as a prop.

### Bug 2: AI Questions Missing Options + Correct Answer
The question card in `_questionCard()` only shows the question text and points — it never renders `options` or highlights `correctAnswer`. The web's `QuestionEditor` shows full expandable cards.

### Bug 3: Save Button → 400 Error
**Root cause confirmed from backend DTO** (`create-quiz.dto.ts`):

| Field | Backend Expects | Flutter Sends | Problem |
|-------|----------------|---------------|---------|
| `courseId` | `@IsNumber()` **REQUIRED** | conditional `if (_courseId != null)` | Missing = 400! |
| `passingScore` | `@IsNumber()` | `string` (`.toString()`) | Type mismatch |
| `weight` | `@IsNumber()` | `string` (`.toString()`) | Type mismatch |
| `randomizeQuestions` | `@IsBoolean()` | `int` (0/1) | Type mismatch |
| `showCorrectAnswers` | `@IsBoolean()` | `int` (0/1) | Type mismatch |

The web sends `passingScore` as string too BUT it works because NestJS class-validator coerces strings to numbers with `enableImplicitConversion`. However, `courseId` being missing is the **primary 400 cause**.

### Bug 4: Student Quiz Shows Nothing  
The student taker checks `state.totalQuestions > 0` — if 0, it shows a spinner forever. The `getById` endpoint may not include questions in its response for students, and `getQuizQuestions` endpoint may require instructor role.

## Proposed Changes

---

### Create Screen Fixes (`instructor_quiz_create_screen.dart`)

#### 1. Add Course Selector Dropdown
- Import `InstructorCoursesBloc` + state
- Add `_buildCourseSelector(dk)` in the Basic Info card
- Block AI generation if `_courseId` is null (show snackbar + switch to settings tab)

#### 2. Fix Question Card — Collapsible with Options
- Add `_expandedQuestions` set to track expanded cards
- Show expand/collapse arrow button in card header
- When expanded, show: options list with correct answer highlighted (green radio), explanation, points
- For MCQ: show options with the correct one checked
- For T/F: show "True"/"False" with correct one checked

#### 3. Fix Save Payload Types
Change:
```dart
// BEFORE (broken)
'passingScore': (double.tryParse(_passingScore.text) ?? 50).toString(),
'weight': (double.tryParse(_weight.text) ?? 1).toString(),
'randomizeQuestions': _randomize ? 1 : 0,
'showCorrectAnswers': _showCorrect ? 1 : 0,
if (_courseId != null) 'courseId': _courseId,

// AFTER (correct)
'courseId': _courseId,  // REQUIRED — always send
'passingScore': double.tryParse(_passingScore.text) ?? 50,
'weight': double.tryParse(_weight.text) ?? 1,
'randomizeQuestions': _randomize,
'showCorrectAnswers': _showCorrect,
```

Also add `courseId` validation before save (show error if null).

#### 4. Navigate to Management After Save
After successful save, call `context.pop()` — this already exists but the 400 error prevented it from being reached.

---

### TA Create Screen (`ta_quiz_create_screen.dart`)
Mirror all the same fixes using `TACoursesCubit`.

---

### Edit Screens (Both Instructor + TA)
Fix the same payload type mismatches in `_save()`:
- `passingScore` → send as `double`, not string  
- `weight` → send as `double`, not string
- `randomizeQuestions` → send as `bool`, not int
- `showCorrectAnswers` → send as `bool`, not int

---

### Student Quiz Taker (`student_quiz_cubit.dart`)
The current flow is:
1. `getById(quizId)` → may not include questions for students
2. `attempt.questions` → usually empty from `startAttempt`  
3. `getQuizQuestions(quizId)` → fallback

> [!IMPORTANT]
> The `getQuizQuestions` endpoint (`GET /quizzes/:id/questions`) may require instructor/TA role. Need to verify and potentially use a different endpoint or ensure the `getById` response includes questions for students.

Check the backend controller to verify student access to questions endpoint.

---

## Verification Plan

### Automated Tests
- `flutter analyze` — zero errors

### Manual Verification
1. Create quiz as instructor → course dropdown visible → select course → add questions → save → navigates to management → quiz appears
2. AI generation → file upload → shows warning if no course selected → generates questions → card shows options with correct answer highlighted → collapsible
3. Student views published quiz → starts quiz → questions render → can answer → submit
