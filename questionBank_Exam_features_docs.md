# Question Bank And Exam Generator Frontend API Documentation

Date: 2026-05-04  
Backend root: `D:\Graduation\backend\last_backend\EduVerse_Backend`  
Audience: frontend developers implementing instructor question bank and exam generator screens.

## 1. Current Scope

The current backend scope is instructor authoring only.

Allowed role:

1. `INSTRUCTOR`

Blocked roles for these features:

1. `STUDENT`
2. `TA`
3. `ADMIN`

Every endpoint below requires:

```http
Authorization: Bearer <instructor_jwt>
Content-Type: application/json
```

Multipart upload endpoints use:

```http
Authorization: Bearer <instructor_jwt>
Content-Type: multipart/form-data
```

The backend also checks course ownership. An instructor can only manage courses assigned through:

```text
course_instructors -> course_sections -> course_id
```

## 2. Base URL And Common Conventions

Examples use:

```text
{{baseUrl}}/api
```

IDs are numeric.

Dates are ISO strings when returned or sent as query filters.

Pagination response shape for exam list APIs:

```json
{
  "data": [],
  "meta": {
    "total": 0,
    "page": 1,
    "limit": 20,
    "totalPages": 0
  }
}
```

Question bank list response shape:

```json
{
  "data": [],
  "total": 0
}
```

Common NestJS error shape:

```json
{
  "statusCode": 400,
  "message": "Validation or business error message",
  "error": "Bad Request"
}
```

For exam-generation shortages, `message` can be an object:

```json
{
  "statusCode": 400,
  "message": {
    "message": "Insufficient question pool for one or more buckets",
    "shortages": [
      {
        "section": "Part A",
        "chapterId": 2,
        "required": 5,
        "available": 3,
        "questionType": "mcq",
        "difficulty": "easy",
        "bloomLevel": null
      }
    ]
  },
  "error": "Bad Request"
}
```

## 3. Enums

Question types:

```ts
type QuestionBankType =
  | 'written'
  | 'mcq'
  | 'true_false'
  | 'fill_blanks'
  | 'essay';
```

Question difficulty:

```ts
type QuestionBankDifficulty = 'easy' | 'medium' | 'hard';
```

Bloom levels:

```ts
type BloomLevel =
  | 'remembering'
  | 'understanding'
  | 'applying'
  | 'analyzing'
  | 'evaluating'
  | 'creating';
```

Question status:

```ts
type QuestionBankStatus = 'draft' | 'approved' | 'archived';
```

Attachment type:

```ts
type QuestionAttachmentType = 'image' | 'document' | 'audio' | 'video';
```

Question group type:

```ts
type QuestionGroupType =
  | 'passage'
  | 'case_study'
  | 'image_set'
  | 'multipart'
  | 'other';
```

Exam draft status:

```ts
type ExamDraftStatus =
  | 'open'
  | 'finalized'
  | 'expired'
  | 'cancelled'
  | 'failed';
```

Exam status:

```ts
type ExamStatus = 'draft' | 'published' | 'archived';
```

Exam mark distribution mode:

```ts
type ExamMarkDistributionMode =
  | 'manual'
  | 'weight_normalized'
  | 'equal';
```

Exam rounding policy:

```ts
type ExamRoundingPolicy =
  | 'none'
  | 'nearest_0_25'
  | 'nearest_0_5'
  | 'nearest_1';
```

Exam section answer policy:

```ts
type ExamSectionAnswerPolicy = 'answer_all' | 'answer_any';
```

Exam group selection mode:

```ts
type ExamGroupSelectionMode =
  | 'independent'
  | 'keep_group_together'
  | 'exclude_grouped';
```

Important: only `independent` is implemented now. Sending `keep_group_together` or `exclude_grouped` returns `400`.

Exam export format:

```ts
type ExamExportFormat = 'html_doc' | 'docx' | 'pdf';
```

Important: current export implementation returns HTML content with Microsoft Word MIME for `html_doc`. `docx` and `pdf` are reserved by the enum, but frontend should treat `html_doc` as the supported format unless backend is extended.

## 4. Shared Response Shapes

### 4.1 Course Chapter

```ts
type CourseChapter = {
  id: number;
  courseId: number;
  name: string;
  chapterOrder: number;
  isActive: number;
  createdAt: string;
  updatedAt: string;
};
```

### 4.2 Question Private Response

This response is for instructors only and includes answer keys.

```ts
type QuestionBankPrivateResponse = {
  id: number;
  questionId: number;
  courseId: number;
  chapterId: number;
  questionType: QuestionBankType;
  difficulty: QuestionBankDifficulty;
  bloomLevel: BloomLevel;
  status: QuestionBankStatus;
  questionText: string | null;
  expectedAnswerText: string | null;
  hints: string | null;
  options: QuestionOptionResponse[];
  fillBlanks: FillBlankResponse[];
  attachments: QuestionAttachmentResponse[];
  groups: QuestionGroupSummary[];
};
```

```ts
type QuestionOptionResponse = {
  optionId: number;
  optionText: string;
  isCorrect: boolean;
  optionOrder: number;
};
```

```ts
type FillBlankResponse = {
  blankId: number;
  blankKey: string;
  acceptableAnswer: string;
  isCaseSensitive: boolean;
};
```

```ts
type QuestionAttachmentResponse = {
  attachmentId: number;
  fileId: number;
  attachmentType: QuestionAttachmentType;
  caption: string | null;
  altText: string | null;
  displayOrder: number;
  isPrimary: boolean;
  storagePath: string | null;
  imageUrl?: string | null;
};
```

Nested question responses normalize attachment fields for frontend use. Direct attachment endpoints return the attachment entity shape below.

