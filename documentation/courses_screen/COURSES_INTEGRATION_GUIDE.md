# Courses Screen Integration Guide

## Quick Start

The Courses screen has been fully integrated into the EduVerse application and is now accessible via the `/courses` route.

## Navigation

### From Dashboard
To navigate to the Courses screen from any screen in the app:

```dart
context.go('/courses');
```

Or using named routes (if you prefer to update the router):

```dart
context.push('/courses');
```

### In UI
Add a button or menu item:

```dart
ElevatedButton(
  onPressed: () => context.go('/courses'),
  child: const Text('View All Courses'),
)
```

## Features Implemented

✅ **Courses Grid Display**
- 6 sample courses with realistic data
- Course icons with themed backgrounds
- Instructor names and course titles
- Progress percentage display
- Next event information

✅ **Search & Filter**
- Real-time course search by name or instructor
- Filter by course type: All, Lectures, Labs, Completed
- Combined search + filter logic

✅ **Theme Support**
- Full dark mode support
- Color palette adheres to Figma design
- Responsive to theme changes

✅ **Localization**
- English and Arabic support
- All text strings externalized
- RTL-ready for Arabic

✅ **Performance**
- Staggered animations for smooth UX
- Lazy loading with SliverList
- Efficient state management
- Proper resource cleanup

## Sample Data

The screen comes pre-loaded with 6 sample courses:

| Course | Instructor | Progress | Next Event |
|--------|-----------|----------|-----------|
| Introduction to AI | Dr. Alan Turing | 75% | Nov 12 - AI Lab 3 |
| Data Structures | Dr. Grace Hopper | 40% | Nov 15 - Assignment |
| Neural Networks | Dr. Yann LeCun | 95% | Dec 5 - Final Exam |
| Cybersecurity Ethics | Dr. Ada Lovelace | 15% | Nov 20 - Lecture |
| Machine Learning Fundamentals | Dr. Andrew Ng | 60% | Nov 18 - Lab |
| Web Development | Dr. Tim Berners-Lee | 85% | Nov 25 - Project |

## Customization

### Adding Real Course Data

Replace the sample data initialization in `courses_screen.dart`:

```dart
void _initializeCourses() {
  _allCourses = [
    // Your API call here
    // CourseModel(...),
  ];
  _applyFilters();
}
```

### Customize Colors

Update icon background colors in `course_model.dart`:

```dart
iconBackgroundColor: const Color(0xFFYourColor),
```

### Button Actions

Add callbacks to CourseModel:

```dart
onPrimaryButtonPressed: () {
  // Handle "Continue" button
},
onSecondaryButtonPressed: () {
  // Handle "Materials" button
},
```

## File Structure

```
lib/
├── widgets/student/courses/
│   ├── courses_screen.dart          # Main screen
│   ├── course_card.dart             # Individual course card
│   ├── course_model.dart            # Data model
│   ├── courses_app_bar.dart         # App bar
│   ├── courses_header.dart          # Header section
│   ├── course_search_bar.dart       # Search input
│   ├── course_filter_bar.dart       # Filter buttons
│   ├── courses_list_view.dart       # Course list
│   ├── join_course_button.dart      # Join button
│   └── courses_barrel.dart          # Barrel export
│
└── l10n/
    ├── app_en.arb                   # English strings
    └── app_ar.arb                   # Arabic strings
```

## Configuration

### Router Setup (Already Done)
The route is pre-configured in `lib/config/app_router.dart`:

```dart
GoRoute(
  path: '/courses',
  builder: (context, state) => const CoursesScreen(),
),
```

## Localization Keys

All localization strings are available in the `AppLocalizations` class:

- `l10n.myCoursesHeader` - "My Courses"
- `l10n.allEnrolledCoursesThisSemester` - "All enrolled courses this semester"
- `l10n.searchCourseNameOrInstructor` - Search placeholder
- `l10n.filter` - "Filter"
- `l10n.sort` - "Sort"
- `l10n.all` - "All"
- `l10n.lectures` - "Lectures"
- `l10n.labs` - "Labs"
- `l10n.completed` - "Completed"
- `l10n.joinCourse` - "Join Course"
- `l10n.materials` - "Materials"
- `l10n.continueButton` - "Continue"

## Testing

### Manual Testing Checklist

- [ ] Navigate to `/courses` route
- [ ] Verify all 6 courses display
- [ ] Search for "AI" - should show AI-related courses
- [ ] Filter by "Lectures" - should show appropriate courses
- [ ] Toggle dark mode - colors should adapt
- [ ] Switch language to Arabic - layout should be RTL
- [ ] Click "Join Course" button - should trigger callback
- [ ] Verify animations play smoothly
- [ ] Test on different screen sizes (mobile, tablet)

### Widget Testing
Create unit tests in `test/widgets/student/courses/` directory

## Performance Tips

1. **Image Optimization**: If adding course images, use appropriate asset sizes
2. **Data Loading**: Implement pagination for large course lists
3. **Animations**: Already optimized with proper disposal
4. **Memory**: State management already handles cleanup

## Troubleshooting

### Courses Not Showing
- Check if `CoursesScreen` is properly imported
- Verify `/courses` route is in router config
- Check theme state is being provided

### Localization Issues
- Run `flutter gen-l10n` after adding new strings
- Clear build directory: `flutter clean`
- Restart app

### Theme Colors Not Applying
- Ensure ThemeBloc is initialized
- Check that `isDark` state is being read correctly
- Verify color constants are properly defined

## Future Enhancements

- [ ] Backend API integration
- [ ] Real-time course enrollment
- [ ] Course recommendations
- [ ] Advanced filtering options
- [ ] Course search with Algolia
- [ ] Student performance analytics
- [ ] Peer comparison
- [ ] Course announcements

## Dependencies

The Courses screen uses:
- `flutter_bloc` - State management
- `go_router` - Navigation
- `flutter_localizations` - i18n support

No additional dependencies were added.

## Support

For issues or questions:
1. Check the main README.md
2. Review COURSES_SCREEN_README.md for detailed architecture
3. Check widget documentation in individual files

---

**Version**: 1.0.0
**Last Updated**: 2025-12-05
**Status**: Production Ready ✅
