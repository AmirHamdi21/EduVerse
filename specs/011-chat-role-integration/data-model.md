# Data Model: Role-Specific Screen Integration & Unification

**Feature**: 011-chat-role-integration  
**Date**: 2026-04-07

## Overview

This phase is primarily a UI integration effort that composes existing components from Phases 3-5. It does not introduce new data models but defines the configuration structures needed to support role-specific customization of the unified chat screen.

## Configuration Entities

### RoleConfiguration

Defines the visual and behavioral settings for each role when accessing the shared chat screen.

**Properties**:
| Property | Type | Required | Description | Validation |
|----------|------|----------|-------------|------------|
| `accentColor` | `Color` | Yes | Primary color for UI elements (message bubbles, buttons) | Must be valid hex color |
| `defaultDisplayName` | `String` | Yes | Fallback display name if auth context unavailable | Non-empty string |
| `isDarkMode` | `bool` | Yes | Whether to apply dark theme styling | true/false |
| `currentUserId` | `String?` | No | Authenticated user ID | Nullable, from auth context |
| `currentUserName` | `String?` | No | Authenticated user's full name | Nullable, overrides defaultDisplayName |

**Example Instances**:
```dart
// Student Configuration
RoleConfiguration(
  accentColor: Color(0xFF3B82F6),  // Blue
  defaultDisplayName: 'Student',
  isDarkMode: false,
  currentUserId: '12345',
  currentUserName: 'John Doe',
)

// Instructor Configuration
RoleConfiguration(
  accentColor: Color(0xFF4F46E5),  // Indigo
  defaultDisplayName: 'Instructor',
  isDarkMode: true,
  currentUserId: '67890',
  currentUserName: 'Prof. Sarah Martinez',
)
```

**Lifecycle**: Created once per role dashboard render, passed as props to `SharedChatScreen`.

---

### SharedChatScreenProps

Interface defining all props accepted by the unified chat screen component.

**Properties**:
| Property | Type | Required | Description | Default |
|----------|------|----------|-------------|---------|
| `accentColor` | `Color` | No | Primary UI color | `Color(0xFF4F46E5)` (indigo) |
| `currentUserName` | `String` | No | Display name for current user | `'User'` |
| `currentUserId` | `String?` | No | Authenticated user ID | `null` |
| `isDark` | `bool` | No | Dark mode flag | `false` |

