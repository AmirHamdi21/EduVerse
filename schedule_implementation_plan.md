# Schedule Feature — Full API Parity Implementation Plan

Migrate the Flutter schedule module from mock/local data to production API-driven schedule management, achieving 1:1 feature parity with the React web frontend for all roles (Student, Instructor, TA, Admin).

> [!IMPORTANT]
> **UI Preservation Rule**: No existing UI widget files will be structurally changed. Only their **data source** (the cubits/state they read from) will be updated to emit real API data instead of mocks. The one exception is the instructor calendar filter where a new "Campus Events Source" filter chip will be added.

---

## Endpoint Audit — Verified Against Backend Controllers & Web Frontend

> [!CAUTION]
> **All endpoint paths have been verified line-by-line against the actual backend controller decorators and the web frontend's `scheduleService.ts`.** The backend has **6 separate controllers** inside the schedule module, each with its OWN base path. The endpoints are NOT all under `/schedule`.

### Verified Endpoint Map

| Controller | Base Path | Web Frontend Method | Flutter Plan Method |
|-----------|-----------|-------------------|-------------------|
| `ScheduleController` | `api/schedule` | | |
| | `GET my/daily?date=` | `getDailyUnified(date?)` | `getDailySchedule({date?})` |
| | `GET my/weekly?startDate=` | `getWeeklyUnified(startDate?)` | `getWeeklySchedule({startDate?})` |
| | `GET range` | (not used in calendar) | (not needed) |
| | `GET section/:sectionId` | (not used — section-level) | (existing `ScheduleService.getBySection()`) |
| | `GET academic` | (not used in calendar) | (not needed) |
| `CalendarEventsController` | `api/calendar/events` | | |
| | `GET /` | (via daily/weekly response) | (via daily/weekly response) |
| | `POST /` | (via add event form) | `createCalendarEvent(data)` |
| | `PUT /:id` | (via edit event) | `updateCalendarEvent(id, data)` |
| | `DELETE /:id` | (via delete event) | `deleteCalendarEvent(id)` |
| `CampusEventsController` | `api/campus-events` | | |
| | `GET /` | `getCampusEvents(params?)` | `getCampusEvents({...})` |
| | `GET /my` | `getMyCampusEvents(params?)` | `getMyCampusEvents({page?, limit?})` |
| | `POST /:id/register` | `registerForCampusEvent(id, notes?)` | `registerForCampusEvent(id, {notes?})` |
| | `DELETE /:id/register` | `unregisterFromCampusEvent(id)` | `unregisterFromCampusEvent(id)` |
| `ExamScheduleController` | `api/exams/schedule` | | |
| | `GET /` | (via daily/weekly response) | (via daily/weekly response) |
| `OfficeHoursController` | `api/office-hours` | | |
| | `GET /my-slots` | `getMyOfficeHoursSlots()` | (use existing `OfficeHoursService`) |
| | `GET /slots` | `getOfficeHoursSlots(params?)` | (use existing `OfficeHoursService.getSlots()`) |

---

## Cross-Feature Investigation Results

> [!NOTE]
> **Thoroughly investigated** the following Flutter screens and widgets for schedule feature usage:
>
> | Screen / Widget | Uses Schedule Feature? | Details |
> |-----------------|----------------------|---------|
> | Student `courses_screen.dart` | ❌ No | No schedule references |
> | Student `course_details_screen.dart` | ❌ No | No schedule references |
> | Student `labs_screen.dart` | ❌ No | No schedule references |
> | Student `assignments_screen.dart` | ❌ No | No schedule references |
> | Student `course_card.dart` widget | ⚠️ Uses `ScheduleModel` | Reads `enrollment.section.schedules` — **already API-driven** from enrollment data, no change needed |
> | Instructor `course_management_screen.dart` | ⚠️ Uses `ScheduleModel` | Passes `teachingCourse.section.schedules` to `OverviewTab` — **already API-driven**, no change needed |
> | Instructor `overview_tab.dart` widget | ⚠️ Uses `ScheduleModel` | Displays "Section Schedule" card — **already API-driven** from enrollment data, no change needed |
> | Instructor labs/assignments screens | ❌ No | No schedule references |
> | TA `ta_course_overview_tab.dart` | ❌ No | Only uses schedule icon, no schedule data |
> | TA courses/labs/assignments screens | ❌ No | No schedule references |
>
> **Conclusion**: No cross-feature changes are required.

---

## OfficeHoursService Investigation

