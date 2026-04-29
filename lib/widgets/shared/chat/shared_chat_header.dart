import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/chat/chat_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SharedChatHeader extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final ConnectionStatus connectionStatus;
  final bool isSearching;
  final VoidCallback onToggleSearch;
  final Future<void> Function(int conversationId)? onConversationCreated;
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;

  const SharedChatHeader({
    super.key,
    required this.isDark,
    required this.accentColor,
    required this.connectionStatus,
    required this.isSearching,
    required this.onToggleSearch,
    this.onConversationCreated,
    this.title = 'Messages',
    this.leadingIcon,
    this.onLeadingPressed,
  });

  Future<void> _openNewConversation(BuildContext context) async {
    final conversationId = await context.push<int>('/messages/new');
    if (conversationId != null && conversationId > 0) {
      await onConversationCreated?.call(conversationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusData = _resolveStatus(l10n, connectionStatus);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              accentColor,
              Color.lerp(accentColor, Colors.white, 0.18)!,
              Color.lerp(accentColor, const Color(0xFF06B6D4), 0.28)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.28 : 0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -14,
              top: -16,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -18,
              bottom: -28,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (leadingIcon != null)
                        _HeaderCircleButton(
                          icon: leadingIcon!,
                          onPressed: onLeadingPressed,
                          foregroundColor: Colors.white,
                        ),
                      if (leadingIcon != null) const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.chatHubSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 11.5,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _HeaderCircleButton(
                        icon: isSearching
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        onPressed: onToggleSearch,
                        foregroundColor: Colors.white,
                        tooltip: isSearching
                            ? l10n.chatCloseSearchTooltip
                            : l10n.search,
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _openNewConversation(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: accentColor,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(l10n.chatNewButton),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: _HeaderInfoChip(
                          icon: Icons.fiber_manual_record_rounded,
                          label: statusData.label,
                          backgroundColor: statusData.color.withValues(
                            alpha: 0.18,
                          ),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: _HeaderInfoChip(
                          icon: Icons.bolt_rounded,
                          label: l10n.chatFastRepliesLabel,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusData _resolveStatus(AppLocalizations l10n, ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.live:
        return _StatusData(
          label: l10n.chatConnectionLive,
          color: const Color(0xFF22C55E),
        );
      case ConnectionStatus.connecting:
        return _StatusData(
          label: l10n.chatConnectionConnecting,
          color: const Color(0xFFFBBF24),
        );
      case ConnectionStatus.offline:
        return _StatusData(
          label: l10n.chatConnectionOffline,
          color: const Color(0xFFF97316),
        );
    }
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color foregroundColor;
  final String? tooltip;

  const _HeaderCircleButton({
    required this.icon,
    required this.onPressed,
    required this.foregroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        icon: Icon(icon, color: foregroundColor, size: 18),
      ),
    );
  }
}

class _HeaderInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _HeaderInfoChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusData {
  final String label;
  final Color color;

  const _StatusData({required this.label, required this.color});
}
