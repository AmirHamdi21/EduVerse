# Chat / Messages Feature Audit Report

Date: 2026-04-26

Scope:
- Flutter app: `C:\Users\Friends\Desktop\Graduation\EduVerse`
- Website frontend: `C:\Users\Friends\Desktop\Graduation\Frontend\Eduverse-Frontend`
- Backend: `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`

Roles covered:
- Student
- Instructor
- TA
- Admin

Supplementary note:
- The Flutter app and website also expose chat to IT Admin. I included IT Admin where it helps explain the architecture, but the main comparison below stays focused on student, instructor, TA, and admin.

## 1. Executive Summary

The website and the Flutter app are not merely different UIs over the same chat flow. They currently consume the backend messaging module in different ways, and the Flutter app has several contract mismatches that explain the realtime issue you described and several other parity gaps.

Most important conclusion:
- The website opens its chat socket when the chat component mounts with the current token and therefore receives live events normally (`src/components/shared/MessagingChat.tsx:610`).
- The Flutter app creates `ChatBloc` once at app startup (`lib/main.dart:194`) and attempts socket connection once inside the bloc constructor (`lib/bloc/chat/chat_bloc.dart:115-129`).
- Login stores tokens later (`lib/services/storage_service.dart:18`, `lib/bloc/auth/auth_bloc.dart:291`, `lib/bloc/auth/auth_bloc.dart:456`), but there is no code that reconnects the chat socket after login.
- That means the Flutter app can successfully use HTTP chat APIs after login, but still miss websocket events for incoming messages. This is the strongest code-level explanation for the reported bug where messages appear only after leaving the conversation, refreshing the list, and re-opening it.

High-level verdict:
- Backend messaging module: feature-rich but internally inconsistent in several places.
- Website chat: best current reference for live message flow, but still only partially uses backend capabilities.
- Flutter chat: ambitious shared architecture, but currently only partially matches website behavior and contains several incorrect backend integrations.

## 2. Architecture Snapshot

### 2.1 Backend

Main messaging module:
- Controller: `src/modules/messaging/controllers/messaging.controller.ts`
- Gateway: `src/modules/messaging/gateways/messaging.gateway.ts`
- Service: `src/modules/messaging/services/messaging.service.ts`

Backend exposes:
- User search: `messaging.controller.ts:43`
- Conversation list: `messaging.controller.ts:53`
- Start conversation: `messaging.controller.ts:64`
- Conversation messages: `messaging.controller.ts:77`
- Send message: `messaging.controller.ts:93`
- Edit message: `messaging.controller.ts:111`
- Mark one message read: `messaging.controller.ts:129`
- Delete for me: `messaging.controller.ts:141`
- Delete for everyone: `messaging.controller.ts:153`
- Unread count: `messaging.controller.ts:166`
- Global message search: `messaging.controller.ts:177`
- Online users HTTP endpoint: `messaging.controller.ts:188`

Realtime gateway events:
- `join_conversation`: `messaging.gateway.ts:96`
- `leave_conversation`: `messaging.gateway.ts:107`
- `send_message`: `messaging.gateway.ts:120`
- `typing`: `messaging.gateway.ts:161`
- `mark_read`: `messaging.gateway.ts:178`
- `delete_message`: `messaging.gateway.ts:208`
- `edit_message`: `messaging.gateway.ts:237`

### 2.2 Website frontend

Main messaging implementation:
- API service: `src/services/api/chatService.ts`
- Socket client: `src/services/chat/chatSocket.ts`
- Shared UI: `src/components/shared/MessagingChat.tsx`

Role entry points all mount the same component:
- Student: `src/pages/student-dashboard/StudentDashboard.tsx:465-472`
- Instructor: `src/pages/instructor-dashboard/InstructorDashboard.tsx:1584-1591`
- TA: `src/pages/ta-dashboard/TADashboard.tsx:1347-1353`
- Admin: `src/pages/admin-dashboard/AdminDashboard.tsx:959-967`
- IT Admin: `src/pages/it-admin-dashboard/ITAdminDashboard.tsx:519-526`

### 2.3 Flutter app

