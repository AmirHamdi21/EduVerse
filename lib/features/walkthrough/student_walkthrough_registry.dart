import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StudentWalkthroughIds {
  const StudentWalkthroughIds._();

  static const dashboard = 'student.dashboard';
  static const dashboardTop = 'student.dashboard.top';
  static const dashboardStats = 'student.dashboard.stats';
  static const dashboardQuick = 'student.dashboard.quick';
  static const dashboardCourses = 'student.dashboard.courses';

  static const courses = 'student.courses';
  static const coursesHeader = 'student.courses.header';
  static const coursesControls = 'student.courses.controls';
  static const coursesList = 'student.courses.list';
  static const coursesJoin = 'student.courses.join';

  static const courseDetails = 'student.courseDetails';
  static const courseDetailsHero = 'student.courseDetails.hero';
  static const courseDetailsTabs = 'student.courseDetails.tabs';
  static const courseDetailsContent = 'student.courseDetails.content';

  static const registration = 'student.registration';
  static const registrationHeader = 'student.registration.header';
  static const registrationStats = 'student.registration.stats';
  static const registrationFilters = 'student.registration.filters';
  static const registrationCourses = 'student.registration.courses';

  static const assignments = 'student.assignments';
  static const assignmentsHeader = 'student.assignments.header';
  static const assignmentsFilters = 'student.assignments.filters';
  static const assignmentsList = 'student.assignments.list';

  static const labs = 'student.labs';
  static const labsHeader = 'student.labs.header';
  static const labsFilters = 'student.labs.filters';
  static const labsList = 'student.labs.list';

  static const grades = 'student.grades';
  static const gradesGpa = 'student.grades.gpa';
  static const gradesTabs = 'student.grades.tabs';
  static const gradesList = 'student.grades.list';

  static const attendance = 'student.attendance';
  static const attendanceHeader = 'student.attendance.header';
  static const attendanceTabs = 'student.attendance.tabs';
  static const attendanceStats = 'student.attendance.stats';
  static const attendanceList = 'student.attendance.list';

  static const quizzes = 'student.quizzes';
  static const quizzesHeader = 'student.quizzes.header';
  static const quizzesSearch = 'student.quizzes.search';
  static const quizzesList = 'student.quizzes.list';

  static const discussions = 'student.discussions';
  static const discussionsHeader = 'student.discussions.header';
  static const discussionsFilters = 'student.discussions.filters';
  static const discussionsList = 'student.discussions.list';

  static const ai = 'student.ai';
  static const aiHeader = 'student.ai.header';
  static const aiMessages = 'student.ai.messages';
  static const aiQuick = 'student.ai.quick';
  static const aiComposer = 'student.ai.composer';
}

class StudentWalkthroughRegistry {
  const StudentWalkthroughRegistry._();

