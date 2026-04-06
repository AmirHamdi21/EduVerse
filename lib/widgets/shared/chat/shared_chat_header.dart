import 'package:flutter/material.dart';

import '../../../bloc/chat/chat_state.dart';

class SharedChatHeader extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final ConnectionStatus connectionStatus;
  final bool isSearching;
  final VoidCallback onToggleSearch;
  final VoidCallback onNewChat;
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
    required this.onNewChat,
    this.title = 'Messages',
    this.leadingIcon,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _resolveStatus(connectionStatus);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (leadingIcon != null)
            IconButton(
              onPressed: onLeadingPressed,
              icon: Icon(
                leadingIcon,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              splashRadius: 22,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusData.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: statusData.color),
                      const SizedBox(width: 6),
                      Text(
                        statusData.label,
                        style: TextStyle(
                          color: statusData.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleSearch,
            icon: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isSearching
                  ? accentColor
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
            tooltip: isSearching ? 'Close search' : 'Search',
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: onNewChat,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New'),
          ),
        ],
      ),
    );
  }

  _StatusData _resolveStatus(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.live:
        return const _StatusData(label: 'Live', color: Color(0xFF16A34A));
      case ConnectionStatus.connecting:
        return const _StatusData(label: 'Connecting', color: Color(0xFFF59E0B));
      case ConnectionStatus.offline:
        return const _StatusData(label: 'Offline', color: Color(0xFFDC2626));
    }
  }
}

class _StatusData {
  final String label;
  final Color color;

  const _StatusData({required this.label, required this.color});
}
