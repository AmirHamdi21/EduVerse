# Attendance Feature Documentation

## Overview

The Attendance feature provides students with a comprehensive view of their course attendance records. It includes an overview tab showing all courses with attendance statistics, and a detailed view for each course showing individual lecture attendance.

## Architecture

### Directory Structure

```
lib/
├── bloc/
│   └── attendance/
│       ├── attendance_cubit.dart    # State management
│       └── attendance_state.dart    # State models and enums
├── screens/
│   └── student/
│       └── attendance/
│           ├── attendance_screen.dart           # Main screen with tabs
│           └── course_attendance_detail_screen.dart  # Course detail view
└── widgets/
    └── student/
        └── attendance/
            ├── attendance_app_bar.dart          # Custom app bar
            ├── attendance_overview_tab.dart     # Overview tab content
            ├── attendance_stats_card.dart       # Statistics summary card
            ├── course_attendance_card.dart      # Course card in list
            └── lecture_attendance_item.dart     # Lecture item in detail
```

### State Management

Uses **Cubit pattern** (flutter_bloc) for predictable state management.

#### AttendanceState

```dart
class AttendanceState {
  final List<CourseAttendance> courses;
  final CourseAttendance? selectedCourse;
  final AttendanceStatus status;
  final String? errorMessage;
  final String searchQuery;
  final AttendanceFilter filter;
  final AttendanceSortOption sortOption;
  final OverallStats overallStats;
}
```

#### CourseAttendance Model

```dart
class CourseAttendance {
  final String id;
  final String courseName;
  final String courseCode;
  final String instructorName;
  final int totalLectures;
  final int attendedLectures;
  final int absentLectures;
  final int excusedAbsences;
  final double attendancePercentage;
  final List<LectureAttendance> lectures;
  final Color courseColor;
}
```

#### LectureAttendance Model

```dart
class LectureAttendance {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final AttendanceType type; // present, absent, excused, late
  final String? notes;
  final String? location;
}
```

## Features

### 1. Overview Tab

- **Overall Statistics Card**: Shows total attendance percentage, present/absent counts
- **Course List**: All enrolled courses with attendance summary
- **Visual Indicators**: Color-coded attendance percentages
  - Green (≥80%): Good attendance
  - Yellow (60-79%): Needs improvement
  - Red (<60%): Critical

### 2. Course Detail View

- **Course Header**: Course name, code, instructor
- **Statistics Summary**: Detailed breakdown of attendance
- **Lecture History**: Chronological list of all lectures
- **Status Badges**: Present, Absent, Excused, Late

### 3. Search & Filter

- **Real-time Search**: Search courses by name or code
- **Clear Button**: One-tap to clear search query
- **Filter Options**:
  - All courses
  - Below threshold (<75%)
  - Perfect attendance (100%)
  - In progress

### 4. Sort Options

- Date (Recent first / Oldest first)
- Name (A-Z / Z-A)
- Attendance percentage (High to Low / Low to High)

## Screen Navigation Flow

```
Student Dashboard
    │
    ├── Attendance Widget (tap) ───► Attendance Screen
    │                                      │
    └── Drawer Menu ─────────────────────►│
                                           │
                                           ├── Overview Tab
                                           │      │
                                           │      └── Course Card (tap)
                                           │              │
                                           │              ▼
                                           │      Course Detail Screen
                                           │
                                           └── Calendar Tab (future)
```

## UI Components

### AttendanceStatsCard

Displays overall attendance statistics with:
- Circular progress indicator
- Attendance percentage
- Present/Absent/Excused counts
- Visual breakdown bars

```dart
AttendanceStatsCard(
  isDark: isDark,
  totalLectures: 120,
  attended: 108,
  absent: 8,
  excused: 4,
  percentage: 90.0,
)
```

### CourseAttendanceCard

Individual course card showing:
- Course color indicator
- Course name and code
- Instructor name
- Attendance percentage with progress bar
- Tap to view details

```dart
CourseAttendanceCard(
  course: courseAttendance,
  isDark: isDark,
  onTap: () => _navigateToDetail(course),
)
```

### LectureAttendanceItem

Lecture entry in detail view:
- Date and time
- Lecture title
- Status badge (color-coded)
- Location (if available)
- Notes (if available)

## Localization

All UI text is localized in both English and Arabic:

