# Data Models: Admin — Course Management

The data models required for this feature already exist in the codebase from prior phases (backend parity achieved previously). However, they will be utilized and potentially extended in the admin context:

## 1. CourseModel
- `id` (String)
- `title` (String)
- `code` (String)
- `description` (String)
- `department` (String)
- `credits` (int)
- `prerequisites` (List<String>)
- `status` (enum: ACTIVE, INACTIVE, ARCHIVED)

## 2. SectionModel
- `id` (String)
- `courseId` (String)
- `sectionNumber` (String)
- `capacity` (int)
- `enrolledCount` (int)
- `status` (enum: OPEN, CLOSED, WAITLISTED)

## 3. ScheduleModel
- `id` (String)
- `sectionId` (String)
- `dayOfWeek` (String)
- `startTime` (DateTime)
- `endTime` (DateTime)
- `location` (String)
- `type` (enum: LECTURE, LAB, TUTORIAL)

## 4. InstructorAssignmentModel / StaffAssignmentModel
- `instructorId` (String)
- `sectionId` (String)
- `role` (enum: PRIMARY, CO_INSTRUCTOR, TA, GUEST)

## Note on AddCourseWizardState (UI State Model)
- Used within `CourseWizardBloc` to hold draft data between wizard steps.
- Fields: `draftCourseId`, `draftSectionId`, `isStep1Complete`, `isStep2Complete`, `status` (Initial, Loading, Success, Error, Conflict).
