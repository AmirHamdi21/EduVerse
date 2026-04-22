# Discussion REST API Contracts

This defines the expected API endpoints to implement inside `DiscussionService`.

## Endpoints

### 1. `GET /api/discussions?courseId={id}`
- **Permissions**: Enrolled Students, Staff, Admins.
- **Parameters**: `page`, `limit`, `courseId` (Optional for global Admins).
- **Response**: Paginated `List<DiscussionThread>`. `isPinned` sorts first.

### 2. `POST /api/discussions`
- **Permissions**: Enrolled Students, Staff, Admins.
- **Body**: `{ courseId: number, title: string, description: string }`
- **Response**: `DiscussionThread`

### 3. `GET /api/discussions/:id`
- **Permissions**: Enrolled Students, Staff, Admins.
- **Response**: Object containing `{ thread: DiscussionThread, replies: { data: List<DiscussionReply>, meta: Pagination } }`.
- **Side-effects**: Increments `viewCount`.

### 4. `POST /api/discussions/:id/reply`
- **Permissions**: Enrolled Students, Staff, Admins.
- **Body**: `{ messageText: string, parentMessageId: number? }`
- **Response**: `DiscussionReply`. (Fails 400 if thread is `isLocked`).

### 5. `PUT /api/discussions/:id`
- **Permissions**: Thread Author, Staff, Admins.
- **Body**: `{ title: string, description: string }`
- **Response**: Updated `DiscussionThread`.

### 6. `DELETE /api/discussions/:id`
- **Permissions**: Staff, Instructors, Admins (Authors CANNOT delete their threads, only modify).
- **Response**: `204 No Content`.

### 7. Moderation Flags (`PATCH` Endpoints)

- **Toggle Pin**: `PATCH /api/discussions/:id/pin`
- **Toggle Lock**: `PATCH /api/discussions/:id/lock`
- **Mark Answer**: `PATCH /api/discussions/replies/:replyId/mark-answer`
- **Endorse**: `PATCH /api/discussions/replies/:replyId/endorse`

All PATCH endpoints return `200 Update Successful` and toggle the corresponding boolean.
