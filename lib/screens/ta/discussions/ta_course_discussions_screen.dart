import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/discussion/discussion_models.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:edu_verse/screens/ta/discussions/ta_discussion_ui.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/discussion_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';

class TACourseDiscussionsScreen extends StatefulWidget {
  const TACourseDiscussionsScreen({
    super.key,
    required this.courseId,
    this.initialCourse,
    this.discussionService,
    this.enrollmentService,
    this.embedded = false,
  });

  final int courseId;
  final TeachingCourseModel? initialCourse;
  final DiscussionService? discussionService;
  final EnrollmentService? enrollmentService;
  final bool embedded;

  @override
  State<TACourseDiscussionsScreen> createState() =>
      _TACourseDiscussionsScreenState();
}

enum _PostFilter { all, open, pinned, locked, unanswered }

enum _PostSort { latest, mostReplies, mostViews, title }

class _TACourseDiscussionsScreenState
    extends State<TACourseDiscussionsScreen> {
  late final DiscussionService _discussionService;
  late final EnrollmentService _enrollmentService;

  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;
  TeachingCourseModel? _course;
  List<DiscussionThread> _threads = const <DiscussionThread>[];
  _PostFilter _selectedFilter = _PostFilter.all;
  _PostSort _selectedSort = _PostSort.latest;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final storage = StorageService();
    final client = CoreApiClient(storageService: storage);
    _discussionService =
        widget.discussionService ?? DiscussionService(coreApiClient: client);
    _enrollmentService =
        widget.enrollmentService ?? EnrollmentService(coreApiClient: client);
    _course = widget.initialCourse;
    _loadData();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    } else {
      setState(() => _errorMessage = null);
    }

    try {
      if (_course == null) {
        final coursesResult = await _enrollmentService.getTeachingCourses();
        if (!coursesResult.isSuccess) {
          throw Exception(
            coursesResult.error?.message ?? 'Failed to load teaching courses.',
          );
        }

        for (final course in coursesResult.data ?? const <TeachingCourseModel>[]) {
          if (course.courseId == widget.courseId) {
            _course = course;
            break;
          }
        }
      }

      final threads = await _loadAllThreads();
      if (!mounted) {
        return;
      }

      setState(() {
        _threads = threads;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<DiscussionThread>> _loadAllThreads() async {
    const limit = 50;
    var page = 1;
    var hasMore = true;
    final all = <DiscussionThread>[];

    while (hasMore && page <= 20) {
      final result = await _discussionService.getThreads(
        courseId: widget.courseId,
        page: page,
        limit: limit,
      );
      all.addAll(result.data);
      hasMore = result.meta.hasMore;
      page += 1;
    }

    return all;
  }

  List<DiscussionThread> _visibleThreads() {
    final normalizedSearch = _searchQuery.trim().toLowerCase();
    final filtered = _threads.where((thread) {
      final matchesSearch =
          normalizedSearch.isEmpty ||
          thread.title.toLowerCase().contains(normalizedSearch) ||
          thread.description.toLowerCase().contains(normalizedSearch) ||
          thread.createdByName.toLowerCase().contains(normalizedSearch);
      if (!matchesSearch) {
        return false;
      }

      switch (_selectedFilter) {
        case _PostFilter.all:
          return true;
        case _PostFilter.open:
          return !thread.isLocked;
        case _PostFilter.pinned:
          return thread.isPinned;
        case _PostFilter.locked:
          return thread.isLocked;
        case _PostFilter.unanswered:
          return thread.replyCount == 0;
      }
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case _PostSort.latest:
          return (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt);
        case _PostSort.mostReplies:
          return b.replyCount.compareTo(a.replyCount);
        case _PostSort.mostViews:
          return b.viewCount.compareTo(a.viewCount);
        case _PostSort.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> _createPost() async {
    final l10n = AppLocalizations.of(context);
    final draft = await showTADiscussionThreadComposer(context);
    if (draft == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _discussionService.createThread(
        courseId: widget.courseId,
        title: draft.title,
        description: draft.description,
      );
      if (!mounted) {
        return;
      }
      await _loadData(showLoader: false);
      _showSnack(l10n.instructorDiscussionPostCreated);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _editThread(DiscussionThread thread) async {
    final l10n = AppLocalizations.of(context);
    final draft = await showTADiscussionThreadComposer(
      context,
      initialValue: TADiscussionComposerResult(
        title: thread.title,
        description: thread.description,
      ),
    );
    if (draft == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _discussionService.updateThread(
        threadId: thread.id,
        title: draft.title,
        description: draft.description,
      );
      if (!mounted) {
        return;
      }
      await _loadData(showLoader: false);
      _showSnack(l10n.instructorDiscussionPostUpdated);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deleteThread(DiscussionThread thread) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showTADiscussionConfirmDialog(
      context,
      title: l10n.instructorDiscussionDeletePostTitle,
      message: l10n.instructorDiscussionDeletePostMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _discussionService.deleteThread(thread.id);
      if (!mounted) {
        return;
      }
      await _loadData(showLoader: false);
      _showSnack(l10n.instructorDiscussionPostDeleted);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _togglePin(DiscussionThread thread) async {
    await _runThreadAction(
      () => _discussionService.togglePin(thread.id),
      successMessage: thread.isPinned
          ? AppLocalizations.of(context).instructorDiscussionThreadUnpinned
          : AppLocalizations.of(context).instructorDiscussionThreadPinned,
    );
  }

  Future<void> _toggleLock(DiscussionThread thread) async {
    await _runThreadAction(
      () => _discussionService.toggleLock(thread.id),
      successMessage: thread.isLocked
          ? AppLocalizations.of(context).instructorDiscussionThreadUnlocked
          : AppLocalizations.of(context).instructorDiscussionThreadLocked,
    );
  }

  Future<void> _runThreadAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() => _submitting = true);
    try {
      await action();
      if (!mounted) {
        return;
      }
      await _loadData(showLoader: false);
      _showSnack(successMessage);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);
        final r = context.responsive;
        final threads = _visibleThreads();
        final viewer = resolveTADiscussionViewerContext(context);
        final scrollBody = RefreshIndicator(
          onRefresh: _loadData,
          color: TAColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              if (!widget.embedded) _buildAppBar(isDark, l10n),
              if (widget.embedded)
                SliverToBoxAdapter(
                  child: _buildEmbeddedHeader(isDark, l10n),
                ),
              if (_loading) ...<Widget>[
                SliverToBoxAdapter(
                  child: TADiscussionSummaryHeader(
                    isDark: isDark,
                    responsive: r,
                    title: l10n.instructorCourseDiscussionHeaderTitle,
                    subtitle: l10n.instructorCourseDiscussionHeaderSubtitle,
                    icon: Icons.groups_rounded,
                    stats: <({
                      IconData icon,
                      String label,
                      String value,
                      Color color,
                    })>[
                      (
                        icon: Icons.forum_rounded,
                        label: l10n.instructorDiscussionPostsLabel,
                        value: '—',
                        color: TAColors.accent,
                      ),
                      (
                        icon: Icons.reply_all_rounded,
                        label: l10n.instructorDiscussionRepliesLabel,
                        value: '—',
                        color: TAColors.success,
                      ),
                      (
                        icon: Icons.push_pin_rounded,
                        label: l10n.instructorDiscussionPinnedLabel,
                        value: '—',
                        color: TAColors.warning,
                      ),
                      (
                        icon: Icons.lock_rounded,
                        label: l10n.instructorDiscussionLockedLabel,
                        value: '—',
                        color: TAColors.pink,
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildSkeletonCard(isDark);
                    }, childCount: 3),
                  ),
                ),
              ] else if (_errorMessage != null) ...<Widget>[
                SliverFillRemaining(
                  child: TADiscussionEmptyState(
                    isDark: isDark,
                    icon: Icons.error_outline_rounded,
                    title: l10n.instructorDiscussionLoadFailedTitle,
                    message: _errorMessage!,
                    action: FilledButton.icon(
                      onPressed: _loadData,
                      style: FilledButton.styleFrom(
                        backgroundColor: TAColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ),
                ),
              ] else ...<Widget>[
                SliverToBoxAdapter(
                  child: TADiscussionSummaryHeader(
                    isDark: isDark,
                    responsive: r,
                    title: _course == null
                        ? l10n.instructorCourseDiscussionHeaderTitle
                        : '${_course!.course.code} • ${_course!.course.name}',
                    subtitle: l10n.instructorCourseDiscussionHeaderSubtitle,
                    icon: Icons.forum_rounded,
                    stats: _buildHeaderStats(l10n),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildFilters(isDark, l10n, r, threads.length),
                ),
                if (threads.isEmpty)
                  SliverFillRemaining(
                    child: TADiscussionEmptyState(
                      isDark: isDark,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: l10n.instructorDiscussionNoPostsTitle,
                      message: l10n.instructorDiscussionNoPostsSubtitle,
                      action: FilledButton.icon(
                        onPressed: _submitting ? null : _createPost,
                        style: FilledButton.styleFrom(
                          backgroundColor: TAColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.instructorDiscussionCreatePost),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final thread = threads[index];
                        return _buildThreadCard(
                          context,
                          thread,
                          isDark,
                          l10n,
                          viewer,
                          index,
                        );
                      }, childCount: threads.length),
                    ),
                  ),
              ],
            ],
          ),
        );

        if (widget.embedded) {
          return scrollBody;
        }

        return Scaffold(
          backgroundColor: TAColors.background(isDark),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _submitting ? null : _createPost,
            backgroundColor: TAColors.primary,
            foregroundColor: Colors.white,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_comment_rounded),
            label: Text(l10n.instructorDiscussionCreatePost),
          ),
          body: SafeArea(child: scrollBody),
        );
      },
    );
  }

  Widget _buildEmbeddedHeader(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.discussions,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.instructorCourseDiscussionHeaderSubtitle,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _submitting ? null : _createPost,
            style: FilledButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_comment_rounded, size: 18),
            label: Text(l10n.instructorDiscussionCreatePost),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.background(isDark),
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Text(
        l10n.discussions,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  List<({IconData icon, String label, String value, Color color})>
  _buildHeaderStats(AppLocalizations l10n) {
    final replyCount = _threads.fold<int>(
      0,
      (total, thread) => total + thread.replyCount,
    );
    final pinnedCount = _threads.where((thread) => thread.isPinned).length;
    final lockedCount = _threads.where((thread) => thread.isLocked).length;
    final unanswered = _threads.where((thread) => thread.replyCount == 0).length;

    return <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.forum_rounded,
        label: l10n.instructorDiscussionPostsLabel,
        value: '${_threads.length}',
        color: TAColors.accent,
      ),
      (
        icon: Icons.reply_all_rounded,
        label: l10n.instructorDiscussionRepliesLabel,
        value: '$replyCount',
        color: TAColors.success,
      ),
      (
        icon: Icons.push_pin_rounded,
        label: l10n.instructorDiscussionPinnedLabel,
        value: '$pinnedCount',
        color: TAColors.warning,
      ),
      (
        icon: Icons.lock_rounded,
        label: l10n.instructorDiscussionLockedLabel,
        value: '$lockedCount',
        color: TAColors.pink,
      ),
      (
        icon: Icons.help_center_rounded,
        label: l10n.instructorDiscussionNeedsRepliesShort,
        value: '$unanswered',
        color: TAColors.orange,
      ),
    ];
  }

  Widget _buildFilters(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    int visibleCount,
  ) {
    return TADiscussionFilterPanel(
      isDark: isDark,
      badgeLabel: '$visibleCount ${l10n.instructorDiscussionVisiblePostsLabel}',
      footer: TADiscussionSearchField(
        isDark: isDark,
        hintText: l10n.instructorDiscussionSearchPosts,
        value: _searchQuery,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
      children: <Widget>[
        Expanded(
          child: TADiscussionDropdown<_PostFilter>(
            isDark: isDark,
            label: l10n.status,
            selectedLabel: _postFilterLabel(l10n, _selectedFilter),
            value: _selectedFilter,
            icon: Icons.tune_rounded,
            menuMaxHeight: r.screenHeight * 0.45,
            items: _PostFilter.values
                .map(
                  (filter) => DropdownMenuItem<_PostFilter>(
                    value: filter,
                    child: Text(
                      _postFilterLabel(l10n, filter),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedFilter = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TADiscussionDropdown<_PostSort>(
            isDark: isDark,
            label: l10n.instructorDiscussionSortBy,
            selectedLabel: _postSortLabel(l10n, _selectedSort),
            value: _selectedSort,
            icon: Icons.swap_vert_rounded,
            menuMaxHeight: r.screenHeight * 0.45,
            items: _PostSort.values
                .map(
                  (sort) => DropdownMenuItem<_PostSort>(
                    value: sort,
                    child: Text(
                      _postSortLabel(l10n, sort),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedSort = value);
            },
          ),
        ),
      ],
    );
  }

  String _postFilterLabel(AppLocalizations l10n, _PostFilter filter) {
    switch (filter) {
      case _PostFilter.all:
        return l10n.instructorDiscussionPostFilterAll;
      case _PostFilter.open:
        return l10n.open;
      case _PostFilter.pinned:
        return l10n.instructorDiscussionPinnedLabel;
      case _PostFilter.locked:
        return l10n.instructorDiscussionLockedLabel;
      case _PostFilter.unanswered:
        return l10n.instructorDiscussionPostFilterUnanswered;
    }
  }

  String _postSortLabel(AppLocalizations l10n, _PostSort sort) {
    switch (sort) {
      case _PostSort.latest:
        return l10n.instructorDiscussionSortLatestActivity;
      case _PostSort.mostReplies:
        return l10n.instructorDiscussionSortMostReplies;
      case _PostSort.mostViews:
        return l10n.instructorDiscussionSortMostViews;
      case _PostSort.title:
        return l10n.instructorDiscussionSortTitle;
    }
  }

  Widget _buildThreadCard(
    BuildContext context,
    DiscussionThread thread,
    bool isDark,
    AppLocalizations l10n,
    TADiscussionViewerContext viewer,
    int index,
  ) {
    final gradient = taDiscussionAccentGradient(index);
    final canEdit =
        viewer.userId == thread.createdBy || viewer.canEditAnyThread;
    final canDelete = viewer.canDeleteAnyThread;
    final canShowMenu = canEdit || canDelete || viewer.canModerate;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: taDiscussionCardDecoration(
        isDark,
        highlighted: thread.replyCount == 0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openThread(context, thread),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          thread.title,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          thread.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canShowMenu)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            if (canEdit) {
                              _editThread(thread);
                            }
                            break;
                          case 'delete':
                            if (canDelete) {
                              _deleteThread(thread);
                            }
                            break;
                          case 'pin':
                            _togglePin(thread);
                            break;
                          case 'lock':
                            _toggleLock(thread);
                            break;
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        if (canEdit)
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text(l10n.edit),
                          ),
                        if (viewer.canModerate)
                          PopupMenuItem<String>(
                            value: 'pin',
                            child: Text(
                              thread.isPinned
                                  ? l10n.instructorDiscussionUnpinThread
                                  : l10n.instructorDiscussionPinThread,
                            ),
                          ),
                        if (viewer.canModerate)
                          PopupMenuItem<String>(
                            value: 'lock',
                            child: Text(
                              thread.isLocked
                                  ? l10n.instructorDiscussionUnlockThread
                                  : l10n.instructorDiscussionLockThread,
                            ),
                          ),
                        if (canDelete)
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              l10n.delete,
                              style: const TextStyle(color: TAColors.error),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  TADiscussionMetricChip(
                    color: TAColors.success,
                    icon: Icons.reply_all_rounded,
                    label:
                        '${thread.replyCount} ${l10n.instructorDiscussionRepliesLabel}',
                  ),
                  TADiscussionMetricChip(
                    color: TAColors.cyan,
                    icon: Icons.visibility_rounded,
                    label:
                        '${thread.viewCount} ${l10n.instructorDiscussionViewsLabel}',
                  ),
                  if (thread.isPinned)
                    TADiscussionMetricChip(
                      color: TAColors.warning,
                      icon: Icons.push_pin_rounded,
                      label: l10n.instructorDiscussionPinnedLabel,
                    ),
                  if (thread.isLocked)
                    TADiscussionMetricChip(
                      color: TAColors.error,
                      icon: Icons.lock_rounded,
                      label: l10n.instructorDiscussionLockedLabel,
                    ),
                  if (thread.replyCount == 0)
                    TADiscussionMetricChip(
                      color: TAColors.orange,
                      icon: Icons.help_center_rounded,
                      label: l10n.instructorDiscussionNeedsRepliesShort,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: TAColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      taDiscussionInitials(thread.createdByName),
                      style: const TextStyle(
                        color: TAColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          taDiscussionDisplayName(
                            context,
                            thread.createdByName,
                          ),
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          taDiscussionFormatDate(context, thread.createdAt),
                          style: TextStyle(
                            color: TAColors.textTertiaryColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openThread(context, thread),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TAColors.primary,
                      side: BorderSide(
                        color: TAColors.primary.withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(l10n.instructorDiscussionOpenThread),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openThread(BuildContext context, DiscussionThread thread) async {
    await context.push(
      '/ta/course/${widget.courseId}/discussions/${thread.id}',
      extra: <String, dynamic>{'course': _course, 'thread': thread},
    );
    if (!mounted) {
      return;
    }
    await _loadData(showLoader: false);
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: taDiscussionCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(4, (index) {
          final widths = <double>[52, double.infinity, 180, 120];
          final heights = <double>[52, 18, 14, 32];
          return Padding(
            padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
            child: Container(
              width: widths[index],
              height: heights[index],
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(index == 0 ? 16 : 10),
              ),
            ),
          );
        }),
      ),
    );
  }
}





