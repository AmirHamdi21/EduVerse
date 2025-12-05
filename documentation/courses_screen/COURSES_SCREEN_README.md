# Courses Screen Implementation

## Overview
The Courses screen displays all enrolled courses for the current semester with detailed information about each course's progress, next events, and actions.

## Widget Structure

### Main Screen Component
- **CoursesScreen** (`courses_screen.dart`)
  - Main entry point for the courses screen
  - Handles filtering and search logic
  - Manages animated course list

### Components

#### 1. CoursesAppBar (`courses_app_bar.dart`)
- Floating app bar with back button
- Notification icon
- Responsive to theme changes

#### 2. CoursesHeader (`courses_header.dart`)
- Title: "My Courses"
- Subtitle: "All enrolled courses this semester"
- Static text component

#### 3. CourseSearchBar (`course_search_bar.dart`)
- Search input field for filtering courses
- Shows placeholder: "Search course name or instructor"
- Clear button functionality
- Real-time search updates

#### 4. CourseFilterBar (`course_filter_bar.dart`)
- Filter buttons: All, Lectures, Labs, Completed
- Animated state transitions
- Gradient button for selected filter
- Updates course list on filter change

#### 5. CourseCard (`course_card.dart`)
- Displays individual course information
- Shows:
  - Course icon with themed background
  - Course title (with multi-line support)
  - Instructor name
  - Next event details
  - Progress percentage (circular display)
  - Animated progress bar
  - Primary and secondary action buttons
- Staggered entrance animations

#### 6. CoursesListView (`courses_list_view.dart`)
- Renders list of course cards
- Staggered animation on initial load
- Shows empty state when no courses available
- Handles dynamic updates

#### 7. JoinCourseButton (`join_course_button.dart`)
- Floating action button with gradient
- Pulse animation effect
- Positioned at bottom of screen

#### 8. CourseModel (`course_model.dart`)
- Data model for course information
- Contains all course-related properties
- Supports custom button callbacks

## Features

### Theme Support
- Fully responsive to dark/light theme via ThemeBloc
- Color scheme adapts based on `isDark` state
- Consistent with app's design system

### Localization
- Supports English and Arabic
- All strings extracted to localization files
- RTL-ready layout

### Performance Optimizations
1. **Lazy Loading**: Uses SliverList for efficient rendering
2. **Animation Performance**: Staggered animations with proper disposal
3. **Memory Management**: Proper controller lifecycle management
4. **Rendering**: Uses SizedBox for fixed dimensions instead of Container

### Search & Filter
- Real-time search filtering
- Multi-filter support (All, Lectures, Labs, Completed)
- Case-insensitive search
- Combined search + filter logic

### Animations
- Staggered entrance animations for course cards
- Fade + Slide transitions
- Pulse animation for join button
- Smooth progress bar animations

## Data Structure

Each course contains:
```dart
CourseModel(
  title: String,
  instructor: String,
  progress: double (0.0 - 1.0),
  nextEvent: String,
  eventDate: String,
  iconBackgroundColor: Color,
  courseIcon: IconData,
  primaryButtonLabel: String,
  onPrimaryButtonPressed: VoidCallback?,
  onSecondaryButtonPressed: VoidCallback?,
)
```

## Localization Keys

### English (app_en.arb)
- myCoursesHeader
- allEnrolledCoursesThisSemester
- searchCourseNameOrInstructor
- filter, sort
- all, lectures, labs, completed
- joinCourse
- Materials

### Arabic (app_ar.arb)
- Corresponding Arabic translations

## Integration

### Route Setup
Add to router configuration:
```dart
GoRoute(
  path: '/courses',
  builder: (context, state) => const CoursesScreen(),
)
```

### Theme Integration
Uses existing ThemeBloc from project
- Respects `isDark` state
- Maintains consistent color scheme

## Color Palette (from Figma)

### Primary Colors
- Blue Gradient: #2B7FFF → #155DFC
- Progress Blue: #155DFC
- Text Dark: #101828

### Background Colors
- Icon backgrounds vary by course:
  - AI courses: #DEEAFF (light blue)
  - Data courses: #DEFFDD (light green)
  - Ethics courses: #FFE8E8 (light red)
  - Network courses: #E8E0FF (light purple)
  - Web courses: #FFEDD1 (light orange)

### Borders & Shadows
- Border: #D1D5DC (light), white.withOpacity(0.1) (dark)
- Shadow: rgba(0, 0, 0, 0.1) with blur 6

## Sample Data

The screen initializes with 6 sample courses:
1. Introduction to AI (Dr. Alan Turing) - 75%
2. Data Structures (Dr. Grace Hopper) - 40%
3. Neural Networks (Dr. Yann LeCun) - 95%
4. Cybersecurity Ethics (Dr. Ada Lovelace) - 15%
5. Machine Learning Fundamentals (Dr. Andrew Ng) - 60%
6. Web Development (Dr. Tim Berners-Lee) - 85%

## Future Enhancements

1. **Backend Integration**
   - Replace sample data with API calls
   - Dynamic course loading

2. **Advanced Filtering**
   - Filter by semester
   - Filter by instructor
   - Custom date range filtering

3. **Additional Features**
   - Course details screen
   - Enrollment functionality
   - Course search/discovery
   - Recommended courses

4. **Performance**
   - Pagination for large course lists
   - Caching layer
   - Lazy loading of course content

## Testing

### Widget Test Coverage
- CourseCard rendering
- Filter functionality
- Search functionality
- Theme responsiveness
- Empty state handling

### Manual Testing
1. Navigate to courses screen
2. Test search functionality
3. Test filter buttons
4. Toggle dark/light theme
5. Change language to Arabic
6. Verify all text localization

## File Structure
```
lib/widgets/student/courses/
├── courses_screen.dart
├── courses_app_bar.dart
├── courses_header.dart
├── course_search_bar.dart
├── course_filter_bar.dart
├── course_card.dart
├── courses_list_view.dart
├── join_course_button.dart
├── course_model.dart
└── courses_barrel.dart
```

## Notes

- Animations are GPU-accelerated for smooth 60fps performance
- All widgets are stateless where possible, with state management at screen level
- Proper cleanup of AnimationControllers prevents memory leaks
- BlocBuilder ensures reactive UI updates
- Material 3 design principles applied throughout
