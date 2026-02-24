# EduVerse Instructor - Button & Action Comparison

## Detailed Button/Action Analysis per Screen

This document provides a granular comparison of all buttons, actions, and interactive elements in each instructor screen between Flutter Mobile App and React Website.

---

## 1. Dashboard Screen

### App Bar / Header

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Menu/Hamburger Button | ✅ Opens drawer | ❌ No drawer | Different nav |
| Search Button | ✅ → /instructor/search | ✅ In header | ✅ Both |
| Notification Bell | ✅ Badge + → /instructor/notifications | ✅ Dropdown | Different UX |
| Profile Avatar | ✅ → /instructor/profile | ✅ Dropdown menu | ✅ Both |
| Theme Toggle | ✅ In drawer | ✅ In header | ✅ Both |
| Language Toggle | ❌ | ✅ In header | Add to Flutter |

### Dashboard Cards/Sections

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| AI Teaching Card - "Review Insights" | ❌ | ✅ → AI page | Add to Flutter |
| AI Teaching Card - "Dismiss" | ❌ | ✅ Hides card | Add to Flutter |
| Stat Card - Active Courses | ❌ | ✅ Display only | Add to Flutter |
| Stat Card - Pending Grading | ❌ | ✅ Display only | Add to Flutter |
| Stat Card - Total Students | ❌ | ✅ Display only | Add to Flutter |

### Quick Actions

| Action Button | Flutter | React | Status |
|---------------|---------|-------|--------|
| My Courses | ✅ → /instructor/courses | ❌ | Different |
| Create Assignment | ✅ → /instructor/create-assignment | ❌ | Different |
| Grading Center | ✅ → /instructor/grading | ❌ | Different |
| Upload Material | ✅ → /instructor/upload-materials | ❌ | Flutter only |
| Analytics | ✅ → /instructor/reports | ❌ | Different |
| AI Assistant | ✅ → /ai-chat | ❌ | Different |
| Office Hours | ❌ | ✅ → calendar | Add to Flutter |
| Materials | ❌ | ✅ → courses | Different |
| Add Task | ❌ | ✅ → grades | Add to Flutter |
| Help Desk | ❌ | ✅ → messages | Add to Flutter |

### Course Section

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| View All Courses | ✅ → /instructor/courses | ❌ | Add to Website |
| Course Card Click | ✅ → /instructor/course-management | ✅ → courses tab | ✅ Both |
| Manage Button | ✅ → course management | ❌ | Add to Website |
| Materials Button | ✅ Opens bottom sheet | ❌ | Add to Website |
| More Menu (⋯) | ✅ Popup menu | ❌ | Add to Website |

### Pending Grading Section

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| View All | ✅ → /instructor/grading | ❌ | Add to Website |
| Grade Now Button | ✅ Opens grade dialog | ❌ | Add to Website |

### Upcoming Events Section

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| View Full Calendar | ✅ → /instructor/calendar | ❌ | Add to Website |
| Event Item Click | ❌ | ❌ | Neither has |

---

## 2. Courses List Screen

### Header Actions

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Back Button | ✅ | ❌ Tab-based | Different nav |
| View Toggle - Grid | ✅ | ❌ Fixed grid | Add to Website |
| View Toggle - List | ✅ | ❌ | Add to Website |
| View Toggle - Compact | ✅ | ❌ | Add to Website |
| Selection Mode Toggle | ✅ | ❌ | Add to Website |
| Create Course FAB | ✅ Opens modal | ✅ Opens modal | ✅ Both |

### Search & Filter Bar

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Search Input | ✅ Name/Code/Desc | ✅ Name/Code | ✅ Both |
| Clear Search (X) | ✅ | ✅ | ✅ Both |
| Status Filter | ✅ Dropdown (4 options) | ✅ Dropdown (3 options) | ⚠️ Different |
| Category Filter | ✅ Dropdown (6 options) | ❌ | Add to Website |
| Semester Filter | ❌ | ✅ Dynamic | Add to Flutter |
| Sort Dropdown | ✅ 7 options | ✅ 3 options | Flutter more |

