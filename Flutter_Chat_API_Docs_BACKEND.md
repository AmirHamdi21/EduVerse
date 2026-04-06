# EduVerse API - Chat & Discussions Documentation for Flutter

This document provides a comprehensive, technically detailed guide for integrating the Chat and Discussions features into the EduVerse Flutter application. It covers all roles (`student`, `instructor`, `teaching_assistant`, `admin`, `it_admin`), providing endpoint details, expected request shapes, response formats, WebSocket specifications, and Flutter implementation tips.

---

## 1. General Info & Headers

**Base URL Configuration**
- **Local Dev (Android Emulator)**: `http://10.0.2.2:8081` 
- **Local Dev (iOS Simulator / Web)**: `http://localhost:8081`
- **Production**: `<PRODUCTION_URL>`

**Headers**
For all protected endpoints, the JWT `accessToken` must be passed in the `Authorization` header:
```text
Authorization: Bearer <your_access_token>
```

---

## 2. Real-Time Messaging (Direct & Groups)

The Messaging module (`/api/messages` and `/messaging` WebSocket) provides real-time chat capabilities. It is accessible to **all roles**.

### 2.1 WebSocket Connection

**Namespace:** `/messaging`
**Access:** All Roles (Requires Token)
**Type:** Socket.IO connection

**Connection URI:**
```text
ws://localhost:8081/messaging?token=<your_access_token>
```

**Events Emitted by Client (Flutter -> Backend):**
- `join_conversation`: Join a room. Payload: `{ "conversationId": 1 }`
- `leave_conversation`: Leave a room. Payload: `{ "conversationId": 1 }`
- `send_message`: Send a real-time message.
  Payload (`WsSendMessageDto`):
  ```json
  {
    "conversationId": 1,
    "text": "Hello!",
    "fileId": null, // Optional file attachment ID
    "replyToId": null // Optional message ID to reply to
  }
  ```
- `typing`: Indicate typing status. Payload: `{ "conversationId": 1, "isTyping": true }`
- `mark_read`: Mark conversation as read. Payload: `{ "conversationId": 1 }`
- `delete_message`: Socket-based deletion. Payload: `{ "messageId": 5, "forEveryone": true }`
- `edit_message`: Socket-based editing. Payload: `{ "messageId": 5, "text": "Edited hello!" }`

**Events Listened by Client (Backend -> Flutter):**
- `new_message`: Incoming message in active room.
- `new_message_notification`: Incoming message for unjoined room (global notification).
- `user_typing`: Someone is typing. Payload: `{ "conversationId": 1, "userId": 42, "isTyping": true }`
- `message_read`: Receipt that messages were read.
- `message_deleted`: A message was deleted for everyone.
- `message_edited`: A message text was updated.
- `user_status`: User came online/offline. Payload: `{ "userId": 42, "isOnline": true, "lastSeen": "..." }`

---

### 2.2 Messaging REST Endpoints

#### 2.2.1 Search Users (Start New Chat)
**Endpoint:** `GET /api/messages/users/search`
**Access:** All Roles
**Description:** Search for users by name or email to start a conversation.
**Query params:** `query` (string), `limit` (int, default 20).
**Success Response:** (Array of Users)
```json
[
  { "userId": 2, "firstName": "John", "lastName": "Doe", "email": "johndoe@example.com" }
]
```

#### 2.2.2 List Conversations
**Endpoint:** `GET /api/messages/conversations`
**Access:** All Roles
**Description:** Lists all active conversations for the current user. Result sorted by `lastMessageAt`.
**Success Response:**
```json
[
  {
    "conversationId": 15,
    "type": "direct", // 'direct' or 'group'
    "name": null, // For groups, this is the group name
    "participants": [42, 10], // Array of User IDs
    "participantUsers": [ { "userId": 42, "fullName": "Student One" } ],
    "directDisplayUser": { "userId": 10, "fullName": "Instructor John" }, // Who you are talking to in direct chat
    "lastMessage": "Sure, no problem!",
    "lastMessageInfo": { "id": 102, "senderId": 10, "isDeleted": false, "sentAt": "2026-08-15T..." },
    "unreadCount": 2
  }
]
```