Main messaging implementation:
- Global bloc: `lib/bloc/chat/chat_bloc.dart`
- API service: `lib/services/api/chat_service.dart`
- Socket service: `lib/services/chat/chat_socket_service.dart`
- Shared screen: `lib/screens/shared/shared_chat_screen.dart`
- Shared conversation list: `lib/widgets/shared/chat/shared_conversation_list.dart`
- Shared detail view: `lib/widgets/shared/chat/shared_chat_detail_view.dart`
- New conversation flow: `lib/screens/shared/chat/new_conversation_screen.dart`
- Profile flow: `lib/screens/shared/chat/user_profile_screen.dart`

Role routes all point to the shared screen:
- Student: `lib/config/app_router.dart:477-480`
- Instructor: `lib/config/app_router.dart:943-946`
- TA: `lib/config/app_router.dart:1238-1241`
- Admin: `lib/config/app_router.dart:1352-1355`
- IT Admin: `lib/config/app_router.dart:1537-1540`

Important architectural note:
- The old role-specific Flutter chat screen files exist but are empty placeholders with no implementation:
  - `lib/screens/student/chat/chat_screen.dart`
  - `lib/screens/instructor/chat/instructor_chat_screen.dart`
  - `lib/screens/ta/messages/ta_messages_screen.dart`
  - `lib/screens/admin/messages/admin_messages_screen.dart`
  - `lib/screens/it_admin/chat/it_admin_chat_screen.dart`

## 3. Role Coverage Comparison

| Role | Backend behavior | Website behavior | Flutter behavior | Notes |
|---|---|---|---|---|
| Student | Same messaging module as all roles | Uses shared `MessagingChat` | Uses shared `SharedChatScreen` | Good structural parity |
| Instructor | Same messaging module as all roles | Uses shared `MessagingChat` | Uses shared `SharedChatScreen` | Good structural parity |
| TA | Same messaging module as all roles | Uses shared `MessagingChat`; live mode hides call buttons | Uses shared `SharedChatScreen`; call placeholders always visible by default | Minor UI divergence |
| Admin | Same messaging module as all roles | Uses shared `MessagingChat` | Uses shared `SharedChatScreen` | Good structural parity |

Important backend observation:
- I found no role-specific branching inside the backend messaging service. All authenticated roles use the same conversation, message, read, delete, search, and socket code paths.
- Therefore, most chat differences are frontend-side differences, not backend role-policy differences.

## 4. Feature Matrix

Legend:
- `Implemented`: usable and reasonably aligned
- `Partial`: exists but incomplete or inconsistent
- `Missing`: absent in that client
- `Wrong`: implemented in a way that conflicts with the backend contract or reference behavior

| Feature | Backend | Website | Flutter | Assessment |
|---|---|---|---|---|
| Conversation list | Implemented | Implemented | Implemented | Flutter adds local pin/mute/hide not present on website/backend |
| Open conversation | Implemented | Implemented | Implemented | Both clients load history over HTTP |
| Live incoming message in active chat | Implemented | Implemented | Partial / wrong | Flutter socket lifecycle is faulty |
| Live incoming message preview in list | Implemented | Implemented | Implemented | Flutter uses `new_message_notification` more aggressively than web |
| Typing indicator | Implemented | Implemented | Implemented | Web label is generic `User {id}`; Flutter resolves participant names better |
| Mark conversation read | Partial | Partial | Partial / wrong | Backend only has websocket conversation-level mark-read; HTTP only marks one message |
| Read receipts in message UI | Partial | Missing | Wrong | Backend payloads and clients do not align |
| Reply to message | Implemented | Partial | Implemented | Website reply only works when socket is live |
| Delete for me | Implemented | Partial | Partial | Both frontends currently treat it as local-only behavior |
| Delete for everyone | Implemented | Implemented | Wrong | Flutter removes the message instead of showing deleted placeholder |
| Edit message | Implemented | Missing | Partial | Flutter has service/socket/bloc plumbing, but no UI action |
| Direct new conversation | Implemented | Implemented | Partial / wrong | Flutter allows missing initial message although backend requires it |
| Group conversation | Implemented | Missing | Implemented | Flutter exceeds website here |
| User search for new conversation | Implemented | Implemented | Implemented | Flutter flow is richer |
| Attachment sending | Partial | Partial | Missing / placeholder | Backend supports `fileId`, but no end-to-end upload/send path exists |
| Voice message | Missing | Placeholder only | Placeholder only | No backend flow |
| Voice/video call buttons | Placeholder only | Placeholder only | Placeholder only | Pure UI placeholders |
| Global message search | Implemented | Missing | Missing | Backend-only feature |
| Unread count endpoint | Implemented | Missing | Missing | Backend-only feature |
| Online users snapshot | Implemented over HTTP only | Missing | Wrong expectation | Flutter expects nonexistent websocket event |

