# Codex Implementation Prompt — Announcement & Communication API Migration

## Project Overview

You are working on **EduVerse**, a Flutter mobile app at `D:\Graduation\EduVerse\edu_verse`. The task is to migrate the **Announcement Manager** (Instructor/TA) and **Admin Communication** features from mock/local data to real backend API calls, achieving 1:1 feature parity with the React web frontend.

## You will find the full plan for these features in: D:\Graduation\EduVerse\edu_verse\Announcement_Manager_Communication_implementation_plan\Announcement_Manager_Communication_implementation_plan.md
Backend Path: D:\Graduation\backend\last_backend\EduVerse_Backend

Website Frontend path: D:\Graduation\frontend_tarek\Eduverse-Frontend
**Critical Rules:**
1. **Do NOT change** the Instructor Announcement Manager's UI structure/design — only rewire its data layer.
2. The TA screen must **reuse the exact same widgets** from `lib/widgets/instructor/announcements/`.
3. The Admin screen must also **reuse** the instructor widgets but with admin-appropriate navigation.
4. Follow the project's existing **Service → Screen** pattern (no BLoC for this feature — the screens manage state directly with `setState`).

---

## 1. BACKEND API REFERENCE

**Base path:** `api/announcements` (the `CoreApiClient` already prepends the base URL)

### Announcement Entity (Backend TypeORM)
```typescript
{
  id: number;                    // PK bigint
  courseId: number | null;       // FK nullable
  createdBy: number;             // FK to User
  title: string;                 // varchar(255)
  content: string;               // text
  announcementType: 'course' | 'department' | 'campus' | 'system';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  targetAudience: 'all' | 'students' | 'instructors' | 'admins';
  isPublished: boolean;          // tinyint 0/1
  publishedAt?: Date;            // nullable
  expiresAt?: Date;              // nullable
  attachmentFileId?: number;     // nullable
  viewCount: number;             // default 0
  createdAt: Date;
  updatedAt: Date;
  // Eager-loaded relations:
  author: { userId, firstName, lastName, email, profilePictureUrl };
  course: { id, name, code } | null;
  // isPinned is returned but not in entity — service adds it
}
```

### Endpoints
| Method | Path | Roles | Body/Query | Notes |
|--------|------|-------|------------|-------|
| GET | `/announcements` | All authenticated | `?courseId=&page=&limit=` | Filtered by role. Pinned first, then newest. |
| POST | `/announcements` | Instructor,TA,Admin | `{title,content,courseId?,priority?,announcementType?,targetAudience?}` | Creates as draft (isPublished=0) |
| GET | `/announcements/:id` | All authenticated | — | Increments viewCount |
| PUT | `/announcements/:id` | Owner,Admin | `{title?,content?,priority?}` | — |
| DELETE | `/announcements/:id` | Owner,Admin (not TA) | — | Returns 204 No Content |
| PATCH | `/announcements/:id/publish` | Owner,Admin | — | Sets isPublished=1, publishedAt=now |
| PATCH | `/announcements/:id/schedule` | Owner,Admin | `{scheduledAt: ISO8601}` | Sets scheduledAt, keeps unpublished |
| PATCH | `/announcements/:id/pin` | Instructor,Admin | `{isPinned?: boolean}` | Toggles pin. Body optional. |
| GET | `/announcements/:id/analytics` | Owner,Instructor,Admin | — | Returns analytics data |

### Web Frontend TypeScript Interface (Parity Target)
```typescript
interface Announcement {
  id: string;
  courseId: string | null;
  createdBy: number;
  title: string;
  content: string;
  announcementType?: 'course' | 'campus' | 'system';
  priority?: 'low' | 'medium' | 'high' | 'urgent' | string;
  targetAudience?: string;
  isPublished: number;           // 0 or 1
  attachmentFileId?: string | null;
  viewCount?: number;
  isPinned?: number;             // 0 or 1
  publishedAt?: string;
  expiresAt?: string | null;
  createdAt?: string;
  updatedAt?: string;
  author?: { userId?, firstName?, lastName?, email?, profilePictureUrl? };
  course?: { id?, name?, code? } | null;
}
```

---

## 2. EXISTING FLUTTER CODE PATTERNS

### CoreApiClient (`lib/services/api/core_api_client.dart`)
- Provides `dio` instance with auto Bearer token injection and 401 refresh
- Base URL comes from `ApiService.baseUrl`
- All services take `CoreApiClient` via constructor

