# EduVerse Admin Role - Button & Action Comparison
## Granular Analysis of Every Interactive Element

---

## 1. Admin Dashboard

### Flutter Dashboard (`admin_dashboard_screen.dart`)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Menu (drawer) | `menu` | Opens drawer | ✅ Works |
| Search | `search` | `/admin/search` | ✅ Works |
| Notifications | `notifications_rounded` | `/admin/notifications` + badge | ✅ Works |
| Profile Avatar | Custom gradient | `/admin/profile` | ✅ Works |
| Pull to Refresh | N/A | Reloads data | ✅ Works |
| **Quick Actions (6):** |
| Add User | `person_add_rounded` | Opens dialog | ✅ Works |
| Add Course | `library_add_rounded` | Opens dialog | ✅ Works |
| Announcement | `campaign_rounded` | Opens dialog | ✅ Works |
| Assign Instructor | `person_pin_rounded` | Opens dialog | ✅ Works |
| View Reports | `analytics_rounded` | `/admin/analytics` | ✅ Works |
| System Settings | `settings_rounded` | `/admin/settings` | ✅ Works |
| **Drawer Items (18):** |
| Dashboard | `dashboard_rounded` | `/admin/dashboard` | ✅ Works |
| User Management | `people_rounded` | `/admin/users` | ✅ Works |
| Role Permissions | `admin_panel_settings_rounded` | `/admin/roles` | ✅ Works |
| Course Management | `school_rounded` | `/admin/courses` | ✅ Works |
| Staff Assignment | `assignment_ind_rounded` | `/admin/staff` | ✅ Works |
| Departments | `business_rounded` | `/admin/departments` | ✅ Works |
| Reports & Analytics | `analytics_rounded` | `/admin/analytics` | ✅ Works |
| Security | `security_rounded` | `/admin/security` | ✅ Works |
| Announcements | `campaign_rounded` | Not implemented | ⚠️ Stub |
| Attendance | `fact_check_rounded` | `/admin/attendance` | ✅ Works |
| Backup Center | `backup_rounded` | `/admin/backup-center` | ✅ Works |
| Payment Management | `payment_rounded` | `/admin/payments` | ✅ Works |
| Audit Compliance | `gavel_rounded` | `/admin/audit` | ✅ Works |
| Integrations | `integration_instructions_rounded` | `/admin/integrations` | ✅ Works |
| AI Insights | `auto_awesome_rounded` | `/admin/ai-insights` | ✅ Works |
| System Health | `speed_rounded` | `/admin/analytics` | ✅ Works |
| Messages | `message_rounded` | `/admin/messages` | ✅ Works |
| Notifications | `notifications_rounded` | `/admin/notifications` | ✅ Works |
| Profile | `person_rounded` | `/admin/profile` | ✅ Works |
| Settings | `settings_rounded` | `/admin/settings` | ✅ Works |
| Theme Toggle | `dark_mode`/`light_mode` | Toggles theme | ✅ Works |
| Logout | `logout_rounded` | `/login` | ✅ Works |
| **AI Alerts:** |
| Review AI Report | Button | Opens modal | ✅ Works |
| View Alert | Tap card | Opens dialog | ✅ Works |
| Resolve Alert | Button | Marks resolved | ✅ Works |
| Dismiss Alert | Button | Closes | ✅ Works |
| **Recent Activity:** |
| View All | Text button | Opens modal | ✅ Works |

### React Dashboard (`DashboardOverview.tsx`)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Manage Users | `Users` | `onNavigate('users')` | ✅ Works |
| Send Broadcast | `AlertCircle` | `onNavigate('communication')` | ✅ Works |

**Missing in React:** 14 actions from Flutter

---

## 2. User Management

