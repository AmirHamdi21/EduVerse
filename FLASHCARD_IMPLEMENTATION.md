# Flashcard Study Screen - Implementation Guide

## Overview
A complete flashcard study application built with Flutter, featuring AI-generated flashcards, course selection, and adaptive flip animations. The implementation follows the project architecture patterns and includes full dark mode support.

## File Structure

```
lib/
├── models/
│   └── flashcard_model.dart          # Data models for Flashcard, StudySet, Course
├── screens/student/
│   └── flashcards_screen.dart        # Main screen container
└── widgets/student/flashcards/
    ├── flip_card.dart                # 3D flip animation card component
    ├── course_selector.dart          # Animated dropdown course selector
    ├── card_action_buttons.dart      # Action buttons (Mark Known, Review, Shuffle)
    ├── card_progress_indicator.dart  # Progress dots & navigation
    ├── flashcards_header.dart        # Header with back & regenerate buttons
    ├── generate_new_set_panel.dart   # Generate new set with options
    └── flashcards_barrel.dart        # Barrel exports
```

## Components

### 1. Data Models (`flashcard_model.dart`)

#### Flashcard
```dart
class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String topic;
  bool isMarkedAsKnown;
  bool isMarkedForReview;
}
```

#### Course
```dart
class Course {
  final String id;
  final String name;
  final String icon;
}
```

#### StudySet
```dart
class StudySet {
  final String id;
  final String name;
  final List<Flashcard> cards;
  final DateTime createdAt;
  final String courseId;
}
```

### 2. UI Components

#### FlipCard Widget
- **3D Flip Animation**: Uses Matrix4 transformation for realistic 3D effect
- **Dual Side Display**: Question on front, answer on back
- **Interactive**: Single tap toggles between sides
- **Smooth Animation**: 600ms easing curve for professional feel
- **Dark Mode**: Full color adaptation

**Features:**
- Rotates on Y-axis for flip effect
- Question side: Shows question + hint text
- Answer side: Shows full answer + flip instruction
- Gradient background on answer side (blue gradient)
- Shadow effects for depth

#### CourseSelector Widget
- **Dropdown Menu**: Animated dropdown with course list
- **Smooth Transitions**: Scale and rotation animations
- **Selection Indicator**: Checkmark for selected course
- **Dark Mode Support**: Proper contrast and borders
- **Responsive**: Auto-sizing based on content

**Features:**
- 300ms animation for dropdown
- List items with borders and separators
- Gradient button styling
- Icons rotate when dropdown opens/closes

#### CardActionButtons Widget
- **Three Action Buttons**: Mark as Known, Review Later, Shuffle Deck
- **Icon + Label Layout**: Icon above text for clarity
- **Semi-transparent Styling**: White background with 0.1 alpha
- **Blue Accent Color**: Consistent with app theme

#### CardProgressIndicator Widget
- **Progress Dots**: Visual representation of progress
- **Navigation Buttons**: Previous/Next with opacity states
- **Card Counter**: Shows "Card X of Y" text
- **Disabled States**: Buttons disabled at edges
- **Expandable Dots**: Current card dot expands

#### FlashcardsHeader Widget
- **Back Button**: Navigate away with styling
- **Regenerate Button**: Recreate flashcards with icon
- **Title & Description**: "Flashcards by AI" messaging
- **Fade Animation**: Appears on screen load

#### GenerateNewSetPanel Widget
- **Checkbox Option**: Include weak topics toggle
- **Generate Button**: Full-width blue button
- **Scale Animation**: Appears with scale effect
- **Option Storage**: State management for checkbox

### 3. Main Screen (`flashcards_screen.dart`)

#### State Management
- Tracks current card index
- Manages course selection
- Handles weak topics flag
- Animation controller for page transitions

#### Key Functions
- `_nextCard()`: Navigate to next card
- `_previousCard()`: Navigate to previous card
- `_shuffleDeck()`: Randomize card order
- `_markAsKnown()`: Mark card as known
- `_reviewLater()`: Mark for review
- `_generateNewSet()`: Trigger generation
- `_changeCourse()`: Switch course