  static const List<WalkthroughSegment> segments = <WalkthroughSegment>[
    WalkthroughSegment(
      id: StudentWalkthroughIds.dashboard,
      route: '/dashboard',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.dashboardTop,
          icon: Icons.search_rounded,
          title: _tDashboardTop,
          body: _bDashboardTop,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.dashboardStats,
          icon: Icons.insights_rounded,
          title: _tDashboardStats,
          body: _bDashboardStats,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.dashboardQuick,
          icon: Icons.bolt_rounded,
          title: _tDashboardQuick,
          body: _bDashboardQuick,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.dashboardCourses,
          icon: Icons.school_rounded,
          title: _tDashboardCourses,
          body: _bDashboardCourses,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.courses,
      route: '/courses',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.coursesHeader,
          icon: Icons.school_rounded,
          title: _tCoursesHeader,
          body: _bCoursesHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.coursesControls,
          icon: Icons.tune_rounded,
          title: _tCoursesControls,
          body: _bCoursesControls,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.coursesList,
          icon: Icons.view_agenda_rounded,
          title: _tCoursesList,
          body: _bCoursesList,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.coursesJoin,
          icon: Icons.add_rounded,
          title: _tCoursesJoin,
          body: _bCoursesJoin,
          shape: WalkthroughTargetShape.circle,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.courseDetails,
      route: '/course-details',
      needsCourse: true,
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.courseDetailsHero,
          icon: Icons.dashboard_customize_rounded,
          title: _tCourseDetailsHero,
          body: _bCourseDetailsHero,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.courseDetailsTabs,
          icon: Icons.tab_rounded,
          title: _tCourseDetailsTabs,
          body: _bCourseDetailsTabs,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.courseDetailsContent,
          icon: Icons.layers_rounded,
          title: _tCourseDetailsContent,
          body: _bCourseDetailsContent,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.registration,
      route: '/registration',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.registrationHeader,
          icon: Icons.app_registration_rounded,
          title: _tRegistrationHeader,
          body: _bRegistrationHeader,
          allowFallback: false,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.registrationStats,
          icon: Icons.query_stats_rounded,
          title: _tRegistrationStats,
          body: _bRegistrationStats,
          allowFallback: false,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.registrationFilters,
          icon: Icons.filter_alt_rounded,
          title: _tRegistrationFilters,
          body: _bRegistrationFilters,
          allowFallback: false,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.registrationCourses,
          icon: Icons.playlist_add_check_rounded,
          title: _tRegistrationCourses,
          body: _bRegistrationCourses,
          allowFallback: false,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.assignments,
      route: '/assignments',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.assignmentsHeader,
          icon: Icons.assignment_rounded,
          title: _tAssignmentsHeader,
          body: _bAssignmentsHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.assignmentsFilters,
          icon: Icons.filter_alt_rounded,
          title: _tAssignmentsFilters,
          body: _bAssignmentsFilters,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.assignmentsList,
          icon: Icons.fact_check_rounded,
          title: _tAssignmentsList,
          body: _bAssignmentsList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.labs,
      route: '/labs',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.labsHeader,
          icon: Icons.science_rounded,
          title: _tLabsHeader,
          body: _bLabsHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.labsFilters,
          icon: Icons.tune_rounded,
          title: _tLabsFilters,
          body: _bLabsFilters,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.labsList,
          icon: Icons.biotech_rounded,
          title: _tLabsList,
          body: _bLabsList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.grades,
      route: '/grades',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.gradesGpa,
          icon: Icons.grade_rounded,
          title: _tGradesGpa,
          body: _bGradesGpa,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.gradesTabs,
          icon: Icons.calendar_month_rounded,
          title: _tGradesTabs,
          body: _bGradesTabs,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.gradesList,
          icon: Icons.format_list_bulleted_rounded,
          title: _tGradesList,
          body: _bGradesList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.attendance,
      route: '/attendance',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.attendanceHeader,
          icon: Icons.how_to_reg_rounded,
          title: _tAttendanceHeader,
          body: _bAttendanceHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.attendanceTabs,
          icon: Icons.tab_rounded,
          title: _tAttendanceTabs,
          body: _bAttendanceTabs,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.attendanceStats,
          icon: Icons.insights_rounded,
          title: _tAttendanceStats,
          body: _bAttendanceStats,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.attendanceList,
          icon: Icons.event_available_rounded,
          title: _tAttendanceList,
          body: _bAttendanceList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.quizzes,
      route: '/student/quizzes',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.quizzesHeader,
          icon: Icons.quiz_rounded,
          title: _tQuizzesHeader,
          body: _bQuizzesHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.quizzesSearch,
          icon: Icons.search_rounded,
          title: _tQuizzesSearch,
          body: _bQuizzesSearch,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.quizzesList,
          icon: Icons.fact_check_rounded,
          title: _tQuizzesList,
          body: _bQuizzesList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.discussions,
      route: '/discussions',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.discussionsHeader,
          icon: Icons.forum_rounded,
          title: _tDiscussionsHeader,
          body: _bDiscussionsHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.discussionsFilters,
          icon: Icons.tune_rounded,
          title: _tDiscussionsFilters,
          body: _bDiscussionsFilters,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.discussionsList,
          icon: Icons.question_answer_rounded,
          title: _tDiscussionsList,
          body: _bDiscussionsList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: StudentWalkthroughIds.ai,
      route: '/ai-chat',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: StudentWalkthroughIds.aiHeader,
          icon: Icons.auto_awesome_rounded,
          title: _tAiHeader,
          body: _bAiHeader,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.aiMessages,
          icon: Icons.chat_bubble_rounded,
          title: _tAiMessages,
          body: _bAiMessages,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.aiQuick,
          icon: Icons.bolt_rounded,
          title: _tAiQuick,
          body: _bAiQuick,
        ),
        WalkthroughStep(
          targetId: StudentWalkthroughIds.aiComposer,
          icon: Icons.edit_note_rounded,
          title: _tAiComposer,
          body: _bAiComposer,
        ),
      ],
    ),
  ];

  static String _tDashboardTop(AppLocalizations l) =>
      l.studentWalkthroughDashboardTopTitle;
  static String _bDashboardTop(AppLocalizations l) =>
      l.studentWalkthroughDashboardTopBody;
  static String _tDashboardStats(AppLocalizations l) =>
      l.studentWalkthroughDashboardStatsTitle;
  static String _bDashboardStats(AppLocalizations l) =>
      l.studentWalkthroughDashboardStatsBody;
  static String _tDashboardQuick(AppLocalizations l) =>
      l.studentWalkthroughDashboardQuickTitle;
  static String _bDashboardQuick(AppLocalizations l) =>
      l.studentWalkthroughDashboardQuickBody;
  static String _tDashboardCourses(AppLocalizations l) =>
      l.studentWalkthroughDashboardCoursesTitle;
  static String _bDashboardCourses(AppLocalizations l) =>
      l.studentWalkthroughDashboardCoursesBody;
  static String _tCoursesHeader(AppLocalizations l) =>
      l.studentWalkthroughCoursesHeaderTitle;
  static String _bCoursesHeader(AppLocalizations l) =>
      l.studentWalkthroughCoursesHeaderBody;
  static String _tCoursesControls(AppLocalizations l) =>
      l.studentWalkthroughCoursesControlsTitle;
  static String _bCoursesControls(AppLocalizations l) =>
      l.studentWalkthroughCoursesControlsBody;
  static String _tCoursesList(AppLocalizations l) =>
      l.studentWalkthroughCoursesListTitle;
  static String _bCoursesList(AppLocalizations l) =>
      l.studentWalkthroughCoursesListBody;
  static String _tCoursesJoin(AppLocalizations l) =>
      l.studentWalkthroughCoursesJoinTitle;
  static String _bCoursesJoin(AppLocalizations l) =>
      l.studentWalkthroughCoursesJoinBody;
  static String _tCourseDetailsHero(AppLocalizations l) =>
      l.studentWalkthroughCourseDetailsHeroTitle;
  static String _bCourseDetailsHero(AppLocalizations l) =>
      l.studentWalkthroughCourseDetailsHeroBody;
  static String _tCourseDetailsTabs(AppLocalizations l) =>
      l.studentWalkthroughCourseDetailsTabsTitle;
  static String _bCourseDetailsTabs(AppLocalizations l) =>
      l.studentWalkthroughCourseDetailsTabsBody;
  static String _tCourseDetailsContent(AppLocalizations l) =>
      l.studentWalkthroughCourseDetailsContentTitle;
  static String _bCourseDetailsContent(AppLocalizations l) =>
      l.studentWalkthroughCourseDetailsContentBody;
  static String _tRegistrationHeader(AppLocalizations l) =>
      l.studentWalkthroughRegistrationHeaderTitle;
  static String _bRegistrationHeader(AppLocalizations l) =>
      l.studentWalkthroughRegistrationHeaderBody;
  static String _tRegistrationStats(AppLocalizations l) =>
      l.studentWalkthroughRegistrationStatsTitle;
  static String _bRegistrationStats(AppLocalizations l) =>
      l.studentWalkthroughRegistrationStatsBody;
  static String _tRegistrationFilters(AppLocalizations l) =>
      l.studentWalkthroughRegistrationFiltersTitle;
  static String _bRegistrationFilters(AppLocalizations l) =>
      l.studentWalkthroughRegistrationFiltersBody;
  static String _tRegistrationCourses(AppLocalizations l) =>
      l.studentWalkthroughRegistrationCoursesTitle;
  static String _bRegistrationCourses(AppLocalizations l) =>
      l.studentWalkthroughRegistrationCoursesBody;
  static String _tAssignmentsHeader(AppLocalizations l) =>
      l.studentWalkthroughAssignmentsHeaderTitle;
  static String _bAssignmentsHeader(AppLocalizations l) =>
      l.studentWalkthroughAssignmentsHeaderBody;
  static String _tAssignmentsFilters(AppLocalizations l) =>
      l.studentWalkthroughAssignmentsFiltersTitle;
  static String _bAssignmentsFilters(AppLocalizations l) =>
      l.studentWalkthroughAssignmentsFiltersBody;
  static String _tAssignmentsList(AppLocalizations l) =>
      l.studentWalkthroughAssignmentsListTitle;
  static String _bAssignmentsList(AppLocalizations l) =>
      l.studentWalkthroughAssignmentsListBody;
  static String _tLabsHeader(AppLocalizations l) =>
      l.studentWalkthroughLabsHeaderTitle;
  static String _bLabsHeader(AppLocalizations l) =>
      l.studentWalkthroughLabsHeaderBody;
  static String _tLabsFilters(AppLocalizations l) =>
      l.studentWalkthroughLabsFiltersTitle;
  static String _bLabsFilters(AppLocalizations l) =>
      l.studentWalkthroughLabsFiltersBody;
  static String _tLabsList(AppLocalizations l) =>
      l.studentWalkthroughLabsListTitle;
  static String _bLabsList(AppLocalizations l) =>
      l.studentWalkthroughLabsListBody;
  static String _tGradesGpa(AppLocalizations l) =>
      l.studentWalkthroughGradesGpaTitle;
  static String _bGradesGpa(AppLocalizations l) =>
      l.studentWalkthroughGradesGpaBody;
  static String _tGradesTabs(AppLocalizations l) =>
      l.studentWalkthroughGradesTabsTitle;
  static String _bGradesTabs(AppLocalizations l) =>
      l.studentWalkthroughGradesTabsBody;
  static String _tGradesList(AppLocalizations l) =>
      l.studentWalkthroughGradesListTitle;
  static String _bGradesList(AppLocalizations l) =>
      l.studentWalkthroughGradesListBody;
  static String _tAttendanceHeader(AppLocalizations l) =>
      l.studentWalkthroughAttendanceHeaderTitle;
  static String _bAttendanceHeader(AppLocalizations l) =>
      l.studentWalkthroughAttendanceHeaderBody;
  static String _tAttendanceTabs(AppLocalizations l) =>
      l.studentWalkthroughAttendanceTabsTitle;
  static String _bAttendanceTabs(AppLocalizations l) =>
      l.studentWalkthroughAttendanceTabsBody;
  static String _tAttendanceStats(AppLocalizations l) =>
      l.studentWalkthroughAttendanceStatsTitle;
  static String _bAttendanceStats(AppLocalizations l) =>
      l.studentWalkthroughAttendanceStatsBody;
  static String _tAttendanceList(AppLocalizations l) =>
      l.studentWalkthroughAttendanceListTitle;
  static String _bAttendanceList(AppLocalizations l) =>
      l.studentWalkthroughAttendanceListBody;
  static String _tQuizzesHeader(AppLocalizations l) =>
      l.studentWalkthroughQuizzesHeaderTitle;
  static String _bQuizzesHeader(AppLocalizations l) =>
      l.studentWalkthroughQuizzesHeaderBody;
  static String _tQuizzesSearch(AppLocalizations l) =>
      l.studentWalkthroughQuizzesSearchTitle;
  static String _bQuizzesSearch(AppLocalizations l) =>
      l.studentWalkthroughQuizzesSearchBody;
  static String _tQuizzesList(AppLocalizations l) =>
      l.studentWalkthroughQuizzesListTitle;
  static String _bQuizzesList(AppLocalizations l) =>
      l.studentWalkthroughQuizzesListBody;
  static String _tDiscussionsHeader(AppLocalizations l) =>
      l.studentWalkthroughDiscussionsHeaderTitle;
  static String _bDiscussionsHeader(AppLocalizations l) =>
      l.studentWalkthroughDiscussionsHeaderBody;
  static String _tDiscussionsFilters(AppLocalizations l) =>
      l.studentWalkthroughDiscussionsFiltersTitle;
  static String _bDiscussionsFilters(AppLocalizations l) =>
      l.studentWalkthroughDiscussionsFiltersBody;
  static String _tDiscussionsList(AppLocalizations l) =>
      l.studentWalkthroughDiscussionsListTitle;
  static String _bDiscussionsList(AppLocalizations l) =>
      l.studentWalkthroughDiscussionsListBody;
  static String _tAiHeader(AppLocalizations l) =>
      l.studentWalkthroughAiHeaderTitle;
  static String _bAiHeader(AppLocalizations l) =>
      l.studentWalkthroughAiHeaderBody;
  static String _tAiMessages(AppLocalizations l) =>
      l.studentWalkthroughAiMessagesTitle;
  static String _bAiMessages(AppLocalizations l) =>
      l.studentWalkthroughAiMessagesBody;
  static String _tAiQuick(AppLocalizations l) =>
      l.studentWalkthroughAiQuickTitle;
  static String _bAiQuick(AppLocalizations l) =>
      l.studentWalkthroughAiQuickBody;
  static String _tAiComposer(AppLocalizations l) =>
      l.studentWalkthroughAiComposerTitle;
  static String _bAiComposer(AppLocalizations l) =>
      l.studentWalkthroughAiComposerBody;
}
