import 'package:edu_verse/widgets/student/course_details/course_details_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/courses/courses_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/course_ui_utils.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/courses/instructor_assignment_model.dart';
import '../../models/ta/ta_assignment_model.dart';
import '../../widgets/student/courses/course_model.dart';
import '../../widgets/student/course_details/course_tabs.dart';

/// Course detail drill-down screen consuming live [CourseEnrollmentModel].
///
/// T014: Constructor now accepts [CourseEnrollmentModel] directly.
/// T015: All header info, credits, and instructor use live object data
///        with safe SC-003 null-coalescing fallbacks.
class CourseDetailsScreen extends StatefulWidget {
  /// Accepts either a [CourseEnrollmentModel] (live) or legacy [CourseModel].
  final CourseEnrollmentModel? enrollment;
  final CourseModel? legacyCourse;
  final int initialTab;

  const CourseDetailsScreen({
    super.key,
    this.enrollment,
    this.legacyCourse,
    this.initialTab = 0,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final CourseDetailBloc _courseDetailBloc;
  late AnimationController _headerAnimationController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  // ── Safe accessors with SC-003 null-coalescing ─────────────────────────

  String get _title {
    if (widget.enrollment != null) {
      return CourseUiUtils.safeCourseTitle(
        widget.enrollment!.course?.courseName,
      );
    }
    return widget.legacyCourse?.title ?? 'Course';
  }

  String get _courseCode {
    if (widget.enrollment != null) {
      return CourseUiUtils.safeCourseCode(
        widget.enrollment!.course?.courseCode,
      );
    }
    return '';
  }

  String get _instructor {
    if (widget.enrollment != null) {
      final enrollmentInstructor = widget.enrollment?.instructor;
      if (enrollmentInstructor != null) {
        final fullName =
            '${enrollmentInstructor.firstName} ${enrollmentInstructor.lastName}'
                .trim();
        if (fullName.isNotEmpty) {
          return fullName;
        }
        if (enrollmentInstructor.email.trim().isNotEmpty) {
          return enrollmentInstructor.email;
        }
      }
      return widget.legacyCourse?.instructor ?? 'Unknown Instructor';
    }
    return widget.legacyCourse?.instructor ?? 'Unknown Instructor';
  }

  int get _credits {
    return widget.enrollment?.course?.credits ?? 0;
  }

  String get _statusLabel {
    if (widget.enrollment != null) {
      switch (widget.enrollment!.status.toLowerCase()) {
        case 'completed':
          return 'Completed';
        case 'dropped':
          return 'Dropped';
        case 'active':
        case 'enrolled':
          return 'Active';
        case 'waitlisted':
          return 'Waitlisted';
        default:
          return 'Active';
      }
    }
    return 'Active';
  }

  String get _level {
    return widget.enrollment?.course?.level ?? 'N/A';
  }

  String? get _description {
    return widget.enrollment?.course?.description;
  }

  int? get _resolvedCourseId {
    final directId = widget.enrollment?.course?.courseId;
    if (directId != null) return directId;

    final fallbackId = widget.enrollment?.courseId;
    if (fallbackId == null || fallbackId.isEmpty) return null;
    return int.tryParse(fallbackId);
  }

  List<Color> get _gradientColors {
    if (widget.enrollment != null) {
      return CourseUiUtils.gradientForCourseId(
        _resolvedCourseId ?? widget.enrollment!.courseId,
      );
    }
    return [const Color(0xFF2B7FFF), const Color(0xFF155DFC)];
  }

  /// Legacy progress value (from old model) or backend enrollment progress.
  double get _progress {
    if (widget.legacyCourse != null) {
      return widget.legacyCourse!.progress;
    }

    final progressPercentage = widget.enrollment?.progressPercentage;
    if (progressPercentage != null) {
      return (progressPercentage / 100).clamp(0.0, 1.0);
    }

    final materialsViewed = widget.enrollment?.materialsViewed ?? 0;
    final totalMaterials = widget.enrollment?.totalMaterials ?? 0;
    if (totalMaterials > 0) {
      return (materialsViewed / totalMaterials).clamp(0.0, 1.0);
    }

    switch (widget.enrollment?.status.toLowerCase() ?? 'active') {
      case 'completed':
        return 1.0;
      case 'dropped':
        return 0.0;
      default:
        return 0.5;
    }
  }

  @override
  void initState() {
    super.initState();

    final coursesBloc = context.read<CoursesBloc>();
    _courseDetailBloc = CourseDetailBloc(
      courseService: coursesBloc.courseService,
      materialService: coursesBloc.materialService,
      assignmentService: coursesBloc.assignmentService,
      labService: coursesBloc.labService,
      enrollmentService: coursesBloc.enrollmentService,
      communicationService: coursesBloc.communicationService,
      publicProfileService: coursesBloc.publicProfileService,
      officeHoursService: coursesBloc.officeHoursService,
    );

    final courseId = _resolvedCourseId;
    final sectionId = widget.enrollment?.sectionId;

    if (courseId != null) {
      _courseDetailBloc.add(
        LoadCourseDetail(
          courseId: courseId,
          sectionId: sectionId,
          prerequisites: widget.enrollment?.prerequisites,
          initialTabIndex: widget.initialTab,
        ),
      );
    } else {
      _courseDetailBloc.add(SwitchTab(tabIndex: widget.initialTab));

      if (sectionId != null && sectionId > 0) {
        _courseDetailBloc.add(LoadSectionStaff(sectionId: sectionId));
      }
    }

    _courseDetailBloc.add(const LoadMyAppointments());

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = true);
        _headerAnimationController.forward();
      } else if (_scrollController.offset <= 100 && _isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = false);
        _headerAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _scrollController.dispose();
    _courseDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final bgColor = isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF5F7FA);

