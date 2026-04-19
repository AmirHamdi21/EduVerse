import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../../models/assignments/assignment_model.dart' as api;
import '../../../models/assignments/assignment_submission_model.dart';
import '../../../models/core/enums/assignment_enums.dart';
import '../../../models/materials/course_material_model.dart';
import '../courses/course_model.dart' as legacy;
import 'assignment_card.dart';

class AssignmentsTabContent extends StatelessWidget {
  final bool isDark;
  final int? courseId;

  const AssignmentsTabContent({super.key, required this.isDark, this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        final assignments = _resolveAssignments(state);

        if (state.isLoadingAssignments && assignments.isEmpty) {
          return _buildLoadingSkeleton();
        }

        if (state.error != null &&
            state.error!.isNotEmpty &&
            assignments.isEmpty) {
          return _buildErrorState(context, state.error!);
        }

        if (assignments.isEmpty) {
          return _buildEmptyState('No assignments are available yet.');
        }

        return Column(
          children: <Widget>[
            if (state.usedAssignmentsMaterialsFallback)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFallbackInfo(),
              ),
            ...List<Widget>.generate(
              assignments.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == assignments.length - 1 ? 0 : 16,
                ),
                child: AssignmentCard(
                  assignment: assignments[index],
                  isDark: isDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<legacy.Assignment> _resolveAssignments(CourseDetailState state) {
    final mapped = state.assignments
        .map(
          (assignment) =>
              _mapAssignment(assignment, state.assignmentSubmissions),
        )
        .toList(growable: false);

    if (mapped.isNotEmpty) {
      final sorted = List<legacy.Assignment>.from(mapped);
      sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return sorted;
    }

    final fallback = state.materials
        .where(_isAssignmentMaterial)
        .map(_mapMaterialAsAssignment)
        .toList(growable: false);

    fallback.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return fallback;
  }

  legacy.Assignment _mapAssignment(
    api.AssignmentModel assignment,
    Map<int, AssignmentSubmissionModel?> submissions,
  ) {
    final assignmentId = assignment.assignmentId > 0
        ? assignment.assignmentId
        : int.tryParse(assignment.id) ?? 0;
    final submission = assignmentId > 0 ? submissions[assignmentId] : null;
    final status = _resolveAssignmentStatus(assignment, submission);
    final progress = _resolveProgress(assignment, submission);

    return legacy.Assignment(
      id: assignment.id,
      title: assignment.title,
      description: _safeDescription(assignment.description),
      dueDate: assignment.dueDate,
      status: status,
      progressPercentage: progress,
      hasSubmission: submission != null,
      isGraded: _isGradedSubmission(submission),
    );
  }

  legacy.Assignment _mapMaterialAsAssignment(CourseMaterialModel material) {
    final dueDate =
        material.publishedAt ?? material.updatedAt ?? material.createdAt;
    final isPastDue = dueDate.isBefore(DateTime.now());

    return legacy.Assignment(
      id: material.materialId,
      title: material.title,
      description: _safeDescription(material.description),
      dueDate: dueDate,
      status: isPastDue
          ? legacy.AssignmentStatus.inProgress
          : legacy.AssignmentStatus.notStarted,
      progressPercentage: isPastDue ? 40 : 0,
    );
  }

  legacy.AssignmentStatus _resolveAssignmentStatus(
    api.AssignmentModel assignment,
    AssignmentSubmissionModel? submission,
  ) {
    if (submission != null) {
      if (_isGradedSubmission(submission)) {
        return legacy.AssignmentStatus.completed;
      }

      if (submission.submissionStatus == SubmissionStatus.returned ||
          submission.submissionStatus == SubmissionStatus.resubmit ||
          submission.submissionStatus == SubmissionStatus.unknown) {
        return legacy.AssignmentStatus.inProgress;
      }

      return legacy.AssignmentStatus.completed;
    }

    return assignment.dueDate.isBefore(DateTime.now())
        ? legacy.AssignmentStatus.inProgress
        : legacy.AssignmentStatus.notStarted;
  }

  int _resolveProgress(
    api.AssignmentModel assignment,
    AssignmentSubmissionModel? submission,
  ) {
    if (submission?.score != null && assignment.maxGrade > 0) {
      final percent = ((submission!.score! / assignment.maxGrade) * 100)
          .round()
          .clamp(0, 100);
      return percent;
    }

    if (submission != null) {
      switch (submission.submissionStatus) {
        case SubmissionStatus.graded:
          return 100;
        case SubmissionStatus.submitted:
          return 85;
        case SubmissionStatus.returned:
        case SubmissionStatus.resubmit:
          return 70;
        case SubmissionStatus.unknown:
          return 60;
      }
    }

    return assignment.dueDate.isBefore(DateTime.now()) ? 40 : 0;
  }

  bool _isGradedSubmission(AssignmentSubmissionModel? submission) {
    if (submission == null) {
      return false;
    }

    return submission.submissionStatus == SubmissionStatus.graded ||
        submission.score != null;
  }

  bool _isAssignmentMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    return type == 'assignment' || type == 'homework';
  }

  String _safeDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No assignment description available yet.';
    }
    return value.trim();
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
              'Showing assignments from course materials while dedicated assignment records sync.',
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
          height: 136,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D44) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF4A5565),
            fontSize: 13,
          ),
        ),
        if (courseId != null && courseId! > 0) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              context.read<CourseDetailBloc>().add(
                LoadAssignments(courseId: courseId!),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ],
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
