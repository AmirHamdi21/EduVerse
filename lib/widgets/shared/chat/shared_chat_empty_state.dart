import 'package:flutter/material.dart';

class SharedChatEmptyState extends StatelessWidget {
  final bool isDark;
  final bool isFiltered;
  final bool isError;
  final bool isOffline;
  final String? searchQuery;
  final Color accentColor;
  final VoidCallback onStartNewChat;
  final VoidCallback onClearFilters;
  final VoidCallback? onRetry;

  const SharedChatEmptyState({
    super.key,
    required this.isDark,
    required this.isFiltered,
    this.isError = false,
    this.isOffline = false,
    this.searchQuery,
    required this.accentColor,
    required this.onStartNewChat,
    required this.onClearFilters,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedSearchQuery = searchQuery?.trim();
    final hasSearchQuery =
        normalizedSearchQuery != null && normalizedSearchQuery.isNotEmpty;

    IconData iconData;
    String title;
    String subtitle;
    String? actionLabel;
    IconData? actionIcon;
    VoidCallback? onAction;
    var isPrimaryAction = false;

    if (isError) {
      iconData = Icons.error_outline_rounded;
      title = 'Something went wrong';
      subtitle = "We couldn't load your conversations. Please try again.";
      actionLabel = 'Try again';
      actionIcon = Icons.refresh_rounded;
      onAction = onRetry;
      isPrimaryAction = true;
    } else if (isOffline) {
      iconData = Icons.wifi_off_rounded;
      title = "You're offline";
      subtitle = 'A connection is needed to load chats for the first time.';
    } else if (hasSearchQuery) {
      iconData = Icons.search_off_rounded;
      title = "No results for '$normalizedSearchQuery'";
      subtitle = 'Try a different search term.';
      actionLabel = 'Clear search';
      actionIcon = Icons.clear_rounded;
      onAction = onClearFilters;
    } else if (isFiltered) {
      iconData = Icons.filter_alt_off_rounded;
      title = 'No matching conversations';
      subtitle = 'Try another query or reset the filters.';
      actionLabel = 'Clear filters';
      actionIcon = Icons.restart_alt_rounded;
      onAction = onClearFilters;
    } else {
      iconData = Icons.forum_outlined;
      title = 'No conversations yet';
      subtitle = 'Start a new chat to begin messaging.';
      actionLabel = 'Start a new chat';
      actionIcon = Icons.add_rounded;
      onAction = onStartNewChat;
      isPrimaryAction = true;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 44, color: accentColor),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              if (actionLabel != null && onAction != null)
                isPrimaryAction
                    ? FilledButton.icon(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                        ),
                        icon: Icon(actionIcon),
                        label: Text(actionLabel),
                      )
                    : OutlinedButton.icon(
                        onPressed: onAction,
                        icon: Icon(actionIcon),
                        label: Text(actionLabel),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
