import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/discussions/ta_discussions_barrel.dart';

class TADiscussionsScreen extends StatefulWidget {
  const TADiscussionsScreen({super.key});

  @override
  State<TADiscussionsScreen> createState() => _TADiscussionsScreenState();
}

class _TADiscussionsScreenState extends State<TADiscussionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  List<TADiscussionThread> _threads = [];
  List<TATrendingTopic> _trendingTopics = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    _threads = _getMockThreads();
    _trendingTopics = _getMockTrendingTopics();

    setState(() => _isLoading = false);
  }

  List<TADiscussionThread> _getMockThreads() {
    return [
      TADiscussionThread(
        id: '1',
        title: 'Need help with Lab 3 synchronization',
        studentName: 'Ahmed Hassan',
        preview: 'I\'m confused about how semaphores work in the producer-consumer problem.',
        tags: ['Lab 3', 'Urgent'],
        replyCount: 3,
        timeAgo: '5 mins ago',
        status: TAThreadStatus.unread,
      ),
      TADiscussionThread(
        id: '2',
        title: 'Deadlock detection algorithm explanation',
        studentName: 'Emily Rodriguez',
        preview: 'Could you clarify the wait-for graph approach?',
        tags: ['Lab 4', 'General', 'Instructor'],
        replyCount: 5,
        timeAgo: '15 mins ago',
        status: TAThreadStatus.resolved,
      ),
      TADiscussionThread(
        id: '3',
        title: 'Assignment 2 submission format',
        studentName: 'Michael Chen',
        preview: 'Should we submit as a single file or multiple files?',
        tags: ['Assignment 2', 'General'],
        replyCount: 2,
        timeAgo: '30 mins ago',
        status: TAThreadStatus.resolved,
      ),
      TADiscussionThread(
        id: '4',
        title: 'Race condition in my code',
        studentName: 'James Williams',
        preview: 'I keep getting inconsistent results when running my threads...',
        tags: ['Lab 3', 'Urgent'],
        replyCount: 1,
        timeAgo: '1 hour ago',
        status: TAThreadStatus.unread,
      ),
      TADiscussionThread(
        id: '5',
        title: 'Memory allocation question',
        studentName: 'Sara Mohamed',
        preview: 'Can we use dynamic allocation for the buffer in Lab 2?',
        tags: ['Lab 2', 'General'],
        replyCount: 4,
        timeAgo: '2 hours ago',
        status: TAThreadStatus.read,
      ),
    ];
  }

  List<TATrendingTopic> _getMockTrendingTopics() {
    return [
      TATrendingTopic(id: '1', name: 'Process Synchronization', count: 8),
      TATrendingTopic(id: '2', name: 'Deadlock Detection', count: 5),
      TATrendingTopic(id: '3', name: 'Thread Programming', count: 3),
    ];
  }

  List<TADiscussionThread> get _filteredThreads {
    var filtered = _threads;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
          t.title.toLowerCase().contains(query) ||
          t.studentName.toLowerCase().contains(query) ||
          t.preview.toLowerCase().contains(query) ||
          t.tags.any((tag) => tag.toLowerCase().contains(query))).toList();
    }

    switch (_selectedFilter) {
      case 'unanswered':
        filtered = filtered.where((t) =>
            t.status == TAThreadStatus.unread).toList();
        break;
      case 'my_replies':
        // In real app, filter by threads user replied to
        filtered = filtered.where((t) =>
            t.status == TAThreadStatus.resolved).toList();
        break;
      case 'flagged':
        filtered = filtered.where((t) =>
            t.tags.any((tag) => tag.toLowerCase() == 'urgent')).toList();
        break;
    }

    return filtered;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: TADrawer(
            currentRoute: '/ta/discussions',
            isDark: isDark,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: TAColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, l10n),
                  SliverToBoxAdapter(
                    child: _buildActionBar(isDark, l10n),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFilterChips(isDark, l10n),
                  ),
                  _buildThreadsList(isDark, l10n),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TATrendingTopics(
                        isDark: isDark,
                        topics: _trendingTopics,
                        onTopicTap: (topic) =>
                            _showSnackBar('Viewing topic: ${topic.name}'),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateThreadDialog(isDark, l10n),
            backgroundColor: TAColors.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  void _showThreadDetailSheet(bool isDark, AppLocalizations l10n, TADiscussionThread thread) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            thread.title,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${thread.studentName} · ${thread.timeAgo}',
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(thread.status, isDark),
                  ],
                ),
              ),
              // Tags
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: thread.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TAColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: TAColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Original Question
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TAColors.scaffoldColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: TAColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  thread.studentName[0],
                                  style: TextStyle(
                                    color: TAColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                thread.studentName,
                                style: TextStyle(
                                  color: TAColors.textPrimaryColor(isDark),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                thread.timeAgo,
                                style: TextStyle(
                                  color: TAColors.textTertiaryColor(isDark),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            thread.preview,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Replies section
                    Row(
                      children: [
                        Icon(Icons.forum_outlined, size: 16, color: TAColors.textSecondaryColor(isDark)),
                        const SizedBox(width: 6),
                        Text(
                          '${thread.replyCount} ${l10n.taDiscussReplies}',
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Sample Reply
                    _buildReplyItem(
                      isDark: isDark,
                      name: 'You (TA)',
                      message: 'Great question! Let me explain the semaphore concept...',
                      timeAgo: '2 mins ago',
                      isTA: true,
                    ),
                    if (thread.replyCount > 1)
                      _buildReplyItem(
                        isDark: isDark,
                        name: thread.studentName,
                        message: 'Thank you! That makes more sense now.',
                        timeAgo: '1 min ago',
                        isTA: false,
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              // Reply input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TAColors.cardColor(isDark),
                  border: Border(
                    top: BorderSide(color: TAColors.borderColor(isDark)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: TAColors.scaffoldColor(isDark),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.taDiscussReplyPlaceholder,
                              hintStyle: TextStyle(
                                color: TAColors.textTertiaryColor(isDark),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: TAColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSnackBar('Reply sent!');
                          },
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TAThreadStatus status, bool isDark) {
    Color bgColor;
    Color textColor;
    String label;
    
    switch (status) {
      case TAThreadStatus.unread:
        bgColor = TAColors.warning.withValues(alpha: 0.15);
        textColor = TAColors.warning;
        label = 'Unread';
        break;
      case TAThreadStatus.read:
        bgColor = TAColors.info.withValues(alpha: 0.15);
        textColor = TAColors.info;
        label = 'Read';
        break;
      case TAThreadStatus.resolved:
        bgColor = TAColors.success.withValues(alpha: 0.15);
        textColor = TAColors.success;
        label = 'Resolved';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReplyItem({
    required bool isDark,
    required String name,
    required String message,
    required String timeAgo,
    required bool isTA,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTA 
            ? TAColors.primary.withValues(alpha: 0.08)
            : TAColors.scaffoldColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: isTA 
            ? Border.all(color: TAColors.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isTA 
                    ? TAColors.primary
                    : TAColors.info.withValues(alpha: 0.2),
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: isTA ? Colors.white : TAColors.info,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (isTA) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TAColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                timeAgo,
                style: TextStyle(
                  color: TAColors.textTertiaryColor(isDark),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateThreadDialog(bool isDark, AppLocalizations l10n) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCourse = 'CS101';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TAColors.borderColor(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.taDiscussCreateThread,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                // Course selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: TAColors.scaffoldColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TAColors.borderColor(isDark)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCourse,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: TAColors.textSecondaryColor(isDark)),
                      dropdownColor: TAColors.cardColor(isDark),
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 14,
                      ),
                      items: ['CS101', 'CS201', 'CS301'].map((course) {
                        return DropdownMenuItem(value: course, child: Text(course));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setSheetState(() => selectedCourse = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title input
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.taDiscussThreadTitle,
                    labelStyle: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: TAColors.scaffoldColor(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Content input
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.taDiscussThreadContent,
                    labelStyle: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: TAColors.scaffoldColor(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: TAColors.borderColor(isDark)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.taLabCancel,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            Navigator.pop(context);
                            setState(() {
                              _threads.insert(0, TADiscussionThread(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleController.text,
                                studentName: 'You (TA)',
                                preview: contentController.text,
                                tags: [selectedCourse, 'Announcement'],
                                replyCount: 0,
                                timeAgo: 'Just now',
                                status: TAThreadStatus.read,
                              ));
                            });
                            _showSnackBar('Thread created successfully!');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TAColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.taDiscussPost,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taDiscussTitle,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.taDiscussSubtitle,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
        ),
      ],
      floating: true,
      pinned: true,
    );
  }

  Widget _buildActionBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: l10n.taDiscussSearch,
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TAColors.textTertiaryColor(isDark),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Flagged
          _buildActionButton(
            icon: Icons.flag_outlined,
            label: l10n.taDiscussFlagged,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedFilter = _selectedFilter == 'flagged' ? 'all' : 'flagged';
              });
            },
            isActive: _selectedFilter == 'flagged',
          ),
          const SizedBox(width: 8),
          // AI Insights
          _buildActionButton(
            icon: Icons.auto_awesome,
            label: l10n.taDiscussAIInsights,
            isDark: isDark,
            onTap: () => _showSnackBar('AI Insights'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? TAColors.primary.withValues(alpha: 0.15)
                : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? TAColors.primary.withValues(alpha: 0.3)
                  : TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? TAColors.primary
                    : TAColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? TAColors.primary
                      : TAColors.textPrimaryColor(isDark),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'all', 'label': l10n.taDiscussAllThreads, 'icon': Icons.forum_outlined},
      {'id': 'unanswered', 'label': l10n.taDiscussUnanswered, 'icon': Icons.help_outline_rounded},
      {'id': 'my_replies', 'label': l10n.taDiscussMyReplies, 'icon': Icons.person_outline_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : TAColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String),
                ],
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : TAColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: TAColors.cardColor(isDark),
              selectedColor: TAColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? TAColors.primary
                    : TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                setState(() => _selectedFilter = filter['id'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThreadsList(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: CircularProgressIndicator(color: TAColors.primary),
          ),
        ),
      );
    }

    final threads = _filteredThreads;

    if (threads.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(isDark, l10n),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TADiscussionThreadCard(
            isDark: isDark,
            thread: threads[index],
            onTap: () => _showThreadDetailSheet(isDark, l10n, threads[index]),
          ),
          childCount: threads.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.taDiscussNoThreads,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taDiscussNoThreadsHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TAColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
