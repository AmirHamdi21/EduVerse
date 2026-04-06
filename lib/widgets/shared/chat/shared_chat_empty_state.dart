import 'package:flutter/material.dart';

class SharedChatEmptyState extends StatelessWidget {
  final bool isDark;
  final bool isFiltered;
  final Color accentColor;
  final VoidCallback onStartNewChat;
  final VoidCallback onClearFilters;

  const SharedChatEmptyState({
    super.key,
    required this.isDark,
    required this.isFiltered,
    required this.accentColor,
    required this.onStartNewChat,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
              child: Icon(
                isFiltered
                    ? Icons.filter_alt_off_rounded
                    : Icons.forum_outlined,
                size: 44,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No matching conversations' : 'No conversations yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try another query or reset the filters.'
                  : 'Start a new chat to begin messaging.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Clear filters'),
              )
            else
              FilledButton.icon(
                onPressed: onStartNewChat,
                style: FilledButton.styleFrom(backgroundColor: accentColor),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Start a new chat'),
              ),
          ],
        ),
      ),
    );
  }
}
