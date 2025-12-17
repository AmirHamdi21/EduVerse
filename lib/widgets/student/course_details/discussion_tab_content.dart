import 'package:flutter/material.dart';
import 'discussion_card.dart';

class DiscussionTabContent extends StatefulWidget {
  final bool isDark;

  const DiscussionTabContent({
    super.key,
    required this.isDark,
  });

  @override
  State<DiscussionTabContent> createState() => _DiscussionTabContentState();
}

class _DiscussionTabContentState extends State<DiscussionTabContent>
    with TickerProviderStateMixin {
  late List<DiscussionPost> posts;
  late AnimationController _inputController;
  late AnimationController _postsController;
  late Animation<double> _inputAnimation;
  late Animation<double> _postsAnimation;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePosts();

    _inputController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _postsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _inputAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeOut),
    );

    _postsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _postsController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        _postsController.forward();
      });
    });
  }

  void _initializePosts() {
    posts = [
      DiscussionPost(
        id: '1',
        authorName: 'Dr. Evelyn Reed',
        authorInitials: 'DER',
        avatarColor: const Color(0xFF9810FA),
        content:
            'Welcome to the course discussion! Feel free to ask questions about lectures, labs, or assignments.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        replies: 3,
        userRole: UserRole.instructor,
      ),
      DiscussionPost(
        id: '2',
        authorName: 'Sarah Chen',
        authorInitials: 'SC',
        avatarColor: const Color(0xFF155DFC),
        content:
            'Can someone explain the difference between supervised and unsupervised learning? I\'m a bit confused after today\'s lecture.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 5,
        replies: 2,
        userRole: UserRole.student,
      ),
      DiscussionPost(
        id: '3',
        authorName: 'Michael Torres',
        authorInitials: 'MT',
        avatarColor: const Color(0xFF155DFC),
        content:
            'The AI lab assignment is really interesting! Has anyone started working on the neural network implementation?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        likes: 8,
        replies: 4,
        userRole: UserRole.student,
      ),
    ];
  }

  void _handlePostMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newPost = DiscussionPost(
      id: DateTime.now().toString(),
      authorName: 'ME',
      authorInitials: 'ME',
      avatarColor: const Color(0xFF155DFC),
      content: _messageController.text,
      timestamp: DateTime.now(),
      likes: 0,
      replies: 0,
    );

    setState(() {
      posts.insert(0, newPost);
    });

    _messageController.clear();
  }

  void _handleLikeChanged(int index, bool isLiked) {
    setState(() {
      if (isLiked) {
        posts[index].likes++;
      } else {
        posts[index].likes--;
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _postsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor =
        widget.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565);
    final inputBgColor =
        widget.isDark ? const Color(0xFF3D3D54) : const Color(0xFFF3F4F6);
    final borderColor =
        widget.isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB);

    return Column(
      children: [
        // Message input area
        FadeTransition(
          opacity: _inputAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: borderColor,
                width: 1,
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // User avatar
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF155DFC),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text(
                        'ME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Input field
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask a question or share your thoughts...',
                          hintStyle: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                            fontFamily: 'Arimo',
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontFamily: 'Arimo',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send button
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF155DFC).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handlePostMessage,
                        borderRadius: BorderRadius.circular(14),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Discussion posts
        FadeTransition(
          opacity: _postsAnimation,
          child: Column(
            children: List.generate(
              posts.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == posts.length - 1 ? 0 : 16,
                ),
                child: DiscussionCard(
                  post: posts[index],
                  isDark: widget.isDark,
                  onCommentsPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          post: posts[index],
                          isDark: widget.isDark,
                        ),
                      ),
                    );
                  },
                  onLikePressed: (isLiked) {
                    _handleLikeChanged(index, isLiked);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Comments Screen
class CommentsScreen extends StatefulWidget {
  final DiscussionPost post;
  final bool isDark;

  const CommentsScreen({
    super.key,
    required this.post,
    required this.isDark,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen>
    with TickerProviderStateMixin {
  late List<Comment> comments;
  late AnimationController _screenController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeComments();

    _screenController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _screenController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenController.forward();
    });
  }

  void _initializeComments() {
    comments = [
      Comment(
        id: '1',
        authorName: 'Dr. Evelyn Reed',
        authorInitials: 'DER',
        avatarColor: const Color(0xFF9810FA),
        content: 'Great question! This is exactly what we\'ll cover in the next lecture.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        likes: 3,
        userRole: UserRole.instructor,
      ),
      Comment(
        id: '2',
        authorName: 'James Wilson',
        authorInitials: 'JW',
        avatarColor: const Color(0xFF155DFC),
        content: 'I had the same confusion initially. The key difference is...',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        likes: 5,
        userRole: UserRole.student,
      ),
      Comment(
        id: '3',
        authorName: 'Sarah Chen',
        authorInitials: 'SC',
        avatarColor: const Color(0xFF155DFC),
        content: 'Thanks so much! This really helped clarify things.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 1,
        userRole: UserRole.student,
      ),
    ];
  }

  void _handlePostReply() {
    if (_replyController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().toString(),
      authorName: 'You',
      authorInitials: 'YOU',
      avatarColor: const Color(0xFF155DFC),
      content: _replyController.text,
      timestamp: DateTime.now(),
      likes: 0,
    );

    setState(() {
      comments.add(newComment);
    });

    _replyController.clear();
  }

  @override
  void dispose() {
    _screenController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAFA);
    final surfaceColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor =
        widget.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565);
    final inputBgColor =
        widget.isDark ? const Color(0xFF3D3D54) : const Color(0xFFF3F4F6);
    final borderColor =
        widget.isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Discussion',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Arimo',
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            // Main post
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border.all(
                      color: borderColor,
                      width: 1,
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author and metadata
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: widget.post.avatarColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  widget.post.authorInitials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Author info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.post.authorName,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Arimo',
                                          ),
                                        ),
                                      ),
                                      if (widget.post.userRole ==
                                          UserRole.instructor)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEDE9FE),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Instructor',
                                              style: TextStyle(
                                                color: Color(0xFF8200DB),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Arimo',
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '· ${_formatTimestamp(widget.post.timestamp)}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Content
                        Text(
                          widget.post.content,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Arimo',
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Divider
                        Divider(
                          color: borderColor,
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        // Stats
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: const Color(0xFFFF6B6B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.likes} likes',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Arimo',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chat_bubble,
                              size: 16,
                              color: const Color(0xFF155DFC),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.replies} replies',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: borderColor,
                  height: 1,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            // Comments section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text(
                  'Replies (${comments.length})',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Arimo',
                  ),
                ),
              ),
            ),
            // Comments list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(bottom: 16),
                  child: _buildCommentCard(comments[index], textColor,
                      secondaryTextColor, borderColor, surfaceColor),
                ),
                childCount: comments.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
        bottomNavigationBar: Container(
          color: surfaceColor,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            children: [
              // User avatar
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF155DFC),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    'YOU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Input field
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      hintStyle: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        fontFamily: 'Arimo',
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontFamily: 'Arimo',
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send button
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF155DFC).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handlePostReply,
                    borderRadius: BorderRadius.circular(14),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(
    Comment comment,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
    Color surfaceColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author and metadata
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: comment.avatarColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      comment.authorInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Author info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              comment.authorName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ),
                          if (comment.userRole == UserRole.instructor)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Instructor',
                                  style: TextStyle(
                                    color: Color(0xFF8200DB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimestamp(comment.timestamp),
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              comment.content,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arimo',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Like button
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 14,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${comment.likes}',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}

class Comment {
  final String id;
  final String authorName;
  final String authorInitials;
  final Color avatarColor;
  final String content;
  final DateTime timestamp;
  int likes;
  final UserRole userRole;

  Comment({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.avatarColor,
    required this.content,
    required this.timestamp,
    required this.likes,
    this.userRole = UserRole.student,
  });
}
