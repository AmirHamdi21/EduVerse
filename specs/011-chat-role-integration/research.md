# Research: Role-Specific Screen Integration & Unification

**Feature**: 011-chat-role-integration  
**Date**: 2026-04-07  
**Status**: Complete

## Overview

This research phase investigates the technical requirements for creating a unified chat screen that replaces four separate role-specific implementations while preserving role-specific styling and responsive layout behavior.

## Research Questions & Findings

### 1. Responsive Layout Implementation (600px Breakpoint)

**Question**: What is the best practice for implementing responsive layout switching at 600px in Flutter?

**Decision**: Use `LayoutBuilder` with `MediaQuery.of(context).size.width` to detect breakpoint and conditionally render mobile vs tablet/desktop layouts.

**Rationale**:
- `LayoutBuilder` provides accurate constraints at build time
- 600px aligns with Material Design mobile/tablet breakpoint standards
- Allows smooth transitions without rebuilding entire widget tree
- Matches website frontend's responsive behavior

**Alternatives Considered**:
- **Device type detection** (`Platform.isAndroid`): Rejected because it doesn't account for tablets or web responsive design
- **Hardcoded aspect ratio checks**: Rejected because unreliable for foldable devices and desktop window resizing
- **Separate routes for mobile/tablet**: Rejected because it would break smooth transitions and require duplicate navigation logic

**Implementation Pattern**:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isTabletOrDesktop = constraints.maxWidth >= 600;
    return isTabletOrDesktop
        ? Row(children: [conversationList, messageDetail])  // Side-by-side
        : Navigator(/* list ↔ detail navigation */);        // Stack navigation
  },
)
```

---

### 2. ChatBloc Scope Placement Strategy

**Question**: How should ChatBloc be provided to ensure accessibility to all five role dashboards without duplication?

**Decision**: Provide ChatBloc as a single `BlocProvider` wrapping the entire `MaterialApp` in `main.dart`.

**Rationale**:
- Guarantees single instance shared across all routes
- Prevents state duplication or synchronization issues
- Allows chat state to persist when switching between role dashboards
- Follows Flutter BLoC best practices for app-wide state

**Alternatives Considered**:
- **Provide in each dashboard**: Rejected because it would create 5 separate ChatBloc instances, breaking message synchronization
- **Provide in router configuration**: Rejected because go_router doesn't support BlocProvider wrapping at route level
- **Lazy initialization per role**: Rejected because it would delay chat availability and complicate lifecycle management

**Implementation Pattern**:
```dart
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            chatService: ChatService(),
            socketService: ChatSocketService(),
          ),
        ),
        // ... other global blocs
      ],
      child: MaterialApp(...),
    ),
  );
}
```

---

### 3. Legacy Code Removal Timing & Strategy

**Question**: When and how should the ~25+ legacy widget files be safely removed?

**Decision**: Remove legacy files only after successful smoke tests validate the unified screen works correctly for all five roles.

**Rationale**:
- Minimizes risk of breaking production functionality
- Allows quick rollback if critical issues are discovered
- Provides time to verify edge cases (offline, role switching, deep links)
- Aligns with safe deployment best practices

**Alternatives Considered**:
- **Same deployment (immediate deletion)**: Rejected because it removes the safety net if the unified screen has bugs
- **Gradual deprecation over sprint**: Rejected because maintaining parallel implementations increases complexity
- **Feature flag toggle**: Rejected because it adds unnecessary infrastructure for a one-time migration

**Deletion Checklist**:
1. ✅ Deploy unified `SharedChatScreen`
2. ✅ Smoke test all 5 roles (Student, Instructor, TA, Admin, IT Admin)
3. ✅ Verify accent colors, responsive layouts, message sending/receiving
4. ✅ Check for broken imports or route references
5. ✅ Delete legacy screens and widgets
6. ✅ Remove orphaned imports from navigation files
7. ✅ Run `flutter build` to ensure no compile errors
8. ✅ Final integration test across all roles

---

### 4. Role-Specific Prop Configuration

**Question**: How should role-specific styling (accent colors, user names) be passed to the unified screen?

**Decision**: Extract role-specific configuration (accent color, user name) from existing dashboard context and pass as props to `SharedChatScreen`.

**Rationale**:
- Maintains separation of concerns (screen doesn't know about roles)
- Makes screen highly reusable and testable
- Allows easy theme updates without modifying shared screen code
- Matches website frontend's prop-based customization pattern

**Configuration Map**:
| Role | Accent Color | Default Display Name |
|------|-------------|----------------------|
| Student | `#3B82F6` (blue) | From auth or "Student" |
| Instructor | `#4F46E5` (indigo) | From auth or "Instructor" |
| TA | `#4F46E5` (indigo) | From auth or "TA" |
| Admin | `#4F46E5` (indigo) | From auth or "Administrator" |
| IT Admin | `#3B82F6` (blue) | From auth or "IT Administrator" |