```ts
type QuestionAttachmentEntityResponse = {
  id: number;
  questionId: number;
  fileId: number;
  attachmentType: QuestionAttachmentType;
  caption: string | null;
  altText: string | null;
  displayOrder: number;
  isPrimary: number; // 0 or 1 in direct attachment endpoint responses
  storagePath: string | null;
  createdBy: number;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
};
```

```ts
type QuestionGroupSummary = {
  groupItemId: number;
  groupId: number;
  itemOrder: number;
  courseId: number;
  chapterId: number;
  title: string | null;
  sharedPrompt: string | null;
  sharedFileId: number | null;
  groupType: QuestionGroupType;
};
```

### 4.3 Question Group Response

Group endpoints return TypeORM-shaped group objects.

```ts
type QuestionGroup = {
  id: number;
  courseId: number;
  chapterId: number;
  title: string | null;
  sharedPrompt: string | null;
  sharedFileId: number | null;
  groupType: QuestionGroupType;
  createdBy: number;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
  items?: QuestionGroupItem[];
};
```

```ts
type QuestionGroupItem = {
  id: number;
  groupId: number;
  questionId: number;
  itemOrder: number;
  createdAt: string;
};
```

### 4.4 File Upload Response

```ts
type FileResponse = {
  fileId: number;
  fileName: string;
  originalFileName: string;
  fileSize: number;
  mimeType: string;
  folderId?: number;
  uploadedBy: number;
  uploaderName?: string;
  createdAt: string;
  versionCount?: number;
  imageUrl?: string | null;
};
```

### 4.5 Exam Response

List/get/save/publish/unpublish/archive exam endpoints return a compact response:

```ts
type ExamResponse = {
  id: number;
  courseId: number;
  title: string;
  totalMarks?: number | null;
  status: ExamStatus;
  publishedAt?: string | null;
  archivedAt?: string | null;
  itemCount?: number;
  sectionCount?: number;
};
```

### 4.6 Exam Draft Response

Draft endpoints return TypeORM-shaped draft objects.

```ts
type ExamDraft = {
  id: number;
  courseId: number;
  title: string;
  generationRequestJson: Record<string, unknown>;
  generatedBy: number;
  seed: string;
  totalMarks: number | null;
  markDistributionMode: ExamMarkDistributionMode;
  roundingPolicy: ExamRoundingPolicy;
  status: ExamDraftStatus;
  finalizedExamId: number | null;
  finalizedBy: number | null;
  finalizedAt: string | null;
  failureReason: string | null;
  expiresAt: string;
  createdAt: string;
  updatedAt: string;
  sections?: ExamDraftSection[];
  items?: ExamDraftItem[];
};
```

```ts
type ExamDraftSection = {
  id: number;
  draftId: number;
  title: string;
  instructions: string | null;
  sectionOrder: number;
  totalMarks: number | null;
  answerPolicy: ExamSectionAnswerPolicy;
  requiredAnswerCount: number | null;
  createdAt: string;
  updatedAt: string;
};
```

```ts
type ExamDraftItem = {
  id: number;
  draftId: number;
  questionId: number;
  draftSectionId: number | null;
  chapterId: number;
  questionType: QuestionBankType;
  difficulty: QuestionBankDifficulty;
  bloomLevel: BloomLevel;
  weight: number;
  weightUnits: number | null;
  marks: number | null;
  itemOrder: number;
  overrideReason: string | null;
  question?: QuestionBankPrivateResponse | Record<string, unknown>;
};
```

## 5. Question Bank Feature

### 5.1 What The Feature Supports

The question bank currently supports:

1. Instructor-owned course chapters.
2. Single question creation.
3. Plain bulk question creation up to 50 questions per request.
4. Related question groups.
5. Batch creation of questions inside a group.
6. Question image upload.
7. Multiple ordered question attachments with captions and alt text.
8. Question list filters.
9. Question answer data for instructor authoring.
10. Question review/status workflow: draft, approved, archived, restored.
11. Immutable question versions internally for audit/snapshot support.

Questions must belong to an instructor-owned course and a chapter in that course.

### 5.2 Question Validation Rules

All question types require:

1. `courseId`
2. `chapterId`
3. `questionType`
4. `difficulty`
5. `bloomLevel`
6. At least one of `questionText` or `questionFileId`

`questionFileId` must reference an image file accessible to the instructor. Supported MIME types:

1. `image/jpeg`
2. `image/png`
3. `image/webp`
4. `image/gif`

MCQ:

1. Requires `options` with at least 2 options.
2. Requires at least one option with `isCorrect: true`.
3. Must not include `fillBlanks`.

True/False:

1. Requires exactly 2 options.
2. Requires exactly one option with `isCorrect: true`.
3. Must not include `fillBlanks`.

Fill blanks:

1. Requires `fillBlanks` with at least one item.
2. `blankKey` values must be unique case-insensitively.
3. Must not include `options`.

Written and essay:

1. Require `expectedAnswerText`.
2. Must not include `options`.
3. Must not include `fillBlanks`.

Update behavior:

1. Omitting `options` or `fillBlanks` preserves existing children when type still needs them.
2. Sending `options` or `fillBlanks` replaces that child collection.
3. Changing `questionType` removes incompatible child rows.

## 6. Question Bank Endpoints

### 6.1 Create Chapter

```http
POST /api/courses/:courseId/chapters
```

Required path params:

1. `courseId`

Request body:

```json
{
  "name": "Chapter 1",
  "chapterOrder": 1
}
```

Required fields:

1. `name`: string, max 200
2. `chapterOrder`: integer >= 1

Response:

```ts
CourseChapter
```

### 6.2 List Chapters

