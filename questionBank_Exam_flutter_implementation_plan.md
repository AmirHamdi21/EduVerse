# Question Bank And Exam Generator Flutter Implementation Plan

Date: 2026-05-04

Frontend root: `D:\Graduation\EduVerse\edu_verse`

Backend root investigated: `D:\Graduation\backend\last_backend\EduVerse_Backend`

Primary backend documentation read: `questionBank_Exam_features_docs.md`

Target role: Instructor only

## Quick Implementation Order

Use this checklist as the execution path before reading the detailed phase notes:

1. Create/confirm shared enums, response models, request DTO builders, and strict JSON serializers for question bank and exams.
2. Add API service methods for chapters, question bank questions, attachments, groups, draft generation, draft editing, saved exams, lifecycle actions, and Word-compatible export.
3. Add localization keys for every static label, button, empty state, validation message, filter label, and action confirmation used by the new instructor screens.
4. Build the instructor Question Bank hub first: course selector, compact hero stats, filters, question list cards, pagination/refresh, and archive/review actions.
5. Build the question create/edit flow next, including type-specific editors, chapter quick-create, strict payload cleanup, image/attachment flows, and responsive mobile/tablet layouts.
6. Build question group screens after the single-question flow is stable: group list/detail, grouped question editor, local-only group type filtering, group item reorder, and grouped batch create.
7. Build the Exams hub: saved exams tab, drafts tab, course/status filters, compact stats, lifecycle actions, and export action.
8. Build the exam generation wizard: flat mode, sectioned mode, rules, mark distribution, shortage handling, and pre-submit validation that blocks backend-known invalid shapes.
9. Build the draft review/editor: sections, unsectioned items, add/replace/remove/reorder, marks/weight editing, override reason handling, and full refetch after structural mutations.
10. Build saved exam detail as a compact lifecycle/export view only; do not promise full saved paper preview until backend expands saved exam detail responses.
11. Wire routes/navigation into the existing instructor area using the same assignment/lab/discussion visual language, responsive constraints, and loading/error patterns.
12. Run the implementation checklist near the end of this document against real backend calls, especially strict DTO payload checks and export/download behavior.

## 1. Investigation Summary

This plan is based on the feature documentation plus direct backend source inspection. The backend feature is implemented as instructor authoring APIs for:

1. Course chapters.
2. Question bank questions.
3. Question image upload.
4. Question attachments.
5. Question groups and grouped batch creation.
6. Question review/status changes.
7. Exam draft generation from approved questions.
8. Manual draft editing.
9. Saving drafts into immutable exams.
10. Publishing, unpublishing, archiving, and exporting saved exams.

The current backend is not a student exam delivery system. The frontend must present this as an instructor authoring and exam assembly system, not as a student-taking workflow.

## 2. Backend Source Files Checked

