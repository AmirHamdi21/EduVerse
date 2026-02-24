# TA Role Feature Comparison: Flutter Mobile App vs React Website

## Document Information
- **Document Type:** Feature Comparison Documentation
- **Role:** Teaching Assistant (TA)
- **Flutter Project Path:** `D:\Graduation\EduVerse\edu_verse`
- **Website Project Path:** `D:\Graduation\frontend tarek\Eduverse-Frontend`
- **Last Updated:** February 2026

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Navigation & Menu Structure](#navigation--menu-structure)
3. [Dashboard Page](#dashboard-page)
4. [Courses Management](#courses-management)
5. [Labs Management](#labs-management)
6. [Grading Features](#grading-features)
7. [Attendance Management](#attendance-management)
8. [Student Performance](#student-performance)
9. [Discussions/Forum](#discussionsforum)
10. [Communication Features](#communication-features)
11. [Schedule/Calendar](#schedulecalendar)
12. [Announcements](#announcements)
13. [Analytics](#analytics)
14. [Upload Materials](#upload-materials)
15. [Office Hours](#office-hours)
16. [Notifications](#notifications)
17. [AI Features](#ai-features)
18. [Profile & Settings](#profile--settings)
19. [Missing Pages/Features Summary](#missing-pagesfeatures-summary)
20. [Summary Comparison Table](#summary-comparison-table)

---

## Executive Summary

This document provides a comprehensive comparison of the TA (Teaching Assistant) role features between the **Flutter Mobile App** and the **React Website**. Both platforms were developed independently and contain different feature sets.

### Quick Statistics
| Metric | Flutter Mobile App | React Website |
|--------|-------------------|---------------|
| Total Screens/Pages | 22 screens | 12 pages/tabs |
| Total Widgets | 93+ widgets | 14 components |
| Navigation Tabs | 23 menu items | 12 tabs |
| AI-Powered Features | Yes (AI Grading, AI Assistant) | Yes (AI Attendance, AI Grading) |
| Theme Support | Dark/Light | Dark/Light |
| Language Support | Multi-language (l10n) | Multi-language (Arabic/English + RTL) |

---

## Navigation & Menu Structure

### Flutter Mobile App (Drawer Navigation)
The Flutter app uses a **Drawer-based navigation** with categorized menu items:

**Main Menu:**
1. Dashboard (`/ta/dashboard`)
2. Assigned Courses (`/ta/courses`)
3. Labs (`/ta/labs`)
4. Student Performance (`/ta/student-performance`)
5. Grading Center (`/ta/grading`) - Badge: 12
6. AI Grading (`/ta/ai-grading`) - AI Highlighted
7. Lab Resources (`/ta/lab-resources`)
8. Student Inbox (`/ta/student-inbox`) - Badge: 3
9. Review Submissions (`/ta/reviews`)
10. Upload Materials (`/ta/upload-materials`)
11. Analytics (`/ta/analytics`)
12. Discussions (`/ta/discussions`) - Badge: 5
13. Office Hours (`/ta/office-hours`)
14. Attendance Manager (`/ta/attendance`)
15. Calendar (`/ta/calendar`)

**AI Tools:**
16. AI Assistant (`/ta/ai-assistant`) - AI Highlighted

**Communication:**
17. Discussions (`/ta/discussions`)
18. Messages (`/ta/messages`) - Badge: 3
19. Notifications (`/ta/notifications`) - Badge: 2

**Account:**
20. Profile (`/ta/profile`)
21. Settings (`/ta/settings`)

**Additional Features in Drawer:**
- Quick Stats (Courses count, Graded count, Pending count)
- Theme Toggle (Light/Dark mode)
- Logout button

### React Website (Tab-based Navigation)
The React website uses a **Tab-based sidebar navigation**:

**Tabs:**
1. Dashboard
2. Courses
3. Labs
4. Grading
5. Students (Student Performance)
6. Attendance
7. Schedule
8. Announcements
9. Discussion
10. Communication
11. Chat
12. Profile

**Additional Header Features:**
- Search functionality
- Language toggle (English/Arabic)
- Theme toggle
- User menu

### Navigation Differences

| Feature | Flutter App | Website | Notes |
|---------|-------------|---------|-------|
| Navigation Type | Drawer | Sidebar/Tabs | Different UX patterns |
| Quick Stats in Nav | ✅ | ❌ | Flutter shows stats in drawer |
| Notifications Menu Item | ✅ | ❌ | Missing from website tabs |
| AI Assistant Menu Item | ✅ | ❌ | Missing from website |
| Office Hours Menu Item | ✅ | ❌ | Missing from website |
| Lab Resources Menu Item | ✅ | ❌ | Missing from website |
| Upload Materials Menu Item | ✅ | ❌ | Missing from website |
| Analytics Menu Item | ✅ | ❌ | Missing from website |
| Student Inbox Menu Item | ✅ | ❌ | Missing from website |
| Chat Tab | ❌ | ✅ | Missing from Flutter |
| Announcements Tab | ❌ | ✅ | Missing from Flutter sidebar |
| Schedule Tab | ❌ | ✅ | Flutter has Calendar instead |

---

## Dashboard Page

### Flutter Mobile App (`ta_dashboard_screen.dart`)

**Features:**
1. **App Bar** with:
   - Hamburger menu icon
   - Title "Dashboard"
   - Theme toggle button
   - Notifications button

2. **AI Insights Card**
   - View Full Insights button
   - Ask AI Help button (navigates to `/ai-chat`)

3. **Quick Actions Grid** (4 actions):
   - Exam Grading → `/ta/ai-grading`
   - Review Labs → `/ta/labs`
   - Open Discussions → `/ta/discussions`
   - Ask AI → `/ai-chat`

4. **Activity Stats Section** showing:
   - Assignments Graded: 36
   - Labs Reviewed: 8
   - Questions Answered: 12
   - Attendance Sessions: 2
   - Time Saved: 14h

5. **Assigned Courses Section**
   - Course cards with code, name, instructor, schedule
   - Students count
   - Pending tasks count
   - Color-coded by course
   - "View All" button → `/ta/courses`

6. **Task Center Section**
   - Tasks list with type (grading, review, discussion)
   - Priority indicators (high, medium, low)
   - Due date
   - Start Task action

7. **Discussion Monitor Section**
   - Recent discussions list
   - Student name, course, question preview
   - View count, upvote count
   - Reply Now action
   - "View All" button → `/ta/discussions`

**Data Model:**
```dart
TACourseModel: id, code, name, instructorName, studentsCount, schedule, pendingTasks, color
TATaskModel: id, title, description, courseCode, type, priority, submissionCount, dueDate
TADiscussionModel: id, studentName, courseCode, question, timeAgo, viewCount, upvoteCount
```

### React Website (`ModernDashboard.tsx`)

**Features:**
1. **Stats Cards Row** (6 cards):
   - Assigned Courses (with icon)
   - Active Labs (with icon)
   - Pending Submissions (with icon)
   - Avg Performance (with icon)
   - Unread Messages (with icon)
   - Upcoming Labs (with icon)

2. **Course Performance Chart** (BarChart using Recharts)
   - Shows course code vs average grade

3. **Upcoming Labs Card**
   - List of upcoming labs with title, course, date, time
   - "View All" button

4. **Recent Activity Feed**
   - Activity type icons (submission, question, grade, attendance)
   - Message, course, timestamp

5. **Quick Actions Card**
   - View All Courses → courses tab
   - Grade Pending Submissions → grading tab
   - Check Messages → communication tab
   - Manage Labs → labs tab

### Dashboard Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| AI Insights Card | ✅ | ❌ | **Missing in Website** |
| Quick Actions Grid (4) | ✅ | ✅ | Both have, different actions |
| Activity Stats (detailed) | ✅ | ❌ | **Missing in Website** |
| Stats Cards Row | ❌ | ✅ (6 cards) | **Missing in Flutter** |
| Performance Chart | ❌ | ✅ | **Missing in Flutter** |
| Task Center | ✅ | ❌ | **Missing in Website** |
| Discussion Monitor | ✅ | ❌ | **Missing in Website** |
| Assigned Courses Section | ✅ | ❌ | **Missing in Website** |
| Upcoming Labs | ❌ | ✅ | **Missing in Flutter Dashboard** |
| Recent Activity Feed | ❌ | ✅ | **Missing in Flutter Dashboard** |
| Ask AI Button | ✅ | ❌ | **Missing in Website** |

---

## Courses Management

### Flutter Mobile App (`ta_courses_list_screen.dart`, `ta_course_detail_screen.dart`)

**Courses List Screen:**
1. **Summary Stats Card**
   - Total courses count
   - Total students count
   - Total pending grading count

2. **Filter Chips**
   - "All" filter
   - "Grading Pending" filter with badge

3. **Course Cards** showing:
   - Course code badge with color
   - Progress percentage
   - Course name
   - Instructor name
   - Students count, Labs count, Assignments count
   - Pending grading count, Pending discussions count
   - Next deadline warning
   - Quick action buttons: View Labs, Grading, Discussion

**Course Detail Screen:**
- Course header with code, name, instructor
- AI Insights button (gradient design)
- **Stats Cards**: Students, Labs, Assignments, Discussions
- **Quick Actions**: View Labs, View Submissions, View Discussions, AI Insights

**4 Tabs:**
1. **Overview Tab**: Upcoming tasks, Recent activities
2. **Labs Tab**: Lab items with status, progress, attendance
3. **Grading Tab**: Grading tasks with AI suggested scores
4. **Discussions Tab**: Discussion threads with filters

### React Website (`CoursesPage.tsx`)

**Features:**
1. **Search Input** for courses
2. **Courses Grid** (3 columns) showing cards with:
   - Course name with icon
   - Code
   - Instructor name
   - Semester
   - Stats grid: Labs count, Students count
   - Average Grade percentage
   - Attendance Rate percentage
   - Pending Submissions warning banner
   - "View Details" button

**Missing:** Course detail page is not implemented - clicking "View Details" navigates to Labs page

### Courses Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Summary Stats | ✅ | ❌ | **Missing in Website** |
| Filter Chips | ✅ | ❌ | **Missing in Website** |
| Search | ❌ | ✅ | **Missing in Flutter List** |
| Course Detail Page | ✅ (full page with tabs) | ❌ (redirects to labs) | **Missing in Website** |
| Course Progress Bar | ✅ | ❌ | **Missing in Website** |
| Next Deadline Warning | ✅ | ❌ | **Missing in Website** |
| Quick Action Buttons | ✅ | ❌ | **Missing in Website** |
| Labs Tab in Detail | ✅ | ❌ | **Missing in Website** |
| Grading Tab in Detail | ✅ | ❌ | **Missing in Website** |
| Discussions Tab in Detail | ✅ | ❌ | **Missing in Website** |
| AI Insights in Course | ✅ | ❌ | **Missing in Website** |
| Semester Display | ❌ | ✅ | **Missing in Flutter** |
| Instructor Email | ❌ | ✅ (in constants) | **Missing in Flutter** |

---

## Labs Management

### Flutter Mobile App (`ta_labs_list_screen.dart`, `ta_lab_detail_screen.dart`)

**Labs List Screen:**
1. **Filter Chips**: All, Active, Pending Review
2. **Labs grouped by Course** with:
   - Course header (code, name, instructor, color)
   - Lab items: Title, Status (active/closed), Submissions count, Due date, Pending review badge

**Lab Detail Screen:**
- Lab header with course info
- Stats cards: Total submissions, Pending review, Attendance
- **3 Tabs**:
  1. **Overview Tab**: Lab info, instructions, materials
  2. **Submissions Tab**: Student submissions list with review modal
  3. **Attendance Tab**: Attendance tracking

**Features:**
- Copilot Widget for AI assistance
- Review Submission Modal
- Lab action buttons

### React Website (`LabsPage.tsx`)

**Features:**
1. **Header** with "Create New Lab" button
2. **Search & Filters**:
   - Search input
   - Status filter buttons (All, Upcoming, Active, Completed)
3. **Labs Table** with columns:
   - Lab (title, lab number, icon)
   - Course
   - Date & Time
   - Location
   - Submissions (graded/total, pending count)
   - Status badge
   - Actions (View Details button)

### Labs Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Labs grouped by course | ✅ | ❌ | **Different approach - Website uses table** |
| Create New Lab button | ❌ | ✅ | **Missing in Flutter** |
| Search | ❌ | ✅ | **Missing in Flutter** |
| Lab Detail Screen | ✅ | ❌ | **Missing in Website** |
| Lab Tabs (Overview/Submissions/Attendance) | ✅ | ❌ | **Missing in Website** |
| Location info | ❌ | ✅ | **Missing in Flutter** |
| Table view | ❌ | ✅ | **Flutter uses cards** |
| AI Copilot Widget | ✅ | ❌ | **Missing in Website** |
| Review Submission Modal | ✅ | ❌ | **Missing in Website** |

---

## Grading Features

### Flutter Mobile App (`ta_ai_grading_screen.dart`)

**Features:**
1. **Course & Lab Selectors** (dropdowns)
2. **Stats Summary**: Pending, Reviewed, Late counts
3. **Search** for students
4. **Submissions List** with:
   - Student avatar with initial
   - Student name & ID
   - Submission time, Word count
   - Status badges: AI Evaluated, Pending, Finalized, Late
   - AI Score display (if evaluated)
5. **Auto-Evaluate All** button (batch AI evaluation)
6. **Submission Detail Modal**:
   - Student info
   - Submission details section
   - AI evaluation section
   - Feedback input
   - Actions: Approve AI Score, Edit Score

**AI Features:**
- AI-suggested scores for each submission
- Batch AI evaluation
- AI score approval workflow

### React Website (`GradingPage.tsx`)

**Features:**
1. **Header** with pending/graded counts
2. **Filter Buttons**: All, Submitted, Graded
3. **Submissions List** showing:
   - Student avatar
   - Student name
   - Submission timestamp
   - Grade display (if graded)
   - Status badges
   - **Submitted Files** section with download buttons
   - **Feedback** section (if exists)
4. **Action Buttons**:
   - AI-Assisted Grade (with Brain icon)
   - Manual Grade
   - Edit Grade (for graded submissions)

### Grading Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Course/Lab Selectors | ✅ | ❌ | **Missing in Website** |
| Stats Summary Cards | ✅ | ✅ (in header) | Both have |
| Search by student | ✅ | ❌ | **Missing in Website** |
| AI Score Display | ✅ | ❌ | **Missing in Website** |
| Auto-Evaluate All | ✅ | ❌ | **Missing in Website** |
| Submission Detail Modal | ✅ | ❌ | **Missing in Website** |
| File Download | ❌ | ✅ | **Missing in Flutter** |
| Feedback Display | ❌ | ✅ | **Missing in Flutter list** |
| AI-Assisted Grade Button | ✅ (in modal) | ✅ | Both have |
| Manual Grade Button | ✅ | ✅ | Both have |
| Word Count | ✅ | ❌ | **Missing in Website** |
| Late Badge | ✅ | ✅ | Both have |

---

## Attendance Management

### Flutter Mobile App (`ta_attendance_screen.dart`)

**Features:**
1. **App Bar** with hamburger menu
2. **Stats Cards**: Present, Absent, Late, Excused counts
3. **Filters**: Course selector, Lab selector, Date picker
4. **Search** for students
5. **3 Tabs**:
   - **Take Attendance Tab**: Manual check-in for students
   - **History Tab**: Past attendance records
   - **Reports Tab**: Attendance reports
6. **Floating Action Button**: Scan QR for quick attendance
7. **Student List** with:
   - Avatar with initials
   - Student name & ID
   - Status (Present/Absent/Late/Excused)
   - Check-in time

**Quick Actions Sheet:**
- QR Code scanning functionality

### React Website (`AttendancePage.tsx`)

**Features (AI-Powered):**
1. **Header**: "AI-Powered Attendance" title
2. **Tab Navigation**: Upload Photo, Results, History
3. **Lab Session Selection** grid
4. **Upload Zone**:
   - Drag-and-drop file upload
   - Photo preview
   - File size display
   - Remove button
5. **Photo Guidelines** tips
6. **Processing Animation**:
   - Circular progress indicator
   - Processing tips rotation
   - Demo note
7. **Results View**:
   - Summary stats: Total, Present, Absent, Uncertain
   - Edit Mode toggle
   - Student list with status override
   - Export to CSV
   - Save session
8. **History Tab**: Past session records

**AI Features:**
- Face detection from class photo
- Confidence scores
- Manual override option
- Uncertain status handling

### Attendance Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| AI Face Detection | ❌ | ✅ | **Missing in Flutter** |
| Photo Upload | ❌ | ✅ | **Missing in Flutter** |
| QR Code Scanning | ✅ | ❌ | **Missing in Website** |
| Manual Check-in | ✅ | ❌ | **Missing in Website (only photo-based)** |
| Course/Lab Filters | ✅ | ✅ | Both have |
| History Tab | ✅ | ✅ | Both have |
| Reports Tab | ✅ | ❌ | **Missing in Website** |
| Export to CSV | ❌ | ✅ | **Missing in Flutter** |
| Confidence Scores | ❌ | ✅ | **Missing in Flutter** |
| Processing Animation | ❌ | ✅ | **Missing in Flutter** |
| Photo Guidelines | ❌ | ✅ | **Missing in Flutter** |
| Excused Status | ✅ | ❌ | **Missing in Website** |

---

## Student Performance

### Flutter Mobile App (`ta_student_performance_screen.dart`)

**Features:**
1. **Stats Grid**:
   - Total Students
   - Total Submissions
   - Average Score
   - Average Attendance
   - High Performers count
   - At-Risk count
   - Engagement percentage
   - On Track count

2. **Filters**: Course, Lab, Name filter (A-Z)
3. **Search** for students
4. **Students List** with:
   - Avatar
   - Name, Student ID
   - Lab average, Attendance percentage
   - Risk level indicator (Low/Medium/High)
   - Submissions count, Late submissions

5. **AI Insights Panel**:
   - Students At Risk list
   - Recommended Actions (prioritized)
   - Academic Alerts (plagiarism detection)

6. **Student Summary Modal**:
   - Detailed student info
   - Performance breakdown
   - Action buttons

### React Website (`StudentPerformancePage.tsx`)

**Features:**
1. **Two-column Layout**:
   - **Left Column**: Students list
   - **Right Column**: Performance details

2. **Students List**:
   - Student name
   - Performance status badge (Excellent/Good/Fair/Needs Improvement)
   - Average and attendance percentages

3. **Performance Details** (when student selected):
   - Overview Stats: Overall Average, Overall Attendance
   - **Performance Bar Chart** (using Recharts)
   - **Course Details** cards with:
     - Course name
     - Average Grade, Attendance, Submissions, Late count

4. **Placeholder** when no student selected

### Student Performance Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Stats Grid (8 metrics) | ✅ | ❌ | **Missing in Website** |
| Course/Lab Filters | ✅ | ❌ | **Missing in Website** |
| Search | ✅ | ❌ | **Missing in Website** |
| Risk Level Indicators | ✅ | ❌ | **Missing in Website** |
| Performance Status Badge | ❌ | ✅ | **Missing in Flutter** |
| Performance Chart | ❌ | ✅ | **Missing in Flutter** |
| Two-column Layout | ❌ | ✅ | **Flutter uses list + modal** |
| AI Insights Panel | ✅ | ❌ | **Missing in Website** |
| Students At Risk | ✅ | ❌ | **Missing in Website** |
| Recommended Actions | ✅ | ❌ | **Missing in Website** |
| Academic Alerts | ✅ | ❌ | **Missing in Website** |
| Student Detail Modal | ✅ | ❌ | **Website uses inline detail** |

---

## Discussions/Forum

### Flutter Mobile App (`ta_discussions_screen.dart`)

**Features:**
1. **Search Input**
2. **Filter Chips**: All, Unanswered, My Replies, Flagged
3. **Discussion Threads List**:
   - Thread title
   - Student name
   - Preview text
   - Tags (Lab, Urgent, Instructor, General)
   - Reply count, Time ago
   - Status: Unread, Read, Resolved

4. **Trending Topics Section**:
   - Topic name with count

5. **Floating Action Button**: Create new thread

6. **Create Thread Dialog** (modal)

### React Website (`DiscussionPage.tsx`)

**Features:**
1. **Header** with Open/Answered counts
2. **Filters**:
   - Search input
   - Course filter dropdown
   - Status filter dropdown (All/Open/Answered/Closed)

3. **Discussion List** (expandable cards):
   - Pinned indicator
   - Title
   - Status badge (Open/Answered/Closed)
   - Content preview
   - Student name, Course, Lab, Date
   - Replies count, Views count
   - Expand/Collapse toggle

4. **Expanded View**:
   - Full question content
   - Pin/Unpin button
   - Close Thread button
   - **Replies Section**:
     - Author with role badge (TA/Instructor/Student)
     - Content
     - Timestamp, Likes
     - Mark as Answer button
     - Accepted Answer indicator
   - **Reply Box** with text area

### Discussions Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Search | ✅ | ✅ | Both have |
| Filter Chips | ✅ | ❌ (uses dropdowns) | **Different approach** |
| Status Filters | ✅ | ✅ | Both have |
| Trending Topics | ✅ | ❌ | **Missing in Website** |
| Create Thread FAB | ✅ | ❌ | **Missing in Website** |
| Expandable Cards | ❌ | ✅ | **Missing in Flutter** |
| Full Reply Section | ❌ | ✅ | **Missing in Flutter** |
| Mark as Answer | ❌ | ✅ | **Missing in Flutter** |
| Pin/Unpin | ❌ | ✅ | **Missing in Flutter** |
| Close Thread | ❌ | ✅ | **Missing in Flutter** |
| Role Badges | ❌ | ✅ | **Missing in Flutter** |
| Likes Count | ❌ | ✅ | **Missing in Flutter** |
| Views Count | ✅ | ✅ | Both have |
| Tags/Labels | ✅ | ❌ | **Missing in Website** |

---

## Communication Features

### Flutter Mobile App (`ta_messages_screen.dart`, `ta_student_inbox_screen.dart`)

**Messages Screen:**
- Inbox for direct messages
- Message list with sender, subject, preview
- Unread indicators

**Student Inbox Screen:**
- Student-specific communications
- Chat interface
- At-Risk Banner for flagged students

### React Website (`CommunicationPage.tsx`)

**Features:**
1. **Tab Navigation**: Messages, Q&A Discussions
2. **Messages Tab**:
   - New Message button
   - Message list with:
     - Avatar
     - Sender name
     - Subject
     - Message preview
     - Timestamp
     - Unread indicator (blue dot)
   - Click to mark as read

3. **Q&A Tab**:
   - Filter button
   - Questions list with:
     - Avatar
     - Student name
     - Course & Lab
     - Question text
     - Answer display (if answered)
     - Status badges (New/Answered/Flagged)
     - **Action Buttons**: Answer, Flag for Instructor

### Communication Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Messages Tab | ✅ | ✅ | Both have |
| Q&A Tab | ❌ | ✅ | **Missing in Flutter** |
| New Message Button | ❌ | ✅ | **Missing in Flutter** |
| Student Inbox (separate) | ✅ | ❌ | **Missing in Website** |
| At-Risk Banner | ✅ | ❌ | **Missing in Website** |
| Flag for Instructor | ❌ | ✅ | **Missing in Flutter** |
| Answer Button | ❌ | ✅ | **Missing in Flutter** |

---

## Schedule/Calendar

### Flutter Mobile App (`ta_calendar_screen.dart`)

**Features:**
1. **App Bar** with Today and Sync buttons
2. **View Selector**: Month, Week, Day
3. **Filter Chips**: Lab, Grading, Office Hours, Meetings
4. **Calendar Card** with date picker
5. **Events for Selected Day**
6. **Upcoming Events Section**
7. **Floating Action Button**: Add Event

**Event Types:**
- Lab sessions
- Grading deadlines
- Office hours
- Meetings

**Event Data:**
- Title, Date, Start/End time
- Type, Location, Description

### React Website (`SchedulePage.tsx`)

**Features:**
1. **Header** with View toggle (Week/List)
2. **Week Navigation** with prev/next buttons
3. **Week View** (5-day grid):
   - Day headers with day name and date
   - Events cards with title, time, type badge

4. **List View**:
   - Events grouped by date
   - Event cards with:
     - Title
     - Type badge
     - Course info
     - Time & Location

5. **Legend** showing event type colors

**Event Types:**
- Lab sessions (blue)
- Office hours (green)
- Meetings (orange)
- Grading deadlines (red)

### Schedule/Calendar Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Month View | ✅ | ❌ | **Missing in Website** |
| Week View | ✅ | ✅ | Both have |
| Day View | ✅ | ❌ | **Missing in Website** |
| List View | ❌ | ✅ | **Missing in Flutter** |
| Add Event FAB | ✅ | ❌ | **Missing in Website** |
| Event Filters | ✅ | ❌ | **Missing in Website** |
| Sync Button | ✅ | ❌ | **Missing in Website** |
| Legend | ❌ | ✅ | **Missing in Flutter** |
| Week Navigation | ✅ | ✅ | Both have |

---

## Announcements

### Flutter Mobile App
**❌ NOT IMPLEMENTED** - No dedicated Announcements screen found.

### React Website (`AnnouncementsPage.tsx`)

**Features:**
1. **Header** with "New Announcement" button
2. **New Announcement Form**:
   - Title input
   - Course selector
   - Content textarea
   - Pin checkbox
   - Post/Cancel buttons

3. **Course Filter** buttons
4. **Announcements List**:
   - Megaphone icon
   - Title with Pin indicator
   - Course & Date
   - Content text
   - Posted by info
   - **Actions**: Pin/Unpin toggle, Delete

### Announcements Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Announcements Page | ❌ | ✅ | **MISSING IN FLUTTER** |
| Create Announcement | ❌ | ✅ | **MISSING IN FLUTTER** |
| Course Filter | ❌ | ✅ | **MISSING IN FLUTTER** |
| Pin/Unpin | ❌ | ✅ | **MISSING IN FLUTTER** |
| Delete | ❌ | ✅ | **MISSING IN FLUTTER** |

---

## Analytics

### Flutter Mobile App (`ta_analytics_screen.dart`)

**Features:**
1. **Stats Grid** (4 metrics):
   - Attendance % with trend
   - Submission Rate % with trend
   - At-Risk Students count with trend
   - Engagement Score % with trend

2. **Charts Section**:
   - Attendance Chart (weekly data)
   - Submission Chart (by lab)
   - Score Distribution Chart

3. **Filter Controls** for charts
4. **AI Insights Section**:
   - Quick Insights list (color-coded)

5. **Bottom Section**:
   - Session Comparison metrics
   - Deadline Detection card
   - Upcoming Deadlines list

6. **View All Analytics** button

### React Website
**❌ NOT IMPLEMENTED** - No dedicated Analytics page found.

### Analytics Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Analytics Page | ✅ | ❌ | **MISSING IN WEBSITE** |
| Stats Grid | ✅ | ❌ | **MISSING IN WEBSITE** |
| Attendance Chart | ✅ | ❌ | **MISSING IN WEBSITE** |
| Submission Chart | ✅ | ❌ | **MISSING IN WEBSITE** |
| Score Distribution | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Insights | ✅ | ❌ | **MISSING IN WEBSITE** |
| Session Comparison | ✅ | ❌ | **MISSING IN WEBSITE** |
| Deadline Detection | ✅ | ❌ | **MISSING IN WEBSITE** |

---

## Upload Materials

### Flutter Mobile App (`ta_upload_materials_screen.dart`)

**Features:**
1. **Course & Lab Selectors**
2. **Search** for materials
3. **File Type Filter**: All, PDF, Video, Code, Image, AI-generated
4. **Sort Options**: Recent, Name, Size, Type

5. **Materials List** showing:
   - File icon by type
   - File name
   - Size, Upload date
   - Uploaded by
   - AI-generated badge (if applicable)

6. **Upload Area** (drag-and-drop style)
7. **AI Material Generator**
8. **File Preview Modal**

**Material Types:**
- PDF
- Video
- Code
- Image
- Archive

### React Website
**❌ NOT IMPLEMENTED** - No dedicated Upload Materials page found.

### Upload Materials Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Upload Materials Page | ✅ | ❌ | **MISSING IN WEBSITE** |
| Course/Lab Selectors | ✅ | ❌ | **MISSING IN WEBSITE** |
| File Type Filter | ✅ | ❌ | **MISSING IN WEBSITE** |
| Materials List | ✅ | ❌ | **MISSING IN WEBSITE** |
| Upload Area | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Material Generator | ✅ | ❌ | **MISSING IN WEBSITE** |
| File Preview | ✅ | ❌ | **MISSING IN WEBSITE** |

---

## Office Hours

### Flutter Mobile App (`ta_office_hours_screen.dart`)
**✅ IMPLEMENTED** - Dedicated screen for managing office hours.

Features include:
- Office hours schedule
- Student appointment requests
- Availability management

### React Website
**❌ NOT IMPLEMENTED** - No dedicated Office Hours page found.

### Office Hours Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Office Hours Page | ✅ | ❌ | **MISSING IN WEBSITE** |

---

## Notifications

### Flutter Mobile App (`ta_notifications_screen.dart`)

**Features:**
1. **Notification Cards** with:
   - Type icon
   - Title
   - Description
   - Timestamp
   - Read/Unread status

2. **AI Reply Assistant** widget
3. **Response Performance** metrics

### React Website
**❌ NOT IMPLEMENTED** - No dedicated Notifications page found.

### Notifications Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Notifications Page | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Reply Assistant | ✅ | ❌ | **MISSING IN WEBSITE** |
| Response Performance | ✅ | ❌ | **MISSING IN WEBSITE** |

---

## AI Features

### Flutter Mobile App

**AI-Powered Features:**
1. **AI Grading Screen** (`ta_ai_grading_screen.dart`)
   - AI-suggested scores
   - Batch AI evaluation
   - AI score approval workflow

2. **AI Assistant Screen** (`ta_ai_assistant_screen.dart`)
   - General AI chat assistant
   - Task automation

3. **AI Insights Cards** (Dashboard)
   - Performance insights
   - Recommendations

4. **AI Copilot Widget** (Labs)
   - In-context AI assistance

5. **AI Material Generator** (Upload Materials)
   - Auto-generate study materials

6. **AI Insights Panel** (Student Performance)
   - At-risk student detection
   - Recommended actions

### React Website

**AI-Powered Features:**
1. **AI Attendance** (`AttendancePage.tsx`)
   - Face detection from photos
   - Automatic student recognition
   - Confidence scores

2. **AI-Assisted Grading** (`GradingPage.tsx`)
   - AI-Assisted Grade button

### AI Features Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| AI Grading Screen | ✅ | ❌ (only button) | **Partial in Website** |
| AI Assistant | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Insights | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Copilot | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Material Generator | ✅ | ❌ | **MISSING IN WEBSITE** |
| AI Attendance (Face Detection) | ❌ | ✅ | **MISSING IN FLUTTER** |
| At-Risk Detection | ✅ | ❌ | **MISSING IN WEBSITE** |

---

## Profile & Settings

### Flutter Mobile App

**Profile Screen** (`ta_profile_screen.dart`):
- User info display
- Avatar
- Contact information
- Department info

**Edit Profile Screen** (`ta_edit_profile_screen.dart`):
- Edit personal information

**Settings Screen** (`ta_settings_screen.dart`):
- App settings
- Notification preferences
- Theme settings

### React Website

**Profile Tab** (`DashboardProfileTab`):
- Full Name
- Role (Teaching Assistant)
- Department
- Email
- Phone
- Address
- Date of Birth
- Bio
- Interests tags
- Skills tags

### Profile & Settings Differences

| Feature | Flutter App | Website | Status |
|---------|-------------|---------|--------|
| Profile Display | ✅ | ✅ | Both have |
| Edit Profile | ✅ | ❌ | **Missing in Website** |
| Settings Page | ✅ | ❌ | **MISSING IN WEBSITE** |
| Bio | ❌ | ✅ | **Missing in Flutter** |
| Interests | ❌ | ✅ | **Missing in Flutter** |
| Skills | ❌ | ✅ | **Missing in Flutter** |

---

## Missing Pages/Features Summary

### Features Missing in Website (MUST ADD)

1. **Analytics Page** - Complete page with charts and insights
2. **Upload Materials Page** - File management system
3. **Office Hours Page** - Appointment management
4. **Notifications Page** - Notification center
5. **AI Assistant Page** - General AI chat
6. **Course Detail Page** - Detailed course view with tabs
7. **Lab Detail Page** - Detailed lab view with submissions
8. **Settings Page** - App configuration
9. **Lab Resources Page** - Lab-specific materials

### Features Missing in Flutter (MUST ADD)

1. **Announcements Page** - Create/manage announcements
2. **Chat Tab** - Real-time messaging chat
3. **AI Face Detection Attendance** - Photo-based attendance
4. **Performance Charts** - Visual data in dashboard
5. **Discussion Reply System** - Full threaded replies

### Features with Different Implementations (NEED ALIGNMENT)

1. **Attendance** - Flutter uses QR/manual, Website uses AI/photo
2. **Navigation** - Flutter uses drawer, Website uses sidebar
3. **Grading** - Both have AI but different workflows
4. **Discussions** - Different UI patterns

---

## Summary Comparison Table

| Page/Feature | Flutter Mobile App | React Website | Alignment Status |
|--------------|-------------------|---------------|------------------|
| **Dashboard** | ✅ Full | ✅ Partial | 🟡 Different features |
| **Courses List** | ✅ Full | ✅ Basic | 🟡 Website needs detail |
| **Course Detail** | ✅ With Tabs | ❌ Missing | 🔴 Add to Website |
| **Labs List** | ✅ Full | ✅ Table | 🟡 Different UI |
| **Lab Detail** | ✅ With Tabs | ❌ Missing | 🔴 Add to Website |
| **Grading** | ✅ AI-Powered | ✅ Basic AI | 🟡 Website needs more AI |
| **Attendance** | ✅ QR/Manual | ✅ AI/Photo | 🟡 Different approach |
| **Student Performance** | ✅ AI Insights | ✅ Charts | 🟡 Combine both |
| **Discussions** | ✅ Basic | ✅ Full Replies | 🟡 Flutter needs replies |
| **Communication** | ✅ Inbox | ✅ Messages + Q&A | 🟡 Different features |
| **Calendar/Schedule** | ✅ Full | ✅ Week/List | 🟡 Website needs month |
| **Announcements** | ❌ Missing | ✅ Full | 🔴 Add to Flutter |
| **Analytics** | ✅ Full | ❌ Missing | 🔴 Add to Website |
| **Upload Materials** | ✅ Full | ❌ Missing | 🔴 Add to Website |
| **Office Hours** | ✅ Full | ❌ Missing | 🔴 Add to Website |
| **Notifications** | ✅ Full | ❌ Missing | 🔴 Add to Website |
| **AI Assistant** | ✅ Full | ❌ Missing | 🔴 Add to Website |
| **Profile** | ✅ Basic | ✅ Detailed | 🟡 Flutter needs bio/skills |
| **Settings** | ✅ Full | ❌ Missing | 🔴 Add to Website |
| **Chat** | ❌ Missing | ✅ Full | 🔴 Add to Flutter |

### Legend
- 🟢 Both platforms aligned
- 🟡 Partial alignment - needs work
- 🔴 Missing - must add

---

## Buttons/Actions Status

### Dashboard Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| View Full Insights | ✅ Shows snackbar | ❌ N/A | 🟡 Mock |
| Ask AI Help | ✅ → /ai-chat | ❌ N/A | ✅ Working |
| Exam Grading | ✅ → /ta/ai-grading | ❌ N/A | ✅ Working |
| Review Labs | ✅ → /ta/labs | ❌ N/A | ✅ Working |
| Open Discussions | ✅ → /ta/discussions | ❌ N/A | ✅ Working |
| View All Courses | ✅ → /ta/courses | ✅ → courses tab | ✅ Both Working |
| Grade Pending | ❌ N/A | ✅ → grading tab | ✅ Working |
| Check Messages | ❌ N/A | ✅ → communication | ✅ Working |
| Manage Labs | ❌ N/A | ✅ → labs tab | ✅ Working |

### Courses Page Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| View Course | ✅ → /ta/course/:id | ❌ → labs tab | 🔴 Different |
| View Labs | ✅ → /ta/labs | ❌ N/A | ✅ Working |
| Grading | ✅ Shows snackbar | ❌ N/A | 🟡 Mock |
| Discussion | ✅ Shows snackbar | ❌ N/A | 🟡 Mock |
| View Details | ❌ N/A | ✅ → labs tab | 🔴 Wrong route |

### Labs Page Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| Create New Lab | ❌ N/A | ✅ Button | 🟡 Not implemented |
| View Details | ✅ → lab detail | ✅ Button | 🟡 Website no detail |
| Filter All | ✅ Working | ✅ Working | ✅ Both Working |
| Filter Active | ✅ Working | ✅ Working | ✅ Both Working |

### Grading Page Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| Auto-Evaluate All | ✅ Works (mock) | ❌ N/A | 🔴 Missing in Website |
| AI-Assisted Grade | ✅ Modal | ✅ Button | 🟡 Different flow |
| Manual Grade | ❌ N/A | ✅ Button | 🔴 Missing in Flutter |
| Download File | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |

### Attendance Page Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| Scan QR | ✅ FAB | ❌ N/A | 🔴 Missing in Website |
| Upload Photo | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Process with AI | ❌ N/A | ✅ Works (mock) | 🔴 Missing in Flutter |
| Export CSV | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Save Session | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |

### Discussion Page Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| Create Thread | ✅ FAB | ❌ N/A | 🔴 Missing in Website |
| Reply | ✅ Shows snackbar | ✅ Works | 🟡 Flutter mock |
| Mark as Answer | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Pin/Unpin | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Close Thread | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |

### Announcements Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| New Announcement | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Post Announcement | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Pin/Unpin | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |
| Delete | ❌ N/A | ✅ Works | 🔴 Missing in Flutter |

### Calendar Buttons

| Button | Flutter | Website | Working? |
|--------|---------|---------|----------|
| Add Event | ✅ FAB | ❌ N/A | 🔴 Missing in Website |
| Go to Today | ✅ Works | ❌ N/A | 🔴 Missing in Website |
| Sync | ✅ Works (mock) | ❌ N/A | 🔴 Missing in Website |
| Week Navigation | ✅ Works | ✅ Works | ✅ Both Working |
| View Toggle | ✅ Month/Week/Day | ✅ Week/List | 🟡 Different |

---

## Recommendations

### Priority 1 - Critical (Must Fix)

**For Website:**
1. Add Analytics Page
2. Add Upload Materials Page  
3. Add Notifications Page
4. Add Settings Page
5. Add Course Detail Page with tabs
6. Add Lab Detail Page with submissions

**For Flutter:**
1. Add Announcements Page
2. Add AI Face Detection Attendance

### Priority 2 - Important

**For Website:**
1. Add Office Hours Page
2. Add AI Assistant
3. Add AI Insights to Dashboard
4. Add more AI Grading features

**For Flutter:**
1. Add Chat functionality
2. Add Discussion reply system
3. Add Performance charts
4. Add Profile bio/skills section

### Priority 3 - Enhancement

**For Both:**
1. Align navigation structure
2. Standardize button behaviors
3. Implement missing mock features
4. Add real API integration

---

## Document End

This document should be used as a reference for aligning features between the Flutter Mobile App and React Website for the TA role. Each team should review this document and implement the missing features to ensure consistency across platforms.
