import 'package:flutter/material.dart';

import '../../../bloc/chat/chat_models.dart';
import '../../../generated_l10n/app_localizations.dart';

class FrequentlyContactedSection extends StatelessWidget {
  final List<ChatUserModel> users;
  final Set<int> onlineUsers;
  final ValueChanged<ChatUserModel> onUserTap;
  final ValueChanged<ChatUserModel>? onAvatarTap;
  final Color? accentColor;

  const FrequentlyContactedSection({
    super.key,
    required this.users,
    required this.onlineUsers,
    required this.onUserTap,
    this.onAvatarTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final effectiveAccent = accentColor ?? theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF111827)
        : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.chatFrequentlyContactedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                l10n.chatTapToStartLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
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
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: effectiveAccent.withValues(alpha: 0.10),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: effectiveAccent.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: onAvatarTap == null
                            ? null
                            : () => onAvatarTap!(user),
                        child: Stack(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    effectiveAccent,
                                    Color.lerp(
                                      effectiveAccent,
                                      const Color(0xFF06B6D4),
                                      0.28,
                                    )!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  _initials(user.displayName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cardColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          user.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isOnline
                            ? l10n.chatOnlineNow
                            : ((user.role ?? '').trim().isEmpty
                                  ? l10n.member
                                  : user.role!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOnline
                              ? const Color(0xFF16A34A)
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
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
