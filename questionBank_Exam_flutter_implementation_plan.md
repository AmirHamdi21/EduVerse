# questionBank_Exam_flutter_implementation_plan.md

## Summary
Implement instructor Question Bank and Exam Generator in `D:\Graduation\EduVerse\edu_verse`, backed by the real backend at `D:\Graduation\backend\last_backend\EduVerse_Backend`.

This file is the implementation contract. The implementation must use the exact file names, class names, route names, services, cubits, widgets, and folders listed here. Do not prepend `/api` in Flutter services because `CoreApiClient` already uses `ApiService.baseUrl`, which includes `/api`. Do not add new test dependencies; existing repo style uses fake services and queued Dio adapters.

## Exact File Structure Contract
Question Bank models:
- `lib/models/question_bank/question_bank_enums.dart`
- `lib/models/question_bank/course_chapter_model.dart`
- `lib/models/question_bank/question_bank_option_model.dart`
- `lib/models/question_bank/question_bank_fill_blank_model.dart`
- `lib/models/question_bank/question_bank_attachment_model.dart`
- `lib/models/question_bank/question_bank_group_model.dart`
- `lib/models/question_bank/question_bank_question_model.dart`
- `lib/models/question_bank/question_bank_page_model.dart`
- `lib/models/question_bank/question_bank_form_payload.dart`
- `lib/models/question_bank/question_bank_upload_response.dart`

Exam Generator models:
- `lib/models/exams/exam_generator_enums.dart`
- `lib/models/exams/exam_generation_rule_model.dart`
- `lib/models/exams/exam_generation_section_model.dart`
- `lib/models/exams/exam_shortage_model.dart`
- `lib/models/exams/exam_response_model.dart`
- `lib/models/exams/exam_draft_section_model.dart`
- `lib/models/exams/exam_draft_item_model.dart`
- `lib/models/exams/exam_draft_model.dart`
- `lib/models/exams/exam_page_model.dart`
- `lib/models/exams/exam_export_response_model.dart`

Services:
- `lib/services/api/question_bank_service.dart`
- `lib/services/api/exam_generator_service.dart`

Cubits/states:
- `lib/bloc/instructor/question_bank/question_bank_cubit.dart`
- `lib/bloc/instructor/question_bank/question_bank_state.dart`
- `lib/bloc/instructor/question_bank/question_form_cubit.dart`
- `lib/bloc/instructor/question_bank/question_form_state.dart`
- `lib/bloc/instructor/exam_generator/exam_generator_cubit.dart`
- `lib/bloc/instructor/exam_generator/exam_generator_state.dart`
- `lib/bloc/instructor/exam_generator/exam_draft_editor_cubit.dart`
- `lib/bloc/instructor/exam_generator/exam_draft_editor_state.dart`

Screens, widgets, drawer, quick access, routes, localization, skeleton loading, responsive layout, and tests must match the detailed user-approved contract in the conversation. All new tabs must use `InstructorModernTabStrip`. Main screens must follow instructor Assignments/Labs/Discussions UI. Create/edit screens must follow Create/Edit Assignment UI. Detail screens must follow Assignment/Lab details UI.

## Backend Contract
Use `CoreApiClient`. Service paths must be `/courses/:courseId/chapters`, `/question-bank/questions`, `/question-bank/groups`, `/exams`, `/exams/drafts`, and `/exam-drafts` only as read fallback if needed.

Question list and group list responses are `{ data, total }`. Exam and draft list responses are `{ data, meta }`. Question responses do not expose `questionFileId` or top-level `questionImageUrl`. Attachment mutations return raw attachment entities, so reload the full question after attachment mutations. Exam export `content` is base64 and must be decoded before saving/opening the `.doc`.

## Verification
Run `flutter gen-l10n`, `flutter analyze`, targeted tests, and `flutter test`. If a command fails because of unrelated existing repo issues, document the exact failure and prove the new feature tests still run where possible.

## Remaining Backend UI Coverage Contract
This section extends the original contract and must be used to verify the second implementation pass. The app must expose all useful backend-supported instructor operations for Question Bank and Exam Generator without changing the established instructor visual style.

