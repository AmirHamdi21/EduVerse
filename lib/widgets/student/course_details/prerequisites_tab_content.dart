import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../../models/core/course_model.dart';
import '../../../models/core/enrollment_model.dart';

class PrerequisitesTabContent extends StatelessWidget {
  final bool isDark;

  const PrerequisitesTabContent({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        final enrollmentPrerequisites = state.prerequisites;
        final fallbackPrerequisites =
            state.course?.prerequisites ?? const <CoursePrerequisite>[];

        final hasEnrollmentData = enrollmentPrerequisites.isNotEmpty;
        final hasFallbackData =
            !hasEnrollmentData && fallbackPrerequisites.isNotEmpty;

        if (state.isLoadingPrerequisites &&
            !hasEnrollmentData &&
            !hasFallbackData) {
          return _buildLoadingSkeleton();
        }

        if (!hasEnrollmentData && !hasFallbackData) {
          return _buildEmptyState(
            'No prerequisites are listed for this course.',
          );
        }

        return Column(
          children: [
            if (hasEnrollmentData) ...[
              _buildProgressSummary(enrollmentPrerequisites),
              const SizedBox(height: 12),
            ],
            if (hasFallbackData)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFallbackInfo(),
              ),
            ..._buildPrerequisiteCards(
              enrollmentPrerequisites: enrollmentPrerequisites,
              fallbackPrerequisites: fallbackPrerequisites,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPrerequisiteCards({
    required List<EnrollmentPrerequisite> enrollmentPrerequisites,
    required List<CoursePrerequisite> fallbackPrerequisites,
  }) {
    if (enrollmentPrerequisites.isNotEmpty) {
      return List<Widget>.generate(
        enrollmentPrerequisites.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == enrollmentPrerequisites.length - 1 ? 0 : 10,
          ),
          child: _buildEnrollmentPrerequisiteCard(
            enrollmentPrerequisites[index],
          ),
        ),
      );
    }

    return List<Widget>.generate(
      fallbackPrerequisites.length,
      (index) => Padding(
        padding: EdgeInsets.only(
          bottom: index == fallbackPrerequisites.length - 1 ? 0 : 10,
        ),
        child: _buildFallbackPrerequisiteCard(fallbackPrerequisites[index]),
      ),
    );
  }

  Widget _buildProgressSummary(List<EnrollmentPrerequisite> prerequisites) {
    final completedCount = prerequisites
        .where((item) => item.studentCompleted)
        .length;
    final mandatoryCount = prerequisites
        .where((item) => item.isMandatory)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF155DFC).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.rule_folder_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$completedCount of ${prerequisites.length} prerequisites completed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$mandatoryCount required',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentPrerequisiteCard(EnrollmentPrerequisite prerequisite) {
    final bgColor = isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final secondary = isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);
    final statusColor = prerequisite.studentCompleted
        ? const Color(0xFF008236)
        : const Color(0xFFCA3500);
    final statusBg = prerequisite.studentCompleted
        ? const Color(0xFFE0F8F0)
        : const Color(0xFFFFEDD4);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  prerequisite.studentCompleted
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${prerequisite.courseCode} - ${prerequisite.courseName}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(
                  label: prerequisite.isMandatory ? 'Mandatory' : 'Optional',
                  textColor: prerequisite.isMandatory
                      ? const Color(0xFF155DFC)
                      : const Color(0xFF364153),
                  backgroundColor: prerequisite.isMandatory
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF3F4F6),
                ),
                _buildBadge(
                  label: prerequisite.studentCompleted
                      ? 'Completed'
                      : 'Not Completed',
                  textColor: statusColor,
                  backgroundColor: statusBg,
                ),
              ],
            ),
            if (prerequisite.studentGrade != null &&
                prerequisite.studentGrade!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Recorded Grade: ${prerequisite.studentGrade}',
                style: TextStyle(
                  color: secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPrerequisiteCard(CoursePrerequisite prerequisite) {
    final bgColor = isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final secondary = isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);
    final code =
        prerequisite.prerequisiteCourse?.code ??
        'Course ${prerequisite.prerequisiteCourseId}';
    final name =
        prerequisite.prerequisiteCourse?.name ??
        'Prerequisite course details unavailable';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$code - $name',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(
                  label: prerequisite.isMandatory ? 'Mandatory' : 'Optional',
                  textColor: prerequisite.isMandatory
                      ? const Color(0xFF155DFC)
                      : const Color(0xFF364153),
                  backgroundColor: prerequisite.isMandatory
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF3F4F6),
                ),
                _buildBadge(
                  label: 'Completion unknown',
                  textColor: const Color(0xFFB54708),
                  backgroundColor: const Color(0xFFFFF4E5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Student completion data is unavailable in this payload.',
              style: TextStyle(color: secondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Arimo',
        ),
      ),
    );
  }

  Widget _buildFallbackInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2B7FFF) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF155DFC)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing course-defined prerequisites because enrollment prerequisite details are missing.',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFF1E40AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List<Widget>.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          height: 110,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D44) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF667085),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
