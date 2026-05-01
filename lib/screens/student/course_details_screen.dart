import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../bloc/courses/courses_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../common/utils/course_ui_utils.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/assignments/assignment_model.dart' as api_assignment;
import '../../models/core/enrollment_model.dart';
import '../../models/core/course_structure_model.dart';
import '../../models/courses/instructor_assignment_model.dart';
import '../../models/labs/lab_model.dart' as api_lab;
import '../../models/materials/announcement_model.dart';
import '../../models/materials/course_material_model.dart';
import '../../models/ta/ta_assignment_model.dart';
import '../../widgets/student/course_details/announcements_tab_content.dart';
import '../../widgets/student/course_details/assignments_tab_content.dart';
import '../../widgets/student/course_details/course_tab_content.dart';
import '../../widgets/student/course_details/discussion_tab_content.dart';
import '../../widgets/student/course_details/labs_tab_content.dart';
import '../../widgets/student/course_details/prerequisites_tab_content.dart';
import '../../widgets/student/course_details/video_player_widget.dart';
import '../../widgets/student/courses/course_model.dart';

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

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  static const int _searchTabIndex = 0;
  static const int _contentTabIndex = 1;
  static const int _overviewTabIndex = 2;
  static const int _announcementsTabIndex = 4;
  static const int _discussionTabIndex = 5;
  static const int _assignmentsTabIndex = 6;
  static const int _labsTabIndex = 7;
  static const int _prerequisitesTabIndex = 8;

  late final CourseDetailBloc _courseDetailBloc;
  final ScrollController _scrollController = ScrollController();
  String? _selectedHeroMaterialId;

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

  int get _initialTabIndex => _mapLegacyInitialTab(widget.initialTab);

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
          initialTabIndex: _initialTabIndex,
        ),
      );
    } else {
      _courseDetailBloc.add(SwitchTab(tabIndex: _initialTabIndex));

      if (sectionId != null && sectionId > 0) {
        _courseDetailBloc.add(LoadSectionStaff(sectionId: sectionId));
      }
    }

    _courseDetailBloc.add(const LoadMyAppointments());
  }

  @override
  void dispose() {
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
                  final l10n = AppLocalizations.of(context);
                  final selectedTabIndex = _normalizeTabIndex(
                    detailState.selectedTabIndex,
                  );
                  final tabs = _buildTabs(l10n);

                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildTopChrome(
                          context,
                          isDark,
                          detailState,
                          l10n,
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _CourseDetailTabsHeaderDelegate(
                          height: 78,
                          child: Container(
                            color: bgColor,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                            child: _CourseDetailTabStrip(
                              tabs: tabs,
                              selectedIndex: selectedTabIndex,
                              isDark: isDark,
                              onTap: (index) {
                                context.read<CourseDetailBloc>().add(
                                  SwitchTab(tabIndex: index),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                          child: _buildSelectedTabContent(
                            context,
                            selectedTabIndex,
                            isDark,
                            detailState,
                            l10n,
                          ),
                        ),
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

  int _mapLegacyInitialTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _contentTabIndex;
      case 1:
        return _labsTabIndex;
      case 2:
        return _assignmentsTabIndex;
      case 3:
        return _announcementsTabIndex;
      case 4:
        return _prerequisitesTabIndex;
      case 5:
        return _overviewTabIndex;
      case 6:
        return _discussionTabIndex;
      default:
        return _overviewTabIndex;
    }
  }

  int _normalizeTabIndex(int rawIndex) {
    if (rawIndex < _searchTabIndex || rawIndex > _prerequisitesTabIndex) {
      return _overviewTabIndex;
    }
    return rawIndex;
  }

  List<_CourseDetailTabSpec> _buildTabs(AppLocalizations l10n) {
    return <_CourseDetailTabSpec>[
      _CourseDetailTabSpec(
        icon: Icons.search_rounded,
        label: l10n.search,
        compact: true,
      ),
      _CourseDetailTabSpec(
        icon: Icons.video_library_outlined,
        label: l10n.studentCourseDetailCourseContent,
      ),
      _CourseDetailTabSpec(icon: Icons.grid_view_rounded, label: l10n.overview),
      _CourseDetailTabSpec(icon: Icons.note_alt_outlined, label: l10n.notes),
      _CourseDetailTabSpec(
        icon: Icons.campaign_outlined,
        label: l10n.announcements,
      ),
      _CourseDetailTabSpec(icon: Icons.forum_outlined, label: l10n.discussions),
      _CourseDetailTabSpec(
        icon: Icons.assignment_outlined,
        label: l10n.assignments,
      ),
      _CourseDetailTabSpec(icon: Icons.science_outlined, label: l10n.labs),
      _CourseDetailTabSpec(
        icon: Icons.rule_folder_outlined,
        label: l10n.studentCourseDetailPrerequisites,
      ),
    ];
  }

  void _switchTab(BuildContext context, int tabIndex) {
    context.read<CourseDetailBloc>().add(SwitchTab(tabIndex: tabIndex));
  }

  Widget _buildSelectedTabContent(
    BuildContext context,
    int selectedTabIndex,
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
  ) {
    switch (selectedTabIndex) {
      case _searchTabIndex:
        return _CourseDetailSearchTab(
          isDark: isDark,
          materials: detailState.materials,
          assignments: detailState.assignments,
          labs: detailState.labs,
          announcements: detailState.announcements,
          onOpenContent: () => _switchTab(context, _contentTabIndex),
          onOpenAssignments: () => _switchTab(context, _assignmentsTabIndex),
          onOpenLabs: () => _switchTab(context, _labsTabIndex),
          onOpenAnnouncements: () =>
              _switchTab(context, _announcementsTabIndex),
          l10n: l10n,
        );
      case _contentTabIndex:
        return CourseTabContent(
          selectedIndex: 0,
          isDark: isDark,
          course: _buildLegacyCourseForTabs(),
          onInterceptMaterialTap: _handleInlineMaterialTap,
        );
      case _overviewTabIndex:
        return _buildOverviewTab(context, isDark, detailState, l10n);
      case 3:
        return _CourseDetailNotesTab(isDark: isDark, l10n: l10n);
      case _announcementsTabIndex:
        return AnnouncementsTabContent(
          isDark: isDark,
          courseId: _resolvedCourseId,
        );
      case _discussionTabIndex:
        return DiscussionTabContent(
          isDark: isDark,
          courseId: _resolvedCourseId,
        );
      case _assignmentsTabIndex:
        return AssignmentsTabContent(
          isDark: isDark,
          courseId: _resolvedCourseId,
        );
      case _labsTabIndex:
        return LabsTabContent(
          isDark: isDark,
          courseId: _resolvedCourseId,
        );
      case _prerequisitesTabIndex:
        return PrerequisitesTabContent(isDark: isDark);
      default:
        return _buildOverviewTab(context, isDark, detailState, l10n);
    }
  }

  Widget _buildTopChrome(
    BuildContext context,
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
  ) {
    final heroVideo = _resolveHeroVideo(detailState);
    final themeButtonColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              children: [
                _buildTopIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  isDark: isDark,
                  backgroundColor: themeButtonColor,
                  onTap: _handleBackPressed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF101828),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: themeButtonColor,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFD8E1EF),
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (heroVideo != null)
            _buildVideoHero(context, isDark, detailState, l10n, heroVideo)
          else
            _buildFallbackHero(context, isDark, detailState, l10n),
        ],
      ),
    );
  }

  Widget _buildTopIconButton({
    required IconData icon,
    required bool isDark,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }

  List<CourseMaterialModel> _videoMaterials(CourseDetailState detailState) {
    return _orderedCourseMaterials(
      detailState,
    ).where(_isVideoMaterial).toList(growable: false);
  }

  List<CourseMaterialModel> _orderedCourseMaterials(
    CourseDetailState detailState,
  ) {
    final ordered = <CourseMaterialModel>[];
    final seenIds = <String>{};
    final materialMap = <String, CourseMaterialModel>{
      for (final material in detailState.materials)
        material.materialId: material,
    };

    if (detailState.structure.isNotEmpty) {
      final sortedStructure = [...detailState.structure]
        ..sort((a, b) {
          final weekCompare = a.weekNumber.compareTo(b.weekNumber);
          if (weekCompare != 0) {
            return weekCompare;
          }
          return a.orderIndex.compareTo(b.orderIndex);
        });

      for (final item in sortedStructure) {
        final material = _materialFromStructure(item, materialMap);
        if (seenIds.add(material.materialId)) {
          ordered.add(material);
        }
      }
    }

    final remainingMaterials = [...detailState.materials]..sort(_sortMaterials);
    for (final material in remainingMaterials) {
      if (seenIds.add(material.materialId)) {
        ordered.add(material);
      }
    }

    return ordered;
  }

  CourseMaterialModel _materialFromStructure(
    CourseStructureModel item,
    Map<String, CourseMaterialModel> materialMap,
  ) {
    if (item.material != null) {
      return item.material!;
    }

    final mapped = item.materialId == null
        ? null
        : materialMap[item.materialId!];
    if (mapped != null) {
      return mapped;
    }

    return CourseMaterialModel(
      materialId: item.materialId ?? 'structure-${item.organizationId}',
      courseId: item.courseId,
      materialType: item.organizationType,
      title: item.title,
      description: item.description,
      orderIndex: item.orderIndex,
      weekNumber: item.weekNumber,
      viewCount: 0,
      downloadCount: 0,
      uploadedBy: null,
      isPublished: true,
      hasBeenViewed: false,
      createdAt: item.createdAt ?? DateTime.now(),
      updatedAt: item.updatedAt,
    );
  }

  int _sortMaterials(CourseMaterialModel a, CourseMaterialModel b) {
    final weekCompare = (a.weekNumber ?? 0).compareTo(b.weekNumber ?? 0);
    if (weekCompare != 0) {
      return weekCompare;
    }

    final orderCompare = (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
    if (orderCompare != 0) {
      return orderCompare;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  CourseMaterialModel? _resolveHeroVideo(CourseDetailState detailState) {
    final videos = _videoMaterials(detailState);
    if (videos.isEmpty) {
      return null;
    }

    if (_selectedHeroMaterialId != null) {
      for (final material in videos) {
        if (material.materialId == _selectedHeroMaterialId) {
          return material;
        }
      }
    }

    return videos.first;
  }

  bool _isVideoMaterial(CourseMaterialModel material) {
    final type = material.materialType.trim().toLowerCase();
    final hasPlayableSource =
        (material.youtubeVideoId?.trim().isNotEmpty ?? false) ||
        (material.externalUrl?.trim().isNotEmpty ?? false) ||
        (material.url?.trim().isNotEmpty ?? false);
    return (type == 'video' || type == 'lecture') && hasPlayableSource;
  }

  bool _handleInlineMaterialTap(CourseMaterialModel material) {
    if (!_isVideoMaterial(material)) {
      return false;
    }

    setState(() => _selectedHeroMaterialId = material.materialId);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    return true;
  }

  void _playNextVideo(CourseDetailState detailState) {
    final videos = _videoMaterials(detailState);
    if (videos.isEmpty) {
      return;
    }

    final current = _resolveHeroVideo(detailState);
    final currentIndex = current == null
        ? -1
        : videos.indexWhere((item) => item.materialId == current.materialId);

    final nextIndex = currentIndex >= 0 && currentIndex < videos.length - 1
        ? currentIndex + 1
        : 0;
    setState(() => _selectedHeroMaterialId = videos[nextIndex].materialId);
  }

  Widget _buildVideoHero(
    BuildContext context,
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
    CourseMaterialModel heroVideo,
  ) {
    final weekLabel = heroVideo.weekNumber != null && heroVideo.weekNumber! > 0
        ? '${l10n.week} ${heroVideo.weekNumber}'
        : _courseCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                VideoPlayerWidget(
                  courseId: _resolvedCourseId,
                  material: heroVideo,
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: _buildVideoHeroSquareButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: () => _playNextVideo(detailState),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heroVideo.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (weekLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  weekLabel,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF667085),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoHeroSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF6D28D9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildFallbackHero(
    BuildContext context,
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
  ) {
    final progress = _resolveProgressFromEnrollment(detailState);
    final materials = _orderedCourseMaterials(detailState);
    final mediaCount = materials.isNotEmpty
        ? materials.length
        : (widget.enrollment?.totalMaterials ?? 0);
    final heroDescription =
        (_description != null && _description!.trim().isNotEmpty)
        ? _description!.trim()
        : l10n.studentCourseDetailHeroFallback;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF172554), Color(0xFF0F172A)]
              : _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _gradientColors.last.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_courseCode.isNotEmpty)
                  _buildHeroChip(label: _courseCode, icon: Icons.sell_outlined),
                _buildHeroChip(
                  label: _localizedStatusLabel(l10n),
                  icon: Icons.check_circle_outline_rounded,
                ),
                _buildHeroChip(
                  label: '$mediaCount ${l10n.studentCourseDetailItemsLabel}',
                  icon: Icons.video_collection_outlined,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        heroDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _courseInitials(_title),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final useVerticalAction = constraints.maxWidth < 430;
                final progressBar = _HeroProgressBar(
                  progress: progress,
                  progressLabel:
                      '${(progress * 100).round()}% ${l10n.complete}',
                );
                final actionButton = _buildHeroActionButton(
                  label: l10n.continueButton,
                  icon: Icons.play_arrow_rounded,
                  onTap: () => _switchTab(context, _contentTabIndex),
                );

                if (useVerticalAction) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      progressBar,
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: actionButton),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: progressBar),
                    const SizedBox(width: 12),
                    actionButton,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: _gradientColors.last),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: _gradientColors.last,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
  ) {
    final summaryCards = <_OverviewMetric>[
      _OverviewMetric(
        label: l10n.studentCourseDetailItemsLabel,
        value:
            ((widget.enrollment?.totalMaterials ?? 0) > 0
                    ? widget.enrollment!.totalMaterials!
                    : _orderedCourseMaterials(detailState).length)
                .toString(),
        icon: Icons.video_library_outlined,
      ),
      _OverviewMetric(
        label: l10n.assignments,
        value: detailState.assignments.length.toString(),
        icon: Icons.assignment_outlined,
      ),
      _OverviewMetric(
        label: l10n.labs,
        value: detailState.labs.length.toString(),
        icon: Icons.science_outlined,
      ),
      _OverviewMetric(
        label: l10n.announcements,
        value: detailState.announcements.length.toString(),
        icon: Icons.campaign_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverviewSummaryCard(isDark, detailState, l10n),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 880
                ? 4
                : constraints.maxWidth >= 560
                ? 2
                : 2;
            final childAspectRatio = constraints.maxWidth >= 560 ? 2.25 : 2.1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summaryCards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                return _buildOverviewMetricCard(summaryCards[index], isDark);
              },
            );
          },
        ),
        const SizedBox(height: 18),
        _buildProgressSection(isDark, detailState, l10n),
        const SizedBox(height: 18),
        _buildInstructorCard(context, isDark, detailState),
        if ((widget.enrollment?.sectionId ?? 0) > 0 ||
            detailState.teachingAssistants.isNotEmpty) ...[
          const SizedBox(height: 18),
          _buildTeachingAssistantsSection(context, isDark, detailState),
        ],
      ],
    );
  }

  Widget _buildOverviewSummaryCard(
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
  ) {
    final infoChips = <_OverviewInfoChip>[
      if (_courseCode.isNotEmpty)
        _OverviewInfoChip(icon: Icons.sell_outlined, label: _courseCode),
      _OverviewInfoChip(
        icon: Icons.credit_card_outlined,
        label: '$_credits ${l10n.credits}',
      ),
      _OverviewInfoChip(
        icon: Icons.layers_outlined,
        label: _localizedLevelLabel(l10n),
      ),
      if (widget.enrollment?.semester?.name.trim().isNotEmpty == true)
        _OverviewInfoChip(
          icon: Icons.calendar_month_outlined,
          label: widget.enrollment!.semester!.name.trim(),
        ),
      _OverviewInfoChip(
        icon: Icons.event_available_outlined,
        label:
            '${l10n.studentCourseDetailEnrolledOn} ${_formatShortDate(widget.enrollment?.enrollmentDate)}',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121C35) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.studentCourseDetailOverviewHeading,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (_description != null && _description!.trim().isNotEmpty)
                ? _description!.trim()
                : l10n.studentCourseDetailOverviewFallback,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 360
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: infoChips.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: columns == 1 ? 64 : 72,
                ),
                itemBuilder: (context, index) {
                  final chip = infoChips[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF6F8FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          chip.icon,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF8EC5FF)
                              : const Color(0xFF155DFC),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chip.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetricCard(_OverviewMetric metric, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE4F2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _gradientColors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101828),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF667085),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedStatusLabel(AppLocalizations l10n) {
    switch (widget.enrollment?.status.toLowerCase() ?? 'active') {
      case 'completed':
        return l10n.completed;
      case 'dropped':
        return l10n.studentCourseDetailDropped;
      case 'active':
      case 'enrolled':
        return l10n.active;
      case 'waitlisted':
        return l10n.studentCourseDetailWaitlisted;
      default:
        return _toTitleCase(widget.enrollment?.status ?? 'active');
    }
  }

  String _localizedLevelLabel(AppLocalizations l10n) {
    switch ((widget.enrollment?.course?.level ?? '').trim().toLowerCase()) {
      case 'beginner':
        return l10n.studentCourseDetailBeginner;
      case 'intermediate':
        return l10n.studentCourseDetailIntermediate;
      case 'advanced':
        return l10n.advanced;
      default:
        if ((widget.enrollment?.course?.level ?? '').trim().isNotEmpty) {
          return _toTitleCase(widget.enrollment!.course!.level!);
        }
        return l10n.noData;
    }
  }

  String _toTitleCase(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return value;
    }

    return normalized
        .split(RegExp(r'[\s_-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _courseInitials(String title) {
    final parts = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList(growable: false);

    if (parts.isEmpty) {
      return 'CR';
    }

    return parts.map((part) => part.substring(0, 1)).join().toUpperCase();
  }

  String _formatShortDate(DateTime? date) {
    if (date == null) {
      return '--';
    }

    return DateFormat(
      'MMM d, yyyy',
      Localizations.localeOf(context).languageCode,
    ).format(date.toLocal());
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
    final l10n = AppLocalizations.of(blocContext);
    final instructorLabel = _resolveInstructorLabel(detailState);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121C35) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(colors: _gradientColors),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.studentCourseDetailInstructorTitle,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () =>
                          _openInstructorInfo(blocContext, detailState),
                      child: Text(
                        instructorLabel,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF101828),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.studentCourseDetailInstructorSubtitle,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildSupportActionButton(
              label: l10n.studentCourseDetailOpenProfileBooking,
              onTap: () => _openInstructorInfo(blocContext, detailState),
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
          ? AppLocalizations.of(context).studentCourseDetailLoadingInstructor
          : AppLocalizations.of(context).studentCourseDetailUnknownInstructor;
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
    final l10n = AppLocalizations.of(context);
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
            SnackBar(
              content: Text(l10n.studentCourseDetailInstructorLoadingMessage),
            ),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.studentCourseDetailNoInstructorAssigned),
            ),
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
    final l10n = AppLocalizations.of(context);
    final assistants = detailState.teachingAssistants;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121C35) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.studentCourseDetailTeachingAssistantsTitle,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.studentCourseDetailTeachingAssistantsSubtitle,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          if (detailState.isLoadingStaff && assistants.isEmpty)
            Text(
              l10n.studentCourseDetailLoadingTeachingAssistants,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF667085),
                fontSize: 14,
              ),
            )
          else if (assistants.isEmpty)
            Text(
              l10n.studentCourseDetailNoTeachingAssistants,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF667085),
                fontSize: 14,
              ),
            )
          else
            ...List<Widget>.generate(assistants.length, (index) {
              final assistant = assistants[index];
              final assistantName = _resolveTeachingAssistantLabel(assistant);

              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(colors: _gradientColors),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openTeachingAssistantInfo(
                                context,
                                assistant,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assistantName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF101828),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.studentCourseDetailTeachingAssistantRole,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : const Color(0xFF667085),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.studentCourseDetailTeachingAssistantsSubtitle,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475467),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: _buildSupportActionButton(
                          label: l10n.studentCourseDetailOpenProfileBooking,
                          onTap: () =>
                              _openTeachingAssistantInfo(context, assistant),
                        ),
                      ),
                    ],
                  ),
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
    final l10n = AppLocalizations.of(context);
    if (assistant.userId <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.studentCourseDetailNoTaProfile)),
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

  Widget _buildSupportActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _gradientColors.last.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildProgressSection(
    bool isDark,
    CourseDetailState detailState,
    AppLocalizations l10n,
  ) {
    final progress = _resolveProgressFromEnrollment(detailState);
    final materialsViewed = widget.enrollment?.materialsViewed ?? 0;
    final totalMaterials = (widget.enrollment?.totalMaterials ?? 0) > 0
        ? widget.enrollment!.totalMaterials!
        : detailState.materials.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121C35) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.studentCourseDetailProgressTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                  _localizedStatusLabel(l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.studentCourseDetailProgressSubtitle,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF667085),
              fontSize: 14,
              height: 1.5,
            ),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(progress * 100).round()}% ${l10n.complete}',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101828),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$materialsViewed/$totalMaterials ${l10n.studentCourseDetailItemsCompleted}',
                style: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF667085),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.enrollment != null
                ? '${l10n.studentCourseDetailEnrolledOn} ${_formatShortDate(widget.enrollment!.enrollmentDate)}'
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