> [!TIP]
> **`OfficeHoursService` already exists** at `lib/services/api/office_hours_service.dart` with:
> - `getSlots({page, limit, instructorId, dayOfWeek})` → `GET /office-hours/slots` → `PaginatedResult<OfficeHourSlotModel>`
> - `getMyAppointments()` → `GET /office-hours/my-appointments` → `List<OfficeHourAppointmentModel>`
> - `bookAppointment({slotId, appointmentDate, topic?, notes?})` → `POST /office-hours/appointments`
>
> **For instructor "my slots"**: the web frontend tries `GET /office-hours/my-slots` first, with a fallback to `GET /office-hours/slots?instructorId=...`. The existing Flutter `OfficeHoursService.getSlots()` uses the fallback path, which works fine. **No modification needed.**

---

## User Review Required

> [!WARNING]
> **Breaking Change — BLoC State Models**: `CalendarEvent`, `InstructorCalendarEvent` classes and TA inline `Map<String, dynamic>` events will gain new nullable fields. Local SharedPreferences caching will be replaced by API-driven state.

> [!IMPORTANT]
> **New UI Element**: The instructor calendar will gain a "Campus Events Source" filter (animated segmented chips: "All Campus Events" / "My Campus Events").

---

## Proposed Changes

### Phase 1 — Shared Schedule Models & Enums

Create unified data models that EXACTLY match the backend response shapes as consumed by the web frontend's `scheduleService.ts`.

---

#### [NEW] [schedule_enums.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/models/schedule/schedule_enums.dart)

```dart
enum ScheduleItemKind { classSession, exam, event, campusEvent, officeHours }
// with fromString() and toJson() matching existing enum patterns
```

---

#### [NEW] [daily_schedule_response.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/models/schedule/daily_schedule_response.dart)

**MUST match the web frontend's TypeScript interfaces exactly:**

```dart
/// Matches web: CourseBasic
class CourseBasic {
  final int courseId;
  final String courseCode;
  final String courseName;
}

/// Matches web: ClassScheduleItem (type = 'class')
class ClassScheduleItem {
  final String type; // always 'class'
  final int id;
  final int sectionId;
  final String dayOfWeek;
  final String startTime;    // "HH:mm" or "HH:mm:ss"
  final String endTime;      // "HH:mm" or "HH:mm:ss"
  final String? room;
  final String? building;
  final String scheduleType; // LECTURE, LAB, TUTORIAL, EXAM
  final ClassScheduleSection? section;
}

class ClassScheduleSection {
  final int id;              // NOTE: "id" not "sectionId" — matches web
  final String sectionNumber;
  final CourseBasic? course;
}

/// Matches web: PersonalEventScheduleItem (type = 'event')
class PersonalEventItem {
  final String type; // always 'event'
  final int eventId;
  final String title;
  final String? description;
  final String eventType;
  final String startTime;    // ISO datetime: "2026-01-15T14:00:00.000Z"
  final String endTime;      // ISO datetime
  final String? location;
  final String color;
  final CourseBasic? course;
}

/// Matches web: ExamScheduleItem (type = 'exam')
class ExamScheduleItem {
  final String type; // always 'exam'
  final int examId;
  final int courseId;        // NOTE: direct field, matches web
  final String examType;
  final String? title;
  final String examDate;     // "YYYY-MM-DD"
  final String startTime;    // "HH:mm"
  final int durationMinutes;
  final String? location;
  final CourseBasic course;
}

/// Matches web: CampusEventScheduleItem (type = 'campus_event')
/// NOTE: This is the SCHEDULE response shape — NOT the full CampusEvent
class CampusEventScheduleItem {
  final String type; // always 'campus_event'
  final int eventId;
  final String title;
  final String? description;
  final String eventType;
  final String startDatetime; // ISO datetime
  final String endDatetime;   // ISO datetime
  final String? location;
  final String color;
  final bool isMandatory;
  final bool registrationRequired;
  // NOTE: NO building, room, spotsRemaining, status —
  //       those are only on the full CampusEvent from GET /campus-events
}

/// The daily schedule API response
class DailyScheduleResponse {
  final String date;          // "YYYY-MM-DD"
  final String dayOfWeek;     // "MONDAY", "TUESDAY", etc.
  final List<ClassScheduleItem> schedules;
  final List<PersonalEventItem> events;
  final List<ExamScheduleItem> exams;
  final List<CampusEventScheduleItem> campusEvents;
}
```

---

#### [NEW] [weekly_schedule_response.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/models/schedule/weekly_schedule_response.dart)

```dart
class WeeklyScheduleResponse {
  final String weekStart;  // "YYYY-MM-DD"
  final String weekEnd;    // "YYYY-MM-DD"
  final List<DailyScheduleResponse> days; // exactly 7
}
```

