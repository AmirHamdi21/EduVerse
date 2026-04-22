import 'package:flutter/material.dart';

import '../../../bloc/chat/chat_models.dart';

class FrequentlyContactedSection extends StatelessWidget {
  final List<ChatUserModel> users;
  final Set<int> onlineUsers;
  final ValueChanged<ChatUserModel> onUserTap;
  final ValueChanged<ChatUserModel>? onAvatarTap;

  const FrequentlyContactedSection({
    super.key,
    required this.users,
    required this.onlineUsers,
    required this.onUserTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Frequently Contacted',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isOnline = onlineUsers.contains(user.userId);

              return GestureDetector(
                onTap: () => onUserTap(user),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: onAvatarTap == null
                            ? null
                            : () => onAvatarTap!(user),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.16),
                              child: Text(
                                _initials(user.displayName),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _initials(String value) {
    final tokens = value
        .split(RegExp(r'\s+'))
        .where((entry) => entry.trim().isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return 'U';
    }

    if (tokens.length == 1) {
      final token = tokens.first;
      return token.length == 1
          ? token.toUpperCase()
          : token.substring(0, 2).toUpperCase();
    }

    return '${tokens.first[0]}${tokens[1][0]}'.toUpperCase();
  }
}