## 5. Critical Findings

### 5.1 Flutter realtime failure root cause: socket connection is not tied to login lifecycle

Evidence:
- `ChatBloc` is created once during app bootstrap: `lib/main.dart:194`
- It immediately attempts `_connectSocket()`: `lib/bloc/chat/chat_bloc.dart:115-129`
- Token storage happens later on login: `lib/services/storage_service.dart:18`, `lib/bloc/auth/auth_bloc.dart:291`, `lib/bloc/auth/auth_bloc.dart:456`
- I found no code path that reconnects `ChatBloc` or `ChatSocketService` after successful login

Impact:
- If the app starts before the user is authenticated, chat socket connection can fail once and remain disconnected.
- REST chat calls still work after login, so conversation list refresh and manual re-opening work.
- Live events do not reliably arrive, which matches the exact user-reported bug.

Why the website does not have the same problem:
- The website connects inside the mounted chat component with the current token from storage: `src/components/shared/MessagingChat.tsx:610`
- So the website socket lifecycle is naturally aligned with the authenticated session.

Severity:
- Critical

### 5.2 Flutter does not guarantee room rejoin after reconnect

Evidence:
- Flutter joins the active room during conversation selection: `lib/bloc/chat/chat_bloc.dart:323`
- There is no code that re-joins the currently active conversation after a reconnect event
- Connection recovery only updates status and requests online users: `lib/bloc/chat/chat_bloc.dart:884-893`

Impact:
- Even if the socket reconnects later, the active chat room may not be rejoined automatically.
- That can cause missed `new_message` room events while the user is actively viewing the conversation.

Severity:
- Critical

### 5.3 Flutter expects websocket events for online users that the backend never emits

Evidence:
- Flutter emits `get_online_users`: `lib/services/chat/chat_socket_service.dart:298`
- Flutter listens for `online_users_list`: `lib/services/chat/chat_socket_service.dart:434`, `lib/bloc/chat/chat_bloc.dart:1028`
- Backend gateway does not implement `get_online_users` and never emits `online_users_list`
- Backend only exposes online users through HTTP `GET /api/messages/online-users`: `messaging.controller.ts:188`

Impact:
- Flutter online user state is incomplete and depends only on later `user_status` broadcasts.
- Users who were already online before the current client connected will not be represented correctly.

Severity:
- High

### 5.4 Backend conversation pagination is ordered incorrectly for chat UIs

Evidence:
- Backend loads messages with `orderBy('m.sent_at', 'ASC')` and paginates with `skip/take`: `messaging.service.ts:237-248`
- Website requests page 1 only: `src/services/api/chatService.ts:153`, used in `MessagingChat.tsx:759`
- Flutter also requests page 1 initially: `lib/bloc/chat/chat_bloc.dart:364-367`

Impact:
- For conversations with more than 50 messages, page 1 returns the oldest messages, not the latest.
- Both website and Flutter will open older history first instead of the most recent messages.
- Infinite scroll logic becomes semantically inverted.

Severity:
- High

### 5.5 Flutter delete-for-everyone behavior is wrong compared to backend and website

Evidence:
- Backend delete-for-everyone is a soft delete marker: `messaging.service.ts:364-374`
- Website replaces message content with “This message was deleted”: `src/components/shared/MessagingChat.tsx:675-693`, `931-953`
- Flutter detail UI dispatches delete-for-everyone correctly: `lib/widgets/shared/chat/shared_chat_detail_view.dart:349-354`
- But `ChatBloc` removes the message from the list entirely after deletion: `lib/bloc/chat/chat_bloc.dart:755-784`

