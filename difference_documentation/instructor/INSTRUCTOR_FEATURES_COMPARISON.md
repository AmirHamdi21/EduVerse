# EduVerse Instructor Features Comparison
## Flutter Mobile App vs React Website

**Document Version:** 1.0  
**Date:** February 2026  
**Purpose:** Comprehensive comparison of instructor role features between Flutter mobile app and React website to identify differences and ensure feature parity.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Navigation & Structure Comparison](#navigation--structure-comparison)
3. [Dashboard Features](#1-dashboard-features)
4. [Courses Management](#2-courses-management)
5. [Course Management (Single Course)](#3-course-management-single-course)
6. [Grading System](#4-grading-system)
7. [Attendance Management](#5-attendance-management)
8. [Assignments](#6-assignments)
9. [AI Features](#7-ai-features)
10. [Reports & Analytics](#8-reports--analytics)
11. [Calendar & Schedule](#9-calendar--schedule)
12. [Chat & Communication](#10-chat--communication)
13. [Notifications](#11-notifications)
14. [Profile Management](#12-profile-management)
15. [Settings](#13-settings)
16. [Announcements](#14-announcements)
17. [Upload Materials](#15-upload-materials)
18. [Search](#16-search)
19. [Student Roster & Waitlist](#17-student-roster--waitlist)
20. [Labs Management](#18-labs-management)
21. [Quizzes Management](#19-quizzes-management)
22. [Summary Tables](#summary-tables)
23. [Recommendations](#recommendations)

---

## Executive Summary

This document provides an exhaustive comparison of the instructor role features between the **Flutter Mobile App** and the **React Website**. The analysis covers every screen, page, feature, button, and functionality to identify gaps and differences between the two platforms.

### Key Findings:

| Aspect | Flutter Mobile App | React Website |
|--------|-------------------|---------------|
| **Total Screens** | 17 dedicated screens | 17 tab-based views |
| **Navigation Style** | Side drawer with categories | Tab-based interface |
| **AI Features** | 4 separate AI tools | 1 consolidated AI Tools page |
| **Missing in Flutter** | Roster/Waitlist, Labs, Quizzes, Discussion Forum | - |
| **Missing in Website** | Upload Materials, Global Search, Calendar Views | - |

---

## Navigation & Structure Comparison

### Flutter Mobile App Navigation (Side Drawer)

**MAIN MENU:**
1. ✅ Dashboard (`/instructor-dashboard`)
2. ✅ My Courses (`/instructor/courses`)
3. ✅ Grading Center (`/instructor/grading`) - badge: 12
4. ✅ Announcements Manager (`/instructor/announcements`)
5. ✅ Attendance Manager (`/instructor/attendance`)
6. ✅ Create Assignment (`/instructor/create-assignment`)
7. ✅ Calendar (`/instructor/calendar`)
8. ✅ Reports & Analytics (`/instructor/reports`)
9. ✅ My Files (`/my-files`)

**AI TOOLS (Highlighted Section):**
1. ✅ AI Teaching Assistant (`/instructor/ai-teaching`)
2. ✅ AI Assistant (`/ai-chat`)
3. ✅ AI Quiz Generator (`/ai-quiz-generator`)
4. ✅ Summarizer (`/summarizer`)

**CONNECT:**
1. ✅ Messages (`/instructor/messages`) - badge: 5
2. ✅ Notifications (`/instructor/notifications`) - badge: 3

**ACCOUNT:**
1. ✅ Profile (`/instructor/profile`)
2. ✅ Settings (`/instructor/settings`)

**Additional Routes (Not in Drawer):**
- `/instructor/course-management` (single course)
- `/instructor/upload-materials`
- `/instructor/search`
- `/instructor/edit-profile`

---

### React Website Navigation (Tabs)

**Overview Section:**
1. ✅ Dashboard

**Teaching Section:**
1. ✅ Courses
2. ✅ Labs
3. ✅ Quizzes
4. ✅ Assignments
5. ✅ Schedule

**Students Section:**
1. ✅ Roster
2. ✅ Waitlist
3. ✅ Grades
4. ✅ Attendance
5. ✅ Analytics

**Communication Section:**
1. ✅ Communication (Announcements)
2. ✅ Discussion
3. ✅ Chat

**Tools Section:**
1. ✅ AI Tools
2. ✅ Settings
3. ✅ Profile

---

### Navigation Differences Summary

| Feature | Flutter | React | Notes |
|---------|---------|-------|-------|
| Navigation Style | Side Drawer | Tab Bar | Different UX patterns |
| AI Tools | 4 separate menu items | 1 consolidated tab | Flutter more granular |
| Labs Management | ❌ Missing | ✅ Present | Add to Flutter |
| Quizzes Management | ❌ Missing | ✅ Present | Add to Flutter |
| Discussion Forum | ❌ Missing | ✅ Present | Add to Flutter |
| Student Roster | ❌ Missing | ✅ Present | Add to Flutter |
| Waitlist | ❌ Missing | ✅ Present | Add to Flutter |
| Upload Materials | ✅ Present | ❌ Missing | Add to Website |
| Global Search | ✅ Present | ❌ Missing | Add to Website |
| Calendar Views | ✅ Day/Week/Month | ⚠️ Schedule only | Website has limited calendar |
| My Files | ✅ Present | ❌ Missing | Add to Website |

---

## 1. Dashboard Features

### Flutter Mobile App Dashboard

**UI Elements:**
- ✅ AI Teaching Overview Card (pending assignments, students at risk, AI suggestions)
- ✅ Quick Access Grid (6 shortcuts)
- ✅ My Courses Carousel
- ✅ Pending Grading Section
- ✅ Upcoming Events Section
- ✅ Side Drawer Navigation
- ✅ App Bar with search, notifications, profile icons
- ✅ Pull-to-refresh
- ✅ Dark/Light theme support

**AI Teaching Card Shows:**
- Pending assignments count
- Students at risk count
- AI-generated suggestions

**Quick Actions (6):**
1. My Courses
2. Create Assignment
3. Grading Center
4. Upload Material
5. Analytics
6. AI Assistant

**Data Displayed:**
- Courses with progress percentage
- Student counts per course
- Pending submissions
- Upcoming events (lectures, deadlines)

---

### React Website Dashboard

**UI Elements:**
- ✅ Metric Cards (3): Active Courses, Pending Grading, Total Students
- ✅ Evy AI Teaching Assistant Card with insights
- ✅ Course Performance Bar Chart
- ✅ Student Engagement Area Chart
- ✅ My Courses Cards Grid
- ✅ Upcoming Teaching List
- ✅ Quick Actions (4 buttons)
- ✅ Recent Activity Timeline
- ✅ Dark/Light theme support

**Metric Cards Show:**
- Active courses count with "NEW" badge
- Pending grading count with "HIGH PRIORITY" badge
- Total students count

**Charts:**
- Course Performance (Bar Chart by course)
- Student Engagement (Area Chart by week)

**Quick Actions (4):**
1. Office Hours
2. Materials
3. Add Task
4. Help Desk

**Evy AI Section:**
- AI quote/insight
- "Review Insights" button
- "Dismiss" button

---

### Dashboard Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| AI Teaching Card | ✅ | ✅ | ✅ Both |
| Performance Charts | ❌ | ✅ Bar + Area Charts | Add to Flutter |
| Quick Actions Count | 6 actions | 4 actions | Flutter has more |
| Courses Display | Carousel | Grid cards | Different style |
| Pending Grading Section | ✅ Detailed | ✅ Metric only | Flutter more detailed |
| Upcoming Events | ✅ List | ✅ List | ✅ Both |
| Recent Activity | ❌ | ✅ Timeline | Add to Flutter |
| Student Engagement Chart | ❌ | ✅ Area chart | Add to Flutter |
| Pull-to-refresh | ✅ | ❌ | Add to Website |

---

## 2. Courses Management

### Flutter Mobile App - My Courses Screen

**Views Available:**
- ✅ Grid View (2 columns)
- ✅ List View (full width)
- ✅ Compact View (minimal rows)

**Statistics Dashboard:**
- Total Courses (animated counter)
- Total Students
- Engagement Rate (%)
- Trends with +/- indicators

**Filter Options:**
- Search by name/code/description
- Status filter: All, Published, Draft, Archived
- Category filter: Programming, Data Science, Web Dev, Mobile, AI/ML, Database
- Sort: Newest, Oldest, Most Students, Least Students, A-Z, Z-A, Top Engagement

**Course Card Shows:**
- Course code badge
- Course name
- Status badge (Published/Draft/Archived)
- Student count
- Engagement percentage
- Completion progress bar
- Milestone badges ("150+ Students! 🎉")

**Actions per Course:**
- Manage (opens course management)
- Materials
- Edit
- Analytics
- Duplicate
- Share
- Delete
- Archive

**Bulk Actions (Selection Mode):**
- Archive selected
- Publish selected
- Delete selected

**FAB Action:**
- Create Course

---

### React Website - Courses Page

**Layout:**
- Grid cards (1→2→3 columns responsive)
- AI Tools sidebar (320px)

**Filter Options:**
- Search by name/code
- Semester filter (dynamic from courses)
- Status filter: All, Active, Archived
- Sort: Course Name, Course Code, Students Enrolled

**Course Card Shows:**
- Gradient background with emoji
- Course name
- Course type label
- Student count
- Next lecture schedule
- "Open Course" button

**AI Tools Sidebar:**
- Create Quiz button
- Analyze Course button

**Create/Edit Course Modal Fields:**
- Course Code (required)
- Credits
- Course Name (required)
- Semester
- Capacity
- Schedule
- Room
- Prerequisites
- Description

---

### Courses Management Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| View Modes | 3 (Grid/List/Compact) | 1 (Grid only) | Flutter more options |
| Statistics Dashboard | ✅ Animated counters | ❌ | Add to Website |
| Search | ✅ Name/Code/Desc | ✅ Name/Code | ✅ Both |
| Status Filter | All/Published/Draft/Archived | All/Active/Archived | Slightly different |
| Category Filter | ✅ 6 categories | ❌ | Add to Website |
| Sort Options | 7 options | 3 options | Flutter has more |
| Bulk Actions | ✅ Selection mode | ❌ | Add to Website |
| Duplicate Course | ✅ | ❌ Not in list | Add to Website |
| Share Course | ✅ | ❌ | Add to Website |
| Preview Modal | ✅ Long-press | ❌ | Add to Website |
| AI Sidebar | ❌ | ✅ | Different approach |
| Course Creation Fields | Less detailed | ✅ 9 fields | Website more detailed |
| Progress Bar | ✅ | ❌ | Add to Website |
| Engagement Score | ✅ | ❌ | Add to Website |

---

## 3. Course Management (Single Course)

### Flutter Mobile App - Course Management Screen

**Tabs (4):**
1. Overview - Course stats, description
2. Assignments - Assignment list with submission counts
3. Materials - Course materials
4. Students - Student roster

**FAB Options:**
- Create Assignment
- Upload Material
- Post Announcement

**Settings Modal:**
- Edit Course
- Archive Course
- Delete Course

---

### React Website - Course Detail

**Tabs (11):**
1. Dashboard (Overview) - Summary, deadlines, AI insights, activity
2. Lectures - Week-based video lectures
3. Materials - File upload, materials list
4. Assignments - Create, edit, grade, AI auto-grade
5. Grading - AutoGradingSystem component
6. Students - Enrolled students list
7. Registration Period - Registration management, TA collaboration
8. Settings - Feature toggles
9. Analytics - Performance metrics
10. Announcements - Create, view announcements
11. AI Tools - Generate quiz, Analyze performance

**Assignment Card Actions:**
- View Submissions
- Edit
- Grade Manually
- AI Auto-Grading
- Publish (for drafts)

---

### Course Management Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Tab Count | 4 tabs | 11 tabs | React more comprehensive |
| Lectures Tab | ❌ | ✅ Week-based | Add to Flutter |
| Grading Tab | ❌ (separate screen) | ✅ Integrated | Different approach |
| Registration Period | ❌ | ✅ | Add to Flutter |
| TA Collaboration | ❌ | ✅ | Add to Flutter |
| Feature Toggles | ❌ | ✅ | Add to Flutter |
| AI Insights | ❌ | ✅ | Add to Flutter |
| Recent Activity | ❌ | ✅ 3 activities | Add to Flutter |
| Upcoming Deadlines | ❌ | ✅ 3 items | Add to Flutter |
| FileUploadDropzone | ❌ | ✅ Drag-drop | Different approach |
| AI Auto-Grading | ✅ (AI screen) | ✅ Per assignment | ✅ Both |

---

## 4. Grading System

### Flutter Mobile App - Grading Center

**Tabs (4):**
1. All - All submissions
2. Pending - Pending grading
3. Graded - Already graded
4. Late - Late submissions

**Filter Options:**
- Search by student name/assignment
- Course dropdown filter
- Tab-based status filter

**Statistics Dashboard:**
- Pending count
- Graded count
- Late count
- Total submissions

**Submission Card Shows:**
- Student avatar/initials
- Student name
- Assignment title
- Course name
- Submission timestamp (relative)
- Status badge (Pending/Graded/Late)
- Grade & percentage (if graded)
- Late indicator with days

**Grade Dialog:**
- Large grade input (0-100)
- Quick grade buttons (100%, 90%, 80%, 70%, 60%, 50%)
- Feedback textarea
- Validation with error messages
- Submit button

**Actions:**
- View Details (per submission)
- Grade Now (opens dialog)
- View All (navigate to full list)

---

### React Website - Grades System

**GradesTable Component:**
- 6-column table: Student, Email, Assignment, Score, Grade, Actions
- Search by name/assignment/email
- Sort by Student, Assignment, Score
- Grade badge (A, A-, B+, etc.)
- Edit/Delete actions per row

**GradeModal:**
- Student field (read-only)
- Assignment field (read-only)
- Score input (0-100)
- Letter Grade (auto-calculated, read-only)
- Save Changes button

**AutoGradingSystem Component:**
- Two-panel layout: Submissions list (left), Details (right)
- Auto-Grade All button
- Per-submission status: Pending, Auto-Graded, Reviewed, Finalized
- Expandable answer cards
- "Needs Review" indicators
- Inline score/feedback editing
- Finalize Grade action

**Grading Suggestions (AI):**
- Mock suggestions in constants
- Auto-grade functionality

---

### Grading System Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Tab-based filtering | ✅ 4 tabs | ❌ Single view | Flutter better organized |
| Statistics Dashboard | ✅ Animated | ❌ | Add to Website |
| Course Filter | ✅ Dropdown | ❌ | Add to Website |
| Quick Grade Buttons | ✅ 6 percentages | ❌ | Add to Website |
| Letter Grade Display | ✅ A/B/C/D/F | ✅ A/A-/B+ etc | ✅ Both (Website more granular) |
| Feedback Input | ✅ | ❌ Not in modal | Add to Website modal |
| Auto-Grading System | ❌ (separate AI) | ✅ Integrated | Add to Flutter grading |
| Bulk Auto-Grade | ❌ | ✅ Auto-Grade All | Add to Flutter |
| Needs Review Flag | ❌ | ✅ | Add to Flutter |
| Per-Answer Grading | ❌ | ✅ Expandable | Add to Flutter |
| Finalize Action | ❌ | ✅ | Add to Flutter |
| Late Indicator | ✅ Days late | ❌ | Add to Website |
| Skeleton Loading | ✅ | ❌ | Add to Website |

---

## 5. Attendance Management

### Flutter Mobile App - Attendance Manager

**UI Elements:**
- Course & Week selector dropdowns
- AI Alert Card (low attendance detection)
- Statistics Card (4 stats grid)
- Quick Actions bar
- Filter Chips
- Search Bar
- Student Cards list

**Statistics Grid:**
- Present count + percentage
- Absent count + percentage
- Late count + percentage
- Progress (marked/total)

**Quick Actions (4):**
1. All Present (green)
2. All Absent (red)
3. Clear All (gray)
4. QR Scan (blue, primary)

**Filter Chips:**
- All, Unmarked, Present, Absent

**Student Card Shows:**
- Avatar with initials
- Student name
- Student ID
- Note indicator (if note exists)
- Attendance percentage (circular progress)
- Status buttons (Present/Late/Absent)
- Edit Note button

**Student Detail Sheet:**
- Overall Rate percentage
- Last Attended date
- Classes Attended (X/Y)
- Add Note textarea
- Save Note button

**Actions:**
- Mark individual status
- Mark all present/absent
- Clear all marks
- QR scan (coming soon)
- Save attendance
- Export attendance (PDF/Excel/Share)
- Notify students (absent/low attendance/all)
- Edit student notes

---

### React Website - Attendance System

**AttendanceTable Component:**
- 6-column table: Date, Present, Absent, Total, Attendance %, Actions
- Search by date
- Add Record button
- Edit/Delete per row
- Percentage color-coding (≥80% green, <80% yellow)

**AttendanceModal:**
- Date input (required)
- Present count input
- Absent count input
- Total (calculated, read-only)
- Save/Cancel buttons

**AI Attendance Features (Separate Folder):**

**AIAttendanceContainer:**
- View states: upload, results, history
- Tab navigation

**AIAttendanceUpload:**
- File upload zone (jpg/jpeg/png, max 5MB)
- Photo guidelines info
- Process with AI button
- 5-second processing simulation

**AIAttendanceResults:**
- 4 stats cards: Total, Present, Absent, Uncertain
- "Needs Review" section
- All Students table
- Edit mode toggle
- Status change buttons
- Export to CSV
- Save/Cancel actions

**AIAttendanceHistory:**
- Session cards with:
  - Course section
  - Date/time
  - Students detected count
  - Attendance rate percentage
  - View Details button

---

### Attendance Management Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Per-Student Marking | ✅ Individual buttons | ❌ Aggregate only | Flutter more detailed |
| AI Low Attendance Alert | ✅ | ❌ | Add to Website |
| Statistics Grid | ✅ 4 stats | ❌ | Add to Website |
| Quick Actions | ✅ 4 buttons | ❌ | Add to Website |
| QR Scan | ✅ Placeholder | ❌ | Add to both |
| Student Notes | ✅ | ❌ | Add to Website |
| Circular Progress | ✅ Per student | ❌ | Add to Website |
| Student Detail Sheet | ✅ | ❌ | Add to Website |
| Export Options | ✅ PDF/Excel/Share | ❌ | Add to Website |
| Notify Students | ✅ 3 options | ❌ | Add to Website |
| AI Photo Detection | ❌ | ✅ Full workflow | Add to Flutter |
| Confidence Scores | ❌ | ✅ Per student | Add to Flutter |
| Manual Override | ❌ | ✅ | Add to Flutter |
| Session History | ❌ | ✅ | Add to Flutter |
| Uncertain Status | ❌ | ✅ | Add to Flutter |
| CSV Export | ❌ | ✅ | Add to Flutter |

---

## 6. Assignments

### Flutter Mobile App - Create Assignment

**Assignment Types (3):**
1. Assignment (blue)
2. Lab (green)
3. Project (purple)

**Sections (Collapsible):**

**Basic Details:**
- Title
- Short Description
- Course Dropdown
- Module Dropdown

**Instructions:**
- Rich text editor
- Formatting toolbar (Bold, Italic, List, Code)

**Questions:**
- Add/Edit/Delete questions
- Question types: Short Answer, Multiple Choice, Essay, True/False
- Points per question
- Hint option
- AI Generate button (placeholder)

**Attachments:**
- Drag-drop zone
- Choose Files button
- File type icons

**Deadline Settings:**
- Due Date picker
- Due Time picker
- Toggles: Late Submissions, Plagiarism Detection, Group Work, Auto-Grading
- Difficulty slider (Easy/Medium/Hard/Very Hard)

**Lab-Specific Fields:**
- Lab Room dropdown
- Duration selector (+/- 30 min)
- Lab Objectives
- Equipment & Materials
- Lab Procedure
- Safety Instructions
- Safety Equipment checkboxes (Coat, Glasses, Gloves)
- Require Lab Report toggle

**Project-Specific Fields:**
- Project Scope
- Learning Objectives
- Resources & References
- Team Size (Min/Max)
- Allow Individual toggle
- Project Milestones (add/edit/remove)
- Deliverables (Report, Code, Presentation, Demo, Documentation)
- Requirements (Presentation, Documentation, Peer Review)

**Actions:**
- Save Draft
- Preview
- Schedule
- Assign to Class

---

### React Website - Assignments

**AssignmentsList Component:**
- Grid layout (1→2→3 columns)
- Search by title
- Status filter (All/Draft/Open/Closed)
- Assignment cards with:
  - Title
  - Due date
  - Submissions count
  - Status badge (Draft/Open/Closed)
  - Open/Close buttons

**AssignmentModal:**
- Title (required)
- Due Date (required)
- Status dropdown (Draft/Open/Closed)
- Submissions count (edit mode only)
- Save/Cancel buttons

**Course Detail - Assignments Tab:**
- Create New Assignment button
- Assignment cards with:
  - Title
  - Subject tag
  - Due date
  - Submission status (X/Y)
  - Description
  - Attached files
  - Status badge
  - Actions: View Submissions, Edit, Grade Manually, AI Auto-Grading, Publish

---

### Assignment Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Assignment Types | ✅ 3 types | ❌ 1 type | Flutter more comprehensive |
| Lab-Specific Fields | ✅ Full section | ❌ Separate Labs tab | Different approach |
| Project-Specific | ✅ Milestones, Deliverables | ❌ | Add to Website |
| Questions Builder | ✅ | ❌ | Add to Website |
| Rich Text Editor | ✅ | ❌ | Add to Website |
| Difficulty Slider | ✅ 4 levels | ❌ | Add to Website |
| Plagiarism Detection | ✅ Toggle | ❌ | Add to Website |
| Group Work Toggle | ✅ | ❌ | Add to Website |
| Auto-Grading Toggle | ✅ | ❌ | Add to Website |
| Safety Equipment | ✅ Lab-specific | ❌ | Add to Website |
| Team Size Config | ✅ Project-specific | ❌ | Add to Website |
| Attachments | ✅ Drag-drop | ✅ In course detail | ✅ Both |
| Schedule Assignment | ✅ | ❌ | Add to Website |
| Preview | ✅ | ❌ | Add to Website |
| Save Draft | ✅ | ✅ Status=Draft | ✅ Both |
| AI Auto-Grading | ❌ In assignments | ✅ Button per assignment | Add to Flutter |

---

## 7. AI Features

### Flutter Mobile App - AI Tools

**AI Teaching Assistant Screen:**
- 5 AI Modes with colors/icons:
  1. Create Content (Blue)
  2. Analyze Data (Cyan)
  3. Rewrite/Enhance (Purple)
  4. Course Insights (Amber)
  5. Communication (Green)

**Quick Actions (5):**
1. Generate 10 MCQs
2. Summarize Lecture
3. Create Lesson Plan
4. Generate Rubric
5. Write Feedback

**Suggested Prompts (4):**
- Create a pop quiz
- Analyze performance trends
- Generate discussion questions
- Create study materials

**Chat Features:**
- User/AI message bubbles
- Typing indicator (3 animated dots)
- Message actions: Regenerate, Easier, Harder, Copy, Export
- Attachment options: Document, Image, Spreadsheet
- Export formats: PDF, Word, Text

**Drawer AI Items (4):**
1. AI Teaching Assistant
2. AI Assistant (General chat)
3. AI Quiz Generator
4. Summarizer

---

### React Website - AI Tools

**AIToolsPage (4-Column Grid):**

**1. Quiz Generator:**
- Difficulty selection (Easy/Medium/Hard)
- Generate Quiz button
- Upload from Lecture File button

**2. Auto-Grading "Evy":**
- Auto-Grade All button
- Generate Feedback button
- Analyze Submissions button

**3. Materials Generator:**
- Topic input field
- Upload Material button
- Generate Slides button
- Generate Summary button

**4. AI Insights:**
- 3 Alert cards (performance, engagement, at-risk)
- View Details button
- Send Tips button

**Additional Tools:**
- Voice to Text (VoiceRecorder component)
- Image to Text (OCR) (ImageTextExtractor component)
- Smart Teaching Plan (Generate Plan button)
- AI Question Editor (edit/delete/reorder questions)
- Floating AI Chatbot button

**AIChatbot Component:**
- Quick actions by role (instructor/student)
- Context-aware responses
- Copy, thumbs up/down feedback
- Minimize/Maximize controls

**AIQuestionEditor:**
- Add/Edit/Delete questions
- Question types: Multiple Choice, True/False, Short Answer, Essay
- Difficulty badge (Easy/Medium/Hard)
- Points per question
- Drag-and-drop reorder
- Generate More button

**AutoGradingSystem:**
- Two-panel layout
- Bulk auto-grade
- Per-answer editing
- Finalize grades

---

### AI Features Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| AI Modes | ✅ 5 modes | ❌ | Add to Website |
| Quick Actions | ✅ 5 chat actions | ✅ Quiz/Grade/Materials | ✅ Both |
| Voice to Text | ❌ | ✅ | Add to Flutter |
| Image to Text (OCR) | ❌ | ✅ | Add to Flutter |
| Smart Teaching Plan | ❌ | ✅ | Add to Flutter |
| AI Question Editor | ❌ | ✅ Full CRUD + reorder | Add to Flutter |
| Materials Generator | ❌ | ✅ | Add to Flutter |
| AI Insights Cards | ❌ | ✅ 3 alerts | Add to Flutter |
| Message Regenerate | ✅ | ❌ | Add to Website |
| Easier/Harder Options | ✅ | ❌ | Add to Website |
| Export Chat | ✅ PDF/Word/Text | ❌ | Add to Website |
| Attachment Upload | ✅ 3 types | ❌ | Add to Website |
| Chatbot Minimize | ❌ | ✅ | Add to Flutter |
| Copy Message | ✅ | ✅ | ✅ Both |
| Feedback Thumbs | ❌ | ✅ | Add to Flutter |
| Difficulty Selection | ❌ | ✅ Per quiz | Add to Flutter |

---

## 8. Reports & Analytics

### Flutter Mobile App - Reports & Analytics

**Tabs (3):**
1. Performance
2. Attendance
3. Analytics

**Course Dropdown:** Multi-select

**Course Summary Card:**
- Total students
- Average grade
- Attendance rate
- At-risk count
- AI insight text

**Search Bar:** Search students by name/ID

**Selection Mode:**
- Select multiple students
- Export selected

**Student Performance Card:**
- Name, ID
- Average grade (color-coded A/B/C/D/F)
- Performance breakdown (Assignments, Labs, Quizzes, Midterm)
- At-risk flag
- Trend indicator (improving/declining)

**Grade Distribution:**
- A/B/C/D/F counts

**Engagement Metrics:**
- Assignment submission (92%)
- Lab completion (88%)
- Discussion participation (75%)

**Attendance Overview:**
- Present (85%), Absent (10%), Late (5%)
- AI insights

**Student Detail Sheet:**
- Full student info
- Contact button
- Export button

**Export Options:**
- PDF
- CSV
- Excel

---

### React Website - Analytics

**AnalyticsPage:**
- Filter dropdowns: Course, Time Period, Analytics Type
- Course Performance line chart (6 weeks)
- Engagement Analytics multi-line chart
- Attendance bar chart
- Course Comparison bar chart

**Key Metrics Cards:**
- Average Grade (82%)
- Engagement Rate (76%)

**Low-Performance Topics (4):**
- Topic name + percentage

**At-Risk Students (5):**
- Name + reason
- View All button
- Message button

**AI Insights (4 cards):**
- Performance improvement
- Struggling topic
- Recommendation
- Generate Teaching Plan

**Export Modal:**
- CSV, Excel, PDF options

**ReportsAnalytics:**
- Performance Chart
- Trend Chart
- Assignment Performance table
- Attendance by Section table
- Key Metrics (4 cards)
- Top Performers list (5)
- At-Risk Students list (3)
- Recent Activities feed (5)
- Tabs: Overview, Performance, Engagement

---

### Reports & Analytics Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Tab Organization | ✅ 3 tabs | ✅ Different tabs | Different approach |
| Multi-select Students | ✅ | ❌ | Add to Website |
| Line Charts | ❌ | ✅ Performance/Engagement | Add to Flutter |
| Bar Charts | ❌ | ✅ Attendance/Comparison | Add to Flutter |
| Grade Distribution | ✅ | ❌ | Add to Website |
| Performance Breakdown | ✅ Progress bars | ❌ | Add to Website |
| At-Risk Students | ✅ | ✅ | ✅ Both |
| Low-Performance Topics | ❌ | ✅ | Add to Flutter |
| AI Insights | ✅ Text | ✅ 4 cards | ✅ Both |
| Generate Teaching Plan | ❌ | ✅ | Add to Flutter |
| Recent Activities | ❌ | ✅ | Add to Flutter |
| Top Performers | ❌ | ✅ | Add to Flutter |
| Contact Student | ✅ | ❌ | Add to Website |
| Time Period Filter | ❌ | ✅ | Add to Flutter |

---

## 9. Calendar & Schedule

### Flutter Mobile App - Calendar

**Views (3):**
1. Month View - Full calendar grid
2. Week View - 7-day hourly layout
3. Day View - Single day detailed

**UI Elements:**
- Calendar Header with navigation
- Filter Dropdown by event type
- View Selector buttons
- Upcoming Events list

**Event Types (7):**
1. Lecture (Blue)
2. Lab (Purple)
3. Office Hours (Green)
4. Meeting (Amber)
5. Deadline (Red)
6. Grading (Cyan)
7. Exam (Pink)

**Actions:**
- Add Event (FAB + header button)
- Filter by type
- Select dates
- Double-tap to add event
- View event details (bottom sheet)
- Edit/Delete events

---

### React Website - Schedule

**Views:**
- Week view (default selected)
- Month/Week/Day toggle buttons (Month and Day not fully implemented)

**UI Elements:**
- Date range display
- "Today" button
- Course filter dropdown
- Event type filter dropdown
- Time grid (9 AM - 4 PM)
- Color-coded events

**Weekly Statistics:**
- Total Hours (18.5h)
- Lectures count (6)
- Labs count (4)
- Conflicts count (0)

**AI Features:**
- Evy Scheduling Assistant
- Detect Conflicts button
- Optimize Schedule button

---

### Calendar Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Month View | ✅ Full grid | ⚠️ Button only | Implement in Website |
| Week View | ✅ | ✅ | ✅ Both |
| Day View | ✅ | ⚠️ Button only | Implement in Website |
| Event Types | 7 types | 4 visible (Lecture, Lab, Quiz, Office) | Website needs more |
| Add Event | ✅ Full form | ❌ | Add to Website |
| Edit Event | ✅ | ❌ | Add to Website |
| Delete Event | ✅ | ❌ | Add to Website |
| Event Details Sheet | ✅ | ❌ | Add to Website |
| Filter by Type | ✅ | ✅ | ✅ Both |
| Conflict Detection | ❌ | ✅ AI | Add to Flutter |
| Optimize Schedule | ❌ | ✅ AI | Add to Flutter |
| Weekly Statistics | ❌ | ✅ 4 stats | Add to Flutter |
| Today Button | ❌ | ✅ | Add to Flutter |

---

## 10. Chat & Communication

### Flutter Mobile App - Chat

**Views:**
- Conversation List (sidebar on desktop, full on mobile)
- Chat Detail View

**Filter Chips (4):**
- All
- Students
- Colleagues
- Groups

**Conversation Card Shows:**
- Avatar/initials
- Name
- Last message preview
- Timestamp (relative)
- Unread count badge
- Online status (green dot)
- Pinned indicator
- Muted indicator

**Conversation Types:**
- Student (1-on-1)
- Colleague (1-on-1)
- Group (multiple participants)

**Chat Features:**
- Message bubbles (user/others)
- Timestamps
- Read status
- Sender info (in groups)
- Message input with send button

**Actions:**
- Create new chat
- Search conversations
- Filter by type
- Pin/Unpin conversations
- Mute/Unmute
- Delete conversations
- Mark as read
- Send messages

---

### React Website - Communication

**CommunicationPage Tabs (3):**
1. Announcements - Create, edit, delete, send notifications
2. Course Chats - MessagingChat component
3. Direct Messages - MessagingChat component

**AI Communication Assistant:**
- Generate Announcement
- Summarize Chat
- Suggest Reply

**MessagesPanel (Separate Component):**
- WhatsApp-style UI
- Conversation list (left)
- Chat area (right)
- Online status indicators
- Read receipts (single/double check)
- Phone/Video call buttons
- Attachment button
- Enter to send (Shift+Enter for newline)

**DiscussionPage:**
- Discussion forum (separate tab)

---

### Chat & Communication Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Filter Chips | ✅ 4 types | ❌ | Add to Website |
| Pin/Mute Conversations | ✅ | ❌ | Add to Website |
| Group Chats | ✅ | ❌ | Add to Website |
| Discussion Forum | ❌ | ✅ Separate tab | Add to Flutter |
| Video Calls | ❌ | ✅ Button | Add to Flutter |
| Voice Calls | ❌ | ✅ Button | Add to Flutter |
| Read Receipts | ✅ | ✅ Check marks | ✅ Both |
| Online Status | ✅ | ✅ | ✅ Both |
| AI Generate Announcement | ❌ | ✅ | Add to Flutter |
| AI Summarize Chat | ❌ | ✅ | Add to Flutter |
| AI Suggest Reply | ❌ | ✅ | Add to Flutter |
| Attachments | ❌ | ✅ Button | Add to Flutter |
| Responsive Layout | ✅ Desktop/Mobile | ✅ | ✅ Both |
| Long-press Menu | ✅ | ❌ | Add to Website |

---

## 11. Notifications

### Flutter Mobile App - Notifications

**Tabs (3):**
1. All
2. Unread
3. Read

**Filter Chips (6):**
- All, Submissions, Grading, Messages, Deadlines, System

**Search:** Search by title, message, student, course

**Notification Types (7):**
- submission
- grading
- message
- deadline
- attendance
- system
- announcement

**Notification Card Shows:**
- Unread indicator dot
- Type-based icon & color
- Title
- Message
- Timestamp (relative)
- Student name (optional)
- Course name (optional)
- Delete button

**Actions:**
- Search notifications
- Filter by category
- Filter by read status (tabs)
- Mark as read (single/all)
- Delete notification
- Undo delete
- Pull-to-refresh

---

### React Website - Notifications

**Header Features:**
- Notification icon with badge count
- Dropdown panel on click

**No dedicated notifications page found** - Notifications appear to be handled via header dropdown.

---

### Notifications Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Dedicated Screen | ✅ Full screen | ❌ Header dropdown only | Add to Website |
| Tab Filtering | ✅ All/Unread/Read | ❌ | Add to Website |
| Category Chips | ✅ 6 categories | ❌ | Add to Website |
| Search | ✅ | ❌ | Add to Website |
| Mark All Read | ✅ | ❌ | Add to Website |
| Delete with Undo | ✅ | ❌ | Add to Website |
| Pull-to-refresh | ✅ | ❌ | N/A (web) |
| Notification Types | 7 types | Unknown | Document Website |

---

## 12. Profile Management

### Flutter Mobile App - Profile

**Profile View Screen:**
- Cover photo area
- Profile avatar (100x100)
- Name, title, department
- Rating badge (4.8 stars)
- Join date badge

**Stats Section (3):**
- Courses (4)
- Students (156)
- Assignments (28)

**Sections:**
- About/Bio
- Specialization tags
- Education history (3 entries)
- Current courses list

**Actions:**
- Edit Profile button
- Settings button
- Help/Support
- Logout (with confirmation)

**Edit Profile Screen (16 fields):**

**Personal Information:**
- First Name
- Last Name
- Email
- Phone
- Location
- Date of Birth
- Bio (3 lines)

**Professional Information:**
- Title
- Department
- Employee ID (read-only)
- Specialization
- Office
- Office Hours

**Social & Academic:**
- Website
- LinkedIn
- Google Scholar
- ResearchGate

**Actions:**
- Change cover photo
- Change profile picture
- Save changes
- Discard changes dialog

---

### React Website - Profile

**Profile Card:**
- Avatar (initials-based)
- Name & Department
- Active status badge
- Member Since, Sections Teaching, Total Students

**Quick Actions:**
- Change Password
- Notification Settings
- Language & Region

**Personal Information (Editable):**
- Full Name
- Email Address
- Phone Number
- Department
- Office Location
- Office Hours
- Bio

**Education (Read-only):**
- Degree, Institution, Year entries

**Specialization (Read-only):**
- Tag badges

**Achievements (Read-only):**
- Bulleted list

**Edit Mode:**
- Toggle edit mode
- Camera icon for photo
- Save/Cancel buttons

---

### Profile Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Cover Photo | ✅ | ❌ | Add to Website |
| Rating Display | ✅ | ❌ | Add to Website |
| Separate Edit Screen | ✅ | ❌ Inline edit | Different approach |
| Total Fields | 16 | 7 editable | Flutter more comprehensive |
| Social Links | ✅ 4 fields | ❌ | Add to Website |
| Education Editable | ❌ Read-only | ❌ Read-only | Same |
| Quick Actions | ❌ | ✅ 3 buttons | Add to Flutter |
| Change Password | ❌ | ✅ | Add to Flutter |
| Member Since | ✅ | ✅ | ✅ Both |
| Employee ID | ✅ | ❌ | Add to Website |
| Location | ✅ | ❌ | Add to Website |
| Date of Birth | ✅ | ❌ | Add to Website |

---

## 13. Settings

### Flutter Mobile App - Settings

**Profile Section:**
- Click to view profile

**Preferences:**
- Appearance
- Language
- Notifications

**Teaching Settings (Modal Sheets):**
- Grading Preferences
- Assignment Defaults
- Attendance Settings

**Privacy & Security:**
- Privacy
- Two-Factor Auth
- Connected Devices
- Login History

**Data & Storage:**
- Storage Usage
- Export Data (4 options)

**Support:**
- Help Center
- Send Feedback (modal)
- Share App

**Legal:**
- Terms of Service
- Privacy Policy
- About

**Account:**
- Logout (with confirmation)

---

### React Website - Settings

**Profile Information:**
- Photo upload (JPG, PNG, GIF, Max 2MB)
- Full Name, Title, Email, Phone, Department, Office, Bio
- Save Changes button

**Account Settings:**
- Change Password button
- Two-Factor Authentication toggle
- Login Activity display
- Notification Preferences (5 toggles)
- Language dropdown (English, Spanish, French, Arabic)

**Teaching Preferences:**
- Classroom toggles (Analytics, Auto Grading, Smart Attendance, At Risk)
- AI Preferences (Difficulty, Explanation Style, Tone)

**Privacy & Sharing:**
- Allow TAs Access
- Allow Auto Announcements
- Hide Email From Students

**Danger Zone:**
- Deactivate Account
- Delete Account

---

### Settings Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Appearance/Theme | ✅ | ❌ | Add to Website |
| Language Setting | ✅ Navigation | ✅ Dropdown | ✅ Both |
| Teaching Settings | ✅ 3 modals | ✅ Inline toggles | ✅ Both |
| AI Preferences | ❌ | ✅ 3 settings | Add to Flutter |
| Connected Devices | ✅ | ❌ | Add to Website |
| Login History | ✅ | ✅ Activity | ✅ Both |
| Storage Usage | ✅ | ❌ | Add to Website |
| Export Data | ✅ 4 options | ❌ | Add to Website |
| Send Feedback | ✅ Modal | ❌ | Add to Website |
| Share App | ✅ | ❌ | N/A (Mobile only) |
| Deactivate Account | ❌ | ✅ | Add to Flutter |
| Delete Account | ❌ | ✅ | Add to Flutter |
| Privacy Toggles | ❌ | ✅ 3 toggles | Add to Flutter |

---

## 14. Announcements

### Flutter Mobile App - Announcement Manager

**Filters:**
- Search bar
- Filter chips: All, Published, Scheduled, Draft

**Announcement Card Shows:**
- Title
- Content preview
- Status badge
- Created/Published/Scheduled date
- Audience
- Total audience count
- Read count
- Attachments list

**Actions per Announcement:**
- Edit
- Delete (with confirmation)
- Analytics (published only)
- Publish (drafts only)

**Analytics Dialog:**
- Total views
- Read rate percentage
- Views over time (7-day chart)
- AI insights

**Create/Edit Form:**
- Title
- Content
- Status
- Audience
- Scheduled time
- Attachments

**FAB:** New Announcement

---

### React Website - Communication (Announcements Tab)

**Announcements List:**
- Title
- Course badge
- Date
- Content
- Scheduled indicator

**Actions:**
- Edit
- Delete
- Send notification

**Filters:**
- Course dropdown
- Search field

**Create Announcement Button**

**AI Features:**
- Generate Announcement (AI)
- Summarize Chat
- Suggest Reply

---

### Announcements Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Dedicated Screen | ✅ | ❌ Tab only | Add to Website |
| Filter Chips | ✅ 4 status | ❌ | Add to Website |
| Search | ✅ | ✅ | ✅ Both |
| Analytics Dialog | ✅ Views, Rate, Chart | ❌ | Add to Website |
| AI Insights | ✅ | ❌ | Add to Website |
| Schedule Announcements | ✅ | ✅ | ✅ Both |
| Attachments | ✅ | ❌ | Add to Website |
| Read Count | ✅ | ❌ | Add to Website |
| Audience Selection | ✅ | ❌ | Add to Website |
| AI Generate | ❌ | ✅ | Add to Flutter |
| Course Badge | ✅ | ✅ | ✅ Both |

---

## 15. Upload Materials

### Flutter Mobile App - Upload Materials

**Tabs (2):**
1. Upload - Course/Module selectors, drop zone, queue
2. Materials - List of uploaded materials

**Course/Module Selectors:**
- Course dropdown
- Module dropdown (dependent)

**Upload Options (3):**
1. File upload
2. Link add (URL + title)
3. Folder upload (coming soon)

**Quick Upload Buttons (3):**
- Documents
- Videos
- Links

**Upload Queue:**
- File name, size, type
- Progress percentage
- Status: pending, uploading, processing, completed, failed
- Cancel/Retry/Remove actions

**Materials List:**
- Material name, description
- File type icon
- File size
- Upload timestamp
- Download count
- Visibility toggle
- Tags

**Material Actions:**
- Edit (name, description)
- Delete
- Toggle visibility
- Download
- Search

**Material Type Filter:** Filter chips by type

---

### React Website - Materials

**Course Detail - Materials Tab:**
- FileUploadDropzone component
- Accepted: PDF, images, videos, .doc, .docx, .ppt, .pptx
- Max files: 10
- Max size: 50MB

**Materials List:**
- File icon
- Filename
- Download button

**No dedicated Upload Materials page.**

---

### Upload Materials Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Dedicated Screen | ✅ | ❌ | Add to Website |
| Tab Organization | ✅ Upload/Materials | ❌ | Add to Website |
| Upload Queue | ✅ Progress tracking | ❌ | Add to Website |
| Course/Module Selection | ✅ | ❌ | Add to Website |
| Link Embedding | ✅ | ❌ | Add to Website |
| Quick Upload Buttons | ✅ 3 types | ❌ | Add to Website |
| Upload Status | ✅ 5 statuses | ❌ | Add to Website |
| Cancel/Retry | ✅ | ❌ | Add to Website |
| Material Management | ✅ Full CRUD | ❌ Download only | Add to Website |
| Visibility Toggle | ✅ | ❌ | Add to Website |
| Download Count | ✅ | ❌ | Add to Website |
| Search Materials | ✅ | ❌ | Add to Website |
| Type Filtering | ✅ | ❌ | Add to Website |
| Drag-Drop Upload | ✅ | ✅ | ✅ Both |

---

## 16. Search

### Flutter Mobile App - Search

**Search Input:** Real-time with 300ms delay

**Category Chips (7):**
- All, Students, Courses, Assignments, Grades, Materials, Announcements

**Recent Searches:**
- History chips
- Individual remove
- Clear All button

**Quick Actions Grid (6):**
1. Grade Submissions
2. Create Assignment
3. Upload Materials
4. Post Announcement
5. Take Attendance
6. View Reports

**Search Tips Box:**
- 3 tips with bullet points

**Search Results:**
- Grouped by category
- Category headers with counts
- Result cards (title, subtitle, icon)

---

### React Website - Search

**Header Global Search:**
- Search icon in header
- Modal search (Ctrl/Cmd + K)

**No dedicated search page found.**

---

### Search Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Dedicated Screen | ✅ | ❌ Modal only | Add to Website |
| Category Filtering | ✅ 7 categories | ❌ | Add to Website |
| Recent Searches | ✅ | ❌ | Add to Website |
| Quick Actions | ✅ 6 actions | ❌ | Add to Website |
| Search Tips | ✅ | ❌ | Add to Website |
| Grouped Results | ✅ By category | ❌ | Add to Website |
| Keyboard Shortcut | ❌ | ✅ Ctrl+K | N/A (Mobile) |
| Real-time Search | ✅ | Unknown | Document Website |

---

## 17. Student Roster & Waitlist

### Flutter Mobile App

**❌ NOT IMPLEMENTED** - No dedicated roster or waitlist screens found in Flutter.

Students are only viewable in:
- Course Management → Students Tab (basic list)
- Reports → Student cards

---

### React Website - Roster & Waitlist

**RosterTable:**
- 5-column table: Student Name, Email, Status, Grade, Actions
- Search by name/email/status
- Sort by Name/Email/Status
- Status badges: Enrolled, Auditing, Dropped, Pending
- Actions: Edit, Toggle Status, Delete
- Add Student button

**WaitlistTable:**
- 5-column table: Student Name, Email, Requested Date, Priority, Actions
- Search by name/email/date
- Sort by Name/Email/Date
- Priority badge (#1, #2, etc.)
- Actions: Approve, Reject
- Count in subtitle

---

### Roster & Waitlist Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Roster Table | ❌ | ✅ | **ADD TO FLUTTER** |
| Waitlist Table | ❌ | ✅ | **ADD TO FLUTTER** |
| Add Student | ❌ | ✅ | Add to Flutter |
| Approve/Reject | ❌ | ✅ | Add to Flutter |
| Status Management | ❌ | ✅ | Add to Flutter |
| Priority Display | ❌ | ✅ | Add to Flutter |
| Sorting | ❌ | ✅ | Add to Flutter |
| Search | ❌ | ✅ | Add to Flutter |

---

## 18. Labs Management

### Flutter Mobile App

**❌ NOT IMPLEMENTED** - Labs are only part of Create Assignment as a type.

Lab-specific fields available in Create Assignment:
- Lab Room dropdown
- Duration selector
- Lab Objectives
- Equipment & Materials
- Lab Procedure
- Safety Instructions
- Safety Equipment checkboxes
- Require Lab Report toggle

**No separate labs listing or management screen.**

---

### React Website - Labs Page

**Labs Grid:**
- Lab cards (not table)
- Beaker icon placeholder
- Lab title
- Subject badge (color-coded)
- Due date
- Description
- Submission stats (X/Y)
- Attendance percentage with progress bar
- Status badge (Active/Pending)

**Filters:**
- Course dropdown
- Status dropdown
- Search bar

**Actions:**
- Create New Lab button
- View Submissions
- Edit Lab
- Upload Instructions
- Grade Lab
- AI Auto-Grading

---

### Labs Management Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Labs List Screen | ❌ | ✅ | **ADD TO FLUTTER** |
| Lab Cards | ❌ | ✅ | Add to Flutter |
| Course Filter | ❌ | ✅ | Add to Flutter |
| Status Filter | ❌ | ✅ | Add to Flutter |
| Submission Stats | ❌ | ✅ | Add to Flutter |
| Attendance % | ❌ | ✅ | Add to Flutter |
| AI Auto-Grading | ❌ | ✅ | Add to Flutter |
| View Submissions | ❌ | ✅ | Add to Flutter |
| Lab Creation Fields | ✅ In Assignment | ❌ Separate | Different approach |

---

## 19. Quizzes Management

### Flutter Mobile App

**❌ NOT IMPLEMENTED** - No dedicated quizzes management screen.

Related features:
- AI Quiz Generator (drawer item - generates quizzes)
- AI Teaching Assistant can generate MCQs

**No quiz listing, editing, or analytics screen.**

---

### React Website - Quizzes Page

**Quizzes Grid:**
- Quiz cards (not table)
- Title with subject badge
- Date/time display
- Questions count
- Attempted ratio (X/Y)
- Difficulty badge (Easy/Medium/Hard)
- Duration in minutes
- Status badge (Active/Closed/Scheduled)

**Filters:**
- Course dropdown
- Status dropdown
- Search bar

**Actions:**
- Create New Quiz button
- View Attempts
- Edit Quiz
- Generate with AI
- Analyze Results
- Publish (for Scheduled)

---

### Quizzes Management Differences

| Feature | Flutter | React | Status |
|---------|---------|-------|--------|
| Quizzes List Screen | ❌ | ✅ | **ADD TO FLUTTER** |
| Quiz Cards | ❌ | ✅ | Add to Flutter |
| Course Filter | ❌ | ✅ | Add to Flutter |
| Status Filter | ❌ | ✅ | Add to Flutter |
| Questions Count | ❌ | ✅ | Add to Flutter |
| Attempts Stats | ❌ | ✅ | Add to Flutter |
| Difficulty Badge | ❌ | ✅ | Add to Flutter |
| Duration Display | ❌ | ✅ | Add to Flutter |
| View Attempts | ❌ | ✅ | Add to Flutter |
| Analyze Results | ❌ | ✅ | Add to Flutter |
| AI Generate | ✅ Separate screen | ✅ Button | Different approach |
| Publish Action | ❌ | ✅ | Add to Flutter |

---

## Summary Tables

### Pages/Screens Comparison

| Screen/Page | Flutter | React | Priority |
|-------------|---------|-------|----------|
| Dashboard | ✅ | ✅ | - |
| Courses List | ✅ | ✅ | - |
| Course Detail | ✅ 4 tabs | ✅ 11 tabs | Align tabs |
| Grading Center | ✅ | ✅ | - |
| Attendance | ✅ | ✅ | - |
| Create Assignment | ✅ | ✅ | - |
| Calendar/Schedule | ✅ 3 views | ⚠️ Limited | Add views to Website |
| Reports/Analytics | ✅ | ✅ | - |
| Chat/Messages | ✅ | ✅ | - |
| Notifications | ✅ | ⚠️ Dropdown only | Add screen to Website |
| Profile | ✅ View + Edit | ✅ Inline | - |
| Settings | ✅ | ✅ | - |
| Announcements | ✅ | ✅ Tab | - |
| Upload Materials | ✅ | ❌ | **ADD TO WEBSITE** |
| Search | ✅ | ⚠️ Modal only | **ADD TO WEBSITE** |
| Student Roster | ❌ | ✅ | **ADD TO FLUTTER** |
| Waitlist | ❌ | ✅ | **ADD TO FLUTTER** |
| Labs | ❌ | ✅ | **ADD TO FLUTTER** |
| Quizzes | ❌ | ✅ | **ADD TO FLUTTER** |
| Discussion | ❌ | ✅ | **ADD TO FLUTTER** |
| AI Tools | ✅ 4 screens | ✅ 1 page | Consolidate Flutter |

---

### Features Missing in Flutter (Add to Mobile App)

| Feature | Priority | Complexity |
|---------|----------|------------|
| Student Roster Management | HIGH | Medium |
| Waitlist Management | HIGH | Medium |
| Labs Management Screen | HIGH | Medium |
| Quizzes Management Screen | HIGH | Medium |
| Discussion Forum | MEDIUM | High |
| Course Performance Charts | MEDIUM | Medium |
| Student Engagement Charts | MEDIUM | Medium |
| AI Photo Attendance | HIGH | High |
| AI Voice to Text | MEDIUM | Medium |
| AI Image to Text (OCR) | MEDIUM | Medium |
| AI Question Editor | MEDIUM | Medium |
| Smart Teaching Plan | LOW | Medium |
| Video/Voice Calls | LOW | High |
| Conflict Detection | LOW | Medium |
| Schedule Optimization | LOW | Medium |
| Deactivate/Delete Account | LOW | Low |
| AI Privacy Settings | LOW | Low |
| Low-Performance Topics | MEDIUM | Low |
| Top Performers List | LOW | Low |
| Recent Activities Feed | LOW | Low |

---

### Features Missing in Website (Add to React)

| Feature | Priority | Complexity |
|---------|----------|------------|
| Upload Materials Screen | HIGH | Medium |
| Global Search Screen | HIGH | Medium |
| Notifications Screen | HIGH | Medium |
| Calendar Month/Day Views | MEDIUM | Medium |
| View Modes (Grid/List/Compact) | LOW | Low |
| Statistics Dashboard | MEDIUM | Medium |
| Bulk Course Actions | LOW | Medium |
| Course Category Filter | LOW | Low |
| Quick Grade Buttons | LOW | Low |
| Per-Student Attendance | HIGH | Medium |
| QR Scan Attendance | MEDIUM | High |
| Student Notes | MEDIUM | Low |
| Attendance Export | MEDIUM | Low |
| Notify Students | MEDIUM | Low |
| Announcement Analytics | MEDIUM | Medium |
| Attachment Management | MEDIUM | Medium |
| Assignment Preview | LOW | Low |
| Assignment Scheduling | LOW | Low |
| Chat Pin/Mute | LOW | Low |
| Long-press Context Menu | LOW | Low |
| Export Data Options | MEDIUM | Low |

---

### Feature Parity Status

| Category | Flutter | React | Parity |
|----------|---------|-------|--------|
| Navigation | Drawer | Tabs | ⚠️ Different UX |
| Dashboard | 90% | 95% | ⚠️ Charts missing in Flutter |
| Courses | 95% | 85% | ⚠️ Features differ |
| Grading | 85% | 90% | ⚠️ Auto-grade better in React |
| Attendance | 80% | 85% | ⚠️ AI photo in React only |
| Assignments | 95% | 70% | ⚠️ Flutter more comprehensive |
| AI Features | 75% | 85% | ⚠️ Features differ |
| Calendar | 95% | 50% | ⚠️ Flutter better |
| Chat | 90% | 85% | ⚠️ Features differ |
| Notifications | 95% | 30% | ⚠️ Flutter better |
| Profile | 95% | 80% | ⚠️ Flutter more fields |
| Settings | 85% | 90% | ⚠️ Features differ |
| Announcements | 90% | 70% | ⚠️ Flutter better |
| Materials | 95% | 30% | ⚠️ Flutter has dedicated screen |
| Search | 95% | 40% | ⚠️ Flutter has dedicated screen |
| Roster/Waitlist | 0% | 95% | ❌ Missing in Flutter |
| Labs | 30% | 90% | ❌ Missing in Flutter |
| Quizzes | 20% | 90% | ❌ Missing in Flutter |
| Discussion | 0% | 80% | ❌ Missing in Flutter |

---

## Recommendations

### High Priority - Add to Flutter Mobile App

1. **Student Roster Management**
   - Create `/instructor/roster` screen
   - Table with search, sort, status management
   - Add/Edit/Remove students

2. **Waitlist Management**
   - Create `/instructor/waitlist` screen
   - Approve/Reject functionality
   - Priority display

3. **Labs Management Screen**
   - Create `/instructor/labs` screen
   - List all labs with filters
   - Link to create lab assignment

4. **Quizzes Management Screen**
   - Create `/instructor/quizzes` screen
   - List all quizzes with filters
   - Analytics per quiz

5. **AI Photo Attendance**
   - Add photo upload/capture
   - AI detection integration
   - Manual override capability

### High Priority - Add to React Website

1. **Upload Materials Screen**
   - Create dedicated page
   - Upload queue with progress
   - Course/Module organization

2. **Global Search Screen**
   - Create dedicated search page
   - Category filtering
   - Recent searches

3. **Notifications Screen**
   - Create dedicated page
   - Tab filtering (All/Unread/Read)
   - Category filtering

4. **Per-Student Attendance**
   - Individual marking UI
   - Quick actions (All Present/Absent)
   - Student notes

### Medium Priority

**Flutter:**
- Add performance/engagement charts to dashboard
- Integrate AI Voice/Image to text
- Add Discussion Forum tab
- Add Top Performers list
- Add Recent Activities feed

**React:**
- Add Calendar Month/Day views
- Add Event creation/editing
- Add Statistics Dashboard
- Add Announcement Analytics
- Add Material visibility toggle

### Low Priority

**Flutter:**
- Video/Voice call integration
- Account deactivation
- AI Privacy settings

**React:**
- View mode toggles (Grid/List/Compact)
- Bulk course actions
- Chat pin/mute features
- Long-press context menus

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 2026 | System | Initial comprehensive comparison |

---

*End of Document*
