# StudentStatsSection Visual Design Mockup

## Light Theme Preview

```
╔═══════════════════════════════════════════════════════════╗
║  Good Evening, Amir 👋                                    ║
║  (26px, Bold, Dark Gray)                                  ║
╠═══════════════════════╦═══════════════════════════════════╣
║                       ║                                   ║
║  ┌──────────┐         ║  ┌──────────┐                    ║
║  │ 🎓 (GPA) │  3.62   ║  │ ✅ (ATD) │  100               ║
║  └──────────┘         ║  └──────────┘                    ║
║  GPA          90%     ║  Attendance   100%               ║
║                       ║  ⭐ Perfect                       ║
║  (Purple gradient BG) ║  (Green gradient BG)             ║
║  140px height         ║  140px height                    ║
╠═══════════════════════╩═══════════════════════════════════╣
║                                                           ║
║  📈 Semester Progress                        [ 67% ]     ║
║                                              (Blue badge)║
║  ▓▓▓▓▓▓▓▓░░░░░░░                                         ║
║  Started ←──────────────────────────→ Complete           ║
║  (Animated blue progress bar with glow)                  ║
║                                                           ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ╔═══╗  ⏰ Upcoming Deadline                         →   ║
║  ║NOV║  Calculus II Exam                                ║
║  ║12 ║  (Bold, Dark Text)                               ║
║  ╚═══╝  2025 (Small text)                                ║
║  (Red gradient calendar with glow shadow)                ║
║  (Red gradient background with border)                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

## Dark Theme Preview

```
╔═══════════════════════════════════════════════════════════╗
║  Good Evening, Amir 👋                                    ║
║  (26px, Bold, White)                                      ║
╠═══════════════════════╦═══════════════════════════════════╣
║                       ║                                   ║
║  ┌──────────┐         ║  ┌──────────┐                    ║
║  │ 🎓 White │  3.62   ║  │ ✅ White │  100               ║
║  └──────────┘         ║  └──────────┘                    ║
║  GPA          90%     ║  Attendance   100%               ║
║  (Light purple text)  ║  (Light green text) ⭐           ║
║  (Dark purple glow BG)║  (Dark green glow BG)            ║
║  140px height         ║  140px height                    ║
╠═══════════════════════╩═══════════════════════════════════╣
║                                                           ║
║  📈 Semester Progress                        [ 67% ]     ║
║  (White text)                      (Blue gradient badge) ║
║  ▓▓▓▓▓▓▓▓░░░░░░░                                         ║
║  Started ←──────────────────────────→ Complete           ║
║  (Blue progress bar with stronger glow on dark BG)       ║
║  (Dark slate background)                                 ║
║                                                           ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ╔═══╗  ⏰ Upcoming Deadline                         →   ║
║  ║NOV║  Calculus II Exam                                ║
║  ║12 ║  (White, Bold Text)                              ║
║  ╚═══╝  2025                                             ║
║  (Red gradient calendar with stronger glow)              ║
║  (Dark red glow background)                              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

## Component Breakdown

### 1. Compact Stat Cards (GPA & Attendance)
```
Width: 50% each (with 12px gap)
Height: 140px
Padding: 16px
Border Radius: 20px

┌─────────────────────────┐
│ ┌─────┐           [⭐]  │  ← Icon badge & Perfect star (if 100%)
│ │ 🎓  │                 │
│ └─────┘                 │
│                         │
│ 3.62                    │  ← Large value (28px)
│ GPA            90%      │  ← Title & percentage (13px/12px)
└─────────────────────────┘

Background: Gradient (subtle, colored)
Icon Badge: Gradient (bold, with shadow)
Border: Matching color with alpha
```

### 2. Semester Progress Card
```
Width: 100%
Height: ~110px
Padding: 20px
Border Radius: 20px

┌────────────────────────────────────┐
│ 📈 Semester Progress    [ 67% ]    │  ← Icon + Title + Badge
│                                    │
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░         │  ← Progress bar (12px height)
│ Started        Complete            │  ← Labels (11px)
└────────────────────────────────────┘

Progress Colors (Dynamic):
- Green: ≥80%
- Blue: 50-79%
- Orange: <50%

Percentage Badge: Gradient with glow shadow
Progress Bar: Animated, gradient, rounded
```

### 3. Compact Deadline Card
```
Width: 100%
Height: ~96px
Padding: 18px
Border Radius: 20px

┌────────────────────────────────────┐
│ ╔═══╗  ⏰ Upcoming Deadline    →  │
│ ║NOV║  Calculus II Exam           │
│ ║12 ║  (Course name, 15px bold)   │
│ ╚═══╝  2025                        │
└────────────────────────────────────┘

Calendar Badge: 60x60px, red gradient, glow
Background: Red gradient (subtle)
Border: Red with stronger alpha
Arrow: Indicates tap action
```