### Flutter User Management

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Search | `search` | Real-time filter | ✅ Works |
| Clear Search | `clear` | Clears text | ✅ Works |
| Sort Menu | `sort` | Dropdown with 4 options | ✅ Works |
| Sort by Name | `person_outline` | Sets sort | ✅ Works |
| Sort by Email | `email_outlined` | Sets sort | ✅ Works |
| Sort by Date | `calendar_today` | Sets sort | ✅ Works |
| Sort by Role | `badge_outlined` | Sets sort | ✅ Works |
| Tab: All | N/A | Filters all | ✅ Works |
| Tab: Students | N/A | Filters students | ✅ Works |
| Tab: Instructors | N/A | Filters instructors | ✅ Works |
| Tab: TAs | N/A | Filters TAs | ✅ Works |
| Tab: Admins | N/A | Filters admins | ✅ Works |
| Select All Checkbox | `checkbox` | Bulk selection | ✅ Works |
| Select Row Checkbox | `checkbox` | Row selection | ✅ Works |
| View Details | `visibility` | Bottom sheet | ✅ Works |
| Edit User | `edit_outlined` | `/admin/users/edit/{id}` | ✅ Works |
| Reset Password | `lock_reset` | Confirmation dialog | ✅ Works |
| Delete User | `delete_outline` | Confirmation dialog | ✅ Works |
| Add User | FAB | `/admin/users/add` | ✅ Works |
| **Filters:** |
| Role Dropdown | `arrow_drop_down` | Filters by role | ✅ Works |
| Status Dropdown | `arrow_drop_down` | Filters by status | ✅ Works |
| Most Inactive Toggle | `access_time` | Toggles chip | ✅ Works |
| **AI Alerts:** |
| Review All Alerts | Button | Navigate | ✅ Works |
| Review | Button | View alert | ✅ Works |
| Investigate | Button | View alert | ✅ Works |
| Send Reminder | Button | Send notification | ✅ Works |

### React User Management

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Add User | `UserPlus` | `setShowAddModal(true)` | ✅ Works |
| Edit User | `Edit2` | `setEditingUser(user)` | ✅ Works |
| Delete User | `Trash2` | `onDeleteUser(user.id)` | ⚠️ No confirm |
| Send Email | `Mail` | No handler | ❌ Not working |
| Manage Permissions | `Shield` | No handler | ❌ Not working |
| Search | Input | Filters users | ✅ Works |
| Role Filter | Dropdown | Filters by role | ✅ Works |
| Status Filter | Dropdown | Filters by status | ✅ Works |
| Export | `Download` | No handler | ❌ Not working |
| Modal: Cancel | Button | Closes modal | ✅ Works |
| Modal: Save/Add | Button | Callback to parent | ✅ Works |

**Missing in React:** Sort, Bulk select, Tabs, View details, Reset password, AI alerts

---

## 3. Course Management

### Flutter Course Management

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Search | `search` | Real-time filter | ✅ Works |
| Sort Menu | `sort` | 4 sort options | ✅ Works |
| Department Filter | Dropdown | Dynamic filter | ✅ Works |
| **Filter Chips (7):** |
| All Courses | N/A | Shows all | ✅ Works |
| Active | N/A | Filters active | ✅ Works |
| Inactive | N/A | Filters inactive | ✅ Works |
| Needs Instructor | N/A | Filters unassigned | ✅ Works |
| Needs TA | N/A | Filters no TA | ✅ Works |
| AI Flagged | `auto_awesome` | Filters warnings | ✅ Works |
| Lab Based | `science` | Filters with labs | ✅ Works |
| Add Course | FAB | `/admin/courses/add` | ✅ Works |
| **Course Card Actions:** |
| Edit | `edit_outlined` | Opens dialog | ✅ Works |
| Assign Staff | `person_add` | Opens sheet | ✅ Works |
| View Labs | `science` | SnackBar | ✅ Works |
| **Add Course Screen:** |
| Back | `arrow_back_ios_rounded` | Pop with unsaved warning | ✅ Works |
| Reset | `refresh` | Clears form | ✅ Works |
| Previous Step | Button | Step back | ✅ Works |
| Next Step | Button | Step forward | ✅ Works |
| Submit | Button | Creates course | ✅ Works |
| Upload Syllabus | `upload` | Sets filename | ✅ Works |
| Instructor Dropdown | `arrow_drop_down` | Selects instructor | ✅ Works |
| TA Chips | `check_circle` | Multi-select | ✅ Works |
| Capacity Slider | `+`/`-` | Adjusts value | ✅ Works |
| Lab Toggle | Switch | Enables labs | ✅ Works |
| Lab Count Buttons | `1`-`4` | Sets lab count | ✅ Works |
| Status Toggle | Switch | Active/Inactive | ✅ Works |

