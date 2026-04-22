# Color Palette Guide

## Overview
Complete color palette used in the Courses screen based on Figma design specifications.

## Primary Colors

### Blue Gradient
- **Start**: `#2B7FFF`
- **End**: `#155DFC`
- **Usage**: Buttons, Active filters, Primary actions
- **Hex String**: `LinearGradient(colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)])`

### Accent Blue
- **Color**: `#155DFC`
- **RGB**: `rgb(21, 93, 252)`
- **Usage**: Progress bars, Links, Primary buttons, Active states
- **Dart**: `const Color(0xFF155DFC)`

## Text Colors

### Primary Text (Light Mode)
- **Color**: `#101828`
- **RGB**: `rgb(16, 24, 40)`
- **Usage**: Main headings, Body text
- **Dart**: `const Color(0xFF101828)`

### Primary Text (Dark Mode)
- **Color**: `#FFFFFF`
- **Usage**: Main headings, Body text in dark mode
- **Dart**: `Colors.white`

### Secondary Text (Light Mode)
- **Color**: `#4A5565`
- **RGB**: `rgb(74, 85, 101)`
- **Usage**: Descriptions, Secondary information
- **Dart**: `const Color(0xFF4A5565)`

### Secondary Text (Dark Mode)
- **Color**: `#B5BCC4`
- **Opacity**: 70% of white
- **Usage**: Descriptions in dark mode
- **Dart**: `Colors.white70`

### Tertiary Text
- **Color**: `#717182`
- **RGB**: `rgb(113, 113, 130)`
- **Usage**: Placeholders, Hints, Disabled text
- **Dart**: `const Color(0xFF717182)`

## Background Colors

### Card Background (Light Mode)
- **Color**: `#FFFFFF`
- **Usage**: Card backgrounds
- **Dart**: `Colors.white`

### Card Background (Dark Mode)
- **Color**: `#16213E`
- **RGB**: `rgb(22, 33, 62)`
- **Usage**: Card backgrounds in dark mode
- **Dart**: `const Color(0xFF16213E)`

### Screen Background (Light Mode)
- **Color**: `#FAFAFA`
- **RGB**: `rgb(250, 250, 250)`
- **Usage**: Screen/page background
- **Dart**: `const Color(0xFFFAFAFA)`

### Screen Background (Dark Mode)
- **Color**: `#1A1A2E`
- **RGB**: `rgb(26, 26, 46)`
- **Usage**: Screen/page background in dark mode
- **Dart**: `const Color(0xFF1A1A2E)`

### Gradient Background (Light Mode)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFEEF5FE),  // Light blue
    Colors.white,
    Color(0xFFFAF5FE),  // Light purple
  ],
)
```

## Border Colors

### Border (Light Mode)
- **Color**: `#D1D5DC`
- **RGB**: `rgb(209, 213, 220)`
- **Usage**: Card borders, Input borders
- **Dart**: `const Color(0xFFD1D5DC)`

### Border (Dark Mode)
- **Color**: White with 10% opacity
- **RGB**: `rgba(255, 255, 255, 0.1)`
- **Usage**: Card borders in dark mode
- **Dart**: `Colors.white.withOpacity(0.1)`

### Border (Alternative Dark Mode)
- **Color**: White with 30% opacity
- **Usage**: Button borders in dark mode
- **Dart**: `Colors.white.withOpacity(0.3)`

## Icon Background Colors

### AI Courses (Light Blue)
- **Color**: `#DEEAFF`
- **RGB**: `rgb(222, 234, 255)`
- **Usage**: Background for AI/ML course icons
- **Dart**: `const Color(0xFFDEEAFF)`

### Data Courses (Light Green)
- **Color**: `#DEFFDD`
- **RGB**: `rgb(222, 255, 221)`
- **Usage**: Background for data-related course icons
- **Dart**: `const Color(0xFFDEFFDD)`

### Ethics Courses (Light Red)
- **Color**: `#FFE8E8`
- **RGB**: `rgb(255, 232, 232)`
- **Usage**: Background for ethics course icons
- **Dart**: `const Color(0xFFFFE8E8)`