### Additional Files Created Or Used
Question Bank:
- `lib/bloc/instructor/question_bank/question_detail_cubit.dart`
- `lib/bloc/instructor/question_bank/question_detail_state.dart`
- `lib/bloc/instructor/question_bank/question_bulk_create_cubit.dart`
- `lib/bloc/instructor/question_bank/question_bulk_create_state.dart`
- `lib/bloc/instructor/question_bank/question_group_cubit.dart`
- `lib/bloc/instructor/question_bank/question_group_state.dart`
- `lib/models/question_bank/question_bulk_row_model.dart`
- `lib/models/question_bank/question_attachment_payload.dart`
- `lib/models/question_bank/question_group_payload.dart`
- `lib/screens/instructor/question_bank/question_bank_chapters_screen.dart`
- `lib/screens/instructor/question_bank/question_group_create_screen.dart`
- `lib/screens/instructor/question_bank/question_group_edit_screen.dart`
- `lib/widgets/instructor/question_bank/question_chapter_selector.dart`
- `lib/widgets/instructor/question_bank/question_chapter_manager_card.dart`
- `lib/widgets/instructor/question_bank/question_chapter_form_card.dart`
- `lib/widgets/instructor/question_bank/question_chapter_delete_dialog.dart`
- `lib/widgets/instructor/question_bank/question_attachment_manager.dart`
- `lib/widgets/instructor/question_bank/question_attachment_form_card.dart`
- `lib/widgets/instructor/question_bank/question_attachment_reorder_list.dart`
- `lib/widgets/instructor/question_bank/question_group_form_card.dart`
- `lib/widgets/instructor/question_bank/question_group_reorder_list.dart`
- `lib/widgets/instructor/question_bank/question_group_batch_editor.dart`
- `lib/widgets/instructor/question_bank/question_bulk_row_card.dart`
- `lib/widgets/instructor/question_bank/question_bulk_validation_panel.dart`
- `lib/widgets/instructor/question_bank/question_bank_localized_labels.dart`

Exam Generator:
- `lib/bloc/instructor/exam_generator/exam_generator_form_cubit.dart`
- `lib/bloc/instructor/exam_generator/exam_generator_form_state.dart`
- `lib/models/exams/exam_generation_form_model.dart`
- `lib/models/exams/exam_draft_item_update_payload.dart`
- `lib/models/exams/exam_draft_section_payload.dart`
- `lib/widgets/instructor/exam_generator/exam_generation_mode_toggle.dart`
- `lib/widgets/instructor/exam_generator/exam_generation_settings_card.dart`
- `lib/widgets/instructor/exam_generator/exam_generation_rule_card.dart`
- `lib/widgets/instructor/exam_generator/exam_generation_section_card.dart`
- `lib/widgets/instructor/exam_generator/exam_generation_validation_panel.dart`
- `lib/widgets/instructor/exam_generator/exam_draft_editor_toolbar.dart`
- `lib/widgets/instructor/exam_generator/exam_draft_section_editor_card.dart`
- `lib/widgets/instructor/exam_generator/exam_draft_section_reorder_list.dart`
- `lib/widgets/instructor/exam_generator/exam_draft_item_editor_card.dart`
- `lib/widgets/instructor/exam_generator/exam_draft_item_reorder_list.dart`
- `lib/widgets/instructor/exam_generator/exam_candidate_question_picker.dart`
- `lib/widgets/instructor/exam_generator/exam_override_reason_field.dart`
- `lib/widgets/instructor/exam_generator/exam_generator_localized_labels.dart`

### Additional Routes
These routes must stay before dynamic question routes:
- `/instructor/question-bank/chapters`
- `/instructor/question-bank/groups/create`
- `/instructor/question-bank/groups/:groupId/edit`

### Question Bank Required Coverage
- Chapter create, update, and delete must be available through `QuestionBankChaptersScreen`.
- Question create/edit must allow creating a new chapter from the chapter selector, then reload and select it.
- Question delete/archive-via-DELETE must be exposed with confirmation.
- Bulk create must use `POST /question-bank/questions/batch`, enforce max 50 rows, keep failed rows editable, and validate each row locally.
- Attachment tab must support add by existing `fileId`, image upload after question creation, metadata edit, reorder, and delete. After each attachment mutation, reload the full question.
- Group create/edit/delete must be available through full-screen routes.
- Group detail must support grouped batch create with `POST /question-bank/groups/:groupId/questions/batch`.
- Group detail must support question reorder with `{ questionId, itemOrder }`.
- Group delete confirmation must state that deleting the group does not delete its questions.

### Exam Generator Required Coverage
- Create screen must support flat and sectioned generation modes.
- Generation settings must expose total marks, mark distribution, rounding, seed, and independent group mode only.
- Rules must expose chapter, count, weight per question, optional type, difficulty, and Bloom level.
- Sectioned rules must expose section title, instructions, marks, answer policy, required answer count, and nested rules.
- Draft detail must behave as an editor with tabs for Overview, Sections, Questions, Reorder, and Add Question.
- Draft sections must support create, update, reorder, and delete.
- Draft items must support add approved question, replace question, update section/marks/weights/order/override reason, reorder, remove, open source question, and edit source question.
- Draft editing controls must be disabled when draft status is not `open` or the draft is expired.
- Saved exam detail must remain compact because the backend does not return saved exam items.

### Localization Contract
Every visible static string in the Question Bank and Exam Generator feature files must come from `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, except backend-provided dynamic content and low-level debug/test-only values. Regenerate `lib/generated_l10n/*` with `flutter gen-l10n` after ARB edits.