### Course Card Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Card Tap | ✅ → course management | ✅ → course detail | ✅ Both |
| Long Press | ✅ Preview modal | ❌ | Add to Website |
| Manage Button | ✅ → course management | ❌ | Add to Website |
| Materials Button | ✅ Shows materials | ❌ | Add to Website |
| Edit Button | ✅ Opens modal | ✅ Opens modal | ✅ Both |
| Analytics Button | ✅ Placeholder | ❌ | Add to Website |
| Duplicate Button | ✅ Duplicates course | ❌ | Add to Website |
| Share Button | ✅ Copies link | ❌ | Add to Website |
| Delete Button | ✅ Confirmation dialog | ✅ Confirmation | ✅ Both |
| Selection Checkbox | ✅ In selection mode | ❌ | Add to Website |
| Open Course Button | ❌ | ✅ → course detail | Add to Flutter |

### Bulk Actions Bar

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Archive Selected | ✅ | ❌ | Add to Website |
| Publish Selected | ✅ | ❌ | Add to Website |
| Delete Selected | ✅ | ❌ | Add to Website |

### AI Sidebar (Website Only)

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Create Quiz | ❌ | ✅ | Different approach |
| Analyze Course | ❌ | ✅ | Different approach |

---

## 3. Course Management/Detail Screen

### Tab Navigation

| Tab | Flutter | React | Status |
|-----|---------|-------|--------|
| Overview | ✅ | ✅ | ✅ Both |
| Assignments | ✅ | ✅ | ✅ Both |
| Materials | ✅ | ✅ | ✅ Both |
| Students | ✅ | ✅ | ✅ Both |
| Lectures | ❌ | ✅ | Add to Flutter |
| Grading | ❌ | ✅ | Add to Flutter |
| Registration Period | ❌ | ✅ | Add to Flutter |
| Settings | ❌ | ✅ | Add to Flutter |
| Analytics | ❌ | ✅ | Add to Flutter |
| Announcements | ❌ | ✅ | Add to Flutter |
| AI Tools | ❌ | ✅ | Add to Flutter |

### FAB / Add Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| FAB → Create Assignment | ✅ | ❌ In tab | Different |
| FAB → Upload Material | ✅ | ❌ In tab | Different |
| FAB → Post Announcement | ✅ | ❌ In tab | Different |
| Create Assignment Button | ❌ In FAB | ✅ In Assignments tab | ✅ Both |
| New Announcement Button | ❌ In FAB | ✅ In Announcements tab | ✅ Both |

### Settings Modal

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Edit Course | ✅ | ❌ In tab | Different |
| Archive Course | ✅ | ❌ | Add to Website |
| Delete Course | ✅ | ❌ | Add to Website |

### Assignments Tab Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| View Submissions | ❌ | ✅ | Add to Flutter |
| Edit Assignment | ❌ | ✅ | Add to Flutter |
| Grade Manually | ❌ | ✅ | Add to Flutter |
| AI Auto-Grading | ❌ | ✅ | Add to Flutter |
| Publish (Draft) | ❌ | ✅ | Add to Flutter |

---

## 4. Grading Center Screen

### Header Actions

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Back Button | ✅ | ❌ | Different nav |
| Refresh Button | ✅ | ❌ | Add to Website |

### Filter Actions

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Search Input | ✅ Student/Assignment | ✅ Name/Email/Assignment | ✅ Both |
| Course Filter | ✅ Dropdown | ❌ | Add to Website |
| All Tab | ✅ | ❌ | Add to Website |
| Pending Tab | ✅ | ❌ | Add to Website |
| Graded Tab | ✅ | ❌ | Add to Website |
| Late Tab | ✅ | ❌ | Add to Website |
| Sort by Student | ❌ | ✅ | Add to Flutter |
| Sort by Assignment | ❌ | ✅ | Add to Flutter |
| Sort by Score | ❌ | ✅ | Add to Flutter |

### Stats Dashboard

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Pending Stat Tap | ✅ → Pending tab | ❌ | Add to Website |
| Graded Stat Tap | ✅ → Graded tab | ❌ | Add to Website |
| Late Stat Tap | ✅ → Late tab | ❌ | Add to Website |

