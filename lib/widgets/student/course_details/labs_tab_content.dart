import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../../models/core/enums/assignment_enums.dart';
import '../../../models/core/enums/lab_enums.dart' as lab_api;
import '../../../models/labs/lab_model.dart' as api;
import '../../../models/labs/lab_submission_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../courses/course_model.dart' as legacy;
import 'lab_card.dart';

enum _LabDisplayStatus { upcoming, inProgress, completed, missed }

class LabsTabContent extends StatelessWidget {
  final bool isDark;
  final int? courseId;

  const LabsTabContent({super.key, required this.isDark, this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        final labs = _resolveLabs(state);

        if (state.isLoadingLabs && labs.isEmpty) {
          return _buildLoadingSkeleton();
        }

        if (state.error != null && state.error!.isNotEmpty && labs.isEmpty) {
          return _buildErrorState(context, state.error!);
        }

        if (labs.isEmpty) {
          return _buildEmptyState('No labs are available yet.');
        }

        return Column(
          children: <Widget>[
            if (state.usedLabsMaterialsFallback)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFallbackInfo(),
              ),
            ...List<Widget>.generate(
              labs.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == labs.length - 1 ? 0 : 16,
                ),
                child: LabCard(lab: labs[index], isDark: isDark),
              ),
            ),
          ],
        );
      },
    );
  }

  List<legacy.Lab> _resolveLabs(CourseDetailState state) {
    final mapped = state.labs
        .map((lab) => _mapLab(lab, state.labSubmissions))
        .toList(growable: false);

    if (mapped.isNotEmpty) {
      final sorted = List<legacy.Lab>.from(mapped);
      sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return sorted;
    }

    final fallback = state.materials
        .where(_isLabMaterial)
        .map(_mapMaterialAsLab)
        .toList(growable: false);

    fallback.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return fallback;
  }

  legacy.Lab _mapLab(
    api.LabModel lab,
    Map<int, LabSubmissionModel?> submissions,
  ) {
    final dueDate =
        lab.dueDate ??
        lab.availableFrom ??
        lab.updatedAt ??
        lab.createdAt ??
        DateTime.now();
    final parsedLabId = lab.labId ?? int.tryParse(lab.id) ?? 0;
    final submission = parsedLabId > 0 ? submissions[parsedLabId] : null;

    return legacy.Lab(
      id: lab.id,
      title: lab.title,
      description: _safeDescription(lab.description),
      dueDate: dueDate,
      status: _resolveLabStatus(lab, submission, dueDate),
      gradePercentage: _resolveGradePercentage(lab, submission),
    );
  }

  legacy.Lab _mapMaterialAsLab(CourseMaterialModel material) {
    final dueDate =
        material.publishedAt ?? material.updatedAt ?? material.createdAt;
    final isPastDue = dueDate.isBefore(DateTime.now());

    return legacy.Lab(
      id: material.materialId,
      title: material.title,
      description: _safeDescription(material.description),
      dueDate: dueDate,
      status: isPastDue
          ? legacy.LabStatus.pending
          : legacy.LabStatus.notStarted,
    );
  }

  legacy.LabStatus _resolveLabStatus(
    api.LabModel lab,
    LabSubmissionModel? submission,
    DateTime dueDate,
  ) {
    if (submission != null) {
      if (submission.submissionStatus == SubmissionStatus.graded ||
          submission.score != null) {
        return legacy.LabStatus.graded;
      }

      if (submission.submissionStatus == SubmissionStatus.submitted ||
          submission.submissionStatus == SubmissionStatus.returned ||
          submission.submissionStatus == SubmissionStatus.resubmit ||
          submission.submissionStatus == SubmissionStatus.unknown) {
        return legacy.LabStatus.submitted;
      }
    }

    final displayStatus = _displayStatusForLab(lab, dueDate);

    switch (displayStatus) {
      case _LabDisplayStatus.upcoming:
        return legacy.LabStatus.notStarted;
      case _LabDisplayStatus.inProgress:
      case _LabDisplayStatus.completed:
      case _LabDisplayStatus.missed:
        return legacy.LabStatus.pending;
    }
  }

  _LabDisplayStatus _displayStatusForLab(api.LabModel lab, DateTime dueDate) {
    switch (lab.status) {
      case lab_api.LabStatus.closed:
        return _LabDisplayStatus.completed;
      case lab_api.LabStatus.archived:
        return _LabDisplayStatus.missed;
      case lab_api.LabStatus.published:
        final now = DateTime.now();
        if (dueDate.isAfter(now)) {
          return _LabDisplayStatus.upcoming;
        }

        final daysUntilDue = dueDate.difference(now).inDays;
        if (daysUntilDue <= -2) {
          return _LabDisplayStatus.missed;
        }

        return _LabDisplayStatus.inProgress;
      case lab_api.LabStatus.draft:
      case lab_api.LabStatus.unknown:
        return _LabDisplayStatus.upcoming;
    }
  }

  String? _resolveGradePercentage(
    api.LabModel lab,
    LabSubmissionModel? submission,
  ) {
    final score = submission?.score;
    if (score == null) {
      return null;
    }

    if (lab.maxScore > 0) {
      final percentage = ((score / lab.maxScore) * 100).round().clamp(0, 100);
      return '$percentage';
    }

    final hasDecimal = score % 1 != 0;
    return hasDecimal ? score.toStringAsFixed(1) : score.toStringAsFixed(0);
  }

  bool _isLabMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    return type == 'lab' || type == 'laboratory';
  }

  String _safeDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No lab description available yet.';
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
              'Showing labs from course materials while dedicated lab records sync.',
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
          height: 120,
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
                LoadLabs(courseId: courseId!),
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