        return PopScope<Object?>(
          canPop: true,
          onPopInvokedWithResult: _onPopInvoked,
          child: Scaffold(
            backgroundColor: bgColor,
            body: BlocProvider.value(
              value: _courseDetailBloc,
              child: BlocConsumer<CourseDetailBloc, CourseDetailState>(
                listenWhen: (previous, current) =>
                    previous.error != current.error ||
                    previous.bookingMessage != current.bookingMessage,
                listener: (context, detailState) {
                  if (detailState.error != null &&
                      detailState.error!.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(detailState.error!)),
                      );
                  } else if (detailState.bookingMessage != null &&
                      detailState.bookingMessage!.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(detailState.bookingMessage!)),
                      );
                  }
                },
                builder: (context, detailState) {
                  return Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Hero header with gradient
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF1E293B),
                                          const Color(0xFF0F172A),
                                        ]
                                      : _gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      CourseDetailsHeader(
                                        title: _title,
                                        isDark: isDark,
                                        onBackPressed: _handleBackPressed,
                                      ),
                                      const SizedBox(height: 20),
                                      // Stats cards row — T015
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              icon: Icons.credit_card_outlined,
                                              value: '$_credits',
                                              label: 'Credits',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildStatCard(
                                              icon: Icons.layers_outlined,
                                              value: _level,
                                              label: 'Level',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildStatCard(
                                              icon: Icons.check_circle_outline,
                                              value: _statusLabel,
                                              label: 'Status',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          // Content card
                          SliverToBoxAdapter(
                            child: Transform.translate(
                              offset: const Offset(0, -20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Instructor / Department info card
                                      _buildInstructorCard(
                                        context,
                                        isDark,
                                        detailState,
                                      ),
                                      if ((widget.enrollment?.sectionId ?? 0) >
                                              0 ||
                                          detailState
                                              .teachingAssistants
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 20),
                                        _buildTeachingAssistantsSection(
                                          context,
                                          isDark,
                                          detailState,
                                        ),
                                      ],
                                      const SizedBox(height: 20),
                                      // Course code & description
                                      if (_courseCode.isNotEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : const Color(0xFFF0F4FF),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            _courseCode,
                                            style: TextStyle(
                                              color: isDark
                                                  ? const Color(0xFF8EC5FF)
                                                  : const Color(0xFF155DFC),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      if (_description != null &&
                                          _description!.isNotEmpty) ...[
                                        Text(
                                          _description!,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : const Color(0xFF4A5565),
                                            fontSize: 14,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                      // Action buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _buildActionButton(
                                              label: 'Continue',
                                              icon: Icons.play_circle_outline,
                                              isPrimary: true,
                                              onTap: () {},
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildActionButton(
                                              label: 'Chat',
                                              icon: Icons.chat_bubble_outline,
                                              isPrimary: false,
                                              onTap: () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      // Progress section
                                      _buildProgressSection(
                                        isDark,
                                        detailState,
                                      ),
                                      const SizedBox(height: 24),
                                      // T008: Course Structure Viewer
                                      // if (widget.enrollment != null)
                                      //   CourseStructureViewer(
                                      //     courseId:
                                      //         widget
                                      //             .enrollment!
                                      //             .course
                                      //             ?.courseId ??
                                      //         widget.enrollment!.courseId,
                                      //     isDark: isDark,
                                      //   ),
                                      // if (widget.enrollment != null)
                                      //   const SizedBox(height: 24),
                                      // Tabs — pass legacy CourseModel for tab content compatibility
                                      CourseTabs(
                                        selectedIndex:
                                            detailState.selectedTabIndex,
                                        onTabChanged: (index) {
                                          context.read<CourseDetailBloc>().add(
                                            SwitchTab(tabIndex: index),
                                          );
                                        },
                                        isDark: isDark,
                                        course: _buildLegacyCourseForTabs(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (!didPop) {
      context.go('/courses');
    }
  }

  void _handleBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/courses');
  }

  /// Builds a legacy [CourseModel] for backwards compatibility with
  /// CourseTabs which still expects the old type.
  CourseModel _buildLegacyCourseForTabs() {
    if (widget.legacyCourse != null) return widget.legacyCourse!;
    return CourseModel(
      courseId: _resolvedCourseId,
      title: _title,
      instructor: _instructor,
      progress: _progress,
      nextEvent: '',
      eventDate: '',
      iconBackgroundColor: _gradientColors.first,
      courseIcon: Icons.school_outlined,
    );
  }

  Widget _buildInstructorCard(
    BuildContext blocContext,
    bool isDark,
    CourseDetailState detailState,
  ) {
    final instructorLabel = _resolveInstructorLabel(detailState);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: _gradientColors),
            ),
            child: const Icon(Icons.person, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openInstructorInfo(blocContext, detailState),
                  child: Text(
                    instructorLabel,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF101828),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Course Instructor',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF667085),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openInstructorInfo(blocContext, detailState),
            icon: const Icon(
              Icons.message_outlined,
              color: Color(0xFF155DFC),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  InstructorAssignmentModel? _resolvePrimaryInstructor(
    CourseDetailState detailState,
  ) {
    if (detailState.instructors.isEmpty) {
      return null;
    }

    for (final instructor in detailState.instructors) {
      if (instructor.role.toLowerCase() == 'primary') {
        return instructor;
      }
    }

    return detailState.instructors.first;
  }

  String _resolveInstructorLabel(CourseDetailState detailState) {
    final primaryInstructor = _resolvePrimaryInstructor(detailState);
    if (primaryInstructor != null) {
      final fullName = primaryInstructor.fullName.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }

      final email = primaryInstructor.email.trim();
      if (email.isNotEmpty) {
        return email;
      }
    }

    final enrollmentInstructorLabel = _resolveEnrollmentInstructorLabel();
    if (enrollmentInstructorLabel != null &&
        enrollmentInstructorLabel.isNotEmpty) {
      return enrollmentInstructorLabel;
    }

    final hasSection = (widget.enrollment?.sectionId ?? 0) > 0;
    if (hasSection) {
      return detailState.isLoadingStaff
          ? 'Loading instructor...'
          : 'Unknown Instructor';
    }

    return _instructor;
  }

  int? _resolveInstructorId(CourseDetailState detailState) {
    final primaryInstructor = _resolvePrimaryInstructor(detailState);
    if (primaryInstructor != null && primaryInstructor.userId > 0) {
      return primaryInstructor.userId;
    }

    final enrollmentInstructorId = _resolveEnrollmentInstructorId();
    if (enrollmentInstructorId != null && enrollmentInstructorId > 0) {
      return enrollmentInstructorId;
    }

    final directId = widget.enrollment?.course?.instructorId;
    if (directId != null && directId > 0) {
      return directId;
    }

    return null;
  }

  String? _resolveEnrollmentInstructorLabel() {
    final enrollmentInstructor = widget.enrollment?.instructor;
    if (enrollmentInstructor == null) {
      return null;
    }

    final fullName =
        '${enrollmentInstructor.firstName} ${enrollmentInstructor.lastName}'
            .trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = enrollmentInstructor.email.trim();
    if (email.isNotEmpty) {
      return email;
    }

    return null;
  }

  int? _resolveEnrollmentInstructorId() {
    final enrollmentInstructorId = widget.enrollment?.instructor?.userId;
    if (enrollmentInstructorId != null && enrollmentInstructorId > 0) {
      return enrollmentInstructorId;
    }

    return widget.enrollment?.course?.instructorId;
  }

  void _openInstructorInfo(
    BuildContext context,
    CourseDetailState detailState,
  ) {
    final primaryInstructor = _resolvePrimaryInstructor(detailState);
    final instructorId = _resolveInstructorId(detailState);

    if (instructorId == null || instructorId <= 0) {
      final sectionId = widget.enrollment?.sectionId;
      if (sectionId != null &&
          sectionId > 0 &&
          detailState.instructors.isEmpty &&
          !detailState.isLoadingStaff) {
        context.read<CourseDetailBloc>().add(
          LoadSectionStaff(sectionId: sectionId),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Instructor information is still loading.'),
            ),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No instructor is assigned yet.')),
          );
      }
      return;
    }

    final instructorName = primaryInstructor == null
        ? (_resolveEnrollmentInstructorLabel() ??
              _resolveInstructorLabel(detailState))
        : (primaryInstructor.fullName.trim().isNotEmpty
              ? primaryInstructor.fullName
              : (primaryInstructor.email.trim().isNotEmpty
                    ? primaryInstructor.email
                    : (_resolveEnrollmentInstructorLabel() ??
                          _resolveInstructorLabel(detailState))));
    final resolvedSectionId = (primaryInstructor?.sectionId ?? 0) > 0
        ? primaryInstructor!.sectionId
        : widget.enrollment?.sectionId;

    context.push(
      '/course-instructor-info',
      extra: <String, dynamic>{
        'instructorId': instructorId,
        'instructorName': instructorName,
        'courseId': _resolvedCourseId,
        'sectionId': resolvedSectionId,
        'staffRole': 'instructor',
      },
    );
  }

  Widget _buildTeachingAssistantsSection(
    BuildContext context,
    bool isDark,
    CourseDetailState detailState,
  ) {
    final assistants = detailState.teachingAssistants;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teaching Assistants',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (detailState.isLoadingStaff && assistants.isEmpty)
            Text(
              'Loading teaching assistants...',
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF667085),
                fontSize: 13,
              ),
            )
          else if (assistants.isEmpty)
            Text(
              'No teaching assistants are assigned yet.',
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF667085),
                fontSize: 13,
              ),
            )
          else
            ...List<Widget>.generate(assistants.length, (index) {
              final assistant = assistants[index];
              final assistantName = _resolveTeachingAssistantLabel(assistant);

              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: _gradientColors),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _openTeachingAssistantInfo(context, assistant),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assistantName,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF101828),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Teaching Assistant',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF667085),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _openTeachingAssistantInfo(context, assistant),
                      icon: const Icon(
                        Icons.message_outlined,
                        color: Color(0xFF155DFC),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _resolveTeachingAssistantLabel(TAAssignmentModel assistant) {
    final fullName = assistant.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = assistant.email.trim();
    if (email.isNotEmpty) {
      return email;
    }

    return 'TA #${assistant.userId}';
  }

  void _openTeachingAssistantInfo(
    BuildContext context,
    TAAssignmentModel assistant,
  ) {
    if (assistant.userId <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No TA profile is available yet.')),
        );
      return;
    }

    context.push(
      '/course-instructor-info',
      extra: <String, dynamic>{
        'instructorId': assistant.userId,
        'instructorName': _resolveTeachingAssistantLabel(assistant),
        'courseId': _resolvedCourseId,
        'sectionId': assistant.sectionId > 0
            ? assistant.sectionId
            : widget.enrollment?.sectionId,
        'staffRole': 'ta',
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
              )
            : null,
        color: isPrimary
            ? null
            : (context.read<ThemeBloc>().state.isDark
                  ? const Color(0xFF2D2D44)
                  : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFF155DFC), width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF155DFC).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF155DFC),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF155DFC),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _resolveProgressFromEnrollment(CourseDetailState detailState) {
    final progressPercentage = widget.enrollment?.progressPercentage;
    if (progressPercentage != null) {
      return (progressPercentage / 100).clamp(0.0, 1.0);
    }

    final backendMaterialsViewed = widget.enrollment?.materialsViewed ?? 0;
    final backendTotalMaterials = widget.enrollment?.totalMaterials ?? 0;
    final fallbackTotalMaterials = detailState.materials.length;

    final progressTotalMaterials = backendTotalMaterials > 0
        ? backendTotalMaterials
        : fallbackTotalMaterials;

    if (progressTotalMaterials > 0) {
      return (backendMaterialsViewed / progressTotalMaterials).clamp(0.0, 1.0);
    }

    return _progress;
  }

  Widget _buildProgressSection(bool isDark, CourseDetailState detailState) {
    final progress = _resolveProgressFromEnrollment(detailState);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Progress',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3D3D54)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _gradientColors),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.enrollment != null
                ? 'Enrolled: ${widget.enrollment!.enrollmentDate.toString().substring(0, 10)}'
                : (widget.legacyCourse?.nextEvent ?? ''),
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF667085),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