Impact:
- Flutter loses the deleted-message placeholder behavior.
- The conversation timeline no longer matches backend semantics or website behavior.
- Reply references and chronological continuity become inconsistent.

Severity:
- High

## 6. Major Backend Contract Problems

### 6.1 Read-receipt contract is inconsistent across backend, website, and Flutter

Evidence:
- Backend websocket `mark_read` emits conversation-level data with `conversationId`, `userId`, `readAt`, `markedRead`: `messaging.gateway.ts:178-204`
- Flutter expects `MessageReadEvent` with `messageId`, `conversationId`, `userId`: `lib/bloc/chat/chat_models.dart:458-485`
- Flutter handles `message_read` as if a single message ID exists: `lib/bloc/chat/chat_bloc.dart:1062-1085`
- Website does not subscribe to `message_read` at all; it only subscribes to new/deleted/typing events: `src/components/shared/MessagingChat.tsx:723-742`
- Backend `getConversationMessages()` returns `status` via `getMessageStatus(m)`, but that method relies on `message.readStatus`: `messaging.service.ts:251-261`, `531-534`
- I found no code that updates `message.readStatus` when participants read messages

Impact:
- Read receipts are effectively broken end-to-end.
- Message status shown from backend history cannot become accurate.
- Flutter’s `message_read` event handling cannot work with the current gateway payload.

Severity:
- High

### 6.2 Backend only supports conversation-level mark-read over websocket, not over HTTP

Evidence:
- HTTP controller only exposes `PATCH /api/messages/:id/read` for one message: `messaging.controller.ts:129`
- Conversation-level mark-read exists only in websocket handler `mark_read`: `messaging.gateway.ts:178`
- Flutter falls back to `markRead(markerId)` over HTTP for only one message: `lib/bloc/chat/chat_bloc.dart:824-842`
- Website never calls the HTTP mark-read endpoint from the chat UI

Impact:
- If websocket is unavailable, there is no proper HTTP fallback to mark an entire conversation read.
- This weakens resilience on mobile and explains inconsistent unread states.

Severity:
- High

### 6.3 Websocket room join lacks participant authorization

Evidence:
- `join_conversation` simply joins `conversation_${id}`: `messaging.gateway.ts:96-105`
- I found no participant verification in that handler
- Participant verification exists in service methods like `getConversationMessages()` and `sendMessage()`: `messaging.service.ts:225`, `272`, `512-518`

Impact:
- Any authenticated user who can guess a conversation ID can join its websocket room.
- That is a serious privacy flaw for chat content.

Severity:
- High

### 6.4 Backend delete broadcast is scoped too broadly

Evidence:
- On delete-for-everyone, backend emits `message_deleted` with `this.server.emit(...)`: `messaging.gateway.ts:220`
- That broadcasts globally, not just to the conversation room or participants

Impact:
- Unrelated connected users receive delete events for conversations they are not part of.
- Even if the clients ignore unknown message IDs, the event leakage is still incorrect.

Severity:
- Medium

## 7. Website vs Flutter Parity Gaps

### 7.1 Flutter new-conversation flow conflicts with backend requirement for first message

Evidence:
- Backend `StartConversationDto.text` is required: `src/modules/messaging/dto/index.ts:23`
- Website enforces first message: `src/components/shared/MessagingChat.tsx:960`
- Flutter labels the field as optional: `lib/screens/shared/chat/new_conversation_screen.dart:258`
- Flutter sends `initialMessage: null` when input is empty: `lib/screens/shared/chat/new_conversation_screen.dart:44`, `75`

Impact:
- Flutter can present a valid-looking UI path that the backend rejects.
- Direct and group conversation creation will fail when the user leaves the initial message empty.

Severity:
- High

### 7.2 Website has working direct-chat creation flow; Flutter has richer UI but weaker contract alignment

Website behavior:
- Search by email/name, require first message, create conversation, refresh list, select conversation: `MessagingChat.tsx:955-1040`

Flutter behavior:
- Full-screen contact search
- Frequently contacted list
- Direct and group conversation modes
- Profile drill-down

Assessment:
- Flutter is richer than the website in UX scope.
- But the website flow is currently more aligned with backend direct-message constraints.

Severity:
- Medium