### Submission Card Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| View Details | ✅ Placeholder | ❌ | Both incomplete |
| Grade Now | ✅ → Grade dialog | ❌ In table row | Different |
| Edit Grade | ✅ → Grade dialog | ✅ → Modal | ✅ Both |
| Delete | ❌ | ✅ | Add to Flutter |

### Grade Dialog

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Grade Input | ✅ 0-100 | ✅ 0-100 | ✅ Both |
| Quick Grade - 100% | ✅ | ❌ | Add to Website |
| Quick Grade - 90% | ✅ | ❌ | Add to Website |
| Quick Grade - 80% | ✅ | ❌ | Add to Website |
| Quick Grade - 70% | ✅ | ❌ | Add to Website |
| Quick Grade - 60% | ✅ | ❌ | Add to Website |
| Quick Grade - 50% | ✅ | ❌ | Add to Website |
| Feedback Textarea | ✅ | ❌ | Add to Website |
| Submit Button | ✅ | ✅ Save Changes | ✅ Both |
| Cancel Button | ❌ Tap outside | ✅ | Add to Flutter |

### Auto-Grading System (Website Only)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Auto-Grade All | ❌ | ✅ | Add to Flutter |
| Expand Answer | ❌ | ✅ | Add to Flutter |
| Edit Score | ❌ | ✅ | Add to Flutter |
| Edit Feedback | ❌ | ✅ | Add to Flutter |
| Finalize Grade | ❌ | ✅ | Add to Flutter |

---

## 5. Attendance Manager Screen

### Header Actions

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Back Button | ✅ | ❌ | Different nav |
| Refresh Button | ✅ | ❌ | Add to Website |

### Selector Actions

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Course Dropdown | ✅ | ❌ | Add to Website |
| Week Dropdown | ✅ | ❌ | Add to Website |

### Quick Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| All Present | ✅ | ❌ | Add to Website |
| All Absent | ✅ | ❌ | Add to Website |
| Clear All | ✅ | ❌ | Add to Website |
| QR Scan | ✅ Placeholder | ❌ | Complete Flutter, Add to Website |

### Filter Chips

| Chip | Flutter | React | Status |
|------|---------|-------|--------|
| All | ✅ | ❌ | Add to Website |
| Unmarked | ✅ | ❌ | Add to Website |
| Present | ✅ | ❌ | Add to Website |
| Absent | ✅ | ❌ | Add to Website |

### Student Card Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Mark Present | ✅ | ❌ | Add to Website |
| Mark Late | ✅ | ❌ | Add to Website |
| Mark Absent | ✅ | ❌ | Add to Website |
| Edit Note | ✅ | ❌ | Add to Website |
| Card Tap | ✅ → Detail sheet | ❌ | Add to Website |

### Bottom Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Export Attendance | ✅ Bottom sheet | ❌ | Add to Website |
| Export as PDF | ✅ | ❌ | Add to Website |
| Export as Excel | ✅ | ❌ | Add to Website |
| Share Report | ✅ | ❌ | Add to Website |
| Notify Students | ✅ Dialog | ❌ | Add to Website |
| Notify Absent | ✅ | ❌ | Add to Website |
| Notify Low Attendance | ✅ | ❌ | Add to Website |
| Notify All | ✅ | ❌ | Add to Website |
| Save Attendance | ✅ | ❌ | Add to Website |

### Student Detail Sheet

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Close Button | ✅ | ❌ | Add to Website |
| Add Note Input | ✅ | ❌ | Add to Website |
| Save Note Button | ✅ | ❌ | Add to Website |

### AI Attendance (Website Only)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Upload Photo | ❌ | ✅ | Add to Flutter |
| Process with AI | ❌ | ✅ | Add to Flutter |
| Mark as Present | ❌ | ✅ Edit mode | Add to Flutter |
| Mark as Absent | ❌ | ✅ Edit mode | Add to Flutter |
| Export CSV | ❌ | ✅ | Add to Flutter |
| Save Results | ❌ | ✅ | Add to Flutter |
| View History | ❌ | ✅ | Add to Flutter |
| View Details (History) | ❌ | ✅ | Add to Flutter |

### Attendance Table (Website)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Add Record | ❌ | ✅ | Add to Flutter |
| Edit Record | ❌ | ✅ | Add to Flutter |
| Delete Record | ❌ | ✅ | Add to Flutter |
| Search by Date | ❌ | ✅ | Add to Flutter |

