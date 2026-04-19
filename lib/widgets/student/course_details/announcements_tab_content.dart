import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../../models/materials/announcement_model.dart';

class AnnouncementsTabContent extends StatelessWidget {
  final bool isDark;
  final int? courseId;

  const AnnouncementsTabContent({
    super.key,
    required this.isDark,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        final announcements = List<AnnouncementModel>.from(state.announcements)
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

        if (state.isLoadingAnnouncements && announcements.isEmpty) {
          return _buildLoadingSkeleton();
        }

        if (state.error != null &&
            state.error!.isNotEmpty &&
            announcements.isEmpty) {
          return _buildErrorState(context, state.error!);
        }

        if (announcements.isEmpty) {
          return _buildEmptyState('No announcements have been posted yet.');
        }

        return Column(
          children: List<Widget>.generate(
            announcements.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == announcements.length - 1 ? 0 : 12,
              ),
              child: _buildAnnouncementCard(announcements[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    final backgroundColor = isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final secondaryColor = isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);
    final priorityColor = _priorityColor(announcement.priority);
    final prioritySurface = _prioritySurfaceColor(announcement.priority);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF155DFC).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    size: 18,
                    color: Color(0xFF155DFC),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: prioritySurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _priorityLabel(announcement.priority),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.content,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arimo',
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 15,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Published ${_formatDate(announcement.publishedAt)}',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (announcement.expiresAt != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 15,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Expires ${_formatDate(announcement.expiresAt!)}',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'high':
        return const Color(0xFFB42318);
      case 'medium':
        return const Color(0xFFB54708);
      default:
        return const Color(0xFF155DFC);
    }
  }

  Color _prioritySurfaceColor(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'high':
        return const Color(0xFFFEE4E2);
      case 'medium':
        return const Color(0xFFFFF4E5);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  String _priorityLabel(String priority) {
    final normalized = priority.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Low';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List<Widget>.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          height: 132,
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
                LoadAnnouncements(courseId: courseId!),
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