## Color Specifications

### Light Theme Colors
```
Background Cards:      #FFFFFF
Text Primary:          #0F172A (Slate 900)
Text Secondary:        #64748B (Slate 500)
Border Default:        #E5E7EB (Gray 200)
Progress Bar BG:       #F1F5F9 (Slate 100)

Gradients (Backgrounds - Subtle):
GPA:        #8B5CF6 (8% alpha) → #EC4899 (5% alpha)
Attendance: #10B981 (8% alpha) → #059669 (5% alpha)
Progress:   White → #F8FAFC
Deadline:   #EF4444 (6% alpha) → #FEE2E2

Gradients (Icons & Badges - Bold):
GPA:        #8B5CF6 → #EC4899
Attendance: #10B981 → #059669
Progress:   #3B82F6 → #2563EB (Blue for 50-79%)
            #10B981 → #059669 (Green for ≥80%)
            #F59E0B → #D97706 (Orange for <50%)
Deadline:   #EF4444 → #DC2626

Shadows:
Soft:       rgba(0,0,0,0.04), 12px blur
Icon Glow:  Primary color with 30% alpha, 8-12px blur
```

### Dark Theme Colors
```
Background Cards:      #1E293B (Slate 800)
Text Primary:          #FFFFFF
Text Secondary:        rgba(255,255,255,0.7)
Border Default:        rgba(255,255,255,0.08)
Progress Bar BG:       rgba(255,255,255,0.08)

Gradients (Backgrounds - Stronger):
GPA:        #8B5CF6 (15% alpha) → #EC4899 (10% alpha)
Attendance: #10B981 (15% alpha) → #059669 (10% alpha)
Progress:   #1E293B → #1E293B (80% alpha)
Deadline:   #EF4444 (12% alpha) → #DC2626 (8% alpha)

Gradients (Icons & Badges - Same as light):
(Icons remain vibrant for visibility)

Shadows:
Icon Glow:  Primary color with 30-40% alpha, stronger blur
```

## Spacing & Measurements

### Grid System
```
Screen Width: 100% (with 16px padding on sides)
Column Gap: 12px
Row Gap: 12px
Header Spacing: 16px below greeting

Card Layout:
Row 1: [50% Card] [12px gap] [50% Card]
Row 2: [100% Card]
Row 3: [100% Card]

Total Height: ~350px
├─ Greeting: 26px
├─ Gap: 16px
├─ Row 1 (Compact Cards): 140px
├─ Gap: 12px
├─ Row 2 (Progress): ~110px
├─ Gap: 12px
└─ Row 3 (Deadline): ~96px
```

### Touch Targets
```
Minimum: 48x48px
Calendar Badge: 60x60px ✅
Icon Badges: 36x36px (inside cards, less critical)
Entire Cards: Tappable for future interactions
```

## Animation Details

### Progress Bar Animation
```
Duration: 1500ms
Curve: easeOutCubic
Delay: 100ms (after build)
Animates: Width from 0% to actual percentage
Effect: Smooth fill with gradient
```

### Future Animation Ideas
- Fade in cards sequentially (stagger by 100ms)
- Scale effect on perfect score badge
- Pulse animation on urgent deadline
- Shimmer effect while loading data

## Responsive Behavior

### Portrait (Normal)
```
Uses described layout
Optimal viewing experience
```

### Landscape (Tablet)
```
Could show all 4 stats in single row
Progress bar below in full width
Deadline at bottom full width
```

### Small Screens (<360px width)
```
Maintains current layout
Text scales slightly
Padding reduces to 12px
```

## Implementation Tips

### For Developers
1. Use `LayoutBuilder` for responsive adjustments
2. Cache gradient objects for performance
3. Use `RepaintBoundary` on animated widgets
4. Implement `AutomaticKeepAliveClientMixin` if in scrollable
5. Add haptic feedback on taps

### For Designers
1. Export icons at 3x resolution
2. Provide gradient color stops if needed
3. Specify shadow blur and spread values
4. Include transition/animation specs
5. Document interactive states

## Accessibility Features

### Screen Readers
- Semantic labels for all stats
- Progress percentages announced
- Deadline urgency conveyed
- Achievement badges acknowledged

### Visual
- High contrast maintained (WCAG AA)
- Large touch targets (≥48px)
- Clear visual hierarchy
- Color not sole indicator (icons + text)

### Motion
- Respects `prefers-reduced-motion`
- Can disable animations
- Instant display mode available

---

**Design Status**: ✅ Implemented & Tested
**Performance**: ✅ Optimized
**Accessibility**: ✅ WCAG AA Compliant
**Responsive**: ✅ Adaptive Layout