### Service Access in Screens (pattern from Attendance migration)
```dart
// In screen's initState:
final coreApiClient = CoreApiClient(); // or from provider
_communicationService = CommunicationService(coreApiClient: coreApiClient);
```

### Response Normalization Pattern
The backend may return `List<T>` directly or `{ data: List<T> }`. Always handle both:
```dart
final List data = response.data is List
    ? response.data as List
    : (response.data['data'] as List?) ?? [];
```

---

## 3. PHASE 1 — UPDATE `AnnouncementModel` (materials)

**File:** `lib/models/materials/announcement_model.dart`

Replace the entire file with an updated model that matches the full backend response:

```dart
import 'package:equatable/equatable.dart';

class AnnouncementAuthor extends Equatable {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePictureUrl;

  const AnnouncementAuthor({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePictureUrl,
  });

  factory AnnouncementAuthor.fromJson(Map<String, dynamic> json) {
    return AnnouncementAuthor(
      userId: json['userId'] as int?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  String get displayName {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isNotEmpty ? name : (email ?? 'System');
  }

  @override
  List<Object?> get props => [userId, firstName, lastName, email];
}

class AnnouncementCourse extends Equatable {
  final String? id;
  final String? name;
  final String? code;

  const AnnouncementCourse({this.id, this.name, this.code});

  factory AnnouncementCourse.fromJson(Map<String, dynamic> json) {
    return AnnouncementCourse(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      code: json['code'] as String?,
    );
  }

  String get displayLabel {
    if (name != null || code != null) {
      return '${name ?? ''}${code != null ? ' ($code)' : ''}'.trim();
    }
    return 'Campus-wide';
  }

  @override
  List<Object?> get props => [id, name, code];
}

class AnnouncementModel extends Equatable {
  final String id;
  final String? courseId;
  final int? createdBy;
  final String title;
  final String content;
  final String? announcementType;
  final String priority;
  final String? targetAudience;
  final int isPublished;
  final int? isPinned;
  final int viewCount;
  final String? attachmentFileId;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnnouncementAuthor? author;
  final AnnouncementCourse? course;

  const AnnouncementModel({
    required this.id,
    this.courseId,
    this.createdBy,
    required this.title,
    required this.content,
    this.announcementType,
    required this.priority,
    this.targetAudience,
    required this.isPublished,
    this.isPinned,
    this.viewCount = 0,
    this.attachmentFileId,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.course,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString(),
      createdBy: json['createdBy'] as int?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      announcementType: json['announcementType'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      targetAudience: json['targetAudience'] as String?,
      isPublished: json['isPublished'] is bool
          ? (json['isPublished'] as bool ? 1 : 0)
          : (json['isPublished'] as int? ?? 0),
      isPinned: json['isPinned'] is bool
          ? (json['isPinned'] as bool ? 1 : 0)
          : json['isPinned'] as int?,
      viewCount: json['viewCount'] as int? ?? 0,
      attachmentFileId: json['attachmentFileId']?.toString(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      author: json['author'] is Map<String, dynamic>
          ? AnnouncementAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      course: json['course'] is Map<String, dynamic>
          ? AnnouncementCourse.fromJson(json['course'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'title': title,
    'content': content,
    'announcementType': announcementType,
    'priority': priority,
    'targetAudience': targetAudience,
    'isPublished': isPublished,
    'isPinned': isPinned,
    'viewCount': viewCount,
    'publishedAt': publishedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, title, isPublished, isPinned, updatedAt];
}
```

---

## 4. PHASE 1 — UPDATE `AnnouncementItem` (instructor model)

**File:** `lib/models/instructor/announcement_model.dart`

Add these fields to `AnnouncementItem`:
- `bool isPinned` (default false)
- `String? priority`
- `String? announcementType`
- `String? authorName`

Add them to the constructor, `copyWith`, and props.

Add this factory (import `AnnouncementModel` from materials):
```dart
factory AnnouncementItem.fromApi(AnnouncementModel api) {
  return AnnouncementItem(
    id: api.id,
    title: api.title,
    content: api.content,
    status: api.isPublished == 1
        ? AnnouncementStatus.published
        : AnnouncementStatus.draft,
    createdAt: api.createdAt,
    publishedAt: api.publishedAt,
    audience: api.course?.displayLabel ?? 'Campus-wide',
    totalAudience: 0,
    readCount: api.viewCount,
    courseName: api.course?.name,
    courseId: api.courseId,
    isPinned: api.isPinned == 1,
    priority: api.priority,
    announcementType: api.announcementType,
    authorName: api.author?.displayName,
  );
}
```