---

#### [NEW] [unified_schedule_item.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/models/schedule/unified_schedule_item.dart)

Mirrors the web's `StudentScheduleItem` from `useSchedule.ts` lines 15–31:

```dart
class UnifiedScheduleItem {
  final String id;              // e.g. "class-5-2026-01-15", "exam-3", "event-10-2026-01-15"
  final ScheduleItemKind kind;
  final String date;            // "YYYY-MM-DD"
  final String startTime;       // "HH:mm" (normalized)
  final String endTime;         // "HH:mm" (normalized)
  final String title;
  final String? subtitle;
  final String? location;
  final String color;           // hex e.g. "#3b82f6"
  final String? courseCode;
  final int? courseId;

  // Original item references (nullable, exactly one set per instance)
  final ClassScheduleItem? classItem;
  final ExamScheduleItem? examItem;
  final PersonalEventItem? eventItem;
  final CampusEventScheduleItem? campusEventItem;

  // For instructor/TA — office hours slot reference
  final OfficeHourSlotModel? officeHoursSlot;

  // Campus event display extras
  final bool? isMandatory;
  final bool? registrationRequired;
}
```

---

#### [NEW] [schedule_helpers.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/models/schedule/schedule_helpers.dart)

Port from web `useSchedule.ts` lines 39–110:

```dart
String normalizeTime(String value);       // Handle "HH:mm", "HH:mm:ss", ISO datetime → "HH:mm"
String formatTime24To12(String time24);   // "14:30" → "2:30 PM"
int toMinutes(String time);              // "14:30" → 870
String toISODate(DateTime date);         // "2026-01-15"
DateTime startOfWeek(DateTime date);     // Sunday of the week
DateTime endOfWeek(DateTime date);
DateTime startOfMonth(DateTime date);
DateTime endOfMonth(DateTime date);
List<String> monthWeekStartDates(DateTime referenceDate); // all week-start ISOs covering month grid
```

---

#### [NEW] [schedule_models.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/models/schedule/schedule_models.dart) (barrel)

Re-exports all schedule model files.

---

### Phase 2 — Unified Schedule API Service

#### [NEW] [schedule_api_service.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/services/api/schedule_api_service.dart)

**MUST use the CORRECT endpoint paths matching the web frontend:**

```dart
class ScheduleApiService {
  final CoreApiClient _client;

  // ── Aggregated Schedule (ScheduleController: /api/schedule) ──
  // Web: ScheduleService.getDailyUnified(date?)
  Future<ServiceResult<DailyScheduleResponse>> getDailySchedule({String? date})
  // → GET /schedule/my/daily?date=...

  // Web: ScheduleService.getWeeklyUnified(startDate?)  
  Future<ServiceResult<WeeklyScheduleResponse>> getWeeklySchedule({String? startDate})
  // → GET /schedule/my/weekly?startDate=...

  // Web: getMonthDays() in useSchedule.ts lines 124-138
  Future<ServiceResult<List<DailyScheduleResponse>>> getMonthSchedule(DateTime referenceDate)
  // → Compute monthWeekStartDates, fetch getWeeklySchedule for each, flatten & deduplicate by date, filter to month range

  // ── Calendar Events (CalendarEventsController: /api/calendar/events) ──
  // Web: creates via form submit
  Future<ServiceResult<PersonalEventItem>> createCalendarEvent(Map<String, dynamic> data)
  // → POST /calendar/events

  Future<ServiceResult<PersonalEventItem>> updateCalendarEvent(int eventId, Map<String, dynamic> data)
  // → PUT /calendar/events/$eventId

  Future<ServiceResult<void>> deleteCalendarEvent(int eventId)
  // → DELETE /calendar/events/$eventId

  // ── Campus Events (CampusEventsController: /api/campus-events) ──
  // Web: ScheduleService.getCampusEvents(params?)
  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getCampusEvents({
    String? eventType, int? scopeId, String? status,
    String? fromDate, String? toDate, String? tag, String? search,
    int page = 1, int limit = 10,
  })
  // → GET /campus-events?...

  // Web: ScheduleService.getMyCampusEvents(params?)
  Future<ServiceResult<PaginatedResult<CampusEventModel>>> getMyCampusEvents({
    int page = 1, int limit = 10,
  })
  // → GET /campus-events/my?...

  // Web: ScheduleService.registerForCampusEvent(eventId, notes?)
  Future<ServiceResult<void>> registerForCampusEvent(int eventId, {String? notes})
  // → POST /campus-events/$eventId/register  (body: {notes})

  // Web: ScheduleService.unregisterFromCampusEvent(eventId)
  Future<ServiceResult<void>> unregisterFromCampusEvent(int eventId)
  // → DELETE /campus-events/$eventId/register  (NOTE: DELETE, not POST)
}
```