### 7.3 Website reply flow is only partially implemented; Flutter reply flow is better

Evidence:
- Backend supports `replyToId` for HTTP and websocket: `dto/index.ts:45`, `91-93`
- Website websocket send supports `replyToId`: `src/services/chat/chatSocket.ts:101`
- Website REST send does not accept `replyToId`: `src/services/api/chatService.ts:160`
- Website explicitly blocks reply fallback when socket is offline: `src/components/shared/MessagingChat.tsx:859`
- Flutter supports reply context in UI and service/socket paths: `lib/widgets/shared/chat/shared_chat_detail_view.dart:336-445`, `lib/services/api/chat_service.dart:68-95`, `lib/services/chat/chat_socket_service.dart:313-326`

Impact:
- Website reply is only reliable while live socket is connected.
- Flutter reply implementation is closer to backend capability.

Severity:
- Medium

### 7.4 Website direct-conversation creation has a duplicate-send bug when the conversation already exists

Evidence:
- Backend `startConversation()` already sends the message into an existing direct conversation and returns `existing: true`: `messaging.service.ts:155-167`
- Website calls `ChatService.sendMessage(conversationId, firstMessage)` again when `startResponse.existing` is true: `src/components/shared/MessagingChat.tsx:1000-1001`

Impact:
- Starting a message to an already-existing direct conversation can duplicate the first message on the website.

Severity:
- Medium

### 7.5 Flutter currently shows some non-parity local behaviors not present on the website

Examples:
- Local pin conversation: `lib/widgets/shared/chat/shared_conversation_list.dart`
- Local mute conversation: `lib/widgets/shared/chat/shared_conversation_list.dart`
- Local hide/delete conversation: `lib/widgets/shared/chat/shared_conversation_list.dart`

Assessment:
- These are not backend-backed features.
- They are extra mobile-only behaviors and can diverge from website expectations.
- The “delete conversation” behavior is only local hiding, not true backend deletion.

Severity:
- Low

## 8. Backend Features Missing or Only Partially Used by Both Frontends

### 8.1 Edit message

Backend:
- Fully exposed over REST and websocket: `messaging.controller.ts:111`, `messaging.gateway.ts:237`, `messaging.service.ts:463`

Website:
- Socket client exposes `emitEditMessage`: `src/services/chat/chatSocket.ts:122`
- No UI or component behavior uses it

Flutter:
- API service supports `editMessage`: `lib/services/api/chat_service.dart:196`
- Socket service supports `editMessage`: `lib/services/chat/chat_socket_service.dart:338`
- Bloc handles `message_edited`: `lib/bloc/chat/chat_bloc.dart:970-1027`
- No edit action in the message bubble UI

Assessment:
- Backend implemented
- Website missing
- Flutter partial plumbing only

### 8.2 Global message search

Backend:
- `GET /api/messages/search`: `messaging.controller.ts:177`

Website:
- No usage found

Flutter:
- No usage found

Assessment:
- Completely missing in both frontends

### 8.3 Unread total count for messages

Backend:
- `GET /api/messages/unread-count`: `messaging.controller.ts:166`

Website:
- No usage found in chat module

Flutter:
- No chat API method for it

Assessment:
- Completely missing in both frontends

### 8.4 Attachment sending with backend `fileId`

Backend:
- Start/send DTOs support `fileId`: `dto/index.ts:28`, `40`, `92`

Website:
- Attachment UI exists: `MessagingChat.tsx:1516`
- File upload only creates a local optimistic bubble: `MessagingChat.tsx:884-910`
- No upload-to-file-service and no `fileId` send path

Flutter:
- Attachment button is only placeholder “Coming soon”: `lib/widgets/shared/chat/shared_chat_detail_view.dart:954`

Assessment:
- End-to-end attachment messaging is missing in both frontends

## 9. Flutter-Specific Incorrect or Partial Implementations

### 9.1 Delete-for-me is UI-local only, even though backend supports persistent delete-for-me

Evidence:
- Backend supports `DELETE /api/messages/:id`: `messaging.controller.ts:141`, `messaging.service.ts:353`
- Flutter UI wires delete-for-me to `HideMessageLocally`: `lib/widgets/shared/chat/shared_chat_detail_view.dart:344`
- `HideMessageLocally` only stores message IDs in bloc state: `lib/bloc/chat/chat_bloc.dart:1106-1113`

