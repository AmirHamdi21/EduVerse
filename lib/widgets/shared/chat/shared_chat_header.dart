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
    final secondaryText = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          borderRadius: BorderRadius.circular(28),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.34 : 0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -22,
              bottom: -34,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (leadingIcon != null)
                        _HeaderCircleButton(
                          icon: leadingIcon!,
                          onPressed: onLeadingPressed,
                          foregroundColor: Colors.white,
                        ),
                      if (leadingIcon != null) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.chatHubSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      _HeaderInfoChip(
                        icon: Icons.fiber_manual_record_rounded,
                        label: statusData.label,
                        backgroundColor: statusData.color.withValues(
                          alpha: 0.18,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      _HeaderInfoChip(
                        icon: Icons.bolt_rounded,
                        label: l10n.chatFastRepliesLabel,
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: Text(l10n.chatNewButton),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.chatHeaderHint,
                            style: TextStyle(
                              color: secondaryText.withValues(alpha: 0.98),
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
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
        icon: Icon(icon, color: foregroundColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
