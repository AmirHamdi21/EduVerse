import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/announcement_model.dart';
import '../../../services/api/communication_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/instructor/announcements/announcement_barrel.dart';

class AnnouncementManagerScreen extends StatefulWidget {
  const AnnouncementManagerScreen({super.key});

  @override
  State<AnnouncementManagerScreen> createState() =>
      _AnnouncementManagerScreenState();
}

class _AnnouncementManagerScreenState extends State<AnnouncementManagerScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _fabAnimController;
  late AnimationController _listAnimController;
  late final CommunicationService _communicationService;
  late final EnrollmentService _enrollmentService;

  AnnouncementFilterType _selectedFilter = AnnouncementFilterType.all;
  List<AnnouncementItem> _announcements = [];
  List<Map<String, String>> _courseOptions = const [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    _fabAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _listAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final coreApiClient = CoreApiClient();
    _communicationService = CommunicationService(coreApiClient: coreApiClient);
    _enrollmentService = EnrollmentService(coreApiClient: coreApiClient);

    _loadCourseOptions();
    _loadAnnouncements();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _fabAnimController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadCourseOptions() async {
    final result = await _enrollmentService.getTeachingCourses();
    if (!mounted || !result.isSuccess) {
      return;
    }

    final options =
        result.data
            ?.map(
              (course) => {
                'id': course.courseId.toString(),
                'label': '${course.course.code} - ${course.course.name}',
              },
            )
            .toList() ??
        <Map<String, String>>[];

    if (!mounted) return;
    setState(() {
      _courseOptions = options;
    });
  }

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiList = await _communicationService.getAnnouncements();

      if (!mounted) return;

      setState(() {
        _announcements = apiList.map(AnnouncementItem.fromApi).toList();
        _isLoading = false;
      });

      _fabAnimController.forward();
      _listAnimController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  List<AnnouncementItem> get _filteredAnnouncements {
    var filtered = _announcements;

    // Apply status filter
    if (_selectedFilter != AnnouncementFilterType.all) {
      filtered = filtered.where((a) {
        switch (_selectedFilter) {
          case AnnouncementFilterType.published:
            return a.status == AnnouncementStatus.published;
          case AnnouncementFilterType.scheduled:
            return a.status == AnnouncementStatus.scheduled;
          case AnnouncementFilterType.draft:
            return a.status == AnnouncementStatus.draft;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search filter
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.content.toLowerCase().contains(query) ||
            a.audience.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Map<AnnouncementFilterType, int> get _filterCounts {
    return {
      AnnouncementFilterType.all: _announcements.length,
      AnnouncementFilterType.published: _announcements
          .where((a) => a.status == AnnouncementStatus.published)
          .length,
      AnnouncementFilterType.scheduled: _announcements
          .where((a) => a.status == AnnouncementStatus.scheduled)
          .length,
      AnnouncementFilterType.draft: _announcements
          .where((a) => a.status == AnnouncementStatus.draft)
          .length,
    };
  }

  void _showCreateDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnnouncementFormDialog(
        isDark: isDark,
        courseOptions: _courseOptions,
        onSave: (announcement) {
          Navigator.pop(context);
          _addOrUpdateAnnouncement(announcement, isDark);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showEditDialog(AnnouncementItem announcement, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnnouncementFormDialog(
        announcement: announcement,
        isDark: isDark,
        courseOptions: _courseOptions,
        onSave: (updated) {
          Navigator.pop(context);
          _addOrUpdateAnnouncement(updated, isDark);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showAnalyticsDialog(AnnouncementItem announcement, bool isDark) {
    final analytics = AnnouncementAnalytics(
      announcementId: announcement.id,
      announcementTitle: announcement.title,
      totalViews: announcement.readCount,
      readRate: announcement.readRate,
      viewsOverTime: List.generate(
        7,
        (i) => ViewDataPoint(
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          views: (announcement.readCount * (0.1 + i * 0.15)).toInt(),
        ),
      ),
      aiInsight:
          'Students are most active between 6-8 PM. Consider posting announcements during these times for maximum visibility.',
    );

    showDialog(
      context: context,
      builder: (context) => AnnouncementAnalyticsDialog(
        analytics: analytics,
        isDark: isDark,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showDeleteConfirmation(AnnouncementItem announcement, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AnnouncementColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AnnouncementColors.delete.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AnnouncementColors.delete,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Delete Announcement',
              style: TextStyle(
                color: AnnouncementColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${announcement.title}"? This action cannot be undone.',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(isDark),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AnnouncementColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAnnouncement(announcement.id, isDark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AnnouncementColors.delete,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrUpdateAnnouncement(
    AnnouncementItem announcement,
    bool isDark,
  ) async {
    try {
      if (_announcements.any((a) => a.id == announcement.id)) {
        await _communicationService.updateAnnouncement(announcement.id, {
          'title': announcement.title,
          'content': announcement.content,
          'priority': announcement.priority ?? 'medium',
        });

        if (announcement.status == AnnouncementStatus.published) {
          await _communicationService.publishAnnouncement(announcement.id);
        } else if (announcement.status == AnnouncementStatus.scheduled &&
            announcement.scheduledAt != null) {
          await _communicationService.scheduleAnnouncement(
            announcement.id,
            announcement.scheduledAt!,
          );
        }
      } else {
        final created = await _communicationService.createAnnouncement({
          'title': announcement.title,
          'content': announcement.content,
          'priority': announcement.priority ?? 'medium',
          if (announcement.courseId != null && announcement.courseId != '0')
            'courseId': int.tryParse(announcement.courseId!) ?? 0,
        });

        if (announcement.status == AnnouncementStatus.published) {
          await _communicationService.publishAnnouncement(created.id);
        } else if (announcement.status == AnnouncementStatus.scheduled &&
            announcement.scheduledAt != null) {
          await _communicationService.scheduleAnnouncement(
            created.id,
            announcement.scheduledAt!,
          );
        }
      }

      _showSuccessSnackbar('Announcement saved!', isDark);
      await _loadAnnouncements();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Future<void> _deleteAnnouncement(String id, bool isDark) async {
    try {
      await _communicationService.deleteAnnouncement(id);
      _showSuccessSnackbar('Announcement deleted successfully!', isDark);
      await _loadAnnouncements();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _publishAnnouncement(
    AnnouncementItem announcement,
    bool isDark,
  ) async {
    try {
      await _communicationService.publishAnnouncement(announcement.id);
      _showSuccessSnackbar('Announcement published successfully!', isDark);
      await _loadAnnouncements();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to publish: $e')));
      }
    }
  }

  Future<void> _pinAnnouncement(
    AnnouncementItem announcement,
    bool isDark,
  ) async {
    try {
      await _communicationService.pinAnnouncement(
        announcement.id,
        isPinned: !announcement.isPinned,
      );
      _showSuccessSnackbar(
        announcement.isPinned ? 'Unpinned' : 'Pinned',
        isDark,
      );
      await _loadAnnouncements();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pin: $e')));
      }
    }
  }

  void _showSuccessSnackbar(String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AnnouncementColors.published,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AnnouncementColors.background(isDark),
            body: SafeArea(
              child: Container(
                decoration: isDark
                    ? null
                    : BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFEEF5FE),
                            Colors.white,
                            const Color(0xFFFAF5FE),
                          ],
                        ),
                      ),
                child: Column(
                  children: [
                    _buildAppBar(isDark, l10n),
                    _buildSearchBar(isDark, l10n),
                    const SizedBox(height: 16),
                    _buildFilterChips(isDark),
                    const SizedBox(height: 8),
                    Expanded(child: _buildContent(isDark, l10n)),
                  ],
                ),
              ),
            ),
            floatingActionButton: _buildFAB(isDark, l10n),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AnnouncementColors.textPrimaryColor(isDark),
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AnnouncementColors.darkCard
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.announcementsManager,
                  style: TextStyle(
                    color: AnnouncementColors.textPrimaryColor(isDark),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.announcementsManagerSubtitle,
                  style: TextStyle(
                    color: AnnouncementColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isDark) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AnnouncementColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  // Handle language toggle
                },
                icon: Icon(
                  Icons.translate_rounded,
                  color: AnnouncementColors.textSecondaryColor(isDark),
                  size: 20,
                ),
                tooltip: 'Change Language',
              ),
              Container(
                width: 1,
                height: 24,
                color: AnnouncementColors.borderColor(isDark),
              ),
              IconButton(
                onPressed: () => context.push('/settings/appearance'),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AnnouncementColors.textSecondaryColor(isDark),
                  size: 20,
                ),
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return AnnouncementSearchBar(
      controller: _searchController,
      isDark: isDark,
      hintText: l10n.searchAnnouncements,
      onClear: () => setState(() {}),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return AnnouncementFilterChips(
      selectedFilter: _selectedFilter,
      onFilterChanged: (filter) {
        setState(() => _selectedFilter = filter);
        HapticFeedback.selectionClick();
      },
      isDark: isDark,
      counts: _filterCounts,
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return AnnouncementLoadingSkeleton(isDark: isDark);
    }

    if (_hasError) {
      return AnnouncementErrorState(
        isDark: isDark,
        message: _errorMessage,
        onRetry: _loadAnnouncements,
      );
    }

    final filtered = _filteredAnnouncements;

    if (filtered.isEmpty) {
      return AnnouncementEmptyState(
        isDark: isDark,
        title: _searchController.text.isNotEmpty
            ? l10n.noAnnouncementsFoundSearch
            : l10n.noAnnouncementsYet,
        subtitle: _searchController.text.isNotEmpty
            ? l10n.tryDifferentSearch
            : l10n.createFirstAnnouncement,
        onCreateNew: () => _showCreateDialog(isDark),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      color: AnnouncementColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final announcement = filtered[index];
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _listAnimController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index + 1) * 0.2).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _listAnimController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index + 1) * 0.2).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              child: AnnouncementCard(
                announcement: announcement,
                isDark: isDark,
                onEdit: () => _showEditDialog(announcement, isDark),
                onDelete: () => _showDeleteConfirmation(announcement, isDark),
                onAnalytics: announcement.status == AnnouncementStatus.published
                    ? () => _showAnalyticsDialog(announcement, isDark)
                    : null,
                onPublish: () => _publishAnnouncement(announcement, isDark),
                onPin: () => _pinAnnouncement(announcement, isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimController,
        curve: Curves.easeOutBack,
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(isDark),
        backgroundColor: AnnouncementColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.newAnnouncement,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
