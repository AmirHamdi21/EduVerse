# Instructor Courses API Contract

**Endpoint**: `GET /api/enrollments/teaching`
**Access**: Protected (Bearer Token, Role: INSTRUCTOR)
**Description**: Retrieves sections assigned to the current instructor or TA.

## Example Success Response Payload

```json
[
  {
    "sectionId": 5,
    "courseId": 10,
    "course": {
      "id": 10,
      "name": "Data Structures",
      "code": "CS201",
      "description": "...",
      "credits": 4,
      "level": "200"
    },
    "section": {
      "id": 5,
      "sectionNumber": "01",
      "maxCapacity": 50,
      "currentEnrollment": 46,
      "location": "Room 204"
    },
    "semester": {
      "id": 1,
      "name": "Fall 2026",
      "startDate": "2026-08-20T00:00:00.000Z",
      "endDate": "2026-12-15T00:00:00.000Z"
    }
  }
]
```