---

## 6. Create Assignment Screen

### Type Selection

| Type | Flutter | React | Status |
|------|---------|-------|--------|
| Assignment | ✅ | ✅ Default | ✅ Both |
| Lab | ✅ | ❌ Separate page | Different |
| Project | ✅ | ❌ | Add to Website |

### Section Collapse/Expand

| Section | Flutter | React | Status |
|---------|---------|-------|--------|
| Basic Details | ✅ Collapsible | ❌ | Different |
| Instructions | ✅ Collapsible | ❌ | Different |
| Questions | ✅ Collapsible | ❌ | Different |
| Attachments | ✅ Collapsible | ❌ | Different |
| Deadline Settings | ✅ Collapsible | ❌ | Different |
| Lab Details | ✅ Collapsible | ❌ | Different |
| Project Details | ✅ Collapsible | ❌ | Different |

### Form Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Save Draft | ✅ | ❌ Status=Draft | Different |
| Preview | ✅ Bottom sheet | ❌ | Add to Website |
| Schedule | ✅ Dialog | ❌ | Add to Website |
| Assign to Class | ✅ | ✅ Create | ✅ Both |

### Questions Section

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Add Question | ✅ | ❌ | Add to Website |
| Edit Question | ✅ | ❌ | Add to Website |
| Delete Question | ✅ | ❌ | Add to Website |
| AI Generate | ✅ Placeholder | ❌ | Add to Website |
| Add Hint | ✅ | ❌ | Add to Website |
| Change Type | ✅ Dropdown | ❌ | Add to Website |
| Set Points | ✅ | ❌ | Add to Website |

### Attachments Section

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Drop Zone | ✅ | ✅ In course detail | Different |
| Choose Files | ✅ | ❌ | Different |
| Remove Attachment | ✅ | ❌ | Add to Website |

### Lab-Specific

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Lab Room Dropdown | ✅ | ❌ | Different approach |
| Duration +/- | ✅ | ❌ | Different approach |
| Lab Coat Checkbox | ✅ | ❌ | Different approach |
| Safety Glasses | ✅ | ❌ | Different approach |
| Gloves | ✅ | ❌ | Different approach |
| Require Lab Report | ✅ | ❌ | Different approach |

### Project-Specific

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Min Team Size +/- | ✅ | ❌ | Add to Website |
| Max Team Size +/- | ✅ | ❌ | Add to Website |
| Allow Individual | ✅ | ❌ | Add to Website |
| Add Milestone | ✅ | ❌ | Add to Website |
| Edit Milestone | ✅ Dialog | ❌ | Add to Website |
| Remove Milestone | ✅ | ❌ | Add to Website |
| Toggle Deliverable | ✅ | ❌ | Add to Website |
| Require Presentation | ✅ | ❌ | Add to Website |
| Require Documentation | ✅ | ❌ | Add to Website |
| Peer Review | ✅ | ❌ | Add to Website |

---

## 7. AI Features

### AI Teaching Screen (Flutter)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Mode Selector | ✅ 5 modes | ❌ | Add to Website |
| Quick Action 1: Generate MCQs | ✅ | ❌ | Different |
| Quick Action 2: Summarize | ✅ | ❌ | Different |
| Quick Action 3: Lesson Plan | ✅ | ❌ | Different |
| Quick Action 4: Rubric | ✅ | ❌ | Different |
| Quick Action 5: Feedback | ✅ | ❌ | Different |
| Send Message | ✅ | ✅ | ✅ Both |
| Regenerate Response | ✅ | ❌ | Add to Website |
| Make Easier | ✅ | ❌ | Add to Website |
| Make Harder | ✅ | ❌ | Add to Website |
| Copy Response | ✅ | ✅ | ✅ Both |
| Export Response | ✅ 3 formats | ❌ | Add to Website |
| Attach Document | ✅ | ❌ | Add to Website |
| Attach Image | ✅ | ❌ | Add to Website |
| Attach Spreadsheet | ✅ | ❌ | Add to Website |
| Clear Chat | ✅ | ✅ | ✅ Both |
| History Button | ✅ | ❌ | Add to Website |

