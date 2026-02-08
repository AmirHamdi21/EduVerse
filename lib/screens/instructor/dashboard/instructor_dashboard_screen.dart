import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/instructor/instructor_course_model.dart';
import '../../../widgets/instructor/dashboard/instructor_app_bar.dart';
import '../../../widgets/instructor/dashboard/dashboard_header.dart';
import '../../../widgets/instructor/dashboard/quick_actions_grid.dart';
import '../../../widgets/instructor/dashboard/my_courses_section.dart';
import '../../../widgets/instructor/dashboard/pending_grading_section.dart';
import '../../../widgets/instructor/dashboard/upcoming_events_section.dart';
import '../../../widgets/instructor/dashboard/instructor_drawer.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  late List<InstructorCourseModel> _courses;
  late List<PendingSubmission> _pendingSubmissions;
  late List<UpcomingEvent> _upcomingEvents;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate loading data
    await Future.delayed(const Duration(milliseconds: 500));
    
    _courses = _getMockCourses();
    _pendingSubmissions = _getMockSubmissions();
    _upcomingEvents = _getMockEvents();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          drawer: const InstructorDrawer(),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEEF5FE),
                          Colors.white,
                          Color(0xFFFAF5FE),
                        ],
                      ),
                    ),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDark ? Colors.white : const Color(0xFF155CFB),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF155CFB),
                      child: CustomScrollView(
                        slivers: [
                          const InstructorAppBar(),
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                // AI Teaching Overview Card
                                InstructorAITeachingCard(
                                  pendingAssignments: 12,
                                  studentsAtRisk: 2,
                                  aiSuggestion: 'Send a reminder quiz for CS305 students',
                                ),
                                const SizedBox(height: 24),
                                // Quick Access Grid
                                const InstructorQuickAccessGrid(),
                                const SizedBox(height: 24),
                                // My Courses Section
                                MyCoursesSection(courses: _courses),
                                const SizedBox(height: 24),
                                // Pending Grading Section
                                PendingGradingSection(submissions: _pendingSubmissions),
                                const SizedBox(height: 24),
                                // Upcoming Events Section
                                UpcomingEventsSection(events: _upcomingEvents),
                                const SizedBox(height: 24),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  List<InstructorCourseModel> _getMockCourses() {
    return [
      InstructorCourseModel(
        id: '1',
        code: 'CS101',
        name: 'Operating Systems',
        description: 'Introduction to operating systems concepts',
        totalStudents: 45,
        colorValue: 0xFF155CFB,
        progress: 67,
        isActive: true,
        newItems: 3,
        activeQuizzes: 2,
        unreadMessages: 5,
        assignments: [
          AssignmentModel(
            id: 'a1',
            title: 'Process Scheduling',
            description: 'Implement process scheduling algorithms',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            totalPoints: 100,
            submissionsCount: 32,
            gradedCount: 28,
          ),
          AssignmentModel(
            id: 'a2',
            title: 'Memory Management',
            description: 'Virtual memory implementation',
            dueDate: DateTime.now().add(const Duration(days: 12)),
            totalPoints: 100,
            submissionsCount: 15,
            gradedCount: 0,
          ),
        ],
        materials: [
          MaterialModel(
            id: 'm1',
            title: 'Week 1 Slides',
            type: 'PDF',
            fileSize: '2.4 MB',
            uploadedAt: DateTime.now().subtract(const Duration(days: 14)),
          ),
          MaterialModel(
            id: 'm2',
            title: 'Process Demo Video',
            type: 'Video',
            fileSize: '45 MB',
            uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
        announcements: [
          AnnouncementModel(
            id: 'an1',
            title: 'Midterm Exam Schedule',
            content: 'The midterm exam will be held on March 15th.',
            postedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
      InstructorCourseModel(
        id: '2',
        code: 'CS202',
        name: 'Data Structures & Algorithms',
        description: 'Advanced data structures and algorithm design',
        totalStudents: 38,
        colorValue: 0xFF10B981,
        progress: 72,
        isActive: true,
        newItems: 1,
        activeQuizzes: 1,
        unreadMessages: 2,
        assignments: [
          AssignmentModel(
            id: 'a3',
            title: 'Binary Trees',
            description: 'Implement binary tree operations',
            dueDate: DateTime.now().add(const Duration(days: 3)),
            totalPoints: 100,
            submissionsCount: 35,
            gradedCount: 30,
          ),
        ],
        materials: [],
        announcements: [],
      ),
      InstructorCourseModel(
        id: '3',
        code: 'CS305',
        name: 'Database Management Systems',
        description: 'Relational database design and SQL',
        totalStudents: 52,
        colorValue: 0xFFF59E0B,
        progress: 56,
        isActive: true,
        newItems: 0,
        activeQuizzes: 3,
        unreadMessages: 0,
        assignments: [],
        materials: [],
        announcements: [],
      ),
      InstructorCourseModel(
        id: '4',
        code: 'CS401',
        name: 'Machine Learning Fundamentals',
        description: 'Introduction to machine learning algorithms',
        totalStudents: 28,
        colorValue: 0xFF3B82F6,
        progress: 67,
        isActive: true,
        newItems: 2,
        activeQuizzes: 0,
        unreadMessages: 1,
        assignments: [],
        materials: [],
        announcements: [],
      ),
    ];
  }

  List<PendingSubmission> _getMockSubmissions() {
    return [
      PendingSubmission(
        studentName: 'Sarah Johnson',
        studentAvatar: '',
        courseName: 'Operating Systems Lab 5',
        assignmentTitle: 'OS Lab Assignment',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        submittedDate: DateTime.now(),
      ),
      PendingSubmission(
        studentName: 'Michael Chen',
        studentAvatar: '',
        courseName: 'Essay: Search Trees',
        assignmentTitle: 'Data Structures Essay',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        submittedDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PendingSubmission(
        studentName: 'Emily Rodriguez',
        studentAvatar: '',
        courseName: 'SQL Query Project',
        assignmentTitle: 'Database Project',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        submittedDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<UpcomingEvent> _getMockEvents() {
    final now = DateTime.now();
    return [
      UpcomingEvent(
        title: 'CS101 - Lecture',
        subtitle: 'Memory Management',
        dateTime: now.add(const Duration(days: 1)),
        color: const Color(0xFF155CFB),
        icon: Icons.school_rounded,
      ),
      UpcomingEvent(
        title: 'CS202 - Assignment Deadline',
        subtitle: 'Binary Trees Implementation',
        dateTime: now.add(const Duration(days: 3)),
        color: const Color(0xFFF59E0B),
        icon: Icons.assignment_turned_in_rounded,
      ),
      UpcomingEvent(
        title: 'CS305 - Lab Session',
        subtitle: 'SQL Joins Practice',
        dateTime: now.add(const Duration(days: 4)),
        color: const Color(0xFF10B981),
        icon: Icons.computer_rounded,
      ),
      UpcomingEvent(
        title: 'CS401 - Lecture: Graph Algorithms',
        subtitle: 'Dijkstra and A* Algorithms',
        dateTime: now.add(const Duration(days: 5)),
        color: const Color(0xFF3B82F6),
        icon: Icons.auto_graph_rounded,
      ),
    ];
  }
}
