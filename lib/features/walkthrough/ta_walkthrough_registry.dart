import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TAWalkthroughIds {
  const TAWalkthroughIds._();

  static const dashboard = 'ta.dashboard';
  static const dashboardTop = 'ta.dashboard.top';
  static const dashboardStats = 'ta.dashboard.stats';
  static const dashboardQuick = 'ta.dashboard.quick';
  static const dashboardTasks = 'ta.dashboard.tasks';

  static const courses = 'ta.courses';
  static const coursesHeader = 'ta.courses.header';
  static const coursesFilters = 'ta.courses.filters';
  static const coursesList = 'ta.courses.list';

  static const courseDetails = 'ta.courseDetails';
  static const courseDetailsHero = 'ta.courseDetails.hero';
  static const courseDetailsTabs = 'ta.courseDetails.tabs';
  static const courseDetailsContent = 'ta.courseDetails.content';

  static const assignments = 'ta.assignments';
  static const assignmentsHeader = 'ta.assignments.header';
  static const assignmentsFilters = 'ta.assignments.filters';
  static const assignmentsList = 'ta.assignments.list';

  static const labs = 'ta.labs';
  static const labsHeader = 'ta.labs.header';
  static const labsFilters = 'ta.labs.filters';
  static const labsList = 'ta.labs.list';

  static const grading = 'ta.grading';
  static const gradingHeader = 'ta.grading.header';
  static const gradingFilters = 'ta.grading.filters';
  static const gradingList = 'ta.grading.list';

  static const attendance = 'ta.attendance';
  static const attendanceHeader = 'ta.attendance.header';
  static const attendanceControls = 'ta.attendance.controls';
  static const attendanceRoster = 'ta.attendance.roster';

  static const roster = 'ta.roster';
  static const rosterHeader = 'ta.roster.header';
  static const rosterControls = 'ta.roster.controls';
  static const rosterList = 'ta.roster.list';

  static const discussions = 'ta.discussions';
  static const discussionsHeader = 'ta.discussions.header';
  static const discussionsFilters = 'ta.discussions.filters';
  static const discussionsList = 'ta.discussions.list';

  static const quiz = 'ta.quiz';
  static const quizHeader = 'ta.quiz.header';
  static const quizFilters = 'ta.quiz.filters';
  static const quizList = 'ta.quiz.list';

  static const analytics = 'ta.analytics';
  static const analyticsStats = 'ta.analytics.stats';
  static const analyticsCharts = 'ta.analytics.charts';
  static const analyticsInsights = 'ta.analytics.insights';

  static const ai = 'ta.ai';
  static const aiStarters = 'ta.ai.starters';
  static const aiHistory = 'ta.ai.history';
  static const aiComposer = 'ta.ai.composer';
}

class TAWalkthroughRegistry {
  const TAWalkthroughRegistry._();