class _CourseDetailTabSpec {
  const _CourseDetailTabSpec({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;
}

class _CourseDetailTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _CourseDetailTabsHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _CourseDetailTabsHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _CourseDetailTabStrip extends StatelessWidget {
  const _CourseDetailTabStrip({
    required this.tabs,
    required this.selectedIndex,
    required this.isDark,
    required this.onTap,
  });

  final List<_CourseDetailTabSpec> tabs;
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: tabs.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final tab = tabs[index];
        final isSelected = index == selectedIndex;

        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(
              horizontal: tab.compact ? 16 : 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? const Color(0xFF121C35) : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFD8E1EF)),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF155DFC).withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475467)),
                ),
                if (!tab.compact) ...[
                  const SizedBox(width: 8),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF101828)),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroProgressBar extends StatelessWidget {
  const _HeroProgressBar({required this.progress, required this.progressLabel});

  final double progress;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progressLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _OverviewInfoChip {
  const _OverviewInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _CourseDetailSearchTab extends StatefulWidget {
  const _CourseDetailSearchTab({
    required this.isDark,
    required this.materials,
    required this.assignments,
    required this.labs,
    required this.announcements,
    required this.onOpenContent,
    required this.onOpenAssignments,
    required this.onOpenLabs,
    required this.onOpenAnnouncements,
    required this.l10n,
  });

  final bool isDark;
  final List<CourseMaterialModel> materials;
  final List<api_assignment.AssignmentModel> assignments;
  final List<api_lab.LabModel> labs;
  final List<AnnouncementModel> announcements;
  final VoidCallback onOpenContent;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenLabs;
  final VoidCallback onOpenAnnouncements;
  final AppLocalizations l10n;

  @override
  State<_CourseDetailSearchTab> createState() => _CourseDetailSearchTabState();
}

class _CourseDetailSearchTabState extends State<_CourseDetailSearchTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final hasQuery = query.isNotEmpty;

    final results = <_SearchResultEntry>[
      ...widget.materials
          .where((item) => _matches(query, item.title, item.description))
          .map(
            (item) => _SearchResultEntry(
              title: item.title,
              subtitle: widget.l10n.studentCourseDetailSearchMaterialsLabel,
              icon: Icons.video_library_outlined,
              onTap: widget.onOpenContent,
            ),
          ),
      ...widget.assignments
          .where((item) => _matches(query, item.title, item.description))
          .map(
            (item) => _SearchResultEntry(
              title: item.title,
              subtitle: widget.l10n.assignments,
              icon: Icons.assignment_outlined,
              onTap: widget.onOpenAssignments,
            ),
          ),
      ...widget.labs
          .where((item) => _matches(query, item.title, item.description))
          .map(
            (item) => _SearchResultEntry(
              title: item.title,
              subtitle: widget.l10n.labs,
              icon: Icons.science_outlined,
              onTap: widget.onOpenLabs,
            ),
          ),
      ...widget.announcements
          .where((item) => _matches(query, item.title, item.content))
          .map(
            (item) => _SearchResultEntry(
              title: item.title,
              subtitle: widget.l10n.announcements,
              icon: Icons.campaign_outlined,
              onTap: widget.onOpenAnnouncements,
            ),
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF121C35) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFD8E1EF),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.l10n.studentCourseDetailSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: hasQuery
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (!hasQuery)
          _SearchEmptyState(
            isDark: widget.isDark,
            title: widget.l10n.studentCourseDetailSearchPromptTitle,
            subtitle: widget.l10n.studentCourseDetailSearchPromptSubtitle,
          )
        else if (results.isEmpty)
          _SearchEmptyState(
            isDark: widget.isDark,
            title: widget.l10n.studentCourseDetailSearchNoResultsTitle,
            subtitle: widget.l10n.studentCourseDetailSearchNoResultsSubtitle,
          )
        else
          ...List<Widget>.generate(
            results.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == results.length - 1 ? 0 : 12,
              ),
              child: _SearchResultCard(
                isDark: widget.isDark,
                entry: results[index],
              ),
            ),
          ),
      ],
    );
  }

  bool _matches(String query, String primary, String? secondary) {
    if (query.isEmpty) {
      return false;
    }

    return primary.toLowerCase().contains(query) ||
        (secondary?.toLowerCase().contains(query) ?? false);
  }
}