### React Course Management

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Add Course | `Plus` | `setShowAddModal(true)` | ✅ Works |
| Edit Course | `Edit2` | `setEditingCourse(course)` | ✅ Works |
| Delete Course | `Trash2` | `onDeleteCourse(id)` | ⚠️ No confirm |
| Search | Input | Filters courses | ✅ Works |
| Department Filter | Dropdown | Filters by dept | ✅ Works |
| Status Filter | Dropdown | Filters by status | ✅ Works |
| Export | `Download` | No handler | ❌ Not working |
| Modal: Cancel | Button | Closes modal | ✅ Works |
| Modal: Save/Add | Button | Callback | ✅ Works |

**Missing in React:** Sort, Filter chips, Multi-step creation, Staff assignment, AI preview, Lab management

---

## 4. Department Management

### Flutter Department Management

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Add | `add` | Opens dialog | ✅ Works |
| Settings | `settings` | Navigate | ✅ Works |
| Search | `search` | Filters depts | ✅ Works |
| Faculty Filter | Dropdown | Filters by faculty | ✅ Works |
| View Toggle | `view_list`/`grid_view`/`map` | Changes view | ✅ Works |
| **Filter Chips (5):** |
| All Departments | N/A | Shows all | ✅ Works |
| Understaffed | N/A | <6 TAs | ✅ Works |
| Missing Courses | N/A | <10 courses | ✅ Works |
| No Head | N/A | Missing head | ✅ Works |
| AI Warnings | `auto_awesome` | Has warnings | ✅ Works |
| **Card Actions:** |
| Expand/Collapse | Chevron | Toggle details | ✅ Works |
| Edit | Button | SnackBar stub | ⚠️ Stub |
| View Details | Button | Opens dialog | ✅ Works |
| Assign Head | Button | SnackBar stub | ⚠️ Stub |
| Assign TAs | Button | SnackBar stub | ⚠️ Stub |

### React Department Management

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Add Department | `Plus` | `setShowAddModal(true)` | ✅ Works |
| Edit | `Edit2` | `setEditingDepartment(dept)` | ✅ Works |
| Delete | `Trash2` | `onDeleteDepartment(id)` | ✅ Works |
| Search | Input | Filters depts | ✅ Works |
| Faculty Filter | Dropdown | Filters by faculty | ✅ Works |
| Export | `Download` | No handler | ❌ Not working |
| Modal: Cancel | Button | Closes modal | ✅ Works |
| Modal: Save/Add | Button | Callback | ✅ Works |

**Missing in React:** View modes, Filter chips, AI warnings, Health map, Assign actions

---

## 5. Staff Assignment (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Department Filter | Dropdown | Filters courses | ✅ Works |
| View Toggle | `grid_view`/`list` | Changes view | ✅ Works |
| **Filter Chips (6):** |
| All Courses | N/A | Shows all | ✅ Works |
| Needs Instructor | N/A | Missing instructor | ✅ Works |
| Needs TA | N/A | Missing TA | ✅ Works |
| Instructor Overloaded | N/A | >100% workload | ✅ Works |
| TA Overloaded | N/A | >100% workload | ✅ Works |
| AI Suggestions | `auto_awesome` | Has suggestions | ✅ Works |
| **Course Card:** |
| Assign Instructor | Tap instructor area | Opens sheet | ✅ Works |
| Assign TA | Tap TA area | Opens sheet | ✅ Works |
| **Staff Panel:** |
| View Details | Tap staff | Opens modal | ✅ Works |
| **AI Suggestions:** |
| Apply | Button | Applies suggestion | ✅ Works |
| Dismiss | Button | Removes suggestion | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE**

---

## 6. Role Management (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | With unsaved warning | ✅ Works |
| **Role Chips:** |
| Student | Chip | Selects role | ✅ Works |
| Instructor | Chip | Selects role | ✅ Works |
| TA | Chip | Selects role | ✅ Works |
| Admin | Chip | Selects role | ✅ Works |
| Add Custom Role | `add` chip | Opens dialog | ✅ Works |
| **Permission Toggles (32):** |
| View/Create/Edit/Delete per module | Switch | Toggles permission | ✅ Works |
| Save Changes | Button | Saves permissions | ✅ Works |
| Discard | Button | Reverts changes | ✅ Works |
| **AI Recommendations:** |
| Apply | Button | Applies suggestion | ✅ Works |
| Dismiss | Button | Removes | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE**

---