> [!CAUTION]
> **Critical Endpoint Corrections** from original plan:
> - Daily: `/schedule/my/daily` NOT `/schedule/daily`
> - Weekly: `/schedule/my/weekly` NOT `/schedule/weekly`
> - Calendar events: `/calendar/events` NOT `/schedule/calendar-events`
> - Campus events: `/campus-events` NOT `/schedule/campus-events`
> - Unregister: `DELETE /campus-events/:id/register` NOT `POST .../unregister`
> - My campus events: `GET /campus-events/my` (was missing entirely)

---

### Phase 3 — Schedule Item Builder (Normalization Logic)

#### [NEW] [schedule_item_builder.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/schedule/schedule_item_builder.dart)

**MUST exactly replicate the web's `buildUnifiedScheduleItems()` from `useSchedule.ts` lines 221-389:**

```dart
class ScheduleItemBuilder {
  /// Port of web's buildUnifiedScheduleItems() — useSchedule.ts L221-389
  static List<UnifiedScheduleItem> build({
    required List<DailyScheduleResponse> days,
    List<OfficeHourSlotModel>? officeHoursSlots,
    String? startDate,
    String? endDate,
  }) {
    // For each day:
    //   schedules → kind: classSession, color: '#3b82f6'
    //     id: "class-{entryId}-{date}"
    //     title: "{courseCode} - {courseName}" (with pickString fallback logic)
    //     subtitle: scheduleType.toUpperCase()
    //     location: [building, room].filter(notEmpty).join(' ') || 'TBD'
    //   events → kind: event, color: event.color || '#8b5cf6'
    //     id: "event-{eventId}-{date}"
    //   exams → kind: exam, color: '#ef4444'
    //     id: "exam-{examId}"
    //     endTime: computed from startTime + durationMinutes (min 30)
    //     title: "{courseCode} {EXAMTYPE}"
    //     subtitle: exam.title || 'Exam'
    //   campusEvents → kind: campusEvent, color: event.color || '#10b981'
    //     id: "campus-{eventId}"
    //     date: toISODate(DateTime.parse(startDatetime))
    //     startTime: normalizeTime(startDatetime)
    //     endTime: normalizeTime(endDatetime)
    // For officeHoursSlots:
    //   Expand across date range matching dayOfWeek
    //   kind: officeHours, color: '#f59e0b'
    //   id: "oh-{slotId}-{date}"
    //
    // Sort: by date ASC, then startTime minutes ASC
  }

  /// Port of web's detectScheduleConflicts() — useSchedule.ts L391-414
  static List<ScheduleConflict> detectConflicts(List<UnifiedScheduleItem> items);

  /// Port of web's getUpcomingScheduleItems() — useSchedule.ts L417-453
  /// NOTE: filters by endTime >= nowMinutes (not startTime >= nowMinutes)
  static List<UnifiedScheduleItem> upcoming(List<UnifiedScheduleItem> items, {int limit = 6});

  /// Filter items by kind and/or courseCode
  static List<UnifiedScheduleItem> filter(List<UnifiedScheduleItem> items, {
    ScheduleItemKind? kindFilter, String? courseFilter,
  });

  /// Extract unique course codes for filter dropdown
  static List<String> extractCourseCodes(List<UnifiedScheduleItem> items);
}

class ScheduleConflict {
  final String date;
  final UnifiedScheduleItem first;
  final UnifiedScheduleItem second;
}
```

---

### Phase 4 — Student Calendar Cubit Refactoring

#### [MODIFY] [calendar_state.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/calendar/calendar_state.dart)

1. Add `List<UnifiedScheduleItem> unifiedItems` (default `const []`)
2. Add `List<DailyScheduleResponse> rawDays` (default `const []`)
3. Add `ScheduleItemKind? kindFilter`, `String? courseFilter`
4. Keep `CalendarEvent` class (used for personal event creation form only)
5. Add `filteredItems` getter → `ScheduleItemBuilder.filter(unifiedItems, ...)`
6. Add `getUnifiedEventsForDate(DateTime)` → filter `unifiedItems` by date
7. Add `upcomingItems` getter → `ScheduleItemBuilder.upcoming(unifiedItems)`
8. Update `copyWith()` and `props`

#### [MODIFY] [calendar_cubit.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/calendar/calendar_cubit.dart)

