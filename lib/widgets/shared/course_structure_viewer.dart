import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/courses/courses_bloc.dart';
import '../../bloc/courses/courses_event.dart';
import '../../bloc/courses/courses_state.dart';
import '../../models/core/course_structure_model.dart';
import '../../widgets/shared/material_type_icon.dart';

/// T008/T009/T010/T012: Shared course structure viewer widget that renders
/// the week-by-week syllabus from the backend `/api/courses/{courseId}/structure`.
///
/// Reused across Student, Instructor, and TA dashboards.
class CourseStructureViewer extends StatefulWidget {
  final dynamic courseId;
  final bool isDark;

  const CourseStructureViewer({
    super.key,
    required this.courseId,
    required this.isDark,
  });

  @override
  State<CourseStructureViewer> createState() => _CourseStructureViewerState();
}

class _CourseStructureViewerState extends State<CourseStructureViewer> {
  @override
  void initState() {
    super.initState();
    // Dispatch the fetch event to load structure from API (or cache)
    context.read<CoursesBloc>().add(
          CourseStructureFetched(courseId: widget.courseId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      buildWhen: (prev, curr) =>
          curr is CourseStructureLoaded ||
          curr is CoursesLoading ||
          curr is CoursesError,
      builder: (context, state) {
        if (state is CoursesLoading) {
          return _buildLoadingSkeleton();
        }
        if (state is CoursesError) {
          return _buildErrorState(state.message);
        }
        if (state is CourseStructureLoaded) {
          if (state.structure.isEmpty) {
            return _buildEmptyState();
          }
          return _buildStructureList(state.structure);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── Structure List ──────────────────────────────────────────────────────

  Widget _buildStructureList(List<CourseStructureModel> items) {
    // Group by week number
    final Map<int, List<CourseStructureModel>> byWeek = {};
    for (final item in items) {
      final week = item.weekNumber;
      byWeek.putIfAbsent(week, () => []).add(item);
    }

    final sortedWeeks = byWeek.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.calendar_view_week_rounded,
              color: widget.isDark
                  ? const Color(0xFF8EC5FF)
                  : const Color(0xFF155DFC),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Course Structure',
              style: TextStyle(
                color: widget.isDark ? Colors.white : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekly sections
        ...sortedWeeks.map((week) => _buildWeekSection(week, byWeek[week]!)),
      ],
    );
  }

  Widget _buildWeekSection(int weekNumber, List<CourseStructureModel> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF2D2D44) : Colors.white,
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
          // Week header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                    : [const Color(0xFFF0F4FF), const Color(0xFFE8EEFF)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF155DFC).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Week $weekNumber',
                    style: TextStyle(
                      color: widget.isDark
                          ? const Color(0xFF8EC5FF)
                          : const Color(0xFF155DFC),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${items.length} item${items.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white54 : const Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return _buildStructureItem(entry.value, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildStructureItem(CourseStructureModel item, bool isLast) {
    final hasMaterial = item.material != null;
    final materialType = item.material?.materialType ?? item.organizationType;

    return InkWell(
      onTap: hasMaterial ? () => _onMaterialTapped(item) : null,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF0F0F5),
                  ),
                ),
        ),
        child: Row(
          children: [
            // Material type icon
            MaterialTypeIcon(
              type: materialType,
              isDark: widget.isDark,
              size: 20,
            ),
            const SizedBox(width: 14),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF1A202C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.white54
                            : const Color(0xFF667085),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Tap indicator chevron for materials
            if (hasMaterial)
              Icon(
                Icons.chevron_right_rounded,
                color: widget.isDark ? Colors.white38 : const Color(0xFFCBD5E0),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ── T012: URL Launcher Interaction ────────────────────────────────────────

  Future<void> _onMaterialTapped(CourseStructureModel item) async {
    final material = item.material;
    if (material == null) return;

    // Try external URL first
    String? urlToLaunch = material.externalUrl;

    // If YouTube video, construct URL
    if (urlToLaunch == null && material.youtubeVideoId != null) {
      urlToLaunch = 'https://www.youtube.com/watch?v=${material.youtubeVideoId}';
    }

    if (urlToLaunch != null && urlToLaunch.isNotEmpty) {
      final uri = Uri.tryParse(urlToLaunch);
      if (uri != null) {
        try {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched && mounted) {
            _showErrorSnackbar('Could not open this resource');
          }
        } catch (_) {
          if (mounted) {
            _showErrorSnackbar('Invalid or broken resource link');
          }
        }
      } else {
        _showErrorSnackbar('Invalid resource URL');
      }
    } else {
      // No external link — show info toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${material.title} — No viewable link available'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── State Views ────────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: widget.isDark ? const Color(0xFFFC8181) : const Color(0xFFE53E3E),
          ),
          const SizedBox(height: 12),
          Text(
            message.isNotEmpty ? message : 'Failed to load course structure',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isDark ? Colors.white70 : const Color(0xFF4A5565),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              context.read<CoursesBloc>().add(
                    CourseStructureFetched(courseId: widget.courseId),
                  );
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF2D2D44).withValues(alpha: 0.5)
                : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 56,
            color: widget.isDark ? Colors.white24 : const Color(0xFFCBD5E0),
          ),
          const SizedBox(height: 16),
          Text(
            'No materials available yet',
            style: TextStyle(
              color: widget.isDark ? Colors.white54 : const Color(0xFF667085),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Course content will appear here once uploaded.',
            style: TextStyle(
              color: widget.isDark ? Colors.white30 : const Color(0xFFA0AEC0),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