## 7. Attendance Management (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| QR Scanner | `qr_code_scanner` | SnackBar stub | ⚠️ Stub |
| Export | `download` | Opens menu | ✅ Works |
| **Export Options:** |
| PDF Report | Item | Export stub | ⚠️ Stub |
| Excel/CSV | Item | Export stub | ⚠️ Stub |
| Email Report | Item | Email stub | ⚠️ Stub |
| Print | Item | Print stub | ⚠️ Stub |
| **Tabs:** |
| Courses | Tab | Shows courses | ✅ Works |
| Students | Tab | Shows students | ✅ Works |
| Analytics | Tab | Shows analytics | ✅ Works |
| **Filters:** |
| Department | Dropdown | Filters data | ✅ Works |
| Status Chips | Filter chips | Filters by status | ✅ Works |
| Search | Input | Searches | ✅ Works |
| Clear Filters | Button | Resets filters | ✅ Works |
| **Stats Card:** |
| Refresh | `refresh` | Reloads data | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE**

---

## 8. Analytics/Reports

### Flutter Analytics

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Export | `download` | Export action | ✅ Works |
| Refresh | `refresh` | Reloads data | ✅ Works |
| **Time Filters:** |
| Today | Chip | Sets period | ✅ Works |
| This Week | Chip | Sets period | ✅ Works |
| This Month | Chip | Sets period | ✅ Works |
| Custom | Chip | Opens picker | ✅ Works |
| **AI Insights:** |
| View Analysis | Button | Opens details | ✅ Works |

### React Analytics

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Date Range | Dropdown | Changes period | ✅ Works |
| Export PDF | Button | Export action | ⚠️ UI only |
| Export Excel | Button | Export action | ⚠️ UI only |
| **Report Tabs:** |
| User Analytics | Tab | Shows users | ✅ Works |
| Course Analytics | Tab | Shows courses | ✅ Works |
| Engagement | Tab | Shows engagement | ✅ Works |
| AI Usage | Tab | Shows AI stats | ✅ Works |

**Differences:** Flutter has AI recommendations, React has more chart tabs

---

## 9. Security & Activity Logs (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Settings | `settings` | Navigate | ✅ Works |
| Export | `download` | Export logs | ✅ Works |
| **Tabs:** |
| Overview | Tab | Shows overview | ✅ Works |
| Access Controls | Tab | Shows toggles | ✅ Works |
| Activity Logs | Tab | Shows logs | ✅ Works |
| **Access Toggles:** |
| Two-Factor Auth | Switch | Toggle 2FA | ✅ Works |
| IP Restriction | Switch | Toggle IP | ✅ Works |
| Session Timeout | Switch | Toggle timeout | ✅ Works |
| Login Notifications | Switch | Toggle alerts | ✅ Works |
| **Alerts:** |
| Resolve | Button | Marks resolved | ✅ Works |
| **Sessions:** |
| Terminate | Button | Ends session | ✅ Works |
| Terminate All | Button | Ends all | ✅ Works |
| **IP Management:** |
| Add Whitelist | Button | Adds IP | ✅ Works |
| Add Blacklist | Button | Adds IP | ✅ Works |
| Remove | Button | Removes IP | ✅ Works |
| **Logs:** |
| Search | Input | Filters logs | ✅ Works |
| Filter Activity | Dropdown | By type | ✅ Works |
| Filter Role | Dropdown | By role | ✅ Works |
| Filter Date | Dropdown | By date | ✅ Works |
| Clear Filters | Button | Resets | ✅ Works |
| View Details | Row tap | Opens modal | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE**

---

## 10. Audit & Compliance (Flutter Only - Full)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Tabs:** |
| Overview | Tab | Stats | ✅ Works |
| Audit Logs | Tab | Log list | ✅ Works |
| Compliance | Tab | Items | ✅ Works |
| **Filters:** |
| Severity Chips | Chips | info/warning/critical | ✅ Works |
| Action Type Chips | Chips | login/logout/etc | ✅ Works |
| Date Range | Date picker | Range filter | ✅ Works |
| **Export:** |
| Format Selection | Chips | PDF/CSV/Excel/JSON | ✅ Works |
| Include Details | Switch | Toggle details | ✅ Works |
| Export | Button | Exports data | ✅ Works |
| Schedule Report | Button | Schedules | ✅ Works |
| **Compliance:** |
| Run Check | Button | Runs verification | ✅ Works |
| Load More | Button | Pagination | ✅ Works |
| Clear Filters | Button | Resets filters | ✅ Works |

**React has partial:** Only audit logs table in SystemConfigPage