#### 2.2.3 Start New Conversation
**Endpoint:** `POST /api/messages/conversations`
**Access:** All Roles
**Body:** `StartConversationDto`
```json
{
  "participantIds": [10],
  "type": "direct", // or 'group'
  "groupName": "Optional Group Name",
  "text": "Hi Instructor! I have a question.",
  "fileId": null 
}
```
*Note: If a direct conversation already exists, the backend automatically routes the message to the existing thread.*

#### 2.2.4 Get Conversation Messages
**Endpoint:** `GET /api/messages/conversations/:id`
**Access:** All Roles (Must be participant)
**Query params:** `page` (int), `limit` (int).
**Response:** Paginated list of messages. Deleted messages return text `"This message was deleted"` and `isDeleted: true`.

#### 2.2.5 Send Message (REST fallback)
**Endpoint:** `POST /api/messages/conversations/:id`
**Access:** All Roles (Must be participant)
**Body:** `SendMessageDto` (`text`, `fileId`, `replyToId`).

#### 2.2.6 Edit / Mark Read / Delete
- **Edit Message:** `PATCH /api/messages/:id` (Body: `{ "text": "new text" }`). Only sender can edit.
- **Mark as Read:** `PATCH /api/messages/:id/read`
- **Delete for Me:** `DELETE /api/messages/:id`
- **Delete for Everyone:** `DELETE /api/messages/:id/everyone` (Only sender can invoke).

---

## 3. Course Discussions (Forums)

The Discussions module (`/api/discussions`) provides thread-based, Q&A style forums bound to specific courses.

### 3.1 Role-Based Access Rules
- **Student**: Allowed to read/create/reply ONLY if they have an `enrolled` status in `course_enrollments` for a section belonging to the course. Can only update/delete their own threads.
- **Instructor / TA**: Full access to courses they teach. They can Pin, Lock, Endorse, and Delete threads/replies.
- **Admin / IT Admin**: Global access to all discussions. Full moderation powers.

### 3.2 Discussion Endpoints

#### 3.2.1 List Discussion Threads
**Endpoint:** `GET /api/discussions`
**Access:** Students (if enrolled), Staff/Admins (course specific or global).
**Query params:** `courseId` (int, required for students), `page` (int), `limit` (int).
**Response:** Paginated threads. Pinned threads ALWAYS appear first.
```json
{
  "data": [
    {
      "id": 1,
      "courseId": 5,
      "createdBy": 42,
      "title": "Help with Binary Search Trees",
      "description": "I don't understand the insertion...",
      "isPinned": false,
      "isLocked": false,
      "viewCount": 15,
      "replyCount": 3,
      "createdAt": "..."
    }
  ]
}
```

#### 3.2.2 Create Thread
**Endpoint:** `POST /api/discussions`
**Access:** Students (enrolled), Instructors, TAs, Admins.
**Body:**
```json
{
  "courseId": 5,
  "title": "Midterm Review Session Topics",
  "description": "What should we cover?"
}
```

#### 3.2.3 Get Thread & Replies
**Endpoint:** `GET /api/discussions/:id`
**Description:** Fetch a thread and its paginated replies. Calling this increments the view count. Replies marked as `isAnswer` appear first.
**Response Shape:**
```json
{
  "thread": { /* Thread object */ },
  "replies": {
    "data": [
      {
        "id": 100,
        "userId": 10,
        "messageText": "Start with the invariant property...",
        "isAnswer": true, // Instructor marked this as correct answer
        "isEndorsed": true, // Instructor endorsed
        "endorsedBy": 10
      }
    ],
    "meta": { /* Pagination */ }
  }
}
```

#### 3.2.4 Post Reply
**Endpoint:** `POST /api/discussions/:id/reply`
**Body:** `{ "messageText": "Here is my answer...", "parentMessageId": null }`
*Fails (400) if thread `isLocked`.*

