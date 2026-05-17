import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:flutter/material.dart';

export 'package:edu_verse/features/walkthrough/walkthrough_models.dart'
    show WalkthroughTargetShape;

class InstructorWalkthroughStep extends WalkthroughStep {
  const InstructorWalkthroughStep({
    required super.targetId,
    required super.icon,
    required super.title,
    required super.body,
    super.shape = WalkthroughTargetShape.roundedRect,
    super.allowFallback = true,
  });
}

class InstructorWalkthroughSegment extends WalkthroughSegment {
  const InstructorWalkthroughSegment({
    required super.id,
    required super.route,
    required super.steps,
    super.needsCourse = false,
  });
}

class InstructorWalkthroughIds {
  const InstructorWalkthroughIds._();

  static const dashboard = 'instructor.dashboard';
  static const dashboardTop = 'instructor.dashboard.top';
  static const dashboardStats = 'instructor.dashboard.stats';
  static const dashboardQuick = 'instructor.dashboard.quick';
  static const dashboardPending = 'instructor.dashboard.pending';

  static const courses = 'instructor.courses';
  static const coursesHeader = 'instructor.courses.header';
  static const coursesToolbar = 'instructor.courses.toolbar';
  static const coursesList = 'instructor.courses.list';
  static const coursesCreate = 'instructor.courses.create';

  static const courseDetails = 'instructor.courseDetails';
  static const courseDetailsHero = 'instructor.courseDetails.hero';
  static const courseDetailsTabs = 'instructor.courseDetails.tabs';
  static const courseDetailsContent = 'instructor.courseDetails.content';

  static const assignments = 'instructor.assignments';
  static const assignmentsHeader = 'instructor.assignments.header';
  static const assignmentsFilters = 'instructor.assignments.filters';
  static const assignmentsList = 'instructor.assignments.list';

  static const labs = 'instructor.labs';
  static const labsHeader = 'instructor.labs.header';
  static const labsFilters = 'instructor.labs.filters';
  static const labsList = 'instructor.labs.list';

  static const questionBank = 'instructor.questionBank';
  static const questionBankHeader = 'instructor.questionBank.header';
  static const questionBankControls = 'instructor.questionBank.controls';
  static const questionBankFeed = 'instructor.questionBank.feed';
  static const questionBankCreate = 'instructor.questionBank.create';

  static const examGenerator = 'instructor.examGenerator';
  static const examGeneratorHeader = 'instructor.examGenerator.header';
  static const examGeneratorFilters = 'instructor.examGenerator.filters';
  static const examGeneratorList = 'instructor.examGenerator.list';
  static const examGeneratorCreate = 'instructor.examGenerator.create';

  static const grading = 'instructor.grading';
  static const gradingHeader = 'instructor.grading.header';
  static const gradingFilters = 'instructor.grading.filters';
  static const gradingList = 'instructor.grading.list';

  static const attendance = 'instructor.attendance';
  static const attendanceHeader = 'instructor.attendance.header';
  static const attendanceControls = 'instructor.attendance.controls';
  static const attendanceRoster = 'instructor.attendance.roster';

  static const quiz = 'instructor.quiz';
  static const quizHeader = 'instructor.quiz.header';
  static const quizFilters = 'instructor.quiz.filters';
  static const quizList = 'instructor.quiz.list';
  static const quizCreate = 'instructor.quiz.create';
}

class InstructorWalkthroughRegistry {
  const InstructorWalkthroughRegistry._();

