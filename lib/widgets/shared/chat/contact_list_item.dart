import 'package:flutter/material.dart';

import '../../../bloc/chat/chat_models.dart';

class ContactListItem extends StatelessWidget {
  final ChatUserModel user;
  final bool isOnline;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onAvatarTap;

  const ContactListItem({
    super.key,
    required this.user,
    required this.isOnline,
    required this.onTap,
    this.isSelected = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: GestureDetector(
        onTap: onAvatarTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.16,
              ),
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
      title: Text(
        user.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        user.email ?? (isOnline ? 'Online' : 'Offline'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
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