| Key | English | Arabic |
|-----|---------|--------|
| `attendance` | Attendance | الحضور |
| `overview` | Overview | نظرة عامة |
| `totalLectures` | Total Lectures | إجمالي المحاضرات |
| `attended` | Attended | حضور |
| `absent` | Absent | غياب |
| `excused` | Excused | معذور |
| `late` | Late | متأخر |
| `attendanceRate` | Attendance Rate | نسبة الحضور |
| `searchCourses` | Search courses | البحث في المقررات |
| `noCoursesFound` | No courses found | لم يتم العثور على مقررات |
| `lectureHistory` | Lecture History | سجل المحاضرات |

## Theme Support

### Light Mode

| Element | Color |
|---------|-------|
| Background | `#F8FAFC` |
| Card | `#FFFFFF` |
| Primary Text | `#1E293B` |
| Secondary Text | `#64748B` |
| Present | `#10B981` |
| Absent | `#EF4444` |
| Excused | `#F59E0B` |
| Late | `#8B5CF6` |

### Dark Mode

| Element | Color |
|---------|-------|
| Background | `#0F172A` |
| Card | `#1E293B` |
| Primary Text | `#FFFFFF` |
| Secondary Text | `#94A3B8` |
| Present | `#10B981` |
| Absent | `#EF4444` |
| Excused | `#F59E0B` |
| Late | `#8B5CF6` |

## Navigation

### Routes

```dart
// Main attendance screen
GoRoute(
  path: '/attendance',
  name: 'attendance',
  builder: (context, state) => const AttendanceScreen(),
),

// Course detail screen
GoRoute(
  path: '/attendance/:courseId',
  name: 'courseAttendanceDetail',
  builder: (context, state) {
    final courseId = state.pathParameters['courseId']!;
    return CourseAttendanceDetailScreen(courseId: courseId);
  },
),
```

### Access Points

1. **Student Dashboard**: Attendance widget card
2. **Student Drawer**: Menu item in navigation drawer
3. **Deep Link**: `eduverse://attendance`

## Error Handling

### Scenarios Handled

1. **Network Error**: Shows retry option with cached data if available
2. **Empty State**: Displays friendly message when no courses
3. **Loading State**: Shows skeleton loading animation
4. **Course Not Found**: Redirects to overview with error message

### Error Display

```dart
if (state.status == AttendanceStatus.error) {
  return ErrorView(
    message: state.errorMessage ?? l10n.errorOccurred,
    onRetry: () => cubit.loadAttendance(),
  );
}
```

## Performance Optimizations

1. **Selective Rebuilds**: `buildWhen` in BlocBuilder for targeted updates
2. **Lazy Loading**: Course details loaded on demand
3. **Search Debouncing**: 300ms debounce on search input
4. **Cached Statistics**: Overall stats calculated once and cached
5. **Efficient List Rendering**: `SliverList` for smooth scrolling

## Search Implementation

The search function filters courses in real-time:

```dart
void searchCourses(String query) {
  emit(state.copyWith(searchQuery: query));
  _filterCourses();
}

void _filterCourses() {
  var filtered = state.courses;
  
  // Apply search filter
  if (state.searchQuery.isNotEmpty) {
    final query = state.searchQuery.toLowerCase();
    filtered = filtered.where((course) =>
      course.courseName.toLowerCase().contains(query) ||
      course.courseCode.toLowerCase().contains(query)
    ).toList();
  }
  
  // Apply category filter
  switch (state.filter) {
    case AttendanceFilter.belowThreshold:
      filtered = filtered.where((c) => c.attendancePercentage < 75).toList();
      break;
    case AttendanceFilter.perfect:
      filtered = filtered.where((c) => c.attendancePercentage == 100).toList();
      break;
    // ... other filters
  }
  
  emit(state.copyWith(filteredCourses: filtered));
}
```

## Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   API / Local   │────►│ AttendanceCubit  │────►│  UI Widgets     │
│     Storage     │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │ AttendanceState  │
                        │  - courses       │
                        │  - searchQuery   │
                        │  - filter        │
                        │  - sortOption    │
                        └──────────────────┘
```

## Usage Example

```dart
// Navigate to Attendance
context.push('/attendance');

// Navigate to specific course detail
context.push('/attendance/course_123');

// Search courses programmatically
context.read<AttendanceCubit>().searchCourses('Math');

// Apply filter
context.read<AttendanceCubit>().setFilter(AttendanceFilter.belowThreshold);
```

## Future Enhancements

- [ ] Calendar view tab for visual attendance tracking
- [ ] Push notifications for attendance warnings
- [ ] QR code check-in integration
- [ ] Export attendance report as PDF
- [ ] Attendance prediction based on patterns
- [ ] Integration with institution's attendance system
- [ ] Excuse request submission
- [ ] Attendance goal setting
