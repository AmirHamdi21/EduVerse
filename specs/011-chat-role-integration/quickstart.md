# Quickstart: Role-Specific Screen Integration & Unification

**Feature**: 011-chat-role-integration  
**Date**: 2026-04-07  
**Audience**: Flutter developers implementing the unified chat screen

## Prerequisites

Before starting this integration, ensure the following phases are complete:

- ✅ **Phase 1-2**: ChatBloc, ChatService, ChatSocketService implemented and tested
- ✅ **Phase 3**: ConversationListWidget created in `lib/widgets/shared/chat/`
- ✅ **Phase 4**: MessageDetailWidget created in `lib/widgets/shared/chat/`
- ✅ **Phase 5**: NewConversationDialog created in `lib/widgets/shared/chat/`

## Quick Start (5 minutes)

### Step 1: Ensure ChatBloc is provided globally

**File**: `lib/main.dart`

```dart
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        // Add ChatBloc as global provider if not already present
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            chatService: ChatService(),
            socketService: ChatSocketService(),
          ),
        ),
        // ... other global blocs
      ],
      child: const MyApp(),
    ),
  );
}
```

**Verification**: Run the app and verify no "BlocProvider not found" errors occur when navigating to any dashboard.

---

### Step 2: Create the unified SharedChatScreen

**File**: `lib/screens/shared/chat_screen.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../widgets/shared/chat/conversation_list_widget.dart';
import '../../widgets/shared/chat/message_detail_widget.dart';
import '../../widgets/shared/chat/new_conversation_dialog.dart';

class SharedChatScreen extends StatelessWidget {
  final Color accentColor;
  final String currentUserName;
  final String? currentUserId;
  final bool isDark;

  const SharedChatScreen({
    Key? key,
    this.accentColor = const Color(0xFF4F46E5), // Indigo default
    this.currentUserName = 'User',
    this.currentUserId,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletOrDesktop = constraints.maxWidth >= 600;

        return Scaffold(
          body: isTabletOrDesktop
              ? _buildTabletDesktopLayout(context)
              : _buildMobileLayout(context),
        );
      },
    );
  }

  // Side-by-side layout for tablet/desktop (≥ 600px)
  Widget _buildTabletDesktopLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: ConversationListWidget(
            accentColor: accentColor,
            isDark: isDark,
          ),
        ),
        Expanded(
          child: MessageDetailWidget(
            accentColor: accentColor,
            currentUserName: currentUserName,
            currentUserId: currentUserId,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // Stack navigation for mobile (< 600px)
  Widget _buildMobileLayout(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final hasSelectedConversation = state.selectedConversation != null;

        return hasSelectedConversation
            ? MessageDetailWidget(
                accentColor: accentColor,
                currentUserName: currentUserName,
                currentUserId: currentUserId,
                isDark: isDark,
                showBackButton: true,
                onBackPressed: () {
                  context.read<ChatBloc>().add(DeselectConversation());
                },
              )
            : ConversationListWidget(
                accentColor: accentColor,
                isDark: isDark,
              );
      },
    );
  }
}
```

---

### Step 3: Update navigation routes for each role

**File**: `lib/routes/app_router.dart` (MODIFY)

```dart
import '../screens/shared/chat_screen.dart';

// Add shared chat route for each role
GoRoute(
  path: '/studentdashboard/chat',
  builder: (context, state) => SharedChatScreen(
    accentColor: Color(0xFF3B82F6), // Blue
    currentUserName: user?.fullName ?? 'Student',
    currentUserId: user?.userId.toString(),
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
),

GoRoute(
  path: '/instructordashboard/chat',
  builder: (context, state) => SharedChatScreen(
    accentColor: Color(0xFF4F46E5), // Indigo
    currentUserName: user?.fullName ?? 'Instructor',
    currentUserId: user?.userId.toString(),
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
),

GoRoute(
  path: '/tadashboard/messages',
  builder: (context, state) => SharedChatScreen(
    accentColor: Color(0xFF4F46E5), // Indigo
    currentUserName: user?.fullName ?? 'TA',
    currentUserId: user?.userId.toString(),
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
),

GoRoute(
  path: '/admindashboard/messages',
  builder: (context, state) => SharedChatScreen(
    accentColor: Color(0xFF4F46E5), // Indigo
    currentUserName: user?.fullName ?? 'Administrator',
    currentUserId: user?.userId.toString(),
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
),

GoRoute(
  path: '/itadmindashboard/chat',  // NEW route for IT Admin
  builder: (context, state) => SharedChatScreen(
    accentColor: Color(0xFF3B82F6), // Blue
    currentUserName: user?.fullName ?? 'IT Administrator',
    currentUserId: user?.userId.toString(),
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
),
```

---

### Step 4: Add Chat tab to IT Admin dashboard