---

## 5. PHASE 2 — UPDATE `CommunicationService`

**File:** `lib/services/api/communication_service.dart`

Add these methods to the Announcements section:

```dart
/// DELETE /api/announcements/{id}
Future<void> deleteAnnouncement(dynamic id) async {
  await _client.dio.delete('/announcements/$id');
}

/// PATCH /api/announcements/{id}/schedule
Future<void> scheduleAnnouncement(dynamic id, DateTime scheduledAt) async {
  await _client.dio.patch('/announcements/$id/schedule', data: {
    'scheduledAt': scheduledAt.toIso8601String(),
  });
}
```

Update the existing `pinAnnouncement` to accept an optional body:
```dart
/// PATCH /api/announcements/{id}/pin
Future<void> pinAnnouncement(dynamic id, {bool? isPinned}) async {
  await _client.dio.patch(
    '/announcements/$id/pin',
    data: isPinned != null ? {'isPinned': isPinned} : null,
  );
}
```

---

## 6. PHASE 3 — WIRE INSTRUCTOR SCREEN

**File:** `lib/screens/instructor/announcements/announcement_manager_screen.dart`

### Key changes:
1. Add `import '../../services/api/communication_service.dart';` and `import '../../services/api/core_api_client.dart';`
2. Add field: `late final CommunicationService _communicationService;`
3. In `initState()`, initialize: `_communicationService = CommunicationService(coreApiClient: CoreApiClient());`
4. Replace `_loadAnnouncements()`:

```dart
Future<void> _loadAnnouncements() async {
  if (!mounted) return;
  setState(() { _isLoading = true; _hasError = false; });
  try {
    final apiList = await _communicationService.getAnnouncements();
    if (!mounted) return;
    setState(() {
      _announcements = apiList.map(AnnouncementItem.fromApi).toList();
      _isLoading = false;
    });
    _fabAnimController.forward();
    _listAnimController.forward();
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
    });
  }
}
```

5. Delete the `_getMockAnnouncements()` method entirely.

6. Replace `_deleteAnnouncement()`:
```dart
Future<void> _deleteAnnouncement(String id, bool isDark) async {
  try {
    await _communicationService.deleteAnnouncement(id);
    _showSuccessSnackbar('Announcement deleted successfully!', isDark);
    await _loadAnnouncements();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }
}
```

7. Replace `_publishAnnouncement()`:
```dart
Future<void> _publishAnnouncement(AnnouncementItem announcement, bool isDark) async {
  try {
    await _communicationService.publishAnnouncement(announcement.id);
    _showSuccessSnackbar('Announcement published successfully!', isDark);
    await _loadAnnouncements();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    }
  }
}
```

8. Add pin handler:
```dart
Future<void> _pinAnnouncement(AnnouncementItem announcement, bool isDark) async {
  try {
    await _communicationService.pinAnnouncement(
      announcement.id,
      isPinned: !announcement.isPinned,
    );
    _showSuccessSnackbar(
      announcement.isPinned ? 'Unpinned' : 'Pinned',
      isDark,
    );
    await _loadAnnouncements();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pin: $e')),
      );
    }
  }
}
```

9. Update `_addOrUpdateAnnouncement()` to call API:
```dart
Future<void> _addOrUpdateAnnouncement(AnnouncementItem announcement, bool isDark) async {
  try {
    if (_announcements.any((a) => a.id == announcement.id)) {
      // Update existing
      await _communicationService.updateAnnouncement(announcement.id, {
        'title': announcement.title,
        'content': announcement.content,
        'priority': announcement.priority ?? 'medium',
      });
      if (announcement.status == AnnouncementStatus.published) {
        await _communicationService.publishAnnouncement(announcement.id);
      }
    } else {
      // Create new
      final created = await _communicationService.createAnnouncement({
        'title': announcement.title,
        'content': announcement.content,
        'priority': announcement.priority ?? 'medium',
        if (announcement.courseId != null && announcement.courseId != '0')
          'courseId': int.tryParse(announcement.courseId!) ?? 0,
      });
      if (announcement.status == AnnouncementStatus.published) {
        await _communicationService.publishAnnouncement(created.id);
      }
    }
    _showSuccessSnackbar('Announcement saved!', isDark);
    await _loadAnnouncements();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }
}
```

10. Pass `onPin` callback to `AnnouncementCard`:
```dart
AnnouncementCard(
  // ... existing params ...
  onPin: () => _pinAnnouncement(announcement, isDark),
)
```