Question bank:

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/dto/question.dto.ts`
4. `src/modules/question-bank/dto/question-bulk.dto.ts`
5. `src/modules/question-bank/dto/question-group.dto.ts`
6. `src/modules/question-bank/dto/question-attachment.dto.ts`
7. `src/modules/question-bank/dto/chapter.dto.ts`
8. `src/modules/question-bank/dto/question-response.dto.ts`
9. `src/modules/question-bank/enums/question-bank.enums.ts`
10. `src/modules/question-bank/entities/*`
11. `src/modules/question-bank/services/instructor-course-access.service.ts`

Exam generator:

1. `src/modules/exams/exams.controller.ts`
2. `src/modules/exams/exam-drafts.controller.ts`
3. `src/modules/exams/exams.service.ts`
4. `src/modules/exams/dto/generate-exam.dto.ts`
5. `src/modules/exams/dto/exam-draft-item.dto.ts`
6. `src/modules/exams/dto/exam-section.dto.ts`
7. `src/modules/exams/dto/exam-query.dto.ts`
8. `src/modules/exams/dto/exam-export.dto.ts`
9. `src/modules/exams/dto/exam-response.dto.ts`
10. `src/modules/exams/entities/*`

Flutter app patterns:

1. `lib/services/api/core_api_client.dart`
2. `lib/common/retry_helper.dart`
3. `lib/common/service_error.dart`
4. `lib/services/api/assignment_service.dart`
5. `lib/services/api/lab_service.dart`
6. `lib/services/api/enrollment_service.dart`
7. `lib/bloc/instructor/instructor_assignments_cubit.dart`
8. `lib/bloc/instructor/instructor_assignments_state.dart`
9. `lib/screens/instructor/assignments/instructor_assignments_screen.dart`
10. `lib/screens/instructor/labs/instructor_labs_screen.dart`
11. `lib/screens/instructor/discussions/instructor_discussions_screen.dart`
12. `lib/widgets/instructor/shared/instructor_colors.dart`
13. `lib/common/utils/responsive.dart`
14. `lib/config/app_router.dart`
15. `lib/l10n/app_en.arb`
16. `lib/l10n/app_ar.arb`

## 3. Backend Facts The Frontend Must Follow

### 3.0 Re-Audit Corrections From Backend Source

The backend has a global `ValidationPipe` configured with `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`, and implicit conversion. This changes how the frontend must build payloads:

1. Do not send unknown keys. They will be rejected.
2. Do not rely on service-layer normalization to satisfy DTO-required fields, because DTO validation happens before controller methods call services.
3. For create, bulk create, and grouped batch create, every question object must include `courseId` and `chapterId` because `CreateQuestionBankQuestionDto` requires both. The bulk endpoint also accepts `defaultChapterId`, but each nested question is still typed as `CreateQuestionBankQuestionDto`; safest implementation should send `chapterId` on every nested question after applying the default in Flutter.
4. Do not send empty `options: []` or `fillBlanks: []` in create/bulk/grouped-create payloads. In create DTOs those fields are optional, but if present they have `ArrayMinSize(1)`. Omit incompatible child arrays entirely.
5. Update DTOs allow empty arrays, but the service validation still checks the final merged question. Use empty arrays on update only when intentionally clearing/replacing children for a compatible type change.
6. Main prompt image response gap: the backend accepts and stores `questionFileId`, and the service internally attaches a `questionImageUrl` property to loaded entities, but `toPrivateResponse()` currently returns neither `questionFileId` nor `questionImageUrl`. Persistently previewable image URLs are available through attachments (`attachments[].imageUrl`), not through the main image field, unless the backend response DTO/service is extended to expose main image metadata and URL.
7. Exam and draft list endpoints return compact/paginated rows without item/section relations loaded. Saved exam `GET /exams/:id` returns compact `ExamResponseDto` with counts populated, but still not full item snapshots. Draft detail `GET /exams/drafts/:draftId` loads items, sections, and each item question entity, but not full nested question options/fill blanks/attachments.
8. Reorder endpoints differ: draft item reorder explicitly requires every draft item exactly once; attachment reorder validates that requested attachment IDs exist; group item and draft section reorder do not explicitly verify every requested ID or enforce a full list. The frontend should send the full visible ordered list for all reorder operations, build it only from currently loaded backend IDs, then refetch and compare the result.
9. `manual` mark distribution during generation does not accept per-item marks. It sets marks from rule weights rounded by policy. True manual marks happen later through draft item editing.
10. Question image upload limit is 15 MB and MIME types are `image/jpeg`, `image/png`, `image/webp`, and `image/gif`.
11. `UpdateQuestionBankQuestionDto` does not allow `courseId`. Edit mode can change the chapter only inside the existing course, and the frontend must never send `courseId` in `PATCH /question-bank/questions/:id`.
12. `DELETE /question-bank/questions/:id` sets status to `archived` and then soft-deletes the row, so it disappears from normal list queries. Use `POST /question-bank/questions/:id/archive` for the normal reversible archive flow that remains visible through `status=archived`.
13. `DELETE /courses/:courseId/chapters/:chapterId` hard-removes a chapter. Questions and groups reference chapters with cascade behavior, so chapter delete must be treated as destructive and guarded by strong confirmation or disabled when related content exists.
14. `QuestionGroupQueryDto` has no `groupType` filter. Group type counts/filters can only be computed client-side from the loaded page or require a backend query enhancement.
15. Although create/update DTOs accept `status`, the frontend should use dedicated status endpoints for approve/reject/archive/restore so review fields and review events stay consistent.
16. List pagination should stay within the backend's practical limits. Question lists validate `limit <= 100`, group lists cap `limit` at 100 in service code, and exam/draft lists normalize `limit` to a maximum of 100.
17. Do not blindly strip all `null` values from update payloads. Explicit `null` is meaningful for clear operations such as `questionFileId`, `questionText`, `expectedAnswerText`, `hints`, attachment `caption`/`altText`, group `title`, group `sharedPrompt`, group `sharedFileId`, draft item `draftSectionId`, and nullable draft section fields such as `instructions`, `totalMarks`, and `requiredAnswerCount`.
18. For multipart attachment image upload metadata, omit `isPrimary` when false instead of sending a string `"false"`. JSON endpoints can send real booleans, but multipart form fields arrive as strings and should be kept minimal.
19. `DELETE /question-bank/groups/:groupId` soft-deletes the group record. It does not delete the underlying questions; the UI should refresh group lists and grouped question chips after deletion.
20. Sectioned exam generation should not allow a request where every section has zero rules. The backend can create an open empty draft from empty section arrays, but that draft cannot be saved because save rejects drafts without items.
21. Draft section deletion does not delete draft items. The backend sets every item in that section to `draftSectionId: null` and then removes the section, so the UI must move those items into an unsectioned area after refresh instead of dropping them from the draft.
22. Draft item add and update payloads are different. `AddDraftItemDto` accepts `questionId`, optional `draftSectionId`, `weightUnits`, `marks`, and `overrideReason`; it does not accept `weight`. The backend derives stored `weight` as `weightUnits ?? marks ?? 1` during add. `UpdateDraftItemDto` accepts `weight`, `weightUnits`, and `marks` independently, and the backend does not automatically keep them consistent. For add-item flows, send either `marks` alone for a manually marked item or `weightUnits` alone for a weighted item; never send `weight` in `POST /exams/drafts/:draftId/items`.
23. Draft detail nested `item.question` is a raw shallow `QuestionBankQuestion` entity in the current backend, not `QuestionBankPrivateResponseDto`. Mutation endpoints for draft items usually return `ExamDraftItem` without the nested question relation. Always fetch `GET /question-bank/questions/:id` for full private question preview/answers.
24. Question update preserves existing MCQ options/fill-blank answers when `options` and `fillBlanks` are omitted. Do not resend child arrays during a text/metadata-only edit; send full child arrays only when the user actually changes the children or intentionally changes type/clears compatible children.
25. `hasAttachments=false` is a real server filter. Backend transforms the query string to boolean false and uses a `NOT EXISTS` condition. Query serializers must preserve false values instead of dropping them as empty/falsey.
26. Main question images, grouped question images, question attachment files, and group shared files all pass backend file access checks. Main/grouped prompt image fields and `upload-image` attachment flows require image MIME files. Generic `addAttachment` can attach existing non-image files when `attachmentType` is `document`, `audio`, or `video`. Group `sharedFileId` is access-checked but not MIME-restricted unless the Flutter UI deliberately treats it as an image prompt.
27. Equal and weight-normalized generation modes adjust rounded marks so returned draft item marks can exactly match the requested total. The frontend should trust backend-returned item marks in the draft preview instead of recomputing them from rules for display.
28. `CourseChapter.isActive` is stored and validated as a numeric tinyint/int value, not as a strict JSON boolean contract. Parse `0/1` defensively into a UI boolean helper, but send `0` or `1` only from chapter update payloads if the UI ever exposes chapter activation. Chapter create does not accept `isActive`.
29. Date filters for exams and drafts must be sent as ISO date strings accepted by `@IsDateString()`, not localized display strings. Validate `dateFrom <= dateTo` in Flutter before requesting the backend.
30. Question review/status endpoints use request body key `comment`, while exam lifecycle endpoints use request body key `reason`. Do not share one generic lifecycle payload mapper across both modules unless it maps the key per endpoint family.
31. Exam publish/unpublish/archive stores `statusReason` internally, but `ExamResponseDto` does not return `statusReason`. The UI can collect and send the reason, but should not promise to display the persisted reason after refresh unless the backend response is expanded.
32. `AddDraftItemDto.draftSectionId` is optional but not nullable in DTO validation. Omit `draftSectionId` to add an unsectioned item; use explicit `draftSectionId: null` only in `UpdateDraftItemDto` when moving an existing item out of a section.
33. Generated draft creation avoids duplicate selected question IDs, but manual `POST /exams/drafts/:draftId/items` has no duplicate-question guard or unique index in the inspected backend. The draft editor should prevent accidental duplicate manual additions or require a clear confirmation.
34. Question bank `search` only filters `LOWER(q.questionText)`. It does not search options, fill blank answers, expected answers, hints, attachments, group prompt, or chapter name. UI placeholder text should reflect that narrow backend search behavior.
35. Read-only draft aliases exist at `/exam-drafts`, `/exam-drafts/list`, and `/exam-drafts/:draftId`; mutation routes exist under `/exams/drafts/...`. Prefer `/exams/drafts` in the Flutter exam service for consistency and treat `/exam-drafts` as a compatibility/read-only alias.
36. `CreateChapterDto` requires `name` and numeric `chapterOrder >= 1`. The backend does not auto-assign chapter order. If the UI offers quick chapter creation, compute `max(existing.chapterOrder) + 1` from the loaded chapter list or expose an order field. Do not send `isActive` on chapter create because strict DTO validation rejects it; activation changes belong to `PATCH /courses/:courseId/chapters/:chapterId`.
37. `weight_normalized` mark distribution can fail even though `weightPerQuestion` accepts `0`. `applyMarks()` rejects a normalized scope whose generated items have total weight `<= 0`. For flat generation with `totalMarks`, and for every section in sectioned generation, the frontend must require the planned weighted sum to be greater than zero when mode is `weight_normalized`.
38. `answer_any` does not make `requiredAnswerCount` mandatory at DTO/service level; the backend stores `null` if omitted. The Flutter UI may still require it for a clear instructor-facing exam contract, but the plan must treat that as a UX rule, not a backend validation rule.
39. Draft add/replace override rules are scoped to the target flat rule set or target section rule set. The backend requires `overrideReason` only when that scope has rules and the selected approved question matches none of them. If the target scope has no generation rules, the backend allows the add/replace without an override.
40. `ExportExamDto.format` validates `html_doc`, `docx`, and `pdf`, but `exportExamAsWord()` currently always returns base64 Word-compatible HTML as `exam-{id}.doc` with `application/msword`. Flutter should force `format: html_doc` and not expose PDF/DOCX choices until the service produces those formats.
41. In sectioned generation, `ExamGenerationSectionDto.totalMarks` is required for every section even when mark distribution mode is `manual`. Manual mode still sets generated item marks from each rule's `weightPerQuestion`; section totals are stored on sections and summed into `draft.totalMarks`, so the UI must show possible section/item total divergence.
42. Question option and fill-blank response fields are not the same as create/update payload fields. The backend returns `optionId`, `optionOrder`, and `blankId`, but `CreateQuestionBankOptionDto`, `UpdateQuestionBankOptionDto`, `CreateQuestionBankFillBlankDto`, and `UpdateQuestionBankFillBlankDto` do not accept those fields. With strict validation enabled, the Flutter editor must never echo `optionId`, `optionOrder`, or `blankId` inside `options` or `fillBlanks` arrays. Reordering MCQ/true-false options is done by array order because the service rewrites `optionOrder` from the submitted array index; fill blanks have no order field in the current entity.

### 3.1 Authorization And Ownership

All endpoints require an instructor JWT through `Authorization: Bearer <token>`.

The backend uses `JwtAuthGuard`, `RolesGuard`, and `@Roles(RoleName.INSTRUCTOR)`. Student, TA, and admin roles are blocked for this feature.

Course ownership is enforced through:

`course_instructors -> course_sections -> course_id`

Frontend course selectors must use the instructor's teaching courses from `GET /api/enrollments/teaching`, then send the selected `courseId` to question bank and exam APIs. The frontend should not show admin course pickers or allow arbitrary course IDs.

### 3.2 Endpoint Base Path In Flutter

`CoreApiClient` already uses `ApiService.baseUrl`, which includes `/api`.

Therefore Flutter services must call paths without `/api`, for example:

1. Backend route: `GET /api/question-bank/questions`
2. Flutter Dio path: `'/question-bank/questions'`

### 3.3 Question Bank Endpoints

Chapters:

1. `POST /courses/:courseId/chapters`
2. `GET /courses/:courseId/chapters`
3. `PATCH /courses/:courseId/chapters/:chapterId`
4. `DELETE /courses/:courseId/chapters/:chapterId`

Questions:

1. `POST /question-bank/questions`
2. `POST /question-bank/questions/batch`
3. `POST /question-bank/questions/upload-image`
4. `GET /question-bank/questions`
5. `GET /question-bank/questions/:id`
6. `PATCH /question-bank/questions/:id`
7. `DELETE /question-bank/questions/:id`

Attachments:

1. `POST /question-bank/questions/:id/attachments`
2. `POST /question-bank/questions/:id/attachments/upload-image`
3. `PATCH /question-bank/questions/:id/attachments/reorder`
4. `PATCH /question-bank/questions/:id/attachments/:attachmentId`
5. `DELETE /question-bank/questions/:id/attachments/:attachmentId`

Groups:

1. `POST /question-bank/groups`
2. `GET /question-bank/groups`
3. `GET /question-bank/groups/:groupId`
4. `PATCH /question-bank/groups/:groupId`
5. `DELETE /question-bank/groups/:groupId`
6. `POST /question-bank/groups/:groupId/questions/batch`
7. `PATCH /question-bank/groups/:groupId/questions/reorder`

Review:

1. `POST /question-bank/questions/:id/submit-for-review`
2. `POST /question-bank/questions/:id/approve`
3. `POST /question-bank/questions/:id/reject`
4. `POST /question-bank/questions/:id/archive`
5. `POST /question-bank/questions/:id/restore`

Important review behavior:

1. `submit-for-review` currently keeps status as `draft` in backend source and writes "Submitted for review" as review event/comment. There is no separate `pending_review` status.
2. `approve` sets status to `approved`.
3. `reject` sets status back to `draft`.
4. `archive` sets status to `archived`.
5. `restore` restores a soft-deleted/archived question to usable state.
6. Only `approved` questions are eligible for exam generation.
7. Prefer `POST /archive` over `DELETE` for instructor UI archive actions. `DELETE` is a soft-delete path and is not suitable for a normal "archive and still browse archived questions" workflow.
8. Review action request bodies must use `{ "comment": "..." }` when a note is provided. This differs from saved exam lifecycle actions, which use `{ "reason": "..." }`.

### 3.4 Exam Endpoints

Exam list and saved exams:

1. `GET /exams`
2. `GET /exams/list`
3. `GET /exams/:id`
4. `POST /exams/:id/publish`
5. `POST /exams/:id/unpublish`
6. `POST /exams/:id/archive`
7. `POST /exams/:id/export-word`

Drafts:

1. `GET /exams/drafts`
2. `GET /exams/drafts/list`
3. `GET /exams/drafts/:draftId`
4. `GET /exam-drafts`
5. `GET /exam-drafts/list`
6. `GET /exam-drafts/:draftId`
7. `POST /exams/generate-preview`

Use `/exams/drafts` for new Flutter work. The `/exam-drafts` routes are read-only aliases for compatibility; all draft mutation routes are under `/exams/drafts/...`.

Draft sections:

1. `POST /exams/drafts/:draftId/sections`
2. `PATCH /exams/drafts/:draftId/sections/reorder`
3. `PATCH /exams/drafts/:draftId/sections/:sectionId`
4. `DELETE /exams/drafts/:draftId/sections/:sectionId`

Draft items:

1. `POST /exams/drafts/:draftId/items`
2. `PATCH /exams/drafts/:draftId/items/reorder`
3. `PATCH /exams/drafts/:draftId/items/:itemId`
4. `DELETE /exams/drafts/:draftId/items/:itemId`

Save draft:

1. `POST /exams/drafts/:draftId/save`

### 3.5 Actual Export Behavior To Handle

The documentation says `export-word` returns raw HTML content, but the inspected backend source currently does:

`content: Buffer.from(content).toString('base64')`

Frontend must treat `content` as base64 for the current backend. The export workflow should:

1. Call `POST /exams/:id/export-word` with `{ "format": "html_doc", "includeAnswerKey": bool }`.
2. Decode `content` from base64 into bytes/string.
3. Save as `fileName` using `mimeType`.
4. Open or share the generated `.doc` file.

Backend tests confirm the generated Word-compatible document is escaped HTML wrapped in a `.doc` response, not a DOCX/PDF binary. Question text, options, and answer-key labels are HTML-escaped; attachment references are rendered as text/link-style entries rather than guaranteed embedded images. The UI should present this as a Word-compatible export, not as a faithful on-screen saved-paper preview.

If the backend is later changed to return raw HTML, the frontend service can detect raw content by checking whether it starts with `<html` after trimming. Until then, base64 decoding is the source-of-truth behavior.

Platform note:

1. Mobile/desktop can decode the base64 into bytes, write the `.doc` file with `path_provider`, then open/share it with `open_file` or `share_plus`.
2. Flutter web cannot use `dart:io`; if web support is required, implement a conditional export helper that uses browser Blob download instead of `File`.

### 3.6 Error Shape To Preserve

Normal NestJS errors:

```json
{
  "statusCode": 400,
  "message": "Validation message",
  "error": "Bad Request"
}
```

Shortage errors:

```json
{
  "statusCode": 400,
  "message": {
    "message": "Insufficient question pool for one or more buckets",
    "shortages": []
  },
  "error": "Bad Request"
}
```

Current `RetryHelper._resolveDioMessage` only extracts `message` when it is a string. For exam generation, the service/cubit must preserve the structured shortage list. Add a local parser in the exam service layer or enhance `RetryHelper` carefully so shortage details are not lost.

## 4. Flutter Architecture To Match Existing App

The app currently uses:

1. Dio through `CoreApiClient`.
2. `RetryHelper.execute` and `ServiceResult<T>`.
3. Manual model parsing with defensive `_parseInt`, `_parseDouble`, `_parseDateTime`.
4. Cubits with Equatable states for instructor features.
5. `RouteRequestController` and `SafeRouteCubitMixin` in long-lived feature cubits.
6. GoRouter in `lib/config/app_router.dart`.
7. ARB localization in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, generated into `lib/generated_l10n`.
8. Instructor UI theme via `InstructorColors`.
9. Responsive utilities via `context.responsive`.
10. `CustomScrollView`, `SliverAppBar`, compact gradient headers, filter panels, and grouped cards in assignment/lab/discussion screens.

The implementation should follow those patterns instead of introducing a second architecture.

## 5. Proposed File Structure

### 5.1 Models

Create:

1. `lib/models/question_bank/question_bank_enums.dart`
2. `lib/models/question_bank/course_chapter_model.dart`
3. `lib/models/question_bank/question_bank_models.dart`
4. `lib/models/question_bank/question_group_model.dart`
5. `lib/models/question_bank/question_attachment_model.dart`
6. `lib/models/question_bank/question_form_data.dart`
7. `lib/models/question_bank/question_bank_query.dart`
8. `lib/models/exams/exam_enums.dart`
9. `lib/models/exams/exam_models.dart`
10. `lib/models/exams/exam_draft_models.dart`
11. `lib/models/exams/exam_generation_form_data.dart`
12. `lib/models/exams/exam_query.dart`
13. `lib/models/exams/exam_export_model.dart`
14. `lib/models/exams/exam_generation_shortage.dart`
15. `lib/models/question_bank/question_image_upload_response.dart`

Model guidance:

1. Use Dart enums with `value`, `fromString`, and `toJson`, matching `AssignmentStatus` style.
2. Preserve backend strings exactly: `true_false`, `fill_blanks`, `weight_normalized`, `nearest_0_5`, `answer_any`.
3. Parse numeric strings safely because TypeORM decimal columns may serialize as strings.
4. Use nullable fields for backend nullable values.
5. Keep `questionId` and `id` both available because the backend returns both for questions.
6. For attachments, parse `isPrimary` from bool or integer-like values because nested responses return bool and direct attachment endpoints return `0/1`.
7. Add a dedicated `QuestionImageUploadResponse` model for `POST /question-bank/questions/upload-image`. It should parse `fileId`, `fileName`, `originalFileName`, `fileSize`, `mimeType`, `folderId`, `uploadedBy`, `uploaderName`, `createdAt`, `versionCount`, and optional `imageUrl`.
8. Treat upload response `imageUrl` as a temporary editor preview convenience. The persisted private question response currently returns neither `questionFileId` nor `questionImageUrl`, so the editor must keep the uploaded preview locally or use attachments for reloadable previews.
9. For drafts, include helper getters:
   - `isEditable`
   - `isExpired`
   - `expiresIn`
   - `hasSections`
   - `orderedSections`
   - `orderedItems`
   - `itemsForSection(sectionId)`
10. For exams, include helper getters:
   - `isDraft`
   - `isPublished`
   - `isArchived`
   - `canPublish`
   - `canUnpublish`
   - `canArchive`

### 5.2 Services

Create:

1. `lib/services/api/question_bank_service.dart`
2. `lib/services/api/exam_generator_service.dart`

`QuestionBankService` methods:

1. `getChapters(int courseId)`
2. `createChapter(int courseId, CreateChapterRequest data)`
3. `updateChapter(int courseId, int chapterId, UpdateChapterRequest data)`
4. `deleteChapter(int courseId, int chapterId)`
5. `uploadQuestionImage(File file, {ProgressCallback? onSendProgress})`
6. `createQuestion(QuestionFormData data)`
7. `bulkCreateQuestions({required int courseId, int? defaultChapterId, required List<QuestionFormData> questions})`
8. `listQuestions(QuestionBankQuery query)`
9. `getQuestion(int id)`
10. `updateQuestion(int id, QuestionFormData data)`
11. `softDeleteQuestionByDelete(int id)` only for an explicit destructive/remove-from-list action
12. `addAttachment(int questionId, QuestionAttachmentCreateRequest data)`
13. `uploadAttachmentImage(int questionId, File file, QuestionAttachmentUploadMetadata metadata)`
14. `reorderAttachments(int questionId, List<QuestionAttachmentOrderItem> items)`
15. `updateAttachment(int questionId, int attachmentId, QuestionAttachmentUpdateRequest data)`
16. `deleteAttachment(int questionId, int attachmentId)`
17. `createGroup(QuestionGroupFormData data)`
18. `listGroups(QuestionGroupQuery query)`
19. `getGroup(int groupId)`
20. `updateGroup(int groupId, QuestionGroupFormData data)`
21. `deleteGroup(int groupId)`
22. `addGroupedQuestions(int groupId, List<QuestionFormData> questions)`
23. `reorderGroupQuestions(int groupId, List<QuestionGroupOrderItem> items)`
24. `submitForReview(int questionId)`
25. `approveQuestion(int questionId, {String? comment})`
26. `rejectQuestion(int questionId, {String? comment})`
27. `archiveQuestion(int questionId, {String? comment})`
28. `restoreQuestion(int questionId, {String? comment})`

Service naming guidance:

The normal UI archive action should call `archiveQuestion`, which maps to `POST /question-bank/questions/:id/archive`. Do not wire the ordinary archive menu item to `DELETE /question-bank/questions/:id`, because that endpoint soft-deletes the row after marking it archived and normal archived list queries will not show it.

`ExamGeneratorService` methods:

1. `listExams(ExamQuery query)`
2. `listDrafts(ExamDraftQuery query)`
3. `getDraft(int draftId)`
4. `generatePreview(ExamGenerationFormData data)`
5. `createDraftSection(int draftId, DraftSectionFormData data)`
6. `updateDraftSection(int draftId, int sectionId, DraftSectionFormData data)`
7. `deleteDraftSection(int draftId, int sectionId)`
8. `reorderDraftSections(int draftId, List<DraftSectionOrderItem> items)`
9. `addDraftItem(int draftId, DraftItemFormData data)`
10. `updateDraftItem(int draftId, int itemId, DraftItemUpdateFormData data)`
11. `removeDraftItem(int draftId, int itemId)`
12. `reorderDraftItems(int draftId, List<DraftItemOrderItem> items)`
13. `saveDraft(int draftId)`
14. `getExam(int examId)`
15. `publishExam(int examId, {String? reason})`
16. `unpublishExam(int examId, {String? reason})`
17. `archiveExam(int examId, {String? reason})`
18. `exportWord(int examId, {required bool includeAnswerKey})`

Service response extraction:

1. Reuse `_extractMap`, `_extractList`, and `_extractPaginatedPayload` style from assignment/lab services.
2. Add `QuestionBankListResponse<T>` for `{ data: [], total: 0 }`.
3. Reuse `PaginatedResponse<T>` for exams and drafts.
4. Add `ExamGenerationFailure` or `ExamGenerationShortageException` equivalent data inside `ServiceError.originalError` when shortages are returned.
5. Clamp requested list limits to 100 in the Flutter query objects/services so UI paging matches backend validation and normalization.

Payload building rules for this service:

1. Strip all null/empty optional fields that the backend does not need.
2. For create-like question endpoints, omit incompatible child arrays instead of sending empty arrays.
3. For bulk create, build each nested question with explicit `courseId` and `chapterId`; do not depend on `defaultChapterId` alone.
4. For grouped batch create, build each nested question with the group's `courseId` and `chapterId` before sending because backend DTO validation requires those fields before service normalization.
5. For uploaded main question images, keep local upload preview state, but understand that reloading the question from backend will not return the main image URL until backend response is enhanced.
6. `uploadQuestionImage` returns file metadata plus optional `imageUrl`; use that URL for the current editor session only, then send the returned `fileId` as `questionFileId` in create/update payloads.
7. Prefer attachments for images that must be previewable after a reload because nested private question responses include `attachments[].imageUrl`.
8. For question update, strip `courseId` from the payload. Backend update supports `chapterId` but not moving the question to a different course.
9. After attachment create/upload/update/reorder/delete, refetch `GET /question-bank/questions/:id` before relying on `imageUrl`. Direct attachment mutation endpoints return attachment entities, while the signed `attachments[].imageUrl` is attached in private question responses.
10. Preserve explicit `null` values when the user is clearing an updateable field. Examples: clear main image with `questionFileId: null`, clear group file with `sharedFileId: null`, clear group title/prompt with `title: null` or `sharedPrompt: null`.
11. For multipart upload metadata, send `isPrimary` only when true. Omit it when false to avoid boolean-string conversion ambiguity in multipart validation.
12. Preserve `hasAttachments=false` in question list query params. This is different from multipart false metadata: list filtering needs the false value because it means "without attachments" on the backend.
13. On question update, omit `options`/`fillBlanks` when children were not edited and the question type did not change. The backend preserves existing children in that case; unnecessary resends increase accidental rewrite risk.
14. When serializing edited `options` or `fillBlanks`, map editor state to the backend DTO shape only. Option request objects may contain only `optionText` and `isCorrect`; blank request objects may contain only `blankKey`, `acceptableAnswer`, and `isCaseSensitive`. Keep `optionId`, `optionOrder`, and `blankId` only in local UI state for stable widget keys, diffing, and display.
15. Separate attachment flows clearly:
   - `uploadAttachmentImage` posts multipart `image` and is image-only.
   - `addAttachment` posts JSON with an existing `fileId` and can use `attachmentType: image | document | audio | video`; only `image` is MIME-checked as an image by the backend.
   - `updateAttachment` can clear `caption` and `altText` with explicit `null`.
16. Map note fields by endpoint family:
   - Question review endpoints send `{ "comment": value }`.
   - Saved exam lifecycle endpoints send `{ "reason": value }`.
17. For manual draft item add, omit `draftSectionId` when adding to the unsectioned area. Send `draftSectionId: null` only on draft item update when intentionally moving an existing item out of a section.

### 5.3 Cubits And States

Create:

1. `lib/bloc/instructor/question_bank/question_bank_cubit.dart`
2. `lib/bloc/instructor/question_bank/question_bank_state.dart`
3. `lib/bloc/instructor/question_bank/question_editor_cubit.dart`
4. `lib/bloc/instructor/question_bank/question_editor_state.dart`
5. `lib/bloc/instructor/question_bank/question_group_cubit.dart`
6. `lib/bloc/instructor/question_bank/question_group_state.dart`
7. `lib/bloc/instructor/exams/instructor_exams_cubit.dart`
8. `lib/bloc/instructor/exams/instructor_exams_state.dart`
9. `lib/bloc/instructor/exams/exam_generator_cubit.dart`
10. `lib/bloc/instructor/exams/exam_generator_state.dart`
11. `lib/bloc/instructor/exams/exam_draft_editor_cubit.dart`
12. `lib/bloc/instructor/exams/exam_draft_editor_state.dart`

Cubit rules:

1. Use `SafeRouteCubitMixin` for cubits that call APIs.
2. Use `RouteRequestController` for course loading, list loading, mutation, and detail loading.
3. Keep list state and editor state separate so long forms do not trigger unnecessary list reloads.
4. Never let a stale request overwrite newer filters.
5. After successful mutation, update local state immediately and refresh from backend when correctness matters.
6. Use optimistic local reorder only after the backend returns success.
7. Preserve backend error messages and shortage details.

## 6. Screen Map

### 6.1 Main Routes To Add

Add these GoRouter routes:

1. `/instructor/question-bank`
   - Screen: `InstructorQuestionBankScreen`
2. `/instructor/question-bank/create`
   - Screen: `QuestionEditorScreen`
3. `/instructor/question-bank/bulk-create`
   - Screen: `BulkQuestionCreateScreen`
4. `/instructor/question-bank/groups`
   - Screen: `QuestionGroupsScreen`
5. `/instructor/question-bank/groups/:groupId`
   - Screen: `QuestionGroupDetailScreen`
6. `/instructor/question-bank/:questionId`
   - Screen: `QuestionDetailScreen`
7. `/instructor/question-bank/:questionId/edit`
   - Screen: `QuestionEditorScreen`
8. `/instructor/exams`
   - Screen: `InstructorExamsScreen`
9. `/instructor/exams/generate`
   - Screen: `ExamGeneratorScreen`
10. `/instructor/exams/drafts/:draftId`
    - Screen: `ExamDraftReviewScreen`
11. `/instructor/exams/:examId`
    - Screen: `SavedExamDetailScreen`

Route ordering rule:

Register static question-bank child routes before `:questionId`. In GoRouter, `/instructor/question-bank/groups` and `/instructor/question-bank/bulk-create` must not be captured by the dynamic question detail route.

Add dashboard/drawer entries:

1. Drawer main menu: `Question Bank` with `Icons.inventory_2_outlined` or `Icons.quiz_outlined`.
2. Drawer main menu: `Exam Generator` with `Icons.assignment_add` or `Icons.fact_check_outlined`.
3. Quick access grid: add one compact tile for Question Bank and one for Exam Generator if layout still fits. If the grid becomes too crowded, add `Exam Generator` and keep `Question Bank` reachable from Exams screen and drawer.
4. Course management screen optional integration: add a `Questions` or `Assessments` tab only after standalone routes work.

### 6.2 Screen Grouping Recommendation

Use two top-level instructor hubs:

1. `Question Bank`
   - Question listing, authoring, review, grouping, attachments, chapters.
2. `Exam Generator`
   - Saved exams, drafts, generation wizard, draft editing, export.

Do not merge these into the old quiz management screens. The backend feature uses a different contract and is exam-authoring oriented, not the existing quiz attempt/grading flow.

## 7. Question Bank Screens

### 7.1 InstructorQuestionBankScreen

Purpose:

Instructor manages the question pool across owned courses and chapters.

Data loaded:

1. `GET /enrollments/teaching`
2. `GET /courses/:courseId/chapters` when a course is selected.
3. `GET /question-bank/questions` with filters.
4. Optional stat queries by status: call `GET /question-bank/questions?courseId=X&status=approved&limit=1`, same for draft/archived, to get totals without fetching all records.

Top UI structure:

1. `Scaffold`
2. `SafeArea`
3. `RefreshIndicator`
4. `CustomScrollView`
5. Compact `SliverAppBar`
6. Compact gradient summary header
7. Filter panel
8. Question content list
9. Floating action button for create question

Header style:

Match instructor assignments/labs:

1. Margin `16, 8, 16, 12`.
2. Border radius about `22`.
3. Use `InstructorColors.headerGradient` in light mode and `darkHeaderGradient` in dark mode.
4. Keep height compact by using a single title row plus stat chips; avoid a tall hero.
5. Title: localized `Question Bank`.
6. Subtitle: selected course code/name or localized "Manage reusable questions for your courses".
7. Icon: `Icons.inventory_2_rounded` or `Icons.quiz_rounded`.
8. Stats in responsive `Wrap`, not a fixed row.

Header stat cards:

1. Courses: number of teaching courses or 1 when selected.
2. Questions: total current filter total.
3. Approved: approved total.
4. Draft: draft total.
5. Archived: archived total.
6. Attachments: count from loaded page or optional query with `hasAttachments=true`.
7. Without attachments: optional query with `hasAttachments=false` if this stat is useful; do not compute it by dropping the query param.

Filter panel:

1. Search field: `search`.
2. Course dropdown: all courses or one course.
3. Chapter dropdown: disabled until course selected and chapters loaded.
4. Status dropdown: all, draft, approved, archived.
5. Type dropdown: all, written, mcq, true/false, fill blanks, essay.
6. Difficulty dropdown: all, easy, medium, hard.
7. Bloom dropdown: all Bloom levels.
8. Attachment filter: all, with attachments, without attachments.
9. Group filter entry point: filter by selected group or open groups screen.
10. Clear filters button.

Search contract:

Backend search only checks `questionText` with a case-insensitive `LIKE`. The search hint should say it searches question text, not answers, choices, attachments, groups, or chapter names. Image-only questions without text will not be found by search unless the instructor adds text.

Attachment filter mapping:

1. All: omit `hasAttachments`.
2. With attachments: send `hasAttachments=true`.
3. Without attachments: send `hasAttachments=false` and ensure the Dio query builder does not remove the false value.

Responsive filter behavior:

1. Mobile: search full width, filters in a bottom sheet opened by a filter button.
2. Tablet/desktop: search and dropdown chips in a wrap inside the page.
3. Avoid fixed widths below `320`.
4. Every dropdown must use ellipsis for selected labels.

Question list content:

Desktop/tablet:

1. Group by course/chapter when no specific chapter is selected.
2. Use section cards similar to assignment course cards.
3. Each question row/card shows:
   - Type icon and type label.
   - Question text preview, max 2 lines.
   - Chapter label.
   - Difficulty chip.
   - Bloom chip.
   - Status chip.
   - Attachment count.
   - Group indicator when `groups.isNotEmpty`.
   - More actions button.

Mobile:

1. Single column cards.
2. Metadata in `Wrap`.
3. Action menu through `showModernActionSheet`.

Question actions:

1. Open detail.
2. Edit.
3. Approve, only if not approved and not archived.
4. Reject to draft, only if approved or after pseudo-review action.
5. Archive.
6. Restore, only archived.
7. Duplicate locally into create form.
8. Add to group, if groups exist.
9. Archive through `POST /question-bank/questions/:id/archive` with an optional `comment` body value.
10. Use `DELETE /question-bank/questions/:id` only for an explicit remove-from-normal-lists action, because it soft-deletes the question after marking it archived.

Empty states:

1. No teaching courses: show localized no courses state.
2. No chapters for selected course: show "Create chapter" CTA.
3. No questions: show create question and bulk import CTAs.
4. Filtered empty: show clear filters CTA.

### 7.2 QuestionEditorScreen

Purpose:

Create and edit a single question with backend-valid type-specific fields.

Route modes:

1. Create: `/instructor/question-bank/create`
2. Edit: `/instructor/question-bank/:questionId/edit`

Screen structure:

1. Compact `SliverAppBar` with back button and save action.
2. Top compact gradient strip with mode title and validation progress.
3. Form body as grouped sections, not nested cards inside cards.
4. Sticky bottom action bar on mobile for Save Draft, Save And Approve.
5. Desktop/tablet: two-column layout with form on left and live preview on right.

Form sections:

1. Course and chapter
   - Create mode: course dropdown from teaching courses.
   - Edit mode: course is read-only/disabled because `PATCH /question-bank/questions/:id` does not accept `courseId`.
   - Chapter dropdown from `GET /courses/:courseId/chapters`; in edit mode load chapters for the question's existing course only.
   - Add chapter button opens `ChapterFormSheet`.
   - Chapter quick-create must send `name` plus `chapterOrder`. If the sheet is intentionally simple and does not expose manual ordering, compute the next order from loaded chapters and show it as quiet secondary metadata.
   - Chapter quick-create must not send `isActive`; only chapter edit/activation controls may send `isActive: 0|1` through the update endpoint.
   - Chapter edit/delete actions available from a chapter management sheet.
   - Chapter delete must show destructive confirmation or be disabled when the chapter has questions/groups, because backend chapter delete is a hard delete and related question-bank records cascade.
2. Question metadata
   - Question type segmented control.
   - Difficulty segmented control.
   - Bloom level dropdown or chips.
   - Status is displayed as read-only in the editor. Use explicit approve/reject/archive/restore actions outside the form so status changes go through the dedicated backend workflow endpoints.
3. Question prompt
   - Multiline question text.
   - Image upload button using `POST /question-bank/questions/upload-image`.
   - Uploaded image preview with remove action while the editor is open.
   - Backend requires at least text or an existing/new main image. In create mode that means non-empty `questionText` or a newly uploaded `questionFileId`. In edit mode, an already stored image can still satisfy backend validation even though the current response DTO does not expose its id or URL, because the update service merges the existing entity before validating.
   - If edit mode loads a question with no `questionText` and no attachment preview, show a neutral "Existing image question" placeholder instead of a broken image or an empty prompt. Do not invent or prefill `questionFileId`; omit it unless the user uploads a replacement or explicitly clears the stored main image.
4. Type-specific answer editor
   - MCQ editor.
   - True/False editor.
   - Fill blanks editor.
   - Written/Essay answer editor.
5. Hints
   - Optional multiline text.
6. Attachments
   - Create mode: show disabled note that additional attachments can be added after first save. `questionFileId` can satisfy the backend's image-question validation, but the current question response does not expose main image metadata or URL after reload.
   - Edit mode: show existing attachments, upload image, edit caption/alt text, mark primary, reorder, delete.
7. Live validation summary
   - Shows missing required fields and type-specific problems.

Validation rules to implement locally:

All question types:

1. Create mode: `courseId` required.
2. Edit mode: existing `courseId` required in state but not sent in PATCH payload.
3. `chapterId` required.
4. `questionType` required.
5. `difficulty` required.
6. `bloomLevel` required.
7. Create mode: at least one of non-empty `questionText` or newly uploaded `questionFileId`.
8. Edit mode: allow the current persisted main image to remain implicitly when `questionFileId` is omitted. If the user clears the main image, require non-empty `questionText` or a replacement upload before save.

MCQ:

1. At least 2 options.
2. At least one correct option.
3. No fill blanks.
4. Empty option text is invalid.

True/False:

1. Exactly two options: True and False.
2. Exactly one correct option.
3. No fill blanks.
4. Use radio selection for correct answer so exactly one is selected.

Fill blanks:

1. At least one blank.
2. Every `blankKey` non-empty.
3. `blankKey` values unique case-insensitively.
4. Every acceptable answer non-empty.
5. No options.
6. Optional helper can detect `{{blankKey}}` tokens in question text and suggest blanks.

Written and essay:

1. `expectedAnswerText` required.
2. No options.
3. No fill blanks.

Type change behavior:

1. Warn before clearing incompatible fields.
2. MCQ to true/false: replace option list with True/False options.
3. MCQ/true_false to fill_blanks: clear options.
4. fill_blanks to written/essay: clear blanks.
5. written/essay to MCQ: clear expected answer only after confirmation or keep in draft form but omit from payload if incompatible.

Payload building:

Create:

1. Send `courseId`, `chapterId`, `questionType`, `difficulty`, `bloomLevel`.
2. Include `questionText` only if non-empty.
3. Include `questionFileId` only if uploaded.
4. Include `expectedAnswerText` only for written/essay.
5. Include `hints` if non-empty.
6. Omit `status` or send `draft` for normal create. For Save And Approve, still create/update first and then call the approve endpoint; do not depend on create payload status to perform approval workflow.
7. Include `options` only for MCQ/true_false.
8. Include `fillBlanks` only for fill_blanks.
9. Do not send `options: []` or `fillBlanks: []` on create-like endpoints. Omit incompatible or empty arrays because nested DTO validation rejects empty arrays when those fields are present.

Edit:

1. Use `PATCH /question-bank/questions/:id`.
2. Do not send `courseId`; `UpdateQuestionBankQuestionDto` does not allow it and global validation will reject it.
3. Send `chapterId` only for a chapter in the existing course.
4. Send full compatible child arrays when replacing options/blanks.
5. If the user does not edit children and the type did not change, omit `options` and `fillBlanks`; backend tests confirm existing children are preserved when those fields are absent.
6. If replacing the main image, upload first and send the new `questionFileId`.
7. If preserving an existing main image, omit `questionFileId`; this keeps the stored server value because the backend merges the update payload with the existing entity.
8. If clearing the main image, send `questionFileId: null`, but only after the form has non-empty `questionText` or a replacement image. Clearing the hidden stored image from an image-only question without text will fail backend validation.
9. Main image preview can only be restored from local editor state unless the backend response DTO is enhanced. For images that must remain visible in detail/list screens after reload, use attachments because `attachments[].imageUrl` is returned.
10. If the type changes, treat incompatible children as intentionally replaced/cleared and rebuild the compatible arrays from the active editor controls.

Save And Approve flow:

1. Create or update question.
2. If success, call `POST /question-bank/questions/:id/approve`.
3. Return to list or detail.

### 7.3 QuestionDetailScreen

Purpose:

Instructor previews the complete private question response, including answer keys.

Data:

1. `GET /question-bank/questions/:id`
2. Optionally load chapter name from cached chapters by course.

Layout:

1. Compact app bar.
2. Header with status, type, difficulty, Bloom level.
3. Prompt preview.
   - Show text when `questionText` exists.
   - Show attachment images when available.
   - If a question was created with only `questionFileId`, show a neutral "Image question" placeholder because the current backend private response does not expose main image metadata or `questionImageUrl`.
4. Main answer panel:
   - MCQ options with correct indicators.
   - True/False selected correct answer.
   - Fill blanks table.
   - Written/Essay expected answer.
5. Attachments gallery/list.
6. Groups panel showing group title, prompt, item order.
7. Review history is not exposed by current backend response; do not create a fake timeline. Show only current status and review comment if backend later exposes it.
8. Bottom action bar:
   - Edit.
   - Approve.
   - Reject.
   - Archive.
   - Restore.
   - Add to exam draft is future/optional because draft add requires draft context.

### 7.4 BulkQuestionCreateScreen

Purpose:

Create up to 50 plain questions transactionally.

Data:

1. Teaching courses.
2. Chapters for selected course.

Layout:

1. Header with selected course, default chapter, current count.
2. Top form for batch defaults.
3. List of question mini editors.
4. Import actions:
   - Manual add row.
   - Duplicate row.
   - Remove row.
   - Reorder row.
5. Validation summary grouped by row number.
6. Submit button disabled until all rows are locally valid.

Behavior:

1. Send `POST /question-bank/questions/batch`.
2. Limit to 50 rows.
3. Use `defaultChapterId` as a UI default to fill rows, but build every nested question payload with an explicit `chapterId`.
4. If any row fails, the whole backend transaction fails. Keep all rows in the UI and show backend message.
5. On success, show count and navigate back to bank with created questions refreshed.
6. Each row payload must include `courseId` and `chapterId`, and must omit empty incompatible arrays exactly like single-question create.

### 7.5 QuestionGroupsScreen

Purpose:

Manage related question groups such as passage/case-study/multipart groups.

Data:

1. Teaching courses.
2. Chapters for selected course.
3. `GET /question-bank/groups`

Layout:

1. Compact gradient header with groups total, passage count, case study count, multipart count.
2. Filters: course and chapter are server-side. Group type is client-side on the loaded page only unless the backend adds `groupType` to `QuestionGroupQueryDto`.
3. Group cards:
   - Title or fallback "Untitled group".
   - Type chip.
   - Shared prompt preview.
   - Chapter/course.
   - Item count when `items` is returned.
   - Actions.

Actions:

1. Create group.
2. Edit group.
3. Delete group.
4. Open group detail.
5. Batch-create grouped questions.

Delete behavior:

`DELETE /question-bank/groups/:groupId` soft-deletes the group only. It does not delete the questions that were created inside the group. After deletion, refresh the group list and any visible question cards so stale group chips disappear.

Important backend limitation:

`GET /question-bank/groups` cannot currently filter by `groupType`. The compact header can show group type counts from the loaded page, or the implementation can omit those type-specific counts until the backend supports a true group type query.

Shared file handling:

There is no group-specific file upload endpoint. `sharedFileId` must reference an existing file that the instructor owns, can read, or is public. For an image-based shared prompt, the frontend may reuse the question image upload endpoint to obtain a `fileId`, but it should treat the result as a file reference only; group responses do not provide a signed preview URL for `sharedFileId`.

Backend nuance: `sharedFileId` is not MIME-restricted in `createQuestionGroup` or `updateQuestionGroup`. If the UI labels it as a visual shared prompt, enforce image MIME in Flutter before upload/selection. If the UI labels it as a generic shared file, allow non-image files and render only file metadata because no signed preview URL is returned by the group response.

### 7.6 QuestionGroupDetailScreen

Purpose:

Show group prompt/file and ordered questions inside the group.

Data:

1. `GET /question-bank/groups/:groupId`
2. `GET /question-bank/questions?groupId=:groupId&limit=100`

Layout:

1. Header with group metadata.
2. Shared prompt panel.
3. Ordered question list.
4. Add grouped questions button.
5. Reorder mode.

Behavior:

1. Reorder sends `PATCH /question-bank/groups/:groupId/questions/reorder` with the full visible ordered list of `{ questionId, itemOrder }`.
2. Batch-create sends `POST /question-bank/groups/:groupId/questions/batch`.
3. Grouped question payloads must include valid question fields plus the group's `courseId` and `chapterId` on every nested question before sending. The backend service may normalize again internally, but global DTO validation runs first and will reject missing `courseId` or `chapterId`.
4. `GET /question-bank/groups/:groupId` returns group metadata and group item ids/order, not full private question models. Use the `groupId` question list query to render question cards, then fetch `GET /question-bank/questions/:id` for full option/blank/attachment details when a row is opened.

## 8. Exam Generator Screens

### 8.1 InstructorExamsScreen

Purpose:

Main exam hub for saved exams and drafts.

Data:

1. Teaching courses.
2. `GET /exams`
3. `GET /exams/drafts`

Top UI:

1. Compact gradient header matching assignments/labs.
2. Stats:
   - Saved exams.
   - Open drafts.
   - Published.
   - Draft saved exams.
   - Archived.
   - Expiring soon drafts.
3. Action buttons:
   - Generate Exam.
   - View Drafts.
   - Question Bank.

Tabs:

1. Saved Exams.
2. Drafts.

Saved Exams tab:

1. Filters: course, status, date from, date to.
2. Exam cards:
   - Title.
   - Course.
   - Status.
   - Total marks.
   - Item count when returned; otherwise show a dash or lazy-load detail for the selected row.
   - Section count when returned; otherwise show a dash or lazy-load detail for the selected row.
   - Published/archived timestamps.
   - Actions: open, publish, unpublish, archive, export.

Drafts tab:

1. Filters: course, status, date from, date to.
2. Draft cards:
   - Title.
   - Course.
   - Status.
   - Total marks.
   - Item count only if already available from detail state; draft list responses do not load items.
   - Section count only if already available from detail state; draft list responses do not load sections.
   - Expires at / expired.
   - Generated seed.
   - Actions: open/edit if open and not expired, save, cancel unavailable because backend has no cancel endpoint.

Important:

Do not show a "cancel draft" action unless backend adds an endpoint. `cancelled` exists as a status enum but there is no controller route for it.
Do not make saved exam or draft list card layout depend on counts. The current list endpoints may omit item/section counts because relations are not loaded there.
Validate date filters before sending. Backend expects ISO date strings and rejects `dateFrom > dateTo` with `dateFrom must be before dateTo`; the UI should prevent that request and show a localized inline filter error. Never send localized display dates in query params.

### 8.2 ExamGeneratorScreen

Purpose:

Build generation request and call `POST /exams/generate-preview`.

Data:

1. Teaching courses.
2. Chapters for selected course.
3. Optional approved question counts by rule for preflight warnings.

Modes:

1. Flat rules.
2. Sectioned exam.

Top structure:

1. Compact app bar.
2. Progress header with steps:
   - Setup.
   - Rules.
   - Marks.
   - Preview.
3. Mode segmented control: Flat / Sectioned.
4. Form sections below.

Setup fields:

1. Course.
2. Title.
3. Seed optional.
4. Group selection mode hidden or locked to `independent`.

Marks fields:

1. Mark distribution mode:
   - `weight_normalized`
   - `equal`
   - `manual`
2. Rounding policy:
   - `none`
   - `nearest_0_25`
   - `nearest_0_5`
   - `nearest_1`
3. Total marks for flat mode when normalized/equal.
4. Per-section total marks for sectioned mode.

Flat rule editor:

Each rule row:

1. Chapter.
2. Count.
3. Weight per question.
4. Optional question type.
5. Optional difficulty.
6. Optional Bloom level.
7. Remove/duplicate.

Sectioned rule editor:

Each section:

1. Title.
2. Instructions.
3. Total marks.
4. Answer policy:
   - `answer_all`
   - `answer_any`
5. Required answer count when answer_any.
6. Nested rules, same fields as flat rules.
7. Reorder sections locally before generation.

Validation before generate:

1. Course required.
2. Title required.
3. At least one rule in flat mode or one section with at least one rule in sectioned mode.
4. Every rule needs chapter, count >= 1, weightPerQuestion >= 0.
5. For `answer_any`, treat `requiredAnswerCount` as required in the Flutter UI and keep it within the generated item count in that section. Backend DTOs allow it to be omitted and then store `null`, so this is a deliberate UX validation rule to avoid ambiguous exam instructions.
6. `groupSelectionMode` must be omitted or `independent`.
7. If mark mode is `manual`, explain that generation still uses each rule's `weightPerQuestion` as the generated item mark source, with rounding applied by policy. There is no per-item manual marks array in the generation request; true item-level manual marks are edited after draft creation.
8. In sectioned mode, section `totalMarks` remains required even for `manual` mark mode. Show it as the declared section total, not as a per-item distribution control in manual mode, because backend item marks still come from rule weights.
9. When mark distribution is `weight_normalized`, require the planned weighted sum to be greater than zero for every scope that will be normalized. For flat generation, this matters when `totalMarks` is sent. For sectioned generation, each section calls backend mark distribution, so each section with rules must have at least one planned selected item with `weightPerQuestion > 0`.
10. In sectioned mode, block a request where all sections have empty `rules`. Prefer requiring at least one rule per section; if the UI intentionally supports empty/instructions-only sections, it must still require at least one generated item somewhere because backend save rejects drafts with zero items.

Preflight pool check:

Before calling generate, optionally query approved questions for each rule:

`GET /question-bank/questions?courseId=X&chapterId=Y&status=approved&questionType=...&difficulty=...&bloomLevel=...&limit=1`

Use response `total` to show available count. This does not replace backend validation because duplicate selection across rules can still cause shortages.

Generate behavior:

1. Emit loading state.
2. Call `POST /exams/generate-preview`.
3. On success, navigate to `/instructor/exams/drafts/:draftId` and pass the returned draft preview.
4. On shortage error, show a structured shortage panel:
   - Section.
   - Chapter.
   - Required.
   - Available.
   - Type/difficulty/Bloom filters.
   - Quick action: open question bank filtered to that course/chapter/status approved.
5. For equal and weight-normalized modes, display the marks returned on each draft item. The backend applies rounding and final adjustments; recomputing marks from the request can show slightly wrong totals.

### 8.3 ExamDraftReviewScreen

Purpose:

Review and manually edit an open draft before saving.

Data:

1. `GET /exams/drafts/:draftId`
2. `GET /question-bank/questions?courseId=:courseId&status=approved` for add/replace dialogs.
3. Chapters for course.

Important backend response note:

`GET /exams/drafts/:draftId` loads draft items, sections, and each item's `question`, but the nested `question` is not guaranteed to contain the full private question response with options, fill blanks, and attachments. The draft review screen should render safe metadata from the draft item immediately, then fetch `GET /question-bank/questions/:questionId` for the selected item when a full answer/attachment preview is needed.

Top UI:

1. App bar with save button.
2. Compact header:
   - Draft title.
   - Status.
   - Total marks.
   - Item count.
   - Section count.
   - Expiry countdown.
3. Lock banner when `status != open` or `expiresAt <= now`.

Main layout:

Mobile:

1. Section list.
2. Each section expands to items.
3. Bottom action sheet for item actions.

Tablet/desktop:

1. Left panel: sections and item outline.
2. Right panel: selected question preview / edit form.
3. Top action toolbar.

Draft section capabilities:

1. Add section: `POST /exams/drafts/:draftId/sections`.
2. Edit section: `PATCH /exams/drafts/:draftId/sections/:sectionId`.
3. Delete section: `DELETE /exams/drafts/:draftId/sections/:sectionId`.
   - Backend does not delete the section's items. It moves items from that section to `draftSectionId: null`, then removes the section.
   - After success, refetch draft detail and render moved items under a "No section" / unsectioned group.
4. Reorder sections: `PATCH /exams/drafts/:draftId/sections/reorder`.

Draft section update payload rule:

1. Never send `title: null`; the database column is required and the DTO does not need null title clearing.
2. To clear optional `instructions`, `totalMarks`, or `requiredAnswerCount`, send explicit `null`.
3. To leave optional fields unchanged, omit them.

Draft section reorder rule:

Backend does not verify that every requested section id exists or that every section is included. Build reorder payloads only from the current draft's loaded section ids, include the full visible section list, then refetch draft detail after reorder.

Draft item capabilities:

1. Add approved question: `POST /exams/drafts/:draftId/items`.
2. Replace question: `PATCH /exams/drafts/:draftId/items/:itemId` with `replacementQuestionId`.
3. Edit marks/weight/section/order: `PATCH /exams/drafts/:draftId/items/:itemId`.
4. Remove item: `DELETE /exams/drafts/:draftId/items/:itemId`.
5. Reorder all items: `PATCH /exams/drafts/:draftId/items/reorder`.

Manual add payload rules:

1. Add to a section by sending `draftSectionId` with that section id.
2. Add to "No section" / unsectioned by omitting `draftSectionId`; do not send `draftSectionId: null` to `AddDraftItemDto`.
3. Do not send `weight` in manual add payloads. `AddDraftItemDto` does not whitelist it; the backend derives stored `weight` from `weightUnits ?? marks ?? 1`.
4. Moving an existing item to "No section" uses `PATCH /exams/drafts/:draftId/items/:itemId` with explicit `draftSectionId: null`.
5. Generation avoids duplicate question picks, but manual add does not have a backend duplicate guard. Disable already-added question IDs by default or require confirmation before adding the same approved question again.

Draft item editor fields:

1. Question selector filtered to approved questions from same course.
2. Section selector including "No section" if flat draft.
3. Weight units.
4. Marks.
5. Override reason.

Draft item marks and weights:

1. `AddDraftItemDto` accepts `weightUnits` and `marks`, but not `weight`. Backend computes the stored `weight` as `weightUnits ?? marks ?? 1`.
2. Do not send conflicting `weightUnits` and `marks` from the add-item sheet. If the instructor is adding a manually marked item, send `marks` only. If the instructor is adding a weighted item to be normalized later, send `weightUnits` only. If neither is sent, backend stores `weight = 1`, `weightUnits = 1`, and `marks = null`.
3. `UpdateDraftItemDto` accepts `weight`, `weightUnits`, and `marks` independently. The UI should keep visible controls coherent by updating the paired value intentionally, or show separate "weight units" and "marks" fields instead of implying one auto-updates the other.
4. If `draft.totalMarks` is already set on the draft, backend save uses that as saved exam `totalMarks` even if the instructor later edits item marks. Show both declared total marks and item marks sum when they diverge so the instructor can fix the draft before saving.

Override reason workflow:

1. Backend checks the target generation scope, not a stored original item rule. For an unsectioned/flat item it checks `generationRequestJson.rules`; for a sectioned item it checks `generationRequestJson.sections[section.sectionOrder].rules`.
2. If the target scope has no rules, backend does not require `overrideReason`.
3. If the target scope has rules and the add/replace question does not match any rule by chapter, question type, difficulty, and Bloom level, backend requires `overrideReason`.
4. Frontend can detect likely mismatch using `generationRequestJson` plus the target section. If mismatch and reason is empty, block locally and explain.
5. If the frontend cannot determine match, allow submit and surface backend's exact error.

Reorder rules:

1. Draft item reorder payload must include every item in the draft exactly once.
2. UI must reorder all items as one full list, even when displayed by section.
3. Draft section reorder should also send the full visible section list to avoid order-index collisions.
4. Do not send partial reorder payloads.

Remove rules:

1. Backend rejects removing the last item from an open draft.
2. UI should disable remove when draft has one item.

Save draft:

1. Call `POST /exams/drafts/:draftId/save`.
2. Backend save is idempotent.
3. On success, navigate to `/instructor/exams/:examId`.
4. Refresh exams and drafts list when returning to hub.

### 8.4 SavedExamDetailScreen

Purpose:

Show saved exam metadata and lifecycle/export actions.

Data:

1. `GET /exams/:id`

Current backend loads relations internally for `GET /exams/:id`, but the controller still maps the result to compact `ExamResponseDto`, not full item snapshots. Therefore this screen should not promise full paper preview unless the draft data was passed from save flow. For saved exams, show metadata, counts when present, lifecycle actions, and export actions. If full saved exam preview is required, backend needs a richer get exam response.

Lifecycle reason visibility:

Publish, unpublish, and archive send `{ "reason": value }` and the backend stores it as `statusReason`, but `ExamResponseDto` does not return `statusReason`. The UI should treat the reason as an action note sent to the backend, not as displayable saved metadata after refresh.

Layout:

1. Header with title, status, total marks.
2. Metadata cards:
   - Course.
   - Item count.
   - Section count.
   - Published at.
   - Archived at.
3. Lifecycle action bar:
   - Publish if draft.
   - Unpublish if published.
   - Archive if not archived.
4. Export panel:
   - Export student paper.
   - Export answer key.
5. Related draft link if navigated from a draft save flow.

Export behavior:

1. Call `exportWord`.
2. Decode base64.
3. Save file.
4. Open/share file.
5. Show success snack with file name.
6. Show error if file write/open is unavailable on platform.

### 8.5 ExamQuestionPickerSheet

Reusable sheet for draft add/replace.

Inputs:

1. Course ID.
2. Optional current section/rule constraints.
3. Optional excluded question IDs already in draft.

UI:

1. Search.
2. Chapter filter.
3. Type filter.
4. Difficulty filter.
5. Bloom filter.
6. Approved-only enforced.
7. Question cards with metadata and preview.

Selection:

1. Return selected `QuestionBankQuestion`.
2. If likely mismatch, show override reason field before returning or in draft editor.

## 9. Shared UI Components To Build

Create widgets under:

1. `lib/widgets/instructor/question_bank/`
2. `lib/widgets/instructor/exams/`
3. `lib/widgets/instructor/assessments/` for shared cross-feature components if useful.

Question bank widgets:

1. `QuestionBankHeader`
2. `QuestionBankFilterPanel`
3. `QuestionCard`
4. `QuestionStatusBadge`
5. `QuestionTypeChip`
6. `DifficultyChip`
7. `BloomLevelChip`
8. `ChapterSelector`
9. `QuestionTypeSegmentedControl`
10. `QuestionPromptEditor`
11. `QuestionImageUploader`
12. `McqOptionsEditor`
13. `TrueFalseAnswerEditor`
14. `FillBlanksEditor`
15. `WrittenAnswerEditor`
16. `QuestionAttachmentList`
17. `QuestionPreviewPanel`
18. `ChapterFormSheet`
19. `QuestionGroupCard`
20. `QuestionGroupFormSheet`

Exam widgets:

1. `ExamHubHeader`
2. `ExamFilterPanel`
3. `ExamCard`
4. `ExamDraftCard`
5. `ExamStatusBadge`
6. `ExamDraftStatusBadge`
7. `ExamGenerationModeSwitch`
8. `ExamRuleEditor`
9. `ExamSectionRuleEditor`
10. `ExamGenerationShortagePanel`
11. `DraftSectionCard`
12. `DraftItemCard`
13. `DraftItemEditorSheet`
14. `ExamQuestionPickerSheet`
15. `ExamExportSheet`
16. `ExpiryCountdownChip`

Design rules:

1. Use the existing instructor colors.
2. Use icons in buttons.
3. Keep cards at reasonable radius, mostly `14-22` where existing instructor screens already use them.
4. Avoid nested cards.
5. Use `Wrap`, `LayoutBuilder`, `Flexible`, and `Expanded` to prevent overflow.
6. Long text must use `maxLines` and `TextOverflow.ellipsis` in cards.
7. Dialogs/sheets need scroll views with safe area padding.

## 10. API Data Details By Model

### 10.1 QuestionBankQuestion

Fields:

1. `id`
2. `questionId`
3. `courseId`
4. `chapterId`
5. `questionType`
6. `difficulty`
7. `bloomLevel`
8. `status`
9. `questionText`
10. `expectedAnswerText`
11. `hints`
12. `options`
13. `fillBlanks`
14. `attachments`
15. `groups`

Important:

`questionFileId` is a create/update request field, not a field currently returned by `toPrivateResponse()`. The service also attaches `questionImageUrl` internally before mapping, but the mapper does not expose it. The Flutter response model should therefore treat both `questionFileId` and `questionImageUrl` as optional future/backend-enhancement fields, not as reliable current response data.

Question image upload response fields:

1. `fileId`
2. `fileName`
3. `originalFileName`
4. `fileSize`
5. `mimeType`
6. `folderId`
7. `uploadedBy`
8. `uploaderName`
9. `createdAt`
10. `versionCount`
11. `imageUrl`

The upload response `imageUrl` can drive the immediate editor preview, but it is not returned later as `questionImageUrl` on `GET /question-bank/questions/:id`, and the current response also omits `questionFileId`. Send `fileId` as `questionFileId` in create/update payloads, and use attachments when a reloadable signed preview is required.

Option fields:

1. `optionId`
2. `optionText`
3. `isCorrect`
4. `optionOrder`

Fill blank fields:

1. `blankId`
2. `blankKey`
3. `acceptableAnswer`
4. `isCaseSensitive`

Request DTO rule: `optionId`, `optionOrder`, and `blankId` are response-only. They are useful in Flutter response models for stable UI keys and display, but they must be stripped from create/update payload arrays. Option request payloads contain only `optionText` and `isCorrect`; fill-blank request payloads contain only `blankKey`, `acceptableAnswer`, and `isCaseSensitive`.

Attachment fields:

1. `attachmentId`
2. `fileId`
3. `attachmentType`
4. `caption`
5. `altText`
6. `displayOrder`
7. `isPrimary`
8. `storagePath`
9. `imageUrl`

Group summary fields:

1. `groupItemId`
2. `groupId`
3. `itemOrder`
4. `courseId`
5. `chapterId`
6. `title`
7. `sharedPrompt`
8. `sharedFileId`
9. `groupType`

### 10.2 CourseChapter

Fields:

1. `id`
2. `courseId`
3. `name`
4. `chapterOrder`
5. `isActive`
6. `createdAt`
7. `updatedAt`

Parsing rule:

`isActive` should be parsed from `0/1`, `true/false`, or missing into a nullable/best-effort bool for UI display. Payloads that update activation should send `0` or `1` because `UpdateChapterDto.isActive` uses integer validation.

Create/update payload rules:

1. Create chapter payload sends only DTO-supported fields: `name` and `chapterOrder`.
2. Create must include `chapterOrder >= 1`; the backend does not auto-number chapters.
3. Create must not send `isActive`; strict validation rejects that key for `CreateChapterDto`.
4. Quick-add chapter UI should calculate the next order from the currently loaded chapters: `max(chapterOrder) + 1`, defaulting to `1` when the course has no chapters.
5. Update chapter payload may send `name`, `chapterOrder`, and `isActive: 0|1`; omit unchanged fields.

### 10.3 ExamDraft

Fields:

1. `id`
2. `courseId`
3. `title`
4. `generationRequestJson`
5. `generatedBy`
6. `seed`
7. `totalMarks`
8. `markDistributionMode`
9. `roundingPolicy`
10. `status`
11. `finalizedExamId`
12. `finalizedBy`
13. `finalizedAt`
14. `failureReason`
15. `expiresAt`
16. `createdAt`
17. `updatedAt`
18. `sections`
19. `items`

### 10.4 ExamDraftSection

Fields:

1. `id`
2. `draftId`
3. `title`
4. `instructions`
5. `sectionOrder`
6. `totalMarks`
7. `answerPolicy`
8. `requiredAnswerCount`
9. `createdAt`
10. `updatedAt`

### 10.5 ExamDraftItem

Fields:

1. `id`
2. `draftId`
3. `questionId`
4. `draftSectionId`
5. `chapterId`
6. `questionType`
7. `difficulty`
8. `bloomLevel`
9. `weight`
10. `weightUnits`
11. `marks`
12. `itemOrder`
13. `overrideReason`
14. `question`

Current backend draft detail loads `item.question` as a raw shallow `QuestionBankQuestion` entity. It is not mapped through `QuestionBankPrivateResponseDto`, and it does not include full option/fill-blank/attachment relations. Draft item mutation responses may omit `question` entirely. Parse `question` defensively when present, but fetch `GET /question-bank/questions/:questionId` before rendering full private answer keys, options, fill blanks, attachment previews, or any main-image placeholder logic.

### 10.6 ExamResponse

Fields:

1. `id`
2. `courseId`
3. `title`
4. `totalMarks`
5. `status`
6. `publishedAt`
7. `archivedAt`
8. `itemCount`
9. `sectionCount`

Not returned by current `ExamResponseDto`:

1. `statusReason`
2. Saved exam item snapshots
3. Saved exam section bodies beyond counts
4. Full question answer/attachment data

## 11. State Management Details

### 11.1 QuestionBankState

State fields:

1. `isLoading`
2. `isRefreshing`
3. `isMutating`
4. `errorMessage`
5. `teachingCourses`
6. `selectedCourseId`
7. `chaptersByCourseId`
8. `questionsPage`
9. `currentPage`
10. `hasMorePages`
11. `searchQuery`
12. `chapterFilter`
13. `typeFilter`
14. `difficultyFilter`
15. `bloomFilter`
16. `statusFilter`
17. `hasAttachmentsFilter`
18. `groupFilter`
19. `stats`

Events/methods:

1. `loadInitial({int? preferredCourseId})`
2. `loadTeachingCourses()`
3. `selectCourse(int? courseId)`
4. `loadChapters(int courseId)`
5. `loadQuestions({int page = 1, bool refresh = false})`
6. `loadMore()`
7. `setSearchQuery(String query)`
8. `setFilters(...)`
9. `clearFilters()`
10. `approveQuestion(int id, {String? comment})`
11. `rejectQuestion(int id, {String? comment})`
12. `archiveQuestion(int id, {String? comment})`
13. `restoreQuestion(int id, {String? comment})`
14. `deleteQuestion(int id)`

### 11.2 QuestionEditorState

State fields:

1. `isLoading`
2. `isSaving`
3. `isUploadingImage`
4. `uploadProgress`
5. `errorMessage`
6. `loadedQuestion`
7. `formData`
8. `teachingCourses`
9. `chapters`
10. `validationErrors`
11. `dirty`

Methods:

1. `loadForCreate({int? initialCourseId, int? initialChapterId})`
2. `loadForEdit(int questionId)`
3. `selectCourse(int courseId)`
4. `loadChapters(int courseId)`
5. `createChapter(...)`
6. `updateField(...)`
7. `changeQuestionType(...)`
8. `uploadQuestionImage(File file)`
9. `saveDraft()`
10. `saveAndApprove()`
11. `validate()`

### 11.3 InstructorExamsState

State fields:

1. `isLoading`
2. `isRefreshing`
3. `isMutating`
4. `errorMessage`
5. `teachingCourses`
6. `selectedCourseId`
7. `selectedTab`
8. `examStatusFilter`
9. `draftStatusFilter`
10. `dateFrom`
11. `dateTo`
12. `examsPage`
13. `draftsPage`
14. `stats`

Methods:

1. `loadInitial()`
2. `loadExams()`
3. `loadDrafts()`
4. `selectCourse(int? courseId)`
5. `setExamFilters(...)`
6. `setDraftFilters(...)`
7. `publishExam(int id, {String? reason})`
8. `unpublishExam(int id, {String? reason})`
9. `archiveExam(int id, {String? reason})`
10. `exportExam(int id, {required bool includeAnswerKey})`

### 11.4 ExamGeneratorState

State fields:

1. `isLoading`
2. `isGenerating`
3. `errorMessage`
4. `shortages`
5. `teachingCourses`
6. `chapters`
7. `formData`
8. `preflightAvailabilityByRule`
9. `validationErrors`

Methods:

1. `loadInitial({int? initialCourseId})`
2. `selectCourse(int courseId)`
3. `addRule()`
4. `updateRule()`
5. `removeRule()`
6. `addSection()`
7. `updateSection()`
8. `removeSection()`
9. `addSectionRule()`
10. `updateSectionRule()`
11. `removeSectionRule()`
12. `runPreflightCounts()`
13. `generatePreview()`

### 11.5 ExamDraftEditorState

State fields:

1. `isLoading`
2. `isSaving`
3. `isMutating`
4. `errorMessage`
5. `draft`
6. `chapters`
7. `approvedQuestions`
8. `selectedSectionId`
9. `selectedItemId`
10. `isReorderMode`
11. `localItemOrder`
12. `localSectionOrder`

Methods:

1. `loadDraft(int draftId)`
2. `loadApprovedQuestions()`
3. `createSection(...)`
4. `updateSection(...)`
5. `deleteSection(...)`
6. `reorderSections(...)`
7. `addItem(...)`
8. `replaceItem(...)`
9. `updateItem(...)`
10. `removeItem(...)`
11. `reorderItems(...)`
12. `saveDraft()`

## 12. Localization Plan

All static UI text must be localized in:

1. `lib/l10n/app_en.arb`
2. `lib/l10n/app_ar.arb`

Then regenerate:

`flutter gen-l10n`

Localization key groups:

Question bank:

1. `questionBankTitle`
2. `questionBankSubtitle`
3. `questionBankCreateQuestion`
4. `questionBankBulkCreate`
5. `questionBankNoQuestionsTitle`
6. `questionBankNoQuestionsSubtitle`
7. `questionBankNoChaptersTitle`
8. `questionBankCreateChapter`
9. `questionBankFilters`
10. `questionBankSearchHint`
11. `questionBankAllTypes`
12. `questionBankAllDifficulties`
13. `questionBankAllBloomLevels`
14. `questionBankAllStatuses`
15. `questionBankWithAttachments`
16. `questionBankWithoutAttachments`
17. `questionBankQuestionTypeMcq`
18. `questionBankQuestionTypeTrueFalse`
19. `questionBankQuestionTypeFillBlanks`
20. `questionBankQuestionTypeWritten`
21. `questionBankQuestionTypeEssay`
22. `questionBankDifficultyEasy`
23. `questionBankDifficultyMedium`
24. `questionBankDifficultyHard`
25. `questionBankBloomRemembering`
26. `questionBankBloomUnderstanding`
27. `questionBankBloomApplying`
28. `questionBankBloomAnalyzing`
29. `questionBankBloomEvaluating`
30. `questionBankBloomCreating`
31. `questionBankStatusDraft`
32. `questionBankStatusApproved`
33. `questionBankStatusArchived`
34. `questionBankApprove`
35. `questionBankReject`
36. `questionBankArchive`
37. `questionBankRestore`
38. `questionBankExpectedAnswer`
39. `questionBankHints`
40. `questionBankOptions`
41. `questionBankFillBlanks`
42. `questionBankAttachments`
43. `questionBankGroups`
44. `questionBankValidationTextOrImageRequired`
45. `questionBankValidationMcqOptions`
46. `questionBankValidationCorrectOption`
47. `questionBankValidationTrueFalse`
48. `questionBankValidationFillBlank`
49. `questionBankValidationExpectedAnswer`

Exam generator:

1. `examGeneratorTitle`
2. `examGeneratorSubtitle`
3. `examGeneratorGenerate`
4. `examGeneratorSavedExams`
5. `examGeneratorDrafts`
6. `examGeneratorOpenDrafts`
7. `examGeneratorPublished`
8. `examGeneratorArchived`
9. `examGeneratorFlatMode`
10. `examGeneratorSectionedMode`
11. `examGeneratorRules`
12. `examGeneratorAddRule`
13. `examGeneratorAddSection`
14. `examGeneratorSectionTitle`
15. `examGeneratorInstructions`
16. `examGeneratorTotalMarks`
17. `examGeneratorCount`
18. `examGeneratorWeightPerQuestion`
19. `examGeneratorMarkDistribution`
20. `examGeneratorRoundingPolicy`
21. `examGeneratorAnswerPolicy`
22. `examGeneratorAnswerAll`
23. `examGeneratorAnswerAny`
24. `examGeneratorRequiredAnswerCount`
25. `examGeneratorPreviewDraft`
26. `examGeneratorShortageTitle`
27. `examGeneratorShortageSubtitle`
28. `examGeneratorRequired`
29. `examGeneratorAvailable`
30. `examGeneratorDraftExpired`
31. `examGeneratorDraftLocked`
32. `examGeneratorSaveDraft`
33. `examGeneratorPublishExam`
34. `examGeneratorUnpublishExam`
35. `examGeneratorArchiveExam`
36. `examGeneratorExport`
37. `examGeneratorExportStudentCopy`
38. `examGeneratorExportAnswerKey`
39. `examGeneratorOverrideReason`
40. `examGeneratorOverrideReasonRequired`

Navigation:

1. `instructorQuestionBank`
2. `instructorExamGenerator`

Avoid hardcoded strings currently visible in drawer/quick access when touching those files. Existing hardcoded `Labs`, `Quiz Management`, and `Roster` can be localized opportunistically if in the same edited area.

## 13. Responsive Design Rules

Use these concrete breakpoints through `ResponsiveUtil`:

1. Mobile: `< 600`
2. Tablet: `600-899`
3. Desktop: `>= 900`

Question bank layout:

1. Mobile: one-column cards, filters in bottom sheet.
2. Tablet: two-column card grid when enough width, inline filters wrapped.
3. Desktop: max content width around `1200`, grouped cards or list/table hybrid.

Exam generator layout:

1. Mobile: wizard sections stacked vertically, sticky bottom action bar.
2. Tablet: rules in wider cards with two fields per row.
3. Desktop: form and preview side-by-side.

Draft editor layout:

1. Mobile: accordion sections and bottom sheets.
2. Tablet/desktop: outline panel plus preview/editor panel.

Overflow prevention:

1. No fixed horizontal rows for long filters.
2. Use `Wrap` for chips.
3. Use `Flexible` around course names and question text.
4. Use `ConstrainedBox` and `LayoutBuilder` for side-by-side content.
5. Use `SingleChildScrollView` inside dialogs and bottom sheets.
6. Use `maxLines` and ellipsis in cards.
7. Keep header stats in `Wrap`, not a rigid grid.
8. Avoid large top hero heights; headers should be compact and should not hide main content on mobile.

## 14. Backend-Conscious UX Rules

1. Always load chapters after selecting course because questions require a chapter.
2. Allow creating chapters before question creation, but treat chapter create as a two-field backend payload: `name` and `chapterOrder`. Compute the next order from the loaded list when the UI does not expose manual chapter ordering.
3. Generate exams only from approved questions; show approved filter shortcuts.
4. Show draft expiry clearly. Disable edit/save once expired.
5. Do not show group selection modes other than `independent`.
6. Do not show PDF/DOCX export choices until backend supports them. Use only Word-compatible `html_doc`.
7. Do not show draft cancel action; backend has no cancel endpoint.
8. Do not show saved exam full question preview unless backend returns full saved exam detail.
9. Preserve shortage detail from generation failures.
10. Treat question list correct answers as instructor-private data. Do not reuse these models in student screens.

## 15. Implementation Phases

### Phase 1: Domain Models And Enums

Files:

1. `lib/models/question_bank/*`
2. `lib/models/exams/*`

Tasks:

1. Add enums for question type, difficulty, Bloom level, question status, attachment type, group type.
2. Add enums for exam status, draft status, mark distribution, rounding, answer policy, export format.
3. Add models for chapters, questions, options, blanks, attachments, groups.
4. Add models for exams, drafts, sections, items, export response, shortage response.
5. Add form data classes with `toJson`.
6. Add tests under `test/models/question_bank/` and `test/models/exams/`.

Acceptance:

1. All sample backend payloads parse.
2. Numeric string fields parse.
3. Null fields do not crash.
4. Enums round-trip backend strings exactly.
5. Question option/blank response models can keep `optionId`, `optionOrder`, and `blankId`, while request/form `toJson` methods strip those response-only fields.

### Phase 2: API Services

Files:

1. `lib/services/api/question_bank_service.dart`
2. `lib/services/api/exam_generator_service.dart`
3. Optional shared parser in `lib/services/api/api_payload_extractors.dart`

Tasks:

1. Implement all question bank methods.
2. Implement multipart image uploads with Dio `FormData`.
3. Implement all exam/draft methods.
4. Implement export decoding.
5. Implement shortage error preservation.
6. Add service tests with mocked Dio under `test/services/api/`.

Acceptance:

1. Endpoints use paths without `/api`.
2. Query parameters match backend DTO names.
3. Multipart field name is `image`.
4. Export handles base64 content.
5. Shortage errors can be rendered by the UI.
6. Explicit update clears preserve `null`; ordinary create payloads still omit unused optional fields.
7. Multipart metadata omits false boolean fields such as `isPrimary`.
8. Question create/update service tests verify edited `options` contain only `optionText` and `isCorrect`, and edited `fillBlanks` contain only `blankKey`, `acceptableAnswer`, and `isCaseSensitive`.

### Phase 3: State Management

Files:

1. `lib/bloc/instructor/question_bank/*`
2. `lib/bloc/instructor/exams/*`

Tasks:

1. Implement question bank list cubit.
2. Implement question editor cubit and validation.
3. Implement group cubit.
4. Implement exams hub cubit.
5. Implement exam generator cubit.
6. Implement draft editor cubit.
7. Add cubit tests for list filters, validation, generation shortage handling, draft locking, and successful mutations.

Acceptance:

1. Stale API calls cannot overwrite current state.
2. Every mutation has loading/error handling.
3. Forms block locally invalid payloads.
4. Draft editing disables correctly when expired/not open.

### Phase 4: Shared UI Components

Files:

1. `lib/widgets/instructor/question_bank/*`
2. `lib/widgets/instructor/exams/*`

Tasks:

1. Build compact headers.
2. Build filter panels.
3. Build status/type/difficulty/Bloom chips.
4. Build question cards and preview panel.
5. Build type-specific editors.
6. Build exam cards, draft cards, rule editors, shortage panel.
7. Build question picker sheet.

Acceptance:

1. Components render in light and dark themes.
2. Components do not overflow at 320px width.
3. Cards and headers match instructor assignment/lab/discussion visual language.

### Phase 5: Question Bank Screens

Files:

1. `lib/screens/instructor/question_bank/instructor_question_bank_screen.dart`
2. `lib/screens/instructor/question_bank/question_editor_screen.dart`
3. `lib/screens/instructor/question_bank/question_detail_screen.dart`
4. `lib/screens/instructor/question_bank/bulk_question_create_screen.dart`
5. `lib/screens/instructor/question_bank/question_groups_screen.dart`
6. `lib/screens/instructor/question_bank/question_group_detail_screen.dart`

Tasks:

1. Build list screen.
2. Build create/edit screen.
3. Build detail screen.
4. Build bulk create screen.
5. Build groups screens.
6. Wire routes.
7. Add navigation from drawer/quick access.

Acceptance:

1. Instructor can create a chapter.
2. Instructor can create each question type.
3. Instructor can edit and archive/restore questions.
4. Instructor can approve questions.
5. Instructor can upload question images.
6. Instructor can manage attachments after save.
7. Instructor can create groups and grouped questions.

### Phase 6: Exam Generator Screens

Files:

1. `lib/screens/instructor/exams/instructor_exams_screen.dart`
2. `lib/screens/instructor/exams/exam_generator_screen.dart`
3. `lib/screens/instructor/exams/exam_draft_review_screen.dart`
4. `lib/screens/instructor/exams/saved_exam_detail_screen.dart`

Tasks:

1. Build exams hub with saved exams and drafts tabs.
2. Build flat/sectioned generation wizard.
3. Build shortage UI.
4. Build draft review/editor.
5. Build saved exam detail/lifecycle/export.
6. Wire routes.

Acceptance:

1. Instructor can generate a draft from approved questions.
2. Shortages display clearly when pool is insufficient.
3. Instructor can add/edit/delete/reorder sections.
4. Instructor can add/replace/update/remove/reorder draft items.
5. Instructor can save draft to exam.
6. Instructor can publish/unpublish/archive saved exam.
7. Instructor can export Word-compatible file with and without answer key.

### Phase 7: Localization And Navigation Polish

Files:

1. `lib/l10n/app_en.arb`
2. `lib/l10n/app_ar.arb`
3. `lib/config/app_router.dart`
4. `lib/widgets/instructor/dashboard/instructor_drawer.dart`
5. `lib/widgets/instructor/dashboard/quick_actions_grid.dart`

Tasks:

1. Add localization keys.
2. Regenerate localization.
3. Replace static hardcoded text in new screens.
4. Add drawer and quick access entries.
5. Ensure Arabic layout does not overflow.

Acceptance:

1. `flutter gen-l10n` succeeds.
2. No hardcoded static UI text in new feature screens.
3. Navigation works from dashboard, drawer, list cards, and detail screens.

### Phase 8: Testing And QA

Run:

1. `flutter analyze`
2. `flutter test`
3. Targeted model tests.
4. Targeted service tests.
5. Targeted cubit tests.
6. Manual responsive checks on 320px mobile, 600px tablet, and desktop widths.

Manual backend integration scenarios:

1. Login as instructor.
2. Open Question Bank.
3. Select owned course.
4. Create chapter.
5. Create MCQ question.
6. Create true/false question.
7. Create fill blanks question.
8. Create essay/written question.
9. Upload image question.
10. Reload the image-only question and verify the UI handles the missing main image URL without a broken image.
11. Create a question with attachment images and verify attachment `imageUrl` previews after reload.
12. Edit question.
13. Approve question.
14. Archive and restore question.
15. Verify normal archive uses `POST /archive`, not `DELETE`, so the question remains visible through the archived filter.
16. Edit a question and verify the PATCH payload does not include `courseId`.
17. Edit an MCQ/true-false/fill-blanks question and verify the PATCH child arrays do not include `optionId`, `optionOrder`, or `blankId`.
18. Try changing chapter inside the same course only.
19. Bulk create questions and verify every nested row sends `courseId` and `chapterId` and omits empty incompatible arrays.
20. Create question group.
21. Add grouped questions and verify every nested row sends the group's `courseId` and `chapterId`.
22. Verify group type filtering is either local-only or omitted because backend does not support `groupType` query.
23. Reorder group questions using the full visible list.
24. Verify chapter delete is guarded by destructive confirmation or disabled when related content exists.
25. Delete a group and verify questions remain available while group UI refreshes.
26. Clear main image/group shared file and verify service sends explicit `null` on update.
27. Upload an attachment image with `isPrimary=false` and verify multipart metadata omits `isPrimary`.
28. Generate flat exam.
29. Generate sectioned exam.
30. Try sectioned generation with all sections empty and verify UI blocks before backend creates an unsavable empty draft.
31. Generate with `manual` mark distribution and verify generated item marks come from rule weights before draft item edits.
32. Trigger shortage and verify shortage panel.
33. Edit draft section.
34. Delete a draft section and verify its items move to the unsectioned group instead of disappearing.
35. Reorder draft sections with the full visible section list.
36. Add a draft item with marks only, verify the POST body omits `weight`, and verify backend stores `weight` and `weightUnits` from that marks value while also storing `marks`.
37. Add a draft item with weight units only, verify the POST body omits `weight`, and verify marks remain unset until edited or generated.
38. Edit item marks and verify the UI detects any divergence between declared draft total marks and item marks sum.
39. Replace draft item with matching question.
40. Replace draft item with mismatching question and override reason.
41. Reorder draft items and verify payload contains every draft item exactly once.
42. Remove item until one remains and verify UI disables further removal.
43. Save draft.
44. Save finalized draft again and verify existing exam is returned.
45. Publish exam.
46. Unpublish exam.
47. Archive exam.
48. Export student copy.
49. Export answer key.

## 16. Known Backend/Frontend Risks

1. `export-word` documentation says raw HTML, but backend returns base64. Frontend should handle current backend and optionally detect raw HTML for future compatibility.
2. Saved exam detail endpoint returns compact exam data only. Full saved paper preview needs backend expansion.
3. `submit-for-review` does not create a distinct visible status. UI should not imply a pending-review state exists.
4. `cancelled` draft status exists but no cancel endpoint exists. UI should not expose cancellation.
5. `docx` and `pdf` enum values exist but backend currently supports practical `html_doc` only.
6. Current `RetryHelper` loses structured `message` objects. Exam generation needs custom shortage parsing.
7. Draft item reorder must include all items exactly once. Partial drag reorder payloads will fail.
8. Draft expiry can change while user is on screen. UI should re-check local time and refresh draft before important mutations.
9. Question attachments direct endpoint returns `isPrimary` as `0/1`; nested question response returns bool. Parser must support both.
10. Bulk question create is transactional. UI must keep unsaved rows after failure.
11. Global DTO validation is strict. Create-like payloads must not include unknown fields, must include required nested `courseId` and `chapterId`, and must omit empty `options`/`fillBlanks` arrays.
12. Main question image metadata and signed URLs are not returned by the current private question response. The backend stores `questionFileId`, but `toPrivateResponse()` omits both `questionFileId` and `questionImageUrl`; persistent previews require attachments or a backend DTO/service enhancement.
13. Saved exam and draft list endpoints may omit item/section counts because relations are not loaded there. List cards must tolerate missing counts.
14. Draft detail nested questions may be shallow. Fetch full question details on selection before showing answer keys, options, fill blanks, or attachments.
15. Attachment, group question, draft section, and draft item reorder operations should all send full visible ordered lists to avoid unique order-index collisions. Group question and draft section reorder should also refetch and compare because backend does not validate every requested id the way draft item reorder does.
16. Question update payloads must not include `courseId`; edit mode cannot move a question between courses.
17. `DELETE /question-bank/questions/:id` soft-deletes after archiving and normal list queries will not show that row. Normal UI archive should use `POST /archive`.
18. Chapter delete is hard and cascades through related question-bank records. The frontend should not expose it as a casual action.
19. Group type filtering is not supported server-side by the current backend.
20. Group `sharedFileId` has no signed preview URL in the group response and no group-specific upload endpoint.
21. Group delete soft-deletes only the group. It does not delete the underlying questions, so UI state must not remove question cards from the bank after group deletion.
22. Update clear operations require explicit `null`; a generic "strip nulls" serializer will make clear buttons appear to do nothing.
23. Multipart boolean metadata can be ambiguous if false is sent as a string. Omit false metadata fields for upload forms.
24. Sectioned generation with no rules can produce an empty open draft that cannot be saved. The frontend should block this shape before calling the backend.
25. Deleting a draft section moves its items to `draftSectionId: null`; it does not delete them. The UI must preserve those items and render them under an unsectioned group after refresh.
26. Draft item add/update DTOs are not symmetrical. Add does not accept `weight`; update accepts `weight`, `weightUnits`, and `marks` independently. Avoid sending non-whitelisted add fields or conflicting update values, and show any declared-total versus item-sum mismatch before saving.
27. Draft nested questions are raw shallow entities, not private question responses. Full answer/attachment rendering requires an explicit question-bank detail fetch.
28. `hasAttachments=false` must be serialized, not dropped. It means "questions without attachments" and is covered by backend tests.
29. Question text/metadata-only update should omit child arrays. Existing child rows are preserved by the backend when `options`/`fillBlanks` are absent.
30. File IDs used for prompt images, attachment files, grouped prompt images, and group shared files are access-checked by the backend. The UI should surface not-owned/not-shared errors clearly. Surface non-image errors for image-only paths, but do not incorrectly reject non-image files for generic attachments or generic group shared files.
31. Export output is base64-encoded escaped HTML in a Word-compatible `.doc`; attachments are referenced in the generated document, but the frontend should not promise embedded image fidelity.
32. Draft section title cannot be cleared to `null`; optional section fields and attachment captions can be cleared with explicit `null`.
33. Question review actions use `comment`; exam lifecycle actions use `reason`.
34. Exam lifecycle `reason` is stored as `statusReason` but not returned by `ExamResponseDto`.
35. `AddDraftItemDto` does not accept `draftSectionId: null`; omit the field for unsectioned manual add.
36. Manual draft item add can duplicate an existing question unless the UI blocks or confirms it.
37. Question bank search only searches `questionText`; UI copy must not imply full-content search.
38. `/exam-drafts` routes are read-only aliases; canonical Flutter draft routes should stay under `/exams/drafts`.
39. Chapter create is not a name-only helper call. It requires `chapterOrder` and rejects `isActive`; chapter activation is update-only.
40. `weightPerQuestion: 0` passes DTO validation, but `weight_normalized` generation fails when the normalized scope's total selected weight is zero. The UI must prevent all-zero weights in normalized flat/section scopes.
41. `answer_any.requiredAnswerCount` is optional in backend DTOs, but should be required by Flutter UX if answer-any sections are exposed.
42. Override reason is target-scope based. Moving an item into another section changes which generation rules are checked; sections or unsectioned scopes with no rules do not need an override.
43. Export `format: docx/pdf` is accepted by validation but does not change the generated file today; the endpoint still returns a `.doc` HTML document.
44. Sectioned manual mark mode still requires `section.totalMarks` in the request, but generated item marks come from rule weights. The draft editor should show declared totals versus actual item mark sums when they diverge.
45. Nested option and fill-blank response IDs/order are response-only. Strict validation rejects `optionId`, `optionOrder`, and `blankId` if the editor echoes them inside question create/update child arrays.

## 17. Final Recommended Build Order

1. Models and enums.
2. QuestionBankService and ExamGeneratorService.
3. Question bank list and create/edit for single questions.
4. Approval/status workflow.
5. Exam hub and generation wizard.
6. Draft review and save.
7. Export.
8. Groups, bulk creation, and advanced attachment management.
9. Full localization and responsive polish.
10. Tests and final QA.

This order gives the instructor a working path early: create chapters, create questions, approve them, generate a draft, save it as an exam, publish/export it. Groups and bulk creation can then extend the system without blocking the core exam generation workflow.
