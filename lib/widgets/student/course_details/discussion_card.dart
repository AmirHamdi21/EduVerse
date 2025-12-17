import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum UserRole { instructor, student }

class DiscussionPost {
  final String id;
  final String authorName;
  final String authorInitials;
  final Color avatarColor;
  final String content;
  final DateTime timestamp;
  int likes;
  int replies;
  final UserRole userRole;
  bool isLiked;

  DiscussionPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.avatarColor,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.replies,
    this.userRole = UserRole.student,
    this.isLiked = false,
  });
}

class DiscussionCard extends StatefulWidget {
  final DiscussionPost post;
  final bool isDark;
  final VoidCallback onCommentsPressed;
  final Function(bool) onLikePressed;

  const DiscussionCard({
    super.key,
    required this.post,
    required this.isDark,
    required this.onCommentsPressed,
    required this.onLikePressed,
  });

  @override
  State<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _likeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _likeController.dispose();
    super.dispose();
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
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  void _handleLikeTap() {
    widget.post.isLiked = !widget.post.isLiked;
    _likeController.forward(from: 0);
    widget.onLikePressed(widget.post.isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor =
        widget.isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565);
    final borderColor =
        widget.isDark ? const Color(0xFF3D3D54) : const Color(0xFFE5E7EB);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
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
            padding: const EdgeInsets.all(20),
            child: SlideTransition(
              position: _slideAnimation,
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
                                if (widget.post.userRole == UserRole.instructor)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDE9FE),
                                        borderRadius: BorderRadius.circular(8),
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
                  // Like and Comments buttons
                  Row(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: _handleLikeTap,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 1.2).animate(
                            CurvedAnimation(
                              parent: _likeController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.post.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: widget.post.isLiked
                                      ? const Color(0xFFFF6B6B)
                                      : secondaryTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.post.likes}',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Comments button
                      GestureDetector(
                        onTap: widget.onCommentsPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: secondaryTextColor,
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
    );
  }
}