  static const List<WalkthroughSegment> segments = <WalkthroughSegment>[
    WalkthroughSegment(
      id: TAWalkthroughIds.dashboard,
      route: '/ta/dashboard',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.dashboardTop,
          icon: Icons.search_rounded,
          title: _tDashboardTop,
          body: _bDashboardTop,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.dashboardStats,
          icon: Icons.insights_rounded,
          title: _tDashboardStats,
          body: _bDashboardStats,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.dashboardQuick,
          icon: Icons.bolt_rounded,
          title: _tDashboardQuick,
          body: _bDashboardQuick,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.dashboardTasks,
          icon: Icons.task_alt_rounded,
          title: _tDashboardTasks,
          body: _bDashboardTasks,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.courses,
      route: '/ta/courses',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.coursesHeader,
          icon: Icons.school_rounded,
          title: _tCoursesHeader,
          body: _bCoursesHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.coursesFilters,
          icon: Icons.tune_rounded,
          title: _tCoursesFilters,
          body: _bCoursesFilters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.coursesList,
          icon: Icons.view_agenda_rounded,
          title: _tCoursesList,
          body: _bCoursesList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.courseDetails,
      route: '/ta/course/:courseId',
      needsCourse: true,
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.courseDetailsHero,
          icon: Icons.dashboard_customize_rounded,
          title: _tCourseDetailsHero,
          body: _bCourseDetailsHero,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.courseDetailsTabs,
          icon: Icons.tab_rounded,
          title: _tCourseDetailsTabs,
          body: _bCourseDetailsTabs,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.courseDetailsContent,
          icon: Icons.layers_rounded,
          title: _tCourseDetailsContent,
          body: _bCourseDetailsContent,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.assignments,
      route: '/ta/assignments',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.assignmentsHeader,
          icon: Icons.assignment_rounded,
          title: _tAssignmentsHeader,
          body: _bAssignmentsHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.assignmentsFilters,
          icon: Icons.filter_alt_rounded,
          title: _tAssignmentsFilters,
          body: _bAssignmentsFilters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.assignmentsList,
          icon: Icons.fact_check_rounded,
          title: _tAssignmentsList,
          body: _bAssignmentsList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.labs,
      route: '/ta/labs',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.labsHeader,
          icon: Icons.science_rounded,
          title: _tLabsHeader,
          body: _bLabsHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.labsFilters,
          icon: Icons.tune_rounded,
          title: _tLabsFilters,
          body: _bLabsFilters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.labsList,
          icon: Icons.biotech_rounded,
          title: _tLabsList,
          body: _bLabsList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.grading,
      route: '/ta/grading',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.gradingHeader,
          icon: Icons.grade_rounded,
          title: _tGradingHeader,
          body: _bGradingHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.gradingFilters,
          icon: Icons.filter_alt_rounded,
          title: _tGradingFilters,
          body: _bGradingFilters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.gradingList,
          icon: Icons.rule_rounded,
          title: _tGradingList,
          body: _bGradingList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.attendance,
      route: '/ta/attendance',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.attendanceHeader,
          icon: Icons.how_to_reg_rounded,
          title: _tAttendanceHeader,
          body: _bAttendanceHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.attendanceControls,
          icon: Icons.event_available_rounded,
          title: _tAttendanceControls,
          body: _bAttendanceControls,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.attendanceRoster,
          icon: Icons.groups_rounded,
          title: _tAttendanceRoster,
          body: _bAttendanceRoster,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.roster,
      route: '/ta/roster',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.rosterHeader,
          icon: Icons.groups_rounded,
          title: _tRosterHeader,
          body: _bRosterHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.rosterControls,
          icon: Icons.manage_search_rounded,
          title: _tRosterControls,
          body: _bRosterControls,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.rosterList,
          icon: Icons.badge_rounded,
          title: _tRosterList,
          body: _bRosterList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.discussions,
      route: '/ta/discussions',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.discussionsHeader,
          icon: Icons.forum_rounded,
          title: _tDiscussionsHeader,
          body: _bDiscussionsHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.discussionsFilters,
          icon: Icons.tune_rounded,
          title: _tDiscussionsFilters,
          body: _bDiscussionsFilters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.discussionsList,
          icon: Icons.question_answer_rounded,
          title: _tDiscussionsList,
          body: _bDiscussionsList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.quiz,
      route: '/ta/quiz-management',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.quizHeader,
          icon: Icons.quiz_rounded,
          title: _tQuizHeader,
          body: _bQuizHeader,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.quizFilters,
          icon: Icons.search_rounded,
          title: _tQuizFilters,
          body: _bQuizFilters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.quizList,
          icon: Icons.format_list_bulleted_rounded,
          title: _tQuizList,
          body: _bQuizList,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.analytics,
      route: '/ta/analytics',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.analyticsStats,
          icon: Icons.query_stats_rounded,
          title: _tAnalyticsStats,
          body: _bAnalyticsStats,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.analyticsCharts,
          icon: Icons.bar_chart_rounded,
          title: _tAnalyticsCharts,
          body: _bAnalyticsCharts,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.analyticsInsights,
          icon: Icons.psychology_rounded,
          title: _tAnalyticsInsights,
          body: _bAnalyticsInsights,
        ),
      ],
    ),
    WalkthroughSegment(
      id: TAWalkthroughIds.ai,
      route: '/ta/ai-assistant',
      steps: <WalkthroughStep>[
        WalkthroughStep(
          targetId: TAWalkthroughIds.aiStarters,
          icon: Icons.auto_awesome_rounded,
          title: _tAiStarters,
          body: _bAiStarters,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.aiHistory,
          icon: Icons.history_rounded,
          title: _tAiHistory,
          body: _bAiHistory,
        ),
        WalkthroughStep(
          targetId: TAWalkthroughIds.aiComposer,
          icon: Icons.edit_note_rounded,
          title: _tAiComposer,
          body: _bAiComposer,
          shape: WalkthroughTargetShape.roundedRect,
        ),
      ],
    ),
  ];

  static WalkthroughSegment? segmentById(String id) {
    for (final segment in segments) {
      if (segment.id == id) return segment;
    }
    return null;
  }

  static String _tDashboardTop(AppLocalizations l) =>
      l.taWalkthroughDashboardTopTitle;
  static String _bDashboardTop(AppLocalizations l) =>
      l.taWalkthroughDashboardTopBody;
  static String _tDashboardStats(AppLocalizations l) =>
      l.taWalkthroughDashboardStatsTitle;
  static String _bDashboardStats(AppLocalizations l) =>
      l.taWalkthroughDashboardStatsBody;
  static String _tDashboardQuick(AppLocalizations l) =>
      l.taWalkthroughDashboardQuickTitle;
  static String _bDashboardQuick(AppLocalizations l) =>
      l.taWalkthroughDashboardQuickBody;
  static String _tDashboardTasks(AppLocalizations l) =>
      l.taWalkthroughDashboardTasksTitle;
  static String _bDashboardTasks(AppLocalizations l) =>
      l.taWalkthroughDashboardTasksBody;
  static String _tCoursesHeader(AppLocalizations l) =>
      l.taWalkthroughCoursesHeaderTitle;
  static String _bCoursesHeader(AppLocalizations l) =>
      l.taWalkthroughCoursesHeaderBody;
  static String _tCoursesFilters(AppLocalizations l) =>
      l.taWalkthroughCoursesFiltersTitle;
  static String _bCoursesFilters(AppLocalizations l) =>
      l.taWalkthroughCoursesFiltersBody;
  static String _tCoursesList(AppLocalizations l) =>
      l.taWalkthroughCoursesListTitle;
  static String _bCoursesList(AppLocalizations l) =>
      l.taWalkthroughCoursesListBody;
  static String _tCourseDetailsHero(AppLocalizations l) =>
      l.taWalkthroughCourseDetailsHeroTitle;
  static String _bCourseDetailsHero(AppLocalizations l) =>
      l.taWalkthroughCourseDetailsHeroBody;
  static String _tCourseDetailsTabs(AppLocalizations l) =>
      l.taWalkthroughCourseDetailsTabsTitle;
  static String _bCourseDetailsTabs(AppLocalizations l) =>
      l.taWalkthroughCourseDetailsTabsBody;
  static String _tCourseDetailsContent(AppLocalizations l) =>
      l.taWalkthroughCourseDetailsContentTitle;
  static String _bCourseDetailsContent(AppLocalizations l) =>
      l.taWalkthroughCourseDetailsContentBody;
  static String _tAssignmentsHeader(AppLocalizations l) =>
      l.taWalkthroughAssignmentsHeaderTitle;
  static String _bAssignmentsHeader(AppLocalizations l) =>
      l.taWalkthroughAssignmentsHeaderBody;
  static String _tAssignmentsFilters(AppLocalizations l) =>
      l.taWalkthroughAssignmentsFiltersTitle;
  static String _bAssignmentsFilters(AppLocalizations l) =>
      l.taWalkthroughAssignmentsFiltersBody;
  static String _tAssignmentsList(AppLocalizations l) =>
      l.taWalkthroughAssignmentsListTitle;
  static String _bAssignmentsList(AppLocalizations l) =>
      l.taWalkthroughAssignmentsListBody;
  static String _tLabsHeader(AppLocalizations l) =>
      l.taWalkthroughLabsHeaderTitle;
  static String _bLabsHeader(AppLocalizations l) =>
      l.taWalkthroughLabsHeaderBody;
  static String _tLabsFilters(AppLocalizations l) =>
      l.taWalkthroughLabsFiltersTitle;
  static String _bLabsFilters(AppLocalizations l) =>
      l.taWalkthroughLabsFiltersBody;
  static String _tLabsList(AppLocalizations l) => l.taWalkthroughLabsListTitle;
  static String _bLabsList(AppLocalizations l) => l.taWalkthroughLabsListBody;
  static String _tGradingHeader(AppLocalizations l) =>
      l.taWalkthroughGradingHeaderTitle;
  static String _bGradingHeader(AppLocalizations l) =>
      l.taWalkthroughGradingHeaderBody;
  static String _tGradingFilters(AppLocalizations l) =>
      l.taWalkthroughGradingFiltersTitle;
  static String _bGradingFilters(AppLocalizations l) =>
      l.taWalkthroughGradingFiltersBody;
  static String _tGradingList(AppLocalizations l) =>
      l.taWalkthroughGradingListTitle;
  static String _bGradingList(AppLocalizations l) =>
      l.taWalkthroughGradingListBody;
  static String _tAttendanceHeader(AppLocalizations l) =>
      l.taWalkthroughAttendanceHeaderTitle;
  static String _bAttendanceHeader(AppLocalizations l) =>
      l.taWalkthroughAttendanceHeaderBody;
  static String _tAttendanceControls(AppLocalizations l) =>
      l.taWalkthroughAttendanceControlsTitle;
  static String _bAttendanceControls(AppLocalizations l) =>
      l.taWalkthroughAttendanceControlsBody;
  static String _tAttendanceRoster(AppLocalizations l) =>
      l.taWalkthroughAttendanceRosterTitle;
  static String _bAttendanceRoster(AppLocalizations l) =>
      l.taWalkthroughAttendanceRosterBody;
  static String _tRosterHeader(AppLocalizations l) =>
      l.taWalkthroughRosterHeaderTitle;
  static String _bRosterHeader(AppLocalizations l) =>
      l.taWalkthroughRosterHeaderBody;
  static String _tRosterControls(AppLocalizations l) =>
      l.taWalkthroughRosterControlsTitle;
  static String _bRosterControls(AppLocalizations l) =>
      l.taWalkthroughRosterControlsBody;
  static String _tRosterList(AppLocalizations l) =>
      l.taWalkthroughRosterListTitle;
  static String _bRosterList(AppLocalizations l) =>
      l.taWalkthroughRosterListBody;
  static String _tDiscussionsHeader(AppLocalizations l) =>
      l.taWalkthroughDiscussionsHeaderTitle;
  static String _bDiscussionsHeader(AppLocalizations l) =>
      l.taWalkthroughDiscussionsHeaderBody;
  static String _tDiscussionsFilters(AppLocalizations l) =>
      l.taWalkthroughDiscussionsFiltersTitle;
  static String _bDiscussionsFilters(AppLocalizations l) =>
      l.taWalkthroughDiscussionsFiltersBody;
  static String _tDiscussionsList(AppLocalizations l) =>
      l.taWalkthroughDiscussionsListTitle;
  static String _bDiscussionsList(AppLocalizations l) =>
      l.taWalkthroughDiscussionsListBody;
  static String _tQuizHeader(AppLocalizations l) =>
      l.taWalkthroughQuizHeaderTitle;
  static String _bQuizHeader(AppLocalizations l) =>
      l.taWalkthroughQuizHeaderBody;
  static String _tQuizFilters(AppLocalizations l) =>
      l.taWalkthroughQuizFiltersTitle;
  static String _bQuizFilters(AppLocalizations l) =>
      l.taWalkthroughQuizFiltersBody;
  static String _tQuizList(AppLocalizations l) => l.taWalkthroughQuizListTitle;
  static String _bQuizList(AppLocalizations l) => l.taWalkthroughQuizListBody;
  static String _tAnalyticsStats(AppLocalizations l) =>
      l.taWalkthroughAnalyticsStatsTitle;
  static String _bAnalyticsStats(AppLocalizations l) =>
      l.taWalkthroughAnalyticsStatsBody;
  static String _tAnalyticsCharts(AppLocalizations l) =>
      l.taWalkthroughAnalyticsChartsTitle;
  static String _bAnalyticsCharts(AppLocalizations l) =>
      l.taWalkthroughAnalyticsChartsBody;
  static String _tAnalyticsInsights(AppLocalizations l) =>
      l.taWalkthroughAnalyticsInsightsTitle;
  static String _bAnalyticsInsights(AppLocalizations l) =>
      l.taWalkthroughAnalyticsInsightsBody;
  static String _tAiStarters(AppLocalizations l) =>
      l.taWalkthroughAiStartersTitle;
  static String _bAiStarters(AppLocalizations l) =>
      l.taWalkthroughAiStartersBody;
  static String _tAiHistory(AppLocalizations l) =>
      l.taWalkthroughAiHistoryTitle;
  static String _bAiHistory(AppLocalizations l) => l.taWalkthroughAiHistoryBody;
  static String _tAiComposer(AppLocalizations l) =>
      l.taWalkthroughAiComposerTitle;
  static String _bAiComposer(AppLocalizations l) =>
      l.taWalkthroughAiComposerBody;
}
