import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
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
      title = l10n.chatLoadFailedTitle;
      subtitle = l10n.chatLoadFailedSubtitle;
      actionLabel = l10n.tryAgain;
      actionIcon = Icons.refresh_rounded;
      onAction = onRetry;
      isPrimaryAction = true;
    } else if (isOffline) {
      iconData = Icons.wifi_off_rounded;
      title = l10n.chatOfflineTitle;
      subtitle = l10n.chatOfflineSubtitle;
    } else if (hasSearchQuery) {
      iconData = Icons.search_off_rounded;
      title = l10n.chatNoSearchResults(normalizedSearchQuery);
      subtitle = l10n.chatNoSearchResultsSubtitle;
      actionLabel = l10n.clearSearch;
      actionIcon = Icons.clear_rounded;
      onAction = onClearFilters;
    } else if (isFiltered) {
      iconData = Icons.filter_alt_off_rounded;
      title = l10n.chatNoFilteredResultsTitle;
      subtitle = l10n.chatNoFilteredResultsSubtitle;
      actionLabel = l10n.chatClearFiltersButton;
      actionIcon = Icons.restart_alt_rounded;
      onAction = onClearFilters;
    } else {
      iconData = Icons.mark_chat_read_rounded;
      title = l10n.chatEmptyTitle;
      subtitle = l10n.chatEmptySubtitle;
      actionLabel = l10n.chatStartNewChatButton;
      actionIcon = Icons.add_comment_rounded;
      onAction = onStartNewChat;
      isPrimaryAction = true;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      accentColor,
                      Color.lerp(accentColor, const Color(0xFF06B6D4), 0.30)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(iconData, size: 46, color: Colors.white),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              if (actionLabel != null && onAction != null)
                isPrimaryAction
                    ? FilledButton.icon(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: Icon(actionIcon),
                        label: Text(actionLabel),
                      )
                    : OutlinedButton.icon(
                        onPressed: onAction,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          side: BorderSide(
                            color: accentColor.withValues(alpha: 0.28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
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