**File**: `lib/screens/it_admin/it_admin_dashboard.dart` (MODIFY)

```dart
// Add to sidebar tabs
final tabs = [
  // ... existing tabs
  DashboardTab(
    key: 'chat',
    label: 'Chat',  // Or use i18n: t('chat')
    icon: Icons.message,
    group: 'Communication',
  ),
];

// Add to tab content rendering
if (activeTab == 'chat') {
  return SharedChatScreen(
    accentColor: Color(0xFF3B82F6),  // Blue
    currentUserName: user?.fullName ?? 'IT Administrator',
    currentUserId: user?.userId.toString(),
    isDark: isDark,
  );
}
```

---

### Step 5: Smoke test all roles

Run the app and verify for **each role** (Student, Instructor, TA, Admin, IT Admin):

1. ✅ Navigate to Chat/Messages tab
2. ✅ Verify accent color matches expected value (blue for Student/IT Admin, indigo for others)
3. ✅ Send a message and verify it appears
4. ✅ Receive a message (use another account) and verify unread badge updates
5. ✅ Resize window/rotate device and verify layout transitions smoothly at 600px
6. ✅ Toggle dark mode and verify theme updates immediately

---

### Step 6: Remove legacy files (AFTER smoke tests pass)

**Delete the following files**:

```bash
# Student legacy chat
rm lib/screens/student/chat/chat_screen.dart
rm -r lib/widgets/student/chat/  # 10 widget files

# Instructor legacy chat
rm lib/screens/instructor/chat/instructor_chat_screen.dart
rm -r lib/widgets/instructor/chat/  # 10 widget files

# TA legacy messages
rm lib/screens/ta/messages/ta_messages_screen.dart

# Admin legacy messages
rm lib/screens/admin/messages/admin_messages_screen.dart
rm -r lib/widgets/admin/messages/  # 5 widget files
```

**Remove legacy imports**:
```bash
# Find and remove all references to legacy screens
grep -r "student/chat/chat_screen" lib/
grep -r "instructor/chat/instructor_chat_screen" lib/
grep -r "ta/messages/ta_messages_screen" lib/
grep -r "admin/messages/admin_messages_screen" lib/
```

**Verification**:
```bash
flutter build apk --debug  # Or flutter build web
# Should complete without errors
```

---

## Common Issues & Solutions

### Issue: ChatBloc not found error

**Symptom**: `BlocProvider.of() called with a context that does not contain a ChatBloc`

**Solution**: Verify `ChatBloc` is provided in `main.dart` **above** `MaterialApp`, not inside individual screens.

---

### Issue: Layout doesn't transition at 600px

**Symptom**: Stuck in mobile or tablet layout regardless of window size

**Solution**: Check `LayoutBuilder` constraints. Use `MediaQuery.of(context).size.width` as fallback if `constraints.maxWidth` is unreliable.

---

### Issue: Accent color not applied

**Symptom**: All roles show the same color (indigo)

**Solution**: Verify `accentColor` prop is correctly passed in each route's `GoRoute` builder. Check for hardcoded color in child widgets.

---

### Issue: Broken imports after deleting legacy files

**Symptom**: Compile errors referencing deleted screens

**Solution**: Use IDE "Find Usages" on each legacy screen before deletion. Update all references to point to `SharedChatScreen`.

---

## Testing Checklist

### Unit Tests

- [ ] `SharedChatScreen` renders correctly with default props
- [ ] Layout switches at exactly 600px breakpoint
- [ ] Props override defaults correctly

### Widget Tests

- [ ] Mobile layout shows conversation list initially
- [ ] Selecting a conversation navigates to message detail
- [ ] Back button returns to conversation list
- [ ] Tablet/desktop layout shows both panels simultaneously

### Integration Tests

- [ ] All 5 roles can access chat from their dashboard
- [ ] Messages sent from one role appear in another role's chat
- [ ] WebSocket connection status updates correctly
- [ ] Offline mode displays cached conversations

---

## Performance Targets

- **Layout transition**: < 16ms (60 FPS)
- **Initial load**: < 2 seconds (from dashboard tap to conversations visible)
- **Memory impact**: No increase compared to legacy implementations

---

## Next Steps

After completing this quickstart:

1. Run `/speckit.tasks` to generate the detailed task breakdown
2. Implement the `SharedChatScreen` following the quickstart template
3. Perform smoke tests on all 5 roles
4. Remove legacy files after validation
5. Deploy to staging for broader QA testing

---

## Support

For issues or questions during implementation:
- Refer to `specs/011-chat-role-integration/research.md` for design decisions
- Check `specs/011-chat-role-integration/data-model.md` for prop specifications
- Review website frontend docs: `CHAT_FEATURE_DOCUMENTATION_FRONTEND_WEBSITE.md`
