import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/discussion/discussion_models.dart';
import 'package:edu_verse/models/core/enrollment_model.dart';
import 'package:edu_verse/screens/student/discussions/student_discussion_ui.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/discussion_service.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';

class StudentDiscussionPostDetailScreen extends StatefulWidget {
  const StudentDiscussionPostDetailScreen({
    super.key,
    required this.courseId,
    required this.threadId,
    this.initialCourse,
    this.initialThread,
    this.discussionService,
    this.enrollmentService,
  });

  final int courseId;
  final int threadId;
  final CourseEnrollmentModel? initialCourse;
  final DiscussionThread? initialThread;
  final DiscussionService? discussionService;
  final EnrollmentService? enrollmentService;

  @override
  State<StudentDiscussionPostDetailScreen> createState() =>
      _StudentDiscussionPostDetailScreenState();
}

class _StudentDiscussionPostDetailScreenState
    extends State<StudentDiscussionPostDetailScreen>
    with SingleTickerProviderStateMixin {
  late final DiscussionService _discussionService;
  late final EnrollmentService _enrollmentService;
  late final TabController _tabController;
  late final ScrollController _repliesScrollController;
  late final TextEditingController _replyController;

  bool _loading = true;
  bool _loadingMore = false;
  bool _submitting = false;
  String? _errorMessage;
  CourseEnrollmentModel? _course;
  DiscussionThread? _thread;
  List<DiscussionReply> _replies = const <DiscussionReply>[];
  int _currentReplyPage = 1;
  bool _hasMoreReplies = true;
  DiscussionReply? _replyingTo;
  int? _knownAuthorId;
  String _knownAuthorName = '';

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
    _thread = widget.initialThread;
    _knownAuthorId = widget.initialThread?.createdBy;
    _knownAuthorName = widget.initialThread?.createdByName.trim() ?? '';
    _tabController = TabController(length: 3, vsync: this);
    _repliesScrollController = ScrollController()
      ..addListener(_handleRepliesScroll);
    _replyController = TextEditingController();
    _loadData(showLoader: true);
  }

  @override
  void dispose() {
    _repliesScrollController
      ..removeListener(_handleRepliesScroll)
      ..dispose();
    _replyController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleRepliesScroll() {
    if (_repliesScrollController.position.pixels >=
        _repliesScrollController.position.maxScrollExtent - 160) {
      _loadMoreReplies();
    }
  }

  DiscussionThread _normalizeThreadAuthor(DiscussionThread incoming) {
    final incomingName = incoming.createdByName.trim();
    if (incomingName.isNotEmpty) {
      _knownAuthorId = incoming.createdBy;
      _knownAuthorName = incomingName;
      return incoming;
    }

    if (_knownAuthorId == incoming.createdBy && _knownAuthorName.isNotEmpty) {
      return incoming.copyWith(createdByName: _knownAuthorName);
    }

    final previousName = _thread?.createdByName.trim() ?? '';
    if ((_thread?.createdBy == incoming.createdBy) && previousName.isNotEmpty) {
      _knownAuthorId = incoming.createdBy;
      _knownAuthorName = previousName;
      return incoming.copyWith(createdByName: previousName);
    }

    final initialName = widget.initialThread?.createdByName.trim() ?? '';
    if ((widget.initialThread?.createdBy == incoming.createdBy) &&
        initialName.isNotEmpty) {
      _knownAuthorId = incoming.createdBy;
      _knownAuthorName = initialName;
      return incoming.copyWith(createdByName: initialName);
    }

    return incoming;
  }

  Future<void> _loadData({required bool showLoader}) async {
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
        final coursesResult = await _enrollmentService.getMyCourses();
        if (!coursesResult.isSuccess) {
          throw Exception(
            coursesResult.error?.message ?? 'Failed to load enrolled courses.',
          );
        }

        for (final course
            in coursesResult.data ?? const <CourseEnrollmentModel>[]) {
          if ((course.course?.courseId ?? 0) == widget.courseId) {
            _course = course;
            break;
          }
        }
      }

      final detail = await _discussionService.getThreadDetail(widget.threadId);
      final resolvedThread = _normalizeThreadAuthor(detail.thread);
      if (!mounted) {
        return;
      }

      setState(() {
        _thread = resolvedThread;
        _replies = detail.replies.data;
        _currentReplyPage = detail.replies.meta.page;
        _hasMoreReplies = detail.replies.meta.hasMore;
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

  Future<void> _loadMoreReplies() async {
    if (_loadingMore || !_hasMoreReplies) {
      return;
    }

    setState(() => _loadingMore = true);
    try {
      final detail = await _discussionService.getThreadDetail(
        widget.threadId,
        page: _currentReplyPage + 1,
      );
      final resolvedThread = _normalizeThreadAuthor(detail.thread);
      if (!mounted) {
        return;
      }

      final merged = <int, DiscussionReply>{for (final reply in _replies) reply.id: reply};
      for (final reply in detail.replies.data) {
        merged[reply.id] = reply;
      }

      setState(() {
        _thread = resolvedThread;
        _replies = merged.values.toList(growable: false)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _currentReplyPage = detail.replies.meta.page;
        _hasMoreReplies = detail.replies.meta.hasMore;
      });
    } catch (_) {
      // Keep current content visible if pagination fails.
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<void> _refresh() async {
    await _loadData(showLoader: false);
  }

  Future<void> _editThread() async {
    final l10n = AppLocalizations.of(context);
    final thread = _thread;
    if (thread == null) {
      return;
    }

    final draft = await showStudentDiscussionThreadComposer(
      context,
      initialValue: StudentDiscussionComposerResult(
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
      await _refresh();
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

  Future<void> _deleteThread() async {
    final l10n = AppLocalizations.of(context);
    final thread = _thread;
    if (thread == null) {
      return;
    }

    final confirmed = await showStudentDiscussionConfirmDialog(
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
      context.pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
      setState(() => _submitting = false);
    }
  }

  Future<void> _togglePin() async {
    final thread = _thread;
    if (thread == null) {
      return;
    }
    await _runAction(
      () => _discussionService.togglePin(thread.id),
      successMessage: thread.isPinned
          ? AppLocalizations.of(context).instructorDiscussionThreadUnpinned
          : AppLocalizations.of(context).instructorDiscussionThreadPinned,
    );
  }

  Future<void> _toggleLock() async {
    final thread = _thread;
    if (thread == null) {
      return;
    }
    await _runAction(
      () => _discussionService.toggleLock(thread.id),
      successMessage: thread.isLocked
          ? AppLocalizations.of(context).instructorDiscussionThreadUnlocked
          : AppLocalizations.of(context).instructorDiscussionThreadLocked,
    );
  }

  Future<void> _sendReply(String message) async {
    final l10n = AppLocalizations.of(context);
    final thread = _thread;
    if (thread == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _discussionService.postReply(
        threadId: thread.id,
        messageText: message,
        parentMessageId: _replyingTo?.id,
      );
      if (!mounted) {
        return;
      }
      setState(() => _replyingTo = null);
      await _refresh();
      _replyController.clear();
      _showSnack(l10n.instructorDiscussionReplyPosted);
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

  Future<void> _markAnswer(DiscussionReply reply) async {
    await _runAction(
      () => _discussionService.markAnswer(reply.id),
      successMessage: reply.isAnswer
          ? AppLocalizations.of(context).instructorDiscussionAnswerUnmarked
          : AppLocalizations.of(context).instructorDiscussionAnswerMarked,
    );
  }

  Future<void> _endorseReply(DiscussionReply reply) async {
    await _runAction(
      () => _discussionService.endorseReply(reply.id),
      successMessage: reply.isEndorsed
          ? AppLocalizations.of(context).instructorDiscussionReplyUnendorsed
          : AppLocalizations.of(context).instructorDiscussionReplyEndorsed,
    );
  }

  Future<void> _toggleReplyUpvote(DiscussionReply reply) async {
    final l10n = AppLocalizations.of(context);
    try {
      final action = await _discussionService.toggleMessageUpvote(reply.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _replies = _replies.map((item) {
          if (item.id != reply.id) {
            return item;
          }
          final nextCount = action == 'added'
              ? item.upvoteCount + 1
              : (item.upvoteCount > 0 ? item.upvoteCount - 1 : 0);
          return item.copyWith(upvoteCount: nextCount);
        }).toList(growable: false);
      });

      _showSnack(
        action == 'added'
            ? l10n.instructorDiscussionUpvoteAdded
            : l10n.instructorDiscussionUpvoteRemoved,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() => _submitting = true);
    try {
      await action();
      if (!mounted) {
        return;
      }
      await _refresh();
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
        final thread = _thread;

        if (_loading && thread == null) {
          return Scaffold(
            backgroundColor: StudentDiscussionPalette.background(isDark),
            appBar: AppBar(
              backgroundColor: StudentDiscussionPalette.background(isDark),
              title: Text(l10n.instructorDiscussionPostDetailsTitle),
            ),
            body: Center(
              child: CircularProgressIndicator(color: StudentDiscussionPalette.primary),
            ),
          );
        }

        if (thread == null) {
          return Scaffold(
            backgroundColor: StudentDiscussionPalette.background(isDark),
            appBar: AppBar(
              backgroundColor: StudentDiscussionPalette.background(isDark),
              title: Text(l10n.instructorDiscussionPostDetailsTitle),
            ),
            body: StudentDiscussionEmptyState(
              isDark: isDark,
              icon: Icons.forum_outlined,
              title: l10n.instructorDiscussionLoadFailedTitle,
              message: _errorMessage ?? l10n.instructorDiscussionThreadMissing,
              action: FilledButton.icon(
                onPressed: _refresh,
                style: FilledButton.styleFrom(
                  backgroundColor: StudentDiscussionPalette.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
          );
        }

        final viewer = resolveStudentDiscussionViewerContext(context);
        DiscussionReply? highlightedAnswer;
        for (final reply in _replies) {
          if (reply.isAnswer) {
            highlightedAnswer = reply;
            break;
          }
        }

        return Scaffold(
          backgroundColor: StudentDiscussionPalette.background(isDark),
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return <Widget>[
                  _buildAppBar(isDark, l10n, thread, innerBoxIsScrolled, viewer),
                  SliverToBoxAdapter(
                    child: _buildThreadHeader(
                      context,
                      isDark,
                      l10n,
                      r,
                      thread,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStatsRow(isDark, l10n, thread),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      backgroundColor: StudentDiscussionPalette.background(isDark),
                      tabBar: _buildTabBar(isDark, l10n),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  _buildOverviewTab(
                    context,
                    isDark,
                    l10n,
                    thread,
                    highlightedAnswer,
                  ),
                  _buildConversationTab(context, isDark, l10n, thread, viewer),
                  _buildDetailsTab(context, isDark, l10n, thread),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
    bool isDark,
    AppLocalizations l10n,
    DiscussionThread thread,
    bool innerBoxIsScrolled,
    StudentDiscussionViewerContext viewer,
  ) {
    final canEdit =
        viewer.userId == thread.createdBy || viewer.canEditAnyThread;
    final canDelete = viewer.canDeleteAnyThread;
    final canShowMenu = canEdit || canDelete || viewer.canModerate;

    return SliverAppBar(
      backgroundColor: StudentDiscussionPalette.background(isDark),
      surfaceTintColor: Colors.transparent,
      floating: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: StudentDiscussionPalette.textPrimaryColor(isDark),
        ),
      ),
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          thread.title,
          style: TextStyle(
            color: StudentDiscussionPalette.textPrimaryColor(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: StudentDiscussionPalette.textSecondaryColor(isDark),
          ),
        ),
        if (canShowMenu)
          PopupMenuButton<String>(
            enabled: !_submitting,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  if (canEdit) {
                    _editThread();
                  }
                  break;
                case 'delete':
                  if (canDelete) {
                    _deleteThread();
                  }
                  break;
                case 'pin':
                  _togglePin();
                  break;
                case 'lock':
                  _toggleLock();
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              if (canEdit)
                PopupMenuItem<String>(value: 'edit', child: Text(l10n.edit)),
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
                    style: const TextStyle(color: StudentDiscussionPalette.error),
                  ),
                ),
            ],
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildThreadHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil r,
    DiscussionThread thread,
  ) {
    final stats = <({IconData icon, String label, String value, Color color})>[
      (
        icon: Icons.forum_rounded,
        label: l10n.instructorDiscussionPostsLabel,
        value: '1',
        color: StudentDiscussionPalette.accent,
      ),
      (
        icon: Icons.reply_all_rounded,
        label: l10n.instructorDiscussionRepliesLabel,
        value: '${thread.replyCount}',
        color: StudentDiscussionPalette.success,
      ),
      (
        icon: Icons.visibility_rounded,
        label: l10n.instructorDiscussionViewsLabel,
        value: '${thread.viewCount}',
        color: StudentDiscussionPalette.cyan,
      ),
      (
        icon: Icons.verified_rounded,
        label: l10n.instructorDiscussionAnswersLabel,
        value: '${_replies.where((reply) => reply.isAnswer).length}',
        color: StudentDiscussionPalette.warning,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: studentDiscussionHeaderGradient(isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StudentDiscussionPalette.primary.withValues(
              alpha: isDark ? 0.28 : 0.2,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -36,
              right: -18,
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.isMobile ? 18 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (_course != null)
                              Text(
                                '${_course!.course?.code ?? ''} • ${_course!.course?.name ?? ''}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              thread.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.isMobile ? 20 : 23,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${studentDiscussionDisplayName(context, thread.createdByName)} • ${studentDiscussionFormatDate(context, thread.createdAt)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (thread.isPinned)
                        StudentDiscussionMetricChip(
                          color: Colors.white,
                          icon: Icons.push_pin_rounded,
                          label: l10n.instructorDiscussionPinnedLabel,
                        ),
                      if (thread.isLocked)
                        StudentDiscussionMetricChip(
                          color: Colors.white,
                          icon: Icons.lock_rounded,
                          label: l10n.instructorDiscussionLockedLabel,
                        ),
                      if (thread.replyCount == 0)
                        StudentDiscussionMetricChip(
                          color: Colors.white,
                          icon: Icons.help_center_rounded,
                          label: l10n.instructorDiscussionNeedsRepliesShort,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 420 ? 2 : 4;
                      const spacing = 10.0;
                      final itemWidth =
                          (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: stats
                            .map(
                              (stat) => SizedBox(
                                width: itemWidth,
                                child: StudentDiscussionHeaderStatCard(
                                  icon: stat.icon,
                                  label: stat.label,
                                  value: stat.value,
                                  color: stat.color,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDark,
    AppLocalizations l10n,
    DiscussionThread thread,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildMiniStat(
              isDark,
              icon: Icons.reply_all_rounded,
              label: l10n.instructorDiscussionRepliesLabel,
              value: '${thread.replyCount}',
              color: StudentDiscussionPalette.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniStat(
              isDark,
              icon: Icons.visibility_rounded,
              label: l10n.instructorDiscussionViewsLabel,
              value: '${thread.viewCount}',
              color: StudentDiscussionPalette.cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniStat(
              isDark,
              icon: Icons.verified_rounded,
              label: l10n.instructorDiscussionAnswersLabel,
              value: '${_replies.where((reply) => reply.isAnswer).length}',
              color: StudentDiscussionPalette.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: studentDiscussionCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: StudentDiscussionPalette.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: StudentDiscussionPalette.textSecondaryColor(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  TabBar _buildTabBar(bool isDark, AppLocalizations l10n) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: StudentDiscussionPalette.primary,
      unselectedLabelColor: StudentDiscussionPalette.textSecondaryColor(isDark),
      indicatorColor: StudentDiscussionPalette.primary,
      indicatorWeight: 3,
      tabs: <Tab>[
        Tab(text: l10n.overview),
        Tab(text: l10n.instructorDiscussionConversationTab),
        Tab(text: l10n.details),
      ],
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    DiscussionThread thread,
    DiscussionReply? highlightedAnswer,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: StudentDiscussionPalette.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          _buildSectionCard(
            isDark,
            title: l10n.instructorDiscussionPostOverviewTitle,
            icon: Icons.article_rounded,
            child: Text(
              thread.description,
              style: TextStyle(
                color: StudentDiscussionPalette.textPrimaryColor(isDark),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            isDark,
            title: l10n.instructorDiscussionHighlightedAnswerTitle,
            icon: Icons.verified_rounded,
            child: highlightedAnswer == null
                ? Text(
                    l10n.instructorDiscussionNoHighlightedAnswer,
                    style: TextStyle(
                      color: StudentDiscussionPalette.textSecondaryColor(isDark),
                      fontSize: 13,
                    ),
                  )
                : _buildHighlightedReply(context, isDark, highlightedAnswer),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            isDark,
            title: l10n.instructorDiscussionActivitySummaryTitle,
            icon: Icons.insights_rounded,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                StudentDiscussionMetricChip(
                  color: StudentDiscussionPalette.success,
                  icon: Icons.reply_all_rounded,
                  label:
                      '${thread.replyCount} ${l10n.instructorDiscussionRepliesLabel}',
                ),
                StudentDiscussionMetricChip(
                  color: StudentDiscussionPalette.cyan,
                  icon: Icons.visibility_rounded,
                  label:
                      '${thread.viewCount} ${l10n.instructorDiscussionViewsLabel}',
                ),
                StudentDiscussionMetricChip(
                  color: StudentDiscussionPalette.warning,
                  icon: Icons.verified_rounded,
                  label:
                      '${_replies.where((reply) => reply.isAnswer).length} ${l10n.instructorDiscussionAnswersLabel}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    DiscussionThread thread,
    StudentDiscussionViewerContext viewer,
  ) {
    final roots = _buildReplyTree();
    DiscussionReply? pinnedAnswer;
    for (final reply in _replies) {
      if (reply.isAnswer) {
        pinnedAnswer = reply;
        break;
      }
    }

    return Column(
      children: <Widget>[
        if (thread.isLocked)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: StudentDiscussionPalette.warningLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: StudentDiscussionPalette.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.lock_rounded, color: StudentDiscussionPalette.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.instructorDiscussionLockedBanner,
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: StudentDiscussionPalette.primary,
            child: roots.isEmpty
                ? ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 320,
                        child: Center(
                          child: StudentDiscussionEmptyState(
                            isDark: isDark,
                            icon: Icons.mark_chat_unread_outlined,
                            title: l10n.instructorDiscussionNoRepliesTitle,
                            message: l10n.instructorDiscussionNoRepliesSubtitle,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _repliesScrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    itemCount:
                        roots.length +
                        (_loadingMore ? 1 : 0) +
                        (pinnedAnswer == null ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (pinnedAnswer != null && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSectionCard(
                            isDark,
                            title: l10n.instructorDiscussionPinnedAnswerTitle,
                            icon: Icons.verified_rounded,
                            child: _buildHighlightedReply(
                              context,
                              isDark,
                              pinnedAnswer,
                            ),
                          ),
                        );
                      }

                      final adjustedIndex =
                          pinnedAnswer == null ? index : index - 1;

                      if (adjustedIndex >= roots.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildReplyNode(
                        context,
                        roots[adjustedIndex],
                        isDark,
                        l10n,
                        viewer,
                        depth: 0,
                      );
                    },
                  ),
          ),
        ),
        _buildReplyComposer(isDark, l10n, thread),
      ],
    );
  }

  Widget _buildDetailsTab(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    DiscussionThread thread,
  ) {
    final info = <({String label, String value})>[
      (
        label: l10n.instructorDiscussionAuthorLabel,
        value: studentDiscussionDisplayName(context, thread.createdByName),
      ),
      (
        label: l10n.course,
        value: _course == null
            ? '—'
            : '${_course!.course?.code ?? ''} • ${_course!.course?.name ?? ''}',
      ),
      (
        label: l10n.instructorDiscussionSectionLabel,
        value: _course?.section?.sectionNumber.toString() ?? '—',
      ),
      (
        label: l10n.instructorDiscussionSemesterLabel,
        value: _course?.semester?.name ?? '—',
      ),
      (
        label: l10n.instructorDiscussionCreatedLabel,
        value: studentDiscussionFormatDate(context, thread.createdAt),
      ),
      (
        label: l10n.instructorDiscussionUpdatedLabel,
        value: studentDiscussionFormatDate(context, thread.updatedAt),
      ),
      (
        label: l10n.status,
        value: thread.isLocked ? l10n.instructorDiscussionLockedLabel : l10n.open,
      ),
    ];

    return RefreshIndicator(
      onRefresh: _refresh,
      color: StudentDiscussionPalette.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          _buildSectionCard(
            isDark,
            title: l10n.instructorDiscussionPostDetailsTitle,
            icon: Icons.info_outline_rounded,
            child: Column(
              children: info
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: StudentDiscussionPalette.textSecondaryColor(
                                  isDark,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.value,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: StudentDiscussionPalette.textPrimaryColor(isDark),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    bool isDark, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: studentDiscussionCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: StudentDiscussionPalette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: StudentDiscussionPalette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: StudentDiscussionPalette.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHighlightedReply(
    BuildContext context,
    bool isDark,
    DiscussionReply reply,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? StudentDiscussionPalette.surfaceColor(isDark).withValues(alpha: 0.78)
            : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: StudentDiscussionPalette.success.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            studentDiscussionDisplayName(context, reply.userName),
            style: TextStyle(
              color: StudentDiscussionPalette.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            studentDiscussionFormatDate(context, reply.createdAt),
            style: TextStyle(
              color: StudentDiscussionPalette.textTertiaryColor(isDark),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reply.messageText,
            style: TextStyle(
              color: StudentDiscussionPalette.textPrimaryColor(isDark),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<_ReplyNode> _buildReplyTree() {
    final childrenByParent = <int?, List<DiscussionReply>>{};
    for (final reply in _replies) {
      childrenByParent
          .putIfAbsent(reply.parentMessageId, () => <DiscussionReply>[])
          .add(reply);
    }

    final roots = (childrenByParent[null] ?? const <DiscussionReply>[])
        .toList(growable: false)
      ..sort(_replyComparator);

    List<_ReplyNode> buildNodes(List<DiscussionReply> replies) {
      return replies.map((reply) {
        final children = (childrenByParent[reply.id] ?? const <DiscussionReply>[])
            .toList(growable: false);
        children.sort(_replyComparator);
        return _ReplyNode(reply: reply, children: buildNodes(children));
      }).toList(growable: false);
    }

    return buildNodes(roots);
  }

  int _replyComparator(DiscussionReply a, DiscussionReply b) {
    final answerCompare = (b.isAnswer ? 1 : 0).compareTo(a.isAnswer ? 1 : 0);
    if (answerCompare != 0) {
      return answerCompare;
    }

    final endorsementCompare =
        (b.isEndorsed ? 1 : 0).compareTo(a.isEndorsed ? 1 : 0);
    if (endorsementCompare != 0) {
      return endorsementCompare;
    }

    final upvoteCompare = b.upvoteCount.compareTo(a.upvoteCount);
    if (upvoteCompare != 0) {
      return upvoteCompare;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  Widget _buildReplyNode(
    BuildContext context,
    _ReplyNode node,
    bool isDark,
    AppLocalizations l10n,
    StudentDiscussionViewerContext viewer, {
    required int depth,
  }) {
    final reply = node.reply;
    final canManage = viewer.canModerate || viewer.userId == reply.userId;

    return Padding(
      padding: EdgeInsets.only(left: depth * 18.0, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StudentDiscussionPalette.cardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: reply.isAnswer
                ? StudentDiscussionPalette.success.withValues(alpha: 0.35)
                : StudentDiscussionPalette.borderColor(isDark).withValues(alpha: 0.75),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: StudentDiscussionPalette.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Text(
                    studentDiscussionInitials(reply.userName),
                    style: const TextStyle(
                      color: StudentDiscussionPalette.primary,
                      fontSize: 12,
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
                        studentDiscussionDisplayName(
                          context,
                          reply.userName,
                        ),
                        style: TextStyle(
                          color: StudentDiscussionPalette.textPrimaryColor(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        studentDiscussionFormatDate(context, reply.createdAt),
                        style: TextStyle(
                          color: StudentDiscussionPalette.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canManage)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'reply':
                          setState(() => _replyingTo = reply);
                          break;
                        case 'answer':
                          _markAnswer(reply);
                          break;
                        case 'endorse':
                          _endorseReply(reply);
                          break;
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'reply',
                        child: Text(l10n.reply),
                      ),
                      if (viewer.canModerate)
                        PopupMenuItem<String>(
                          value: 'answer',
                          child: Text(
                            reply.isAnswer
                                ? l10n.instructorDiscussionUnmarkAnswer
                                : l10n.instructorDiscussionMarkAnswer,
                          ),
                        ),
                      if (viewer.canModerate)
                        PopupMenuItem<String>(
                          value: 'endorse',
                          child: Text(
                            reply.isEndorsed
                                ? l10n.instructorDiscussionRemoveEndorse
                                : l10n.instructorDiscussionEndorseReply,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reply.messageText,
              style: TextStyle(
                color: StudentDiscussionPalette.textPrimaryColor(isDark),
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => _toggleReplyUpvote(reply),
                  style: TextButton.styleFrom(
                    foregroundColor: StudentDiscussionPalette.accent,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                  label: Text('${reply.upvoteCount}'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _replyingTo = reply),
                  style: TextButton.styleFrom(
                    foregroundColor: StudentDiscussionPalette.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.reply_rounded, size: 16),
                  label: Text(l10n.reply),
                ),
                if (reply.isAnswer)
                  StudentDiscussionMetricChip(
                    color: StudentDiscussionPalette.success,
                    icon: Icons.verified_rounded,
                    label: l10n.instructorDiscussionAnswerLabel,
                  ),
                if (reply.isEndorsed)
                  StudentDiscussionMetricChip(
                    color: StudentDiscussionPalette.accent,
                    icon: Icons.thumb_up_alt_rounded,
                    label: l10n.instructorDiscussionEndorsedLabel,
                  ),
                if (reply.parentMessageId != null)
                  StudentDiscussionMetricChip(
                    color: StudentDiscussionPalette.textSecondary,
                    icon: Icons.subdirectory_arrow_right_rounded,
                    label: l10n.replyingTo,
                  ),
              ],
            ),
            if (node.children.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              ...node.children.map(
                (child) => _buildReplyNode(
                  context,
                  child,
                  isDark,
                  l10n,
                  viewer,
                  depth: depth + 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyComposer(
    bool isDark,
    AppLocalizations l10n,
    DiscussionThread thread,
  ) {
    Future<void> submit() async {
      final text = _replyController.text.trim();
      if (text.isEmpty || _submitting || thread.isLocked) {
        return;
      }
      await _sendReply(text);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: StudentDiscussionPalette.cardColor(isDark),
        border: Border(
          top: BorderSide(
            color: StudentDiscussionPalette.borderColor(isDark).withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_replyingTo != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: StudentDiscussionPalette.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${l10n.replyingTo}: ${studentDiscussionDisplayName(context, _replyingTo!.userName)}',
                      style: const TextStyle(
                        color: StudentDiscussionPalette.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _replyingTo = null),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    color: StudentDiscussionPalette.primary,
                  ),
                ],
              ),
            ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _replyController,
                  enabled: !_submitting && !thread.isLocked,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: thread.isLocked
                        ? l10n.instructorDiscussionRepliesDisabledHint
                        : l10n.instructorDiscussionReplyHint,
                    filled: true,
                    fillColor: isDark
                        ? StudentDiscussionPalette.surfaceColor(isDark).withValues(
                            alpha: 0.78,
                          )
                        : const Color(0xFFF8FBFF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: StudentDiscussionPalette.borderColor(isDark).withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: StudentDiscussionPalette.borderColor(isDark).withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: StudentDiscussionPalette.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: thread.isLocked || _submitting ? null : submit,
                style: FilledButton.styleFrom(
                  backgroundColor: StudentDiscussionPalette.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(50, 50),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyNode {
  const _ReplyNode({required this.reply, required this.children});

  final DiscussionReply reply;
  final List<_ReplyNode> children;
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}