#### Initialization
- **Courses**: 5 sample courses (Data Structures, Algorithms, ML, Web, Database)
- **Cards**: 5 sample flashcards with questions/answers
- **Theme**: Integrates with ThemeBloc for dark mode

## Features

### ✅ Flip Animation
- 3D rotation effect using Matrix4
- 600ms smooth animation
- Y-axis rotation for realistic flip
- Both sides of card properly styled

### ✅ Course Selection
- Dropdown menu with 5 courses
- Animated transitions
- Selection indicator (checkmark)
- Full dark mode support

### ✅ Navigation
- Previous/Next buttons with states
- Progress indicator dots
- Card counter display
- Disabled states at edges

### ✅ Action Buttons
- Mark as Known (checkmark icon)
- Review Later (refresh icon)
- Shuffle Deck (shuffle icon)
- Tap feedback (SnackBar notifications)

### ✅ Generate Panel
- Checkbox for weak topics option
- Generate New Set button
- Scale animation on appearance
- State persistence

### ✅ Dark Mode
- Full theme support via ThemeBloc
- Adaptive colors for all components
- Proper contrast ratios
- Border color adaptation

### ✅ Animations
- Card flip with 3D effect
- Dropdown menu scale/rotate
- Progress indicator fade
- Page transitions with fade
- Header fade on load
- Panel scale on appearance

### ✅ Responsive Design
- Uses standard padding (16px base)
- Adaptive text sizes
- Mobile-first design
- Works on all screen sizes

## Sample Data

### Courses
1. Data Structures (📊)
2. Algorithms (⚙️)
3. Machine Learning (🤖)
4. Web Development (🌐)
5. Database Design (💾)

### Flashcards (5 examples)
1. What is a Linked List?
2. What is the time complexity of binary search?
3. Explain the difference between stack and queue
4. What is a hash table?
5. What is a tree in data structures?

## Color Scheme

### Primary Colors
- **Gradient Blue**: #2B7FFF → #155DFC (primary buttons, flip card back)
- **Light Blue**: #2B7FFF (action text, icons)
- **Purple**: #8200DB (instructor badge)

### Neutral Colors (Light Mode)
- **Background**: #FAFAFA
- **Surface**: #FFFFFF
- **Text**: #101828
- **Secondary Text**: #4A5565

### Neutral Colors (Dark Mode)
- **Background**: #1A1A2E
- **Surface**: #2D2D44
- **Text**: #FFFFFF
- **Secondary Text**: #B0B0B0
- **Border**: #3D3D54

## Integration Steps

1. **Add to Routes**: Include FlashcardsScreen in navigation
2. **Model Integration**: Connect to backend API for real flashcards
3. **State Management**: Integrate with existing BLoC patterns
4. **Theme Support**: Already integrated with ThemeBloc
5. **Navigation**: Use Flutter Navigator for routing

## Example Navigation

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const FlashcardsScreen()),
);
```

## Performance Considerations

- Uses SingleTickerProviderStateMixin for efficient animations
- Animations are disposed properly to prevent memory leaks
- LocalAnimationController instances per widget
- No unnecessary rebuilds with proper state management
- Efficient list generation with indexed loops

## Accessibility

- Large tap targets (minimum 48x48 dp)
- Clear visual hierarchy
- Good color contrast
- Clear labels for all buttons
- Touch feedback via SnackBar notifications

## Future Enhancements

- [ ] Connect to real API for flashcard generation
- [ ] Add spaced repetition algorithm
- [ ] Voice-to-text question creation
- [ ] Collaborative study sets
- [ ] Performance analytics
- [ ] Export/Import study sets
- [ ] Gesture-based card navigation (swipe)
- [ ] Sound effects and haptic feedback

## Testing Recommendations

1. **Animation Tests**: Verify flip card rotation
2. **State Tests**: Check navigation and selection
3. **UI Tests**: Verify all buttons respond correctly
4. **Theme Tests**: Test dark and light modes
5. **Integration Tests**: Full user flow testing

## Notes

- All animations use Curves.easeOut for smooth transitions
- Colors follow Material Design guidelines
- Uses Arimo font for consistency with project
- Responsive padding uses fixed values (can be adapted with responsive.dart)
- Shadow effects use standard Material elevation
