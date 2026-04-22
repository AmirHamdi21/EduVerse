# Announcement & Communication API Migration — Tasks

## Phase 1: Model Alignment
- [ ] Update `AnnouncementModel` (materials) — add missing backend fields
- [ ] Update `AnnouncementItem` (instructor) — add `fromApi()` factory + new fields

## Phase 2: Service Fixes
- [ ] Add `deleteAnnouncement()` to `CommunicationService`
- [ ] Add `scheduleAnnouncement()` to `CommunicationService`
- [ ] Fix `pinAnnouncement()` to accept `isPinned` body
- [ ] Update model imports/returns for new `AnnouncementModel` shape

## Phase 3: Instructor Screen API Wiring
- [ ] Wire `_loadAnnouncements()` to `CommunicationService`
- [ ] Wire create/update/delete/publish/pin to real API
- [ ] Update `announcement_form_dialog.dart` — priority, course selection
- [ ] Update `announcement_card.dart` — pin action, priority/course/author display
- [ ] Remove all mock data

## Phase 4: TA Announcement Manager Screen
- [ ] Create `ta_announcement_manager_screen.dart`

## Phase 5: Admin Announcement Manager Screen
- [ ] Create `admin_announcement_manager_screen.dart`

## Phase 6: Router & Drawer Integration
- [ ] Add `/ta/announcements` and `/admin/announcements` routes
- [ ] Add announcements entry to TA drawer

## Verification
- [ ] `flutter analyze` passes
- [ ] App builds successfully