**Validation Rules**:
- If `accentColor` is not provided, default to indigo (#4F46E5)
- If `currentUserName` is empty or null, fallback to generic 'User'
- `isDark` must respect the dashboard's theme context

**Usage Pattern**:
```dart
SharedChatScreen(
  accentColor: roleConfig.accentColor,
  currentUserName: roleConfig.currentUserName ?? roleConfig.defaultDisplayName,
  currentUserId: roleConfig.currentUserId,
  isDark: roleConfig.isDarkMode,
)
```

---

### DashboardRoute

Represents the navigation configuration mapping each role's chat tab to the shared screen.

**Properties**:
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `routePath` | `String` | Yes | Go_router path (e.g., `/studentdashboard/chat`) |
| `tabKey` | `String` | Yes | Dashboard tab identifier (e.g., `'chat'`) |
| `roleType` | `RoleType` | Yes | Enum: `student`, `instructor`, `ta`, `admin`, `itAdmin` |
| `accentColor` | `Color` | Yes | Role-specific accent color |
| `defaultDisplayName` | `String` | Yes | Fallback user name |

**Route Mapping Table**:
| Role | routePath | tabKey | accentColor | defaultDisplayName |
|------|-----------|--------|-------------|-------------------|
| Student | `/studentdashboard/chat` | `chat` | `#3B82F6` | `'Student'` |
| Instructor | `/instructordashboard/chat` | `chat` | `#4F46E5` | `'Instructor'` |
| TA | `/tadashboard/messages` | `messages` | `#4F46E5` | `'TA'` |
| Admin | `/admindashboard/messages` | `messages` | `#4F46E5` | `'Administrator'` |
| IT Admin | `/itadmindashboard/chat` | `chat` | `#3B82F6` | `'IT Administrator'` |

**State Transitions**: N/A (static configuration)

---

## Existing Models (Reused from Phase 2)

This phase **does not modify** the following existing models but depends on them:

### ChatBloc State

- **`ChatState`**: Contains `conversations`, `messages`, `selectedConversation`, `connectionStatus`, `typingUsers`, `onlineUsers`
- **Source**: `lib/bloc/chat/chat_state.dart` (Phase 2)
- **Usage**: `SharedChatScreen` consumes `ChatState` via `BlocBuilder<ChatBloc, ChatState>`

### ConversationModel

- **Fields**: `conversationId`, `type`, `name`, `participants`, `participantUsers`, `directDisplayUser`, `lastMessage`, `unreadCount`, `lastMessageAt`
- **Source**: `lib/bloc/chat/chat_models.dart` (Phase 2)
- **Usage**: Passed to `ConversationListWidget` (Phase 3)

### ChatMessageModel

- **Fields**: `id`, `text`, `senderId`, `senderName`, `sentAt`, `editedAt`, `isDeleted`, `replyToId`, `conversationId`, `status`
- **Source**: `lib/bloc/chat/chat_models.dart` (Phase 2)
- **Usage**: Passed to `MessageDetailWidget` (Phase 4)

---

## Responsive Layout Model

### LayoutMode (Enum)

Represents the current responsive layout mode based on screen width.

**Note**: This is pseudo-code for planning purposes. The actual enum will be defined in lib/screens/shared/chat_screen.dart per tasks.md:T024.

**Values**:
- `mobile`: Screen width < 600px → Stack navigation between list and detail
- `tabletDesktop`: Screen width ≥ 600px → Side-by-side layout (terminology: use "tablet/desktop" in documentation)

**Determination Logic**:
```dart
enum LayoutMode { mobile, tabletDesktop }

LayoutMode getLayoutMode(double screenWidth) {
  return screenWidth < 600 ? LayoutMode.mobile : LayoutMode.tabletDesktop;
}
```

**State Transitions**:
```
mobile ↔ tabletDesktop  (triggered by screen width crossing 600px threshold)
```

---

## Validation Rules

### Role Configuration Validation

1. **accentColor**: Must be a valid `Color` object (no null or invalid hex)
2. **defaultDisplayName**: Must be non-empty string
3. **isDarkMode**: Must be boolean (not nullable)

### Route Validation

1. **routePath**: Must start with `/` and match existing dashboard route patterns
2. **tabKey**: Must correspond to existing dashboard tab key
3. **roleType**: Must be one of the 5 defined RoleType enum values

### Layout Breakpoint Validation

1. **Breakpoint**: Must be exactly 600px (no dynamic adjustment)
2. **Transition**: Must be smooth without widget rebuilds or flashing

---

## Data Flow Diagram

```
Dashboard Context
    ↓
RoleConfiguration (accentColor, displayName, isDark)
    ↓
SharedChatScreen Props
    ↓
LayoutBuilder (detects 600px breakpoint)
    ↓
    ├─→ Mobile Layout (< 600px)
    │       ├─→ ConversationListWidget (from Phase 3)
    │       └─→ MessageDetailWidget (from Phase 4) [navigated to]
    │
    └─→ Tablet/Desktop Layout (≥ 600px)
            ├─→ ConversationListWidget (left, fixed 320px)
            └─→ MessageDetailWidget (right, flexible)
    
Both layouts overlay:
    └─→ NewConversationDialog (from Phase 5) [when triggered]
    
All consume:
    └─→ ChatBloc State (conversations, messages, connectionStatus)
```

---

## Dependencies

- **Phase 2**: `ChatBloc`, `ChatState`, `ConversationModel`, `ChatMessageModel`
- **Phase 3**: `ConversationListWidget`
- **Phase 4**: `MessageDetailWidget`
- **Phase 5**: `NewConversationDialog`

---

## Edge Cases

1. **Missing auth context**: Fall back to `defaultDisplayName` from role configuration
2. **ChatBloc not provided**: Display error screen with helpful message (not crash)
3. **Invalid accent color**: Fall back to default indigo (#4F46E5)
4. **Rapid breakpoint crossing**: Debounce layout transitions to prevent jank
5. **Role change during active session**: Apply new role styling on next login (not mid-session)

---

## Next Steps

Proceed to **quickstart.md** to define the developer guide for integrating the unified chat screen into each role dashboard.
