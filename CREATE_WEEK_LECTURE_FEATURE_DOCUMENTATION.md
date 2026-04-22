# Create New Week for Lecture Feature - Comprehensive Documentation

> **Feature:** Create and manage weeks/lectures in a course detail screen (Lectures Tab)  
> **Location:** Instructor Dashboard → Courses → Select Course → Lectures Tab  
> **Version:** 1.0  
> **Last Updated:** April 2026  
> **Scope:** Frontend implementation - week creation, material upload, week assignment, and lecture management

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Component Architecture](#2-component-architecture)
3. [Data Flow Architecture](#3-data-flow-architecture)
4. [Backend API Endpoints](#4-backend-api-endpoints)
5. [Data Models & TypeScript Interfaces](#5-data-models--typescript-interfaces)
6. [State Management](#6-state-management)
7. [Implementation Details](#7-implementation-details)
   - [7.1 CourseDetail Component - Lectures Tab](#71-coursedetail-component---lectures-tab)
   - [7.2 UploadMaterialsPage Component](#72-uploadmaterialspage-component)
   - [7.3 Week Number Derivation](#73-week-number-derivation)
   - [7.4 Material Upload with Week Assignment](#74-material-upload-with-week-assignment)
8. [Week Creation Mechanisms](#8-week-creation-mechanisms)
   - [8.1 Simple Approach: Via CourseDetail](#81-simple-approach-via-coursedetail)
   - [8.2 Advanced Approach: Via UploadMaterialsPage](#82-advanced-approach-via-uploadmaterialspage)
   - [8.3 Structure-Based Week Creation](#83-structure-based-week-creation)
9. [Data Transformation Pipeline](#9-data-transformation-pipeline)
10. [Complete Variable & Props Reference](#10-complete-variable--props-reference)
11. [User Interactions](#11-user-interactions)
12. [Loading, Error & Edge Cases](#12-loading-error--edge-cases)
13. [Mock Mode vs Live Mode](#13-mock-mode-vs-live-mode)
14. [Styling & UI/UX](#14-styling--uiux)
15. [Related Features & Cross-References](#15-related-features--cross-references)
16. [Debugging & Troubleshooting](#16-debugging--troubleshooting)

---

## 1. Feature Overview

### 1.1 Purpose

The "Create New Week for Lecture" feature allows instructors to organize course materials by week. Weeks are dynamically created when materials are uploaded with a specific week number, and the Lectures Tab automatically renders week containers based on the uploaded materials.

### 1.2 Key Concept: Weeks are Derived from Materials

**Important:** Weeks are NOT explicitly created as standalone entities. Instead, they are **dynamically derived** from the `weekNumber` field of uploaded course materials. When you upload a material and assign it to "Week 5", Week 5 is automatically created and displayed in the Lectures Tab.

### 1.3 User Journey

1. Instructor navigates to Courses in the dashboard
2. Instructor clicks on a specific course to view details
3. Instructor clicks the **Lectures** tab
4. Instructor clicks **"Upload Material"** button
5. Instructor fills out material form:
   - Title
   - File (optional)
   - **Target Lecture/Week** (dropdown selection)
6. Upon upload, material is assigned to the selected week
7. The week automatically appears in the Lectures Tab if it didn't exist before

### 1.4 Key Capabilities

- ✅ Dynamic week creation through material upload
- ✅ Upload materials to specific weeks
- ✅ Automatic week derivation from materials
- ✅ Visual organization by week containers
- ✅ Material preview and metadata display
- ✅ Week filtering and navigation
- ✅ Support for multiple materials per week
- ✅ Responsive design with dark/light theme support

---

## 2. Component Architecture

### 2.1 Component Tree

```
InstructorDashboard
 └─ CoursesPage (when viewing course detail)
     └─ CourseDetail (courseId: number)
         ├─ Tab Navigation (overview, lectures, assignments, grading, students)
         └─ Lectures Tab (activeTab === 'lectures')
             ├─ Header with "Upload Material" button
             ├─ Week Container (for each week)
             │   ├─ Week Title (e.g., "Week 1")
             │   ├─ Lecture Entry (auto-generated)
             │   └─ Materials List
             │       ├─ Material Item
             │       └─ Material Item
             └─ Upload Material Modal
                 ├─ Title Input
                 ├─ File Upload
                 ├─ Week/Lecture Selector
                 └─ Upload Button
```

### 2.2 Component Files

| Component | File Path | Purpose |
|-----------|-----------|---------|
| **CourseDetail** | `src/pages/instructor-dashboard/components/CourseDetail.tsx` | Main course detail with Lectures Tab |
| **UploadMaterialsPage** | `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx` | Advanced material upload with week management |
| **CourseService** | `src/services/api/courseService.ts` | API service for course materials |
| **MaterialBundles** | `src/utils/materialBundles.ts` | Utility for grouping materials by week |

### 2.3 Component Relationships

```
CourseDetail (lines 192-200)
  │
  ├─ Fetches: courseMaterials via useQuery
  │   └─ Hook: CourseService.getMaterials(course!.id)
  │   └─ Query Key: ['course-materials', course?.id]
  │
  ├─ Derives weeks: dynamicWeeks (line 192-193)
  │   └─ Array.from(new Set(courseMaterials.map(m => m.weekNumber || 1)))
  │
  ├─ Generates lectures: lectures (line 199-202)
  │   └─ weeksToRender.map(week => ({ id: `${week}.1`, label: `Lecture ${week}.1` }))
  │
  └─ Renders: Weeks with materials (lines 654-728)
      │
      └─ For each week in weeksToRender:
          ├─ Filters materials for that week
          ├─ Renders week container with title
          ├─ Renders lecture entry
          └─ Renders materials list
```

---

## 3. Data Flow Architecture

### 3.1 High-Level Data Flow

```
Backend API (NestJS)
    │
    ├─ GET /api/courses/{courseId}/materials
    │
    ▼
ApiClient (fetch wrapper)
    │
    ├─ Adds Authorization header (Bearer token)
    └─ Returns CourseMaterial[] or { data: CourseMaterial[] }
    │
    ▼
CourseService.getMaterials(courseId)
    │
    ├─ Calls ApiClient.get()
    ├─ Handles paginated response
    └─ Returns CourseMaterial[]
    │
    ▼
React Query (useQuery hook in CourseDetail)
    │
    ├─ Query Key: ['course-materials', course?.id]
    ├─ Caching & refetch logic
    └─ Returns { data: courseMaterials, isLoading: isLoadingMaterials }
    │
    ▼
CourseDetail Component - Week Derivation
    │
    ├─ Extracts unique weekNumbers: dynamicWeeks
    │   └─ Array.from(new Set(courseMaterials.map(m => m.weekNumber || 1)))
    │
    ├─ Sorts weeks: (a, b) => a - b
    │
    ├─ Generates lecture entries for each week
    │
    └─ Renders week containers with materials
    │
    ▼
User Uploads Material
    │
    ├─ Selects week from dropdown
    ├─ Submits form with weekNumber
    │
    ▼
POST /api/courses/{courseId}/materials
    │
    ├─ Body: { title, materialType, weekNumber, isPublished }
    │
    ▼
Backend creates material with weekNumber
    │
    ▼
React Query invalidates ['course-materials', course?.id]
    │
    ▼
Refetch triggers, new week appears if weekNumber is new
```

### 3.2 Week Creation Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ User Action: Upload Material to Week 5                         │
│                                                                  │
│ 1. Click "Upload Material" button                               │
│ 2. Fill form:                                                    │
│    - Title: "Chapter 5 Slides"                                   │
│    - File: chapter5.pdf                                          │
│    - Target Lecture: "Lecture 5.1 - Introduction"               │
│ 3. Click "Upload"                                                │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ handleSaveMaterial() (line 367-398)                            │
│                                                                  │
│ 1. Extract weekNumber from lectureId:                           │
│    weekNumber: parseInt(materialForm.lectureId.split('.')[0])   │
│    Result: 5                                                     │
│                                                                  │
│ 2. If file upload:                                              │
│    - Create FormData with weekNumber field                      │
│    - POST to /api/courses/{id}/materials/document               │
│                                                                  │
│ 3. If text-only:                                                │
│    - POST JSON with weekNumber field                            │
│    - POST to /api/courses/{id}/materials                        │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Backend Response                                                 │
│                                                                  │
│ {                                                                │
│   "materialId": "uuid",                                         │
│   "title": "Chapter 5 Slides",                                  │
│   "weekNumber": 5,  ← New week created!                         │
│   "materialType": "document",                                   │
│   "isPublished": 1,                                             │
│   "createdAt": "2024-10-15T10:30:00.000Z"                      │
│ }                                                                │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ CourseDetail Re-render                                           │
│                                                                  │
│ 1. Query invalidates and refetches                              │
│ 2. courseMaterials now includes new material with weekNumber: 5 │
│ 3. dynamicWeeks recalculates:                                    │
│    Before: [1, 2, 3, 4]                                         │
│    After:  [1, 2, 3, 4, 5]  ← Week 5 added!                    │
│ 4. weeksToRender updates                                         │
│ 5. lectures regenerates:                                         │
│    [..., { id: "5.1", label: "Lecture 5.1 - Introduction" }]   │
│ 6. New week container renders in UI                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Backend API Endpoints

### 4.1 Primary Endpoint: Get Course Materials

**Endpoint:** `GET /api/courses/{courseId}/materials`

**Used By:** `CourseService.getMaterials(courseId)`

#### Request

| Aspect | Value |
|--------|-------|
| **Method** | GET |
| **URL** | `/api/courses/{courseId}/materials` |
| **Path Parameters** | `courseId` (number) - The course ID to fetch materials for |
| **Headers** | `Authorization: Bearer {accessToken}` |
| **Query Parameters** | None (optional: `?weekNumber=`, `?materialType=`) |
| **Request Body** | None |

#### Response

**Success (200 OK):**

```typescript
// Can be returned as either:
// Option 1: Direct array
CourseMaterial[]

// Option 2: Paginated wrapper (CourseMaterialsResponse)
{
  data: CourseMaterial[];
  meta?: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

**CourseMaterial Response Structure:**

```json
{
  "materialId": "uuid-string",
  "courseId": "123",
  "course": {
    "id": "123",
    "name": "Introduction to Computer Science",
    "code": "CS101",
    "credits": 3,
    "level": "FRESHMAN"
  },
  "fileId": "file-uuid",
  "driveFileId": "google-drive-file-id",
  "materialType": "document",
  "title": "Chapter 5 Slides",
  "description": "Object-oriented programming concepts",
  "externalUrl": "https://drive.google.com/...",
  "driveViewUrl": "https://drive.google.com/file/d/.../view",
  "driveDownloadUrl": "https://drive.google.com/uc?export=download&id=...",
  "fileName": "chapter5.pdf",
  "youtubeVideoId": "youtube-video-id",
  "orderIndex": 1,
  "weekNumber": 5,
  "viewCount": 45,
  "downloadCount": 23,
  "uploadedBy": 101,
  "uploader": {
    "userId": 101,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@university.edu"
  },
  "isPublished": 1,
  "publishedAt": "2024-10-15T10:30:00.000Z",
  "createdAt": "2024-10-15T10:30:00.000Z",
  "updatedAt": "2024-10-15T10:30:00.000Z"
}
```

### 4.2 Create Material Endpoint

**Endpoint:** `POST /api/courses/{courseId}/materials`

**Used By:** `CourseService.createMaterial(courseId, data)`

#### Request

| Aspect | Value |
|--------|-------|
| **Method** | POST |
| **URL** | `/api/courses/{courseId}/materials` |
| **Path Parameters** | `courseId` (number) |
| **Headers** | `Authorization: Bearer {accessToken}`, `Content-Type: application/json` |
| **Request Body (JSON):** |

```json
{
  "title": "Chapter 5 Slides",
  "materialType": "document",
  "description": "Object-oriented programming concepts",
  "weekNumber": 5,
  "isPublished": true,
  "orderIndex": 1
}
```

### 4.3 Upload Document Endpoint

**Endpoint:** `POST /api/courses/{courseId}/materials/document`

**Used By:** `CourseService.uploadDocument(courseId, formData)`

#### Request

| Aspect | Value |
|--------|-------|
| **Method** | POST |
| **URL** | `/api/courses/{courseId}/materials/document` |
| **Path Parameters** | `courseId` (number) |
| **Headers** | `Authorization: Bearer {accessToken}`, `Content-Type: multipart/form-data` |
| **Request Body (FormData):** |

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `document` | File | ✅ Yes | The file to upload |
| `title` | string | ✅ Yes | Material title |
| `materialType` | string | ✅ Yes | Type: "document", "video", etc. |
| `weekNumber` | number | ✅ Yes | **Week number to assign** |
| `isPublished` | string | No | "true" or "false" |
| `description` | string | No | Material description |

### 4.4 Create Structure Item Endpoint

**Endpoint:** `POST /api/courses/{courseId}/structure`

**Used By:** `structureService.createStructureItem(courseId, data)`

#### Request

| Aspect | Value |
|--------|-------|
| **Method** | POST |
| **URL** | `/api/courses/{courseId}/structure` |
| **Path Parameters** | `courseId` (string) |
| **Headers** | `Authorization: Bearer {accessToken}`, `Content-Type: application/json` |
| **Request Body (JSON):** |

```json
{
  "title": "Week 5 - Object Oriented Programming",
  "organizationType": "lecture",
  "weekNumber": 5,
  "orderIndex": 5,
  "description": "Introduction to OOP concepts"
}
```

**organizationType Options:**
- `"lecture"` - Lecture content
- `"lab"` - Lab session
- `"section"` - Discussion section
- `"tutorial"` - Tutorial session

### 4.5 Get Course Structure Endpoint

**Endpoint:** `GET /api/courses/{courseId}/structure`

**Used By:** `structureService.getStructure(courseId)`

#### Response

```typescript
{
  data: CourseStructure[];
  byWeek: {
    "1": CourseStructure[];
    "2": CourseStructure[];
    "5": CourseStructure[];
    // ... weeks with structures
  };
}
```

---

## 5. Data Models & TypeScript Interfaces

### 5.1 CourseMaterial Interface

**Source:** `src/services/api/courseService.ts` (lines 29-66)

```typescript
export interface CourseMaterial {
  /** Unique material ID (UUID string) */
  materialId: string;
  
  /** Course ID this material belongs to */
  courseId: string;
  
  /** Nested course object */
  course?: {
    id: string;
    name: string;
    code: string;
    credits: number;
    level: string;
  } | null;
  
  /** File ID (legacy) */
  fileId?: string | null;
  
  /** File metadata */
  file?: unknown | null;
  
  /** Google Drive file ID */
  driveFileId?: string | null;
  
  /** Material type */
  materialType: 'document' | 'video' | 'lecture' | 'slide' | 'reading' | 'link' | 'other';
  
  /** Material title */
  title: string;
  
  /** Material description */
  description?: string;
  
  /** External URL (for links, videos) */
  externalUrl?: string | null;
  
  /** Google Drive view URL */
  driveViewUrl?: string | null;
  
  /** Google Drive download URL */
  driveDownloadUrl?: string | null;
  
  /** Original file name */
  fileName?: string | null;
  
  /** YouTube video ID */
  youtubeVideoId?: string | null;
  
  /** Display order */
  orderIndex?: number;
  
  /** ⭐ WEEK NUMBER - Key field for week assignment */
  weekNumber?: number | null;
  
  /** View count */
  viewCount?: number;
  
  /** Download count */
  downloadCount?: number;
  
  /** User ID who uploaded */
  uploadedBy?: number;
  
  /** Uploader info */
  uploader?: {
    userId: number;
    firstName: string;
    lastName: string;
    email: string;
  } | null;
  
  /** Publication status (0 or 1) */
  isPublished: number;
  
  /** Published timestamp */
  publishedAt?: string | null;
  
  /** Created timestamp */
  createdAt: string;
  
  /** Updated timestamp */
  updatedAt?: string;
}
```

### 5.2 CourseStructure Interface

**Source:** `src/services/api/courseService.ts` (lines 68-81)

```typescript
export interface CourseStructure {
  /** Organization ID */
  organizationId: string;
  
  /** Course ID */
  courseId: string;
  
  /** Material ID (if linked) */
  materialId: string | null;
  
  /** Linked material */
  material: CourseMaterial | null;
  
  /** ⭐ ORGANIZATION TYPE - Defines the type of week content */
  organizationType: 'lecture' | 'lab' | 'section' | 'tutorial';
  
  /** Title of the structure */
  title: string;
  
  /** ⭐ WEEK NUMBER - Associates structure with a week */
  weekNumber: number;
  
  /** Display order */
  orderIndex: number;
  
  /** Description */
  description?: string;
  
  /** Timestamps */
  createdAt?: string;
  updatedAt?: string;
}
```

### 5.3 CourseMaterialsResponse Interface

**Source:** `src/services/api/courseService.ts` (lines 83-90)

```typescript
export interface CourseMaterialsResponse {
  data: CourseMaterial[];
  meta?: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

### 5.4 CourseStructureResponse Interface

**Source:** `src/services/api/courseService.ts` (lines 92-95)

```typescript
export interface CourseStructureResponse {
  data: CourseStructure[];
  byWeek: Record<string, CourseStructure[]>;  // Keyed by week number
}
```

### 5.5 MaterialBundle Interface (Utility)

**Source:** `src/utils/materialBundles.ts`

```typescript
export interface MaterialBundle {
  /** Unique bundle key */
  key: string;
  
  /** Week number for this bundle */
  weekNumber: number | null;
  
  /** Base title */
  baseTitle: string;
  
  /** Materials in this bundle */
  materials: CourseMaterial[];
}
```

### 5.6 MaterialFormState (UploadMaterialsPage)

**Source:** `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx` (lines 46-53)

```typescript
type MaterialFormState = {
  /** Material title */
  title: string;
  
  /** Material type */
  materialType: 'document' | 'video' | 'lecture' | 'slide' | 'link' | 'reading' | 'other';
  
  /** Description */
  description: string;
  
  /** ⭐ WEEK NUMBER - String input that gets parsed to number */
  weekNumber: string;
  
  /** Publication status */
  isPublished: boolean;
};
```

---

## 6. State Management

### 6.1 CourseDetail Component State

**Source:** `src/pages/instructor-dashboard/components/CourseDetail.tsx`

#### Local State Variables (Lectures Tab Related)

| Variable | Type | Initial Value | Purpose | Lines |
|----------|------|---------------|---------|-------|
| `activeTab` | `string` | `'overview'` | Current tab selection | 62 |
| `showMaterialModal` | `boolean` | `false` | Controls upload modal visibility | 80 |
| `isUploading` | `boolean` | `false` | Upload in progress flag | 81 |
| `materialForm` | `{ title: string; lectureId: string; file: File \| null }` | `{ title: '', lectureId: '', file: null }` | Material upload form state | 82-86 |

#### React Query Hooks (Lectures Tab Related)

| Hook | Query Key | Data Type | Enabled Condition | Lines |
|------|-----------|-----------|-------------------|-------|
| `useQuery` for course materials | `['course-materials', course?.id]` | `CourseMaterial[]` | `!!course?.id && !isMockMode` | 95-99 |

**Hook Implementation:**

```typescript
const { data: courseMaterials = [], isLoading: isLoadingMaterials } = useQuery({
  queryKey: ['course-materials', course?.id],
  queryFn: () => CourseService.getMaterials(course!.id),
  enabled: !!course?.id && !isMockMode,
});
```

#### Computed Values (Week Derivation)

| Variable | Type | Dependencies | Purpose | Lines |
|----------|------|--------------|---------|-------|
| `dynamicWeeks` | `number[]` | `courseMaterials` | Extract unique week numbers from materials | 192-193 |
| `weeksToRender` | `number[]` | `isMockMode`, `dynamicWeeks` | Final week list (fallback to [1,2,3,4] in mock mode) | 197 |
| `lectures` | `Array<{ id: string; label: string }>` | `weeksToRender` | Generate lecture entries for each week | 199-202 |

**dynamicWeeks Implementation:**

```typescript
const dynamicWeeks = Array.from(new Set(courseMaterials.map((m: any) => m.weekNumber || 1))).sort(
  (a: any, b: any) => a - b
);
```

**Key Points:**
- Uses `Set` to extract unique week numbers
- Defaults to `1` if `weekNumber` is null/undefined
- Sorts numerically in ascending order

**weeksToRender Implementation:**

```typescript
const weeksToRender = isMockMode || dynamicWeeks.length === 0 ? [1, 2, 3, 4] : dynamicWeeks;
```

**Key Points:**
- Falls back to `[1, 2, 3, 4]` in mock mode or if no materials
- Otherwise uses dynamically derived weeks

**lectures Implementation:**

```typescript
const lectures = weeksToRender.map((week) => ({
  id: `${week}.1`,
  label: `Lecture ${week}.1 - Introduction`,
}));
```

**Key Points:**
- Generates one lecture per week
- Uses format `{week}.1` for lecture ID
- Label format: `Lecture {week}.1 - Introduction`

### 6.2 UploadMaterialsPage Component State

**Source:** `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx`

#### Local State Variables (Week Related)

| Variable | Type | Initial Value | Purpose | Lines |
|----------|------|---------------|---------|-------|
| `createForm` | `MaterialFormState` | `defaultFormState` | Create modal form state (includes weekNumber) | 186 |
| `editForm` | `MaterialFormState` | `defaultFormState` | Edit modal form state | 187 |
| `weekFilter` | `string` | `'all'` | Week filter dropdown value | 222 |

#### Computed Values (Week Options)

| Variable | Type | Dependencies | Purpose | Lines |
|----------|------|--------------|---------|-------|
| `weekOptions` | `Array<{ value: string; label: string }>` | `structureResponse.byWeek` | Generate week dropdown options | 309-313 |

**weekOptions Implementation:**

```typescript
const weekOptions = useMemo(() => {
  const dynamic = Object.keys(structureResponse.byWeek || {})
    .map((week) => ({ value: week, label: `Week ${week}` }));
  return [{ value: 'all', label: 'All Weeks' }, ...dynamic];
}, [structureResponse.byWeek]);
```

---

## 7. Implementation Details

### 7.1 CourseDetail Component - Lectures Tab

**File:** `src/pages/instructor-dashboard/components/CourseDetail.tsx`  
**Lines:** 637-728

#### Lectures Tab Rendering

```typescript
{activeTab === 'lectures' && (
  <div className="space-y-6">
    {/* Header with Upload Button */}
    <div className="flex justify-between items-center mb-4">
      <h2 className={`text-2xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
        {t('lectures')}
      </h2>
      <button
        onClick={() => setShowMaterialModal(true)}
        className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors text-sm font-medium"
      >
        <Plus size={16} />
        Upload Material
      </button>
    </div>

    {/* Week Containers */}
    <div className="space-y-4">
      {weeksToRender.map((week) => {
        const weekMaterials = courseMaterials.filter(
          (m: any) => m.weekNumber === week || (!m.weekNumber && week === 1)
        );

        return (
          <div
            key={week}
            className={`${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-gray-200'} rounded-xl p-6 border shadow-sm`}
          >
            <h3 className={`font-semibold ${isDark ? 'text-white' : 'text-gray-900'} mb-4`}>
              Week {week}
            </h3>
            
            {/* Lecture Entry */}
            <div className="space-y-3">
              <div className={`flex items-center justify-between p-4 ...`}>
                <div className="flex items-center gap-3">
                  <Video size={20} className="text-indigo-600" />
                  <div>
                    <div className={`font-medium ...`}>
                      Lecture {week}.1 - Introduction
                    </div>
                    <div className={`text-sm ...`}>
                      {course.schedule || 'Scheduled via portal'}
                    </div>
                  </div>
                </div>
                <CheckCircle size={20} className="text-green-600" />
              </div>

              {/* Materials List */}
              {weekMaterials.length > 0 ? (
                <div className="mt-4 space-y-2 pl-4 border-l-2 border-indigo-100 ml-4">
                  <h4 className={`text-xs font-semibold uppercase ...`}>
                    Materials
                  </h4>
                  {weekMaterials.map((material: any) => (
                    <div key={material.materialId || material.id} className={`...`}>
                      <div className="flex items-center gap-2">
                        <FileText size={16} className="text-indigo-500" />
                        <span>{material.title}</span>
                      </div>
                      <span className={`text-xs ...`}>
                        {material.createdAt ? new Date(material.createdAt).toLocaleDateString() : 'Just now'}
                      </span>
                    </div>
                  ))}
                </div>
              ) : (
                <div className={`mt-4 pl-4 text-xs italic ...`}>
                  No materials uploaded yet for this week.
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  </div>
)}
```

**Key Points:**

1. **Week Filtering Logic (line 655-657):**
   ```typescript
   const weekMaterials = courseMaterials.filter(
     (m: any) => m.weekNumber === week || (!m.weekNumber && week === 1)
   );
   ```
   - Shows materials where `weekNumber` matches the week
   - Materials without `weekNumber` (null/undefined) are shown in Week 1

2. **Lecture Entry:**
   - Auto-generated for each week
   - Format: `Lecture {week}.1 - Introduction`
   - Shows schedule from course data

3. **Materials List:**
   - Indented under lecture with left border
   - Shows material title and upload date
   - Empty state message if no materials

### 7.2 UploadMaterialsPage Component

**File:** `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx`  
**Total Lines:** 1892

This component provides advanced week management capabilities beyond the simple CourseDetail modal.

#### Week Filter Dropdown (lines 1189-1200)

```typescript
<CleanSelect
  value={weekFilter}
  onChange={(e) => setWeekFilter(e.target.value)}
  className={`...`}
>
  {weekOptions.map((option) => (
    <option key={option.value} value={option.value}>
      {option.label}
    </option>
  ))}
</CleanSelect>
```

**weekOptions Generation (lines 309-313):**

```typescript
const weekOptions = useMemo(() => {
  const dynamic = Object.keys(structureResponse.byWeek || {})
    .map((week) => ({ value: week, label: `Week ${week}` }));
  return [{ value: 'all', label: 'All Weeks' }, ...dynamic];
}, [structureResponse.byWeek]);
```

**Key Points:**
- Dynamically generates options from course structure
- Includes "All Weeks" option
- Sorted by week number

#### Create Material Modal (lines 1416-1430)

```typescript
<div>
  <label className={`block text-sm font-medium mb-1 ...`}>
    Week Number
  </label>
  <input
    type="number"
    min="1"
    placeholder="e.g. 5"
    value={form.weekNumber}
    onChange={(e) => setForm((prev) => ({ ...prev, weekNumber: e.target.value }))}
    className={`w-full px-3 py-2 rounded-lg border text-sm ...`}
  />
</div>
```

**Key Points:**
- Free-form number input for week
- User can type any week number
- No dropdown, allowing creation of any week

### 7.3 Week Number Derivation

#### In CourseDetail (lines 192-193)

```typescript
const dynamicWeeks = Array.from(new Set(courseMaterials.map((m: any) => m.weekNumber || 1))).sort(
  (a: any, b: any) => a - b
);
```

**Process:**
1. Map all materials to their `weekNumber` values
2. Default to `1` if `weekNumber` is null/undefined
3. Create a `Set` to get unique values
4. Convert back to array
5. Sort numerically

**Example:**

```typescript
// Input: courseMaterials
[
  { title: "Chapter 1", weekNumber: 1 },
  { title: "Chapter 2", weekNumber: 2 },
  { title: "Chapter 3", weekNumber: 2 },
  { title: "Chapter 4", weekNumber: 4 },
  { title: "Syllabus", weekNumber: null },  // → defaults to 1
]

// Output: dynamicWeeks
[1, 2, 4]
```

#### In UploadMaterialsPage (lines 309-313)

```typescript
const dynamic = Object.keys(structureResponse.byWeek || {})
  .map((week) => ({ value: week, label: `Week ${week}` }));
```

**Process:**
1. Get `byWeek` object from structure response
2. Extract keys (week numbers as strings)
3. Map to dropdown options

**Example:**

```typescript
// Input: structureResponse.byWeek
{
  "1": [/* structures for week 1 */],
  "2": [/* structures for week 2 */],
  "5": [/* structures for week 5 */]
}

// Output: weekOptions (after mapping)
[
  { value: '1', label: 'Week 1' },
  { value: '2', label: 'Week 2' },
  { value: '5', label: 'Week 5' }
]
```

### 7.4 Material Upload with Week Assignment

#### handleSaveMaterial Function (lines 367-398)

```typescript
const handleSaveMaterial = async () => {
  if (!materialForm.title.trim() || !materialForm.lectureId || !course) return;

  if (materialForm.file) {
    // File upload path
    setIsUploading(true);
    try {
      const formData = new FormData();
      formData.append('document', materialForm.file);
      formData.append('title', materialForm.title.trim());
      formData.append('materialType', 'document');
      
      // ⭐ EXTRACT WEEK NUMBER FROM LECTURE ID
      formData.append('weekNumber', String(parseInt(materialForm.lectureId.split('.')[0]) || 1));
      formData.append('isPublished', 'true');

      await courseService.uploadDocument(course.id, formData);
      queryClient.invalidateQueries({ queryKey: ['course-materials', course.id] });
      setShowMaterialModal(false);
      setMaterialForm({ title: '', lectureId: '', file: null });
    } catch (error) {
      console.error('Failed to upload document', error);
    } finally {
      setIsUploading(false);
    }
  } else {
    // Text-only path
    createMaterialMutation.mutate({
      title: materialForm.title,
      materialType: 'document',
      
      // ⭐ EXTRACT WEEK NUMBER FROM LECTURE ID
      weekNumber: parseInt(materialForm.lectureId.split('.')[0]) || 1,
      isPublished: true,
    });
  }
};
```

**Week Number Extraction:**

```typescript
parseInt(materialForm.lectureId.split('.')[0]) || 1
```

**Example:**

```typescript
materialForm.lectureId = "5.1"
materialForm.lectureId.split('.') → ["5", "1"]
materialForm.lectureId.split('.')[0] → "5"
parseInt("5") → 5
Result: weekNumber = 5
```

**Fallback:** If parsing fails or returns 0, defaults to week `1`.

---

## 8. Week Creation Mechanisms

### 8.1 Simple Approach: Via CourseDetail

**User Flow:**

1. Navigate to Course → Lectures Tab
2. Click "Upload Material"
3. Fill form:
   - Title: "Chapter 5 Slides"
   - File: (optional file upload)
   - Target Lecture: Select "Lecture 5.1 - Introduction"
4. Click "Upload"

**What Happens:**

```typescript
// Week number extracted from lecture ID
lectureId: "5.1" → weekNumber: 5

// POST request
POST /api/courses/123/materials
Body: {
  "title": "Chapter 5 Slides",
  "materialType": "document",
  "weekNumber": 5,  // ← Creates Week 5
  "isPublished": true
}

// Response
{
  "materialId": "uuid",
  "weekNumber": 5,
  ...
}

// UI Update
queryClient.invalidateQueries(['course-materials', 123])
→ Refetch materials
→ dynamicWeeks recalculates: [1, 2, 3, 4] → [1, 2, 3, 4, 5]
→ New week container renders
```

**Limitations:**
- Can only upload to existing weeks (from dropdown)
- Dropdown is generated from existing materials
- Cannot create arbitrary week without material
- Week 1 is default if no selection

### 8.2 Advanced Approach: Via UploadMaterialsPage

**User Flow:**

1. Navigate to Course → Materials Page (if available)
2. Click "Create New Material"
3. Fill form:
   - Title: "Week 5 Introduction"
   - Week Number: Type "5" (free-form input)
   - Material Type: Select type
   - File: Upload files
4. Click "Create"

**What Happens:**

```typescript
// Free-form week number input
createForm.weekNumber: "5" → parseWeekNumber("5") → 5

// POST request
POST /api/courses/123/materials
Body: {
  "title": "Week 5 Introduction",
  "materialType": "document",
  "weekNumber": 5,  // ← Creates Week 5
  "isPublished": true
}

// If bundle upload (video + documents)
for each file:
  POST /api/courses/123/materials/video (or /document)
  Body includes: weekNumber: 5
```

**Advantages:**
- Free-form week number input
- Can create any week directly
- Supports bundle uploads (video + documents)
- Advanced filtering and organization

### 8.3 Structure-Based Week Creation

**Alternative Method:**

Weeks can also be created through the **Course Structure** API, which provides hierarchical organization:

```typescript
// Create structure for a week
POST /api/courses/123/structure
Body: {
  "title": "Week 5 - Object Oriented Programming",
  "organizationType": "lecture",
  "weekNumber": 5,
  "orderIndex": 5,
  "description": "Introduction to OOP concepts"
}

// Response
{
  "organizationId": "org-uuid",
  "weekNumber": 5,
  "organizationType": "lecture",
  ...
}

// This creates a structure entry in byWeek["5"]
// which can be used to populate week dropdowns
```

**Structure Types:**

| Type | Icon | Use Case |
|------|------|----------|
| `lecture` | 📹 Video | Main lecture content |
| `lab` | 🧪 Flask | Lab sessions |
| `section` | 👥 Users | Discussion sections |
| `tutorial` | 👤 User | Tutorial sessions |

**Benefits of Structure:**
- Hierarchical organization
- Multiple organization types per week
- Better course navigation for students
- Enables advanced features (quizzes, attendance per week)

---

## 9. Data Transformation Pipeline

### 9.1 Complete Transformation Flow

```
┌──────────────────────────────────────────────────────────────┐
│ Backend API Response (CourseMaterial[])                      │
│                                                              │
│ [                                                            │
│   {                                                          │
│     materialId: "uuid-1",                                    │
│     title: "Syllabus",                                       │
│     weekNumber: null,  ← No week assigned                    │
│     materialType: "document",                                │
│     createdAt: "2024-09-01T10:00:00.000Z"                   │
│   },                                                         │
│   {                                                          │
│     materialId: "uuid-2",                                    │
│     title: "Chapter 1 Slides",                               │
│     weekNumber: 1,                                           │
│     materialType: "slide",                                   │
│     createdAt: "2024-09-08T10:00:00.000Z"                   │
│   },                                                         │
│   {                                                          │
│     materialId: "uuid-3",                                    │
│     title: "Chapter 5 Slides",                               │
│     weekNumber: 5,  ← New week!                              │
│     materialType: "document",                                │
│     createdAt: "2024-10-15T10:00:00.000Z"                   │
│   }                                                          │
│ ]                                                            │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ CourseDetail - dynamicWeeks Extraction (line 192-193)       │
│                                                              │
│ courseMaterials.map(m => m.weekNumber || 1)                 │
│ → [1, 1, 5]                                                  │
│                                                              │
│ new Set([1, 1, 5])                                          │
│ → Set { 1, 5 }                                               │
│                                                              │
│ Array.from(Set)                                             │
│ → [1, 5]                                                     │
│                                                              │
│ .sort((a, b) => a - b)                                      │
│ → [1, 5]                                                     │
│                                                              │
│ Result: dynamicWeeks = [1, 5]                               │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ CourseDetail - weeksToRender (line 197)                     │
│                                                              │
│ isMockMode || dynamicWeeks.length === 0                     │
│ → false || false = false                                    │
│                                                              │
│ Result: weeksToRender = dynamicWeeks = [1, 5]              │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ CourseDetail - lectures Generation (line 199-202)           │
│                                                              │
│ weeksToRender.map(week => ({                                │
│   id: `${week}.1`,                                           │
│   label: `Lecture ${week}.1 - Introduction`                 │
│ }))                                                          │
│                                                              │
│ Result: lectures = [                                        │
│   { id: "1.1", label: "Lecture 1.1 - Introduction" },       │
│   { id: "5.1", label: "Lecture 5.1 - Introduction" }        │
│ ]                                                            │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Rendering - Week Containers (line 654-728)                  │
│                                                              │
│ weeksToRender.map(week => {                                 │
│   const weekMaterials = courseMaterials.filter(             │
│     m => m.weekNumber === week || (!m.weekNumber && week === 1) │
│   )                                                          │
│                                                              │
│   For week = 1:                                             │
│     weekMaterials = [                                        │
│       { title: "Syllabus", weekNumber: null },  ← Matches!  │
│       { title: "Chapter 1 Slides", weekNumber: 1 }          │
│     ]                                                          │
│                                                              │
│   For week = 5:                                             │
│     weekMaterials = [                                        │
│       { title: "Chapter 5 Slides", weekNumber: 5 }          │
│     ]                                                          │
│ })                                                           │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Displayed in UI:                                             │
│                                                              │
│ ┌─────────────────────────────────────┐                     │
│ │ Week 1                              │                     │
│ │ ├─ Lecture 1.1 - Introduction       │                     │
│ │ ├─ Materials:                        │                     │
│ │ │  ├─ Syllabus                       │                     │
│ │ │  └─ Chapter 1 Slides              │                     │
│ └─────────────────────────────────────┘                     │
│                                                              │
│ ┌─────────────────────────────────────┐                     │
│ │ Week 5                              │                     │
│ │ ├─ Lecture 5.1 - Introduction       │                     │
│ │ ├─ Materials:                        │                     │
│ │ │  └─ Chapter 5 Slides              │                     │
│ └─────────────────────────────────────┘                     │
└──────────────────────────────────────────────────────────────┘
```

### 9.2 Week Number Parsing

**In CourseDetail (modal upload):**

```typescript
// Extract week from lecture ID format "week.lecture"
weekNumber: parseInt(materialForm.lectureId.split('.')[0]) || 1

// Examples:
"1.1" → parseInt("1") → 1
"5.1" → parseInt("5") → 5
"10.1" → parseInt("10") → 10
"" → parseInt("") → NaN → fallback to 1
```

**In UploadMaterialsPage (parseWeekNumber helper - lines 134-139):**

```typescript
const parseWeekNumber = (value: string): number | undefined => {
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : undefined;
};

// Examples:
"5" → 5
"  10  " → 10
"" → undefined
"abc" → undefined
"0" → 0 (but treated as invalid in UI)
```

---

## 10. Complete Variable & Props Reference

### 10.1 CourseDetail Component Variables

| Variable | Type | Source | Used in Lectures Tab? | Purpose |
|----------|------|--------|----------------------|---------|
| `courseId` | `number` | Props | ✅ Yes | Course ID from URL/route |
| `courses` | `Course[]` | Props | ✅ Yes | Array to find current course |
| `isMockMode` | `boolean` | Props | ✅ Yes | Toggle mock/live data |
| `isDark` | `boolean` | ThemeContext | ✅ Yes | Dark mode flag |
| `activeTab` | `string` | useState | ✅ Yes | Current tab selection |
| `course` | `Course` | Derived | ✅ Yes | Current course object |
| `courseMaterials` | `CourseMaterial[]` | useQuery | ✅ Yes | Fetched materials data |
| `isLoadingMaterials` | `boolean` | useQuery | ❌ No (unused) | Loading state |
| `showMaterialModal` | `boolean` | useState | ✅ Yes | Upload modal visibility |
| `isUploading` | `boolean` | useState | ✅ Yes | Upload progress flag |
| `materialForm` | `{ title, lectureId, file }` | useState | ✅ Yes | Upload form state |
| `dynamicWeeks` | `number[]` | Computed | ✅ Yes | Unique week numbers |
| `weeksToRender` | `number[]` | Computed | ✅ Yes | Final week list |
| `lectures` | `Array<{id, label}>` | Computed | ✅ Yes | Lecture entries |

### 10.2 UploadMaterialsPage Variables

| Variable | Type | Source | Purpose |
|----------|------|--------|---------|
| `activeCourseId` | `string` | Computed | Current course ID |
| `createForm` | `MaterialFormState` | useState | Create form data (includes weekNumber) |
| `editForm` | `MaterialFormState` | useState | Edit form data |
| `weekFilter` | `string` | useState | Week filter value |
| `weekOptions` | `Array<{value, label}>` | Computed | Week dropdown options |
| `structureResponse` | `CourseStructureResponse` | useState | Course structure data |
| `materialsResponse` | `CourseMaterialsResponse` | useState | Materials data |
| `selectedCourseId` | `string` | useState | Selected course in dropdown |

### 10.3 API Request Variables

| Variable | Value | Source | Purpose |
|----------|-------|--------|---------|
| `API_BASE_URL` | `/api` (dev) or `http://localhost:8081/api` (prod) | config.ts | Base URL for API calls |
| `accessToken` | From localStorage | TOKEN_KEYS.ACCESS_TOKEN | Bearer token for auth |
| `courseId` | From route/props | CourseDetail/CoursesPage | Path parameter for API |

---

## 11. User Interactions

### 11.1 Upload Material Flow

**User Flow:**
1. User clicks "Upload Material" button
2. Modal opens with form
3. User fills title, selects file (optional)
4. User selects week from dropdown
5. User clicks "Upload"
6. Form submits with weekNumber
7. Modal closes on success
8. Week container appears/updates

**Code Path:**

```typescript
// Button click (line 645)
<button onClick={() => setShowMaterialModal(true)}>
  <Plus size={16} />
  Upload Material
</button>

// Form submission (line 367-398)
const handleSaveMaterial = async () => {
  // Validate
  if (!materialForm.title.trim() || !materialForm.lectureId || !course) return;
  
  // Upload file or create material
  if (materialForm.file) {
    // File upload with FormData including weekNumber
    formData.append('weekNumber', String(parseInt(materialForm.lectureId.split('.')[0]) || 1));
    await courseService.uploadDocument(course.id, formData);
  } else {
    // Text-only with weekNumber
    createMaterialMutation.mutate({
      weekNumber: parseInt(materialForm.lectureId.split('.')[0]) || 1,
      ...
    });
  }
  
  // Invalidate query to refresh
  queryClient.invalidateQueries({ queryKey: ['course-materials', course.id] });
};
```

### 11.2 Week Selection Dropdown

**Dropdown Population (line 199-202):**

```typescript
const lectures = weeksToRender.map((week) => ({
  id: `${week}.1`,
  label: `Lecture ${week}.1 - Introduction`,
}));
```

**Dropdown Rendering (line 1155-1165):**

```typescript
<CleanSelect
  value={materialForm.lectureId}
  onChange={(e) => setMaterialForm({ ...materialForm, lectureId: e.target.value })}
>
  <option value="">Select a lecture...</option>
  {lectures.map((lec) => (
    <option key={lec.id} value={lec.id}>
      {lec.label}
    </option>
  ))}
</CleanSelect>
```

**Example Dropdown:**

```
Select a lecture...
Lecture 1.1 - Introduction
Lecture 2.1 - Introduction
Lecture 3.1 - Introduction
Lecture 4.1 - Introduction
```

### 11.3 Week Navigation

**In Lectures Tab:**
- Weeks are rendered as scrollable containers
- Each week shows its materials
- No explicit "next/previous week" buttons in CourseDetail
- User scrolls to navigate between weeks

**In UploadMaterialsPage:**
- Week filter dropdown allows filtering materials by week
- "All Weeks" option shows all materials
- Selecting a week filters to only that week's materials

---

## 12. Loading, Error & Edge Cases

### 12.1 Loading States

**CourseDetail Level:**

```typescript
const { data: courseMaterials = [], isLoading: isLoadingMaterials } = useQuery({...});
```

- `isLoadingMaterials` is available but NOT used in Lectures Tab rendering
- Tab shows weeks immediately with empty materials if loading

**Loading Indicator (not currently implemented):**
- Could add spinner during material fetch
- Currently shows empty state instead

### 12.2 Error Handling

**CourseDetail Level:**
- React Query handles errors internally
- No error UI shown in Lectures Tab
- Errors logged to console by React Query

**Error Handling in Upload:**

```typescript
try {
  await courseService.uploadDocument(course.id, formData);
  queryClient.invalidateQueries({ queryKey: ['course-materials', course.id] });
  setShowMaterialModal(false);
} catch (error) {
  console.error('Failed to upload document', error);
  // ⚠️ No user-facing error message shown
}
```

**⚠️ Limitation:** Upload errors are only logged to console, not shown to user.

### 12.3 Edge Cases

#### No Materials Uploaded

```typescript
// dynamicWeeks will be empty
const dynamicWeeks = Array.from(new Set([].map(m => m.weekNumber || 1)))
→ []

// weeksToRender falls back to mock data
const weeksToRender = isMockMode || dynamicWeeks.length === 0 ? [1, 2, 3, 4] : dynamicWeeks
→ [1, 2, 3, 4]  // Shows 4 empty weeks
```

**Result:** Shows 4 empty week containers with "No materials uploaded yet" message

#### Materials Without Week Number

```typescript
// Filter logic (line 655-657)
const weekMaterials = courseMaterials.filter(
  (m: any) => m.weekNumber === week || (!m.weekNumber && week === 1)
);
```

**Behavior:**
- Materials without `weekNumber` (null/undefined) are shown in **Week 1**
- This is a fallback behavior for legacy materials

#### Large Week Numbers

```typescript
// User uploads material to week 100
weekNumber: 100

// dynamicWeeks will include it
dynamicWeeks = [1, 2, 3, 4, 100]
```

**Result:**
- Week 100 will render
- Weeks 5-99 will NOT render (no materials)
- User sees weeks 1, 2, 3, 4, 100 (gap in between)

**Potential Issue:** Non-contiguous weeks may confuse users

#### Mock Mode Behavior

```typescript
const weeksToRender = isMockMode || dynamicWeeks.length === 0 ? [1, 2, 3, 4] : dynamicWeeks
```

**In Mock Mode:**
- Always shows weeks [1, 2, 3, 4]
- Ignores actual materials
- Shows mock lecture data

### 12.4 Empty States

**Week with No Materials:**

```typescript
{weekMaterials.length > 0 ? (
  // Materials list
) : (
  <div className={`mt-4 pl-4 text-xs italic ...`}>
    No materials uploaded yet for this week.
  </div>
)}
```

**Message Variants:**
- Always shows "No materials uploaded yet for this week."
- Not customizable based on week number

---

## 13. Mock Mode vs Live Mode

### 13.1 Mode Comparison

| Aspect | Mock Mode (`isMockMode = true`) | Live Mode (`isMockMode = false`) |
|--------|--------------------------------|----------------------------------|
| **API Calls** | ❌ Disabled | ✅ Enabled |
| **Data Source** | Hardcoded mock data | Backend API |
| **Query Enabled** | `enabled: false` | `enabled: true` |
| **courseMaterials** | Empty array `[]` | Fetched from `/api/courses/{id}/materials` |
| **Weeks Rendered** | `[1, 2, 3, 4]` (hardcoded) | Derived from materials |
| **Lecture Labels** | `Lecture {week}.1 - Introduction` | Same format |
| **Materials** | None (empty list) | Actual uploaded materials |
| **Upload Functionality** | ❌ Disabled (mutation not enabled) | ✅ Enabled |

### 13.2 Mock Mode Behavior

**CourseDetail Query:**

```typescript
const { data: courseMaterials = [], isLoading: isLoadingMaterials } = useQuery({
  queryKey: ['course-materials', course?.id],
  queryFn: () => CourseService.getMaterials(course!.id),
  enabled: !!course?.id && !isMockMode,  // ← Disabled in mock mode
});
```

**Result:** `courseMaterials` remains `[]` (default value)

**Week Derivation:**

```typescript
const dynamicWeeks = Array.from(new Set([].map(m => m.weekNumber || 1)))
→ []

const weeksToRender = isMockMode || dynamicWeeks.length === 0 ? [1, 2, 3, 4] : dynamicWeeks
→ [1, 2, 3, 4]  // Because isMockMode = true
```

### 13.3 Live Mode Behavior

**When `isMockMode = false`:**

1. Query executes API call to fetch materials
2. Response populates `courseMaterials`
3. `dynamicWeeks` derives from materials
4. Weeks render with actual materials
5. Upload functionality works

---

## 14. Styling & UI/UX

### 14.1 Theme Support

**Dark/Light Mode:**

```typescript
const { isDark, primaryHex = '#3b82f6' } = useTheme() as any;
```

**Week Container Styling:**

```typescript
className={`${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-gray-200'} rounded-xl p-6 border shadow-sm`}
```

| Element | Dark Mode | Light Mode |
|---------|-----------|------------|
| Week Background | `bg-white/5` (5% white) | `bg-white` |
| Week Border | `border-white/10` (10% white) | `border-gray-200` |
| Week Title Text | `text-white` | `text-gray-900` |
| Lecture Text (secondary) | `text-slate-400` | `text-gray-600` |
| Material Text | `text-slate-200` | `text-gray-700` |
| Date Text | `text-slate-400` | `text-gray-500` |
| Hover | `hover:bg-white/10` | `hover:bg-gray-100` |

### 14.2 Week Container Layout

```typescript
<div className="rounded-xl p-6 border shadow-sm">
  <h3 className="font-semibold mb-4">Week {week}</h3>
  
  {/* Lecture Entry */}
  <div className="flex items-center justify-between p-4 rounded-lg transition-colors cursor-pointer">
    <div className="flex items-center gap-3">
      <Video size={20} className="text-indigo-600" />
      <div>
        <div className="font-medium">Lecture {week}.1 - Introduction</div>
        <div className="text-sm">Schedule info</div>
      </div>
    </div>
    <CheckCircle size={20} className="text-green-600" />
  </div>

  {/* Materials List */}
  <div className="mt-4 space-y-2 pl-4 border-l-2 border-indigo-100 ml-4">
    <h4 className="text-xs font-semibold uppercase tracking-wider mb-2">Materials</h4>
    {/* Material items */}
  </div>
</div>
```

**Visual Hierarchy:**
1. Week title (large, bold)
2. Lecture entry (icon + title + schedule + checkmark)
3. Materials section (indented with left border)
   - Material heading (small, uppercase)
   - Material items (icon + title + date)

### 14.3 Material Item Styling

```typescript
<div className="flex items-center justify-between p-3 rounded-lg text-sm">
  <div className="flex items-center gap-2">
    <FileText size={16} className="text-indigo-500" />
    <span>{material.title}</span>
  </div>
  <span className="text-xs">{formattedDate}</span>
</div>
```

**Elements:**
- FileText icon (indigo color)
- Material title
- Upload date (right-aligned, small text)

### 14.4 Responsive Design

**Container:**

```typescript
<div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
```

- Max width: 7xl (1280px)
- Horizontal padding: 4 (1rem) on mobile, 6 (1.5rem) on sm+
- Vertical padding: 6 (1.5rem)

**Week Cards:**
- Full width on all screens
- Padding adjusts for screen size

**Upload Modal:**
- Fixed positioning, centered
- Max width: `max-w-md` (28rem / 448px)
- Responsive padding: `p-4` on mobile

### 14.5 Icons Used

| Icon | Library | Size | Usage |
|------|---------|------|-------|
| `Video` | lucide-react | 20 | Lecture entry |
| `CheckCircle` | lucide-react | 20 | Completed lecture indicator |
| `FileText` | lucide-react | 16 | Material item |
| `Plus` | lucide-react | 16 | Upload button |
| `Loader2` | lucide-react | 16 | Upload spinner |

---

## 15. Related Features & Cross-References

### 15.1 Student Course View

**File:** `src/pages/student-dashboard/pages/CourseView.tsx`

Students view weeks organized by structure:

```typescript
// Lines 288-316
const byWeek = structureResponse.byWeek || {};
const weekKeys = Object.keys(byWeek).sort((a, b) => Number(a) - Number(b));

return weekKeys.map((weekKey) => {
  const lessons = (byWeek[weekKey] || [])
    .filter(item => item.material)
    .map(item => ({
      type: item.organizationType === 'lecture' ? 'video' : 'resource',
      organizationType: item.organizationType,
      ...
    }));
  
  return {
    title: `Week ${weekKey}`,
    lessons,
    ...
  };
});
```

**Key Difference:**
- Students see weeks from `structureResponse.byWeek` (hierarchical)
- Instructors see weeks from `courseMaterials` (flat list)

### 15.2 UploadMaterialsPage Advanced Features

**File:** `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx`

Provides advanced week management:

```typescript
// Week filter (line 222)
const [weekFilter, setWeekFilter] = useState('all');

// Week options from structure (lines 309-313)
const weekOptions = useMemo(() => {
  const dynamic = Object.keys(structureResponse.byWeek || {})
    .map(week => ({ value: week, label: `Week ${week}` }));
  return [{ value: 'all', label: 'All Weeks' }, ...dynamic];
}, [structureResponse.byWeek]);
```

**Additional Features:**
- Week filtering
- Material type filtering
- Search functionality
- Bundle upload (video + documents for same week)
- Edit/delete materials
- Visibility toggle

### 15.3 Material Bundles Utility

**File:** `src/utils/materialBundles.ts`

Groups materials by week for display:

```typescript
export function groupMaterialsIntoBundles(
  materials: CourseMaterial[]
): MaterialBundle[] {
  // Group by weekNumber
  // Create bundles with same weekNumber
  // Return sorted bundles
}
```

**Used By:** UploadMaterialsPage for organized display

### 15.4 Course Service - Related Methods

**File:** `src/services/api/courseService.ts`

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `getMaterials(courseId)` | `GET /courses/{id}/materials` | Get all materials |
| `createMaterial(courseId, data)` | `POST /courses/{id}/materials` | Create material with weekNumber |
| `uploadDocument(courseId, formData)` | `POST /courses/{id}/materials/document` | Upload file with weekNumber |
| `getStructure(courseId)` | `GET /courses/{id}/structure` | Get course structure by week |
| `materialService.uploadVideo` | `POST /courses/{id}/materials/video` | Upload video with weekNumber |
| `materialService.uploadFile` | `POST /courses/{id}/materials/document` | Upload file with weekNumber |
| `structureService.createStructureItem` | `POST /courses/{id}/structure` | Create structure with weekNumber |

### 15.5 Schedule Integration

**File:** `src/pages/instructor-dashboard/components/SchedulePage.tsx`

Weeks are also used in scheduling:

```typescript
// Weeks calculated from semester dates
const weekStarts = monthWeekStartDates(referenceDate);
const weeks = await Promise.all(
  weekStarts.map(startDate => ScheduleService.getWeeklyUnified(startDate))
);
```

**Connection:**
- Schedule weeks align with material weeks
- Enables "Week X" schedule view
- Attendance can be tracked per week

---

## 16. Debugging & Troubleshooting

### 16.1 Common Issues

#### Issue 1: Week Not Appearing After Upload

**Symptoms:** Upload succeeds but week doesn't show up

**Possible Causes:**
1. Backend didn't save `weekNumber`
2. Query didn't invalidate/refetch
3. `weekNumber` is null in response

**Debugging Steps:**

```typescript
// 1. Check API response
const handleSaveMaterial = async () => {
  // ... upload code
  const response = await courseService.uploadDocument(course.id, formData);
  console.log('Upload Response:', response); // ← Check weekNumber
  console.log('Response weekNumber:', response.weekNumber);
};

// 2. Check query refetch
const { data: courseMaterials } = useQuery({
  queryKey: ['course-materials', course?.id],
  queryFn: async () => {
    const result = await CourseService.getMaterials(course!.id);
    console.log('Fetched Materials:', result); // ← Check all weekNumbers
    return result;
  },
});

// 3. Check dynamicWeeks calculation
console.log('Raw weekNumbers:', courseMaterials.map(m => m.weekNumber));
console.log('dynamicWeeks:', dynamicWeeks);
console.log('weeksToRender:', weeksToRender);
```

**Solution:**
- Ensure backend returns `weekNumber` in response
- Verify query invalidation: `queryClient.invalidateQueries({ queryKey: ['course-materials', course.id] })`
- Check backend saves `weekNumber` correctly

#### Issue 2: All Materials Showing in Week 1

**Cause:** Backend not returning `weekNumber` or all materials have `weekNumber: null`

**Debugging:**

```typescript
// Check material data
console.log('Materials:', courseMaterials.map(m => ({
  title: m.title,
  weekNumber: m.weekNumber
})));

// Expected:
// [{ title: "Ch1", weekNumber: 1 }, { title: "Ch5", weekNumber: 5 }]

// If you see:
// [{ title: "Ch1", weekNumber: null }, { title: "Ch5", weekNumber: null }]
// → Backend issue: not saving/returning weekNumber
```

**Solution:**
- Check backend material creation endpoint
- Verify `weekNumber` is being saved in database
- Check API response includes `weekNumber` field

#### Issue 3: Week Dropdown Empty

**Cause:** No materials uploaded yet, so `lectures` array is empty

**Debugging:**

```typescript
// Check lectures generation
console.log('weeksToRender:', weeksToRender);
console.log('lectures:', lectures);

// If weeksToRender = [] and not in mock mode:
// → No materials = no weeks = empty dropdown
```

**Solution:**
- Upload first material to create Week 1
- Or enable mock mode for development
- Consider adding "Create Week" button independent of materials

#### Issue 4: Non-Contiguous Weeks

**Symptoms:** Weeks show as 1, 2, 5, 10 (gaps in between)

**Cause:** Materials uploaded to non-sequential weeks

**Example Scenario:**
```
Upload to Week 1 → weeks: [1]
Upload to Week 2 → weeks: [1, 2]
Upload to Week 5 → weeks: [1, 2, 5]  ← Gap!
Upload to Week 10 → weeks: [1, 2, 5, 10]  ← Bigger gap!
```

**Potential Solutions:**

**Option A: Fill Gaps Automatically**

```typescript
// In CourseDetail
const dynamicWeeks = Array.from(new Set(courseMaterials.map(m => m.weekNumber || 1))).sort((a, b) => a - b);

// Fill gaps
const maxWeek = Math.max(...dynamicWeeks);
const filledWeeks = Array.from({ length: maxWeek }, (_, i) => i + 1);

const weeksToRender = isMockMode || dynamicWeeks.length === 0 ? [1, 2, 3, 4] : filledWeeks;
```

**Option B: Show Warning**

```typescript
const hasGaps = dynamicWeeks.some((week, index) => {
  return index > 0 && week !== dynamicWeeks[index - 1] + 1;
});

if (hasGaps) {
  console.warn('Non-contiguous weeks detected. Some weeks may be skipped.');
}
```

### 16.2 Debugging Tools

#### React DevTools

- Inspect `courseMaterials` in component state
- View `dynamicWeeks` and `weeksToRender` computed values
- Check `materialForm` state during upload

#### Browser Network Tab

- Filter by `materials` to see API calls
- Check POST request includes `weekNumber`
- Verify response includes `weekNumber` field

#### Console Logging

Add temporary logs in CourseDetail:

```typescript
// After fetching materials
console.log('=== Lectures Tab Debug ===');
console.log('Course ID:', course?.id);
console.log('Materials Count:', courseMaterials.length);
console.log('Materials weekNumbers:', courseMaterials.map(m => m.weekNumber));
console.log('dynamicWeeks:', dynamicWeeks);
console.log('weeksToRender:', weeksToRender);
console.log('lectures:', lectures);

// During upload
console.log('=== Upload Debug ===');
console.log('Form lectureId:', materialForm.lectureId);
console.log('Extracted weekNumber:', parseInt(materialForm.lectureId.split('.')[0]) || 1);
```

#### React Query DevTools

- View `['course-materials', course?.id]` query state
- Manually invalidate query to test refetch
- Check query cache for stale data

### 16.3 Performance Optimization

#### Current Optimizations

1. **Memoized Computed Values:**
   - `dynamicWeeks` recalculates only when `courseMaterials` changes
   - `weeksToRender` depends on `dynamicWeeks`
   - `lectures` depends on `weeksToRender`

2. **Efficient Week Extraction:**
   ```typescript
   Array.from(new Set(courseMaterials.map(m => m.weekNumber || 1)))
   ```
   - Uses Set for O(n) unique extraction
   - Single pass through materials

3. **React Query Caching:**
   ```typescript
   queryKey: ['course-materials', course?.id]
   ```
   - Cached by course ID
   - Automatic cache invalidation on mutation

#### Potential Improvements

1. **Virtualize Week List:**
   - Use `react-window` for large number of weeks
   - Render only visible weeks

2. **Lazy Load Materials:**
   - Fetch materials per week on demand
   - Reduce initial payload

3. **Optimistic Updates:**
   ```typescript
   // Add week immediately without waiting for refetch
   createMaterialMutation.mutate(data, {
     onMutate: async (newMaterial) => {
       // Optimistically add to cache
       const previous = queryClient.getQueryData(['course-materials', course.id]);
       queryClient.setQueryData(['course-materials', course.id], old => [...old, newMaterial]);
       return { previous };
     },
   });
   ```

4. **Prefetch Next Week:**
   ```typescript
   // When user is on Week 5, prefetch Week 6 materials
   if (currentWeek) {
     queryClient.prefetchQuery({
       queryKey: ['course-materials', course.id, { week: currentWeek + 1 }],
       queryFn: () => CourseService.getMaterials(course.id, { weekNumber: currentWeek + 1 }),
     });
   }
   ```

### 16.4 Testing Recommendations

#### Unit Tests

```typescript
describe('CourseDetail - Week Derivation', () => {
  it('should extract unique week numbers from materials', () => {
    const mockMaterials = [
      { title: 'Week 1 Material', weekNumber: 1 },
      { title: 'Another Week 1', weekNumber: 1 },
      { title: 'Week 2 Material', weekNumber: 2 },
      { title: 'Week 5 Material', weekNumber: 5 },
    ];
    
    // Render component
    const { container } = render(
      <CourseDetail courseId={1} onBack={jest.fn()} courses={mockCourses} />
    );
    
    // Check weeks rendered
    const weekTitles = container.querySelectorAll('h3');
    expect(weekTitles).toHaveLength(3); // Weeks 1, 2, 5
    expect(weekTitles[0].textContent).toContain('Week 1');
    expect(weekTitles[1].textContent).toContain('Week 2');
    expect(weekTitles[2].textContent).toContain('Week 5');
  });

  it('should default to weeks 1-4 in mock mode', () => {
    const { container } = render(
      <CourseDetail courseId={1} onBack={jest.fn()} courses={mockCourses} isMockMode={true} />
    );
    
    const weekTitles = container.querySelectorAll('h3');
    expect(weekTitles).toHaveLength(4);
    expect(weekTitles[0].textContent).toContain('Week 1');
    expect(weekTitles[3].textContent).toContain('Week 4');
  });

  it('should assign materials to correct week', () => {
    const mockMaterials = [
      { materialId: '1', title: 'Week 1 Material', weekNumber: 1 },
      { materialId: '2', title: 'Week 2 Material', weekNumber: 2 },
    ];
    
    // Mock API response
    mockCourseService.getMaterials.mockResolvedValue(mockMaterials);
    
    const { getByText, queryByText } = render(
      <CourseDetail courseId={1} onBack={jest.fn()} courses={mockCourses} />
    );
    
    // Check materials in correct weeks
    expect(getByText('Week 1 Material')).toBeInTheDocument();
    expect(getByText('Week 2 Material')).toBeInTheDocument();
  });
});
```

#### Integration Tests

```typescript
describe('Upload Material Flow', () => {
  it('should create new week when material uploaded to new week', async () => {
    // Setup: Course with materials for weeks 1, 2
    mockCourseService.getMaterials.mockResolvedValue([
      { materialId: '1', title: 'Week 1', weekNumber: 1 },
      { materialId: '2', title: 'Week 2', weekNumber: 2 },
    ]);
    
    const { getByText, getByRole, findByText } = render(
      <CourseDetail courseId={1} onBack={jest.fn()} courses={mockCourses} />
    );
    
    // Initially should have weeks 1, 2
    expect(getByText('Week 1')).toBeInTheDocument();
    expect(getByText('Week 2')).toBeInTheDocument();
    
    // Upload material to week 5
    fireEvent.click(getByText('Upload Material'));
    fireEvent.change(getByPlaceholderText('e.g. Chapter_1_Slides.pdf'), {
      target: { value: 'Week 5 Material' }
    });
    
    // Select lecture 5.1 (need to add to dropdown first)
    // This depends on implementation
    
    fireEvent.click(getByRole('button', { name: /upload/i }));
    
    // After upload, should refetch and show week 5
    await findByText('Week 5');
    expect(getByText('Week 5')).toBeInTheDocument();
  });
});
```

---

## Appendix A: File Locations Quick Reference

| File | Path | Lines | Purpose |
|------|------|-------|---------|
| CourseDetail Component | `src/pages/instructor-dashboard/components/CourseDetail.tsx` | 1198 | Main course detail with Lectures Tab |
| UploadMaterialsPage | `src/pages/instructor-dashboard/components/UploadMaterialsPage.tsx` | 1892 | Advanced material upload with week management |
| CourseService | `src/services/api/courseService.ts` | 433 | Course and material API service layer |
| MaterialBundles Utility | `src/utils/materialBundles.ts` | ~120 | Group materials by week |
| InstructorDashboard | `src/pages/instructor-dashboard/InstructorDashboard.tsx` | 1440 | Parent dashboard component |
| CoursesPage | `src/pages/instructor-dashboard/components/CoursesPage.tsx` | ~400 | Course list page |
| CourseView (Student) | `src/pages/student-dashboard/pages/CourseView.tsx` | ~1200 | Student course view with weeks |

## Appendix B: API Endpoints Quick Reference

| Endpoint | Method | Used In | Purpose |
|----------|--------|---------|---------|
| `/courses/{id}/materials` | GET | ✅ Lectures Tab | Get all course materials |
| `/courses/{id}/materials` | POST | ✅ Upload Modal | Create material with weekNumber |
| `/courses/{id}/materials/document` | POST | ✅ File Upload | Upload document with weekNumber |
| `/courses/{id}/materials/video` | POST | UploadMaterialsPage | Upload video with weekNumber |
| `/courses/{id}/structure` | GET | UploadMaterialsPage | Get course structure by week |
| `/courses/{id}/structure` | POST | UploadMaterialsPage | Create structure with weekNumber |

## Appendix C: Week Number Flow Quick Reference

```
User Action → Select Lecture "5.1"
    ↓
Extract Week: "5.1".split('.')[0] → "5" → parseInt → 5
    ↓
POST /courses/{id}/materials
Body: { weekNumber: 5 }
    ↓
Backend saves material with weekNumber: 5
    ↓
Response: { materialId: "uuid", weekNumber: 5 }
    ↓
React Query invalidates ['course-materials', id]
    ↓
Refetch materials
    ↓
dynamicWeeks recalculates: [1, 2, 3, 4] → [1, 2, 3, 4, 5]
    ↓
New Week 5 container renders in UI
```

## Appendix D: Environment Variables

| Variable | Purpose | Default (Dev) | Default (Prod) |
|----------|---------|---------------|----------------|
| `VITE_API_BASE_URL` | Backend API URL | (uses `/api` proxy) | `http://localhost:8081/api` |
| `VITE_AI_ATTENDANCE_URL` | AI attendance service | (uses `/ai-attendance` proxy) | `http://127.0.0.1:8000` |
| `VITE_AI_QUIZ_URL` | AI quiz service | (uses `/ai-quiz` proxy) | `http://127.0.0.1:8001` |

## Appendix E: Common Week-Related Operations

| Operation | Code | Result |
|-----------|------|--------|
| Extract week from lecture ID | `"5.1".split('.')[0]` | `"5"` |
| Parse week string | `parseInt("5")` | `5` |
| Parse with fallback | `parseInt("") | 1` | `1` |
| Parse week (helper) | `parseWeekNumber("  10  ")` | `10` |
| Invalid parse | `parseWeekNumber("abc")` | `undefined` |
| Extract unique weeks | `Array.from(new Set([1,1,2,2,5]))` | `[1, 2, 5]` |
| Sort weeks | `[5, 1, 2].sort((a,b) => a-b)` | `[1, 2, 5]` |
| Filter materials by week | `materials.filter(m => m.weekNumber === 5)` | Week 5 materials |
| Null week handling | `m.weekNumber \|\| 1` | `1` if null |

---

**Document End**

*For questions or updates to this documentation, contact the development team.*