---

## 11. Backup Center (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Tabs:** |
| Overview | Tab | Status | ✅ Works |
| Backups | Tab | History | ✅ Works |
| Export | Tab | Options | ✅ Works |
| Settings | `settings` | Navigate | ✅ Works |
| **Quick Actions:** |
| Backup Now | Button | Manual backup | ✅ Works |
| Export Data | Button | Goes to tab | ✅ Works |
| Restore | Button | Opens selector | ✅ Works |
| Schedule | Button | View schedule | ✅ Works |
| **Backup Config:** |
| Auto-Backup | Switch | Toggles auto | ✅ Works |
| Frequency | Radio | hourly/daily/weekly/monthly | ✅ Works |
| Retention | Radio | 7/14/30/60/90 days | ✅ Works |
| **Backup Actions:** |
| Restore | Menu item | Restore backup | ✅ Works |
| Download | Menu item | Download file | ✅ Works |
| Delete | Menu item | Delete backup | ✅ Works |
| **Export Options:** |
| Users | Checkbox | Include users | ✅ Works |
| Courses | Checkbox | Include courses | ✅ Works |
| Grades | Checkbox | Include grades | ✅ Works |
| Attendance | Checkbox | Include attendance | ✅ Works |
| Analytics | Checkbox | Include analytics | ✅ Works |
| Format | Chips | CSV/JSON/Excel/PDF | ✅ Works |
| Export | Button | Performs export | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE** (IT Admin has database backup)

---

## 12. Payment Management (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Tabs:** |
| Overview | Tab | Stats | ✅ Works |
| Transactions | Tab | List | ✅ Works |
| Subscriptions | Tab | Plans | ✅ Works |
| Analytics | `analytics` | Navigate | ✅ Works |
| Settings | `settings` | Navigate | ✅ Works |
| **Transaction Filters:** |
| All | Chip | Shows all | ✅ Works |
| Completed | Chip | Completed | ✅ Works |
| Pending | Chip | Pending | ✅ Works |
| Failed | Chip | Failed | ✅ Works |
| Refunded | Chip | Refunded | ✅ Works |
| **Transaction Actions:** |
| View Details | Tap | Opens sheet | ✅ Works |
| Process Refund | Button | Confirmation | ✅ Works |
| **Payment Methods:** |
| Toggle Method | Switch | Enable/disable | ✅ Works |
| Add Method | Button | Opens form | ✅ Works |
| Manage Gateways | Button | Navigate | ✅ Works |
| **Subscription Plans:** |
| Add Plan | Button | Opens form | ✅ Works |
| Edit Plan | Button | Opens form | ✅ Works |
| Toggle Active | Switch | Activate/deactivate | ✅ Works |
| View Subscribers | `chevron_right` | Navigate | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE**

---

## 13. Integrations & API (Flutter vs React Partial)

### Flutter Integrations

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Tabs:** |
| Overview | Tab | Stats | ✅ Works |
| Integrations | Tab | List | ✅ Works |
| API Keys | Tab | Keys | ✅ Works |
| Webhooks | Tab | Hooks | ✅ Works |
| Refresh | `refresh` | Reloads | ✅ Works |
| **Category Filters:** |
| All | Chip | Shows all | ✅ Works |
| LMS | Chip | LMS only | ✅ Works |
| Payment | Chip | Payment | ✅ Works |
| Communication | Chip | Comm | ✅ Works |
| Storage | Chip | Storage | ✅ Works |
| Analytics | Chip | Analytics | ✅ Works |
| **Integration Actions:** |
| Connect/Disconnect | Switch | Toggle | ✅ Works |
| Sync | `refresh` | Syncs data | ✅ Works |
| View Details | Tap | Opens dialog | ✅ Works |
| **API Keys:** |
| Create | Button | Creates key | ✅ Works |
| Edit | Button | Edits key | ✅ Works |
| Revoke | Button | Revokes | ✅ Works |
| Delete | Button | Deletes | ✅ Works |
| Copy | `copy` | Copies key | ✅ Works |
| Toggle Visibility | `visibility` | Shows/hides | ✅ Works |
| **Webhooks:** |
| Create | Button | Creates hook | ✅ Works |
| Edit | Button | Edits | ✅ Works |
| Delete | Button | Deletes | ✅ Works |
| Test | `play` | Tests hook | ✅ Works |
| Toggle Active | Switch | Enable/disable | ✅ Works |