### AI Tools Page (Website)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Quiz Difficulty Select | ❌ | ✅ 3 levels | Add to Flutter |
| Generate Quiz | ✅ Separate screen | ✅ | ✅ Both |
| Upload Lecture File | ❌ | ✅ | Add to Flutter |
| Auto-Grade All | ❌ | ✅ | Add to Flutter |
| Generate Feedback | ❌ | ✅ | Add to Flutter |
| Analyze Submissions | ❌ | ✅ | Add to Flutter |
| Topic Input | ❌ | ✅ | Add to Flutter |
| Upload Material | ❌ | ✅ | Add to Flutter |
| Generate Slides | ❌ | ✅ | Add to Flutter |
| Generate Summary | ❌ | ✅ | Add to Flutter |
| View Insights Details | ❌ | ✅ | Add to Flutter |
| Send Tips | ❌ | ✅ | Add to Flutter |
| Voice to Text | ❌ | ✅ | Add to Flutter |
| Image to Text | ❌ | ✅ | Add to Flutter |
| Generate Teaching Plan | ❌ | ✅ | Add to Flutter |
| Open AI Chatbot | ❌ | ✅ Floating button | Different approach |
| Thumbs Up/Down | ❌ | ✅ | Add to Flutter |
| Minimize/Maximize | ❌ | ✅ | N/A (mobile) |

### AI Question Editor (Website)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Add Question | ❌ | ✅ | Add to Flutter |
| Edit Question | ❌ | ✅ | Add to Flutter |
| Delete Question | ❌ | ✅ | Add to Flutter |
| Reorder (Drag) | ❌ | ✅ | Add to Flutter |
| Move Up/Down | ❌ | ✅ Chevrons | Add to Flutter |
| Generate More | ❌ | ✅ | Add to Flutter |
| Add Option (MC) | ❌ | ✅ | Add to Flutter |
| Select Correct Answer | ❌ | ✅ | Add to Flutter |
| Change Difficulty | ❌ | ✅ Dropdown | Add to Flutter |
| Change Type | ❌ | ✅ Dropdown | Add to Flutter |
| Set Points | ❌ | ✅ Input | Add to Flutter |
| Add Explanation | ❌ | ✅ | Add to Flutter |

---

## 8. Calendar/Schedule Screen

### View Toggles

| View | Flutter | React | Status |
|------|---------|-------|--------|
| Month View | ✅ | ⚠️ Button only | Implement in Website |
| Week View | ✅ | ✅ | ✅ Both |
| Day View | ✅ | ⚠️ Button only | Implement in Website |

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Add Event (Header) | ✅ | ❌ | Add to Website |
| Filter Dropdown | ✅ | ✅ | ✅ Both |
| Today Button | ❌ | ✅ | Add to Flutter |
| Detect Conflicts | ❌ | ✅ AI | Add to Flutter |
| Optimize Schedule | ❌ | ✅ AI | Add to Flutter |

### Calendar Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Select Date | ✅ | ✅ | ✅ Both |
| Double-tap Date | ✅ → Add event | ❌ | Add to Website |
| Event Click | ✅ → Details sheet | ✅ Hover info | Different |
| Add Event FAB | ✅ | ❌ | Add to Website |

### Event Sheet Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| View Details | ✅ | ❌ | Add to Website |
| Edit Event | ✅ | ❌ | Add to Website |
| Delete Event | ✅ | ❌ | Add to Website |

### Add Event Sheet

| Field | Flutter | React | Status |
|-------|---------|-------|--------|
| Event Title | ✅ | ❌ | Add to Website |
| Event Type | ✅ | ❌ | Add to Website |
| Date Picker | ✅ | ❌ | Add to Website |
| Time Picker | ✅ | ❌ | Add to Website |
| End Time | ✅ | ❌ | Add to Website |
| Location | ✅ | ❌ | Add to Website |
| Notes | ✅ | ❌ | Add to Website |
| Save Button | ✅ | ❌ | Add to Website |

---

## 9. Chat/Messages Screen

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| New Chat Button | ✅ | ❌ | Add to Website |
| Search Toggle | ✅ | ✅ | ✅ Both |