**Implementation Pattern**:
```dart
SharedChatScreen(
  accentColor: Color(0xFF3B82F6),  // From role config
  currentUserName: user?.fullName ?? 'Student',
  currentUserId: user?.userId.toString(),
  isDark: Theme.of(context).brightness == Brightness.dark,
)
```

---

### 5. Composition of Existing Phase 3-5 Components

**Question**: How should the unified screen compose the existing conversation list, message detail, and new chat dialog components?

**Decision**: Import and compose `ConversationListWidget`, `MessageDetailWidget`, and `NewConversationDialog` from `lib/widgets/shared/chat/` with responsive container logic.

**Rationale**:
- Reuses thoroughly tested components from previous phases
- Maintains single source of truth for each UI piece
- Simplifies maintenance (fixes propagate to all roles automatically)
- Follows React website's component composition pattern

**Component Dependencies** (from Phases 3-5):
- `ConversationListWidget` (Phase 3): Displays conversation list with search, filters, unread badges
- `MessageDetailWidget` (Phase 4): Displays message thread with reply, delete, typing indicators
- `NewConversationDialog` (Phase 5): Modal for starting new conversation by email search

**Composition Strategy**:
- Mobile (< 600px): Stack navigation between `ConversationListWidget` and `MessageDetailWidget`
- Tablet/Desktop (≥ 600px): `Row` with fixed-width `ConversationListWidget` (320px) and flexible `MessageDetailWidget`
- `NewConversationDialog` overlays on both layouts when triggered

---

## Dependencies Verified

All required dependencies are already present in `pubspec.yaml`:
- ✅ `flutter_bloc: ^8.1.3` - State management
- ✅ `equatable: ^2.0.5` - Value equality for BLoC states
- ✅ `go_router: ^13.0.0` - Navigation

No additional packages required.

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Broken route references after deletion | Medium | High | Run comprehensive grep for all legacy screen imports before deletion |
| ChatBloc not accessible in some contexts | Low | High | Validate BlocProvider wraps MaterialApp in main.dart |
| Visual regressions in role-specific colors | Medium | Medium | Manual QA checklist for all 5 roles before legacy deletion |
| Performance degradation on low-end devices | Low | Medium | Profile layout build times, ensure <16ms frame time |
| Offline state not preserved during layout switch | Low | Medium | Test responsive breakpoint crossing with airplane mode enabled |

---

## Success Metrics

- ✅ Single `SharedChatScreen` file replaces 4 separate implementations
- ✅ All 5 roles render correct accent colors
- ✅ Layout transitions smoothly at 600px breakpoint
- ✅ ~25+ legacy files successfully deleted with zero broken imports
- ✅ Build time reduced or unchanged after cleanup
- ✅ No user-reported regressions post-migration

---

## Next Steps

Proceed to **Phase 1: Design & Contracts** to define the `SharedChatScreen` component interface and update the agent context with this implementation plan.