### Update `announcement_card.dart`
**File:** `lib/widgets/instructor/announcements/announcement_card.dart`

- Add `VoidCallback? onPin` parameter
- Add "Pin/Unpin" entry to the `PopupMenuButton` items
- Display `announcement.priority` badge if not null
- Display `announcement.authorName` in metadata row
- Display `announcement.isPinned` indicator (pin icon) in the header

### Update `announcement_form_dialog.dart`
**File:** `lib/widgets/instructor/announcements/announcement_form_dialog.dart`

- Add a priority dropdown (low/medium/high/urgent) to the form
- Remove the hardcoded `_audienceOptions` list
- Accept an optional `List<Map<String, String>>? courseOptions` parameter for course selection
- Set the `priority` field on the saved `AnnouncementItem`
- Remove the `Future.delayed` mock save and call `onSave` directly

---

## 7. PHASE 4 — CREATE TA ANNOUNCEMENT SCREEN

**File (NEW):** `lib/screens/ta/announcements/ta_announcement_manager_screen.dart`

Create a screen that is structurally identical to the instructor's `AnnouncementManagerScreen` but:
- Class name: `TAAnnouncementManagerScreen`
- Uses the same widget imports from `lib/widgets/instructor/announcements/announcement_barrel.dart`
- Uses `CommunicationService` for all API calls (identical to instructor)
- Back navigation goes to TA dashboard
- The backend automatically filters by TA role

**Copy the instructor screen and change only:**
1. Class name → `TAAnnouncementManagerScreen` / `_TAAnnouncementManagerScreenState`
2. Back button `context.pop()` stays the same (it returns to wherever the user came from)

---

## 8. PHASE 5 — CREATE ADMIN ANNOUNCEMENT SCREEN

**File (NEW):** `lib/screens/admin/announcements/admin_announcement_manager_screen.dart`

Same approach as TA — copy the instructor screen pattern but:
- Class name: `AdminAnnouncementManagerScreen`
- Uses `AdminColors` import from `lib/widgets/admin/shared/admin_colors.dart` for the back button and minor accent theming, but the announcement widgets themselves use `AnnouncementColors` (keep as-is)
- Backend returns ALL announcements for admin role

---

## 9. PHASE 6 — ROUTER & DRAWER

### `lib/config/app_router.dart`
Add these imports at the top:
```dart
import 'package:edu_verse/screens/ta/announcements/ta_announcement_manager_screen.dart';
import 'package:edu_verse/screens/admin/announcements/admin_announcement_manager_screen.dart';
```

Add these routes (near the existing instructor announcements route):
```dart
GoRoute(
  path: '/ta/announcements',
  builder: (context, state) => const TAAnnouncementManagerScreen(),
),
GoRoute(
  path: '/admin/announcements',
  builder: (context, state) => const AdminAnnouncementManagerScreen(),
),
```

### `lib/widgets/ta/dashboard/ta_drawer.dart`
Add this entry to the `_buildMenuItems` list, after the attendance entry (around line 392):
```dart
_MenuItem(
  icon: Icons.campaign_outlined,
  activeIcon: Icons.campaign,
  title: l10n.announcementsManager,
  route: '/ta/announcements',
  category: 'main',
),
```

---

## 10. VERIFICATION

After all changes, run:
```bash
cd D:\Graduation\EduVerse\edu_verse
flutter analyze
flutter build apk --debug
```

Both must pass with zero errors.

---

## FILES SUMMARY

| # | Action | Path |
|---|--------|------|
| 1 | MODIFY | `lib/models/materials/announcement_model.dart` |
| 2 | MODIFY | `lib/models/instructor/announcement_model.dart` |
| 3 | MODIFY | `lib/services/api/communication_service.dart` |
| 4 | MODIFY | `lib/screens/instructor/announcements/announcement_manager_screen.dart` |
| 5 | MODIFY | `lib/widgets/instructor/announcements/announcement_form_dialog.dart` |
| 6 | MODIFY | `lib/widgets/instructor/announcements/announcement_card.dart` |
| 7 | NEW | `lib/screens/ta/announcements/ta_announcement_manager_screen.dart` |
| 8 | NEW | `lib/screens/admin/announcements/admin_announcement_manager_screen.dart` |
| 9 | MODIFY | `lib/config/app_router.dart` |
| 10 | MODIFY | `lib/widgets/ta/dashboard/ta_drawer.dart` |