Impact:
- Deleted-for-me messages reappear after reload or app restart.
- Flutter behavior does not match backend capability.

Severity:
- High

### 9.2 Flutter delete event path double-submits to backend

Evidence:
- `DeleteMessage` first calls REST delete, then emits websocket delete: `lib/bloc/chat/chat_bloc.dart:755-784`
- Backend websocket delete handler performs delete again through the service: `messaging.gateway.ts:208-233`

Impact:
- Redundant backend work
- Harder-to-reason event ordering

Severity:
- Medium

### 9.3 Flutter “Live / Connecting / Offline” badge can be misleading

Evidence:
- Badge is driven by socket state in `SharedChatHeader`: `lib/widgets/shared/chat/shared_chat_header.dart`
- Socket is initialized globally at startup, not re-bound to auth login lifecycle

Impact:
- User can see chat HTTP content loading while socket state is disconnected or stale
- This adds confusion when live updates fail

Severity:
- Medium

## 10. Website-Specific Incorrect or Partial Implementations

### 10.1 Website does not consume backend edit, read-receipt, or online-status events

Evidence:
- Component subscribes only to `new_message`, `message_sent`, `new_message_notification`, `user_typing`, `message_deleted`, `delete_confirmed`: `src/components/shared/MessagingChat.tsx:723-742`
- No handlers for `message_read`, `message_edited`, or `user_status`

Impact:
- Website is the better reference for live incoming messages, but it is not a full reference for all backend messaging capabilities.

Severity:
- Medium

### 10.2 Website “delete for me” is also local-only

Evidence:
- `handleDeleteForMe` only updates local `deletedForMeMessageIds`: `src/components/shared/MessagingChat.tsx:922-929`
- It does not call backend delete-for-me

Impact:
- Refreshing the page restores the message.

Severity:
- Medium

## 11. What Is Already Good in the Flutter Implementation

These areas should be preserved during the fix work:
- One unified shared screen for all roles instead of duplicating logic: `lib/screens/shared/shared_chat_screen.dart`
- Stronger new-conversation UX than the website: contact search, group mode, profile flow, frequently contacted list
- Reply context UX is better than the website and closer to backend intent
- Shared model normalization is more robust than the website in several places

## 12. Recommended Planning Buckets for the Next Phase

This is not the implementation plan yet. It is the clean grouping I recommend using when you create that plan.

### Bucket A: Realtime correctness

Scope:
- Reconnect chat socket after login and disconnect/reset on logout
- Rejoin active conversation after reconnect
- Fix active-thread live updates
- Align online-user handling with actual backend contract

### Bucket B: Backend contract alignment

Scope:
- Fix message read contract
- Fix pagination order for recent-first conversation loading
- Fix delete-for-everyone semantics
- Add or align HTTP conversation-level mark-read behavior

### Bucket C: Website parity in Flutter

Scope:
- Ensure live send/receive matches website behavior
- Ensure direct new-chat flow behaves like website where applicable
- Preserve conversation list, unread updates, reply flow, delete placeholder behavior

### Bucket D: Backend-only features not yet surfaced

Scope:
- Edit message
- Global message search
- Unread total count
- Proper file attachment send flow

### Bucket E: Backend safety / correctness cleanup

Scope:
- Authorize websocket room joins
- Scope delete broadcasts correctly
- Review websocket event schemas for consistency

## 13. Bottom-Line Assessment

If the goal is “make Flutter chat behave like the website, then extend it to cover the real backend feature set,” the work should start with realtime lifecycle fixes in Flutter and contract cleanup in the backend.

The single most likely cause of the reported Flutter bug is:
- `ChatBloc` connects the socket too early and only once, before login is complete, then never reconnects after tokens are stored.

The most important secondary blockers are:
- Flutter does not rejoin rooms after reconnect.
- Flutter expects websocket online-user events that the backend does not provide.
- Backend read receipts are internally inconsistent.
- Backend pagination is wrong for chat history.
- Flutter delete-for-everyone behavior does not match backend or website behavior.

