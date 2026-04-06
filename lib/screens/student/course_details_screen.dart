import 'package:edu_verse/widgets/student/course_details/course_details_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/course_ui_utils.dart';
import '../../models/core/enrollment_model.dart';
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
  late int _selectedTabIndex;
  late AnimationController _headerAnimationController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  // ── Safe accessors with SC-003 null-coalescing ─────────────────────────

  String get _title {
    if (widget.enrollment != null) {
      return CourseUiUtils.safeCourseTitle(
          widget.enrollment!.course?.courseName);
    }
    return widget.legacyCourse?.title ?? 'Course';
  }

  String get _courseCode {
    if (widget.enrollment != null) {
      return CourseUiUtils.safeCourseCode(
          widget.enrollment!.course?.courseCode);
    }
    return '';
  }

  String get _instructor {
    if (widget.enrollment != null) {
      return widget.enrollment!.course?.departmentName ?? 'Unknown Instructor';
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

  List<Color> get _gradientColors {
    if (widget.enrollment != null) {
      return CourseUiUtils.gradientForCourseId(
          widget.enrollment!.course?.courseId ?? widget.enrollment!.courseId);
    }
    return [const Color(0xFF2B7FFF), const Color(0xFF155DFC)];
  }

  /// Legacy progress value (from old model) or status-derived value.
  double get _progress {
    if (widget.legacyCourse != null) {
      return widget.legacyCourse!.progress;
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
    _selectedTabIndex = widget.initialTab;
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

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
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
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
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
                                onBackPressed: () => Navigator.pop(context),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Instructor / Department info card
                              _buildInstructorCard(isDark),
                              const SizedBox(height: 20),
                              // Course code & description
                              if (_courseCode.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.08)
                                        : const Color(0xFFF0F4FF),
                                    borderRadius: BorderRadius.circular(8),
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
                              _buildProgressSection(isDark),
                              const SizedBox(height: 24),
                              // Tabs — pass legacy CourseModel for tab content compatibility
                              CourseTabs(
                                selectedIndex: _selectedTabIndex,
                                onTabChanged: (index) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
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
          ),
        );
      },
    );
  }

  /// Builds a legacy [CourseModel] for backwards compatibility with
  /// CourseTabs which still expects the old type.
  CourseModel _buildLegacyCourseForTabs() {
    if (widget.legacyCourse != null) return widget.legacyCourse!;
    return CourseModel(
      title: _title,
      instructor: _instructor,
      progress: _progress,
      nextEvent: '',
      eventDate: '',
      iconBackgroundColor: _gradientColors.first,
      courseIcon: Icons.school_outlined,
    );
  }

  Widget _buildInstructorCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                Text(
                  _instructor,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
            onPressed: () {},
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

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
              color: Colors.white.withOpacity(0.8),
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
                  color: const Color(0xFF155DFC).withOpacity(0.3),
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

  Widget _buildProgressSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  widthFactor: _progress,
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
