# EduVerse — Courses, Assignments & Labs Feature Documentation

> **Version:** 1.0  
> **Last Updated:** April 2026  
> **Scope:** Frontend implementation details for the Courses, Assignments, and Labs modules across all five user roles.

---

## Table of Contents

1. [Overview & Architecture](#1-overview--architecture)
2. [Global Data Models](#2-global-data-models)
3. [API Service Layer](#3-api-service-layer)
4. [Role: Student](#4-role-student)
5. [Role: Instructor](#5-role-instructor)
6. [Role: Teaching Assistant (TA)](#6-role-teaching-assistant-ta)
7. [Role: Admin (Department Head)](#7-role-admin-department-head)
8. [Role: IT Admin](#8-role-it-admin)
9. [File Upload & Google Drive Integration](#9-file-upload--google-drive-integration)
10. [Endpoint Reference Summary](#10-endpoint-reference-summary)
11. [Course Video Lectures & Material Viewing System](#11-course-video-lectures--material-viewing-system)

---

## 1. Overview & Architecture

### 1.1 Technology Stack

| Layer | Technology |
|---|---|
| Framework | React 18 + TypeScript |
| Routing | `react-router-dom` v6 |
| State / Data Fetching | `@tanstack/react-query` (Instructor), `useApi` custom hook (Student/TA) |
| HTTP Client | Centralized `ApiClient` (`src/services/api/client.ts`) |
| Notifications | `sonner` (toast) |
| Icons | `lucide-react` |
| API Base URL | Configured via `VITE_API_BASE_URL` environment variable |

### 1.2 Component Architecture

```
src/
├── services/api/
│   ├── client.ts              # ApiClient – centralized Axios wrapper
│   ├── courseService.ts        # CourseService
│   ├── assignmentService.ts    # AssignmentService
│   ├── labService.ts           # LabService
│   ├── quizService.ts          # QuizService
│   └── enrollmentService.ts    # EnrollmentService
├── types/
│   └── api.ts                  # Global TypeScript interfaces
└── pages/
    ├── student-dashboard/      # Student role
    ├── instructor-dashboard/   # Instructor role
    ├── ta-dashboard/           # TA role
    ├── admin-dashboard/        # Admin (Dept Head) role
    └── it-admin-dashboard/     # IT Admin role
```

### 1.3 Feature Availability Matrix

| Feature | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| **View Courses** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Create/Edit Courses** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Delete Courses** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **View Assignments** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Create/Edit Assignments** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Submit Assignments** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Grade Assignments** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **View Labs** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Create/Edit Labs** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Submit Labs** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Grade Labs** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Assign Staff (Instructor/TA)** | ❌ | ❌ | ❌ | ✅ | ❌ |

---

## 2. Global Data Models

### 2.1 Assignment

> Source: `src/services/api/assignmentService.ts`

```typescript
type AssignmentStatus = 'draft' | 'published' | 'closed' | 'archived';

interface Assignment {
  id: string;                           // Required – UUID
  courseId: string;                      // Required – FK to Course
  title: string;                        // Required
  description: string | null;           // Optional
  instructions: string | null;          // Optional – Markdown supported
  dueDate: string;                      // Required – ISO 8601
  maxScore: string;                     // Required – e.g. "100"
  weight: string;                       // Optional – e.g. "10"
  status: AssignmentStatus;             // Required
  submissionType: 'text'|'file'|'link'|'any'; // Required
  maxFileSize?: number;                 // Optional – bytes
  allowedFileTypes?: string[];          // Optional – e.g. ["pdf","docx"]
  latePenalty?: number;                 // Optional – 0-100 (% per day)
  createdBy: string;                    // Auto-set by backend
  createdAt?: string;                   // Auto-set
  updatedAt?: string;                   // Auto-set
  course?: { id: string; name: string; code: string };
  instructionFiles?: InstructionFile[]; // Google Drive files
}

interface InstructionFile {
  driveId: string;
  fileName: string;
  webViewLink: string;
  iframeUrl: string;
  downloadUrl: string;
}
```

### 2.2 Assignment Submission

```typescript
interface AssignmentSubmission {
  id: string;                           // Required – UUID
  assignmentId: string;                 // Required – FK
  userId: number;                       // Required – FK
  user?: {
    userId: number;
    firstName: string;
    lastName: string;
    email: string;
  };
  submissionText: string | null;        // For text submissions
  submissionLink: string | null;        // For link submissions
  fileId: number | null;                // For file submissions (legacy)
  file?: { name: string; url: string }; // Legacy file reference
  driveFile?: {                         // Google Drive file
    driveId: string;
    fileName: string;
    webViewLink: string;
    iframeUrl: string;
    downloadUrl: string;
  } | null;
  submissionStatus: 'submitted' | 'graded' | 'returned' | 'resubmit';
  score: string | null;
  feedback: string | null;
  gradedBy?: number;
  gradedAt?: string;
  isLate?: boolean | number;           // 1 or true = late
  attemptNumber?: number;
  submittedAt: string;                  // ISO 8601
}
```

### 2.3 Lab

> Source: `src/pages/instructor-dashboard/components/labs/types.ts`

```typescript
type LabStatus = 'draft' | 'published' | 'closed' | 'archived';

interface Lab {
  id: string;                           // Required – UUID
  labId?: number;                       // Backend compat
  courseId: string;                      // Required – FK
  title: string;                        // Required
  description: string | null;           // Optional
  labNumber: number | null;             // Optional – sequential
  dueDate: string | null;               // Optional – ISO 8601
  availableFrom: string | null;         // Optional – ISO 8601
  maxScore: string;                     // Required – e.g. "100"
  weight: string;                       // Optional – e.g. "10"
  status: LabStatus;                    // Required
  createdBy: string;                    // Auto-set
  createdAt?: string;
  updatedAt?: string;
  course?: { id: string; name: string; code: string };
  instructions?: LabInstruction[];
}

interface LabInstruction {
  id: string;
  instructionId?: number;
  labId: string;
  instructionText: string | null;       // Markdown text
  fileId: number | null;                // FK to Drive file
  file?: DriveFile;
  orderIndex: number;                   // Sort order
  createdAt: string;
}

interface LabFormData {
  courseId: string;       // Required
  title: string;         // Required
  description: string;   // Optional
  dueDate: string;       // Optional
  availableFrom: string; // Optional
  maxScore: string;      // Default: "100"
  weight: string;        // Default: "10"
  status: LabStatus;     // Default: "draft"
}
```

### 2.4 Lab Submission

```typescript
interface LabSubmission {
  id: string;
  submissionId?: number;
  labId: string;
  userId: number;
  user?: {
    userId: number;
    firstName: string;
    lastName: string;
    email: string;
  };
  submissionText: string | null;
  fileId: number | null;
  file?: DriveFile;
  driveFile?: DriveFileLink | null;
  submissionStatus: 'submitted' | 'graded' | 'returned' | 'resubmit';
  score: string | null;
  feedback: string | null;
  gradedBy?: number;
  gradedAt?: string;
  isLate?: boolean;
  submittedAt: string;
}
```

### 2.5 Course (Admin Model)

```typescript
interface Course {
  id: number;
  code: string;          // Required – e.g. "CS101"
  name: string;          // Required
  department: string;    // Required
  semester: string;      // Required
  credits: number;       // Required
  enrolled: number;      // Read-only
  capacity: number;      // Required
  status: string;        // "ACTIVE" | "INACTIVE" | "ARCHIVED"
  instructor: string;    // Read-only (resolved name)
  instructorId: number;  // FK to User
  taIds: number[];       // FK list to User
  taNames?: string[];    // Resolved TA names
  level: string;         // "FRESHMAN" | "SOPHOMORE" | "JUNIOR" | "SENIOR"
  prerequisites: string[];
  sectionId?: number | null;  // FK to Section
}
```

---

## 3. API Service Layer

### 3.1 AssignmentService

> Source: `src/services/api/assignmentService.ts`

| Method | Service Function | HTTP | Endpoint | Request Params | Response |
|---|---|---|---|---|---|
| Get All | `getAll(params?)` | `GET` | `/assignments` | `?courseId=&status=&limit=` | `Assignment[]` |
| Get By ID | `getById(id)` | `GET` | `/assignments/{id}` | — | `Assignment` |
| Create | `create(data)` | `POST` | `/assignments` | Body: `AssignmentFormData` (JSON) | `Assignment` |
| Update | `update(id, data)` | `PATCH` | `/assignments/{id}` | Body: partial `AssignmentFormData` | `Assignment` |
| Delete | `delete(id)` | `DELETE` | `/assignments/{id}` | — | `void` |
| Update Status | `updateStatus(id, status)` | `PATCH` | `/assignments/{id}/status` | Body: `{ status }` | `Assignment` |
| Get Submissions | `getSubmissions(assignmentId)` | `GET` | `/assignments/{id}/submissions` | — | `AssignmentSubmission[]` |
| Submit (Text) | `submit(assignmentId, data)` | `POST` | `/assignments/{id}/submit` | Body (JSON): `{ submissionText?, submissionLink? }` | `AssignmentSubmission` |
| Submit (File) | `submitFile(assignmentId, file)` | `POST` | `/assignments/{id}/submit` | **FormData**: `file` field | `AssignmentSubmission` |
| Grade | `gradeSubmission(aId, sId, score, feedback)` | `PATCH` | `/assignments/{aId}/submissions/{sId}/grade` | Body: `{ score: number, feedback: string }` | `AssignmentSubmission` |
| Upload Instructions | `uploadInstructionFile(assignmentId, file)` | `POST` | `/assignments/{id}/instructions/upload` | **FormData**: `file` field | `InstructionFile` |
| Get My Submission | `getMySubmission(assignmentId)` | `GET` | `/assignments/{id}/my-submission` | — | `AssignmentSubmission` |

### 3.2 LabService

> Source: `src/services/api/labService.ts`

| Method | Service Function | HTTP | Endpoint | Request Params | Response |
|---|---|---|---|---|---|
| Get All | `getAll(params?)` | `GET` | `/labs` | `?courseId=` | `Lab[]` |
| Get By ID | `getById(id)` | `GET` | `/labs/{id}` | — | `Lab` |
| Create | `create(data)` | `POST` | `/labs` | Body: `LabFormData` (JSON) | `Lab` |
| Update | `update(id, data)` | `PATCH` | `/labs/{id}` | Body: partial `LabFormData` | `Lab` |
| Delete | `delete(id)` | `DELETE` | `/labs/{id}` | — | `void` |
| Get Instructions | `getInstructions(labId)` | `GET` | `/labs/{id}/instructions` | — | `LabInstruction[]` |
| Add Instruction | `addInstruction(labId, data)` | `POST` | `/labs/{id}/instructions` | Body: `InstructionFormData` | `LabInstruction` |
| Upload Instruction File | `uploadInstructionFile(labId, file)` | `POST` | `/labs/{id}/instructions/upload` | **FormData**: `file` field | `LabInstruction` |
| Get Submissions | `getSubmissions(labId)` | `GET` | `/labs/{id}/submissions` | — | `LabSubmission[]` |
| Submit | `submit(labId, data)` | `POST` | `/labs/{id}/submit` | Body or **FormData** | `LabSubmission` |
| Grade Submission | `gradeSubmission(labId, submissionId, score, feedback)` | `PATCH` | `/labs/{labId}/submissions/{subId}/grade` | Body: `{ score, feedback }` | `LabSubmission` |
| Get Attendance | `getAttendance(labId)` | `GET` | `/labs/{id}/attendance` | — | `LabAttendance[]` |
| Mark Attendance | `markAttendance(labId, data)` | `POST` | `/labs/{id}/attendance` | Body: `AttendanceFormData` | `LabAttendance` |
| Get My Submission | `getMySubmission(labId)` | `GET` | `/labs/{id}/my-submission` | — | `LabSubmission` |

### 3.3 CourseService

> Source: `src/services/api/courseService.ts`

| Method | Service Function | HTTP | Endpoint | Request Params | Response |
|---|---|---|---|---|---|
| Get All | `getAll()` | `GET` | `/courses` | — | `Course[]` |
| Get By ID | `getById(id)` | `GET` | `/courses/{id}` | — | `Course` |
| Create | `create(data)` | `POST` | `/courses` | Body (JSON) | `Course` |
| Update | `update(id, data)` | `PATCH` | `/courses/{id}` | Body (JSON) | `Course` |
| Delete | `delete(id)` | `DELETE` | `/courses/{id}` | — | `void` |
| Get Structure | `getStructure(courseId)` | `GET` | `/courses/{id}/structure` | — | `CourseStructure` |
| Get Materials | `getMaterials(courseId)` | `GET` | `/courses/{id}/materials` | — | `Material[]` |
| Upload Material | `uploadMaterial(courseId, file)` | `POST` | `/courses/{id}/materials/upload` | **FormData** | `Material` |

### 3.4 EnrollmentService

> Source: `src/services/api/enrollmentService.ts`

| Method | Service Function | HTTP | Endpoint | Request Params | Response |
|---|---|---|---|---|---|
| My Courses (Student) | `getMyCourses()` | `GET` | `/enrollments/my-courses` | — | `Enrollment[]` |
| Teaching Courses | `getTeachingCourses()` | `GET` | `/enrollments/teaching` | — | `TeachingCourse[]` |
| Section Students | `getSectionStudents(sectionId)` | `GET` | `/enrollments/sections/{id}/students` | — | `Student[]` |
| Assign Instructor | — | `POST` | `/enrollments/sections/{id}/instructors` | Body: `{ userId }` | — |
| Remove Instructor | — | `DELETE` | `/enrollments/sections/{id}/instructors/{enrollmentId}` | — | — |
| Assign TA | — | `POST` | `/enrollments/sections/{id}/tas` | Body: `{ userId }` | — |
| Remove TA | — | `DELETE` | `/enrollments/sections/{id}/tas/{enrollmentId}` | — | — |
| Get Section Instructors | — | `GET` | `/enrollments/sections/{id}/instructors` | — | `Enrollment[]` |
| Get Section TAs | — | `GET` | `/enrollments/sections/{id}/tas` | — | `Enrollment[]` |

---

## 4. Role: Student

### 4.1 Dashboard Tab: **Assignments**

**Sidebar Item:** `Assignments` (icon: `FileText`)  
**Route:** `/studentdashboard/assignments`  
**Component Tree:**

```
StudentDashboard
 └─ AssignmentsPage
     ├─ AssignmentList          (default view)
     └─ AssignmentView          (when an assignment is selected)
         ├─ MySubmission        (view existing submission)
         └─ SubmissionForm      (submit new work)
             ├─ TextSubmission
             ├─ LinkSubmission
             ├─ FileUpload
             └─ DriveFileSelector
```

#### 4.1.1 AssignmentList Screen

**File:** `src/pages/student-dashboard/components/assignments/AssignmentList.tsx`

| UI Element | Description |
|---|---|
| **Search Bar** | Text input to filter by title/description |
| **Status Filter** | Buttons: `All`, `Submitted`, `Pending`, `Overdue` |
| **Stats Cards** | Total, Submitted count, Pending count, Overdue count |
| **Assignment Cards** | Grid of `AssignmentCard` components |

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load assignments | `GET /assignments?courseId={selectedCourseId}` | Via `StudentAssignmentService.getAssignments(courseId)` |

#### 4.1.2 AssignmentView Screen

**File:** `src/pages/student-dashboard/components/assignments/AssignmentView.tsx`

| UI Element | Description |
|---|---|
| **Back Button** | Returns to AssignmentList |
| **Title & Metadata** | Title, due date, max score, submission type, status badge |
| **Instructions Section** | Rendered Markdown (assignment.instructions) |
| **Instruction Files** | If `instructionFiles[]` exists: Preview iframe, Open link, Download link |
| **MySubmission** | Shows existing submission if present |
| **SubmissionForm** | Visible when no submission exists or resubmission allowed |

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load assignment detail | `GET /assignments/{id}` | `AssignmentService.getById(id)` |
| Load my submission | `GET /assignments/{id}/my-submission` | `AssignmentService.getMySubmission(id)` |

#### 4.1.3 SubmissionForm

**File:** `src/pages/student-dashboard/components/assignments/SubmissionForm.tsx`

Conditionally renders one of the following based on `assignment.submissionType`:

| Submission Type | Component | Key Fields |
|---|---|---|
| `text` | `TextSubmission` | `submissionText: string` (*Required*) – Textarea input |
| `link` | `LinkSubmission` | `submissionLink: string` (*Required*) – URL input with validation |
| `file` | `FileUpload` / `DriveFileSelector` | File picker or Google Drive selector |
| `any` | All of the above | Student can choose any method |

**API Calls on Submit:**

| Submission Type | Endpoint | Method | Body |
|---|---|---|---|
| Text | `POST /assignments/{id}/submit` | JSON | `{ submissionText: string }` |
| Link | `POST /assignments/{id}/submit` | JSON | `{ submissionLink: string }` |
| File | `POST /assignments/{id}/submit` | **FormData** | `file: File` |

#### 4.1.4 MySubmission Component

**File:** `src/pages/student-dashboard/components/assignments/MySubmission.tsx`

Displays the student's existing submission with:
- Submission text (if text type)
- Submission link (if link type) — clickable
- File preview (if file type) — iframe for Drive files, download link
- Score display: `{score} / {maxScore}`
- Feedback from instructor/TA
- Late badge (if `isLate`)
- Graded date and graded-by info

---

### 4.2 Dashboard Tab: **Labs**

**Sidebar Item:** `Labs` (icon: `Beaker`)  
**Route:** `/studentdashboard/labs`  
**Component Tree:**

```
StudentDashboard
 └─ LabInstructions
     ├─ Course Selector         (dropdown of enrolled courses)
     ├─ LabList                 (list of labs for selected course)
     └─ LabView                 (when a lab is selected)
         ├─ Lab Instructions    (text + files)
         └─ Lab Submission Form
```

#### 4.2.1 LabInstructions Container

**File:** `src/pages/student-dashboard/components/LabInstructions.tsx`

| UI Element | Description |
|---|---|
| **Course Selector** | `<select>` dropdown populated from `enrollmentService.getMyCourses()` |
| **LabList** | List of labs for the selected course |

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load enrolled courses | `GET /enrollments/my-courses` | `enrollmentService.getMyCourses()` |
| Load labs for course | `GET /labs?courseId={courseId}` | `LabService.getAll({ courseId })` |

#### 4.2.2 LabView Screen

| UI Element | Description |
|---|---|
| **Back Button** | Returns to LabList |
| **Lab Title & Metadata** | Title, lab number, due date, max score, status |
| **Instructions Tab** | Displays `LabInstruction[]` — text and/or file previews |
| **Submission Form** | Text area and/or file upload for lab submission |
| **My Submission** | Shows existing submission, score, feedback |

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load lab detail | `GET /labs/{id}` | `LabService.getById(id)` |
| Load instructions | `GET /labs/{id}/instructions` | `LabService.getInstructions(id)` |
| Load my submission | `GET /labs/{id}/my-submission` | `LabService.getMySubmission(id)` |
| Submit lab work | `POST /labs/{id}/submit` | `LabService.submit(id, data)` — JSON or FormData |

---

### 4.3 Dashboard Tab: **Courses**

**Sidebar Item:** `Courses` (icon: `BookOpen`)  
**Route:** `/studentdashboard/courses`

Students can view their enrolled courses, course materials, and course structure.

**API Calls:**

| Action | Endpoint |
|---|---|
| Load enrolled courses | `GET /enrollments/my-courses` |
| Load course structure | `GET /courses/{id}/structure` |
| Load course materials | `GET /courses/{id}/materials` |

---

## 5. Role: Instructor

### 5.1 Dashboard Navigation

**Route Base:** `/instructordashboard/:tab`  
**Available Tabs (Teaching group):** `courses`, `quizzes`, `assignments`, `labs`, `materials`, `schedule`

### 5.2 Tab: **Assignments**

**Sidebar Item:** `Assignments` (icon: `CheckSquare`)  
**Route:** `/instructordashboard/assignments`  
**Component Tree:**

```
InstructorDashboard
 └─ Section Selector (dropdown)
     └─ AssignmentListPage         (default)
     └─ AssignmentCreateEdit       (modal – create/edit)
     └─ SubmissionListView         (when "Submissions" clicked)
         └─ GradingPanel           (slide-over panel)
```

#### 5.2.1 Section Selector

A dropdown (`CustomDropdown`) at the top of the page that selects which course/section to manage assignments for.

**Data Source:** `EnrollmentService.getTeachingCourses()` → mapped to `{ value: courseId, label: "CODE - Name" }`

#### 5.2.2 AssignmentListPage

**File:** `src/pages/instructor-dashboard/components/instructor-assignments/AssignmentListPage.tsx`

| UI Element | Type | Description |
|---|---|---|
| **Search** | Text Input | Filters by title/description |
| **Status Filter** | `CustomDropdown` | Options: `All`, `Draft`, `Published`, `Closed`, `Archived` |
| **Type Filter** | `CustomDropdown` | Options: `All Types`, `Text`, `File`, `Link`, `Any` |
| **Create Button** | Button (`+ Create Assignment`) | Opens `AssignmentCreateEdit` modal |
| **Assignment Cards** | Grid (3 cols) | Each card shows: title, description, status badge, due date, type, max score |

**Card Actions:**

| Button | Icon | Action |
|---|---|---|
| **Edit** | `Edit2` | Opens `AssignmentCreateEdit` in edit mode |
| **Delete** | `Trash2` | Triggers `ConfirmDialog` → calls `DELETE /assignments/{id}` |
| **Submissions** | `Eye` | Navigates to `SubmissionListView` |
| **Publish/Close/Archive** | `Send`/`Archive` | Calls `PATCH /assignments/{id}/status` with next status |

**Status Transition Flow:**
```
draft → published → closed → archived
```

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load assignments | `GET /assignments?courseId={courseId}` | `AssignmentService.getAll({ courseId })` |
| Delete assignment | `DELETE /assignments/{id}` | `AssignmentService.delete(id)` |
| Change status | `PATCH /assignments/{id}/status` | `AssignmentService.updateStatus(id, newStatus)` |

#### 5.2.3 AssignmentCreateEdit Modal

**File:** `src/pages/instructor-dashboard/components/instructor-assignments/AssignmentCreateEdit.tsx`

**Form Fields:**

| Field | Type | Required | Default | Validation |
|---|---|---|---|---|
| `title` | `string` (text input) | ✅ **Yes** | `""` | Non-empty |
| `description` | `string` (textarea, 3 rows) | ❌ No | `""` | — |
| `instructions` | `string` (textarea, 6 rows, monospace) | ❌ No | `""` | Markdown supported |
| `dueDate` | `string` (datetime-local) | ✅ **Yes** | `""` | Must be set |
| `maxScore` | `number` (number input) | ✅ **Yes** | `100` | Must be > 0 |
| `weight` | `number` (number input, %) | ❌ No | `10` | — |
| `submissionType` | `'text'\|'file'\|'link'\|'any'` (button group) | ✅ **Yes** | `'file'` | — |
| `maxFileSize` | `number` (MB input) | ❌ No | `10 MB` | Only when type = `file` or `any`; > 0 |
| `allowedFileTypes` | `string` (comma-separated text) | ❌ No | `[]` | Only when type = `file` or `any` |
| `latePenalty` | `number` (0-100) | ❌ No | `0` | Between 0 and 100 |
| `status` | `AssignmentStatus` (button group) | ✅ **Yes** | `'draft'` | — |

**Instruction File Upload:**
- **Edit mode:** Shows existing instruction files with Preview/Open/Download buttons + `InstructionUpload` component for adding more
- **Create mode:** File picker (`.pdf,.doc,.docx,.txt,.ppt,.pptx`), files queued and uploaded after assignment creation

**API Calls:**

| Action | Endpoint | Method | Body |
|---|---|---|---|
| Create | `POST /assignments` | JSON | `AssignmentFormData` |
| Update | `PATCH /assignments/{id}` | JSON | Partial `AssignmentFormData` |
| Upload instruction | `POST /assignments/{id}/instructions/upload` | **FormData** | `file` |

#### 5.2.4 SubmissionListView

**File:** `src/pages/instructor-dashboard/components/instructor-assignments/SubmissionListView.tsx`

| UI Element | Type | Description |
|---|---|---|
| **Search** | Text Input | Filter by student name/email |
| **Status Filter** | `<select>` | `All`, `Graded Only`, `Ungraded Only` |
| **Late Filter** | `<select>` | `All`, `Late Only`, `On Time Only` |
| **Sort Headers** | Clickable | Sortable by: Student, Date, Score, Status (asc/desc) |
| **Submission Rows** | Table/Cards | Student name, email, submitted date, attempt #, late badge, score, graded status |

**Row Actions:**

| Button | Action |
|---|---|
| **View** (`Eye` icon) | Opens submission detail (same as GradingPanel but read-only) |
| **Grade / Edit Grade** | Opens `GradingPanel` slide-over |

**API Call:**

| Action | Endpoint |
|---|---|
| Load submissions | `GET /assignments/{id}/submissions` |

#### 5.2.5 GradingPanel (Slide-Over)

**File:** `src/pages/instructor-dashboard/components/instructor-assignments/GradingPanel.tsx`

| Section | Content |
|---|---|
| **Student Info** | Name, email, submitted date, attempt number, late badge |
| **Submission Content** | Text (pre-formatted), Link (clickable), File (iframe preview + Open in Drive + Download) |
| **Score Input** | Number input (0 to `maxScore`, step 0.5) — **Required** |
| **Late Penalty Calculation** | Auto-calculated if `isLate && latePenalty > 0`: shows Original, Penalty %, Final Score |
| **Feedback** | Textarea (6 rows) — **Optional** |
| **Previously Graded Info** | Shows `gradedAt` date if re-grading |

**API Call:**

| Action | Endpoint | Method | Body |
|---|---|---|---|
| Save Grade | `PATCH /assignments/{aId}/submissions/{sId}/grade` | JSON | `{ score: number, feedback: string }` |

---

### 5.3 Tab: **Labs**

**Sidebar Item:** `Labs` (icon: `Beaker`)  
**Route:** `/instructordashboard/labs`  
**Component:** `LabsPage`  
**Component Tree:**

```
InstructorDashboard
 └─ LabsPage
     ├─ Lab List Table           (with filters)
     ├─ LabCreate Modal          (create new lab)
     ├─ LabEdit Modal            (edit existing lab)
     ├─ InstructionManager       (add/view instructions)
     ├─ SubmissionList           (view submissions)
     └─ GradingModal             (grade a submission)
```

#### 5.3.1 LabCreate Modal

**File:** `src/pages/instructor-dashboard/components/labs/LabCreate.tsx`

**Form Fields:**

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `courseId` | `string` (select dropdown) | ✅ **Yes** | `""` | From teaching courses list |
| `title` | `string` (text input) | ✅ **Yes** | `""` | — |
| `description` | `string` (textarea, 3 rows) | ❌ No | `""` | — |
| `availableFrom` | `string` (datetime-local) | ❌ No | `""` | — |
| `dueDate` | `string` (datetime-local) | ❌ No | `""` | — |
| `maxScore` | `string` (number input) | ❌ No | `"100"` | — |
| `weight` | `string` (number input) | ❌ No | `"10"` | — |
| `status` | `LabStatus` (select) | ❌ No | `"draft"` | Options: Draft, Published, Closed |

**API Call:**

| Action | Endpoint | Body |
|---|---|---|
| Save | `POST /labs` | `LabFormData` (JSON) |

#### 5.3.2 Lab Management Actions

| Action | Endpoint |
|---|---|
| Load all labs | `GET /labs` |
| Delete lab | `DELETE /labs/{id}` |
| Update lab | `PATCH /labs/{id}` |
| Get instructions | `GET /labs/{id}/instructions` |
| Add instruction | `POST /labs/{id}/instructions` |
| Upload instruction file | `POST /labs/{id}/instructions/upload` (FormData) |
| Get submissions | `GET /labs/{id}/submissions` |
| Grade submission | `PATCH /labs/{labId}/submissions/{subId}/grade` |
| Get attendance | `GET /labs/{id}/attendance` |
| Mark attendance | `POST /labs/{id}/attendance` |

---

### 5.4 Tab: **Courses**

**Sidebar Item:** `Courses` (icon: `BookOpen`)  
**Route:** `/instructordashboard/courses`  
**Component:** `CoursesPage`

Displays the instructor's teaching courses (from `EnrollmentService.getTeachingCourses()`). Each course card shows:
- Course code, name, semester
- Student count, enrolled count, capacity
- Average grade, attendance rate
- Links to drill-down views for materials, structure, assignments, etc.

**API Calls:**

| Action | Endpoint |
|---|---|
| Load teaching courses | `GET /enrollments/teaching` |
| Load course structure | `GET /courses/{id}/structure` |
| Load course materials | `GET /courses/{id}/materials` |

---

## 6. Role: Teaching Assistant (TA)

### 6.1 Dashboard Navigation

**Route Base:** `/tadashboard/:tab`  
**Available Tabs (Teaching group):** `courses`, `labs`, `quizzes`, `assignments`, `lab-resources`, `grading`

> [!IMPORTANT]
> The TA role has **read-only** or **grade-only** permissions. TAs cannot create, edit, or delete assignments or labs. They can only view and grade.

### 6.2 Tab: **Assignments**

**Sidebar Item:** `Assignments` (icon: `FileText`)  
**Route:** `/tadashboard/assignments`  
**Component:** `AssignmentGradingPage`  
**File:** `src/pages/ta-dashboard/components/AssignmentGradingPage.tsx`

**Component Tree:**

```
TADashboard
 └─ AssignmentGradingPage
     ├─ Status Summary       (Pending count, Graded count)
     ├─ Filter Buttons       (All, Submitted, Graded)
     ├─ Submissions List     (left panel – scrollable)
     └─ Submission Detail    (right panel – grading form)
```

#### 6.2.1 Grading Workflow

1. Page loads → fetches all assignments via `AssignmentService.getAll(courseId?)`
2. For each assignment → fetches submissions via `AssignmentService.getSubmissions(assignmentId)`
3. Submissions are aggregated into a single list with `assignmentTitle` and `assignmentMaxScore`
4. TA selects a submission → detail panel shows:
   - Student name, assignment title
   - Status badge (Graded/Submitted)
   - Submitted date, late indicator
   - Submission content (text / file)
   - Grade input (number, 0 to maxScore, step 0.5)
   - Feedback textarea
   - Previous feedback (if re-grading)
   - Submit Grade button

**Permission Check:** Component verifies `user.roles.includes('teaching_assistant')` on mount. If not TA → access denied screen.

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load assignments | `GET /assignments` or `GET /assignments?courseId={courseId}` | `AssignmentService.getAll()` |
| Load submissions | `GET /assignments/{id}/submissions` | `AssignmentService.getSubmissions(id)` |
| Submit grade | `PATCH /assignments/{aId}/submissions/{sId}/grade` | `AssignmentService.gradeSubmission(aId, sId, score, feedback)` |

**Grading Form Fields:**

| Field | Type | Required | Notes |
|---|---|---|---|
| `score` | `number` (input) | ✅ **Yes** | 0 to `maxScore`, step 0.5 |
| `feedback` | `string` (textarea) | ❌ No | — |

---

### 6.3 Tab: **Labs**

**Sidebar Item:** `Labs` (icon: `Beaker`)  
**Route:** `/tadashboard/labs`  
**Component:** `LabsPage`  
**File:** `src/pages/ta-dashboard/components/LabsPage.tsx`

**Component Tree:**

```
TADashboard
 └─ LabsPage
     ├─ Header ("Lab Management")
     ├─ Search & Filters       (text search + All/Active/Completed buttons)
     ├─ Labs Table             (Lab name, Course, Due Date, Submissions, Status)
     └─ GradingModal           (opened when "View Submissions" is clicked)
```

#### 6.3.1 Labs Table

| Column | Data |
|---|---|
| **Lab** | Title + Lab number |
| **Course** | `lab.course?.name` |
| **Due Date** | `lab.dueDate` formatted |
| **Submissions** | View link |
| **Status** | Badge: Published (green), Draft (blue), Closed (gray) |
| **Actions** | `Eye` icon → View Submissions |

> [!NOTE]
> TA sees **only** the `Eye` (View Submissions) button. No Edit or Delete buttons. This is enforced by the `isTA` permission check in the component.

#### 6.3.2 Lab Grading Flow

1. Click `Eye` → calls `LabService.getSubmissions(lab.id)`
2. Opens `GradingModal` with:
   - Lab title
   - List of submissions
   - Grade input: `score` (number) + `feedback` (text)
3. Submit grade → calls `LabService.gradeSubmission(labId, submissionId, score, feedback)`

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load all labs | `GET /labs` | `LabService.getAll()` |
| Load submissions | `GET /labs/{id}/submissions` | `LabService.getSubmissions(id)` |
| Grade submission | `PATCH /labs/{labId}/submissions/{subId}/grade` | `LabService.gradeSubmission(...)` |

---

### 6.4 Tab: **Courses**

**Sidebar Item:** `Courses` (icon: `BookOpen`)  
**Route:** `/tadashboard/courses`  
**Component:** `CoursesPage`  
**File:** `src/pages/ta-dashboard/components/CoursesPage.tsx`

The TA Courses page provides a comprehensive drill-down view with the following **sub-tabs** within each course:

| Sub-Tab | Description |
|---|---|
| **Overview** | Student count, lab count, avg grade, attendance rate |
| **Sections & Labs** | View sections (read-only) + Create/Edit/Delete labs (⚠️ note: currently uses mock data) |
| **Lectures** | View lecture list (mock data) |
| **Materials** | View + Upload materials |
| **Assignments** | View assignments, view submissions, edit, grade (mock data) |
| **Grading** | Manual and auto grading panels (mock data) |
| **Attendance** | View/update attendance sessions |
| **Students** | View students assigned to course |
| **Announcements** | View/create announcements |

> [!WARNING]
> The TA `CoursesPage` component (`src/pages/ta-dashboard/components/CoursesPage.tsx`) currently uses **mock data** for most sub-tabs (lectures, materials, assignments within course detail, students). The standalone `LabsPage` and `AssignmentGradingPage` tabs use **live API data**.

---

## 7. Role: Admin (Department Head)

### 7.1 Dashboard Navigation

**Route Base:** `/admindashboard/:tab`  
**Available Tabs:** `dashboard`, `students`, `courses`, `periods`, `calendar`, `communication`, `chat`, `profile`

### 7.2 Tab: **Course Management**

**Sidebar Item:** `Course Management` (icon: `BookOpen`)  
**Route:** `/admindashboard/courses`  
**Component:** `CourseManagementPage`  
**File:** `src/pages/admin-dashboard/components/CourseManagementPage.tsx`

**Component Tree:**

```
AdminDashboard
 └─ CourseManagementPage
     ├─ Sub-Tabs: Courses | Staff | Schedule | Exams
     ├─ Filters: Search + Department + Status
     ├─ Course Table/Grid
     ├─ Add Course Modal (3-step wizard)
     ├─ Edit Course Modal (3-step wizard)
     ├─ Staff Assignment Modal
     └─ Delete Confirmation
```

#### 7.2.1 Sub-Tabs

| Sub-Tab | Description |
|---|---|
| **Courses** | Main course list with CRUD operations |
| **Staff** | Staff assignment view (read-only table of courses with their instructors/TAs) |
| **Schedule** | Weekly schedule view (mock data) |
| **Exams** | Exam schedule view (mock data) |

#### 7.2.2 Course List

| UI Element | Description |
|---|---|
| **Search** | Filters by course name or code |
| **Department Filter** | Dropdown from unique departments in course list |
| **Status Filter** | `All`, `Active`, `Inactive`, `Archived` |
| **Add Course** | Button → Opens 3-step modal |

**Course Card/Row Actions:**

| Button | Icon | Action |
|---|---|---|
| **Edit** | `Pencil` | Opens Edit Course modal |
| **Assign Staff** | `UserCheck` | Opens Staff Assignment modal |
| **Delete** | `Trash2` | Confirmation → `DELETE /courses/{id}` |

#### 7.2.3 Add Course Modal (3-Step Wizard)

**Step 1 — Course Details:**

| Field | Type | Required | Default |
|---|---|---|---|
| `code` | `string` | ✅ **Yes** | `""` |
| `name` | `string` | ✅ **Yes** | `""` |
| `department` | `string` | ✅ **Yes** | Admin's department |
| `credits` | `number` | ✅ **Yes** | `3` |
| `level` | `string` (select) | ✅ **Yes** | `"FRESHMAN"` |
| `status` | `string` (select) | ✅ **Yes** | `"ACTIVE"` |

**→ API Call:** `POST /courses` with body:
```json
{
  "code": "string",
  "name": "string",
  "description": "string",
  "credits": "number",
  "level": "string",
  "departmentId": 1
}
```

**Step 2 — Section & Schedule:**

| Field | Type | Required | Default |
|---|---|---|---|
| `sectionNumber` | `string` | ✅ **Yes** | `"01"` |
| `maxCapacity` | `number` | ✅ **Yes** | `30` |
| `location` | `string` | ✅ **Yes** | `"Room A-101"` |
| `semesterId` | `number` (select) | ✅ **Yes** | Auto-selected |
| `scheduleDay` | `string` (select) | ✅ **Yes** | `"Monday"` |
| `startTime` | `string` (time) | ✅ **Yes** | `"09:00"` |
| `endTime` | `string` (time) | ✅ **Yes** | `"10:30"` |

**→ API Calls:**
1. `POST /sections` → Creates section
2. `POST /schedules/section/{sectionId}` → Creates schedule

**Step 3 — Staff Assignment:**

| Field | Type | Required |
|---|---|---|
| `instructorId` | `number` (select from instructors) | ❌ No |
| `taIds` | `number[]` (multi-select from TAs) | ❌ No |

**→ API Calls:**
1. `POST /enrollments/sections/{sectionId}/instructors` with `{ userId: instructorId }`
2. For each TA: `POST /enrollments/sections/{sectionId}/tas` with `{ userId: taId }`

#### 7.2.4 Edit Course Modal

Same structure as Add Course but pre-populated with existing data. Uses:
- `PATCH /courses/{id}` for course details
- `PATCH /sections/{sectionId}` for section update
- Deletes old schedules + creates new: `DELETE /schedules/{id}` then `POST /schedules/section/{sectionId}`
- Syncs staff via `syncStaffAssignments()` which diffs current vs desired

#### 7.2.5 Staff Assignment Modal

Allows admin to directly assign/unassign instructors and TAs to a course's section.

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Get current instructors | `GET /enrollments/sections/{sectionId}/instructors` | GET |
| Get current TAs | `GET /enrollments/sections/{sectionId}/tas` | GET |
| Assign instructor | `POST /enrollments/sections/{sectionId}/instructors` | POST |
| Remove instructor | `DELETE /enrollments/sections/{sectionId}/instructors/{enrollmentId}` | DELETE |
| Assign TA | `POST /enrollments/sections/{sectionId}/tas` | POST |
| Remove TA | `DELETE /enrollments/sections/{sectionId}/tas/{enrollmentId}` | DELETE |

#### 7.2.6 Additional Admin API Calls

| Action | Endpoint | Method |
|---|---|---|
| Load all courses | `GET /courses` | GET |
| Load sections for course | `GET /sections/course/{courseId}` | GET |
| Load section details | `GET /sections/{sectionId}` | GET |
| Load schedules | `GET /schedules/section/{sectionId}` | GET |
| Load semesters | `GET /semesters` | GET |
| Get section instructor | `GET /enrollments/section/{sectionId}/instructor` | GET |
| Get section TAs | `GET /enrollments/section/{sectionId}/tas` | GET |
| Delete course | `DELETE /courses/{id}` | DELETE |

> [!NOTE]
> The Admin role does **not** have assignment or lab management features. The Admin focuses on course lifecycle management (create, edit, delete), section/schedule management, and staff assignment.

---

## 8. Role: IT Admin

### 8.1 Feature Scope

The IT Admin dashboard does **not** include any Courses, Assignments, or Labs features. The IT Admin focuses on:

- User Management
- Role Management
- System Configuration
- Integrations & APIs
- Database Management
- Monitoring & Performance
- Security Management
- Multi-Campus Management
- Alerts, Cloud Services, Error Logs
- Backup Center

> [!TIP]
> If the IT Admin needs to manage courses or academic content, they would need to switch to the Admin role or request the Admin to perform those actions.

---

## 9. File Upload & Google Drive Integration

### 9.1 Upload Pattern

All file uploads in EduVerse use `FormData` with the `ApiClient`. The `Content-Type` header is **not** manually set — the browser auto-generates the `multipart/form-data` boundary.

```typescript
// Pattern used in services
const formData = new FormData();
formData.append('file', file);
return ApiClient.post(`/endpoint`, formData);
// Content-Type is auto-set by browser
```

### 9.2 Google Drive File Structure

Files uploaded to the backend are stored on Google Drive. The response includes:

```typescript
interface DriveFileLink {
  driveId: string;       // Google Drive file ID
  driveFileId?: number;  // Internal DB ID
  fileName: string;      // Original filename
  webViewLink: string;   // Google Drive web viewer URL
  iframeUrl: string;     // Embeddable iframe URL for preview
  downloadUrl: string;   // Direct download URL
}
```

### 9.3 File Preview in UI

When displaying Drive files, the frontend renders:
1. **Iframe Preview** — `<iframe src={iframeUrl}>` for inline document viewing
2. **Open in Drive** — `<a href={webViewLink}>` opens Google Drive viewer
3. **Download** — `<a href={downloadUrl}>` triggers file download

### 9.4 Instruction Files

Both Assignments and Labs support instruction file uploads:

| Entity | Upload Endpoint | Allowed Types |
|---|---|---|
| Assignment | `POST /assignments/{id}/instructions/upload` | `.pdf, .doc, .docx, .txt, .ppt, .pptx` |
| Lab | `POST /labs/{id}/instructions/upload` | Any file type |

---

## 10. Endpoint Reference Summary

### 10.1 Assignment Endpoints

| Method | Endpoint | Used By |
|---|---|---|
| `GET` | `/assignments` | Instructor, TA |
| `GET` | `/assignments?courseId={id}` | Instructor, Student |
| `GET` | `/assignments/{id}` | Student, Instructor |
| `POST` | `/assignments` | Instructor |
| `PATCH` | `/assignments/{id}` | Instructor |
| `DELETE` | `/assignments/{id}` | Instructor |
| `PATCH` | `/assignments/{id}/status` | Instructor |
| `GET` | `/assignments/{id}/submissions` | Instructor, TA |
| `POST` | `/assignments/{id}/submit` | Student |
| `GET` | `/assignments/{id}/my-submission` | Student |
| `PATCH` | `/assignments/{aId}/submissions/{sId}/grade` | Instructor, TA |
| `POST` | `/assignments/{id}/instructions/upload` | Instructor |

### 10.2 Lab Endpoints

| Method | Endpoint | Used By |
|---|---|---|
| `GET` | `/labs` | Instructor, TA |
| `GET` | `/labs?courseId={id}` | Student, Instructor |
| `GET` | `/labs/{id}` | Student, Instructor |
| `POST` | `/labs` | Instructor |
| `PATCH` | `/labs/{id}` | Instructor |
| `DELETE` | `/labs/{id}` | Instructor |
| `GET` | `/labs/{id}/instructions` | Student, Instructor |
| `POST` | `/labs/{id}/instructions` | Instructor |
| `POST` | `/labs/{id}/instructions/upload` | Instructor |
| `GET` | `/labs/{id}/submissions` | Instructor, TA |
| `POST` | `/labs/{id}/submit` | Student |
| `GET` | `/labs/{id}/my-submission` | Student |
| `PATCH` | `/labs/{labId}/submissions/{subId}/grade` | Instructor, TA |
| `GET` | `/labs/{id}/attendance` | Instructor |
| `POST` | `/labs/{id}/attendance` | Instructor |

### 10.3 Course Endpoints

| Method | Endpoint | Used By |
|---|---|---|
| `GET` | `/courses` | Admin |
| `GET` | `/courses/{id}` | All (with courses) |
| `POST` | `/courses` | Admin |
| `PATCH` | `/courses/{id}` | Admin |
| `DELETE` | `/courses/{id}` | Admin |
| `GET` | `/courses/{id}/structure` | Student, Instructor |
| `GET` | `/courses/{id}/materials` | Student, Instructor |
| `POST` | `/courses/{id}/materials/upload` | Instructor |

### 10.4 Enrollment Endpoints

| Method | Endpoint | Used By |
|---|---|---|
| `GET` | `/enrollments/my-courses` | Student |
| `GET` | `/enrollments/teaching` | Instructor, TA |
| `GET` | `/enrollments/sections/{id}/students` | Instructor, Admin |
| `POST` | `/enrollments/sections/{id}/instructors` | Admin |
| `DELETE` | `/enrollments/sections/{id}/instructors/{enrollmentId}` | Admin |
| `POST` | `/enrollments/sections/{id}/tas` | Admin |
| `DELETE` | `/enrollments/sections/{id}/tas/{enrollmentId}` | Admin |
| `GET` | `/enrollments/sections/{id}/instructors` | Admin |
| `GET` | `/enrollments/sections/{id}/tas` | Admin |

### 10.5 Section & Schedule Endpoints (Admin)

| Method | Endpoint | Used By |
|---|---|---|
| `GET` | `/sections/course/{courseId}` | Admin |
| `GET` | `/sections/{sectionId}` | Admin |
| `POST` | `/sections` | Admin |
| `PATCH` | `/sections/{sectionId}` | Admin |
| `GET` | `/schedules/section/{sectionId}` | Admin |
| `POST` | `/schedules/section/{sectionId}` | Admin |
| `DELETE` | `/schedules/{scheduleId}` | Admin |
| `GET` | `/semesters` | Admin |

---

## 11. Course Video Lectures & Material Viewing System

This section documents the full lifecycle of course video lectures: how they are **uploaded** (by Instructors), **structured** (via the Course Structure / Organization system), **bundled** (video + companion files), **viewed** (by Students in the CourseView player), and what **backend endpoints** drive the entire flow.

---

### 11.1 Data Models

#### 11.1.1 CourseMaterial

> Source: `src/services/api/courseService.ts` (lines 30-66)

This is the central model for every piece of course content — videos, documents, slides, readings, and external links.

```typescript
interface CourseMaterial {
  materialId: string;           // Required — Primary key (UUID)
  courseId: string;              // Required — FK to Course
  course?: {                    // Optional — resolved course info
    id: string;
    name: string;
    code: string;
    credits: number;
    level: string;
  } | null;
  fileId?: string | null;       // Legacy internal file reference
  file?: unknown | null;        // Legacy file object
  driveFileId?: string | null;  // Google Drive file ID (used for preview fallback)
  materialType: 'document' | 'video' | 'lecture' | 'slide' | 'reading' | 'link' | 'other';
  title: string;                // Required — display title
  description?: string;         // Optional — shown below preview
  externalUrl?: string | null;  // YouTube embed URL or external link
  driveViewUrl?: string | null; // Google Drive view URL
  driveDownloadUrl?: string | null; // Google Drive download URL
  fileName?: string | null;     // Original uploaded filename
  youtubeVideoId?: string | null; // Extracted YouTube video ID (for thumbnails)
  orderIndex?: number;          // Sort order within a week
  weekNumber?: number | null;   // Week grouping (null = "General")
  viewCount?: number;           // Read-only — tracks views
  downloadCount?: number;       // Read-only — tracks downloads
  uploadedBy?: number;          // FK to uploading user
  uploader?: {                  // Resolved uploader info
    userId: number;
    firstName: string;
    lastName: string;
    email: string;
  } | null;
  isPublished: number;          // 0 = Draft, 1 = Published (students only see 1)
  publishedAt?: string | null;  // ISO 8601
  createdAt: string;            // ISO 8601
  updatedAt?: string;           // ISO 8601
}
```

#### 11.1.2 CourseStructure (Organization Item)

> Source: `src/services/api/courseService.ts` (lines 68-80)

Represents a structural element (a lecture, lab, section, or tutorial slot) in the course outline. Each item can optionally link to a `CourseMaterial`.

```typescript
interface CourseStructure {
  organizationId: string;       // Required — Primary key (UUID)
  courseId: string;              // Required — FK to Course
  materialId: string | null;    // Optional — FK to CourseMaterial (linked content)
  material: CourseMaterial | null; // Resolved material if linked
  organizationType: 'lecture' | 'lab' | 'section' | 'tutorial';
  title: string;                // Required — display title (e.g. "Intro to Algorithms")
  weekNumber: number;           // Required — week grouping
  orderIndex: number;           // Required — sort order within a week
  description?: string;         // Optional
  createdAt?: string;
  updatedAt?: string;
}
```

#### 11.1.3 CourseStructureResponse

```typescript
interface CourseStructureResponse {
  data: CourseStructure[];                          // Flat list of all items
  byWeek: Record<string, CourseStructure[]>;        // Pre-grouped by weekNumber
}
```

#### 11.1.4 CourseMaterialsResponse

```typescript
interface CourseMaterialsResponse {
  data: CourseMaterial[];
  meta?: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

#### 11.1.5 MaterialBundle (Frontend Utility)

> Source: `src/utils/materialBundles.ts`

A **MaterialBundle** is a purely frontend concept that groups multiple `CourseMaterial` items together when they share the same base title. For example, materials named `"Lecture 3 - Video"` and `"Lecture 3 - Slides"` are automatically grouped into a single `"Lecture 3"` bundle.

```typescript
interface MaterialBundle {
  key: string;                  // Computed — e.g. "3::lecture 3" (weekNumber::baseTitle)
  baseTitle: string;            // e.g. "Lecture 3"
  items: CourseMaterial[];      // All materials in the bundle
  video: CourseMaterial | null; // The video item (materialType === 'video')
  documents: CourseMaterial[];  // All non-video items
  instructions: string;        // First non-empty description from any item
  weekNumber: number | null;    // Shared week number
  isPublished: boolean;         // True only if ALL items are published
}
```

**Bundle Detection Logic** (`parseBundleTitle`):
- Title must contain ` - ` (space-dash-space) separator
- Everything before the last ` - ` is the `baseTitle`
- Everything after is the `suffix` (e.g. "Video", "Slides", "Notes")
- Materials with identical `baseTitle` AND same `weekNumber` are grouped
- A group becomes a bundle if it has **more than 1 item** OR has a **video-like item**

**Bundle Title Convention:**
```
"{Base Title} - {Suffix}"
Examples:
  "Lecture 3 - Video"      → baseTitle: "Lecture 3", suffix: "Video"
  "Lecture 3 - Slides"     → baseTitle: "Lecture 3", suffix: "Slides"
  "Lecture 3 - Homework"   → baseTitle: "Lecture 3", suffix: "Homework"
```

---

### 11.2 materialService API Layer

> Source: `src/services/api/courseService.ts` (lines 264-393)

The `materialService` object provides all CRUD and interaction methods for course materials. Unlike the class-based `CourseService`, this is an object-based service layer.

#### 11.2.1 Full Endpoint Table

| Method | Service Function | HTTP | Endpoint | Request Params | Response |
|---|---|---|---|---|---|
| **Get Materials** | `getMaterials(courseId, params?)` | `GET` | `/courses/{courseId}/materials` | Query: `?materialType=&weekNumber=&page=&limit=&search=` | `CourseMaterialsResponse` |
| **Get Single Material** | `getMaterial(courseId, materialId)` | `GET` | `/courses/{courseId}/materials/{materialId}` | — | `CourseMaterial` |
| **Create Material (Text/Link)** | `createMaterial(courseId, data)` | `POST` | `/courses/{courseId}/materials` | Body (JSON): see below | `CourseMaterial` |
| **Upload Document** | `uploadDocument(courseId, formData)` | `POST` | `/courses/{courseId}/materials/document` | **FormData** | `CourseMaterial` |
| **Upload Video** | `uploadVideo(courseId, file, metadata, onProgress?)` | `POST` | `/courses/{courseId}/materials/video` | **FormData**: see below | YouTube-processed `CourseMaterial` |
| **Upload File** | `uploadFile(courseId, file, metadata, onProgress?)` | `POST` | `/courses/{courseId}/materials/document` | **FormData**: see below | `CourseMaterial` |
| **Update Material** | `updateMaterial(courseId, materialId, data)` | `PUT` | `/courses/{courseId}/materials/{materialId}` | Body (JSON) | `CourseMaterial` |
| **Delete Material** | `deleteMaterial(courseId, materialId)` | `DELETE` | `/courses/{courseId}/materials/{materialId}` | — | `{ message: string }` |
| **Toggle Visibility** | `toggleVisibility(courseId, materialId, isPublished)` | `PATCH` | `/courses/{courseId}/materials/{materialId}/visibility` | Body: `{ isPublished: boolean }` | `CourseMaterial` |
| **Track View** | `trackView(courseId, materialId)` | `POST` | `/courses/{courseId}/materials/{materialId}/view` | — | `{ message, materialId, viewCount }` |
| **Get Embed** | `getEmbed(courseId, materialId)` | `GET` | `/courses/{courseId}/materials/{materialId}/embed` | — | `{ videoId, embedUrl, iframeHtml }` |
| **Get Download URL** | `getDownloadUrl(courseId, materialId)` | — (constructs URL) | `/courses/{courseId}/materials/{materialId}/download` | — | `string` (URL) |
| **Get YouTube Auth URL** | `getYouTubeAuthUrl()` | `GET` | `/youtube/auth` | — | `{ authUrl: string }` |
| **Get Google Drive Auth URL** | `getGoogleDriveAuthUrl()` | `GET` | `/google-drive/auth` | — | `{ authUrl, scopes[], instructions }` |

#### 11.2.2 Create Material Request Body (Text/Link)

```typescript
{
  title: string;           // Required
  materialType: string;    // Required — 'document' | 'video' | 'lecture' | 'slide' | 'link' | 'reading' | 'other'
  description?: string;    // Optional
  weekNumber?: number;     // Optional
  isPublished?: boolean;   // Optional — defaults to false
}
```

#### 11.2.3 Upload Video FormData Fields

> Source: `courseService.ts` lines 311-349

The **video upload** uses raw `axios` (not the `ApiClient` wrapper) to support `onUploadProgress` callbacks for a real-time progress bar.

| FormData Field | Type | Required | Description |
|---|---|---|---|
| `video` | `File` | ✅ **Yes** | The video file — field name **MUST** be `"video"` |
| `title` | `string` | ✅ **Yes** | Material title |
| `description` | `string` | ❌ No | Optional description |
| `weekNumber` | `string` (number) | ❌ No | Week assignment |
| `orderIndex` | `string` (number) | ❌ No | Sort order |
| `isPublished` | `string` (boolean) | ❌ No | `"true"` or `"false"` |
| `tags` | `string` | ❌ No | Comma-separated tags |

**Endpoint:** `POST /courses/{courseId}/materials/video`

**Auth:** Bearer token retrieved from `localStorage` via `TOKEN_KEYS.ACCESS_TOKEN`

**Progress:** `onUploadProgress(e)` → `Math.round((e.loaded * 100) / e.total)` — reported to the caller's callback

**Backend Behavior:** The backend receives the video, uploads it to **YouTube** via the YouTube Data API, then stores the resulting YouTube `videoId` and `externalUrl` (embed URL) in the `CourseMaterial` record.

#### 11.2.4 Upload File (Document) FormData Fields

> Source: `courseService.ts` lines 351-386

| FormData Field | Type | Required | Description |
|---|---|---|---|
| `document` | `File` | ✅ **Yes** | The file — field name **MUST** be `"document"` |
| `title` | `string` | ✅ **Yes** | Material title |
| `materialType` | `string` | ✅ **Yes** | `'document'` \| `'lecture'` \| `'slide'` \| `'reading'` |
| `description` | `string` | ❌ No | Optional description |
| `weekNumber` | `string` (number) | ❌ No | Week assignment |
| `isPublished` | `string` (boolean) | ❌ No | `"true"` or `"false"` |

**Endpoint:** `POST /courses/{courseId}/materials/document`

**Backend Behavior:** The backend uploads the file to **Google Drive**, then stores the resulting `driveFileId`, `driveViewUrl`, and `driveDownloadUrl` in the `CourseMaterial` record.

#### 11.2.5 File Validation Rules (Frontend)

> Source: `UploadMaterialsPage.tsx` lines 95-165

| Category | Allowed MIME Types | Allowed Extensions | Max Size |
|---|---|---|---|
| **Documents** | `application/pdf`, `application/msword`, `application/vnd.openxmlformats-officedocument.*`, `application/vnd.ms-*`, `text/plain`, `text/markdown`, `application/zip` | `.pdf, .doc, .docx, .ppt, .pptx, .xls, .xlsx, .txt, .md, .zip` | **50 MB** |
| **Images** | `image/jpeg`, `image/png`, `image/gif`, `image/webp`, `image/svg+xml` | `.jpg, .jpeg, .png, .gif, .webp, .svg` | **10 MB** |
| **Videos** | Any video MIME type | No client-side extension check | No client-side size limit (progress-tracked) |

---

### 11.3 structureService API Layer

> Source: `src/services/api/courseService.ts` (lines 396-419)

| Method | Service Function | HTTP | Endpoint | Request Body | Response |
|---|---|---|---|---|---|
| **Get Structure** | `getStructure(courseId)` | `GET` | `/courses/{courseId}/structure` | — | `CourseStructureResponse` |
| **Create Item** | `createStructureItem(courseId, data)` | `POST` | `/courses/{courseId}/structure` | `{ title, organizationType, weekNumber, orderIndex?, description? }` | `CourseStructure` |
| **Update Item** | `updateStructureItem(courseId, orgId, data)` | `PUT` | `/courses/{courseId}/structure/{organizationId}` | Partial update body | `CourseStructure` |
| **Delete Item** | `deleteStructureItem(courseId, orgId)` | `DELETE` | `/courses/{courseId}/structure/{organizationId}` | — | `{ message: string }` |
| **Reorder** | `reorderStructure(courseId, orderIds)` | `PATCH` | `/courses/{courseId}/structure/reorder` | `{ orderIds: number[] }` | `{ message: string }` |

#### Create Structure Item Request Body

```typescript
{
  title: string;                // Required — e.g. "Introduction to Algorithms"
  organizationType: string;     // Required — 'lecture' | 'lab' | 'section' | 'tutorial'
  weekNumber: number;           // Required — e.g. 1, 2, 3…
  orderIndex?: number;          // Optional — sort position within the week
  description?: string;         // Optional
}
```

---

### 11.4 Preview URL Resolution

> Source: `src/services/api/courseService.ts` — `getCourseMaterialPreviewUrl()` (lines 250-262)

This pure function determines the correct preview URL for any `CourseMaterial`:

```
1. Check externalUrl → driveViewUrl → driveDownloadUrl (first non-empty wins)
2. If the URL is a YouTube link → return as-is
3. If the URL is a Google Drive link:
   a. If it already contains "/preview" → return as-is
   b. Otherwise extract the Drive file ID → return "https://drive.google.com/file/d/{id}/preview"
4. If none of the URLs exist, check driveFileId:
   → return "https://drive.google.com/file/d/{driveFileId}/preview"
5. If nothing matches → return null (preview unavailable)
```

**Google Drive ID Extraction** (`extractGoogleDriveId`):
- Matches `/d/{id}/` path format
- Falls back to `?id={id}` query parameter format

---

### 11.5 Student: CourseView Video Player

> Source: `src/pages/student-dashboard/pages/CourseView.tsx` (1070 lines)

**Route:** `/studentdashboard/courses` → click on a course card → loads `CourseViewPage`

#### 11.5.1 Layout

```
CourseViewPage
 ├─ Header
 │   ├─ Back Button ("Back to My Classes")
 │   ├─ Course Name (h1)
 │   ├─ Meta Badges: Code, Credits, Level, Section, Semester, Status
 │   └─ Stats Row: Students enrolled, Materials count, Location, Enrollment date
 │
 ├─ Main Content Area (left, flexible width)
 │   ├─ Preview Viewer (large area — 70-76vh when content selected)
 │   │   ├─ "Generate AI Notes" Button (top-right overlay)
 │   │   ├─ Welcome Screen (when no material selected)
 │   │   ├─ Bundle Viewer (when a lecture bundle is selected)
 │   │   │   ├─ Video iframe (from bundle.video.externalUrl)
 │   │   │   ├─ Instructions block
 │   │   │   ├─ Lecture Files list (selectable, with Open/Download)
 │   │   │   └─ Document Preview iframe (for selected file)
 │   │   ├─ Video Player (standalone video, non-bundle)
 │   │   │   └─ iframe (src=material.externalUrl)
 │   │   ├─ Document Viewer (non-video material)
 │   │   │   └─ iframe (src=previewUrl from getCourseMaterialPreviewUrl)
 │   │   └─ Link/Other Viewer (external link materials)
 │   │       └─ Title, Description, "Open Link" button
 │   │
 │   └─ Tab Content (below preview)
 │       ├─ Overview: Course description, Section info, Semester, Prerequisites
 │       ├─ Notes: "Coming soon" placeholder
 │       ├─ Announcements: Live course announcements (from announcementService)
 │       └─ Reviews: "Coming soon" placeholder
 │
 └─ Right Sidebar (fixed 384px)
     ├─ Progress Card: "0 / {materialsCount} materials" with progress bar
     └─ Course Content Panel:
         ├─ If hasStructure → Week-based accordion (expandable sections)
         │   └─ Lesson items (icon + title + type badge + "Bundle"/"Video"/"Resource")
         └─ If !hasStructure && hasMaterials → Flat material list
             └─ Material rows (icon + title + type + week)
```

#### 11.5.2 Data Loading Flow

When `CourseViewPage` mounts:

```
1. enrollmentService.getMyCourses() → find matching enrollment by enrollmentId
2. Extract resolvedCourseId from enrollment.course.id
3. Parallel fetch:
   a. structureService.getStructure(resolvedCourseId)  → structure/organization
   b. materialService.getMaterials(resolvedCourseId, { page: 1, limit: 200 })  → all materials
4. Filter materials to only isPublished === 1
5. Group materials into bundles via groupMaterialsIntoBundles()
6. Build courseSections from structure (byWeek grouped accordion)
7. Auto-expand first week section
```

**API Calls on Mount:**

| Action | Endpoint | Method | Response |
|---|---|---|---|
| Load enrollments | `GET /enrollments/my-courses` | GET | `Enrollment[]` |
| Load course structure | `GET /courses/{courseId}/structure` | GET | `CourseStructureResponse` |
| Load all materials | `GET /courses/{courseId}/materials?page=1&limit=200` | GET | `CourseMaterialsResponse` |

#### 11.5.3 Material Selection & View Tracking

When a student clicks on a material/lesson:

```typescript
handleMaterialClick(materialId) {
  1. Find the CourseMaterial by materialId
  2. Check if it belongs to a bundle (via bundleByMaterialId lookup)
  3. If bundle:
     - Set selectedBundleKey → renders Bundle Viewer
     - Set selectedBundleDocumentId → first document in bundle
     - Set selectedMaterial → bundle.video || first document
  4. If standalone:
     - Clear bundle state
     - Set selectedMaterial → the material itself
  5. Call materialService.trackView(courseId, materialId)  ← fire & forget
}
```

**View Tracking API Call:**

| Action | Endpoint | Method | Response |
|---|---|---|---|
| Track material view | `POST /courses/{courseId}/materials/{materialId}/view` | POST | `{ message, materialId, viewCount }` |

#### 11.5.4 Video Rendering

**Standalone Video:**
```html
<iframe
  src="{material.externalUrl}"    <!-- YouTube embed URL -->
  allowFullScreen
  title="{material.title}"
  class="w-full h-[52vh] min-h-[420px] rounded-lg border-0"
/>
```

**Bundle Video (inside Bundle Viewer):**
```html
<iframe
  src="{bundle.video.externalUrl}"
  allowFullScreen
  title="{bundle.baseTitle}"
  class="w-full h-[44vh] min-h-[340px] rounded-lg border-0"
/>
```

**Document Preview (standalone or in bundle):**
```html
<iframe
  src="{getCourseMaterialPreviewUrl(material)}"    <!-- Google Drive /preview URL -->
  title="{material.title}"
  class="w-full h-[52vh] min-h-[420px] rounded-lg border-0"
/>
```

#### 11.5.5 Bundle Viewer Features

When a lecture bundle is selected, the student sees:

| Section | Content |
|---|---|
| **Title** | `bundle.baseTitle` (e.g. "Lecture 3") |
| **Video iframe** | Embedded YouTube player from `bundle.video.externalUrl` |
| **Instructions** | Text block from `bundle.instructions` (first non-empty description in the bundle) |
| **Lecture Files** | Selectable list of companion documents, each with an "Open" button that triggers `materialService.getDownloadUrl()` |
| **Document Preview** | iframe showing the currently selected document's Google Drive preview |

#### 11.5.6 Course Content Sidebar

The right sidebar renders course content in one of two modes:

**Mode 1: Structure-based (when `byWeek` has data)**
- Accordion sections for each week (e.g. "Week 1", "Week 2")
- Each section shows lesson items from the structure
- Bundle deduplication: if multiple structure items link to materials in the same bundle, only the first is shown
- Item display: icon (Lecture=`BookOpen`, Lab=`FlaskConical`, Tutorial=`User`, Section=`Users`) + title + badge ("Bundle" / "Video" / "Resource")

**Mode 2: Flat material list (when no structure exists)**
- Simple list of all published materials, deduplicated by bundle
- Each row: icon + title + type label + week number

---

### 11.6 Instructor: Upload & Manage Materials

> Source: `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx` (1892 lines)

**Route:** `/instructordashboard/materials`  
**Sidebar Item:** `Materials` (icon: `Upload`)

#### 11.6.1 Component Tree

```
InstructorDashboard
 └─ UploadMaterialsPage
     ├─ Course Selector (dropdown from getTeachingCourses)
     ├─ Tabs: "Upload Queue" | "Library"
     ├─ Filters: Search + Type filter + Week filter
     │
     ├─ Library View
     │   ├─ Week-grouped sections
     │   │   ├─ Bundle Cards (expandable — video preview + document list)
     │   │   └─ Single Material Cards (with inline preview)
     │   └─ General (ungrouped materials)
     │
     ├─ Create Modal (4 upload types)
     │   ├─ Text/Link — metadata only (title, type, description, week)
     │   ├─ File — document upload with validation
     │   ├─ Video — YouTube upload with progress bar
     │   └─ Bundle — video + multiple documents as one lecture
     │
     ├─ Edit Modal (update title, description, week, visibility)
     ├─ Delete Confirmation Dialog
     └─ Activity Log (recent upload history)
```

#### 11.6.2 Upload Types

| Upload Type | Icon | Description |
|---|---|---|
| `text` | `FileText` | Create a text/link material — no file upload, metadata only |
| `file` | `Upload` | Upload a single document to Google Drive |
| `video` | `Film` | Upload a video to YouTube via backend |
| `bundle` | `Package` | Upload a lecture bundle: one video + multiple documents |

#### 11.6.3 Create Material Form

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `title` | `string` (text input) | ✅ **Yes** | `""` | Non-empty |
| `materialType` | `'document'\|'video'\|'lecture'\|'slide'\|'link'\|'reading'\|'other'` (select) | ✅ **Yes** | `'document'` | Determines icon/badge |
| `description` | `string` (textarea) | ❌ No | `""` | Shown in previews |
| `weekNumber` | `string` (number input) | ❌ No | `""` | Assigns to a week group |
| `isPublished` | `boolean` (checkbox) | ❌ No | `false` | Controls student visibility |

**Additional fields for Bundle type:**
- **Video file** (file picker — any video type)
- **Document files** (multi-file picker — validated per rules above)

#### 11.6.4 Bundle Upload Flow

When upload type is `bundle`:

```
1. Validate: must have at least a video OR a document
2. Validate all documents against file size/type rules
3. Set bundleUploadStatus = 'uploading'
4. For the video (if present):
   a. Set step label: "Uploading video: {filename}"
   b. Call materialService.uploadVideo(courseId, file, {
        title: "{baseTitle} - Video",
        description, weekNumber, isPublished
      }, progressCallback)
5. For each document (sequentially):
   a. Set step label: "Uploading file {i}/{total}: {filename}"
   b. Call materialService.uploadFile(courseId, file, {
        title: "{baseTitle} - {fileBaseName}",
        materialType, description, weekNumber, isPublished
      }, progressCallback)
6. Progress: each item contributes (1/totalItems) to overall progress
7. On success: toast, close modal, refresh materials
8. On YouTube OAuth error: show "YouTube not authorized" message
```

**Naming Convention:** The bundle automatically prefixes each item:
- Video → `"{Title} - Video"`
- Documents → `"{Title} - {originalFilenameWithoutExtension}"`

This naming convention is what the `groupMaterialsIntoBundles()` utility uses to reconstruct bundles from flat material lists.

#### 11.6.5 Material Card Actions (Library View)

| Button | Icon | Action | API Call |
|---|---|---|---|
| **Load Embed** | `Eye` | Fetch YouTube embed URL (for videos without a cached embed) | `GET /courses/{courseId}/materials/{materialId}/embed` |
| **Toggle Visibility** | `Eye` / `EyeOff` | Publish or unpublish the material | `PATCH /courses/{courseId}/materials/{materialId}/visibility` |
| **Edit** | `Edit` | Opens Edit Modal | — |
| **Delete** | `Trash2` | Opens Delete Confirmation | `DELETE /courses/{courseId}/materials/{materialId}` |
| **Download** | `Download` | Opens download URL in new tab (non-video, non-link only) | Constructs URL: `/courses/{courseId}/materials/{materialId}/download` |

#### 11.6.6 Bundle-Specific Actions

| Action | Description | API Call |
|---|---|---|
| **Toggle Bundle Visibility** | Toggles `isPublished` for ALL items in the bundle | Multiple parallel `PATCH .../visibility` calls |
| **Edit Bundle** | Updates `title`, `description`, `weekNumber`, `isPublished` for ALL items (renames each to `"{newTitle} - {suffix}"`) | Multiple parallel `PUT .../materials/{materialId}` calls |
| **Delete Bundle** | Deletes ALL items in the bundle | Multiple parallel `DELETE .../materials/{materialId}` calls |
| **Expand/Collapse Preview** | Shows/hides the embedded video + document preview pane | `GET .../embed` (lazy load for video) |

#### 11.6.7 Material Card Display

Each material card shows:
- **YouTube Thumbnail** (if `youtubeVideoId` exists): `https://img.youtube.com/vi/{videoId}/mqdefault.jpg`
- **Material Type Badge**: Color-coded — video (blue), document (green), lecture (purple), slide (orange), link (slate)
- **YouTube Badge**: Red badge with YouTube icon when `youtubeVideoId` is set
- **Published/Draft Badge**: Green for published, slate for draft
- **Stats**: `{viewCount} views • {downloadCount} downloads • Uploader: {name}`
- **Inline Video Preview**: `<iframe src="{embedUrl || externalUrl}">` (315px height)
- **Inline Document Preview**: `<iframe src="{getCourseMaterialPreviewUrl(material)}">` (380px height)

---

### 11.7 Instructor: CourseDetail Lectures Tab

> Source: `src/pages/instructor-dashboard/components/CourseDetail.tsx`

When an instructor clicks on a course from `CoursesPage`, the `CourseDetail` component renders with a **Lectures** sub-tab.

**Route:** `/instructordashboard/courses` → click course → `CourseDetail` → select "Lectures" tab

#### 11.7.1 Lectures Tab Layout

```
CourseDetail → Lectures Tab
 ├─ Header: "Lectures" + "Upload Material" button
 └─ Week Cards (accordion-like)
     ├─ Week {N} Card
     │   ├─ Lecture {N}.1 — Introduction (static label with Video icon)
     │   └─ Materials list (fetched from backend)
     │       └─ Material row: icon + title + created date
     └─ Upload Material Modal
         ├─ Title input (Required)
         ├─ Lecture selector (dropdown — week-based)
         ├─ File upload (drag-and-drop via FileUploadDropzone)
         └─ Save Button
```

#### 11.7.2 Upload Material Modal Form

| Field | Type | Required | Default |
|---|---|---|---|
| `title` | `string` (text input) | ✅ **Yes** | `""` |
| `lectureId` | `string` (select — e.g. "1.1", "2.1") | ✅ **Yes** | `""` |
| `file` | `File` (drag-and-drop) | ❌ No | `null` |

**Upload behavior:**
- If a file is selected → creates `FormData` with fields: `document`, `title`, `materialType: 'document'`, `weekNumber`, `isPublished: 'true'` → calls `POST /courses/{courseId}/materials/document`
- If no file → creates text-only material → calls `POST /courses/{courseId}/materials` with JSON body

**API Calls:**

| Action | Endpoint | Method |
|---|---|---|
| Load course materials | `GET /courses/{courseId}/materials` | `CourseService.getMaterials(courseId)` |
| Upload document | `POST /courses/{courseId}/materials/document` | `CourseService.uploadDocument(courseId, formData)` |
| Create metadata-only material | `POST /courses/{courseId}/materials` | `CourseService.createMaterial(courseId, data)` |

---

### 11.8 YouTube & Google Drive Integration

#### 11.8.1 YouTube Integration

**Flow:**
1. Instructor selects "Video" upload type → picks a video file
2. Frontend checks YouTube auth status: `GET /youtube/auth` → returns `{ authUrl }`
3. Frontend uploads video via `POST /courses/{courseId}/materials/video` (FormData)
4. **Backend** receives the file, uses stored YouTube OAuth tokens to upload to YouTube
5. Backend stores the resulting `youtubeVideoId` and `externalUrl` (embed URL) in the material record
6. Frontend displays the video via `<iframe src="{externalUrl}" allowFullScreen />`

**YouTube OAuth Error Handling:**
- If the upload fails with an OAuth/token/authorization error, the frontend displays: _"YouTube not authorized. Please contact admin to set up YouTube integration."_
- The `youtubeAuthUrl` obtained from `GET /youtube/auth` can be used to trigger the OAuth consent flow

#### 11.8.2 Google Drive Integration

**Flow:**
1. Instructor uploads a document via `POST /courses/{courseId}/materials/document`
2. **Backend** uploads the file to Google Drive
3. Backend stores `driveFileId`, `driveViewUrl`, and `driveDownloadUrl` in the material record
4. Frontend previews documents via `<iframe src="{driveViewUrl converted to /preview}">`
5. Downloads are handled via: `GET /courses/{courseId}/materials/{materialId}/download` (opens in new tab)

**Google Drive Auth Endpoint:**

| Endpoint | Method | Response |
|---|---|---|
| `GET /google-drive/auth` | GET | `{ authUrl: string, scopes: string[], instructions: string }` |

---

### 11.9 Video Lectures Endpoint Reference Summary

| Method | Endpoint | Used By | Description |
|---|---|---|---|
| `GET` | `/courses/{courseId}/materials` | Student, Instructor | Get all materials (supports pagination, filtering by type/week/search) |
| `GET` | `/courses/{courseId}/materials/{materialId}` | Instructor | Get single material |
| `POST` | `/courses/{courseId}/materials` | Instructor | Create text/link material (JSON body) |
| `POST` | `/courses/{courseId}/materials/document` | Instructor | Upload document file (FormData — field: `document`) |
| `POST` | `/courses/{courseId}/materials/video` | Instructor | Upload video to YouTube (FormData — field: `video`) |
| `PUT` | `/courses/{courseId}/materials/{materialId}` | Instructor | Update material metadata |
| `DELETE` | `/courses/{courseId}/materials/{materialId}` | Instructor | Delete material |
| `PATCH` | `/courses/{courseId}/materials/{materialId}/visibility` | Instructor | Toggle published status |
| `POST` | `/courses/{courseId}/materials/{materialId}/view` | Student | Track view (increments viewCount) |
| `GET` | `/courses/{courseId}/materials/{materialId}/embed` | Instructor | Get YouTube embed data (`{ videoId, embedUrl, iframeHtml }`) |
| `GET` | `/courses/{courseId}/materials/{materialId}/download` | Student, Instructor | Download file (direct URL construction) |
| `GET` | `/courses/{courseId}/structure` | Student, Instructor | Get course structure (organized by weeks) |
| `POST` | `/courses/{courseId}/structure` | Instructor | Create structure item |
| `PUT` | `/courses/{courseId}/structure/{organizationId}` | Instructor | Update structure item |
| `DELETE` | `/courses/{courseId}/structure/{organizationId}` | Instructor | Delete structure item |
| `PATCH` | `/courses/{courseId}/structure/reorder` | Instructor | Reorder items (body: `{ orderIds: number[] }`) |
| `GET` | `/youtube/auth` | Instructor | Get YouTube OAuth consent URL |
| `GET` | `/google-drive/auth` | Instructor | Get Google Drive OAuth consent URL |

---

> **End of Document**