### React Integrations (SystemConfigPage)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Toggle Connected | Switch | Connect/disconnect | ✅ Works |
| Sync Now | `RefreshCw` | Syncs data | ✅ Works |
| Configure | Button | Setup (disconnected) | ✅ Works |

**Missing in React:** API Keys management, Webhooks, Category filters

---

## 14. Communication & Messaging

### Flutter Messages

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Filter Tabs:** |
| All | Tab | All convos | ✅ Works |
| Students | Tab | Students | ✅ Works |
| Instructors | Tab | Instructors | ✅ Works |
| TAs | Tab | TAs | ✅ Works |
| Groups | Tab | Groups | ✅ Works |
| Search | Input | Search convos | ✅ Works |
| Clear Search | `clear` | Clears | ✅ Works |
| **Conversation Actions:** |
| Select Conversation | Tap | Opens chat | ✅ Works |
| Back (mobile) | `arrow_back` | Returns to list | ✅ Works |
| **Chat Header:** |
| Call | `call` | Voice call stub | ⚠️ Stub |
| Video Call | `videocam` | Video call stub | ⚠️ Stub |
| Info | `info` | Conversation info | ✅ Works |
| **Info Actions:** |
| Mute | Item | Mutes convo | ✅ Works |
| Search in Convo | Item | Searches | ✅ Works |
| Archive | Item | Archives | ✅ Works |
| Delete | Item | Deletes | ✅ Works |
| **Message Input:** |
| Type Message | Input | Text entry | ✅ Works |
| Attach | `attach_file` | Attach file | ✅ Works |
| Voice | `mic` | Record voice | ✅ Works |
| Send | `send` | Sends message | ✅ Works |
| **FAB Actions:** |
| New Message | `chat` | New DM | ✅ Works |
| Create Group | `group_add` | New group | ✅ Works |
| Broadcast | `campaign` | Broadcast msg | ✅ Works |

### React Communication

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Section Tabs:** |
| Broadcast | Tab | Send broadcasts | ✅ Works |
| Templates | Tab | Manage templates | ✅ Works |
| **Broadcast Form:** |
| Title | Input | Enter title | ✅ Works |
| Message | Textarea | Enter message | ✅ Works |
| **Audience Buttons:** |
| All Users | Button | Select all | ✅ Works |
| Students Only | Button | Select students | ✅ Works |
| Instructors Only | Button | Select instructors | ✅ Works |
| Admins Only | Button | Select admins | ✅ Works |
| **Channel Toggles:** |
| Push | Toggle | Enable push | ✅ Works |
| Email | Toggle | Enable email | ✅ Works |
| SMS | Toggle | Enable SMS | ✅ Works |
| **Schedule Options:** |
| Send Now | Button | Immediate | ✅ Works |
| Scheduled | Button | Opens picker | ✅ Works |
| DateTime Picker | Inputs | Select date/time | ✅ Works |
| **Actions:** |
| Preview | Button | Opens preview | ✅ Works |
| Send Broadcast | Button | Sends | ✅ Works |
| **Templates:** |
| Create Template | Button | Opens modal | ✅ Works |
| Edit Template | Button | Opens modal | ✅ Works |
| Copy Template | Button | Copies | ✅ Works |
| Delete Template | Button | Deletes | ✅ Works |

**Differences:** Flutter = Direct messaging, React = Broadcast system. Both need the other's features.

---

## 15. Notifications (Flutter Only - Full Screen)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| **Tabs:** |
| Notifications | Tab | All notifs | ✅ Works |
| Announcements | Tab | Announcements | ✅ Works |
| Archived | Tab | Archived | ✅ Works |
| Search Toggle | `search` | Shows search | ✅ Works |
| **Menu Actions:** |
| Swipe Settings | Item | Navigate | ✅ Works |
| Mark All Read | Item | Marks all | ✅ Works |
| Clear All | Item | Confirmation | ✅ Works |
| **Category Filters:** |
| All | Chip | All categories | ✅ Works |
| Users | Chip | User activity | ✅ Works |
| Courses | Chip | Course updates | ✅ Works |
| System | Chip | System alerts | ✅ Works |
| Security | Chip | Security | ✅ Works |
| Announcements | Chip | Announcements | ✅ Works |
| Reports | Chip | Reports | ✅ Works |
| **Notification Actions:** |
| Tap | Opens detail sheet | ✅ Works |
| Swipe Left | Configurable action | ✅ Works |
| Swipe Right | Configurable action | ✅ Works |
| Mark Read/Unread | Menu | Toggles read | ✅ Works |
| Bookmark | Menu | Saves | ✅ Works |
| Archive | Menu | Archives | ✅ Works |
| Delete | Menu | Deletes | ✅ Works |
| **Announcements:** |
| Create (FAB) | `add` | Opens dialog | ✅ Works |
| Pin/Unpin | Button | Toggles pin | ✅ Works |
| Edit | Button | Edit stub | ⚠️ Stub |
| Delete | Button | Confirmation | ✅ Works |
| **Create Announcement:** |
| Title | Input | Enter title | ✅ Works |
| Message | Textarea | Enter message | ✅ Works |
| Target | Dropdown | Select audience | ✅ Works |
| Create | Button | Creates | ✅ Works |
| Cancel | Button | Closes | ✅ Works |