#### 3.2.5 Moderation Endpoints (Instructors, TAs, Admins)
These return HTTP 200/204 on success.
- **Update Thread:** `PUT /api/discussions/:id` (Update title/desc. Authors can do this too).
- **Delete Thread:** `DELETE /api/discussions/:id` (Instructors/Admins only).
- **Toggle Pin:** `PATCH /api/discussions/:id/pin` (Pins to top of list).
- **Toggle Lock:** `PATCH /api/discussions/:id/lock` (Prevents new replies).
- **Mark as Answer:** `PATCH /api/discussions/replies/:replyId/mark-answer` (Moves reply to top).
- **Endorse Reply:** `PATCH /api/discussions/replies/:replyId/endorse` (Marks as staff-approved).

---

## 4. Role-Specific Action Matrix

This matrix clarifies what UI elements you should render in Flutter based on the user's role.

### A. Student Profile
- **Messaging Profile**: Can chat directly with any searchable user (other students, TAs, instructors).
- **Discussions Profile**:
  - Can only view/create threads for **enrolled courses**.
  - **Cannot** see "Pin", "Lock", "Endorse", or "Mark Answer" buttons.
  - Can delete/edit **only their own** messages.

### B. Instructor & TA Profile
- **Messaging Profile**: Standard Real-Time chat capabilities.
- **Discussions Profile**:
  - Should have moderation UI buttons visible on threads (`Pin`, `Lock`, `Delete Topic`).
  - Should have moderation UI buttons on replies (`Endorse`, `Mark as Answer`).
  - TAs have identical discussion moderation privileges inside their assigned sections.
  
### C. Admin & IT_Admin Profile
- Has omnipotent access. Can view/moderate any discussion thread across the entire application without needing enrollment.

---

## 5. Flutter & Dart Implementation Tips

### 1. WebSocket Integration (`socket_io_client`)
For Flutter, use the `socket_io_client` package to connect to NestJS WebSockets. Keep this singleton in a Bloc/Repository.

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  IO.Socket? socket;

  void connect(String token) {
    socket = IO.io('http://10.0.2.2:8081/messaging', IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Web
        .disableAutoConnect()
        .setQuery({'token': token})
        .build());

    socket!.connect();

    // Listeners
    socket!.onConnect((_) => print('Connected to Chat WS'));
    
    socket!.on('new_message', (data) {
      // Map data to MessageModel and dispatch to Bloc
    });
    
    socket!.on('new_message_notification', (data) {
      // Show local notification snackbar
    });
  }

  void sendMessage(int convId, String text) {
    socket!.emit('send_message', {
      'conversationId': convId,
      'text': text,
    });
  }
}
```

### 2. Freezed Models Setup

```dart
@freezed
class ConversationSummary with _$ConversationSummary {
  const factory ConversationSummary({
    required int conversationId,
    required String type,
    String? name,
    @Default([]) List<int> participants,
    UserSummary? directDisplayUser,
    String? lastMessage,
    required DateTime lastMessageAt,
    @Default(0) int unreadCount,
  }) = _ConversationSummary;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) => _$ConversationSummaryFromJson(json);
}

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required int id,
    required int senderId,
    String? text,
    @Default(false) bool isDeleted,
    String? deletedText,
    int? replyToId,
    required DateTime sentAt,
    DateTime? editedAt,
    required String status,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);
}
```

### 3. Moderation Features Visibility

In your Flutter UI for discussions, rely on the user's roles from your `AuthBloc` to conditionally show UI actions.
```dart
bool isModerator = currentUser.roles.any((r) => 
  ['instructor', 'teaching_assistant', 'admin', 'it_admin'].contains(r.roleName)
);

// In your Discussion Thread UI:
if (isModerator) ...[
  IconButton(
    icon: Icon(thread.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
    onPressed: () => context.read<DiscussionBloc>().add(TogglePinEvent(thread.id)),
  ),
  IconButton(
    icon: Icon(thread.isLocked ? Icons.lock : Icons.lock_open),
    onPressed: () => context.read<DiscussionBloc>().add(ToggleLockEvent(thread.id)),
  ),
]
```