```http
GET /api/courses/:courseId/chapters
```

Response:

```ts
CourseChapter[]
```

### 6.3 Update Chapter

```http
PATCH /api/courses/:courseId/chapters/:chapterId
```

Request body:

```json
{
  "name": "Chapter 2",
  "chapterOrder": 2,
  "isActive": 1
}
```

All body fields are optional:

1. `name`: string, max 200
2. `chapterOrder`: integer >= 1
3. `isActive`: integer, usually `1` or `0`

Response:

```ts
CourseChapter
```

### 6.4 Delete Chapter

```http
DELETE /api/courses/:courseId/chapters/:chapterId
```

Response:

```json
{
  "message": "Chapter deleted successfully"
}
```

### 6.5 Upload Question Image

```http
POST /api/question-bank/questions/upload-image
Content-Type: multipart/form-data
```

Form fields:

1. `image`: required binary file.

Supported file types:

1. JPEG
2. PNG
3. WebP
4. GIF

Response:

```ts
FileResponse
```

Use returned `fileId` as:

1. `questionFileId` for image-based questions.
2. `fileId` for question attachments.

### 6.6 Create Question

```http
POST /api/question-bank/questions
```

Base request body:

```json
{
  "courseId": 34,
  "chapterId": 2,
  "questionType": "mcq",
  "difficulty": "medium",
  "bloomLevel": "understanding",
  "questionText": "Which HTTP method is idempotent?",
  "questionFileId": 88,
  "expectedAnswerText": null,
  "hints": "Think about safe retries.",
  "status": "draft",
  "options": [
    { "optionText": "GET", "isCorrect": true },
    { "optionText": "POST", "isCorrect": false }
  ],
  "fillBlanks": []
}
```

Required:

1. `courseId`
2. `chapterId`
3. `questionType`
4. `difficulty`
5. `bloomLevel`
6. `questionText` or `questionFileId`

Optional:

1. `questionText`
2. `questionFileId`
3. `expectedAnswerText`
4. `hints`
5. `status`, defaults to `draft`
6. `options`, depending on type
7. `fillBlanks`, depending on type

Response:

```ts
QuestionBankPrivateResponse
```

### 6.7 Create MCQ Example

```json
{
  "courseId": 34,
  "chapterId": 2,
  "questionType": "mcq",
  "difficulty": "easy",
  "bloomLevel": "remembering",
  "questionText": "What does HTML stand for?",
  "options": [
    { "optionText": "HyperText Markup Language", "isCorrect": true },
    { "optionText": "High Transfer Machine Language", "isCorrect": false },
    { "optionText": "Hyper Tool Multi Language", "isCorrect": false }
  ]
}
```

### 6.8 Create True/False Example

```json
{
  "courseId": 34,
  "chapterId": 2,
  "questionType": "true_false",
  "difficulty": "easy",
  "bloomLevel": "remembering",
  "questionText": "CSS is used for styling web pages.",
  "options": [
    { "optionText": "True", "isCorrect": true },
    { "optionText": "False", "isCorrect": false }
  ]
}
```

### 6.9 Create Fill-Blanks Example

```json
{
  "courseId": 34,
  "chapterId": 2,
  "questionType": "fill_blanks",
  "difficulty": "medium",
  "bloomLevel": "applying",
  "questionText": "The HTTP status code for not found is {{code}}.",
  "fillBlanks": [
    {
      "blankKey": "code",
      "acceptableAnswer": "404",
      "isCaseSensitive": false
    }
  ]
}
```

### 6.10 Create Written/Essay Example

```json
{
  "courseId": 34,
  "chapterId": 2,
  "questionType": "essay",
  "difficulty": "hard",
  "bloomLevel": "evaluating",
  "questionText": "Explain tradeoffs between server-side rendering and client-side rendering.",
  "expectedAnswerText": "A complete answer should mention SEO, first paint, interactivity, caching, server cost, and complexity.",
  "hints": "Compare performance and operational concerns."
}
```

### 6.11 Bulk Create Questions

```http
POST /api/question-bank/questions/batch
```

Request body:

```json
{
  "courseId": 34,
  "defaultChapterId": 2,
  "questions": [
    {
      "courseId": 34,
      "chapterId": 2,
      "questionType": "mcq",
      "difficulty": "easy",
      "bloomLevel": "remembering",
      "questionText": "Question 1",
      "options": [
        { "optionText": "A", "isCorrect": true },
        { "optionText": "B", "isCorrect": false }
      ]
    }
  ]
}
```

Required:

1. `courseId`
2. `questions`: array, minimum 1, maximum 50

Optional:

1. `defaultChapterId`: used for items that do not include `chapterId`.

Rules:

1. All questions are created transactionally.
2. If any question is invalid, the whole batch fails.
3. Every item must belong to the same course.

Response:

```json
{
  "count": 1,
  "created": [
    {
      "id": 101,
      "questionId": 101,
      "courseId": 34,
      "chapterId": 2,
      "questionType": "mcq",
      "difficulty": "easy",
      "bloomLevel": "remembering",
      "status": "draft",
      "questionText": "Question 1",
      "expectedAnswerText": null,
      "hints": null,
      "options": [],
      "fillBlanks": [],
      "attachments": [],
      "groups": []
    }
  ]
}
```

### 6.12 List Questions

```http
GET /api/question-bank/questions
```

Query params:

| Param | Type | Required | Notes |
|---|---:|---:|---|
| `courseId` | number | no | Restricts to owned course. |
| `chapterId` | number | no | Filter by chapter. |
| `questionType` | enum | no | `mcq`, `essay`, etc. |
| `difficulty` | enum | no | `easy`, `medium`, `hard`. |
| `bloomLevel` | enum | no | Bloom enum. |
| `status` | enum | no | `draft`, `approved`, `archived`. |
| `search` | string | no | Case-insensitive text search. |
| `hasAttachments` | boolean | no | `true` or `false`. |
| `groupId` | number | no | Questions in group. |
| `createdBy` | number | no | Creator filter. |
| `page` | number | no | Default 1. |
| `limit` | number | no | Default 20, max 100. |

Response:

```json
{
  "total": 1,
  "data": [
    {
      "id": 101,
      "questionId": 101,
      "courseId": 34,
      "chapterId": 2,
      "questionType": "mcq",
      "difficulty": "easy",
      "bloomLevel": "remembering",
      "status": "approved",
      "questionText": "What does HTML stand for?",
      "expectedAnswerText": null,
      "hints": null,
      "options": [
        {
          "optionId": 1,
          "optionText": "HyperText Markup Language",
          "isCorrect": true,
          "optionOrder": 0
        }
      ],
      "fillBlanks": [],
      "attachments": [],
      "groups": []
    }
  ]
}
```

### 6.13 Get Question

```http
GET /api/question-bank/questions/:id
```

Response:

```ts
QuestionBankPrivateResponse
```

### 6.14 Update Question

```http
PATCH /api/question-bank/questions/:id
```

All body fields are optional:

```json
{
  "chapterId": 3,
  "questionType": "mcq",
  "difficulty": "medium",
  "bloomLevel": "applying",
  "questionText": "Updated text",
  "questionFileId": null,
  "expectedAnswerText": null,
  "hints": "Updated hint",
  "status": "draft",
  "options": [
    { "optionText": "A", "isCorrect": true },
    { "optionText": "B", "isCorrect": false }
  ],
  "fillBlanks": []
}
```

Response:

```ts
QuestionBankPrivateResponse
```

### 6.15 Delete Question

```http
DELETE /api/question-bank/questions/:id
```

This archives/soft-deletes the question.

Response:

```json
{
  "message": "Question archived successfully"
}
```

### 6.16 Add Existing File As Attachment

```http
POST /api/question-bank/questions/:id/attachments
```

Request body:

```json
{
  "fileId": 88,
  "attachmentType": "image",
  "caption": "Architecture diagram",
  "altText": "Diagram showing request flow",
  "displayOrder": 0,
  "isPrimary": true
}
```

Required:

1. `fileId`

Optional:

1. `attachmentType`, defaults to `image`
2. `caption`, max 500
3. `altText`, max 500
4. `displayOrder`, integer >= 0
5. `isPrimary`

Rules:

1. File must exist and be owned/shared/public for instructor access.
2. If `attachmentType` is `image`, file MIME must be supported image type.
3. `isPrimary: true` unsets primary on other attachments for the same question.

Response:

```ts
QuestionAttachmentEntityResponse
```

### 6.17 Upload Attachment Image

```http
POST /api/question-bank/questions/:id/attachments/upload-image
Content-Type: multipart/form-data
```

Form fields:

| Field | Type | Required | Notes |
|---|---:|---:|---|
| `image` | file | yes | JPEG, PNG, WebP, GIF. |
| `caption` | string | no | Max 500. |
| `altText` | string | no | Max 500. |
| `displayOrder` | number | no | >= 0. |
| `isPrimary` | boolean | no | Marks primary image. |

Response:

```ts
QuestionAttachmentEntityResponse
```

### 6.18 Reorder Attachments

```http
PATCH /api/question-bank/questions/:id/attachments/reorder
```

Request body:

```json
{
  "items": [
    { "attachmentId": 10, "displayOrder": 0 },
    { "attachmentId": 11, "displayOrder": 1 }
  ]
}
```

Required:

1. `items`: non-empty array
2. `items[].attachmentId`
3. `items[].displayOrder`

Response:

```ts
QuestionAttachmentEntityResponse[]
```

### 6.19 Update Attachment Metadata

```http
PATCH /api/question-bank/questions/:id/attachments/:attachmentId
```

Request body:

```json
{
  "caption": "Updated caption",
  "altText": "Updated alt text",
  "displayOrder": 2,
  "isPrimary": false
}
```

All body fields are optional.

Response:

```ts
QuestionAttachmentEntityResponse
```

### 6.20 Delete Attachment

```http
DELETE /api/question-bank/questions/:id/attachments/:attachmentId
```

Response:

```json
{
  "message": "Attachment removed successfully"
}
```

### 6.21 Create Question Group

```http
POST /api/question-bank/groups
```

Request body:

```json
{
  "courseId": 34,
  "chapterId": 2,
  "title": "Read the passage and answer",
  "sharedPrompt": "Read the following text, then answer questions 1-3.",
  "sharedFileId": 90,
  "groupType": "passage"
}
```

Required:

1. `courseId`
2. `chapterId`

Optional:

1. `title`, max 255
2. `sharedPrompt`
3. `sharedFileId`
4. `groupType`, defaults to `other`

Response:

```ts
QuestionGroup
```

### 6.22 List Question Groups

```http
GET /api/question-bank/groups
```

Query params:

| Param | Type | Required | Notes |
|---|---:|---:|---|
| `courseId` | number | no | Restricts to owned course. |
| `chapterId` | number | no | Filter by chapter. |
| `page` | number | no | Default backend behavior uses 1. |
| `limit` | number | no | Service clamps to 100. |

Response:

```json
{
  "total": 1,
  "data": [
    {
      "id": 20,
      "courseId": 34,
      "chapterId": 2,
      "title": "Read the passage and answer",
      "sharedPrompt": "Read the following text...",
      "sharedFileId": 90,
      "groupType": "passage",
      "createdBy": 5,
      "createdAt": "2026-05-04T00:00:00.000Z",
      "updatedAt": "2026-05-04T00:00:00.000Z",
      "deletedAt": null
    }
  ]
}
```

