# Quiz Bug Fixes Tasks

- `[ ]` **Bug 3: Fix save payload types** (instructor_quiz_create_screen.dart)
  - `[ ]` Fix `courseId` — make it required (not conditional)
  - `[ ]` Fix `passingScore` — send as `double`, not string
  - `[ ]` Fix `weight` — send as `double`, not string
  - `[ ]` Fix `randomizeQuestions` — send as `bool`, not int
  - `[ ]` Fix `showCorrectAnswers` — send as `bool`, not int
  - `[ ]` Add courseId validation before save
  - `[ ]` Add success navigation to pop back

- `[ ]` **Bug 1: Add course selector dropdown** (instructor_quiz_create_screen.dart)
  - `[ ]` Import InstructorCoursesBloc
  - `[ ]` Add course dropdown in Basic Info card
  - `[ ]` Block AI generation if no course selected

- `[ ]` **Bug 2: Fix question card — collapsible with options**
  - `[ ]` Add `_expandedQuestions` set for tracking
  - `[ ]` Add expand/collapse arrow in card header
  - `[ ]` Show options with correct answer highlighted when expanded
  - `[ ]` Show correct answer auto-selected for AI-generated MCQ

- `[ ]` **Mirror all fixes to TA create screen** (ta_quiz_create_screen.dart)

- `[ ]` **Bug 3b: Fix save payload in edit screens** (both instructor + TA)

- `[ ]` **Bug 4: Verify student quiz taker** (debug)

- `[ ]` **Verify** — flutter analyze zero errors
