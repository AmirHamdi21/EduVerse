import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/discussions/discussion_bloc.dart';
import '../../bloc/discussions/discussion_event.dart';
import '../../bloc/discussions/discussion_state.dart';
import '../../models/discussion/discussion_models.dart';
import '../../widgets/shared/discussions/shared_discussions_barrel.dart';

class DiscussionScreen extends StatefulWidget {
  final int? courseId;
  final Color accentColor;
  final bool embedMode;
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;

  const DiscussionScreen({
    super.key,
    this.courseId,
    required this.accentColor,
    this.embedMode = false,
    this.title = 'Discussions',
    this.leadingIcon,
    this.onLeadingPressed,
  });

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  late final DiscussionBloc _discussionBloc;
  bool _isBlocOwned = false;

  @override
  void initState() {
    super.initState();
    _discussionBloc = context.read<DiscussionBloc?>() ?? DiscussionBloc();
    _isBlocOwned = context.read<DiscussionBloc?>() == null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureContextAndLoad();
    });
  }

  @override
  void didUpdateWidget(covariant DiscussionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      _configureContextAndLoad();
    }
  }

  @override
  void dispose() {
    if (_isBlocOwned) {
      _discussionBloc.close();
    }
    super.dispose();
  }

  void _configureContextAndLoad() {
    final authState = context.read<AuthBloc>().state;

    int? userId;
    var canModerate = false;
    if (authState is AuthAuthenticated) {
      userId = authState.user.userId;
      final roleNames = authState.user.roles
          .map((role) => role.roleName.toLowerCase())
          .toSet();
      canModerate =
          roleNames.contains('instructor') ||
          roleNames.contains('ta') ||
          roleNames.contains('teaching_assistant') ||
          roleNames.contains('admin') ||
          roleNames.contains('it_admin') ||
          roleNames.contains('it admin');
    }

    _discussionBloc.add(
      SetDiscussionContext(
        courseId: widget.courseId,
        currentUserId: userId,
        canModerate: canModerate,
      ),
    );
    _discussionBloc.add(
      LoadThreads(courseId: widget.courseId, page: 1, refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isBlocOwned) {
      return BlocProvider<DiscussionBloc>.value(
        value: _discussionBloc,
        child: _buildContent(context),
      );
    }

    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final body = BlocConsumer<DiscussionBloc, DiscussionState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.errorMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.read<DiscussionBloc>().add(const ClearDiscussionError());
        }
      },
      builder: (context, state) {
        if (state.status == DiscussionStatus.loading && state.threads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return _buildWideLayout(state);
            }
            return _buildMobileLayout(state);
          },
        );
      },
    );

    if (widget.embedMode) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: widget.leadingIcon != null
            ? IconButton(
                onPressed:
                    widget.onLeadingPressed ??
                    () => Navigator.of(context).maybePop(),
                icon: Icon(widget.leadingIcon),
              )
            : null,
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildWideLayout(DiscussionState state) {
    return Row(
      children: [
        SizedBox(
          width: 370,
          child: Column(
            children: [
              SharedDiscussionHeader(
                title: widget.title,
                accentColor: widget.accentColor,
                canCreateThread: state.currentCourseId != null,
                onCreateThread: state.currentCourseId == null
                    ? null
                    : () => _showCreateThreadDialog(state.currentCourseId!),
              ),
              Expanded(child: _buildThreadList(state)),
            ],
          ),
        ),
        Container(width: 1, color: Colors.grey.withValues(alpha: 0.2)),
        Expanded(
          child: state.selectedThread == null
              ? SharedDiscussionEmptyState(
                  title: 'Select a thread',
                  message:
                      'Pick a thread from the list to read replies and join the discussion.',
                  accentColor: widget.accentColor,
                )
              : _buildThreadDetail(state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(DiscussionState state) {
    if (state.selectedThread == null) {
      return Column(
        children: [
          SharedDiscussionHeader(
            title: widget.title,
            accentColor: widget.accentColor,
            canCreateThread: state.currentCourseId != null,
            onCreateThread: state.currentCourseId == null
                ? null
                : () => _showCreateThreadDialog(state.currentCourseId!),
          ),
          Expanded(child: _buildThreadList(state)),
        ],
      );
    }

    return _buildThreadDetail(state);
  }

  Widget _buildThreadList(DiscussionState state) {
    return SharedDiscussionThreadList(
      threads: state.threads,
      selectedThreadId: state.selectedThread?.id,
      accentColor: widget.accentColor,
      isError: state.status == DiscussionStatus.failure,
      errorMessage: state.errorMessage,
      canModerate: state.canModerate,
      currentUserId: state.currentUserId,
      hasMore: state.hasMoreThreads,
      isPaginating: state.isPaginatingThreads,
      onRetry: () {
        _discussionBloc.add(
          LoadThreads(
            courseId: state.currentCourseId ?? widget.courseId,
            page: 1,
            refresh: true,
          ),
        );
      },
      onLoadMore: () => _discussionBloc.add(const LoadMoreThreads()),
      onThreadTap: (thread) {
        _discussionBloc.add(
          SelectThread(threadId: thread.id, incrementView: true),
        );
      },
      onEditThread: (thread) => _showEditThreadDialog(thread),
      onDeleteThread: (thread) => _confirmDeleteThread(thread),
      onTogglePin: (thread) =>
          _discussionBloc.add(TogglePinRequested(thread.id)),
      onToggleLock: (thread) =>
          _discussionBloc.add(ToggleLockRequested(thread.id)),
    );
  }

  Widget _buildThreadDetail(DiscussionState state) {
    final selected = state.selectedThread;
    if (selected == null) {
      return const SizedBox.shrink();
    }

    return SharedDiscussionThreadDetail(
      thread: selected,
      replies: state.replies,
      accentColor: widget.accentColor,
      isError: state.status == DiscussionStatus.failure,
      errorMessage: state.errorMessage,
      canModerate: state.canModerate,
      currentUserId: state.currentUserId,
      hasMoreReplies: state.hasMoreReplies,
      isPaginatingReplies: state.isPaginatingReplies,
      onRetry: () {
        _discussionBloc.add(
          SelectThread(threadId: selected.id, incrementView: false),
        );
      },
      onBack: () => _discussionBloc.add(const DeselectThread()),
      onLoadMoreReplies: () => _discussionBloc.add(const LoadMoreReplies()),
      onSendReply: (text) => _submitReply(selected.id, text),
      onEditThread: () => _showEditThreadDialog(selected),
      onDeleteThread: () => _confirmDeleteThread(selected),
      onTogglePin: () => _discussionBloc.add(TogglePinRequested(selected.id)),
      onToggleLock: () => _discussionBloc.add(ToggleLockRequested(selected.id)),
      onMarkAnswer: (reply) =>
          _discussionBloc.add(MarkAnswerRequested(reply.id)),
      onEndorse: (reply) =>
          _discussionBloc.add(EndorseReplyRequested(reply.id)),
      onEditReply: (reply) => _showEditReplyDialog(reply),
      onDeleteReply: (reply) => _confirmDeleteReply(reply),
    );
  }

  Future<bool> _submitReply(int threadId, String text) async {
    final previousReplyCount = _discussionBloc.state.replies.length;
    _discussionBloc.add(
      PostReplyRequested(threadId: threadId, messageText: text),
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    final nextState = _discussionBloc.state;
    if (nextState.errorMessage != null && nextState.errorMessage!.isNotEmpty) {
      return false;
    }

    return nextState.replies.length > previousReplyCount ||
        nextState.status == DiscussionStatus.success;
  }

  Future<void> _showCreateThreadDialog(int courseId) async {
    await showDialog<void>(
      context: context,
      builder: (_) => SharedDiscussionCreateThreadDialog(
        accentColor: widget.accentColor,
        onCreate: (title, description) async {
          _discussionBloc.add(
            CreateThreadRequested(
              courseId: courseId,
              title: title,
              description: description,
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 280));
        },
      ),
    );
  }

  Future<void> _showEditThreadDialog(DiscussionThread thread) async {
    final titleController = TextEditingController(text: thread.title);
    final descriptionController = TextEditingController(
      text: thread.description,
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Thread'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _discussionBloc.add(
                UpdateThreadRequested(
                  threadId: thread.id,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditReplyDialog(DiscussionReply reply) async {
    final controller = TextEditingController(text: reply.messageText);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Reply text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _discussionBloc.add(
                UpdateReplyRequested(
                  replyId: reply.id,
                  messageText: controller.text.trim(),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteThread(DiscussionThread thread) async {
    final approved = await _showDeleteDialog(
      title: 'Delete Thread?',
      message: 'This action cannot be undone.',
    );

    if (approved) {
      _discussionBloc.add(DeleteThreadRequested(thread.id));
    }
  }

  Future<void> _confirmDeleteReply(DiscussionReply reply) async {
    final approved = await _showDeleteDialog(
      title: 'Delete Reply?',
      message: 'This reply will be permanently removed.',
    );

    if (approved) {
      _discussionBloc.add(DeleteReplyRequested(reply.id));
    }
  }

  Future<bool> _showDeleteDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