  static const List<InstructorWalkthroughSegment> segments =
      <InstructorWalkthroughSegment>[
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.dashboard,
          route: '/instructor/dashboard',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.dashboardTop,
              icon: Icons.search_rounded,
              title: _tDashboardTop,
              body: _bDashboardTop,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.dashboardStats,
              icon: Icons.insights_rounded,
              title: _tDashboardStats,
              body: _bDashboardStats,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.dashboardQuick,
              icon: Icons.bolt_rounded,
              title: _tDashboardQuick,
              body: _bDashboardQuick,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.dashboardPending,
              icon: Icons.grading_rounded,
              title: _tDashboardPending,
              body: _bDashboardPending,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.courses,
          route: '/instructor/courses',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.coursesHeader,
              icon: Icons.school_rounded,
              title: _tCoursesHeader,
              body: _bCoursesHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.coursesToolbar,
              icon: Icons.tune_rounded,
              title: _tCoursesToolbar,
              body: _bCoursesToolbar,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.coursesList,
              icon: Icons.view_agenda_rounded,
              title: _tCoursesList,
              body: _bCoursesList,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.coursesCreate,
              icon: Icons.add_rounded,
              title: _tCoursesCreate,
              body: _bCoursesCreate,
              shape: WalkthroughTargetShape.circle,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.courseDetails,
          route: '/instructor/courses/:courseId',
          needsCourse: true,
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.courseDetailsHero,
              icon: Icons.dashboard_customize_rounded,
              title: _tCourseDetailsHero,
              body: _bCourseDetailsHero,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.courseDetailsTabs,
              icon: Icons.tab_rounded,
              title: _tCourseDetailsTabs,
              body: _bCourseDetailsTabs,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.courseDetailsContent,
              icon: Icons.layers_rounded,
              title: _tCourseDetailsContent,
              body: _bCourseDetailsContent,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.assignments,
          route: '/instructor/assignments',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.assignmentsHeader,
              icon: Icons.assignment_rounded,
              title: _tAssignmentsHeader,
              body: _bAssignmentsHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.assignmentsFilters,
              icon: Icons.filter_alt_rounded,
              title: _tAssignmentsFilters,
              body: _bAssignmentsFilters,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.assignmentsList,
              icon: Icons.fact_check_rounded,
              title: _tAssignmentsList,
              body: _bAssignmentsList,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.labs,
          route: '/instructor/labs',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.labsHeader,
              icon: Icons.science_rounded,
              title: _tLabsHeader,
              body: _bLabsHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.labsFilters,
              icon: Icons.tune_rounded,
              title: _tLabsFilters,
              body: _bLabsFilters,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.labsList,
              icon: Icons.biotech_rounded,
              title: _tLabsList,
              body: _bLabsList,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.questionBank,
          route: '/instructor/question-bank',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.questionBankHeader,
              icon: Icons.quiz_rounded,
              title: _tQuestionBankHeader,
              body: _bQuestionBankHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.questionBankControls,
              icon: Icons.manage_search_rounded,
              title: _tQuestionBankControls,
              body: _bQuestionBankControls,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.questionBankFeed,
              icon: Icons.dynamic_feed_rounded,
              title: _tQuestionBankFeed,
              body: _bQuestionBankFeed,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.questionBankCreate,
              icon: Icons.add_circle_rounded,
              title: _tQuestionBankCreate,
              body: _bQuestionBankCreate,
              shape: WalkthroughTargetShape.circle,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.examGenerator,
          route: '/instructor/exam-generator',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.examGeneratorHeader,
              icon: Icons.auto_awesome_rounded,
              title: _tExamGeneratorHeader,
              body: _bExamGeneratorHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.examGeneratorFilters,
              icon: Icons.filter_list_rounded,
              title: _tExamGeneratorFilters,
              body: _bExamGeneratorFilters,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.examGeneratorList,
              icon: Icons.article_rounded,
              title: _tExamGeneratorList,
              body: _bExamGeneratorList,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.examGeneratorCreate,
              icon: Icons.add_rounded,
              title: _tExamGeneratorCreate,
              body: _bExamGeneratorCreate,
              shape: WalkthroughTargetShape.circle,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.grading,
          route: '/instructor/grading',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.gradingHeader,
              icon: Icons.grade_rounded,
              title: _tGradingHeader,
              body: _bGradingHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.gradingFilters,
              icon: Icons.filter_alt_rounded,
              title: _tGradingFilters,
              body: _bGradingFilters,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.gradingList,
              icon: Icons.rule_rounded,
              title: _tGradingList,
              body: _bGradingList,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.attendance,
          route: '/instructor/attendance',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.attendanceHeader,
              icon: Icons.how_to_reg_rounded,
              title: _tAttendanceHeader,
              body: _bAttendanceHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.attendanceControls,
              icon: Icons.event_available_rounded,
              title: _tAttendanceControls,
              body: _bAttendanceControls,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.attendanceRoster,
              icon: Icons.groups_rounded,
              title: _tAttendanceRoster,
              body: _bAttendanceRoster,
            ),
          ],
        ),
        InstructorWalkthroughSegment(
          id: InstructorWalkthroughIds.quiz,
          route: '/instructor/quiz-management',
          steps: <InstructorWalkthroughStep>[
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.quizHeader,
              icon: Icons.quiz_rounded,
              title: _tQuizHeader,
              body: _bQuizHeader,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.quizFilters,
              icon: Icons.search_rounded,
              title: _tQuizFilters,
              body: _bQuizFilters,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.quizList,
              icon: Icons.format_list_bulleted_rounded,
              title: _tQuizList,
              body: _bQuizList,
            ),
            InstructorWalkthroughStep(
              targetId: InstructorWalkthroughIds.quizCreate,
              icon: Icons.add_circle_rounded,
              title: _tQuizCreate,
              body: _bQuizCreate,
              shape: WalkthroughTargetShape.circle,
            ),
          ],
        ),
      ];

  static InstructorWalkthroughSegment? segmentById(String id) {
    for (final segment in segments) {
      if (segment.id == id) return segment;
    }
    return null;
  }

  static String _tDashboardTop(AppLocalizations l) =>
      l.walkthroughDashboardTopTitle;
  static String _bDashboardTop(AppLocalizations l) =>
      l.walkthroughDashboardTopBody;
  static String _tDashboardStats(AppLocalizations l) =>
      l.walkthroughDashboardStatsTitle;
  static String _bDashboardStats(AppLocalizations l) =>
      l.walkthroughDashboardStatsBody;
  static String _tDashboardQuick(AppLocalizations l) =>
      l.walkthroughDashboardQuickTitle;
  static String _bDashboardQuick(AppLocalizations l) =>
      l.walkthroughDashboardQuickBody;
  static String _tDashboardPending(AppLocalizations l) =>
      l.walkthroughDashboardPendingTitle;
  static String _bDashboardPending(AppLocalizations l) =>
      l.walkthroughDashboardPendingBody;
  static String _tCoursesHeader(AppLocalizations l) =>
      l.walkthroughCoursesHeaderTitle;
  static String _bCoursesHeader(AppLocalizations l) =>
      l.walkthroughCoursesHeaderBody;
  static String _tCoursesToolbar(AppLocalizations l) =>
      l.walkthroughCoursesToolbarTitle;
  static String _bCoursesToolbar(AppLocalizations l) =>
      l.walkthroughCoursesToolbarBody;
  static String _tCoursesList(AppLocalizations l) =>
      l.walkthroughCoursesListTitle;
  static String _bCoursesList(AppLocalizations l) =>
      l.walkthroughCoursesListBody;
  static String _tCoursesCreate(AppLocalizations l) =>
      l.walkthroughCoursesCreateTitle;
  static String _bCoursesCreate(AppLocalizations l) =>
      l.walkthroughCoursesCreateBody;
  static String _tCourseDetailsHero(AppLocalizations l) =>
      l.walkthroughCourseDetailsHeroTitle;
  static String _bCourseDetailsHero(AppLocalizations l) =>
      l.walkthroughCourseDetailsHeroBody;
  static String _tCourseDetailsTabs(AppLocalizations l) =>
      l.walkthroughCourseDetailsTabsTitle;
  static String _bCourseDetailsTabs(AppLocalizations l) =>
      l.walkthroughCourseDetailsTabsBody;
  static String _tCourseDetailsContent(AppLocalizations l) =>
      l.walkthroughCourseDetailsContentTitle;
  static String _bCourseDetailsContent(AppLocalizations l) =>
      l.walkthroughCourseDetailsContentBody;
  static String _tAssignmentsHeader(AppLocalizations l) =>
      l.walkthroughAssignmentsHeaderTitle;
  static String _bAssignmentsHeader(AppLocalizations l) =>
      l.walkthroughAssignmentsHeaderBody;
  static String _tAssignmentsFilters(AppLocalizations l) =>
      l.walkthroughAssignmentsFiltersTitle;
  static String _bAssignmentsFilters(AppLocalizations l) =>
      l.walkthroughAssignmentsFiltersBody;
  static String _tAssignmentsList(AppLocalizations l) =>
      l.walkthroughAssignmentsListTitle;
  static String _bAssignmentsList(AppLocalizations l) =>
      l.walkthroughAssignmentsListBody;
  static String _tLabsHeader(AppLocalizations l) =>
      l.walkthroughLabsHeaderTitle;
  static String _bLabsHeader(AppLocalizations l) => l.walkthroughLabsHeaderBody;
  static String _tLabsFilters(AppLocalizations l) =>
      l.walkthroughLabsFiltersTitle;
  static String _bLabsFilters(AppLocalizations l) =>
      l.walkthroughLabsFiltersBody;
  static String _tLabsList(AppLocalizations l) => l.walkthroughLabsListTitle;
  static String _bLabsList(AppLocalizations l) => l.walkthroughLabsListBody;
  static String _tQuestionBankHeader(AppLocalizations l) =>
      l.walkthroughQuestionBankHeaderTitle;
  static String _bQuestionBankHeader(AppLocalizations l) =>
      l.walkthroughQuestionBankHeaderBody;
  static String _tQuestionBankControls(AppLocalizations l) =>
      l.walkthroughQuestionBankControlsTitle;
  static String _bQuestionBankControls(AppLocalizations l) =>
      l.walkthroughQuestionBankControlsBody;
  static String _tQuestionBankFeed(AppLocalizations l) =>
      l.walkthroughQuestionBankFeedTitle;
  static String _bQuestionBankFeed(AppLocalizations l) =>
      l.walkthroughQuestionBankFeedBody;
  static String _tQuestionBankCreate(AppLocalizations l) =>
      l.walkthroughQuestionBankCreateTitle;
  static String _bQuestionBankCreate(AppLocalizations l) =>
      l.walkthroughQuestionBankCreateBody;
  static String _tExamGeneratorHeader(AppLocalizations l) =>
      l.walkthroughExamGeneratorHeaderTitle;
  static String _bExamGeneratorHeader(AppLocalizations l) =>
      l.walkthroughExamGeneratorHeaderBody;
  static String _tExamGeneratorFilters(AppLocalizations l) =>
      l.walkthroughExamGeneratorFiltersTitle;
  static String _bExamGeneratorFilters(AppLocalizations l) =>
      l.walkthroughExamGeneratorFiltersBody;
  static String _tExamGeneratorList(AppLocalizations l) =>
      l.walkthroughExamGeneratorListTitle;
  static String _bExamGeneratorList(AppLocalizations l) =>
      l.walkthroughExamGeneratorListBody;
  static String _tExamGeneratorCreate(AppLocalizations l) =>
      l.walkthroughExamGeneratorCreateTitle;
  static String _bExamGeneratorCreate(AppLocalizations l) =>
      l.walkthroughExamGeneratorCreateBody;
  static String _tGradingHeader(AppLocalizations l) =>
      l.walkthroughGradingHeaderTitle;
  static String _bGradingHeader(AppLocalizations l) =>
      l.walkthroughGradingHeaderBody;
  static String _tGradingFilters(AppLocalizations l) =>
      l.walkthroughGradingFiltersTitle;
  static String _bGradingFilters(AppLocalizations l) =>
      l.walkthroughGradingFiltersBody;
  static String _tGradingList(AppLocalizations l) =>
      l.walkthroughGradingListTitle;
  static String _bGradingList(AppLocalizations l) =>
      l.walkthroughGradingListBody;
  static String _tAttendanceHeader(AppLocalizations l) =>
      l.walkthroughAttendanceHeaderTitle;
  static String _bAttendanceHeader(AppLocalizations l) =>
      l.walkthroughAttendanceHeaderBody;
  static String _tAttendanceControls(AppLocalizations l) =>
      l.walkthroughAttendanceControlsTitle;
  static String _bAttendanceControls(AppLocalizations l) =>
      l.walkthroughAttendanceControlsBody;
  static String _tAttendanceRoster(AppLocalizations l) =>
      l.walkthroughAttendanceRosterTitle;
  static String _bAttendanceRoster(AppLocalizations l) =>
      l.walkthroughAttendanceRosterBody;
  static String _tQuizHeader(AppLocalizations l) =>
      l.walkthroughQuizHeaderTitle;
  static String _bQuizHeader(AppLocalizations l) => l.walkthroughQuizHeaderBody;
  static String _tQuizFilters(AppLocalizations l) =>
      l.walkthroughQuizFiltersTitle;
  static String _bQuizFilters(AppLocalizations l) =>
      l.walkthroughQuizFiltersBody;
  static String _tQuizList(AppLocalizations l) => l.walkthroughQuizListTitle;
  static String _bQuizList(AppLocalizations l) => l.walkthroughQuizListBody;
  static String _tQuizCreate(AppLocalizations l) =>
      l.walkthroughQuizCreateTitle;
  static String _bQuizCreate(AppLocalizations l) => l.walkthroughQuizCreateBody;
}