**React:** Only header dropdown with basic notifications

---

## 16. AI Insights (Flutter Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Refresh/Clear | `refresh` | Clears chat | ✅ Works |
| **Mode Selector:** |
| General | Mode pill | Sets mode | ✅ Works |
| Analytics | Mode pill | Sets mode | ✅ Works |
| Reports | Mode pill | Sets mode | ✅ Works |
| System | Mode pill | Sets mode | ✅ Works |
| **Quick Actions:** |
| Generate Report | Chip | Sends prompt | ✅ Works |
| Analyze Data | Chip | Sends prompt | ✅ Works |
| Find Issues | Chip | Sends prompt | ✅ Works |
| Optimize | Chip | Sends prompt | ✅ Works |
| Forecast | Chip | Sends prompt | ✅ Works |
| Daily Summary | Chip | Sends prompt | ✅ Works |
| **Chat:** |
| Send Message | `send` | Sends message | ✅ Works |
| Suggestion Chips | Tap | Uses suggestion | ✅ Works |
| **Recommendations:** |
| Dismiss | Swipe left | Removes | ✅ Works |
| View All | Button | Opens all | ✅ Works |
| Ask Follow-up | Tap | Asks AI | ✅ Works |

**Status:** ❌ **MISSING IN REACT WEBSITE**

---

## 17. Settings (Flutter: 22 screens vs React: 1 combined)

### Flutter Settings Hub Actions

| Setting Screen | Actions Available |
|----------------|-------------------|
| **Semester** | Add/Edit/Delete semesters, Set active |
| **Registration** | Toggle self-register, social login, approval, add email domains |
| **Appearance** | Select theme, accent color, font size, accessibility toggles |
| **Language** | Select EN/AR |
| **Branding** | Pick colors, select presets, reset defaults |
| **Logo Assets** | Upload/delete 6 asset types |
| **Password Policy** | 10+ configurable options |
| **Two-Factor** | Methods, code settings, grace period |
| **Email** | SMTP config, test email |
| **SMS** | Provider, credentials, test SMS |
| **Push** | Provider, event toggles |
| **Webhooks** | CRUD + test |
| **API** | Rate limits, key management |
| **Cloud Storage** | Provider, bucket, test connection |
| **Payment Gateways** | 4 gateways, currencies, test mode |
| **Video Conferencing** | Provider, settings, limits |
| **Backup/Restore** | Schedule, retention |
| **System Updates** | Check for updates, auto-update toggle |
| **Developer** | Debug mode, environment, clear cache |
| **System Logs** | View, filter, export, clear |
| **Blocked Users** | Unblock, delete, view details |

### React Settings (SystemConfigPage)

| Section | Actions Available |
|---------|-------------------|
| **Audit Logs** | Search, filter, export |
| **Gamification** | Toggle points/badges/leaderboards, edit point values, toggle badges |
| **API Integrations** | Toggle connected, sync, configure |

**Gap:** Flutter has 22 screens with 100+ configurable options, React has 1 page with ~15 options

---

## 18. Profile Management