### Filter Chips

| Chip | Flutter | React | Status |
|------|---------|-------|--------|
| All | ✅ | ❌ | Add to Website |
| Students | ✅ | ❌ | Add to Website |
| Colleagues | ✅ | ❌ | Add to Website |
| Groups | ✅ | ❌ | Add to Website |

### Conversation Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Select Conversation | ✅ | ✅ | ✅ Both |
| Long Press Menu | ✅ | ❌ | Add to Website |
| Pin Conversation | ✅ | ❌ | Add to Website |
| Mute Conversation | ✅ | ❌ | Add to Website |
| Delete Conversation | ✅ | ❌ | Add to Website |
| Mark as Read | ✅ | ❌ | Add to Website |

### Chat Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Send Message | ✅ | ✅ | ✅ Both |
| Attach File | ❌ | ✅ | Add to Flutter |
| Phone Call | ❌ | ✅ | Add to Flutter |
| Video Call | ❌ | ✅ | Add to Flutter |
| More Options | ❌ | ✅ | Add to Flutter |

### New Chat Dialog

| Field | Flutter | React | Status |
|-------|---------|-------|--------|
| Contact Search | ✅ | ❌ | Add to Website |
| Contact Selection | ✅ | ❌ | Add to Website |
| Create Button | ✅ | ❌ | Add to Website |

---

## 10. Notifications Screen

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Search Toggle | ✅ | ❌ | Add to Website |
| Mark All Read | ✅ | ❌ | Add to Website |

### Tab Navigation

| Tab | Flutter | React | Status |
|-----|---------|-------|--------|
| All | ✅ | ❌ | Add to Website |
| Unread | ✅ | ❌ | Add to Website |
| Read | ✅ | ❌ | Add to Website |

### Filter Chips

| Chip | Flutter | React | Status |
|------|---------|-------|--------|
| All | ✅ | ❌ | Add to Website |
| Submissions | ✅ | ❌ | Add to Website |
| Grading | ✅ | ❌ | Add to Website |
| Messages | ✅ | ❌ | Add to Website |
| Deadlines | ✅ | ❌ | Add to Website |
| System | ✅ | ❌ | Add to Website |

### Notification Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Mark as Read | ✅ | ❌ | Add to Website |
| Delete | ✅ | ❌ | Add to Website |
| Undo Delete | ✅ | ❌ | Add to Website |

---

## 11. Profile Screen

### View Profile Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Edit Profile | ✅ → Edit screen | ✅ Inline toggle | Different |
| Settings | ✅ → Settings | ❌ In Quick Actions | Different |
| View Course | ✅ → Course management | ❌ | Add to Website |
| Help/Support | ✅ | ❌ | Add to Website |
| Logout | ✅ Dialog | ❌ | Add to Website |

### Quick Actions (Website)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Change Password | ❌ | ✅ | Add to Flutter |
| Notification Settings | ❌ | ✅ | Add to Flutter |
| Language & Region | ❌ | ✅ | Add to Flutter |

### Edit Profile Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Change Cover Photo | ✅ | ❌ | Add to Website |
| Change Profile Picture | ✅ | ✅ Camera icon | ✅ Both |
| Save Changes | ✅ | ✅ | ✅ Both |
| Discard Dialog | ✅ | ❌ Cancel button | Different |

---

## 12. Settings Screen

### Profile Section

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Go to Profile | ✅ | ❌ Inline | Different |

### Preferences

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Appearance | ✅ → Sub-route | ❌ | Add to Website |
| Language | ✅ → Sub-route | ✅ Dropdown | Different |
| Notifications | ✅ → Sub-route | ✅ 5 toggles | Different |

### Teaching Settings

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Grading Preferences | ✅ Modal | ✅ Inline | ✅ Both |
| Assignment Defaults | ✅ Modal | ✅ Inline | ✅ Both |
| Attendance Settings | ✅ Modal | ✅ Inline | ✅ Both |
| AI Preferences | ❌ | ✅ 3 settings | Add to Flutter |