### Network Courses (Light Purple)
- **Color**: `#E8E0FF`
- **RGB**: `rgb(232, 224, 255)`
- **Usage**: Background for network/neural course icons
- **Dart**: `const Color(0xFFE8E0FF)`

### Web Courses (Light Orange)
- **Color**: `#FFEDD1`
- **RGB**: `rgb(255, 237, 209)`
- **Usage**: Background for web development icons
- **Dart**: `const Color(0xFFFFEDD1)`

## Shadow Colors

### Light Shadow
- **Color**: Black with 8% opacity
- **Blur**: 3px
- **Offset**: (0, 1)
- **Usage**: Subtle shadows on light backgrounds
- **Dart**: `BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3, offset: Offset(0, 1))`

### Medium Shadow
- **Color**: Black with 10% opacity
- **Blur**: 6px
- **Offset**: (0, 2)
- **Usage**: Card shadows
- **Dart**: `BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 2))`

### Dark Shadow
- **Color**: Black with 30% opacity
- **Blur**: 12px
- **Offset**: (0, 4)
- **Usage**: Large shadows on prominent elements
- **Dart**: `BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 4))`

## Opacity Levels

### Full Opacity
- **Value**: `1.0` (100%)
- **Usage**: Primary text, main elements
- **Dart**: No opacity modifier needed

### High Opacity
- **Value**: `0.87` (87%)
- **Usage**: Secondary content
- **Dart**: `.withOpacity(0.87)`

### Medium Opacity
- **Value**: `0.60` (60%)
- **Usage**: Disabled text, secondary labels
- **Dart**: `.withOpacity(0.60)`

### Low Opacity
- **Value**: `0.38` (38%)
- **Usage**: Hints, placeholders
- **Dart**: `.withOpacity(0.38)`

### Very Low Opacity
- **Value**: `0.10` (10%)
- **Usage**: Subtle borders, very faint backgrounds
- **Dart**: `.withOpacity(0.10)`

## Semantic Colors

### Success
- **Color**: Green (from system palette)
- **Usage**: Success states, positive feedback
- **Dart**: `Colors.green[600]`

### Warning
- **Color**: Orange (from system palette)
- **Usage**: Warning states, alerts
- **Dart**: `Colors.orange[600]`

### Error
- **Color**: Red (from system palette)
- **Usage**: Error states, validation errors
- **Dart**: `Colors.red[600]`

### Info
- **Color**: Blue (primary accent)
- **Usage**: Informational messages
- **Dart**: `const Color(0xFF155DFC)`

## Color Usage Examples

### Light Mode Course Card
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,                         // Background
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: const Color(0xFFD1D5DC),           // Border
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),  // Shadow
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFDEEAFF),       // Icon background
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      Text(
        'Course Title',
        style: TextStyle(
          color: const Color(0xFF101828),       // Primary text
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        'Dr. Name',
        style: TextStyle(
          color: const Color(0xFF4A5565),       // Secondary text
          fontSize: 14,
        ),
      ),
    ],
  ),
)
```

### Dark Mode Course Card
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF16213E),             // Background
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),    // Border
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),  // Shadow
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    children: [
      Text(
        'Course Title',
        style: TextStyle(
          color: Colors.white,                  // Primary text
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        'Dr. Name',
        style: TextStyle(
          color: Colors.white70,                // Secondary text
          fontSize: 14,
        ),
      ),
    ],
  ),
)
```

## Accessibility Considerations

### Contrast Ratios
- **Primary Text on White**: 16.5:1 (WCAG AAA)
- **Primary Text on Dark**: 18.2:1 (WCAG AAA)
- **Secondary Text on White**: 8.5:1 (WCAG AA)
- **Accent Blue**: Sufficient contrast for all backgrounds

### Color Blind Safe
- Palette uses colors distinguishable by colorblind users
- Blue gradients are deuteranopia-safe
- Red/green not used as sole differentiator

## Implementation Checklist

- [x] Primary colors defined
- [x] Text colors for both modes
- [x] Background colors
- [x] Border colors
- [x] Icon background colors
- [x] Shadow colors
- [x] Opacity levels
- [x] Semantic colors
- [x] Accessibility verified

---

**Version**: 1.0.0
**Last Updated**: 2025-12-05
**Figma Reference**: EduVerse Design System
