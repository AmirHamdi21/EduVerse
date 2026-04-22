# Quickstart: Chat Cleanup, Caching & Polish

**Feature**: 014-chat-cleanup-polish | **Date**: 2026-04-09

---

## Prerequisites

- Flutter SDK installed and configured
- Project dependencies installed (`flutter pub get`)
- Backend server running for WebSocket and REST API testing

---

## Development Workflow

### 1. Run the app in debug mode
```bash
flutter run -d chrome   # or your preferred device
```

### 2. Navigate to Chat
- Login with any role (Student, Instructor, TA, Admin, IT Admin)
- Navigate to Chat from the sidebar/bottom nav
- The chat module is at `lib/screens/shared/shared_chat_screen.dart`

### 3. Testing Cache Behavior
1. **Normal flow**: Open chat → select conversation → close app → reopen → cached data should appear instantly
2. **Offline**: Enable airplane mode → open chat → cached conversations should display → "Offline" badge visible
3. **Logout**: Logout → login as different user → no stale data from previous user

### 4. Testing Connection Status
1. **Live**: Connect normally → green "Live" badge in header
2. **Offline**: Disconnect WiFi → red "Offline" badge
3. **Reconnecting**: Restore WiFi → amber "Connecting..." badge → transitions to green "Live"

### 5. Testing New Messages Indicator
1. Open a conversation → scroll up to view history
2. Have another user send messages to the same conversation
3. A "↓ New messages" floating indicator should appear
4. Tap indicator → auto-scrolls to bottom

---

## Key Files

| File | Purpose |
|---|---|
| `lib/services/storage_service.dart` | Chat cache read/write/clear methods |
| `lib/bloc/chat/chat_bloc.dart` | Stale-while-revalidate orchestration |
| `lib/bloc/chat/chat_event.dart` | `ClearChatCache` event for logout |
| `lib/bloc/auth/auth_bloc.dart` | Triggers cache clear on logout |
| `lib/widgets/shared/chat/shared_chat_header.dart` | Connection status badge |
| `lib/widgets/shared/chat/shared_chat_detail_view.dart` | New messages indicator |
| `lib/widgets/shared/chat/shared_conversation_list.dart` | Offline/error empty states |
| `lib/widgets/shared/chat/shared_chat_empty_state.dart` | Enhanced empty state variants |

---

## Verification Checklist

- [ ] `flutter analyze` passes with no errors
- [ ] App launches and chat loads with real API data
- [ ] Cached conversations persist across app restart
- [ ] Cache clears on logout (verify SharedPreferences keys)
- [ ] Stale cached data older than 24h still appears offline and refreshes when connectivity returns
- [ ] Connection status badge reflects actual WebSocket state
- [ ] New messages indicator appears when scrolled up
- [ ] Large paste operations still auto-stop typing indicator after 1.5 seconds of inactivity
- [ ] Clearing search query restores the full conversation list immediately
- [ ] Real-time events for deleted/non-member conversations are ignored safely (no ghost threads)
- [ ] Refresh-token failure redirects to login with "Session expired — please sign in again"
- [ ] No `_generateSample` / `_simulateReply` / mock data in chat files
- [ ] Discussion parity checks pass for all 5 roles (entry points, moderation visibility, and empty/error states)
- [ ] No hardcoded/mock discussion data exists in discussion BLoC, services, screens, or shared discussion widgets
