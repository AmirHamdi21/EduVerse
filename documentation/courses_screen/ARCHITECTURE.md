# Courses Screen - Architecture & Design

## Widget Hierarchy

```
CoursesScreen
├── CoursesAppBar (SliverAppBar)
└── SliverPadding
    └── SliverList
        ├── CoursesHeader
        ├── CourseSearchBar
        ├── Filter & Sort Row
        ├── CourseFilterBar
        ├── CoursesListView
        │   └── CourseCard (x N)
        │       ├── Course Header
        │       ├── Progress Section
        │       └── Action Buttons
        └── JoinCourseButton
```

## Component Responsibilities

### CoursesScreen
- **Responsibility**: Orchestration & State Management
- **State**: `_selectedFilter`, `_searchQuery`, `_allCourses`, `_filteredCourses`
- **Methods**: `_initializeCourses()`, `_applyFilters()`
- **Dependencies**: ThemeBloc, AppLocalizations

### CourseCard
- **Responsibility**: Individual Course Display
- **Props**: `CourseModel`, `Animation<double>`
- **Displays**:
  - Icon with custom background
  - Course title & instructor
  - Progress circle & bar
  - Action buttons
- **Animations**: Entrance animation

### CoursesListView
- **Responsibility**: List Rendering with Animations
- **Props**: `List<CourseModel>`
- **Features**: Staggered animations, empty state
- **Renders**: Multiple CourseCard widgets

### CourseSearchBar
- **Responsibility**: Search Input
- **Features**: Real-time search, clear button
- **Callback**: `onSearchChanged(String)`

### CourseFilterBar
- **Responsibility**: Filter Selection
- **Filters**: All, Lectures, Labs, Completed
- **Callback**: `onFilterChanged(String)`

## Data Flow

```
User Input
    ↓
Search/Filter Update
    ↓
setState() in CoursesScreen
    ↓
_applyFilters() called
    ↓
_filteredCourses updated
    ↓
CoursesListView rebuilds
    ↓
CourseCards rendered with animations
```

## State Management

### Screen-Level State
```dart
String _selectedFilter = 'all';
String _searchQuery = '';
List<CourseModel> _allCourses = [];
List<CourseModel> _filteredCourses = [];
```

### Filter Logic
```dart
void _applyFilters() {
  _filteredCourses = _allCourses.where((course) {
    final matchesSearch = _searchQuery.isEmpty ||
        course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        course.instructor.toLowerCase().contains(_searchQuery.toLowerCase());
    
    final matchesFilter = _selectedFilter == 'all' ||
        (_selectedFilter == 'completed' && course.progress >= 0.8) ||
        (_selectedFilter == 'lectures' && course.progress < 0.8) ||
        (_selectedFilter == 'labs' && course.progress >= 0.5);
    
    return matchesSearch && matchesFilter;
  }).toList();
}
```

## Animation Architecture

### Card Entrance Animation
- **Type**: Staggered slide + fade
- **Duration**: 600ms per card
- **Delay**: 120ms between cards
- **Curves**: easeOutCubic (slide), easeOut (fade)

### Implementation
```dart
// In CoursesListView._initializeAnimations()
for (int i = 0; i < _animationControllers.length; i++) {
  Future.delayed(Duration(milliseconds: i * 120), () {
    if (mounted) {
      _animationControllers[i].forward();
    }
  });
}
```

## Theme Integration

### ThemeBloc Usage
```dart
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, themeState) {
    final isDark = themeState.isDark;
    // Build based on isDark
  }
)
```

### Color Mapping
- Light mode: White backgrounds, dark text
- Dark mode: Dark backgrounds (#16213E), light text
- Consistent throughout all widgets

## Localization Strategy

### String Keys Added
27 new localization strings for:
- Headers & titles
- Button labels
- Filter options
- Placeholders
- Localized instructor names

### Generation Flow
1. Update `.arb` files
2. Run `flutter gen-l10n`
3. Generated classes updated automatically
4. Access via `AppLocalizations.of(context)`

## Performance Considerations

### Rendering Optimization
- SliverList for lazy loading
- SizedBox instead of Container for fixed sizes
- Only rebuild on state changes

### Animation Optimization
- Proper AnimationController disposal
- Staggered animations to prevent frame drops
- GPU-accelerated animations

### Memory Management
- Timely cleanup of controllers
- didUpdateWidget for list updates
- Proper dispose() implementation

## Responsive Design

### Breakpoints
- Mobile: Full width with padding
- Tablet: Constrained width (max 400px per card)
- Desktop: Grid layout possible

### Flexible Widgets
- Cards: Responsive padding & spacing
- Buttons: Expanded for proper sizing
- Icons: Scalable with parent container

## Error Handling

### Empty States
- Shows icon + "No Data" message
- Displayed when filters result in 0 courses
- Graceful UI presentation

### Theme Fallbacks
- Default colors if theme unavailable
- Constant color values as backup

## Testing Strategy

### Unit Tests
- Filter logic verification
- Search functionality
- Data model validation

### Widget Tests
- Widget rendering
- Animation execution
- Theme application
- User interactions

### Integration Tests
- Navigation to screen
- Full user workflow
- Theme switching
- Language switching

## File Dependencies

```
courses_screen.dart
├── course_card.dart
├── courses_list_view.dart
├── course_search_bar.dart
├── course_filter_bar.dart
├── courses_app_bar.dart
├── courses_header.dart
├── join_course_button.dart
├── course_model.dart
├── ThemeBloc
└── AppLocalizations

course_card.dart
├── animated_progress_bar.dart
├── course_model.dart
└── ThemeBloc

courses_list_view.dart
├── course_card.dart
└── course_model.dart
```

## Future Architecture Enhancements

1. **Repository Pattern**
   - Add CourseRepository for data fetching
   - Separate API calls from UI logic

2. **Cubit/Bloc**
   - Create CoursesCubit for state management
   - Move filtering logic to Cubit

3. **Pagination**
   - Implement infinite scroll
   - Load data in chunks

4. **Caching**
   - Cache course data locally
   - Invalidate on specific events

## Design Decisions

### Why SliverList?
- Efficient scrolling performance
- Works well with CustomScrollView
- Supports lazy loading

### Why Staggered Animations?
- Better UX perception of content
- Prevents animation jank
- Visual hierarchy emphasis

### Why Screen-Level State?
- Simple for current complexity
- Easy to migrate to Bloc later
- Minimal overhead

### Why BlocBuilder?
- Reactive to theme changes
- Consistent with app architecture
- Good separation of concerns

---

**Version**: 1.0.0
**Last Updated**: 2025-12-05