### 6.23 Get Question Group

```http
GET /api/question-bank/groups/:groupId
```

Response:

```ts
QuestionGroup
```

### 6.24 Update Question Group

```http
PATCH /api/question-bank/groups/:groupId
```

Request body:

```json
{
  "title": "Updated group title",
  "sharedPrompt": "Updated prompt",
  "sharedFileId": null,
  "groupType": "case_study"
}
```

All body fields are optional.

Response:

```ts
QuestionGroup
```

### 6.25 Delete Question Group

```http
DELETE /api/question-bank/groups/:groupId
```

Deletes group metadata. It does not delete the questions.

Response:

```json
{
  "message": "Question group deleted successfully"
}
```

### 6.26 Batch Create Questions Inside Group

```http
POST /api/question-bank/groups/:groupId/questions/batch
```

Request body:

```json
{
  "questions": [
    {
      "courseId": 34,
      "chapterId": 2,
      "questionType": "mcq",
      "difficulty": "medium",
      "bloomLevel": "understanding",
      "questionText": "What is the main idea of the passage?",
      "options": [
        { "optionText": "Idea A", "isCorrect": true },
        { "optionText": "Idea B", "isCorrect": false }
      ]
    }
  ]
}
```

Required:

1. `questions`: non-empty array

Rules:

1. Group course ownership is checked.
2. Questions are created transactionally.
3. `questionFileId` is checked for ownership/shared access and image MIME.
4. If any question fails, the whole batch fails.

Response:

```json
{
  "group": {
    "id": 20,
    "courseId": 34,
    "chapterId": 2,
    "title": "Read the passage and answer",
    "sharedPrompt": "Read the following text...",
    "sharedFileId": 90,
    "groupType": "passage"
  },
  "questions": [
    {
      "id": 101,
      "questionId": 101,
      "courseId": 34,
      "chapterId": 2,
      "questionType": "mcq",
      "difficulty": "medium",
      "bloomLevel": "understanding",
      "status": "draft",
      "questionText": "What is the main idea of the passage?",
      "expectedAnswerText": null,
      "hints": null,
      "options": [],
      "fillBlanks": [],
      "attachments": [],
      "groups": [
        {
          "groupItemId": 1,
          "groupId": 20,
          "itemOrder": 0,
          "courseId": 34,
          "chapterId": 2,
          "title": "Read the passage and answer",
          "sharedPrompt": "Read the following text...",
          "sharedFileId": 90,
          "groupType": "passage"
        }
      ]
    }
  ]
}
```

### 6.27 Reorder Questions Inside Group

```http
PATCH /api/question-bank/groups/:groupId/questions/reorder
```

Request body:

```json
{
  "items": [
    { "questionId": 101, "itemOrder": 0 },
    { "questionId": 102, "itemOrder": 1 }
  ]
}
```

Response:

```ts
QuestionGroupItem[]
```

### 6.28 Question Review And Status Endpoints

Submit for review:

```http
POST /api/question-bank/questions/:id/submit-for-review
```

Response:

```ts
QuestionBankPrivateResponse
```

Approve:

```http
POST /api/question-bank/questions/:id/approve
```

Request body:

```json
{
  "comment": "Approved for exam generation"
}
```

Response:

```ts
QuestionBankPrivateResponse
```

Reject:

```http
POST /api/question-bank/questions/:id/reject
```

Request body:

```json
{
  "comment": "Needs clearer wording"
}
```

Response:

```ts
QuestionBankPrivateResponse
```

Archive:

```http
POST /api/question-bank/questions/:id/archive
```

Request body:

```json
{
  "comment": "Outdated"
}
```

Response:

```ts
QuestionBankPrivateResponse
```

Restore:

```http
POST /api/question-bank/questions/:id/restore
```

Request body:

```json
{
  "comment": "Restored after review"
}
```

Response:

```ts
QuestionBankPrivateResponse
```

Frontend note: only `approved` questions are eligible for exam generation.

## 7. Exam Generator Feature

### 7.1 What The Feature Supports

The exam generator currently supports:

1. Generating drafts from approved question bank questions.
2. Flat rule-based generation.
3. Sectioned generation.
4. Total marks and per-question marks.
5. Mark distribution by weights, equal distribution, or manual values.
6. Rounding policies.
7. Draft expiration and lifecycle.
8. Manual draft section create/update/delete/reorder.
9. Manual draft item add/update/remove/reorder.
10. Override reasons when adding/replacing questions outside the original generation rules.
11. Saving a draft idempotently to a final exam.
12. Publishing, unpublishing, and archiving exams.
13. Exporting an exam as Word-compatible HTML document content.
14. Immutable exam item snapshots for saved exams.

### 7.2 Exam Generation Rules

Generation selects only questions where:

1. `courseId` matches the exam course.
2. Question status is `approved`.
3. Chapter matches the rule.
4. Optional question type matches.
5. Optional difficulty matches.
6. Optional Bloom level matches.
7. Question is not already selected in the same draft generation.

The backend returns a shortage error if it cannot satisfy any bucket.

Drafts expire after 24 hours. Expired drafts cannot be edited or saved.

## 8. Exam Endpoints

### 8.1 List Exams

```http
GET /api/exams
GET /api/exams/list
```

Both routes call the same backend logic.

Query params:

| Param | Type | Required | Notes |
|---|---:|---:|---|
| `page` | number | no | Default 1. |
| `limit` | number | no | Default 20. |
| `courseId` | number | no | Restricts to owned course. |
| `status` | ExamStatus | no | `draft`, `published`, `archived`. |
| `dateFrom` | ISO date string | no | Inclusive created-at lower bound. |
| `dateTo` | ISO date string | no | Inclusive created-at upper bound. |

Response:

```ts
{
  data: ExamResponse[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

### 8.2 List Drafts

```http
GET /api/exams/drafts
GET /api/exams/drafts/list
GET /api/exam-drafts
GET /api/exam-drafts/list
```

All routes call the same backend logic. Prefer `/api/exams/drafts` for new frontend work.

Query params:

| Param | Type | Required | Notes |
|---|---:|---:|---|
| `page` | number | no | Default 1. |
| `limit` | number | no | Default 20. |
| `courseId` | number | no | Restricts to owned course. |
| `status` | ExamDraftStatus | no | `open`, `finalized`, `expired`, `cancelled`, `failed`. |
| `dateFrom` | ISO date string | no | Inclusive created-at lower bound. |
| `dateTo` | ISO date string | no | Inclusive created-at upper bound. |

Response:

```ts
{
  data: ExamDraft[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

### 8.3 Get Draft

```http
GET /api/exams/drafts/:draftId
GET /api/exam-drafts/:draftId
```

Prefer `/api/exams/drafts/:draftId`.

Response:

```ts
ExamDraft
```

### 8.4 Generate Exam Preview / Draft

```http
POST /api/exams/generate-preview
```

This endpoint creates an editable draft and returns the selected draft data.

Flat request body:

```json
{
  "courseId": 34,
  "title": "Web Development Midterm",
  "rules": [
    {
      "chapterId": 2,
      "count": 5,
      "weightPerQuestion": 1,
      "questionType": "mcq",
      "difficulty": "easy",
      "bloomLevel": "remembering"
    }
  ],
  "totalMarks": 50,
  "markDistributionMode": "weight_normalized",
  "roundingPolicy": "nearest_0_5",
  "groupSelectionMode": "independent",
  "seed": "optional-seed"
}
```

Sectioned request body:

```json
{
  "courseId": 34,
  "title": "Web Development Final",
  "sections": [
    {
      "title": "Part A - MCQ",
      "instructions": "Answer all questions.",
      "totalMarks": 20,
      "answerPolicy": "answer_all",
      "rules": [
        {
          "chapterId": 2,
          "count": 10,
          "weightPerQuestion": 1,
          "questionType": "mcq"
        }
      ]
    },
    {
      "title": "Part B - Essay",
      "instructions": "Answer any one question.",
      "totalMarks": 30,
      "answerPolicy": "answer_any",
      "requiredAnswerCount": 1,
      "rules": [
        {
          "chapterId": 3,
          "count": 2,
          "weightPerQuestion": 5,
          "questionType": "essay",
          "difficulty": "hard"
        }
      ]
    }
  ],
  "markDistributionMode": "weight_normalized",
  "roundingPolicy": "nearest_0_5",
  "groupSelectionMode": "independent"
}
```

Required:

1. `courseId`
2. `title`
3. At least one of `rules` or `sections`

Flat rule required fields:

1. `chapterId`
2. `count`
3. `weightPerQuestion`

Flat rule optional fields:

1. `questionType`
2. `difficulty`
3. `bloomLevel`

Section required fields:

1. `title`
2. `totalMarks`
3. `rules`

Section optional fields:

1. `instructions`
2. `answerPolicy`, defaults to backend/entity default `answer_all`
3. `requiredAnswerCount`

Top-level optional fields:

1. `totalMarks`
2. `markDistributionMode`, default `weight_normalized`
3. `roundingPolicy`, default `none`
4. `groupSelectionMode`, only `independent` supported
5. `seed`

Response:

```json
{
  "draftId": 12,
  "seed": "optional-seed-or-generated-uuid",
  "totalQuestions": 10,
  "totalWeight": 10,
  "totalMarks": 50,
  "sections": [
    {
      "id": 1,
      "draftId": 12,
      "title": "Part A - MCQ",
      "instructions": "Answer all questions.",
      "sectionOrder": 0,
      "totalMarks": 20,
      "answerPolicy": "answer_all",
      "requiredAnswerCount": null
    }
  ],
  "items": [
    {
      "id": 1,
      "draftId": 12,
      "questionId": 101,
      "draftSectionId": 1,
      "chapterId": 2,
      "questionType": "mcq",
      "difficulty": "easy",
      "bloomLevel": "remembering",
      "weight": 1,
      "weightUnits": 1,
      "marks": 2,
      "itemOrder": 0,
      "overrideReason": null
    }
  ]
}
```

### 8.5 Create Draft Section

```http
POST /api/exams/drafts/:draftId/sections
```

Request body:

```json
{
  "title": "Part C",
  "instructions": "Answer any two.",
  "totalMarks": 20,
  "answerPolicy": "answer_any",
  "requiredAnswerCount": 2
}
```

Required:

1. `title`

Optional:

1. `instructions`
2. `totalMarks`
3. `answerPolicy`
4. `requiredAnswerCount`

Response:

```ts
ExamDraftSection
```

### 8.6 Reorder Draft Sections

```http
PATCH /api/exams/drafts/:draftId/sections/reorder
```

Request body:

```json
{
  "items": [
    { "sectionId": 1, "sectionOrder": 0 },
    { "sectionId": 2, "sectionOrder": 1 }
  ]
}
```

Response:

```ts
ExamDraftSection[]
```

### 8.7 Update Draft Section

```http
PATCH /api/exams/drafts/:draftId/sections/:sectionId
```

Request body:

```json
{
  "title": "Updated Part A",
  "instructions": "Updated instructions.",
  "totalMarks": 25,
  "answerPolicy": "answer_all",
  "requiredAnswerCount": null
}
```

All body fields are optional.

Response:

```ts
ExamDraftSection
```

### 8.8 Delete Draft Section

```http
DELETE /api/exams/drafts/:draftId/sections/:sectionId
```

Response:

```json
{
  "message": "Draft section deleted successfully"
}
```

### 8.9 Add Draft Item

```http
POST /api/exams/drafts/:draftId/items
```

Request body:

```json
{
  "questionId": 101,
  "draftSectionId": 1,
  "weightUnits": 1,
  "marks": 2,
  "overrideReason": "Needed to replace a missing question from the same chapter."
}
```

Required:

1. `questionId`

Optional:

1. `draftSectionId`
2. `weightUnits`
3. `marks`
4. `overrideReason`

Rules:

1. Draft must be open and not expired.
2. Question must be approved.
3. Question must belong to the same course as the draft.
4. If the question does not match original generation constraints, `overrideReason` is required.

Response:

```ts
ExamDraftItem
```

### 8.10 Reorder Draft Items

```http
PATCH /api/exams/drafts/:draftId/items/reorder
```

Request body:

```json
{
  "items": [
    { "itemId": 1, "itemOrder": 0 },
    { "itemId": 2, "itemOrder": 1 }
  ]
}
```

Required:

1. `items`: non-empty array
2. The payload must include every item in the draft exactly once.

Response:

```ts
ExamDraftItem[]
```

### 8.11 Update Draft Item

```http
PATCH /api/exams/drafts/:draftId/items/:itemId
```

Request body:

```json
{
  "replacementQuestionId": 102,
  "weight": 2,
  "weightUnits": 2,
  "marks": 5,
  "draftSectionId": 1,
  "itemOrder": 0,
  "overrideReason": "Instructor intentionally selected a harder equivalent question."
}
```

All body fields are optional.

Rules:

1. Draft must be open and not expired.
2. Replacement question must be approved and same-course.
3. If replacement does not match original generation constraints, `overrideReason` is required.

Response:

```ts
ExamDraftItem
```

### 8.12 Remove Draft Item

```http
DELETE /api/exams/drafts/:draftId/items/:itemId
```

Rules:

1. Draft must be open and not expired.
2. Cannot remove the last item from an open draft.

Response:

```json
{
  "message": "Draft item removed successfully"
}
```

### 8.13 Save Draft To Exam

```http
POST /api/exams/drafts/:draftId/save
```

No request body.

Rules:

1. Draft must be open and not expired.
2. Draft must contain at least one item.
3. Save is idempotent. If already finalized, backend returns the existing exam.
4. Saved exam gets immutable item snapshots.

Response:

```ts
ExamResponse
```

### 8.14 Get Exam

```http
GET /api/exams/:id
```

Response:

```ts
ExamResponse
```

### 8.15 Publish Exam

```http
POST /api/exams/:id/publish
```

Request body:

```json
{
  "reason": "Ready for review"
}
```

Optional:

1. `reason`, max 1000

Response:

```ts
ExamResponse
```

### 8.16 Unpublish Exam

```http
POST /api/exams/:id/unpublish
```

Request body:

```json
{
  "reason": "Need edits before publishing"
}
```

Response:

```ts
ExamResponse
```

### 8.17 Archive Exam

```http
POST /api/exams/:id/archive
```

Request body:

```json
{
  "reason": "Old version"
}
```

Response:

```ts
ExamResponse
```

### 8.18 Export Exam Word

```http
POST /api/exams/:id/export-word
```

Request body:

```json
{
  "format": "html_doc",
  "includeAnswerKey": false
}
```

Optional:

1. `format`, default/current practical value: `html_doc`
2. `includeAnswerKey`, default false

Response:

```json
{
  "fileName": "exam-1.doc",
  "mimeType": "application/msword",
  "content": "<html><head><meta charset=\"utf-8\"></head><body>...</body></html>"
}
```

Frontend usage:

1. Create a `Blob` from `content`.
2. Use `mimeType`.
3. Download with `fileName`.

Example:

```ts
const blob = new Blob([response.content], { type: response.mimeType });
const url = URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = response.fileName;
a.click();
URL.revokeObjectURL(url);
```

## 9. Recommended Frontend Workflows

### 9.1 Question Authoring Workflow

1. Load chapters: `GET /api/courses/:courseId/chapters`.
2. Optionally upload an image: `POST /api/question-bank/questions/upload-image`.
3. Create question: `POST /api/question-bank/questions`.
4. Optionally add more attachments:
   - existing file: `POST /api/question-bank/questions/:id/attachments`
   - upload image: `POST /api/question-bank/questions/:id/attachments/upload-image`
5. Preview the returned `QuestionBankPrivateResponse`.
6. Approve when ready: `POST /api/question-bank/questions/:id/approve`.

Frontend should block or warn on invalid question-type combinations before calling the API.

### 9.2 Bulk Question Authoring Workflow

1. Build an array of up to 50 questions.
2. Validate each question locally using the rules in Section 5.2.
3. Submit once: `POST /api/question-bank/questions/batch`.
4. If the request fails, show the backend message and let the instructor fix the batch.

### 9.3 Related/Grouped Question Workflow

1. Create group: `POST /api/question-bank/groups`.
2. Add grouped questions: `POST /api/question-bank/groups/:groupId/questions/batch`.
3. Reorder if needed: `PATCH /api/question-bank/groups/:groupId/questions/reorder`.
4. Render group prompt/file at top and questions below using `groups` in question response.

### 9.4 Exam Generation Workflow

1. Ensure enough approved questions exist. List questions by `status=approved`.
2. Build generation rules or sections.
3. Generate draft: `POST /api/exams/generate-preview`.
4. Show returned sections/items for instructor review.
5. Let instructor add, replace, remove, or reorder items.
6. Save: `POST /api/exams/drafts/:draftId/save`.
7. Optionally publish: `POST /api/exams/:id/publish`.
8. Export: `POST /api/exams/:id/export-word`.

### 9.5 Draft Editing UX Rules

Disable editing when:

1. `status !== 'open'`
2. `expiresAt` is in the past

Show warnings when:

1. User tries to remove the last draft item.
2. User replaces/adds a question outside the original generation rules and no `overrideReason` is entered.
3. Reorder payload does not include all items.

## 10. Frontend Field Reference

### 10.1 Required Question Form Fields

Always show:

1. Course selector
2. Chapter selector
3. Question type
4. Difficulty
5. Bloom level
6. Question text and/or image upload

Show for MCQ:

1. Options editor
2. At least two options
3. Correct option checkbox on each option

Show for true/false:

1. Two fixed options: True and False
2. Exactly one correct option

Show for fill blanks:

1. Blank key
2. Acceptable answer
3. Case-sensitive toggle

Show for written/essay:

1. Expected answer text
2. Optional hints

### 10.2 Attachment Form Fields

1. File/image
2. Caption
3. Alt text
4. Display order
5. Primary image toggle

### 10.3 Exam Generator Form Fields

Flat generator:

1. Course
2. Title
3. Total marks
4. Mark distribution mode
5. Rounding policy
6. Rules: chapter, count, weight per question, optional type/difficulty/Bloom

Sectioned generator:

1. Course
2. Title
3. Sections
4. Per-section title
5. Per-section instructions
6. Per-section total marks
7. Per-section answer policy
8. Per-section required answer count when answer policy is `answer_any`
9. Per-section rules

## 11. Important Backend Constraints For Frontend

1. Only instructor JWTs can use these APIs.
2. Course ownership is enforced server-side.
3. Only approved questions are used by exam generation.
4. Drafts expire after 24 hours.
5. Draft save creates immutable snapshots, so later question edits do not change saved exams.
6. Student exam delivery is not implemented in this feature scope.
7. `groupSelectionMode` must currently be omitted or set to `independent`.
8. Export currently returns document content directly, not a stored file URL.
9. Question list/get responses expose correct answers because they are instructor-only.

## 12. Minimal TypeScript Client Types

```ts
export type ApiList<T> = {
  data: T[];
  total: number;
};

export type ApiPage<T> = {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
};

export type ApiMessage = {
  message: string;
};
```

Recommended frontend route modules:

1. `questionBankApi.ts`
2. `questionGroupsApi.ts`
3. `examGeneratorApi.ts`
4. `examDraftsApi.ts`
5. `examExportApi.ts`

## 13. Quick Endpoint Index

Question bank chapters:

```text
POST   /api/courses/:courseId/chapters
GET    /api/courses/:courseId/chapters
PATCH  /api/courses/:courseId/chapters/:chapterId
DELETE /api/courses/:courseId/chapters/:chapterId
```

Question bank questions:

```text
POST   /api/question-bank/questions
POST   /api/question-bank/questions/batch
POST   /api/question-bank/questions/upload-image
GET    /api/question-bank/questions
GET    /api/question-bank/questions/:id
PATCH  /api/question-bank/questions/:id
DELETE /api/question-bank/questions/:id
```

Question attachments:

```text
POST   /api/question-bank/questions/:id/attachments
POST   /api/question-bank/questions/:id/attachments/upload-image
PATCH  /api/question-bank/questions/:id/attachments/reorder
PATCH  /api/question-bank/questions/:id/attachments/:attachmentId
DELETE /api/question-bank/questions/:id/attachments/:attachmentId
```

Question groups:

```text
POST   /api/question-bank/groups
GET    /api/question-bank/groups
GET    /api/question-bank/groups/:groupId
PATCH  /api/question-bank/groups/:groupId
DELETE /api/question-bank/groups/:groupId
POST   /api/question-bank/groups/:groupId/questions/batch
PATCH  /api/question-bank/groups/:groupId/questions/reorder
```

Question review:

```text
POST /api/question-bank/questions/:id/submit-for-review
POST /api/question-bank/questions/:id/approve
POST /api/question-bank/questions/:id/reject
POST /api/question-bank/questions/:id/archive
POST /api/question-bank/questions/:id/restore
```

Exams and drafts:

```text
GET  /api/exams
GET  /api/exams/list
GET  /api/exams/drafts
GET  /api/exams/drafts/list
GET  /api/exams/drafts/:draftId
GET  /api/exam-drafts
GET  /api/exam-drafts/list
GET  /api/exam-drafts/:draftId
POST /api/exams/generate-preview
```

Draft sections:

```text
POST   /api/exams/drafts/:draftId/sections
PATCH  /api/exams/drafts/:draftId/sections/reorder
PATCH  /api/exams/drafts/:draftId/sections/:sectionId
DELETE /api/exams/drafts/:draftId/sections/:sectionId
```

Draft items:

```text
POST   /api/exams/drafts/:draftId/items
PATCH  /api/exams/drafts/:draftId/items/reorder
PATCH  /api/exams/drafts/:draftId/items/:itemId
DELETE /api/exams/drafts/:draftId/items/:itemId
```

Saved exams:

```text
POST /api/exams/drafts/:draftId/save
GET  /api/exams/:id
POST /api/exams/:id/publish
POST /api/exams/:id/unpublish
POST /api/exams/:id/archive
POST /api/exams/:id/export-word
```
