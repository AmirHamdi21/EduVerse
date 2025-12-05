# Courses Screen - Quick Reference

## 📍 Location
`lib/widgets/student/courses/`

## 🚀 Quick Start

### Navigate to Courses
```dart
context.go('/courses');
```

### Import for Custom Usage
```dart
import 'package:edu_verse/widgets/student/courses/courses_barrel.dart';
```

## 📦 Components

| File | Purpose | Key Class |
|------|---------|-----------|
| `courses_screen.dart` | Main screen | `CoursesScreen` |
| `course_card.dart` | Card display | `CourseCard` |
| `course_model.dart` | Data model | `CourseModel` |
| `course_search_bar.dart` | Search | `CourseSearchBar` |
| `course_filter_bar.dart` | Filters | `CourseFilterBar` |
| `courses_app_bar.dart` | App bar | `CoursesAppBar` |
| `join_course_button.dart` | FAB button | `JoinCourseButton` |
| `courses_list_view.dart` | List renderer | `CoursesListView` |
| `courses_header.dart` | Header | `CoursesHeader` |

## 🎨 Key Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Blue | #2B7FFF | Gradients, Active state |
| Accent Blue | #155DFC | Buttons, Links, Progress |
| Text Primary | #101828 | Main text |
| Text Secondary | #4A5565 | Descriptions |
| Border Light | #D1D5DC | Borders (light mode) |
| Border Dark | rgba(255,255,255,0.1) | Borders (dark mode) |

## 🌐 Localization Keys

```dart
l10n.myCoursesHeader                      // "My Courses"
l10n.allEnrolledCoursesThisSemester      // "All enrolled courses..."
l10n.searchCourseNameOrInstructor        // Search placeholder
l10n.filter                              // "Filter"
l10n.sort                                // "Sort"
l10n.all                                 // "All"
l10n.lectures                            // "Lectures"
l10n.labs                                // "Labs"
l10n.completed                           // "Completed"
l10n.joinCourse                          // "Join Course"
l10n.materials                           // "Materials"
l10n.continueButton                      // "Continue"
```

## 📐 Widget Sizes

| Element | Size |
|---------|------|
| Course Card | Full width (max 400px) |
| Icon | 64x64px |
| Progress Circle | 64x64px |
| Card Padding | 24px |
| Border Radius | 14-24px |
| Progress Bar | 6px height |

## 🎬 Animations

| Animation | Duration | Type |
|-----------|----------|------|
| Card Entrance | 600ms | Staggered slide + fade |
| Filter Change | 300ms | Color transition |
| Join Button | 1500ms | Continuous pulse |
| Progress Bar | 1500ms | Linear fill |

## 🔧 Customization Examples

### Add Custom Course
```dart
_allCourses.add(
  CourseModel(
    title: 'Custom Course',
    instructor: 'Dr. Name',
    progress: 0.75,
    nextEvent: 'Event Details',
    eventDate: 'Date',
    iconBackgroundColor: Colors.blue.shade100,
    courseIcon: Icons.book,
    onPrimaryButtonPressed: () {
      // Handle button tap
    },
  ),
);
```

### Add Filter Logic
```dart
// In _applyFilters()
final matchesFilter = _selectedFilter == 'custom' &&
    course.someProperty == value;
```

### Change Colors
```dart
// In course_card.dart _buildActionButtons()
backgroundColor: Colors.green, // Instead of blue
```

## 🧪 Testing

### Manual Test
1. `context.go('/courses')`
2. Search for "AI"
3. Filter by "Lectures"
4. Toggle dark mode
5. Change language to Arabic
6. Tap "Join Course"

### Widget Test Template
```dart
testWidgets('CourseCard displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CourseCard(
          course: testCourse,
        ),
      ),
    ),
  );
  
  expect(find.text('Course Title'), findsOneWidget);
});
```

## 📊 Data Flow

```
CoursesScreen
  ├── _initializeCourses()
  ├── _applyFilters()
  └── UI Build
      ├── CoursesAppBar
      ├── CoursesHeader
      ├── CourseSearchBar
      ├── CourseFilterBar
      ├── CoursesListView
      │   └── CourseCard (x6)
      └── JoinCourseButton
```

## ⚡ Performance Tips

- ✅ Uses SliverList for lazy loading
- ✅ Animations properly disposed
- ✅ State managed at screen level
- ✅ BlocBuilder for reactive UI
- ✅ No unnecessary rebuilds

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Route not found | Check router has `/courses` path |
| Strings not translated | Run `flutter gen-l10n` |
| Theme not applying | Ensure `ThemeBloc` is provided |
| Animations stutter | Check device performance |
| Dark mode colors wrong | Verify `isDark` state |

## 📚 Documentation

- `README.md` - Full component documentation
- `ARCHITECTURE.md` - Architecture & design decisions
- `QUICK_REFERENCE.md` - Quick reference card

## 🔗 Related Files

- `lib/config/app_router.dart` - Route configuration
- `lib/l10n/app_*.arb` - Localization strings
- `lib/bloc/theme/theme_bloc.dart` - Theme management
- `lib/widgets/common/animated_progress_bar.dart` - Progress component

## 📱 Responsive Breakpoints

| Breakpoint | Treatment |
|-----------|-----------|
| < 360px | Mobile (narrow) |
| 360-600px | Mobile |
| 600-900px | Tablet (portrait) |
| > 900px | Tablet/Desktop |

## ✨ Features Summary

- ✅ Display multiple courses
- ✅ Search by title/instructor
- ✅ Filter by type
- ✅ Progress tracking
- ✅ Dark mode support
- ✅ Multi-language (EN/AR)
- ✅ Smooth animations
- ✅ Mobile responsive

---

**Last Updated**: 2025-12-05
**Status**: Production Ready ✅