### Privacy & Security

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Privacy | ✅ → Sub-route | ✅ 3 toggles | Different |
| Two-Factor Auth | ✅ → Sub-route | ✅ Toggle | Different |
| Connected Devices | ✅ → Sub-route | ❌ | Add to Website |
| Login History | ✅ → Sub-route | ✅ Display | ✅ Both |

### Data & Storage

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Storage Usage | ✅ → Sub-route | ❌ | Add to Website |
| Export Data | ✅ Modal (4 options) | ❌ | Add to Website |

### Support

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Help Center | ✅ → Sub-route | ❌ | Add to Website |
| Send Feedback | ✅ Modal | ❌ | Add to Website |
| Share App | ✅ → Sub-route | ❌ | N/A (mobile) |

### Account

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Logout | ✅ Dialog | ❌ | Add to Website |
| Deactivate Account | ❌ | ✅ Button | Add to Flutter |
| Delete Account | ❌ | ✅ Button | Add to Flutter |

---

## 13. Announcements Screen

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Language Toggle | ✅ | ❌ | Add to Website |
| Theme Toggle | ✅ | ❌ | Add to Website |

### Filter Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Search Input | ✅ | ✅ | ✅ Both |
| All Chip | ✅ | ❌ | Add to Website |
| Published Chip | ✅ | ❌ | Add to Website |
| Scheduled Chip | ✅ | ❌ | Add to Website |
| Draft Chip | ✅ | ❌ | Add to Website |
| Course Filter | ❌ | ✅ | Add to Flutter |

### Announcement Card Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Edit | ✅ | ✅ | ✅ Both |
| Delete | ✅ Dialog | ✅ | ✅ Both |
| Analytics | ✅ Dialog | ❌ | Add to Website |
| Publish | ✅ | ❌ | Add to Website |
| Send Notification | ❌ | ✅ | Add to Flutter |

### Create/Edit Form

| Field | Flutter | React | Status |
|-------|---------|-------|--------|
| Title | ✅ | ✅ | ✅ Both |
| Content | ✅ | ✅ | ✅ Both |
| Status | ✅ | ❌ | Add to Website |
| Audience | ✅ | ❌ | Add to Website |
| Schedule Time | ✅ | ❌ | Add to Website |
| Attachments | ✅ | ❌ | Add to Website |
| Course Selection | ❌ | ✅ | Add to Flutter |
| Pin Toggle | ❌ | ✅ | Add to Flutter |

### Analytics Dialog (Flutter)

| Element | Flutter | React | Status |
|---------|---------|-------|--------|
| Total Views | ✅ | ❌ | Add to Website |
| Read Rate | ✅ | ❌ | Add to Website |
| Views Chart | ✅ 7 days | ❌ | Add to Website |
| AI Insights | ✅ | ❌ | Add to Website |

### AI Features (Website)

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Generate Announcement | ❌ | ✅ | Add to Flutter |
| Summarize Chat | ❌ | ✅ | Add to Flutter |
| Suggest Reply | ❌ | ✅ | Add to Flutter |

---

## 14. Upload Materials Screen (Flutter Only)

### Tab Actions

| Tab | Flutter | React | Status |
|-----|---------|-------|--------|
| Upload Tab | ✅ | ❌ | Add to Website |
| Materials Tab | ✅ | ❌ | Add to Website |

### Upload Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Course Dropdown | ✅ | ❌ | Add to Website |
| Module Dropdown | ✅ | ❌ | Add to Website |
| Drop Zone Tap | ✅ | ⚠️ In course | Different |
| Choose Files | ✅ | ❌ | Add to Website |
| Add Link | ✅ | ❌ | Add to Website |
| Quick: Documents | ✅ | ❌ | Add to Website |
| Quick: Videos | ✅ | ❌ | Add to Website |
| Quick: Links | ✅ | ❌ | Add to Website |
| Cancel Upload | ✅ | ❌ | Add to Website |
| Retry Upload | ✅ | ❌ | Add to Website |
| Remove from Queue | ✅ | ❌ | Add to Website |
| Clear Completed | ✅ | ❌ | Add to Website |

### Materials Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Search Materials | ✅ | ❌ | Add to Website |
| Type Filter | ✅ | ❌ | Add to Website |
| Edit Material | ✅ | ❌ | Add to Website |
| Delete Material | ✅ | ❌ | Add to Website |
| Toggle Visibility | ✅ | ❌ | Add to Website |
| Download | ✅ | ✅ | ✅ Both |