class _SearchResultEntry {
  const _SearchResultEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.isDark, required this.entry});

  final bool isDark;
  final _SearchResultEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121C35) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFD8E1EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF155DFC).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(entry.icon, color: const Color(0xFF155DFC)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF667085),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.isDark,
    required this.title,
    required this.subtitle,
  });

  final bool isDark;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121C35) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF155DFC).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Color(0xFF155DFC),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF667085),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseDetailNotesTab extends StatefulWidget {
  const _CourseDetailNotesTab({required this.isDark, required this.l10n});

  final bool isDark;
  final AppLocalizations l10n;

  @override
  State<_CourseDetailNotesTab> createState() => _CourseDetailNotesTabState();
}

class _CourseDetailNotesTabState extends State<_CourseDetailNotesTab> {
  final TextEditingController _noteController = TextEditingController();
  final List<_SessionNote> _notes = <_SessionNote>[];
  _NoteSortOrder _sortOrder = _NoteSortOrder.recent;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = List<_SessionNote>.from(_notes)
      ..sort((a, b) {
        if (_sortOrder == _NoteSortOrder.recent) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return a.createdAt.compareTo(b.createdAt);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF121C35) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFD8E1EF),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.l10n.studentCourseDetailNotesHint,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _addNote,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF155DFC),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _NotesMenuButton(
                label: widget.l10n.studentCourseDetailNotesAllItems,
                icon: Icons.filter_list_rounded,
                items: <PopupMenuEntry<void>>[
                  PopupMenuItem<void>(
                    enabled: false,
                    child: Text(
                      widget.l10n.studentCourseDetailNotesSessionOnly,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NotesMenuButton(
                label: _sortOrder == _NoteSortOrder.recent
                    ? widget.l10n.studentCourseDetailNotesSortRecent
                    : widget.l10n.studentCourseDetailNotesSortOldest,
                icon: Icons.swap_vert_rounded,
                items: [
                  PopupMenuItem<_NoteSortOrder>(
                    value: _NoteSortOrder.recent,
                    child: Text(widget.l10n.studentCourseDetailNotesSortRecent),
                  ),
                  PopupMenuItem<_NoteSortOrder>(
                    value: _NoteSortOrder.oldest,
                    child: Text(widget.l10n.studentCourseDetailNotesSortOldest),
                  ),
                ],
                onSelected: (value) {
                  if (value is _NoteSortOrder) {
                    setState(() => _sortOrder = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (notes.isEmpty)
          _SearchEmptyState(
            isDark: widget.isDark,
            title: widget.l10n.studentCourseDetailNotesEmptyTitle,
            subtitle: widget.l10n.studentCourseDetailNotesEmptySubtitle,
          )
        else
          ...List<Widget>.generate(
            notes.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == notes.length - 1 ? 0 : 12,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF121C35) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFD8E1EF),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notes[index].text,
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF101828),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat(
                        'MMM d, h:mm a',
                      ).format(notes[index].createdAt),
                      style: TextStyle(
                        color: widget.isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _addNote() {
    final value = _noteController.text.trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _notes.add(_SessionNote(text: value, createdAt: DateTime.now()));
      _noteController.clear();
    });
  }
}

enum _NoteSortOrder { recent, oldest }

class _SessionNote {
  const _SessionNote({required this.text, required this.createdAt});

  final String text;
  final DateTime createdAt;
}

class _NotesMenuButton extends StatelessWidget {
  const _NotesMenuButton({
    required this.label,
    required this.icon,
    required this.items,
    this.onSelected,
  });

  final String label;
  final IconData icon;
  final List<PopupMenuEntry<dynamic>> items;
  final PopupMenuItemSelected<dynamic>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121C35)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E1EF)),
      ),
      child: PopupMenuButton<dynamic>(
        onSelected: onSelected,
        itemBuilder: (_) => items,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF155DFC)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF667085),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