1. **Inject** `ScheduleApiService` via constructor
2. **Remove** `_getMockEvents()`, `_getMockReminders()`, all SharedPreferences code
3. **Add** `loadSchedule()` — calls API based on viewType, builds unified items
4. **Refactor** `addEvent()` → `_scheduleService.createCalendarEvent()` then `loadSchedule()`
5. **Refactor** `deleteEvent()` → `_scheduleService.deleteCalendarEvent()` then `loadSchedule()`
6. **Add** `setKindFilter()`, `setCourseFilter()`
7. **Add** `registerForCampusEvent()`, `unregisterFromCampusEvent()`
8. Call `loadSchedule()` in `_initialize()` instead of loading from SharedPreferences

#### [MODIFY] [calendar_screen.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/screens/student/calendar/calendar_screen.dart)

1. Inject `ScheduleApiService` into `CalendarCubit` via BlocProvider
2. No structural UI changes

---

### Phase 5 — Instructor Calendar Cubit Refactoring

#### [MODIFY] [instructor_calendar_state.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/instructor/instructor_calendar_state.dart)

1. Add `unifiedItems`, `rawDays`, `kindFilter`, `courseFilter`
2. Add `String campusSource` — `'all'` (default) or `'my'`
3. Same getters as student state

#### [MODIFY] [instructor_calendar_cubit.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/instructor/instructor_calendar_cubit.dart)

1. **Inject** `ScheduleApiService` + existing `OfficeHoursService`
2. **Remove** mock/SharedPreferences code
3. **Add** `loadSchedule()` — fetch schedule + office hours, merge via `ScheduleItemBuilder.build(officeHoursSlots: ...)`
4. **Add** `setCampusSource('all' | 'my')` — filters campus events accordingly
5. Same CRUD refactoring as student

#### [MODIFY] [instructor_calendar_screen.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/screens/instructor/calendar/instructor_calendar_screen.dart)

1. Inject both `ScheduleApiService` + `OfficeHoursService` into cubit

---

### Phase 5.5 — Instructor Campus Event Source Filter UI

#### [MODIFY] [instructor_calendar_filter_dropdown.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/widgets/instructor/calendar/instructor_calendar_filter_dropdown.dart)

1. Add animated segmented chip pair: "All Campus Events" / "My Campus Events"
2. Style with instructor color palette, `AnimatedContainer` 200ms
3. Icons: `Icons.public_rounded` for "All", `Icons.person_rounded` for "My"
4. Wire to `cubit.setCampusSource()`

---

### Phase 6 — TA Calendar Migration

#### [NEW] [ta_calendar_state.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/ta/ta_calendar_state.dart)

#### [NEW] [ta_calendar_cubit.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/bloc/ta/ta_calendar_cubit.dart)

Same pattern as student/instructor. Injects `ScheduleApiService` + `OfficeHoursService`.

#### [MODIFY] [ta_calendar_screen.dart](file:///D:/Graduation/EduVerse/edu_verse/lib/screens/ta/calendar/ta_calendar_screen.dart)

1. Remove inline `_events` mock data
2. Wrap with `BlocProvider<TACalendarCubit>`
3. Replace `setState` data calls with cubit calls
4. Keep ALL widget builders identical

---

### Phase 7 — Admin (No Changes)

Already fully API-integrated. No changes needed.

---

### Phase 8 — Widget Wiring Updates

Same as original plan — update widgets to read `UnifiedScheduleItem` from cubit state.

---

## File Change Summary

| Category | New Files | Modified Files |
|----------|-----------|----------------|
| Models | 6 | 0 |
| Services | 1 | 0 |
| BLoC/Cubit | 3 (TA cubit+state, builder) | 4 (student cubit+state, instructor cubit+state) |
| Screens | 0 | 3 (student, instructor, TA calendar screens) |
| Widgets | 0 | ~14 (student + instructor calendar widgets) |
| **Total** | **10** | **~21** |

---

## Verification Plan

### Automated Tests
1. Unit tests for `ScheduleItemBuilder.build()` with known JSON fixtures
2. Unit tests for `ScheduleApiService` with mocked Dio responses
3. Unit tests for each cubit state transitions

### Manual Verification
1. Student Calendar: live classes, exams, personal events, campus events display correctly
2. Instructor Calendar: + office hours + campus source toggle
3. TA Calendar: loads from API, add/delete events
4. Admin: unchanged
5. Role-based filtering verified per role

### Build Verification
```bash
cd d:\Graduation\EduVerse\edu_verse
flutter analyze
flutter build apk --debug
```
