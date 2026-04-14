# Enrolled Students Feature - Comprehensive Documentation

> **Feature:** View enrolled students in a course detail screen (Students Tab)  
> **Location:** Instructor Dashboard → Courses → Select Course → Students Tab  
> **Version:** 1.0  
> **Last Updated:** April 2026  
> **Scope:** Frontend implementation - data fetching, transformation, display, and user interactions

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Component Architecture](#2-component-architecture)
3. [Data Flow Architecture](#3-data-flow-architecture)
4. [Backend API Endpoints](#4-backend-api-endpoints)
5. [Data Models & TypeScript Interfaces](#5-data-models--typescript-interfaces)
6. [State Management](#6-state-management)
7. [Implementation Details](#7-implementation-details)
   - [7.1 CourseDetail Component - Students Tab](#71-coursedetail-component---students-tab)
   - [7.2 RosterTable Component](#72-roostertable-component)
   - [7.3 EnrollmentService](#73-enrollmentservice)
8. [Data Transformation Pipeline](#8-data-transformation-pipeline)
9. [Complete Variable & Props Reference](#9-complete-variable--props-reference)
10. [User Interactions](#10-user-interactions)
11. [Loading, Error & Edge Cases](#11-loading-error--edge-cases)
12. [Mock Mode vs Live Mode](#12-mock-mode-vs-live-mode)
13. [Styling & UI/UX](#13-styling--uiux)
14. [Related Features & Cross-References](#14-related-features--cross-references)
15. [Debugging & Troubleshooting](#15-debugging--troubleshooting)

---

## 1. Feature Overview

### 1.1 Purpose

The Enrolled Students feature allows instructors to view all students enrolled in a specific course section. This feature is accessed through the **Students Tab** within the **Course Detail** screen in the Instructor Dashboard.

### 1.2 User Journey

1. Instructor navigates to Courses in the dashboard
2. Instructor clicks on a specific course to view details
3. Instructor clicks the **Students** tab
4. System displays a table of all enrolled students with:
   - Student ID
   - Enrollment date
   - Enrollment status
   - Current grade
   - Final score
   - Notes functionality

### 1.3 Key Capabilities

- ✅ View all enrolled students in a course section
- ✅ Search/filter students by ID or status
- ✅ Sort by Student ID, Enrollment Date, or Status
- ✅ Add/edit inline notes for individual students
- ✅ Responsive design with dark/light theme support
- ✅ Real-time data from backend API
- ✅ Fallback to mock data during development

---

## 2. Component Architecture

### 2.1 Component Tree

```
InstructorDashboard
 └─ CoursesPage (when viewing course detail)
     └─ CourseDetail (courseId: number)
         ├─ Tab Navigation (overview, lectures, assignments, grading, students)
         └─ Students Tab (activeTab === 'students')
             └─ RosterTable
                 ├─ Search Input
                 ├─ Sortable Table Headers
                 ├─ Student Rows (filtered & sorted)
                 └─ Note Modal (for adding/editing notes)
```

### 2.2 Component Files

| Component | File Path | Purpose |
|-----------|-----------|---------|
| **CourseDetail** | `src/pages/instructor-dashboard/components/CourseDetail.tsx` | Main course detail container with tabbed interface |
| **RosterTable** | `src/pages/instructor-dashboard/components/RosterTable.tsx` | Reusable table component for displaying student roster |
| **EnrollmentService** | `src/services/api/enrollmentService.ts` | API service layer for enrollment-related operations |
| **ApiClient** | `src/services/api/client.ts` | Centralized HTTP client with auth interceptors |

### 2.3 Component Relationships

```
CourseDetail (line 177-181)
  │
  ├─ Fetches: sectionStudents via useQuery
  │   └─ Hook: EnrollmentService.getSectionStudents(course!.id)
  │   └─ Query Key: ['section-students', course?.id]
  │
  └─ Renders: RosterTable (line 1086-1101)
      │
      ├─ Prop: data (transformed sectionStudents)
      │   └─ Maps each student to RosterEntry format
      │
      └─ RosterTable internally:
          ├─ Uses sectionId prop (optional) to fetch live data
          ├─ OR uses data prop (fallback/mock mode)
          └─ Manages its own state for search, sort, notes
```

---

## 3. Data Flow Architecture

### 3.1 High-Level Data Flow

```
Backend API (NestJS)
    │
    ├─ GET /api/enrollments/section/{sectionId}/students
    │
    ▼
ApiClient (fetch wrapper)
    │
    ├─ Adds Authorization header (Bearer token)
    ├─ Handles 401 redirects to /login
    └─ Parses JSON response
    │
    ▼
EnrollmentService.getSectionStudents(sectionId)
    │
    ├─ Calls ApiClient.get()
    ├─ Handles paginated response (EnrolledCourse[] or { data: EnrolledCourse[] })
    └─ Returns EnrolledCourse[] via extractArray helper
    │
    ▼
React Query (useQuery hook in CourseDetail)
    │
    ├─ Query Key: ['section-students', course?.id]
    ├─ Caching & refetch logic
    └─ Returns { data: sectionStudents, isLoading: isLoadingStudents }
    │
    ▼
CourseDetail Component (Students Tab)
    │
    ├─ Transforms sectionStudents to RosterTable data format
    ├─ Maps: id, name, email, status, grades
    └─ Passes transformed data to RosterTable
    │
    ▼
RosterTable Component
    │
    ├─ If sectionId provided: fetches live data (ignores data prop)
    ├─ If only data prop: uses provided data directly
    ├─ Applies search filter
    ├─ Applies sorting
    └─ Renders table with notes functionality
```

### 3.2 Data Flow Diagram (CourseDetail → RosterTable)

```
┌─────────────────────────────────────────────────────────────────┐
│ CourseDetail.tsx                                                 │
│                                                                  │
│ 1. course.id extracted from URL/route params                    │
│                                                                  │
│ 2. useQuery hook triggers:                                       │
│    queryKey: ['section-students', course?.id]                   │
│    queryFn: () => EnrollmentService.getSectionStudents(course!.id)│
│                                                                  │
│ 3. Response stored in: sectionStudents (EnrolledCourse[])       │
│                                                                  │
│ 4. Transformation (line 1087-1101):                             │
│    sectionStudents.map((student, index) => ({                   │
│      id: student.id || student.userId || index + 1,             │
│      name: `${student.firstName || ''} ${student.lastName || ''}`.trim() || `Student ${index + 1}`, │
│      email: student.email || `student${index + 1}@edu.com`,     │
│      status: 'Enrolled',                                         │
│      grades: {                                                   │
│        assignments: '-',                                         │
│        quizzes: '-',                                             │
│        midterm: '-',                                             │
│        final: '-',                                               │
│        total: '-',                                               │
│      }                                                           │
│    }))                                                           │
│                                                                  │
│ 5. Passes to <RosterTable data={transformedData} />             │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ RosterTable.tsx                                                  │
│                                                                  │
│ Receives: { sectionId?: string, data?: Array<...> }             │
│                                                                  │
│ useEffect logic (line 45-88):                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ IF !sectionId (CourseDetail passes undefined):              │ │
│ │   → Uses data prop directly                                 │ │
│ │   → Maps to internal RosterEntry format:                    │ │
│ │     {                                                       │ │
│ │       id: String(student.id),                               │ │
│ │       userId: student.id,                                   │ │
│ │       enrollmentDate: new Date().toISOString(),            │ │
│ │       status: student.status,                               │ │
│ │       grade: student.grades?.total || 'N/A',               │ │
│ │       finalScore: 'N/A'                                     │ │
│ │     }                                                       │ │
│ │   → setRows(fallbackRows)                                   │ │
│ │                                                             │ │
│ │ IF sectionId provided:                                      │ │
│ │   → Fetches live data from API                              │ │
│ │   → enrollmentService.getSectionStudents(sectionId)        │ │
│ │   → Maps EnrolledCourse to RosterEntry                      │ │
│ │   → setRows(mapped)                                         │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ State Management:                                               │
│   - rows: RosterEntry[] (final data to display)                 │
│   - searchTerm: string (filter input)                           │
│   - sortField: 'userId' | 'enrollmentDate' | 'status'           │
│   - sortDirection: 'asc' | 'desc'                               │
│   - notes: Record<string, string> (studentId → note text)       │
│                                                                  │
│ useMemo filteredAndSortedData (line 112-133):                   │
│   1. Filter rows by searchTerm (matches userId or status)       │
│   2. Sort by sortField in sortDirection                         │
│   3. Return filtered & sorted array                             │
│                                                                  │
│ Renders: Table with filteredAndSortedData                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Backend API Endpoints

### 4.1 Primary Endpoint: Get Section Students

**Endpoint:** `GET /api/enrollments/section/{sectionId}/students`

**Used By:** `EnrollmentService.getSectionStudents(sectionId)`

#### Request

| Aspect | Value |
|--------|-------|
| **Method** | GET |
| **URL** | `/api/enrollments/section/{sectionId}/students` |
| **Path Parameters** | `sectionId` (string | number) - The section ID to fetch students for |
| **Headers** | `Authorization: Bearer {accessToken}` |
| **Query Parameters** | None |
| **Request Body** | None |

#### Response

**Success (200 OK):**

```typescript
// Can be returned as either:
// Option 1: Direct array
EnrolledCourse[]

// Option 2: Paginated wrapper
{
  data?: EnrolledCourse[];
  total?: number;
}
```

**EnrolledCourse Response Structure:**

```json
{
  "id": "enrollment-uuid-string",
  "userId": 12345,
  "sectionId": "section-id-string",
  "status": "enrolled",
  "grade": "A",
  "finalScore": 92.5,
  "enrollmentDate": "2024-09-01T00:00:00.000Z",
  "canDrop": false,
  "dropDeadline": "2024-09-15T23:59:59.000Z",
  "course": {
    "id": "course-id",
    "name": "Introduction to Computer Science",
    "code": "CS101",
    "description": "Fundamentals of programming",
    "credits": 3,
    "level": "FRESHMAN"
  },
  "section": {
    "id": "section-id",
    "sectionNumber": "001",
    "maxCapacity": 40,
    "currentEnrollment": 35,
    "location": "Room 201"
  },
  "semester": {
    "id": "semester-id",
    "name": "Fall 2024",
    "startDate": "2024-09-01T00:00:00.000Z",
    "endDate": "2024-12-15T00:00:00.000Z"
  },
  "prerequisites": []
}
```

#### Error Responses

| Status Code | Meaning | Example Response |
|-------------|---------|------------------|
| 401 | Unauthorized - Invalid/missing token | Redirects to `/login` |
| 403 | Forbidden - User not instructor of this section | `{ "message": "Access denied" }` |
| 404 | Section not found | `{ "message": "Section not found" }` |
| 500 | Internal server error | Backend error message |

### 4.2 Related Endpoints (Not Used in Students Tab but Available)

| Endpoint | Method | Purpose | Used In Feature? |
|----------|--------|---------|------------------|
| `/enrollments/my-courses` | GET | Get student's enrolled courses | ❌ No (Student dashboard) |
| `/enrollments/available` | GET | Get available courses for enrollment | ❌ No |
| `/enrollments/register` | POST | Enroll in a section | ❌ No |
| `/enrollments/{enrollmentId}` | DELETE | Drop a course | ❌ No |
| `/enrollments/section/{sectionId}/waitlist` | GET | Get waitlisted students | ❌ No (future feature) |
| `/enrollments/section/{sectionId}/instructor` | GET | Get section instructor | ❌ No |
| `/enrollments/section/{sectionId}/tas` | GET | Get section TAs | ❌ No |
| `/enrollments/teaching` | GET | Get instructor's teaching courses | ✅ Yes (parent component) |

### 4.3 API Client Configuration

**Base URL Configuration:**

```typescript
// src/services/api/config.ts
export const API_BASE_URL =
  import.meta.env.MODE === 'development' ? '/api' : 'http://localhost:8081/api';
```

**Development Mode:**
- Vite proxies `/api` → `http://localhost:8081/api`
- Avoids CORS issues during local development

**Production Mode:**
- Direct connection to `http://localhost:8081/api`
- Requires proper CORS configuration on backend

**Authentication:**

```typescript
// Intercepted by ApiClient (src/services/api/client.ts)
const accessToken = localStorage.getItem(TOKEN_KEYS.ACCESS_TOKEN);
if (accessToken) {
  headers['Authorization'] = `Bearer ${accessToken}`;
}
```

**Token Keys:**

```typescript
export const TOKEN_KEYS = {
  ACCESS_TOKEN: 'accessToken',
  REFRESH_TOKEN: 'refreshToken',
  USER: 'user',
};
```

---

## 5. Data Models & TypeScript Interfaces

### 5.1 EnrolledCourse Interface

**Source:** `src/services/api/enrollmentService.ts` (lines 15-47)

```typescript
export interface EnrolledCourse {
  /** Unique enrollment record ID (UUID string) */
  id: string;
  
  /** Student's user ID (numeric) */
  userId: number;
  
  /** Section ID this enrollment belongs to */
  sectionId: string;
  
  /** Enrollment status (e.g., "enrolled", "dropped", "completed", "waitlisted") */
  status: string;
  
  /** Letter grade (nullable) - e.g., "A", "B+", "C" */
  grade: string | null;
  
  /** Numeric final score (nullable) - e.g., 92.5 */
  finalScore: number | null;
  
  /** ISO 8601 timestamp of when student enrolled */
  enrollmentDate: string;
  
  /** Whether student can drop this course (before deadline) */
  canDrop: boolean;
  
  /** ISO 8601 timestamp of drop deadline (nullable) */
  dropDeadline: string | null;
  
  /** Nested course object */
  course: {
    id: string;
    name: string;
    code: string;
    description: string;
    credits: number;
    level: string;
  };
  
  /** Nested section object */
  section: {
    id: string;
    sectionNumber: string;
    maxCapacity: number;
    currentEnrollment: number;
    location: string;
  };
  
  /** Nested semester object */
  semester: {
    id: string;
    name: string;
    startDate: string;
    endDate: string;
  };
  
  /** Prerequisites metadata (usually empty array) */
  prerequisites: unknown[];
}
```

### 5.2 RosterEntry Interface (Internal to RosterTable)

**Source:** `src/pages/instructor-dashboard/components/RosterTable.tsx` (lines 7-14)

```typescript
export type RosterEntry = {
  /** Enrollment record ID (string) */
  id: string;
  
  /** Student's user ID (numeric) */
  userId: number;
  
  /** ISO 8601 timestamp of enrollment */
  enrollmentDate: string;
  
  /** Enrollment status string */
  status: string;
  
  /** Letter grade or 'N/A' */
  grade: string;
  
  /** Numeric final score string or 'N/A' */
  finalScore: string;
};
```

### 5.3 RosterTableProps Interface

**Source:** `src/pages/instructor-dashboard/components/RosterTable.tsx` (lines 16-28)

```typescript
type RosterTableProps = {
  /** Optional section ID for live data fetching. 
   *  If provided, component fetches its own data.
   *  If omitted, uses `data` prop directly. */
  sectionId?: string;
  
  /** Fallback data array when sectionId is not provided */
  data?: Array<{
    id: number;
    name?: string;
    email?: string;
    status: string;
    grades?: { 
      total?: string;
      assignments?: string;
      quizzes?: string;
      midterm?: string;
      final?: string;
    };
  }>;
  
  /** Grades data (unused in current implementation) */
  grades?: unknown[];
  
  /** Callback for editing a student (unused in current implementation) */
  onEdit?: (student: {
    id: number;
    name: string;
    email: string;
    status: string;
    grade?: string;
  }) => void;
};
```

### 5.4 CourseDetail Local Course Type

**Source:** `src/pages/instructor-dashboard/components/CourseDetail.tsx` (lines 36-50)

```typescript
type Course = {
  id: number;
  courseCode: string;
  courseName: string;
  semester: string;
  credits: number;
  prerequisites: string[];
  description: string;
  enrolled: number;          // Total enrollment count
  capacity: number;
  schedule: string;
  room: string;
  status: 'active' | 'archived';
  averageGrade: number;
  attendanceRate: number;
};
```

### 5.5 CourseDetailProps Interface

**Source:** `src/pages/instructor-dashboard/components/CourseDetail.tsx` (lines 52-57)

```typescript
type CourseDetailProps = {
  /** Course ID to display */
  courseId: number;
  
  /** Callback to navigate back to course list */
  onBack: () => void;
  
  /** Array of all courses (used to find the specific course) */
  courses: Course[];
  
  /** Whether to use mock data instead of live API calls */
  isMockMode?: boolean;
};
```

---

## 6. State Management

### 6.1 CourseDetail Component State

**Source:** `src/pages/instructor-dashboard/components/CourseDetail.tsx`

#### Local State Variables

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `activeTab` | `string` | `'overview'` | Currently selected tab (overview, lectures, assignments, grading, students) |
| `selectedLecture` | `string` | `''` | Selected lecture for materials view |
| `showAssignmentForm` | `boolean` | `false` | Controls assignment form modal visibility |
| `assignmentForm` | `AssignmentFormData \| null` | `null` | Assignment form data |
| `editingAssignmentIndex` | `number \| null` | `null` | Index of assignment being edited |
| `gradingSubTab` | `'manual' \| 'auto'` | `'manual'` | Grading sub-tab selection |
| `uploadingInstructionId` | `number \| null` | `null` | Tracks which assignment is uploading instructions |
| `showMaterialModal` | `boolean` | `false` | Controls material upload modal visibility |
| `isUploading` | `boolean` | `false` | Material upload in progress flag |
| `materialForm` | `{ title: string; lectureId: string; file: File \| null }` | `{ title: '', lectureId: '', file: null }` | Material upload form state |

#### React Query Hooks (Students Tab Related)

| Hook | Query Key | Data Type | Enabled Condition |
|------|-----------|-----------|-------------------|
| `useQuery` for section students | `['section-students', course?.id]` | `EnrolledCourse[]` | `!!course?.id && !isMockMode` |

**Hook Implementation (lines 177-181):**

```typescript
const { data: sectionStudents = [], isLoading: isLoadingStudents } = useQuery({
  queryKey: ['section-students', course?.id],
  queryFn: () => EnrollmentService.getSectionStudents(course!.id),
  enabled: !!course?.id && !isMockMode,
});
```

**Variables from Query:**

| Variable | Type | Description |
|----------|------|-------------|
| `sectionStudents` | `EnrolledCourse[]` | Array of enrolled students (defaults to `[]`) |
| `isLoadingStudents` | `boolean` | Loading state for the query |

### 6.2 RosterTable Component State

**Source:** `src/pages/instructor-dashboard/components/RosterTable.tsx`

#### Local State Variables

| Variable | Type | Initial Value | Purpose | Lines |
|----------|------|---------------|---------|-------|
| `searchTerm` | `string` | `''` | Text input for filtering students | 37 |
| `sortField` | `'userId' \| 'enrollmentDate' \| 'status'` | `'userId'` | Current sort field | 38 |
| `sortDirection` | `'asc' \| 'desc'` | `'asc'` | Sort direction | 38 |
| `rows` | `RosterEntry[]` | `[]` | Final roster data to display | 39 |
| `loading` | `boolean` | `false` | API loading state | 40 |
| `error` | `string \| null` | `null` | Error message if fetch fails | 41 |
| `notes` | `Record<string, string>` | `{}` | Map of studentId → note text | 42 |
| `noteStudentId` | `string \| null` | `null` | Currently editing note's student ID | 43 |
| `noteText` | `string` | `''` | Current note text being edited | 44 |

#### Computed Values

| Variable | Type | Dependencies | Purpose | Lines |
|----------|------|--------------|---------|-------|
| `filteredAndSortedData` | `RosterEntry[]` | `rows`, `searchTerm`, `sortField`, `sortDirection` | Filtered and sorted student list using `useMemo` | 112-133 |

**useMemo Implementation:**

```typescript
const filteredAndSortedData = useMemo(
  () =>
    rows
      .filter((student) => {
        const searchLower = searchTerm.toLowerCase();
        return (
          String(student.userId).toLowerCase().includes(searchLower) ||
          student.status.toLowerCase().includes(searchLower)
        );
      })
      .sort((a, b) => {
        let comparison = 0;
        if (sortField === 'userId') {
          comparison = a.userId - b.userId;
        } else if (sortField === 'enrollmentDate') {
          comparison =
            new Date(a.enrollmentDate).getTime() - new Date(b.enrollmentDate).getTime();
        } else {
          comparison = a.status.localeCompare(b.status);
        }
        return sortDirection === 'asc' ? comparison : -comparison;
      }),
  [rows, searchTerm, sortField, sortDirection]
);
```

---

## 7. Implementation Details

### 7.1 CourseDetail Component - Students Tab

**File:** `src/pages/instructor-dashboard/components/CourseDetail.tsx`  
**Lines:** 1081-1101

#### Data Fetching (lines 177-181)

```typescript
const { data: sectionStudents = [], isLoading: isLoadingStudents } = useQuery({
  queryKey: ['section-students', course?.id],
  queryFn: () => EnrollmentService.getSectionStudents(course!.id),
  enabled: !!course?.id && !isMockMode,
});
```

**Key Points:**
- Uses React Query for data fetching and caching
- Query key includes `course?.id` for proper cache invalidation
- Defaults to empty array `[]` to prevent undefined errors
- Only enabled when course exists AND not in mock mode
- Uses `course!.id` (non-null assertion) because `enabled` guarantees course exists

#### Students Tab Rendering (lines 1081-1101)

```typescript
{activeTab === 'students' && (
  <div
    className={`${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-gray-200'} rounded-xl p-6 border shadow-sm`}
  >
    <RosterTable
      data={sectionStudents.map((student: any, index: number) => ({
        id: student.id || student.userId || index + 1,
        name:
          `${student.firstName || ''} ${student.lastName || ''}`.trim() ||
          `Student ${index + 1}`,
        email: student.email || `student${index + 1}@edu.com`,
        status: 'Enrolled',
        grades: {
          assignments: '-',
          quizzes: '-',
          midterm: '-',
          final: '-',
          total: '-',
        },
      }))}
    />
  </div>
)}
```

**Key Points:**
- Does NOT pass `sectionId` prop to RosterTable
- Passes transformed `data` prop instead
- Transforms `EnrolledCourse` to simplified format
- Hardcodes status as `'Enrolled'` (ignores actual enrollment status)
- Hardcodes all grades as `'-'` (doesn't use actual grade data from backend)
- Provides fallback names/emails using index if data missing

**Data Transformation Details:**

| Source Field (EnrolledCourse) | Target Field (RosterTable data) | Transformation Logic |
|-------------------------------|--------------------------------|---------------------|
| `student.id` OR `student.userId` OR `index + 1` | `id` | Fallback chain: id → userId → index+1 |
| `student.firstName` + `student.lastName` | `name` | Concatenated, trimmed, fallback to `Student {index+1}` |
| `student.email` | `email` | Direct or fallback to `student{index+1}@edu.com` |
| Hardcoded | `status` | Always `'Enrolled'` |
| Hardcoded | `grades.assignments` | Always `'-'` |
| Hardcoded | `grades.quizzes` | Always `'-'` |
| Hardcoded | `grades.midterm` | Always `'-'` |
| Hardcoded | `grades.final` | Always `'-'` |
| Hardcoded | `grades.total` | Always `'-'` |

**⚠️ Important Limitation:**
The current implementation does NOT use the actual grade data from the backend (`student.grade`, `student.finalScore`). These fields are available in `EnrolledCourse` but are discarded during transformation.

### 7.2 RosterTable Component

**File:** `src/pages/instructor-dashboard/components/RosterTable.tsx`  
**Total Lines:** 357

#### Data Initialization (useEffect - lines 45-88)

```typescript
useEffect(() => {
  if (!sectionId) {
    // Fallback mode: use data prop
    const fallbackRows = data.map((student) => ({
      id: String(student.id),
      userId: student.id,
      enrollmentDate: new Date().toISOString(),
      status: student.status,
      grade: student.grades?.total || 'N/A',
      finalScore: 'N/A',
    }));
    setRows(fallbackRows);
    return;
  }

  // Live mode: fetch from API
  const fetchRoster = async () => {
    try {
      setLoading(true);
      setError(null);
      const enrollments = await enrollmentService.getSectionStudents(sectionId);
      const mapped = enrollments.map((enrollment: EnrolledCourse) => ({
        id: enrollment.id,
        userId: enrollment.userId,
        enrollmentDate: enrollment.enrollmentDate,
        status: enrollment.status,
        grade: enrollment.grade || 'N/A',
        finalScore:
          enrollment.finalScore === null || enrollment.finalScore === undefined
            ? 'N/A'
            : String(enrollment.finalScore),
      }));
      setRows(mapped);
    } catch (err) {
      console.error('Failed to fetch section students', err);
      const message = err instanceof Error ? err.message : 'Failed to load section students';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  fetchRoster();
}, [sectionId, data]);
```

**Two Operating Modes:**

| Mode | Trigger | Data Source | Behavior |
|------|---------|-------------|----------|
| **Fallback Mode** | `sectionId` is `undefined` or falsy | `data` prop | Maps prop data to RosterEntry format |
| **Live Mode** | `sectionId` is provided | API call | Fetches from backend, maps to RosterEntry |

**Current Usage:** CourseDetail uses **Fallback Mode** (does not pass `sectionId`).

#### Search Functionality (lines 114-120)

```typescript
.filter((student) => {
  const searchLower = searchTerm.toLowerCase();
  return (
    String(student.userId).toLowerCase().includes(searchLower) ||
    student.status.toLowerCase().includes(searchLower)
  );
})
```

**Searchable Fields:**
- Student ID (converted to string)
- Status

**Note:** Does NOT search by student name/email (because RosterEntry doesn't include these fields in the current implementation).

#### Sort Functionality (lines 89-96, 121-133)

```typescript
const handleSort = (field: 'userId' | 'enrollmentDate' | 'status') => {
  if (sortField === field) {
    setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
  } else {
    setSortField(field);
    setSortDirection('asc');
  }
};
```

**Sort Logic:**
- Clicking same field toggles direction
- Clicking different field resets to ascending
- Numeric comparison for `userId`
- Date comparison for `enrollmentDate`
- String comparison for `status`

#### Notes Feature (lines 97-107, 271-329)

```typescript
const openNoteModal = (studentId: string) => {
  setNoteStudentId(studentId);
  setNoteText(notes[studentId] || '');
};

const saveNote = () => {
  if (noteStudentId !== null) {
    setNotes((prev) => ({ ...prev, [noteStudentId]: noteText }));
    setNoteStudentId(null);
    setNoteText('');
  }
};
```

**Notes Implementation:**
- Stored in component state (NOT persisted to backend)
- Notes are lost on component unmount
- Displayed inline below student ID in table
- Modal for editing (textarea with save/cancel)
- StickyNote icon button in each row

#### Table Rendering (lines 179-282)

**Columns:**

| Column | Field | Formatting | Sortable |
|--------|-------|------------|----------|
| Student ID | `student.userId` | Font medium | ✅ Yes |
| Enrollment Date | `student.enrollmentDate` | `MMM DD, YYYY` format | ✅ Yes |
| Status | `student.status` | Badge (indigo bg, capitalized) | ✅ Yes |
| Grade | `student.grade` | Plain text | ❌ No |
| Final Score | `student.finalScore` | Plain text | ❌ No |
| Notes | Action button | StickyNote icon | ❌ No |

**Date Formatting (lines 109-112):**

```typescript
const formatDate = (value: string) =>
  new Date(value).toLocaleDateString('en-US', {
    month: 'short',
    day: '2-digit',
    year: 'numeric',
  });
```

**Performance Optimization:**
- Only renders first 100 rows: `filteredAndSortedData.slice(0, 100)`
- Shows warning if more than 100 results

**Empty State:**
- Shows search-specific message if no matches
- Shows generic message if no students enrolled

### 7.3 EnrollmentService

**File:** `src/services/api/enrollmentService.ts`  
**Total Lines:** 210

#### getSectionStudents Method (lines 120-125)

```typescript
getSectionStudents: async (sectionId: string | number): Promise<EnrolledCourse[]> => {
  const response = await ApiClient.get<EnrolledCourse[] | PaginatedResponse<EnrolledCourse>>(
    `/enrollments/section/${String(sectionId)}/students`
  );
  return extractArray(response);
},
```

**Helper Function - extractArray (lines 8-13):**

```typescript
const extractArray = <T>(payload: T[] | PaginatedResponse<T> | null | undefined): T[] => {
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload.data)) return payload.data;
  return [];
};
```

**Purpose:** Handles both direct array responses and paginated wrapper responses.

#### Class Wrapper (lines 186-210)

```typescript
export class EnrollmentService {
  static getMyCourses = enrollmentService.getMyCourses;
  static getAvailableCourses = enrollmentService.getAvailableCourses;
  static enrollInSection = enrollmentService.enrollInSection;
  static dropCourse = enrollmentService.dropCourse;
  static getSectionStudents = enrollmentService.getSectionStudents;
  static getSectionWaitlist = enrollmentService.getSectionWaitlist;
  static getSectionInstructor = enrollmentService.getSectionInstructor;
  static getSectionTAs = enrollmentService.getSectionTAs;
  static getSectionStaffMembers = enrollmentService.getSectionStaffMembers;
  static assignInstructor = enrollmentService.assignInstructor;
  static assignTA = enrollmentService.assignTA;
  static getTeachingCourses = enrollmentService.getTeachingCourses;

  static register(data: { sectionId: number }): Promise<EnrolledCourse> {
    return enrollmentService.enrollInSection(data.sectionId);
  }

  static drop(enrollmentId: number | string): Promise<{ message?: string }> {
    return enrollmentService.dropCourse(String(enrollmentId));
  }

  static getEnrollmentDetails(enrollmentId: number | string): Promise<EnrolledCourse> {
    return ApiClient.get(`/enrollments/${enrollmentId}`);
  }
}
```

**Note:** Both object and class exports are provided for flexibility. CourseDetail uses the class version: `EnrollmentService.getSectionStudents()`.

---

## 8. Data Transformation Pipeline

### 8.1 Complete Transformation Flow

```
┌──────────────────────────────────────────────────────────────┐
│ Backend API Response (EnrolledCourse)                        │
│                                                              │
│ [                                                            │
│   {                                                          │
│     id: "enrollment-uuid",                                   │
│     userId: 12345,                                           │
│     sectionId: "section-123",                                │
│     status: "enrolled",                                      │
│     grade: "A",                                              │
│     finalScore: 92.5,                                        │
│     enrollmentDate: "2024-09-01T00:00:00.000Z",             │
│     firstName: "John",  ← ⚠️ NOT in actual response!         │
│     lastName: "Doe",    ← ⚠️ NOT in actual response!         │
│     email: "john@edu.com" ← ⚠️ NOT in actual response!       │
│   }                                                          │
│ ]                                                            │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ CourseDetail Transformation (line 1087-1101)                │
│                                                              │
│ sectionStudents.map((student, index) => ({                  │
│   id: student.id || student.userId || index + 1,            │
│   name: `${student.firstName || ''} ${student.lastName || ''}`.trim() || `Student ${index + 1}`, │
│   email: student.email || `student${index + 1}@edu.com`,    │
│   status: 'Enrolled',  ← ⚠️ HARDCODED                       │
│   grades: {                                                   │
│     assignments: '-',  ← ⚠️ HARDCODED                        │
│     quizzes: '-',      ← ⚠️ HARDCODED                        │
│     midterm: '-',      ← ⚠️ HARDCODED                        │
│     final: '-',        ← ⚠️ HARDCODED                        │
│     total: '-',        ← ⚠️ HARDCODED                        │
│   }                                                           │
│ }))                                                           │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ RosterTable Receives: Array of {                            │
│   id, name, email, status, grades                           │
│ }                                                            │
│                                                              │
│ Since sectionId NOT provided, uses fallback mode:           │
│                                                              │
│ data.map((student) => ({                                    │
│   id: String(student.id),                                   │
│   userId: student.id,                                       │
│   enrollmentDate: new Date().toISOString(), ← ⚠️ CURRENT    │
│   status: student.status,                                   │
│   grade: student.grades?.total || 'N/A',  ← Always 'N/A'    │
│   finalScore: 'N/A',                      ← ⚠️ HARDCODED     │
│ }))                                                          │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Displayed in Table:                                          │
│                                                              │
│ Student ID  | Enrollment Date | Status  | Grade | Final Score│
│ 12345       | Apr 14, 2026   | Enrolled| N/A   | N/A        │
│ 12346       | Apr 14, 2026   | Enrolled| N/A   | N/A        │
└──────────────────────────────────────────────────────────────┘
```

### 8.2 Data Loss Points

| Stage | Lost Data | Reason |
|-------|-----------|--------|
| CourseDetail Transformation | `firstName`, `lastName`, `email` | Not present in `EnrolledCourse` from backend |
| CourseDetail Transformation | `grade`, `finalScore` | Not passed to RosterTable (hardcoded to '-') |
| CourseDetail Transformation | `status` | Hardcoded to 'Enrolled' instead of using actual value |
| RosterTable Fallback Mode | Real `enrollmentDate` | Uses `new Date()` instead of actual date |
| RosterTable Fallback Mode | Student name/email | Not available in data prop format |

**⚠️ Critical Issue:** The backend `EnrolledCourse` interface does NOT include `firstName`, `lastName`, or `email` fields. These fields would need to be added to the backend response or fetched separately.

---

## 9. Complete Variable & Props Reference

### 9.1 CourseDetail Component Variables

| Variable | Type | Source | Used in Students Tab? | Purpose |
|----------|------|--------|----------------------|---------|
| `courseId` | `number` | Props | ✅ Yes | Course ID from URL/route |
| `onBack` | `() => void` | Props | ❌ No | Navigate back to course list |
| `courses` | `Course[]` | Props | ✅ Yes | Array to find current course |
| `isMockMode` | `boolean` | Props (default: false) | ✅ Yes | Toggle mock/live data |
| `isDark` | `boolean` | ThemeContext | ✅ Yes | Dark mode flag |
| `primaryHex` | `string` | ThemeContext | ❌ No | Primary color hex code |
| `t` | `(key: string) => string` | LanguageContext | ❌ No | Translation function |
| `activeTab` | `string` | useState | ✅ Yes | Current tab selection |
| `course` | `Course` | Derived from `courses.find()` | ✅ Yes | Current course object |
| `sectionStudents` | `EnrolledCourse[]` | useQuery | ✅ Yes | Fetched student data |
| `isLoadingStudents` | `boolean` | useQuery | ❌ No (unused) | Loading state |

### 9.2 RosterTable Component Variables

| Variable | Type | Source | Purpose |
|----------|------|--------|---------|
| `sectionId` | `string` (optional) | Props | Live data fetch trigger |
| `data` | `Array<...>` (optional) | Props | Fallback data array |
| `searchTerm` | `string` | useState | Filter input value |
| `sortField` | `'userId' \| 'enrollmentDate' \| 'status'` | useState | Current sort field |
| `sortDirection` | `'asc' \| 'desc'` | useState | Sort direction |
| `rows` | `RosterEntry[]` | useState | Final display data |
| `loading` | `boolean` | useState | API loading flag |
| `error` | `string \| null` | useState | Error message |
| `notes` | `Record<string, string>` | useState | Student notes storage |
| `noteStudentId` | `string \| null` | useState | Note editing target |
| `noteText` | `string` | useState | Note text input |
| `filteredAndSortedData` | `RosterEntry[]` | useMemo | Computed display data |
| `isDark` | `boolean` | ThemeContext | Theme flag |
| `t` | `(key: string) => string` | LanguageContext | Translation function |

### 9.3 API Request Variables

| Variable | Value | Source | Purpose |
|----------|-------|--------|---------|
| `API_BASE_URL` | `/api` (dev) or `http://localhost:8081/api` (prod) | config.ts | Base URL for all API calls |
| `accessToken` | From localStorage | TOKEN_KEYS.ACCESS_TOKEN | Bearer token for auth |
| `sectionId` | `course.id` from CourseDetail | CourseDetail props | Path parameter for API |

---

## 10. User Interactions

### 10.1 Tab Navigation

**Trigger:** User clicks "Students" tab in CourseDetail

**Code Path:**
```typescript
// Line 206 in CourseDetail.tsx
const tabs = [
  { id: 'overview', label: t('dashboard'), icon: BookOpen },
  { id: 'lectures', label: t('lectures'), icon: Video },
  { id: 'assignments', label: t('assignments'), icon: FileText },
  { id: 'grading', label: t('grading'), icon: CheckCircle },
  { id: 'students', label: t('students'), icon: Users },
];

// Line 449-463: Tab buttons
{tabs.map((tab) => (
  <button
    key={tab.id}
    onClick={() => setActiveTab(tab.id)}  // ← Sets active tab
    className={`... ${activeTab === tab.id ? 'border-indigo-600 ...' : '...'}`}
  >
    <tab.icon size={18} />
    <span>{tab.label}</span>
  </button>
))}

// Line 1081: Conditional rendering
{activeTab === 'students' && (
  <RosterTable ... />
)}
```

### 10.2 Search Interaction

**User Flow:**
1. User types in search input
2. `searchTerm` state updates (onChange)
3. `filteredAndSortedData` recomputes (useMemo)
4. Table re-renders with filtered data

**Code:**
```typescript
// Search Input (line 161-171)
<input
  type="text"
  placeholder={t('searchStudentsPlaceholder')}
  value={searchTerm}
  onChange={(e) => setSearchTerm(e.target.value)}
  className="..."
/>

// Filter Logic (line 114-120)
rows.filter((student) => {
  const searchLower = searchTerm.toLowerCase();
  return (
    String(student.userId).toLowerCase().includes(searchLower) ||
    student.status.toLowerCase().includes(searchLower)
  );
})
```

**Searchable Fields:**
- Student ID (numeric)
- Status (string)

**Case-Insensitive:** Yes (uses `.toLowerCase()`)

### 10.3 Sort Interaction

**User Flow:**
1. User clicks column header (Student ID, Enrollment Date, or Status)
2. `handleSort()` called with field name
3. Toggles direction if same field, resets to 'asc' if different field
4. `filteredAndSortedData` recomputes with new sort

**Code:**
```typescript
// Sort Handler (line 89-96)
const handleSort = (field: 'userId' | 'enrollmentDate' | 'status') => {
  if (sortField === field) {
    setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
  } else {
    setSortField(field);
    setSortDirection('asc');
  }
};

// Example Header (line 186-193)
<th className="p-3 text-left">
  <button
    onClick={() => handleSort('userId')}
    className="flex items-center gap-1 hover:text-indigo-600 font-semibold"
  >
    Student ID
    <ArrowUpDown size={14} />
  </button>
</th>
```

**Sort Comparison Logic:**

| Field | Comparison Method | Example |
|-------|------------------|---------|
| `userId` | Numeric subtraction | `a.userId - b.userId` |
| `enrollmentDate` | Date timestamp comparison | `new Date(a.enrollmentDate).getTime() - new Date(b.enrollmentDate).getTime()` |
| `status` | String localeCompare | `a.status.localeCompare(b.status)` |

### 10.4 Notes Interaction

**User Flow:**
1. User clicks StickyNote icon in a row
2. Modal opens with existing note (if any) or blank
3. User types note text
4. User clicks "Save"
5. Note stored in `notes` state map
6. Note displays below student ID in table

**Code:**
```typescript
// Open Note Modal (line 97-100)
const openNoteModal = (studentId: string) => {
  setNoteStudentId(studentId);
  setNoteText(notes[studentId] || '');
};

// Save Note (line 102-107)
const saveNote = () => {
  if (noteStudentId !== null) {
    setNotes((prev) => ({ ...prev, [noteStudentId]: noteText }));
    setNoteStudentId(null);
    setNoteText('');
  }
};

// Display Note in Table (line 227-232)
{notes[student.id] && (
  <div className="text-xs mt-1 italic">
    Note: {notes[student.id]}
  </div>
)}

// Note Button (line 261-271)
<button
  onClick={() => openNoteModal(student.id)}
  className={`... ${notes[student.id] ? 'text-amber-600 ...' : '...'}`}
  title={notes[student.id] ? 'Edit Note' : 'Add Note'}
>
  <StickyNote size={16} />
</button>
```

**⚠️ Note Limitation:**
- Notes are NOT persisted to backend
- Notes stored only in component state
- Lost on component unmount/page navigation
- No database integration currently

---

## 11. Loading, Error & Edge Cases

### 11.1 Loading States

**CourseDetail Level:**

```typescript
const { data: sectionStudents = [], isLoading: isLoadingStudents } = useQuery({...});
```

- `isLoadingStudents` is available but NOT used in Students Tab rendering
- Tab shows RosterTable immediately with empty array if loading

**RosterTable Level:**

```typescript
{loading && (
  <div className="flex items-center gap-2 py-3 text-sm text-slate-500">
    <Loader2 size={16} className="animate-spin" />
    Loading roster...
  </div>
)}
```

- Only active in Live Mode (when `sectionId` provided)
- Shows spinner + text during API fetch
- Controlled by `loading` state in RosterTable

### 11.2 Error Handling

**CourseDetail Level:**
- React Query handles errors internally
- No error UI shown in Students Tab
- Errors logged to console by React Query

**RosterTable Level:**

```typescript
{error && (
  <div className="mb-4 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">
    {error}
  </div>
)}
```

- Shows red error banner if API fetch fails
- Error message from caught exception
- Only active in Live Mode

**Error Handling in Live Mode Fetch:**

```typescript
try {
  setLoading(true);
  setError(null);
  const enrollments = await enrollmentService.getSectionStudents(sectionId);
  // ... success handling
} catch (err) {
  console.error('Failed to fetch section students', err);
  const message = err instanceof Error ? err.message : 'Failed to load section students';
  setError(message);
} finally {
  setLoading(false);
}
```

### 11.3 Edge Cases

#### Empty Student List

```typescript
{filteredAndSortedData.length === 0 && (
  <tr>
    <td className="p-6 text-center" colSpan={6}>
      {searchTerm ? t('noStudentsMatch') : t('noStudentsEnrolled')}
    </td>
  </tr>
)}
```

- Shows contextual message based on search state
- Uses i18n keys for translation support

#### Missing Student Data

```typescript
id: student.id || student.userId || index + 1,
name: `${student.firstName || ''} ${student.lastName || ''}`.trim() || `Student ${index + 1}`,
email: student.email || `student${index + 1}@edu.com`,
```

- Fallback chain for missing fields
- Uses index-based fallbacks

#### Large Roster (>100 students)

```typescript
{filteredAndSortedData.slice(0, 100).map((student, index) => (...))}

{filteredAndSortedData.length > 100 && (
  <div className="mt-4 text-sm text-center">
    {t('showingFirst100')} {filteredAndSortedData.length} {t('results')}
  </div>
)}
```

- Only renders first 100 rows
- Shows warning message with total count

#### Course Not Found

```typescript
if (!course) {
  return (
    <div className="flex items-center justify-center">
      <div className="text-center">
        <h2>Course Not Found</h2>
        <button onClick={onBack}>Back to Courses</button>
      </div>
    </div>
  );
}
```

- Early return if course not in courses array
- Shows error message with back button

---

## 12. Mock Mode vs Live Mode

### 12.1 Mode Comparison

| Aspect | Mock Mode (`isMockMode = true`) | Live Mode (`isMockMode = false`) |
|--------|--------------------------------|----------------------------------|
| **API Calls** | ❌ Disabled | ✅ Enabled |
| **Data Source** | Parent component's `courses` prop | Backend API |
| **Query Enabled** | `enabled: false` | `enabled: true` |
| **sectionStudents** | Empty array `[]` | Fetched from `/api/enrollments/section/{id}/students` |
| **RosterTable Mode** | Fallback Mode (uses `data` prop) | Would use Live Mode if `sectionId` provided |
| **Enrollment Date** | Current timestamp (`new Date()`) | Actual enrollment date from backend |
| **Grades** | All `'-'` or `'N/A'` | Actual grades if passed through |

### 12.2 Mock Mode Behavior

**CourseDetail Query:**

```typescript
const { data: sectionStudents = [], isLoading: isLoadingStudents } = useQuery({
  queryKey: ['section-students', course?.id],
  queryFn: () => EnrollmentService.getSectionStudents(course!.id),
  enabled: !!course?.id && !isMockMode,  // ← Disabled in mock mode
});
```

**Result:** `sectionStudents` remains `[]` (default value)

### 12.3 Live Mode Behavior

**When `isMockMode = false`:**

1. Query executes API call
2. Response populates `sectionStudents`
3. Data transformed and passed to RosterTable
4. RosterTable uses fallback mode (still doesn't fetch its own data)

**⚠️ Current Limitation:** Even in live mode, RosterTable doesn't use its built-in live fetching because CourseDetail doesn't pass `sectionId` prop.

---

## 13. Styling & UI/UX

### 13.1 Theme Support

**Dark/Light Mode:**

```typescript
const { isDark, primaryHex = '#3b82f6' } = useTheme() as any;
```

**Conditional Styling Pattern:**

```typescript
className={`${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-gray-200'} rounded-xl p-6 border shadow-sm`}
```

| Element | Dark Mode | Light Mode |
|---------|-----------|------------|
| Background | `bg-white/5` (5% white) | `bg-white` |
| Border | `border-white/10` (10% white) | `border-gray-200` |
| Text (primary) | `text-white` | `text-gray-900` |
| Text (secondary) | `text-slate-400` | `text-gray-600` |
| Text (tertiary) | `text-slate-500` | `text-gray-500` |
| Hover | `hover:bg-white/5` | `hover:bg-gray-50` |

### 13.2 Responsive Design

**Container:**

```typescript
<div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
```

- Max width: 7xl (1280px)
- Horizontal padding: 4 (1rem) on mobile, 6 (1.5rem) on sm+
- Vertical padding: 6 (1.5rem)

**Table:**

```typescript
<div className="overflow-x-auto">
  <table className="min-w-full text-sm">
```

- Horizontal scroll on small screens
- Full width table
- Small text size (0.875rem)

### 13.3 Status Badge Styling

```typescript
<span className="px-3 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-700 capitalize">
  {student.status}
</span>
```

- Pill-shaped badge (rounded-full)
- Indigo color scheme
- Small text, medium weight
- Capitalized status text

### 13.4 Accessibility

**Semantic HTML:**
- Uses `<table>`, `<thead>`, `<tbody>` for tabular data
- Proper `<th>` for headers
- `<button>` for interactive elements

**ARIA Considerations:**
- Buttons have descriptive text
- Tooltips on note button (`title` attribute)
- Color contrast meets WCAG standards

### 13.5 Icons Used

| Icon | Library | Size | Usage |
|------|---------|------|-------|
| `Users` | lucide-react | 18 | Students tab icon |
| `ArrowLeft` | lucide-react | 20 | Back button |
| `Search` | lucide-react | 18 | Search input icon |
| `ArrowUpDown` | lucide-react | 14 | Sort indicators |
| `Calendar` | lucide-react | 14 | Date display |
| `StickyNote` | lucide-react | 16 | Note button |
| `Loader2` | lucide-react | 16 | Loading spinner |
| `X` | lucide-react | 18 | Close modal button |

---

## 14. Related Features & Cross-References

### 14.1 Instructor Dashboard Integration

**File:** `src/pages/instructor-dashboard/InstructorDashboard.tsx`

The InstructorDashboard also fetches section students for the roster tab:

```typescript
// Lines 479-483
const { data: sectionStudentsLive } = useQuery({
  queryKey: ['section-students', activeSectionId],
  queryFn: () => EnrollmentService.getSectionStudents(Number(activeSectionId)),
  enabled: !isMockMode && !!activeSectionId && activeTab === 'roster',
});
```

**Key Difference:**
- InstructorDashboard uses `activeSectionId` (section-level)
- CourseDetail uses `course.id` (course-level, which may differ from section ID)

### 14.2 TA Dashboard Integration

**File:** `src/pages/ta-dashboard/TADashboard.tsx`

TAs also fetch section students:

```typescript
// Lines 694-702
const { data: studentsBySectionLive } = useQuery({
  queryKey: ['ta-students', teachingCoursesLive.map((course) => course.sectionId)],
  queryFn: async () => {
    const result: Record<string, any[]> = {};
    for (const course of teachingCoursesLive) {
      const rows = await EnrollmentService.getSectionStudents(course.sectionId);
      result[course.sectionId] = rows.map((row) => ({
        id: `${course.sectionId}-${row.userId}`,
        sectionId: course.sectionId,
        userId: row.userId,
        enrollmentDate: row.enrollmentDate,
        status: row.status,
        grade: row.grade,
        finalScore: row.finalScore,
      }));
    }
    return result;
  },
  enabled: !isMockMode && teachingCoursesLive?.length > 0,
});
```

### 14.3 Roster Tab in InstructorDashboard

**File:** `src/pages/instructor-dashboard/InstructorDashboard.tsx` (line 1172)

```typescript
<RosterTable
  sectionId={activeSectionId}
  data={rosterOverrides[activeSectionId]}
  grades={sectionGradesLive}
  onEdit={handleEditStudent}
/>
```

**Key Difference:**
- InstructorDashboard passes `sectionId` prop (enables live fetching)
- CourseDetail does NOT pass `sectionId` prop (uses fallback only)

### 14.4 WaitlistTable Component

**File:** `src/pages/instructor-dashboard/components/WaitlistTable.tsx`

Similar pattern to RosterTable but for waitlisted students:

```typescript
const { data: enrollments, loading, error } = useApi(async () => {
  return await enrollmentService.getSectionWaitlist(sectionId);
});
```

### 14.5 Course Service - Related Methods

**File:** `src/services/api/courseService.ts`

While not directly used in Students Tab, these methods are available:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `getCourseSections(courseId)` | `/sections/course/{courseId}` | Get all sections of a course |
| `getSectionSchedules(sectionId)` | `/schedules/section/{sectionId}` | Get section schedule |

### 14.6 Grades Service Integration

**File:** `src/services/api/gradesService.ts`

Grades can be fetched for a section:

```typescript
static async getCourseGrades(courseId: number): Promise<any> {
  return ApiClient.get(`/grades/courses/${courseId}`);
}
```

**Note:** Currently NOT used in CourseDetail's Students Tab, but available for future enhancement.

---

## 15. Debugging & Troubleshooting

### 15.1 Common Issues

#### Issue 1: Students Not Showing

**Symptoms:** Empty table or "No students enrolled" message

**Possible Causes:**
1. Backend not returning data
2. Wrong sectionId being passed
3. Mock mode enabled

**Debugging Steps:**

```typescript
// 1. Check if query is enabled
console.log('Course ID:', course?.id);
console.log('Mock Mode:', isMockMode);

// 2. Check API response
const { data: sectionStudents, isLoading, error } = useQuery({
  queryKey: ['section-students', course?.id],
  queryFn: async () => {
    const result = await EnrollmentService.getSectionStudents(course!.id);
    console.log('API Response:', result); // ← Add this temporarily
    return result;
  },
  enabled: !!course?.id && !isMockMode,
});

// 3. Check transformation
console.log('Transformed Data:', sectionStudents.map(s => ({ id: s.id, userId: s.userId })));
```

**Solution:**
- Ensure backend is running on `http://localhost:8081`
- Verify `course.id` matches a valid section ID
- Check browser Network tab for API response

#### Issue 2: Student Names Showing as "Student 1", "Student 2"

**Cause:** Backend `EnrolledCourse` doesn't include `firstName`, `lastName`, `email`

**Current Code:**
```typescript
name: `${student.firstName || ''} ${student.lastName || ''}`.trim() || `Student ${index + 1}`,
```

**Solutions:**

**Option A: Backend Enhancement**
Modify backend to include user details in enrollment response:
```json
{
  "id": "enrollment-uuid",
  "userId": 12345,
  "user": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@edu.com"
  }
}
```

**Option B: Separate User Fetch**
```typescript
// In CourseDetail or RosterTable
const { data: users } = useQuery({
  queryKey: ['users', sectionStudents.map(s => s.userId)],
  queryFn: () => UserService.getUsersByIds(sectionStudents.map(s => s.userId)),
  enabled: sectionStudents.length > 0,
});
```

**Option C: Use userId as Display**
```typescript
name: `User #${student.userId}`,
```

#### Issue 3: Grades Not Displaying

**Cause:** Grades are hardcoded to `'-'` in CourseDetail transformation

**Current Code:**
```typescript
grades: {
  assignments: '-',
  quizzes: '-',
  midterm: '-',
  final: '-',
  total: '-',
}
```

**Solution:** Use actual grade data from backend

```typescript
grades: {
  assignments: '-',  // Would need separate assignments grades endpoint
  quizzes: '-',      // Would need separate quizzes grades endpoint
  midterm: '-',      // Would need midterm grade from backend
  final: '-',        // Would need final grade from backend
  total: student.grade || '-',  // ← Use EnrolledCourse.grade
}
```

#### Issue 4: 401 Unauthorized Error

**Cause:** Missing or invalid access token

**Debugging:**
```typescript
// Check if token exists
console.log('Access Token:', localStorage.getItem('accessToken'));
```

**Solution:**
- Ensure user is logged in
- Check token expiration
- Verify backend auth configuration

#### Issue 5: CORS Error in Production

**Cause:** Backend CORS not configured for frontend domain

**Error Message:**
```
Access to fetch at 'http://localhost:8081/api/...' from origin 'http://localhost:5176' has been blocked by CORS policy
```

**Solution:**
Backend must whitelist frontend URL in CORS configuration:
```typescript
// NestJS backend example
app.enableCors({
  origin: ['http://localhost:5176', 'https://yourdomain.com'],
  credentials: true,
});
```

### 15.2 Debugging Tools

#### React DevTools

- Inspect component props and state
- View React Query cache in "Components" tab
- Check hook dependencies

#### Browser Network Tab

- Filter by `students` to see API call
- Check request URL, headers, response
- Verify status code (200, 401, 404, 500)

#### Console Logging

Add temporary logs in CourseDetail:

```typescript
// Before RosterTable render
console.log('=== Students Tab Debug ===');
console.log('Course ID:', course?.id);
console.log('Section Students:', sectionStudents);
console.log('Transformed Data:', sectionStudents.map((student, index) => ({
  id: student.id || student.userId || index + 1,
  name: `${student.firstName || ''} ${student.lastName || ''}`.trim() || `Student ${index + 1}`,
  status: 'Enrolled',
})));
```

#### React Query DevTools

Install and use React Query DevTools to:
- View query cache state
- See query status (loading, success, error)
- Manually invalidate queries for testing

### 15.3 Performance Optimization

#### Current Optimizations

1. **useMemo for filtered/sorted data:**
   ```typescript
   const filteredAndSortedData = useMemo(() => {...}, [rows, searchTerm, sortField, sortDirection]);
   ```

2. **Row limit (100 max):**
   ```typescript
   filteredAndSortedData.slice(0, 100)
   ```

3. **React Query caching:**
   ```typescript
   queryKey: ['section-students', course?.id]  // Cached by course ID
   ```

#### Potential Improvements

1. **Virtual scrolling for large rosters:**
   - Use `react-window` or `@tanstack/react-virtual`
   - Render only visible rows

2. **Pagination:**
   - Backend supports pagination
   - Implement "Load More" or page numbers

3. **Debounced search:**
   ```typescript
   const debouncedSearchTerm = useDebounce(searchTerm, 300);
   ```

4. **Prefetch on tab hover:**
   ```typescript
   queryClient.prefetchQuery({
     queryKey: ['section-students', course?.id],
     queryFn: () => EnrollmentService.getSectionStudents(course!.id),
   });
   ```

### 15.4 Testing Recommendations

#### Unit Tests

```typescript
describe('RosterTable', () => {
  it('should display student list from data prop', () => {
    const mockData = [
      { id: 1, name: 'John Doe', email: 'john@edu.com', status: 'Enrolled' }
    ];
    render(<RosterTable data={mockData} />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });

  it('should filter students by search term', () => {
    render(<RosterTable data={mockStudents} />);
    fireEvent.change(screen.getByPlaceholderText(/search/i), {
      target: { value: '12345' }
    });
    expect(screen.getAllByRole('row')).toHaveLength(2); // header + 1 student
  });

  it('should sort by student ID', () => {
    render(<RosterTable data={mockStudents} />);
    fireEvent.click(screen.getByText(/student id/i));
    // Verify sort order
  });
});
```

#### Integration Tests

```typescript
describe('CourseDetail Students Tab', () => {
  it('should fetch and display section students', async () => {
    mockEnrollmentService.getSectionStudents.mockResolvedValue(mockEnrollments);
    render(<CourseDetail courseId={1} onBack={jest.fn()} courses={mockCourses} />);
    
    fireEvent.click(screen.getByText(/students/i));
    
    await waitFor(() => {
      expect(screen.getByText('Student Name')).toBeInTheDocument();
    });
  });
});
```

---

## Appendix A: File Locations Quick Reference

| File | Path | Lines | Purpose |
|------|------|-------|---------|
| CourseDetail Component | `src/pages/instructor-dashboard/components/CourseDetail.tsx` | 1198 | Main course detail with tabs |
| RosterTable Component | `src/pages/instructor-dashboard/components/RosterTable.tsx` | 357 | Reusable student roster table |
| EnrollmentService | `src/services/api/enrollmentService.ts` | 210 | Enrollment API service layer |
| ApiClient | `src/services/api/client.ts` | ~200 | HTTP client with auth |
| API Config | `src/services/api/config.ts` | ~20 | API base URL configuration |
| InstructorDashboard | `src/pages/instructor-dashboard/InstructorDashboard.tsx` | 1440 | Parent dashboard component |
| CoursesPage | `src/pages/instructor-dashboard/components/CoursesPage.tsx` | ~400 | Course list page |
| LanguageContext | `src/pages/instructor-dashboard/contexts/LanguageContext.tsx` | ~1200 | i18n translations |
| ThemeContext | `src/pages/instructor-dashboard/contexts/ThemeContext.tsx` | ~50 | Theme management |

## Appendix B: API Endpoints Quick Reference

| Endpoint | Method | Used In | Purpose |
|----------|--------|---------|---------|
| `/enrollments/section/{sectionId}/students` | GET | ✅ Students Tab | Get enrolled students |
| `/enrollments/teaching` | GET | Parent component | Get instructor's courses |
| `/courses/{id}/materials` | GET | Lectures Tab | Get course materials |
| `/assignments` | GET | Assignments Tab | Get course assignments |
| `/grades/courses/{courseId}` | GET | Not currently used | Get course grades |

## Appendix C: Key React Query Configuration

```typescript
// Default React Query config (using library defaults)
{
  staleTime: 0,              // Data considered stale immediately
  cacheTime: 5 * 60 * 1000, // Cache persists for 5 minutes
  refetchOnWindowFocus: true, // Refetch on window focus
  refetchOnMount: true,      // Refetch on component mount
  retry: 3,                  // Retry failed requests 3 times
  retryDelay: exponential    // Exponential backoff
}
```

## Appendix D: Environment Variables

| Variable | Purpose | Default (Dev) | Default (Prod) |
|----------|---------|---------------|----------------|
| `VITE_API_BASE_URL` | Backend API URL | (uses `/api` proxy) | `http://localhost:8081/api` |
| `VITE_AI_ATTENDANCE_URL` | AI attendance service | (uses `/ai-attendance` proxy) | `http://127.0.0.1:8000` |
| `VITE_AI_QUIZ_URL` | AI quiz service | (uses `/ai-quiz` proxy) | `http://127.0.0.1:8001` |

---

**Document End**

*For questions or updates to this documentation, contact the development team.*
