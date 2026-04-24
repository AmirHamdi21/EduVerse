import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/materials/announcement_model.dart';
import '../../../services/api/communication_service.dart';
import '../../../services/api/core_api_client.dart';

class StudentAnnouncementsScreen extends StatefulWidget {
  const StudentAnnouncementsScreen({super.key});

  @override
  State<StudentAnnouncementsScreen> createState() =>
      _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState
    extends State<StudentAnnouncementsScreen> {
  late final CommunicationService _communicationService;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedAnnouncementIds = <String>{};

  List<AnnouncementModel> _announcements = const [];
  String _selectedCourseFilter = 'all';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _communicationService = CommunicationService(
      coreApiClient: CoreApiClient(),
    );
    _searchController.addListener(_onSearchChanged);
    _loadAnnouncements();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _communicationService.getAnnouncements();
      if (!mounted) return;
      setState(() {
        _announcements = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  List<_CourseFilterOption> get _courseFilters {
    final map = <String, _CourseFilterOption>{};
    for (final announcement in _announcements) {
      final courseId = announcement.courseId ?? announcement.course?.id ?? '';
      if (courseId.trim().isEmpty) continue;
      final code = announcement.course?.code?.trim();
      final name = announcement.course?.name?.trim();
      final label = [
        if (code != null && code.isNotEmpty) code,
        if (name != null && name.isNotEmpty) name,
      ].join(' - ');

      map[courseId] = _CourseFilterOption(
        id: courseId,
        label: label.isEmpty ? 'Course $courseId' : label,
      );
    }

    final options = map.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return options;
  }

  List<AnnouncementModel> get _visibleAnnouncements {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _announcements.where((announcement) {
      if (announcement.isPublished != 1) {
        return false;
      }

      final courseId = announcement.courseId ?? announcement.course?.id ?? '';
      final matchesCourse = _selectedCourseFilter == 'all'
          ? true
          : courseId == _selectedCourseFilter;

      if (!matchesCourse) return false;

      if (query.isEmpty) return true;

      final author = announcement.author?.displayName.toLowerCase() ?? '';
      final courseCode = announcement.course?.code?.toLowerCase() ?? '';
      final courseName = announcement.course?.name?.toLowerCase() ?? '';
      return announcement.title.toLowerCase().contains(query) ||
          announcement.content.toLowerCase().contains(query) ||
          author.contains(query) ||
          courseCode.contains(query) ||
          courseName.contains(query);
    }).toList();

    // Match website behavior: pinned first, then newest first.
    filtered.sort((a, b) {
      final aPinned = a.isPinned == 1;
      final bPinned = b.isPinned == 1;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return (b.publishedAt ?? b.createdAt).compareTo(
        a.publishedAt ?? a.createdAt,
      );
    });
    return filtered;
  }

  _AnnouncementStats get _stats {
    final now = DateTime.now();
    var urgent = 0;
    var thisWeek = 0;
    final courseIds = <String>{};

    for (final announcement in _announcements.where(
      (item) => item.isPublished == 1,
    )) {
      if (announcement.priority.trim().toLowerCase() == 'urgent') {
        urgent += 1;
      }

      final publishedDate = announcement.publishedAt ?? announcement.createdAt;
      if (now.difference(publishedDate).inDays <= 7) {
        thisWeek += 1;
      }

      final courseId = announcement.courseId ?? announcement.course?.id;
      if (courseId != null && courseId.trim().isNotEmpty) {
        courseIds.add(courseId);
      }
    }

    return _AnnouncementStats(
      total: _announcements.length,
      urgent: urgent,
      courses: courseIds.length,
      thisWeek: thisWeek,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final visibleAnnouncements = _visibleAnnouncements;
        final stats = _stats;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FBFF),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadAnnouncements,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context, isDark, l10n, stats),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSearchAndFilters(context, isDark),
                  ),
                  if (_isLoading)
                    SliverToBoxAdapter(child: _buildLoadingState(isDark))
                  else if (_errorMessage != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(context, isDark),
                    )
                  else if (visibleAnnouncements.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(isDark),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                      sliver: SliverList.builder(
                        itemCount: visibleAnnouncements.length,
                        itemBuilder: (context, index) {
                          final announcement = visibleAnnouncements[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == visibleAnnouncements.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: _buildAnnouncementCard(announcement, isDark),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    _AnnouncementStats stats,
  ) {
    final titleColor = Colors.white;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF06B6D4), Color(0xFF0EA5E9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF2563EB,
            ).withValues(alpha: isDark ? 0.25 : 0.18),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.announcements,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Latest updates and important notices from your instructors',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile('Total', stats.total.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile('Urgent', stats.urgent.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile('Courses', stats.courses.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile('This Week', stats.thisWeek.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDark) {
    final filters = _courseFilters;
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Search announcements...',
              hintStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              filled: true,
              fillColor: inputBg,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              suffixIcon: _searchController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => _searchController.clear(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCourseChip(
                  label: 'All Courses',
                  selected: _selectedCourseFilter == 'all',
                  onTap: () => setState(() => _selectedCourseFilter = 'all'),
                ),
                const SizedBox(width: 8),
                ...filters.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCourseChip(
                      label: course.label,
                      selected: _selectedCourseFilter == course.id,
                      onTap: () =>
                          setState(() => _selectedCourseFilter = course.id),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF334155),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: List<Widget>.generate(
          4,
          (index) => Container(
            margin: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
            height: 142,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
            ),
            const SizedBox(height: 10),
            Text(
              'Could not load announcements',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _loadAnnouncements,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final hasFilters =
        _searchController.text.trim().isNotEmpty ||
        _selectedCourseFilter != 'all';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 48,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 10),
            Text(
              'No announcements found',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? "We couldn't find any announcements matching your current filters."
                  : 'There are no announcements for your courses at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
                fontSize: 13.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement, bool isDark) {
    final date = announcement.publishedAt ?? announcement.createdAt;
    final dateText = DateFormat('MMM d, yyyy').format(date);
    final timeText = DateFormat('h:mm a').format(date);
    final author = announcement.author?.displayName ?? 'Instructor';
    final courseCode = announcement.course?.code?.trim();
    final courseName = announcement.course?.name?.trim();
    final courseLabel = (courseCode != null && courseCode.isNotEmpty)
        ? courseCode
        : ((courseName != null && courseName.isNotEmpty)
              ? courseName
              : 'General');
    final priority = announcement.priority.trim().toLowerCase();
    final isExpanded = _expandedAnnouncementIds.contains(announcement.id);
    final shouldCollapse = announcement.content.trim().length > 260;
    final visibleContent = shouldCollapse && !isExpanded
        ? '${announcement.content.trim().substring(0, 260)}...'
        : announcement.content;
    final priorityBg = switch (priority) {
      'urgent' => const Color(0xFFEF4444),
      'high' => const Color(0xFFF97316),
      'medium' => const Color(0xFF3B82F6),
      _ => const Color(0xFF64748B),
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (announcement.isPinned == 1)
                  _metaBadge(
                    label: 'Pinned',
                    bg: isDark
                        ? const Color(0xFF78350F)
                        : const Color(0xFFFEF3C7),
                    fg: isDark
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFF92400E),
                    icon: Icons.push_pin_rounded,
                  ),
                _metaBadge(
                  label: courseLabel,
                  bg: isDark
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFDBEAFE),
                  fg: isDark
                      ? const Color(0xFFBFDBFE)
                      : const Color(0xFF1E40AF),
                  icon: Icons.book_outlined,
                ),
                _metaBadge(
                  label: priority.isEmpty ? 'normal' : priority,
                  bg: priorityBg,
                  fg: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _metaLine(Icons.person_outline_rounded, author, isDark),
                _metaLine(Icons.calendar_today_outlined, dateText, isDark),
                _metaLine(Icons.access_time_rounded, timeText, isDark),
                _metaLine(
                  Icons.visibility_outlined,
                  '${announcement.viewCount} views',
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              visibleContent,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF334155),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (shouldCollapse) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedAnnouncementIds.remove(announcement.id);
                      } else {
                        _expandedAnnouncementIds.add(announcement.id);
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                  ),
                  label: Text(isExpanded ? 'Show less' : 'Read more'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaBadge({
    required String label,
    required Color bg,
    required Color fg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaLine(IconData icon, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
            fontSize: 12.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CourseFilterOption {
  final String id;
  final String label;

  const _CourseFilterOption({required this.id, required this.label});
}

class _AnnouncementStats {
  final int total;
  final int urgent;
  final int courses;
  final int thisWeek;

  const _AnnouncementStats({
    required this.total,
    required this.urgent,
    required this.courses,
    required this.thisWeek,
  });
}