### Flutter Profile

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Back | `arrow_back_ios_rounded` | `context.pop()` | ✅ Works |
| Edit Profile | `edit` | `/admin/edit-profile` | ✅ Works |
| Change Photo | Avatar tap | Opens picker | ✅ Works |
| **Actions Card:** |
| Edit Profile | Item | Navigate | ✅ Works |
| Change Password | Item | Opens dialog | ✅ Works |
| Two-Factor Auth | Item | Opens dialog | ✅ Works |
| Export My Data | Item | Export action | ✅ Works |
| Logout | Item | Confirmation | ✅ Works |
| **Edit Screen:** |
| Save Changes | Button | Saves | ✅ Works |
| Discard | Dialog | Discards | ✅ Works |
| **Change Password Dialog:** |
| Current Password | Input | Enters current | ✅ Works |
| New Password | Input | Enters new | ✅ Works |
| Confirm Password | Input | Confirms | ✅ Works |
| Cancel | Button | Closes | ✅ Works |
| Change | Button | Changes pwd | ✅ Works |
| **2FA Dialog:** |
| Enable/Disable | Button | Toggles 2FA | ✅ Works |
| **Preferences:** |
| Language | Dropdown | EN/AR | ✅ Works |
| Timezone | Dropdown | Select TZ | ✅ Works |

### React Profile (Tab)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Edit Profile | Inline | Edits fields | ✅ Works |

**Missing in React:** Change password, 2FA settings, Export data, Activity timeline, Stats card

---

## 19. Academic Calendar (React Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Add Event | `Plus` | Opens modal | ✅ Works |
| **View Toggle:** |
| Month View | Button | Shows calendar | ✅ Works |
| List View | Button | Shows list | ✅ Works |
| **Navigation:** |
| Previous Month | `ChevronLeft` | Goes back | ✅ Works |
| Next Month | `ChevronRight` | Goes forward | ✅ Works |
| **Event Actions:** |
| Edit | `Edit2` | Opens modal | ✅ Works |
| Delete | `Trash2` | Deletes event | ✅ Works |
| **Event Form:** |
| Title | Input | Event title | ✅ Works |
| Start Date | Input | Start date | ✅ Works |
| End Date | Input | End date | ✅ Works |
| Type | Select | Event type | ✅ Works |
| Cancel | Button | Closes | ✅ Works |
| Save | Button | Saves event | ✅ Works |
| **List Filter:** |
| Event Type | Dropdown | Filters events | ✅ Works |

**Status:** ❌ **MISSING IN FLUTTER**

---

## 20. Feedback/Support (React Only)

| Button/Action | Icon | Handler | Status |
|---------------|------|---------|--------|
| Search | Input | Searches tickets | ✅ Works |
| Status Filter | Dropdown | Filters by status | ✅ Works |
| Priority Filter | Dropdown | Filters by priority | ✅ Works |
| View Ticket | Row click | Opens modal | ✅ Works |
| **Ticket Modal:** |
| Update Status | Buttons | Changes status | ✅ Works |
| Reply | Textarea | Enter reply | ✅ Works |
| Send Reply | Button | Sends | ✅ Works |
| Close | Button | Closes modal | ✅ Works |

**Status:** ❌ **MISSING IN FLUTTER**

---

## Summary: Button Count Comparison

| Screen | Flutter Buttons | React Buttons | Difference |
|--------|:---------------:|:-------------:|:----------:|
| Dashboard | 35+ | 4 | +31 Flutter |
| User Management | 25+ | 12 | +13 Flutter |
| Course Management | 30+ | 10 | +20 Flutter |
| Department Management | 18+ | 8 | +10 Flutter |
| Staff Assignment | 20+ | 0 | +20 Flutter |
| Role Management | 40+ | 0 | +40 Flutter |
| Attendance | 25+ | 0 | +25 Flutter |
| Analytics | 12+ | 8 | +4 Flutter |
| Security | 35+ | 0 | +35 Flutter |
| Audit | 20+ | 5 | +15 Flutter |
| Backup | 25+ | 0 | +25 Flutter |
| Payments | 30+ | 0 | +30 Flutter |
| Integrations | 25+ | 4 | +21 Flutter |
| Messages | 25+ | 20+ | +5 Flutter |
| Notifications | 30+ | 0 | +30 Flutter |
| AI Insights | 18+ | 0 | +18 Flutter |
| Settings | 200+ | 15 | +185 Flutter |
| Search | 15+ | 1 | +14 Flutter |
| Profile | 20+ | 2 | +18 Flutter |
| Calendar | 0 | 15+ | +15 React |
| Feedback | 0 | 10+ | +10 React |
| **TOTAL** | **650+** | **~115** | **+535 Flutter** |

---

*Last Updated: February 24, 2026*
