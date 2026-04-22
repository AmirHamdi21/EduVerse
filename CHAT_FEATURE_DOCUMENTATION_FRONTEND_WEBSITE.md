# EduVerse Chat Feature — Comprehensive Frontend Documentation

> **Version:** 1.0  
> **Last Updated:** April 6, 2026  
> **Applies To:** Student, Instructor, Teaching Assistant (TA), Admin, IT Admin dashboards

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Shared Components](#2-shared-components)
   - [MessagingChat Component](#21-messagingchat-component)
   - [AIChatbot Component](#22-aichatbot-component-evy)
3. [Services Layer](#3-services-layer)
   - [ChatService (REST API)](#31-chatservice-rest-api)
   - [ChatSocketClient (WebSocket)](#32-chatsocketclient-websocket)
4. [Role: Student](#4-role-student)
5. [Role: Instructor](#5-role-instructor)
6. [Role: Teaching Assistant (TA)](#6-role-teaching-assistant-ta)
7. [Role: Admin](#7-role-admin)
8. [Role: IT Admin](#8-role-it-admin)
9. [API Endpoints Reference](#9-api-endpoints-reference)
10. [WebSocket Events Reference](#10-websocket-events-reference)
11. [Data Models & TypeScript Interfaces](#11-data-models--typescript-interfaces)

---

## 1. Architecture Overview

The EduVerse chat system is built on two pillars:

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **REST API** | `ChatService` → `ApiClient` (Axios) | CRUD for conversations + messages, user search, read receipts |
| **WebSocket** | `ChatSocketClient` → `socket.io-client` | Real-time message delivery, typing indicators, live deletions/edits |

All five roles share the **exact same** shared `<MessagingChat />` component and underlying services. Per-role customization is achieved through **props** passed at the dashboard level (accent colors, feature toggles, user identity).

### File Map

```
src/
├── services/
│   ├── api/
│   │   ├── config.ts                 # API_BASE_URL, TOKEN_KEYS
│   │   ├── client.ts                 # Axios ApiClient wrapper
│   │   └── chatService.ts            # ChatService class (REST)
│   └── chat/
│       └── chatSocket.ts             # ChatSocketClient class (WebSocket)
├── components/shared/
│   ├── MessagingChat.tsx             # Full messaging UI (conversations + messages)
│   ├── AIChatbot.tsx                 # Evy AI floating chatbot
│   └── index.ts                      # Barrel exports
└── pages/
    ├── student-dashboard/
    │   ├── StudentDashboard.tsx       # Chat tab integration
    │   └── components/AIFeatures/    # AI Chatbot content (static mockup)
    ├── instructor-dashboard/
    │   ├── InstructorDashboard.tsx    # Chat tab integration
    │   └── components/
    │       ├── CommunicationPage.tsx  # Embedded chat in Communication hub
    │       ├── AnnouncementsManager.tsx # Embedded chat sidebar
    │       └── AIToolsPage.tsx        # Floating AIChatbot (Evy)
    ├── ta-dashboard/
    │   ├── TADashboard.tsx            # Chat tab integration
    │   └── components/
    │       ├── AnnouncementsPage.tsx   # Course Chats + Direct Messages tabs
    │       └── AIAssistantPage.tsx     # TA-specific AI assistant (local, no API)
    ├── admin-dashboard/
    │   └── AdminDashboard.tsx         # Chat tab integration
    └── it-admin-dashboard/
        └── ITAdminDashboard.tsx       # Chat tab integration
```

---

## 2. Shared Components

### 2.1 MessagingChat Component

**File:** `src/components/shared/MessagingChat.tsx` (1,492 lines)

This is the **single, universal messaging component** used across all five roles. It is a fully self-contained chat application that handles:

- Conversation listing, search, and selection
- Real-time messaging via WebSocket
- Fallback REST API message sending
- New conversation creation (by email)
- Typing indicators
- Message replies
- Message deletion (for me / for everyone)
- File attachment UI
- Emoji picker
- Voice message toggle (UI only)
- Voice & video call buttons (UI only)
- Online/offline & connection status
- Dark mode / RTL support
- Optimistic message updates with deduplication

#### Props Interface

```typescript
interface MessagingChatProps {
  conversations?: Conversation[];       // Initial/fallback conversations
  messages?: Message[];                 // Initial/fallback messages
  currentUserId?: string;              // Logged-in user ID (auto-resolved from JWT if "current-user")
  currentUserName?: string;            // Display name for outgoing messages
  onSendMessage?: (conversationId: string, message: { text?: string; file?: File }) => void;
  onSelectConversation?: (conversationId: string) => void;
  onStartNewConversation?: () => void;
  showVideoCall?: boolean;             // Show video call button (default: true)
  showVoiceCall?: boolean;             // Show voice call button (default: true)
  showCalls?: boolean;                 // Master toggle for call buttons (default: true)
  showSearch?: boolean;                // Show search bar (default: true)
  showVoiceMessage?: boolean;          // Show mic button (default: true)
  showEmojiPicker?: boolean;           // Show emoji button (default: true)
  showNewConversation?: boolean;       // Show "+" new chat button (default: true)
  accentColor?: string;                // Primary color hex (default: "#4f46e5")
  className?: string;                  // Extra CSS classes
  height?: string;                     // Container height (default: "600px")
  isDark?: boolean;                    // Dark mode flag (default: false)
}
```

#### UI Layout

```
┌─────────────────────────────────────────────────────────┐
│  SIDEBAR (320px)              │  MESSAGE AREA (flex-1)  │
│                               │                         │
│  ┌─ Header ─────────────────┐ │  ┌─ Conversation Header─┐│
│  │ "Messages"  [Live] [+]   │ │  │ Avatar | Name         ││
│  └──────────────────────────┘ │  │ Typing / Online status││
│                               │  │         [📞] [📹]     ││
│  ┌─ New Chat Modal ─────────┐ │  └───────────────────────┘│
│  │ Email input              │ │                           │
│  │ First message input      │ │  ┌─ Messages List ───────┐│
│  │ [Start] [Cancel]         │ │  │ ┌ Reply badge ┐       ││
│  └──────────────────────────┘ │  │ │ Message bubble│      ││
│                               │  │ │ Timestamp     │      ││
│  ┌─ Search ─────────────────┐ │  │ │ [↩ Reply]     │      ││
│  │ 🔍 Search conversations  │ │  │ │ [🗑 Del Me]   │      ││
│  └──────────────────────────┘ │  │ │ [🗑 Del All]  │      ││
│                               │  │ └───────────────┘      ││
│  ┌─ Conversation List ──────┐ │  └───────────────────────┘│
│  │ Avatar | Name     Time   │ │                           │
│  │         Last msg  (3)    │ │  ┌─ Input Bar ───────────┐│
│  │ ─────────────────────    │ │  │ [Reply preview]       ││
│  │ Avatar | Name     Time   │ │  │ [Emoji row]           ││
│  │         Last msg         │ │  │ 📎 🎤 [text input] 😀 📤││
│  └──────────────────────────┘ │  └───────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

#### Key Buttons & Actions

| Button/Element | Icon | Action | Condition |
|----------------|------|--------|-----------|
| **New Conversation (+)** | `Plus` | Opens email-based new chat modal | `showNewConversation === true` |
| **Search** | `Search` | Filters conversations by name, email, or last message | `showSearch === true` |
| **Voice Call** | `Phone` | Placeholder (no implementation) | `showVoiceCall && showCalls` |
| **Video Call** | `Video` | Placeholder (no implementation) | `showVideoCall && showCalls` |
| **Attach File** | `Paperclip` | Opens file picker → creates file message | Always visible |
| **Voice Message** | `Mic` / `MicOff` | Toggles recording state (UI only) | `showVoiceMessage === true` |
| **Emoji Picker** | `Smile` | Shows inline emoji row | `showEmojiPicker === true` |
| **Send Message** | `Send` | Sends via WebSocket (or REST fallback) | Input not empty |
| **Reply** | `CornerUpLeft` | Sets pending reply context | Per-message action |
| **Delete for me** | `Trash2` (gray) | Hides message locally | Per-message action |
| **Delete for everyone** | `Trash2` (red) | Emits `delete_message` socket event | Own messages only, not pending |
| **Back (mobile)** | `ArrowLeft` | Returns to conversation list | Mobile view only |

#### Data Flow

1. **On Mount (if token exists):**
   - `ChatService.listConversations()` → populates sidebar
   - `chatSocketClient.connect('/messaging', token)` → establishes WebSocket
2. **On Conversation Select:**
   - `ChatService.getConversationMessages(id)` → loads message history
   - `chatSocketClient.emitJoinConversation(id)` → subscribes to live updates
   - `chatSocketClient.emitMarkRead(id)` → clears unread badge
3. **On Send Message:**
   - Optimistic message appended immediately
   - If socket connected: `chatSocketClient.emitSendMessage()`
   - If socket disconnected: `ChatService.sendMessage()` (REST fallback)
4. **On New Chat:**
   - `ChatService.searchUsers(email)` → finds target user
   - `ChatService.startConversation({ participantIds, type: 'direct', text })` → creates conversation
   - If conversation already exists → `ChatService.sendMessage()` sends the first message
   - Refreshes conversation list

---

### 2.2 AIChatbot Component (Evy)

**File:** `src/components/shared/AIChatbot.tsx` (487 lines)

A **floating chatbot widget** that appears in the bottom-right corner. Currently uses **simulated AI responses** (no backend endpoint connected).

#### Props Interface

```typescript
interface AIChatbotProps {
  isOpen: boolean;                    // Visibility toggle
  onClose: () => void;               // Close handler
  onSendMessage?: (message: string) => Promise<string>; // Optional external handler
  userRole?: 'student' | 'instructor'; // Determines quick actions shown
  userName?: string;                   // Greeting personalization
  className?: string;
}
```

#### Quick Actions by Role

| Role | Quick Actions |
|------|---------------|
| **Instructor** | Generate Quiz, Plan Lecture, Analyze Performance, Draft Announcement |
| **Student** | Explain Topic, Study Plan, Track Progress, Get Help |

#### UI Elements

| Element | Icon | Description |
|---------|------|-------------|
| **Header** | `Sparkles` | "Evy - AI Assistant" with status (Thinking.../Online) |
| **Clear Chat** | `RefreshCw` | Resets conversation to welcome message |
| **Minimize** | `Minimize2`/`Maximize2` | Toggles minimized state |
| **Close** | `X` | Closes the chatbot |
| **Copy** | `Copy`/`Check` | Copies AI response to clipboard |
| **Thumbs Up** | `ThumbsUp` | Feedback (UI only) |
| **Thumbs Down** | `ThumbsDown` | Feedback (UI only) |
| **Send** | `Send`/`Loader2` | Sends message / shows loading |

> **Note:** The AIChatbot does NOT use any backend API. All responses are simulated with `simulateAIResponse()` using keyword-based pattern matching.

---

## 3. Services Layer

### 3.1 ChatService (REST API)

**File:** `src/services/api/chatService.ts`

A static service class wrapping all chat-related REST endpoints via `ApiClient`.

| Method | HTTP | Endpoint | Description |
|--------|------|----------|-------------|
| `listConversations()` | `GET` | `/messages/conversations` | Returns all conversations for authenticated user |
| `getConversationMessages(id)` | `GET` | `/messages/conversations/:conversationId` | Returns message history for a conversation |
| `sendMessage(id, text)` | `POST` | `/messages/conversations/:conversationId` | Sends a text message (REST fallback) |
| `startConversation(body)` | `POST` | `/messages/conversations` | Creates a new conversation (direct/group) |
| `searchUsers(query, limit)` | `GET` | `/messages/users/search?query=&limit=` | Searches users by email/name |
| `markRead(messageId)` | `PATCH` | `/messages/:messageId/read` | Marks a specific message as read |
| `getConversationId(payload)` | — | — | Utility: extracts conversation ID from various response shapes |

#### Request/Response Shapes

**Start Conversation Body:**
```typescript
{
  participantIds: number[];    // User IDs to include
  type?: 'direct' | 'group';  // Conversation type
  text?: string;               // First message text
  groupName?: string;          // Group name (for group chats)
}
```

**Start Conversation Response:**
```typescript
{
  conversationId?: number;
  id?: number;
  existing?: boolean;          // True if conversation already existed
  data?: {
    conversationId?: number;
    id?: number;
    existing?: boolean;
  };
}
```

**Send Message Body:**
```typescript
{
  text?: string;
  messageType?: string;  // Always "text"
}
```

---

### 3.2 ChatSocketClient (WebSocket)

**File:** `src/services/chat/chatSocket.ts`

A singleton WebSocket client using `socket.io-client`, connecting to the `/messaging` namespace.

#### Connection Config

| Property | Value |
|----------|-------|
| **Namespace** | `/messaging` |
| **Server URL** | Derived from `API_BASE_URL` (strips `/api`), fallback `http://localhost:8081` |
| **Auth** | `{ token: accessToken }` in both `auth` and `query` params |
| **Transports** | `['websocket', 'polling']` |
| **Reconnection** | Enabled, 5 attempts, 1200ms delay |
| **Token Source** | `localStorage.getItem('accessToken')` |

#### Emitted Events (Client → Server)

| Method | Event Name | Payload |
|--------|-----------|---------|
| `emitJoinConversation(id)` | `join_conversation` | `{ conversationId }` |
| `emitLeaveConversation(id)` | `leave_conversation` | `{ conversationId }` |
| `emitSendMessage(id, text, replyToId?)` | `send_message` | `{ conversationId, text, replyToId, fileId: null }` |
| `emitTyping(id, isTyping)` | `typing` | `{ conversationId, isTyping }` |
| `emitMarkRead(id)` | `mark_read` | `{ conversationId }` |
| `emitDeleteMessage(id, forEveryone)` | `delete_message` | `{ messageId, forEveryone }` |
| `emitEditMessage(id, text)` | `edit_message` | `{ messageId, text }` |

#### Listened Events (Server → Client)

| Event | Handler Purpose |
|-------|----------------|
| `connect` | Sets connection status to "Live" |
| `disconnect` | Sets connection status to "Offline" |
| `new_message` | Incoming message from another user → appended to view |
| `message_sent` | Confirmation of own sent message → replaces optimistic |
| `new_message_notification` | Updates conversation preview (unread badge) |
| `user_typing` | Shows "User X is typing..." indicator |
| `message_deleted` | Marks message as deleted in UI |
| `delete_confirmed` | Same as `message_deleted` (acknowledgment) |
| `message_edited` | (Registered but not actively handled in `MessagingChat`) |
| `connect_error` | (Registered in interface but not handled) |

---

## 4. Role: Student

### 4.1 Dashboard Integration

**File:** `src/pages/student-dashboard/StudentDashboard.tsx`

#### Sidebar Entry

| Property | Value |
|----------|-------|
| **Tab ID** | `chat` |
| **Label** | "Chat" (translatable: EN `chat`, AR `الدردشة`) |
| **Icon** | `MessageCircle` (from lucide-react) |
| **Group** | `Communication` |
| **Route** | `/studentdashboard/chat` |

#### Chat Tab Rendering

```tsx
{activeTab === 'chat' && (
  <MessagingChat
    height="100vh"
    currentUserId={user?.userId ? String(user.userId) : undefined}
    currentUserName={user?.fullName || 'Student'}
    isDark={isDark}
    className="rounded-none border-0"
    accentColor={primaryHex || '#3b82f6'}
  />
)}
```

#### Student-Specific Props

| Prop | Value | Effect |
|------|-------|--------|
| `height` | `"100vh"` | Full-screen immersive chat |
| `currentUserId` | From `useAuth().user.userId` | Enables own-message detection |
| `currentUserName` | From `useAuth().user.fullName` or `"Student"` | Sender name on outgoing |
| `accentColor` | Theme primary hex or `#3b82f6` | Blue accent for bubbles |
| `className` | `"rounded-none border-0"` | Borderless full-screen layout |

#### Layout Behavior

- **Header hidden** when `activeTab === 'chat'`
- **Padding removed**: Main container gets `p-0` class
- **Content wrapper**: Gets `h-screen overflow-hidden p-0` class

#### Feature Availability

| Feature | Available |
|---------|-----------|
| Conversation list & search | ✅ |
| New conversation by email | ✅ |
| Send text messages | ✅ |
| File attachments | ✅ |
| Emoji picker | ✅ |
| Voice message toggle | ✅ |
| Reply to messages | ✅ |
| Delete for me | ✅ |
| Delete for everyone | ✅ (own messages) |
| Typing indicators | ✅ |
| Voice call button | ✅ (default prop) |
| Video call button | ✅ (default prop) |

### 4.2 AI Chatbot (Student AI Features)

**File:** `src/pages/student-dashboard/components/AIFeatures/features/ChatbotContent.tsx`

This is a **static mockup** embedded inside the student's AI Features tab. It is **not connected** to any backend or WebSocket — purely a UI demonstration with hardcoded conversation bubbles.

| Element | Description |
|---------|-------------|
| AI study companion intro | Lists capabilities: explaining concepts, practice problems, study strategies, exam prep |
| Mock conversation | Hardcoded Q&A about stacks vs queues |
| Quick suggestion buttons | "Explain concept", "Practice problem", "Study tips", "Exam prep" |
| Text input + Send button | UI-only, no handler wired |

---

## 5. Role: Instructor

### 5.1 Dashboard Chat Tab

**File:** `src/pages/instructor-dashboard/InstructorDashboard.tsx`

#### Sidebar Entry

| Property | Value |
|----------|-------|
| **Tab Key** | `chat` |
| **Label** | "Chat" / "الدردشة" (Arabic) |
| **Icon** | `MessageCircle` |
| **Group** | `Communication` |
| **Route** | `/instructordashboard/chat` |

#### Chat Tab Rendering

```tsx
{activeTab === 'chat' && (
  <MessagingChat
    height="100vh"
    currentUserName={user?.fullName || 'Prof. Sarah Martinez'}
    showVideoCall={true}
    showVoiceCall={true}
    isDark={isDark}
    accentColor={primaryHex || '#4f46e5'}
    className="rounded-none border-0"
  />
)}
```

#### Instructor-Specific Props

| Prop | Value | Effect |
|------|-------|--------|
| `height` | `"100vh"` | Full-screen immersive chat |
| `currentUserName` | From auth or `"Prof. Sarah Martinez"` | Professional display name |
| `showVideoCall` | `true` | Video call button visible |
| `showVoiceCall` | `true` | Voice call button visible |
| `accentColor` | `#4f46e5` (Indigo) | Indigo accent for bubbles |

### 5.2 Communication Page (Sub-screens)

**File:** `src/pages/instructor-dashboard/components/CommunicationPage.tsx`

The instructor has a dedicated **Communication Center** page with three sub-tabs:

#### Sub-tabs

| Sub-tab | Component | Props |
|---------|-----------|-------|
| **Announcements** | Native announcement list | Course filter, search, CRUD |
| **Course Chats** | `<MessagingChat height="500px" showVideoCall={true} showVoiceCall={true} />` | Default conversations |
| **Direct Messages** | `<MessagingChat height="500px" currentUserName="Professor Martinez" showVideoCall={false} showVoiceCall={true} />` | DM-only, no video call |

#### AI Communication Assistant Panel

Located below the tabs, always visible:

| Button | Icon | Label | Action |
|--------|------|-------|--------|
| Generate Announcement | `FileText` | "Generate Announcement" | Opens scheduled announcement modal |
| Summarize Chat | `MessageSquare` | "Summarize Chat" | Placeholder |
| Suggest Reply | `Sparkles` | "Suggest Reply" | Placeholder |

### 5.3 Announcements Manager (Embedded Chat)

**File:** `src/pages/instructor-dashboard/components/AnnouncementsManager.tsx`

Also embeds `<MessagingChat>` in two configurations:

| Instance | Height | showVideoCall | showVoiceCall | isDark |
|----------|--------|---------------|---------------|--------|
| Instance 1 | `600px` | `true` | `true` | `isDark` |
| Instance 2 | default | default | default | `isDark` |

### 5.4 AI Chatbot (Evy) — Floating

**File:** `src/pages/instructor-dashboard/components/AIToolsPage.tsx`

- A **floating action button** (fixed bottom-right) opens the `<AIChatbot>` overlay
- Configured with `userRole="instructor"` and `userName="Professor"`
- Quick actions: Generate Quiz, Plan Lecture, Analyze Performance, Draft Announcement

---

## 6. Role: Teaching Assistant (TA)

### 6.1 Dashboard Chat Tab

**File:** `src/pages/ta-dashboard/TADashboard.tsx`

#### Sidebar Entry

| Property | Value |
|----------|-------|
| **Tab Key** | `chat` |
| **Label** | "Chat" (translatable via `t('chat')`) |
| **Icon** | `MessageSquare` |
| **Group** | `Communication` |
| **Route** | `/tadashboard/chat` |

#### Chat Tab Rendering

```tsx
{activeTab === 'chat' && (
  <MessagingChat
    height="100vh"
    currentUserName={user?.fullName || 'Ahmed Hassan'}
    showVideoCall={true}
    showVoiceCall={true}
    isDark={isDark}
    accentColor={primaryHex || '#4f46e5'}
    className="rounded-none border-0"
  />
)}
```

#### TA-Specific Props

| Prop | Value | Effect |
|------|-------|--------|
| `height` | `"100vh"` | Full-screen immersive |
| `currentUserName` | From auth or `"Ahmed Hassan"` | TA identity |
| `accentColor` | `#4f46e5` (Indigo) | Matches instructor theme |

### 6.2 Announcements Page (Communication Hub)

**File:** `src/pages/ta-dashboard/components/AnnouncementsPage.tsx`

The TA Announcements page also serves as a communication hub with three sub-tabs:

| Sub-tab | ID | Icon | Component |
|---------|----|------|-----------|
| **Announcements** | `announcements` | `Megaphone` | Native announcement CRUD |
| **Course Chats** | `courseChats` | `Users` | `<MessagingChat isDark={isDark} />` |
| **Direct Messages** | `directMessages` | `MessageSquare` | `<MessagingChat isDark={isDark} />` |

Both chat sub-tabs render in a container with height `calc(100vh - 220px)` and use **default props** (all features enabled, no custom user name/ID passed).

### 6.3 AI Assistant Page (Local)

**File:** `src/pages/ta-dashboard/components/AIAssistantPage.tsx`

This is a **standalone local AI chat** (NOT connected to the shared messaging system or any API). It provides:

- **4 modes:** General Help, Grading Mode, Teaching Mode, Analysis Mode
- **6 quick actions:** Grade Assistance, Generate Feedback, Create Rubric, Explain Concept, Generate Quiz, Lab Preparation
- **Mock responses:** Hardcoded per-mode responses with suggestion buttons
- **Copy/Regenerate actions** on AI messages

> This component does NOT use `ChatService`, `ChatSocketClient`, or `MessagingChat`.

---

## 7. Role: Admin

### 7.1 Dashboard Chat Tab

**File:** `src/pages/admin-dashboard/AdminDashboard.tsx`

#### Sidebar Entry

| Property | Value |
|----------|-------|
| **Tab Key** | `chat` |
| **Label** | "Chat" / "الدردشة" (Arabic) |
| **Icon** | `MessageCircle` |
| **Group** | `Communication` |
| **Route** | `/admindashboard/chat` |

#### Chat Tab Rendering

```tsx
{activeTab === 'chat' && (
  <MessagingChat
    height="100vh"
    currentUserName={user?.fullName || 'Administrator'}
    showVideoCall={true}
    showVoiceCall={true}
    isDark={isDark}
    accentColor={primaryHex || '#4f46e5'}
    className="rounded-none border-0"
  />
)}
```

#### Admin-Specific Props

| Prop | Value | Effect |
|------|-------|--------|
| `currentUserName` | From auth or `"Administrator"` | Admin identity |
| `accentColor` | `#4f46e5` (Indigo) | Consistent accent |

### 7.2 Additional Chat Surfaces

The Admin has a **Communication** tab (separate from Chat) that includes broadcast messaging and notification templates — but this uses `CommunicationPage` component which does **not** embed `MessagingChat`.

---

## 8. Role: IT Admin

### 8.1 Dashboard Chat Tab

**File:** `src/pages/it-admin-dashboard/ITAdminDashboard.tsx`

#### Sidebar Entry

| Property | Value |
|----------|-------|
| **Tab Key** | `chat` |
| **Label** | "Chat" / "الدردشة" (Arabic) |
| **Icon** | `MessageCircle` |
| **Group** | `Communication` |
| **Route** | `/itadmindashboard/chat` |

#### Chat Tab Rendering

```tsx
{activeTab === 'chat' && (
  <MessagingChat
    height="100vh"
    className="rounded-none border-0"
    currentUserName={user?.fullName || 'IT Administrator'}
    showVideoCall={true}
    showVoiceCall={true}
    isDark={isDark}
    accentColor={primaryHex || '#3b82f6'}
  />
)}
```

#### IT Admin-Specific Props

| Prop | Value | Effect |
|------|-------|--------|
| `currentUserName` | From auth or `"IT Administrator"` | IT Admin identity |
| `accentColor` | `#3b82f6` (Blue) | Slightly different from Admin's indigo |

---

## 9. API Endpoints Reference

All endpoints are relative to the `API_BASE_URL` (default: `/api` in development, `http://localhost:8081/api` in production).

**Authentication:** All endpoints require a valid JWT `accessToken` in the `Authorization: Bearer <token>` header, handled automatically by `ApiClient`.

| Method | Endpoint | Service Method | Request Body | Response | Used By |
|--------|----------|---------------|-------------|----------|---------|
| `GET` | `/messages/conversations` | `listConversations()` | — | `ChatConversationApi[]` | All roles |
| `GET` | `/messages/conversations/:id` | `getConversationMessages(id)` | — | `ChatMessageApi[]` | All roles |
| `POST` | `/messages/conversations/:id` | `sendMessage(id, text)` | `{ text, messageType: 'text' }` | `ChatMessageApi` | All roles |
| `POST` | `/messages/conversations` | `startConversation(body)` | `{ participantIds, type, text, groupName? }` | `StartConversationResponse` | All roles |
| `GET` | `/messages/users/search` | `searchUsers(query, limit)` | Query params: `query`, `limit` | `ChatUser[]` | All roles |
| `PATCH` | `/messages/:messageId/read` | `markRead(messageId)` | — | `void` | All roles |

---

## 10. WebSocket Events Reference

**Connection:** `socket.io-client` on `{serverOrigin}/messaging` namespace.

### Client → Server (Emit)

| Event | Payload | Trigger |
|-------|---------|---------|
| `join_conversation` | `{ conversationId: number }` | Selecting a conversation |
| `leave_conversation` | `{ conversationId: number }` | Switching away from a conversation |
| `send_message` | `{ conversationId, text, replyToId?, fileId: null }` | Sending a message (if socket connected) |
| `typing` | `{ conversationId, isTyping: boolean }` | User is typing (debounced 1.5s) |
| `mark_read` | `{ conversationId: number }` | Opening a conversation |
| `delete_message` | `{ messageId, forEveryone: boolean }` | Deleting own message for everyone |
| `edit_message` | `{ messageId, text }` | (Available but not exposed in UI) |

### Server → Client (Listen)

| Event | Payload Shape | UI Effect |
|-------|---------------|-----------|
| `connect` | — | Status badge → "Live" (green) |
| `disconnect` | `reason: string` | Status badge → "Offline" |
| `new_message` | `{ conversationId, text, senderId, ... }` | Appends message to chat (if not own) |
| `message_sent` | `{ conversationId, text, senderId, ... }` | Replaces optimistic message / confirms |
| `new_message_notification` | `{ conversationId, message: { text, senderId } }` | Updates conversation preview + unread count |
| `user_typing` | `{ conversationId, userId, isTyping }` | Shows "User X is typing..." (1.8s timeout) |
| `message_deleted` | `{ messageId }` or `{ data: { messageId } }` | Marks message as "This message was deleted" |
| `delete_confirmed` | Same as `message_deleted` | Same handling |
| `message_edited` | — | (Registered in interface but not handled) |

---

## 11. Data Models & TypeScript Interfaces

### ChatConversationApi

```typescript
interface ChatConversationApi {
  conversationId?: number;
  id?: number;
  name?: string;
  title?: string;
  type?: 'direct' | 'group' | string;
  isGroup?: boolean;
  participants?: Array<number | {
    userId?: number; id?: number;
    firstName?: string; lastName?: string;
    fullName?: string; email?: string;
  }>;
  participantUsers?: Array<{
    userId?: number; id?: number;
    firstName?: string; lastName?: string;
    fullName?: string; email?: string;
  }>;
  directDisplayUser?: {
    userId?: number; id?: number;
    firstName?: string; lastName?: string;
    fullName?: string; email?: string;
  } | null;
  lastMessage?: string | {
    id?: number; text?: string;
    body?: string; content?: string;
    sentAt?: string; createdAt?: string;
    senderId?: number; senderUserId?: number;
  };
  lastMessageInfo?: {
    id?: number; text?: string;
    senderId?: number; senderName?: string;
    senderEmail?: string; sentAt?: string;
    isDeleted?: boolean;
  };
  lastMessageAt?: string;
  lastSenderId?: number;
  unreadCount?: number;
  updatedAt?: string;
  createdAt?: string;
}
```

### ChatMessageApi

```typescript
interface ChatMessageApi {
  id?: number;
  messageId?: number;
  text?: string;
  body?: string;
  content?: string;
  sentAt?: string;
  createdAt?: string;
  updatedAt?: string;
  editedAt?: string;
  senderId?: number;
  senderUserId?: number;
  conversationId?: number;
  replyToId?: number;
  readAt?: string;
  deletedAt?: string;
  isDeleted?: boolean;
  senderName?: string;
  senderFirstName?: string;
  senderLastName?: string;
  sender?: {
    userId?: number;
    firstName?: string;
    lastName?: string;
    fullName?: string;
  };
}
```

### ChatUser

```typescript
interface ChatUser {
  userId: number;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  email?: string;
}
```

### Frontend Message (Mapped)

```typescript
interface Message {
  id: string;
  conversationId?: string;
  replyToId?: string;
  sender: string;
  senderInitials: string;
  senderColor: string;
  text?: string;
  image?: string;
  file?: { name: string; size: string; type: string };
  timestamp: string;
  rawTimestamp?: string;
  isCurrentUser: boolean;
  isDeleted?: boolean;
  status?: 'sent' | 'delivered' | 'read';
  pending?: boolean;
}
```

### Frontend Conversation (Mapped)

```typescript
interface Conversation {
  id: string;
  name: string;
  searchName: string;
  searchEmail: string;
  initials: string;
  color: string;
  lastMessage: string;
  timestamp: string;
  unreadCount: number;
  isOnline: boolean;
  role?: string;
  isGroup?: boolean;
  otherParticipantId?: string;
  otherParticipantEmail?: string;
}
```

---

## Role Comparison Matrix

| Feature | Student | Instructor | TA | Admin | IT Admin |
|---------|---------|------------|-----|-------|----------|
| **Chat sidebar tab** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Full-screen chat (`100vh`)** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Header hidden in chat** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **currentUserId from auth** | ✅ | ❌ (JWT auto) | ❌ (JWT auto) | ❌ (JWT auto) | ❌ (JWT auto) |
| **currentUserName from auth** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Accent color** | `#3b82f6` (blue) | `#4f46e5` (indigo) | `#4f46e5` (indigo) | `#4f46e5` (indigo) | `#3b82f6` (blue) |
| **Video call button** | ✅ (default) | ✅ (explicit) | ✅ (explicit) | ✅ (explicit) | ✅ (explicit) |
| **Voice call button** | ✅ (default) | ✅ (explicit) | ✅ (explicit) | ✅ (explicit) | ✅ (explicit) |
| **Communication page with chat** | ❌ | ✅ (3 sub-tabs) | ✅ (3 sub-tabs) | ❌ | ❌ |
| **Announcements with embedded chat** | ❌ | ✅ | ✅ | ❌ | ❌ |
| **AI Chatbot (Evy)** | ❌ (static mockup) | ✅ (floating) | ❌ | ❌ | ❌ |
| **AI Assistant (local)** | ❌ | ❌ | ✅ (4 modes) | ❌ | ❌ |
| **Chat route** | `/studentdashboard/chat` | `/instructordashboard/chat` | `/tadashboard/chat` | `/admindashboard/chat` | `/itadmindashboard/chat` |

---

## Notes

1. **No role-based restrictions on the backend messaging API**: Any authenticated user can message any other user regardless of role. The frontend does not enforce any restrictions on who can be messaged.

2. **Voice/Video Calls**: The phone and video icons are rendered but are **purely UI placeholders** — no WebRTC or call functionality is implemented.

3. **File Uploads**: The file attachment button triggers a file picker and creates a local optimistic file message, but **actual file upload to the server is not implemented** in the current chat flow.

4. **Voice Messages**: The microphone button toggles a recording state visually, but **no actual recording or sending of voice notes is implemented**.

5. **Message Edit**: The `emitEditMessage` method exists on the socket client, and the `message_edited` event is registered, but the **edit UI is not exposed** in the MessagingChat component.

6. **AI Chatbot (Evy)**: Uses simulated responses with **no backend AI endpoint**. The `onSendMessage` prop allows connecting a real AI backend if provided.

7. **User Directory**: The component builds a local user directory from conversation participants to resolve display names, enriched by search results when starting new conversations.
