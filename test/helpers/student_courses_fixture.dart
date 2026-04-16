import 'package:edu_verse/models/core/course_model.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/models/core/enums/course_enums.dart';
import 'package:edu_verse/models/core/enums/enrollment_enums.dart';
import 'package:edu_verse/models/core/section_model.dart';
import 'package:edu_verse/models/core/semester_model.dart';

class StudentCoursesFixture {
  static CourseEnrollmentModel enrollment({
    String id = '1',
    int courseId = 101,
    String code = 'CS101',
    String title = 'Introduction to Computer Science',
    String status = 'enrolled',
    int? semesterId = 1,
    String semesterName = 'Fall 2026',
    String sectionNumber = 'A',
    int credits = 3,
    DateTime? enrolledAt,
    String instructorFirstName = 'Sara',
    String instructorLastName = 'Hassan',
  }) {
    final DateTime enrollmentDate =
        enrolledAt ?? DateTime.utc(2026, 9, 1, 9, 0, 0);

    return CourseEnrollmentModel(
      id: id,
      userId: 42,
      sectionId: 500 + courseId,
      enrollmentStatus: EnrollmentStatus.fromString(status),
      enrollmentDate: enrollmentDate,
      canDrop: true,
      role: 'student',
      course: CourseModel(
        id: courseId,
        departmentId: 1,
        code: code,
        name: title,
        description: '$title description',
        credits: credits,
        courseLevel: CourseLevel.freshman,
        courseStatus: CourseStatus.active,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
      section: SectionModel(
        id: 500 + courseId,
        courseId: courseId,
        semesterId: semesterId ?? 0,
        sectionNumber: sectionNumber,
        maxCapacity: 40,
        currentEnrollment: 32,
        location: 'B-201',
        sectionStatus: SectionStatus.open,
      ),
      semester: semesterId == null
          ? null
          : SemesterModel(id: semesterId, name: semesterName),
      instructor: UserLite(
        userId: 800 + courseId,
        firstName: instructorFirstName,
        lastName: instructorLastName,
        email:
            '${instructorFirstName.toLowerCase()}.${instructorLastName.toLowerCase()}@eduverse.test',
      ),
      prerequisites: const <EnrollmentPrerequisite>[],
    );
  }

  static List<CourseEnrollmentModel> listWithMixedData() {
    return <CourseEnrollmentModel>[
      enrollment(
        id: '1',
        courseId: 100,
        code: 'CS100',
        title: 'Programming Fundamentals',
        status: 'enrolled',
        semesterId: 1,
        semesterName: 'Fall 2026',
        sectionNumber: 'A1',
        credits: 3,
        instructorFirstName: 'Mona',
        instructorLastName: 'Ali',
      ),
      enrollment(
        id: '2',
        courseId: 200,
        code: 'MATH200',
        title: 'Linear Algebra',
        status: 'completed',
        semesterId: 2,
        semesterName: 'Spring 2027',
        sectionNumber: 'B2',
        credits: 4,
        instructorFirstName: 'Omar',
        instructorLastName: 'Khaled',
      ),
      enrollment(
        id: '3',
        courseId: 300,
        code: 'PHYS300',
        title: 'Modern Physics',
        status: 'dropped',
        semesterId: null,
        sectionNumber: 'C3',
        credits: 2,
        instructorFirstName: 'Lina',
        instructorLastName: 'Samir',
      ),
    ];
  }
}