---

## 15. Search Screen (Flutter Only)

### Search Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Search Input | ✅ | ⚠️ Modal only | Add to Website |
| Clear Search | ✅ | ❌ | Add to Website |

### Category Chips

| Chip | Flutter | React | Status |
|------|---------|-------|--------|
| All | ✅ | ❌ | Add to Website |
| Students | ✅ | ❌ | Add to Website |
| Courses | ✅ | ❌ | Add to Website |
| Assignments | ✅ | ❌ | Add to Website |
| Grades | ✅ | ❌ | Add to Website |
| Materials | ✅ | ❌ | Add to Website |
| Announcements | ✅ | ❌ | Add to Website |

### Recent Searches

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Use Recent Search | ✅ | ❌ | Add to Website |
| Remove Single | ✅ | ❌ | Add to Website |
| Clear All | ✅ | ❌ | Add to Website |

### Quick Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Grade Submissions | ✅ → /instructor/grading | ❌ | Add to Website |
| Create Assignment | ✅ → /instructor/create-assignment | ❌ | Add to Website |
| Upload Materials | ✅ → /instructor/upload-materials | ❌ | Add to Website |
| Post Announcement | ✅ → /instructor/announcements | ❌ | Add to Website |
| Take Attendance | ✅ → /instructor/attendance | ❌ | Add to Website |
| View Reports | ✅ → /instructor/reports | ❌ | Add to Website |

### Results Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Result Card Click | ✅ → Relevant route | ❌ | Add to Website |

---

## 16. Roster Screen (Website Only)

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Add Student | ❌ | ✅ | Add to Flutter |

### Table Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Search | ❌ | ✅ | Add to Flutter |
| Sort by Name | ❌ | ✅ | Add to Flutter |
| Sort by Email | ❌ | ✅ | Add to Flutter |
| Sort by Status | ❌ | ✅ | Add to Flutter |
| Edit Student | ❌ | ✅ | Add to Flutter |
| Toggle Status | ❌ | ✅ | Add to Flutter |
| Delete Student | ❌ | ✅ | Add to Flutter |

---

## 17. Waitlist Screen (Website Only)

### Table Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Search | ❌ | ✅ | Add to Flutter |
| Sort by Name | ❌ | ✅ | Add to Flutter |
| Sort by Email | ❌ | ✅ | Add to Flutter |
| Sort by Date | ❌ | ✅ | Add to Flutter |
| Approve | ❌ | ✅ | Add to Flutter |
| Reject | ❌ | ✅ | Add to Flutter |

---

## 18. Labs Screen (Website Only)

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Create New Lab | ❌ | ✅ | Add to Flutter |

### Filter Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Course Filter | ❌ | ✅ | Add to Flutter |
| Status Filter | ❌ | ✅ | Add to Flutter |
| Search | ❌ | ✅ | Add to Flutter |

### Lab Card Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| View Submissions | ❌ | ✅ | Add to Flutter |
| Edit Lab | ❌ | ✅ | Add to Flutter |
| Upload Instructions | ❌ | ✅ | Add to Flutter |
| Grade Lab | ❌ | ✅ | Add to Flutter |
| AI Auto-Grading | ❌ | ✅ | Add to Flutter |

---

## 19. Quizzes Screen (Website Only)

### Header Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Create New Quiz | ❌ | ✅ | Add to Flutter |

### Filter Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| Course Filter | ❌ | ✅ | Add to Flutter |
| Status Filter | ❌ | ✅ | Add to Flutter |
| Search | ❌ | ✅ | Add to Flutter |

### Quiz Card Actions

| Action | Flutter | React | Status |
|--------|---------|-------|--------|
| View Attempts | ❌ | ✅ | Add to Flutter |
| Edit Quiz | ❌ | ✅ | Add to Flutter |
| Generate with AI | ❌ | ✅ | Add to Flutter |
| Analyze Results | ❌ | ✅ | Add to Flutter |
| Publish | ❌ | ✅ | Add to Flutter |

---

*Document generated: February 2026*
*Total buttons/actions analyzed: 500+*
