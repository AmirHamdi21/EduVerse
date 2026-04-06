
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../common/utils/course_ui_utils.dart';
import '../../../models/core/enrollment_model.dart';

/// Displays a single course enrollment card with live data from the API.
///
/// Consumes [CourseEnrollmentModel] and uses [CourseUiUtils] for
/// deterministic gradient backgrounds when thumbnails are unavailable.
class CourseCard extends StatefulWidget {
  final CourseEnrollmentModel enrollment;
  final Animation<double>? animation;

  const CourseCard({super.key, required this.enrollment, this.animation});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Safe course title extraction with SC-003 null-coalescing.
  String get _title =>
      CourseUiUtils.safeCourseTitle(widget.enrollment.course?.courseName);

  /// Safe course code extraction with SC-003 null-coalescing.
  String get _courseCode =>
      CourseUiUtils.safeCourseCode(widget.enrollment.course?.courseCode);

  /// Department name or fallback text if unavailable.
  String get _departmentOrInstructor =>
      widget.enrollment.course?.departmentName ?? 'General';

  /// Credit hours display.
  int get _credits => widget.enrollment.course?.credits ?? 0;

  /// Enrollment status label.
  String get _statusLabel {
    switch (widget.enrollment.status.toLowerCase()) {
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

  /// Deterministic gradient colors for the course icon placeholder.
  List<Color> get _gradientColors => CourseUiUtils.gradientForCourseId(
      widget.enrollment.course?.courseId ?? widget.enrollment.courseId);

  /// Initials for the gradient avatar.
  String get _initials => CourseUiUtils.initialsFromCourseName(
      widget.enrollment.course?.courseName ?? '');



  /// Status badge color.
  Color get _statusColor {
    switch (widget.enrollment.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'dropped':
        return const Color(0xFFEF4444);
      case 'waitlisted':
        return const Color(0xFFF59E0B);
      case 'active':
      case 'enrolled':
      default:
        return const Color(0xFF155DFC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return SlideTransition(
          position:
              widget.animation?.drive(
                Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ) ??
              const AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity:
                widget.animation?.drive(
                  Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                ) ??
                const AlwaysStoppedAnimation(1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFD1D5DC),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseHeader(isDark),
                    const SizedBox(height: 24),
                    _buildInfoSection(isDark),
                    const SizedBox(height: 24),
                    _buildActionButtons(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient avatar with initials (replaces hardcoded icon)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _courseCode,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF4A5565),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF6A7282),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _departmentOrInstructor,
                    style: TextStyle(
                      color:
                          isDark ? Colors.white54 : const Color(0xFF6A7282),
                      fontSize: 12,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusLabel,
            style: TextStyle(
              color: _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Row(
      children: [
        _buildInfoChip(
          icon: Icons.credit_card_outlined,
          label: '$_credits Credits',
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildInfoChip(
          icon: Icons.layers_outlined,
          label: widget.enrollment.course?.level ?? 'N/A',
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildInfoChip(
          icon: Icons.person_outline,
          label: widget.enrollment.role,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isDark ? Colors.white54 : const Color(0xFF6A7282)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF4A5565),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF155DFC).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.push('/course-details', extra: widget.enrollment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF155DFC),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: isDark ? const Color(0xff8EC5FF) : const Color(0xFF155DFC),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Materials',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xff8EC5FF) : const Color(0xFF155DFC),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
