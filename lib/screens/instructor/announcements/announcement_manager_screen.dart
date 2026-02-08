import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/announcement_model.dart';
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

  AnnouncementFilterType _selectedFilter = AnnouncementFilterType.all;
  List<AnnouncementItem> _announcements = [];
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

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _announcements = _getMockAnnouncements();
        _isLoading = false;
      });

      _fabAnimController.forward();
      _listAnimController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load announcements. Please try again.';
      });
    }
  }

  List<AnnouncementItem> _getMockAnnouncements() {
    return [
      AnnouncementItem(
        id: '1',
        title: 'Midterm Exam Details - Important',
        content:
            'The midterm exam will be held on November 28th, 2025 at 10:00 AM in Hall A. Please bring your student ID and arrive 15 minutes early.',
        status: AnnouncementStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        audience: 'All Students',
        totalAudience: 120,
        readCount: 94,
        attachments: ['exam_guidelines.pdf', 'seating_arrangement.pdf'],
      ),
      AnnouncementItem(
        id: '2',
        title: 'Office Hours Update',
        content:
            "This week's office hours will be moved from Wednesday to Thursday, 2-4 PM. Please plan accordingly.",
        status: AnnouncementStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        audience: 'All Students',
        totalAudience: 120,
        readCount: 87,
      ),
      AnnouncementItem(
        id: '3',
        title: 'Assignment 4 Extension',
        content:
            'Due to technical issues with the lab servers, Assignment 4 deadline has been extended by 3 days. New deadline: December 5th.',
        status: AnnouncementStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledAt: DateTime.now().add(const Duration(hours: 8)),
        audience: 'All Students',
        totalAudience: 120,
        readCount: 0,
      ),
      AnnouncementItem(
        id: '4',
        title: 'Guest Lecture - Cloud Computing',
        content:
            "We're excited to host Dr. Sarah Chen from AWS next week. She'll discuss cloud architecture best practices.",
        status: AnnouncementStatus.draft,
        createdAt: DateTime.now(),
        audience: 'All Students',
        totalAudience: 120,
        readCount: 0,
      ),
      AnnouncementItem(
        id: '5',
        title: 'Lab Session Rescheduled',
        content:
            'The Friday lab session has been moved to Saturday due to campus maintenance.',
        status: AnnouncementStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        audience: 'CS101 Students',
        totalAudience: 45,
        readCount: 0,
      ),
    ];
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
        onSave: (announcement) {
          Navigator.pop(context);
          _addOrUpdateAnnouncement(announcement);
          _showSuccessSnackbar('Announcement created successfully!', isDark);
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
        onSave: (updated) {
          Navigator.pop(context);
          _addOrUpdateAnnouncement(updated);
          _showSuccessSnackbar('Announcement updated successfully!', isDark);
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
              _deleteAnnouncement(announcement.id);
              _showSuccessSnackbar(
                'Announcement deleted successfully!',
                isDark,
              );
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

  void _addOrUpdateAnnouncement(AnnouncementItem announcement) {
    setState(() {
      final index = _announcements.indexWhere((a) => a.id == announcement.id);
      if (index >= 0) {
        _announcements[index] = announcement;
      } else {
        _announcements.insert(0, announcement);
      }
    });
  }

  void _deleteAnnouncement(String id) {
    setState(() {
      _announcements.removeWhere((a) => a.id == id);
    });
  }

  void _publishAnnouncement(AnnouncementItem announcement, bool isDark) {
    final updated = announcement.copyWith(
      status: AnnouncementStatus.published,
      publishedAt: DateTime.now(),
    );
    _addOrUpdateAnnouncement(updated);
    _showSuccessSnackbar('Announcement published successfully!', isDark);
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
