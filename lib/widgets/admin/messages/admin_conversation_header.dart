import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminConversationHeader extends StatelessWidget {
  final bool isDark;
  final String name;
  final String subtitle;
  final String avatar;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback? onCall;
  final VoidCallback? onVideoCall;
  final VoidCallback? onInfo;

  const AdminConversationHeader({
    super.key,
    required this.isDark,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.onBack,
    this.isOnline = false,
    this.onCall,
    this.onVideoCall,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? AdminColors.darkText : AdminColors.lightText,
              ),
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AdminColors.darkText : AdminColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (isOnline) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AdminColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          isOnline ? 'Online' : subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline
                                ? AdminColors.success
                                : (isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onCall != null)
              IconButton(
                icon: Icon(
                  Icons.call_rounded,
                  color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
                ),
                onPressed: onCall,
              ),
            if (onVideoCall != null)
              IconButton(
                icon: Icon(
                  Icons.videocam_rounded,
                  color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
                ),
                onPressed: onVideoCall,
              ),
            if (onInfo != null)
              IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
                ),
                onPressed: onInfo,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          avatar,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
