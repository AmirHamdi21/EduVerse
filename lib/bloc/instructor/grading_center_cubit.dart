import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/instructor/grading_model.dart';
import '../../models/instructor/instructor_course_model.dart';
import 'grading_center_state.dart';

class GradingCenterCubit extends Cubit<GradingCenterState> {
  GradingCenterCubit() : super(const GradingCenterState()) {
    loadGradingData();
  }

  Future<void> loadGradingData() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final courses = _generateDemoCourses();
      final submissions = _generateDemoSubmissions();
      final statistics = _calculateStatistics(submissions);

      emit(state.copyWith(
        courses: courses,
        submissions: submissions,
        statistics: statistics,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load grading data: $e',
      ));
    }
  }

  Future<void> refreshGradingData() async {
    await loadGradingData();
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void setFilter(GradingFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setSelectedCourse(String? courseId) {
    emit(state.copyWith(selectedCourseId: courseId, clearCourse: courseId == null));
  }

  Future<void> gradeSubmission(String submissionId, int grade, String feedback) async {
    final submissions = state.submissions.map((s) {
      if (s.id == submissionId) {
        return StudentSubmission(
          id: s.id,
          studentId: s.studentId,
          studentName: s.studentName,
          studentEmail: s.studentEmail,
          studentAvatar: s.studentAvatar,
          courseId: s.courseId,
          courseName: s.courseName,
          assignmentId: s.assignmentId,
          assignmentTitle: s.assignmentTitle,
          submittedAt: s.submittedAt,
          status: 'graded',
          grade: grade,
          maxGrade: s.maxGrade,
          feedback: feedback,
          attachments: s.attachments,
        );
      }
      return s;
    }).toList();

    emit(state.copyWith(
      submissions: submissions,
      statistics: _calculateStatistics(submissions),
    ));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  List<InstructorCourseModel> _generateDemoCourses() {
    return [
      InstructorCourseModel(
        id: '1',
        code: 'CS101',
        name: 'Operating Systems',
        totalStudents: 45,
        colorValue: 0xFF6366F1,
      ),
      InstructorCourseModel(
        id: '2',
        code: 'CS202',
        name: 'Data Structures & Algorithms',
        totalStudents: 38,
        colorValue: 0xFF10B981,
      ),
      InstructorCourseModel(
        id: '3',
        code: 'CS305',
        name: 'Database Management Systems',
        totalStudents: 52,
        colorValue: 0xFFF59E0B,
      ),
    ];
  }

  List<StudentSubmission> _generateDemoSubmissions() {
    final students = [
      {'id': 's1', 'name': 'Ahmed Mohamed', 'email': 'ahmed@university.edu'},
      {'id': 's2', 'name': 'Sara Ahmed', 'email': 'sara@university.edu'},
      {'id': 's3', 'name': 'Omar Hassan', 'email': 'omar@university.edu'},
      {'id': 's4', 'name': 'Fatima Ali', 'email': 'fatima@university.edu'},
      {'id': 's5', 'name': 'Youssef Khaled', 'email': 'youssef@university.edu'},
      {'id': 's6', 'name': 'Nour Ibrahim', 'email': 'nour@university.edu'},
    ];

    return [
      StudentSubmission(
        id: 'sub1',
        studentId: students[0]['id']!,
        studentName: students[0]['name']!,
        studentEmail: students[0]['email']!,
        studentAvatar: '',
        courseId: '1',
        courseName: 'CS101 - Operating Systems',
        assignmentId: 'a1',
        assignmentTitle: 'Process Scheduling',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'pending',
        maxGrade: 100,
      ),
      StudentSubmission(
        id: 'sub2',
        studentId: students[1]['id']!,
        studentName: students[1]['name']!,
        studentEmail: students[1]['email']!,
        studentAvatar: '',
        courseId: '2',
        courseName: 'CS202 - Data Structures',
        assignmentId: 'a2',
        assignmentTitle: 'Binary Trees',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'pending',
        maxGrade: 100,
      ),
      StudentSubmission(
        id: 'sub3',
        studentId: students[2]['id']!,
        studentName: students[2]['name']!,
        studentEmail: students[2]['email']!,
        studentAvatar: '',
        courseId: '3',
        courseName: 'CS305 - Database Systems',
        assignmentId: 'a3',
        assignmentTitle: 'SQL Queries',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'graded',
        grade: 85,
        maxGrade: 100,
      ),
      StudentSubmission(
        id: 'sub4',
        studentId: students[3]['id']!,
        studentName: students[3]['name']!,
        studentEmail: students[3]['email']!,
        studentAvatar: '',
        courseId: '1',
        courseName: 'CS101 - Operating Systems',
        assignmentId: 'a1',
        assignmentTitle: 'Memory Management',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'late',
        maxGrade: 100,
        lateDays: 1,
      ),
      StudentSubmission(
        id: 'sub5',
        studentId: students[4]['id']!,
        studentName: students[4]['name']!,
        studentEmail: students[4]['email']!,
        studentAvatar: '',
        courseId: '2',
        courseName: 'CS202 - Data Structures',
        assignmentId: 'a2',
        assignmentTitle: 'Hash Tables',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'graded',
        grade: 92,
        maxGrade: 100,
      ),
      StudentSubmission(
        id: 'sub6',
        studentId: students[5]['id']!,
        studentName: students[5]['name']!,
        studentEmail: students[5]['email']!,
        studentAvatar: '',
        courseId: '3',
        courseName: 'CS305 - Database Systems',
        assignmentId: 'a3',
        assignmentTitle: 'ER Diagrams',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: 'late',
        maxGrade: 100,
        lateDays: 2,
      ),
    ];
  }

  GradingStatistics _calculateStatistics(List<StudentSubmission> submissions) {
    final total = submissions.length;
    final pending = submissions.where((s) => s.status == 'pending').length;
    final graded = submissions.where((s) => s.status == 'graded').length;
    final late = submissions.where((s) => s.status == 'late').length;

    final gradedSubmissions = submissions.where((s) => s.status == 'graded' && s.grade != null);
    double avgGrade = 0;
    if (gradedSubmissions.isNotEmpty) {
      avgGrade = gradedSubmissions.map((s) => s.grade!).reduce((a, b) => a + b) / gradedSubmissions.length;
    }

    return GradingStatistics(
      totalSubmissions: total,
      pendingSubmissions: pending,
      gradedSubmissions: graded,
      lateSubmissions: late,
      averageGrade: avgGrade,
      completionRate: total > 0 ? graded / total : 0,
    );
  }
}
